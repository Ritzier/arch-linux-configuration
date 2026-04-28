#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config "${CONFIG_FILE}"

# ---- Validate required variables ----
: "${SERVICES:?SERVICES is not set in config}"

for svc in "${SERVICES[@]}"; do
    svc="$(echo "${svc%.service}.service")"

    # # Check does `$svc` service is available TODO:
    # if ! systemctl list-unit-files --type=service --no-legend | awk '{print $1}' | grep -qx "${svc}"; then
    #     error "service not found: $svc"
    #     exit 1
    # fi

    # ---- Enable + start ----
    info "[+] enabling $svc"

    systemctl enable --now "$svc"

    # ---- Verify ----
    if systemctl is-active --quiet "$svc"; then
        ok "[✓] $svc is active"
    else
        error "[✗] $svc failed to start"
        exit 1
    fi
done
