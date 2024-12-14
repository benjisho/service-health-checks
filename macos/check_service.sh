#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: $0 <service-label>"
    echo "Example: $0 com.apple.screensharing"
    exit 1
fi

SERVICE="$1"

echo "=================================================="
echo "Checking status of: $SERVICE"
echo "=================================================="
# Check if the service is loaded and running
LAUNCHCTL_OUTPUT=$(launchctl list | grep -w "$SERVICE")

if [ -z "$LAUNCHCTL_OUTPUT" ]; then
    echo "Service $SERVICE not currently loaded/running."
else
    echo "Service is loaded. Details:"
    echo "$LAUNCHCTL_OUTPUT"
    echo
    # Print more details if available
    echo "Detailed launchctl info:"
    sudo launchctl print system/"$SERVICE" 2>/dev/null || echo "No detailed info found. May not be a system-level service."
fi
echo

echo "=================================================="
echo "Is the service enabled at startup?"
echo "=================================================="
# A rough check: look for a plist file in LaunchDaemons or LaunchAgents
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
        # Check if RunAtLoad is set
        RUN_AT_LOAD=$(defaults read "${PLIST%.plist}" RunAtLoad 2>/dev/null)
        echo "RunAtLoad: $RUN_AT_LOAD"
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
    # launchctl list output format: PID ExitCode Label
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
echo "You may inspect the service's plist file for 'LaunchEvents' or 'LaunchConstraints'."
echo

echo "=================================================="
echo "Recent logs for $SERVICE:"
echo "=================================================="
# Show last 10 minutes of logs for the service. Adjust as needed.
log show --last 10m --predicate "process == \"$SERVICE\"" --style syslog 2>/dev/null || echo "No recent logs found or no matching predicate."
