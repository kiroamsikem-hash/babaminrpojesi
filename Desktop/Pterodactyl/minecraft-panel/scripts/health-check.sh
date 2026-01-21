#!/bin/bash

# Minecraft Ultra Panel - Health Check Script
# This script monitors the health of all panel components

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PANEL_DIR/logs/health-check.log"

# Source environment
if [[ -f "$PANEL_DIR/config.env" ]]; then
    source "$PANEL_DIR/config.env"
fi

# Configuration
CONTROLLER_URL="http://localhost:3000"
DAEMON_URL="http://localhost:8080"
MAX_FAILURES=3

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Check service status
check_service() {
    local service_name="$1"
    local check_command="$2"
    local restart_command="$3"

    if eval "$check_command"; then
        log "✓ $service_name is healthy"
        return 0
    else
        log "✗ $service_name is not healthy"
        return 1
    fi
}

# Check systemd service
check_systemd_service() {
    local service_name="$1"

    if systemctl is-active --quiet "$service_name" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check HTTP endpoint
check_http_endpoint() {
    local url="$1"
    local timeout="${2:-5}"

    if curl -f -s --max-time "$timeout" "$url" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check database connectivity
check_database() {
    if command -v psql &> /dev/null; then
        # Extract database connection info from DATABASE_URL
        local db_url="${DATABASE_URL:-postgresql://postgres:password@localhost:5432/minecraft_panel}"
        local db_name=$(echo "$db_url" | sed -n 's/.*\/\([^?]*\).*/\1/p')

        if PGPASSWORD="${db_url#*://*:}" PGPASSWORD="${PGPASSWORD%%@*}" \
           psql -h localhost -U postgres -d "$db_name" -c "SELECT 1;" > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Check Redis connectivity
check_redis() {
    if command -v redis-cli &> /dev/null; then
        if redis-cli -h localhost ping | grep -q "PONG"; then
            return 0
        fi
    fi
    return 1
}

# Check disk space
check_disk_space() {
    local threshold="${1:-90}"
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

    if [[ $usage -lt $threshold ]]; then
        return 0
    else
        log "WARNING: Disk usage is ${usage}%, threshold is ${threshold}%"
        return 1
    fi
}

# Check memory usage
check_memory() {
    local threshold="${1:-90}"
    local usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')

    if [[ $usage -lt $threshold ]]; then
        return 0
    else
        log "WARNING: Memory usage is ${usage}%, threshold is ${threshold}%"
        return 1
    fi
}

# Send alert
send_alert() {
    local message="$1"
    local level="${2:-warning}"

    log "ALERT [$level]: $message"

    # Discord alert
    if [[ -n "$DISCORD_WEBHOOK_URL" ]]; then
        curl -s -X POST "$DISCORD_WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "{\"content\": \"🚨 [$level] Minecraft Panel Alert: $message\"}" >> "$LOG_FILE" 2>&1
    fi

    # Slack alert
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        curl -s -X POST "$SLACK_WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "{\"text\": \"🚨 [$level] Minecraft Panel Alert: $message\"}" >> "$LOG_FILE" 2>&1
    fi
}

# Main health check
main() {
    local failures=0
    local alerts=()

    log "Starting health check..."

    # Check systemd services
    if ! check_service "Controller Service" "check_systemd_service aetherpanel-controller"; then
        ((failures++))
        alerts+=("Controller service is not running")
    fi

    if ! check_service "Daemon Service" "check_systemd_service aetherpanel-daemon"; then
        ((failures++))
        alerts+=("Daemon service is not running")
    fi

    # Check HTTP endpoints
    if ! check_service "Controller API" "check_http_endpoint $CONTROLLER_URL/health"; then
        ((failures++))
        alerts+=("Controller API is not responding")
    fi

    if ! check_service "Daemon API" "check_http_endpoint $DAEMON_URL/health"; then
        ((failures++))
        alerts+=("Daemon API is not responding")
    fi

    # Check databases
    if ! check_service "PostgreSQL Database" "check_database"; then
        ((failures++))
        alerts+=("PostgreSQL database is not accessible")
    fi

    if ! check_service "Redis Cache" "check_redis"; then
        ((failures++))
        alerts+=("Redis cache is not accessible")
    fi

    # Check system resources
    if ! check_service "Disk Space" "check_disk_space 90"; then
        alerts+=("Disk space is running low")
    fi

    if ! check_service "Memory Usage" "check_memory 90"; then
        alerts+=("Memory usage is running high")
    fi

    # Send alerts if there are failures
    if [[ ${#alerts[@]} -gt 0 ]]; then
        for alert in "${alerts[@]}"; do
            send_alert "$alert" "warning"
        done
    fi

    # Critical failure check
    if [[ $failures -ge $MAX_FAILURES ]]; then
        send_alert "Critical: $failures services are failing" "critical"
        log "CRITICAL: Too many services failing ($failures/$MAX_FAILURES)"
        exit 1
    fi

    log "Health check completed. Failures: $failures"
    exit 0
}

# Run main function
main "$@"