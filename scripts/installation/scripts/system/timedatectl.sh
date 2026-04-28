#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config "${CONFIG_FILE}"

# -----------------------------
# Validate required variables
# -----------------------------
: "${TIMEZONE:?TIMEZONE is not set in config}"

# -----------------------------
# Configure system time
# -----------------------------
info "Configuring system time (timedatectl)"

timedatectl set-ntp true
timedatectl set-timezone "$TIMEZONE"

# -----------------------------
# Verification
# -----------------------------
if timedatectl status >/dev/null 2>&1; then
    ok "Timezone set to $TIMEZONE and NTP enabled"
else
    error "timedatectl verification failed"
    exit 1
fi
