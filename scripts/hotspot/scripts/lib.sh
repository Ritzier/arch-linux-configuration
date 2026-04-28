#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    source "$SCRIPT_DIR/require_root.sh"

    if source "$SCRIPT_DIR/is_service_running.sh"; then
        exit 1
    fi

    source "$SCRIPT_DIR/health.sh"
    source "$SCRIPT_DIR/setup_nat.sh"
    source "$SCRIPT_DIR/config.sh"
    source "$SCRIPT_DIR/serve.sh"
}

stop_() {
    source "$SCRIPT_DIR/require_root.sh"

    source "$SCRIPT_DIR/stop_serve.sh"
}
