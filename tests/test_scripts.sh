#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$message"
    else
        echo "Output was:"
        echo "$haystack"
        fail "$message"
    fi
}

test_linux_usage() {
    local output
    set +e
    output=$("$ROOT_DIR/linux/check_service.sh" 2>&1)
    local code=$?
    set -e
    [[ $code -eq 1 ]] || fail "linux usage exits 1"
    assert_contains "$output" "Usage:" "linux usage message"
}

test_linux_happy_path_with_stubs() {
    local tmpbin
    tmpbin=$(mktemp -d)
    cat > "$tmpbin/systemctl" <<'STUB'
#!/usr/bin/env bash
case "$2" in
  status) echo "ACTIVE" ;;
  is-enabled) echo "enabled" ;;
  is-active) echo "active" ;;
  list-dependencies) echo "dep-a.service" ;;
  *) echo "unknown" ;;
esac
STUB
    cat > "$tmpbin/journalctl" <<'STUB'
#!/usr/bin/env bash
echo "log line"
STUB
    chmod +x "$tmpbin/systemctl" "$tmpbin/journalctl"

    local output
    output=$(PATH="$tmpbin:$PATH" "$ROOT_DIR/linux/check_service.sh" demo.service)
    assert_contains "$output" "Checking status of: demo.service" "linux prints header"
    assert_contains "$output" "enabled" "linux shows enablement"
    assert_contains "$output" "log line" "linux shows logs"
}

test_macos_usage() {
    local output
    set +e
    output=$("$ROOT_DIR/macos/check_service.sh" 2>&1)
    local code=$?
    set -e
    [[ $code -eq 1 ]] || fail "macos usage exits 1"
    assert_contains "$output" "Usage:" "macos usage message"
}

test_macos_happy_path_with_stubs() {
    local tmpbin home_tmp
    tmpbin=$(mktemp -d)
    home_tmp=$(mktemp -d)
    mkdir -p "$home_tmp/Library/LaunchAgents"
    touch "$home_tmp/Library/LaunchAgents/com.example.demo.plist"

    cat > "$tmpbin/launchctl" <<'STUB'
#!/usr/bin/env bash
if [[ "$1" == "list" ]]; then
  printf "123 0 com.example.demo\n"
elif [[ "$1" == "print" ]]; then
  echo "print ok"
fi
STUB
    cat > "$tmpbin/defaults" <<'STUB'
#!/usr/bin/env bash
echo "1"
STUB
    cat > "$tmpbin/id" <<'STUB'
#!/usr/bin/env bash
echo "501"
STUB
    cat > "$tmpbin/log" <<'STUB'
#!/usr/bin/env bash
echo "log ok"
STUB
    chmod +x "$tmpbin/launchctl" "$tmpbin/defaults" "$tmpbin/id" "$tmpbin/log"

    local output
    output=$(HOME="$home_tmp" PATH="$tmpbin:$PATH" "$ROOT_DIR/macos/check_service.sh" com.example.demo)
    assert_contains "$output" "Service is loaded." "macos loaded service"
    assert_contains "$output" "RunAtLoad: 1" "macos run at load"
    assert_contains "$output" "log ok" "macos logs"
}

main() {
    test_linux_usage
    test_linux_happy_path_with_stubs
    test_macos_usage
    test_macos_happy_path_with_stubs
    echo "All tests passed"
}

main "$@"
