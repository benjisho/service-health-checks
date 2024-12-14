#!/usr/bin/env bash

# Check if the user provided a service name as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <service-name>"
    echo "Example: $0 sshd.service"
    exit 1
fi

SERVICE="$1"

echo "=================================================="
echo "Checking status of: $SERVICE"
echo "=================================================="
systemctl --no-pager status "$SERVICE"
echo

echo "=================================================="
echo "Is the service enabled (i.e., will it start on boot)?"
echo "=================================================="
systemctl --no-pager is-enabled "$SERVICE" 2>/dev/null || echo "Service not found or no information available."
echo

echo "=================================================="
echo "Current state (running, stopped, etc.)"
echo "=================================================="
systemctl --no-pager is-active "$SERVICE"
echo

echo "=================================================="
echo "Dependencies for $SERVICE:"
echo "=================================================="
systemctl --no-pager list-dependencies "$SERVICE"
echo

echo "=================================================="
echo "Recent logs for $SERVICE:"
echo "=================================================="
journalctl --no-pager -u "$SERVICE" -n 10
