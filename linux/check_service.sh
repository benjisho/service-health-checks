#!/usr/bin/env bash
set -u

if [ "${1:-}" = "" ]; then
    echo "Usage: $0 <service-name>"
    echo "Example: $0 sshd.service"
    exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
    echo "Error: systemctl command not found. This script requires systemd." >&2
    exit 1
fi

SERVICE="$1"

echo "=================================================="
echo "Checking status of: $SERVICE"
echo "=================================================="
if ! systemctl --no-pager status "$SERVICE"; then
    echo "Warning: Could not retrieve full status for $SERVICE."
fi
echo

echo "=================================================="
echo "Is the service enabled (i.e., will it start on boot)?"
echo "=================================================="
if ! systemctl --no-pager is-enabled "$SERVICE" 2>/dev/null; then
    echo "Service not found, disabled, or no enablement information available."
fi
echo

echo "=================================================="
echo "Current state (running, stopped, etc.)"
echo "=================================================="
if ! systemctl --no-pager is-active "$SERVICE"; then
    echo "Service is not active or not found."
fi
echo

echo "=================================================="
echo "Dependencies for $SERVICE:"
echo "=================================================="
if ! systemctl --no-pager list-dependencies "$SERVICE"; then
    echo "Dependency information not available for $SERVICE."
fi
echo

echo "=================================================="
echo "Recent logs for $SERVICE:"
echo "=================================================="
if command -v journalctl >/dev/null 2>&1; then
    if ! journalctl --no-pager -u "$SERVICE" -n 10; then
        echo "No recent logs available for $SERVICE or insufficient permissions."
    fi
else
    echo "journalctl command not found. Skipping log retrieval."
fi
