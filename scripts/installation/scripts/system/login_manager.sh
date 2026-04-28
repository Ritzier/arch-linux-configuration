#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config "${CONFIG_FILE}"

# ---- Validate required variables ----
: "${LOGIN_MANAGER:?LOGIN_MANAGER is not set in config}"

require_package "${LOGIN_MANAGER}"

# Check does `$LOGIN_MANAGER` service is available
if ! systemctl status "${LOGIN_MANAGER}.service" >/dev/null 2>&1; then
    error "service not found: $LOGIN_MANAGER"
    exit 1
fi

# ---- Enable + start ----
info "[+] enabling $LOGIN_MANAGER"

systemctl enable --now "$LOGIN_MANAGER"

# ---- Verify ----
if systemctl is-active --quiet "$LOGIN_MANAGER"; then
    ok "[✓] $LOGIN_MANAGER is active"
else
    error "[✗] $LOGIN_MANAGER failed to start"
    exit 1
fi
