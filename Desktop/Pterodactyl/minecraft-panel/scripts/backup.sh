#!/bin/bash

# Minecraft Ultra Panel - Automated Backup Script
# This script creates backups of all running servers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PANEL_DIR/logs/backup.log"

# Source environment
if [[ -f "$PANEL_DIR/config.env" ]]; then
    source "$PANEL_DIR/config.env"
fi

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Check if services are running
check_services() {
    if ! pgrep -f "minecraft-controller" > /dev/null; then
        log "WARNING: Controller service not running"
    fi

    if ! pgrep -f "minecraft-daemon" > /dev/null; then
        log "WARNING: Daemon service not running"
    fi
}

# Create database backup
backup_database() {
    log "Creating PostgreSQL database backup..."

    BACKUP_FILE="$PANEL_DIR/backups/database-$(date +%Y%m%d-%H%M%S).sql"

    if command -v pg_dump &> /dev/null; then
        PGPASSWORD="${DATABASE_URL#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
        pg_dump "${DATABASE_URL}" > "$BACKUP_FILE" 2>> "$LOG_FILE"

        if [[ -f "$BACKUP_FILE" ]]; then
            gzip "$BACKUP_FILE"
            log "Database backup created: ${BACKUP_FILE}.gz"
        else
            log "ERROR: Database backup failed"
        fi
    else
        log "WARNING: pg_dump not found, skipping database backup"
    fi
}

# Create server backups via API
backup_servers() {
    log "Creating server backups..."

    # Get list of servers from API
    if command -v curl &> /dev/null; then
        SERVERS=$(curl -s -H "Authorization: Bearer ${JWT_SECRET:-test}" \
                     "http://localhost:3000/api/servers" 2>/dev/null | \
                  jq -r '.servers[].id' 2>/dev/null || echo "")

        for server_id in $SERVERS; do
            if [[ -n "$server_id" && "$server_id" != "null" ]]; then
                log "Backing up server: $server_id"
                curl -s -X POST \
                     -H "Authorization: Bearer ${JWT_SECRET:-test}" \
                     -H "Content-Type: application/json" \
                     "http://localhost:3000/api/backups/$server_id" \
                     -d "{\"name\": \"auto-backup-$(date +%Y%m%d-%H%M%S)\"}" >> "$LOG_FILE" 2>&1
            fi
        done
    else
        log "WARNING: curl not found, skipping server backups"
    fi
}

# Upload backups to S3 (if configured)
upload_to_s3() {
    if [[ -n "$AWS_ACCESS_KEY_ID" && -n "$AWS_S3_BUCKET_NAME" ]]; then
        log "Uploading backups to S3..."

        if command -v aws &> /dev/null; then
            # Upload database backups
            aws s3 sync "$PANEL_DIR/backups/" "s3://$AWS_S3_BUCKET_NAME/backups/" \
                --exclude "*" --include "database-*.sql.gz" >> "$LOG_FILE" 2>&1

            # Upload server backups
            aws s3 sync "$PANEL_DIR/backups/" "s3://$AWS_S3_BUCKET_NAME/backups/" \
                --exclude "*" --include "backup-*.zip" >> "$LOG_FILE" 2>&1

            log "Backups uploaded to S3"
        else
            log "WARNING: AWS CLI not found, skipping S3 upload"
        fi
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."

    # Keep only last 30 days of local backups
    find "$PANEL_DIR/backups/" -name "*.sql.gz" -mtime +30 -delete 2>/dev/null || true
    find "$PANEL_DIR/backups/" -name "*.zip" -mtime +30 -delete 2>/dev/null || true

    log "Old backups cleaned up"
}

# Send notification (if configured)
send_notification() {
    local message="$1"
    local level="${2:-info}"

    log "Sending notification: $message"

    # Discord notification
    if [[ -n "$DISCORD_WEBHOOK_URL" ]]; then
        curl -s -X POST "$DISCORD_WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "{\"content\": \"[$level] Minecraft Panel Backup: $message\"}" >> "$LOG_FILE" 2>&1
    fi

    # Slack notification
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        curl -s -X POST "$SLACK_WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "{\"text\": \"[$level] Minecraft Panel Backup: $message\"}" >> "$LOG_FILE" 2>&1
    fi
}

# Main backup process
main() {
    log "Starting automated backup process..."

    check_services
    backup_database
    backup_servers
    upload_to_s3
    cleanup_old_backups

    log "Backup process completed successfully"
    send_notification "Automated backup completed successfully" "success"
}

# Run main function
main "$@"