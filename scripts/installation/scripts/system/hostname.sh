#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config "${CONFIG_FILE}"

# ---- Validate required variables ----
: "${HOSTNAME:?HOSTNAME is not set in config}"

# Apply hostname
hostnamectl set-hostname "$HOSTNAME"

ok "Hostname set to '$HOSTNAME'"
