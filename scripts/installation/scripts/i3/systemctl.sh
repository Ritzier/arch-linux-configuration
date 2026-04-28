#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

load_config "${CONFIG_FILE}"

# ---- Validate required variables ----
: "${SERVICES:?SERVICES is not set in config}"

for svc in "${SERVICES[@]}"; do
    svc="$(echo "${svc%.service}.service")"

    # ---- Enable + start ----
    info "[+] enabling $svc"

    systemctl --user enable --now "$svc"

    # ---- Verify ----
    if systemctl --user is-active --quiet "$svc"; then
        ok "[✓] $svc is active"
    else
        error "[✗] $svc failed to start"
        exit 1
    fi
done
