#!/usr/bin/env bash
set -u

if [ "${1:-}" = "" ]; then
    echo "Usage: $0 <service-label>"
    echo "Example: $0 com.apple.screensharing"
    exit 1
fi

if ! command -v launchctl >/dev/null 2>&1; then
    echo "Error: launchctl command not found. This script must run on macOS." >&2
    exit 1
fi

SERVICE="$1"

echo "=================================================="
echo "Checking status of: $SERVICE"
echo "=================================================="
LAUNCHCTL_OUTPUT=$(launchctl list | awk -v label="$SERVICE" '$3 == label { print $0 }')

if [ -z "$LAUNCHCTL_OUTPUT" ]; then
    echo "Service $SERVICE not currently loaded/running."
else
    echo "Service is loaded. Details:"
    echo "$LAUNCHCTL_OUTPUT"
    echo
    echo "Detailed launchctl info:"
    launchctl print "system/$SERVICE" 2>/dev/null \
        || launchctl print "gui/$(id -u)/$SERVICE" 2>/dev/null \
        || echo "No detailed info found."
fi
echo

echo "=================================================="
echo "Is the service enabled at startup?"
echo "=================================================="
PLIST_PATHS=(
    "/Library/LaunchDaemons/$SERVICE.plist"
    "/Library/LaunchAgents/$SERVICE.plist"
    "$HOME/Library/LaunchAgents/$SERVICE.plist"
)

ENABLED="No"
for PLIST in "${PLIST_PATHS[@]}"; do
    if [ -f "$PLIST" ]; then
        ENABLED="Yes"
        echo "Found: $PLIST"
        RUN_AT_LOAD=$(defaults read "${PLIST%.plist}" RunAtLoad 2>/dev/null || true)
        if [ -n "$RUN_AT_LOAD" ]; then
            echo "RunAtLoad: $RUN_AT_LOAD"
        else
            echo "RunAtLoad not explicitly set."
        fi
        break
    fi
done

if [ "$ENABLED" = "No" ]; then
    echo "No corresponding plist found. Possibly not enabled at startup."
fi
echo

echo "=================================================="
echo "Current state (running, stopped, etc.)"
echo "=================================================="
if [ -z "$LAUNCHCTL_OUTPUT" ]; then
    echo "The service is not running."
else
    PID=$(echo "$LAUNCHCTL_OUTPUT" | awk '{print $1}')
    if [ "$PID" = "-" ]; then
        echo "The service is loaded but not currently running (no PID)."
    else
        echo "The service is running with PID: $PID"
    fi
fi
echo

echo "=================================================="
echo "Dependencies for $SERVICE"
echo "=================================================="
echo "Dependency checks are not directly supported on macOS with launchctl."
echo "Inspect the service plist for related LaunchEvents/LaunchConstraints keys."
echo

echo "=================================================="
echo "Recent logs for $SERVICE:"
echo "=================================================="
if command -v log >/dev/null 2>&1; then
    log show --last 10m --predicate "eventMessage CONTAINS[c] \"$SERVICE\" OR process == \"$SERVICE\"" --style syslog 2>/dev/null \
        || echo "No recent logs found or no matching predicate."
else
    echo "log command not found. Skipping log retrieval."
fi
