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
systemctl status "$SERVICE"
echo

echo "=================================================="
echo "Is the service enabled (i.e., will it start on boot)?"
echo "=================================================="
systemctl is-enabled "$SERVICE" 2>/dev/null || echo "Service not found or no information available."
echo

echo "=================================================="
echo "Current state (running, stopped, etc.)"
echo "=================================================="
systemctl is-active "$SERVICE"
echo

echo "=================================================="
echo "Dependencies for $SERVICE:"
echo "=================================================="
systemctl list-dependencies "$SERVICE"
echo

echo "=================================================="
echo "Recent logs for $SERVICE:"
echo "=================================================="
# Adjust '-n 10' to show more or more lines of logs
journalctl -u "$SERVICE" -n 10
