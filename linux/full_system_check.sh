#!/usr/bin/env bash

set -euo pipefail

TOP_COUNT="${TOP_COUNT:-5}"

if ! [[ "$TOP_COUNT" =~ ^[1-9][0-9]*$ ]]; then
    echo "TOP_COUNT must be a positive integer (current: $TOP_COUNT)." >&2
    exit 1
fi

print_section() {
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

print_section "Top ${TOP_COUNT} services by CPU, memory, and I/O (systemd cgroups)"
if command -v systemd-cgtop >/dev/null 2>&1; then
    CGROUP_OUTPUT="$(systemd-cgtop -b -n 1 --depth=1 2>/dev/null || true)"
    SERVICE_LINES="$(printf '%s\n' "$CGROUP_OUTPUT" | grep -E '\\.(service|slice)([[:space:]]|$)' || true)"

    if [ -n "$SERVICE_LINES" ]; then
        printf '%s\n' "$SERVICE_LINES" | head -n "$TOP_COUNT"
    else
        echo "No per-service cgroup data available in this environment."
        echo "(This is common in minimal containers without full systemd integration.)"
    fi
else
    echo "systemd-cgtop not found. Falling back to process-level summaries below."
fi
echo

print_section "Top ${TOP_COUNT} CPU-consuming processes"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n "$((TOP_COUNT + 1))"
echo

print_section "Top ${TOP_COUNT} memory-consuming processes"
ps -eo pid,comm,%mem,rss --sort=-%mem | head -n "$((TOP_COUNT + 1))"
echo

print_section "Top ${TOP_COUNT} network-consuming processes/services"
if command -v nethogs >/dev/null 2>&1; then
    echo "Using nethogs in text mode (short sample)."
    nethogs -t -c 3 2>/dev/null \
        | awk '
            /\t/ {
                split($0, parts, "\t")
                name = parts[1]
                sent = parts[2] + 0
                recv = parts[3] + 0
                total[name] += sent + recv
            }
            END {
                if (length(total) == 0) {
                    print "No nethogs process data available (try running as root)."
                    exit
                }
                for (name in total) {
                    printf "%-30s %.2f KB/s\n", name, total[name]
                }
            }
        ' | sort -k2 -nr | head -n "$TOP_COUNT"
elif command -v ss >/dev/null 2>&1; then
    echo "nethogs not found. Showing process socket counts with ss (activity proxy)."
    ss -tunp 2>/dev/null \
        | awk '
            NR > 1 && match($0, /users:\(\("([^"]+)"/, m) { counts[m[1]]++ }
            END {
                if (length(counts) == 0) {
                    print "No process socket data available (try running as root)."
                    exit
                }
                for (name in counts) {
                    printf "%7d %s\n", counts[name], name
                }
            }
        ' | sort -nr | head -n "$TOP_COUNT"
else
    echo "Neither nethogs nor ss is available for network activity checks."
fi
echo

print_section "Top ${TOP_COUNT} I/O-consuming processes"
if command -v iotop >/dev/null 2>&1; then
    iotop -b -n 1 -o 2>/dev/null | head -n "$((TOP_COUNT + 2))" \
        || echo "Unable to read iotop output (try running as root)."
elif command -v pidstat >/dev/null 2>&1; then
    pidstat -d 1 1 | head -n "$((TOP_COUNT + 4))"
else
    echo "Neither iotop nor pidstat is available to report per-process I/O."
    echo "Install iotop (iotop) or sysstat (pidstat) for detailed I/O metrics."
fi
echo

print_section "Top filesystems by disk usage"
df -hP | awk 'NR==1 || $2 ~ /[0-9]/ {print}' | sort -k5 -rh | head -n "$((TOP_COUNT + 1))"
