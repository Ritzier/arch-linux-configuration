#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/lib.sh"

# ----------------------------
# Entry
# ----------------------------
case "${1:-}" in
stop)
    stop_
    ;;
*)
    main
    ;;
esac
