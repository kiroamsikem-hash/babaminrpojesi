#!/bin/bash

# Minecraft Ultra Panel - Database Maintenance Script
# This script performs database optimization and cleanup tasks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PANEL_DIR/logs/db-maintenance.log"

# Source environment
if [[ -f "$PANEL_DIR/config.env" ]]; then
    source "$PANEL_DIR/config.env"
fi

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# PostgreSQL maintenance functions
vacuum_analyze() {
    log "Running VACUUM ANALYZE on database..."

    local db_url="${DATABASE_URL:-postgresql://postgres:password@localhost:5432/minecraft_panel}"
    local db_name=$(echo "$db_url" | sed -n 's/.*\/\([^?]*\).*/\1/p')

    if PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
       psql -h localhost -U postgres -d "$db_name" -c "VACUUM ANALYZE;" >> "$LOG_FILE" 2>&1; then
        log "VACUUM ANALYZE completed successfully"
    else
        log "ERROR: VACUUM ANALYZE failed"
        return 1
    fi
}

reindex_database() {
    log "Reindexing database..."

    local db_url="${DATABASE_URL:-postgresql://postgres:password@localhost:5432/minecraft_panel}"
    local db_name=$(echo "$db_url" | sed -n 's/.*\/\([^?]*\).*/\1/p')

    if PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
       psql -h localhost -U postgres -d "$db_name" -c "REINDEX DATABASE $db_name;" >> "$LOG_FILE" 2>&1; then
        log "Database reindexing completed successfully"
    else
        log "ERROR: Database reindexing failed"
        return 1
    fi
}

cleanup_old_data() {
    log "Cleaning up old data..."

    local db_url="${DATABASE_URL:-postgresql://postgres:password@localhost:5432/minecraft_panel}"
    local db_name=$(echo "$db_url" | sed -n 's/.*\/\([^?]*\).*/\1/p')

    # Delete old session data (older than 30 days)
    PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
    psql -h localhost -U postgres -d "$db_name" -c "
        DELETE FROM user_sessions WHERE \"createdAt\" < NOW() - INTERVAL '30 days';
    " >> "$LOG_FILE" 2>&1

    # Delete old audit logs (older than 90 days)
    PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
    psql -h localhost -U postgres -d "$db_name" -c "
        DELETE FROM audit_logs WHERE \"createdAt\" < NOW() - INTERVAL '90 days';
    " >> "$LOG_FILE" 2>&1

    # Delete old server stats (older than 30 days)
    PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
    psql -h localhost -U postgres -d "$db_name" -c "
        DELETE FROM server_stats WHERE \"updatedAt\" < NOW() - INTERVAL '30 days';
    " >> "$LOG_FILE" 2>&1

    log "Old data cleanup completed"
}

optimize_tables() {
    log "Optimizing database tables..."

    local db_url="${DATABASE_URL:-postgresql://postgres:password@localhost:5432/minecraft_panel}"
    local db_name=$(echo "$db_url" | sed -n 's/.*\/\([^?]*\).*/\1/p')

    # Get list of tables and optimize them
    PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
    psql -h localhost -U postgres -d "$db_name" -c "
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename;
    " | while read -r schema table; do
        if [[ "$table" != "tablename" && -n "$table" ]]; then
            log "Optimizing table: $table"
            PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
            psql -h localhost -U postgres -d "$db_name" -c "VACUUM ANALYZE \"$table\";" >> "$LOG_FILE" 2>&1
        fi
    done

    log "Table optimization completed"
}

check_database_health() {
    log "Checking database health..."

    local db_url="${DATABASE_URL:-postgresql://postgres:password@localhost:5432/minecraft_panel}"
    local db_name=$(echo "$db_url" | sed -n 's/.*\/\([^?]*\).*/\1/p')

    # Check for table bloat
    PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
    psql -h localhost -U postgres -d "$db_name" -c "
        SELECT schemaname, tablename,
               pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
               pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as data_size
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
        LIMIT 10;
    " >> "$LOG_FILE" 2>&1

    # Check for long-running queries
    PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
    psql -h localhost -U postgres -d "$db_name" -c "
        SELECT pid, age(clock_timestamp(), query_start), usename, query
        FROM pg_stat_activity
        WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%'
        ORDER BY query_start DESC
        LIMIT 5;
    " >> "$LOG_FILE" 2>&1

    log "Database health check completed"
}

backup_before_maintenance() {
    log "Creating pre-maintenance backup..."

    local backup_file="$PANEL_DIR/backups/pre-maintenance-$(date +%Y%m%d-%H%M%S).sql"

    local db_url="${DATABASE_URL:-postgresql://postgres:password@localhost:5432/minecraft_panel}"

    if PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
       pg_dump "$db_url" > "$backup_file" 2>> "$LOG_FILE"; then
        gzip "$backup_file"
        log "Pre-maintenance backup created: ${backup_file}.gz"
    else
        log "WARNING: Pre-maintenance backup failed"
    fi
}

# Send notification
send_notification() {
    local message="$1"
    local status="${2:-success}"

    log "Sending maintenance notification: $message"

    # Discord notification
    if [[ -n "$DISCORD_WEBHOOK_URL" ]]; then
        curl -s -X POST "$DISCORD_WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "{\"content\": \"🔧 Database Maintenance [$status]: $message\"}" >> "$LOG_FILE" 2>&1
    fi

    # Slack notification
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        curl -s -X POST "$SLACK_WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "{\"text\": \"🔧 Database Maintenance [$status]: $message\"}" >> "$LOG_FILE" 2>&1
    fi
}

# Main maintenance function
main() {
    log "Starting database maintenance..."

    # Pre-maintenance backup
    backup_before_maintenance

    # Perform maintenance tasks
    vacuum_analyze
    reindex_database
    cleanup_old_data
    optimize_tables
    check_database_health

    log "Database maintenance completed successfully"
    send_notification "Database maintenance completed successfully" "success"
}

# Run main function with error handling
if main "$@"; then
    log "Database maintenance completed without errors"
    exit 0
else
    log "Database maintenance completed with errors"
    send_notification "Database maintenance completed with errors" "warning"
    exit 1
fi