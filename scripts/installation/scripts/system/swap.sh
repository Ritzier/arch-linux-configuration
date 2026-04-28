#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_FILE="${1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config "${CONFIG_FILE}"

# ---- Validate required variables ----
: "${SWAP_SIZE:?SWAP_SIZE is not set in config}"

# ---- Validate format (e.g. 2GB, 4GB) ----
if [[ ! "$SWAP_SIZE" =~ ^[0-9]+GB$ ]]; then
    error "Invalid SWAP_SIZE format: $SWAP_SIZE (expected e.g. 2GB)"
    exit 1
fi

# ---- Check existing swap ----
if swapon --show 2>/dev/null | awk '{print $1}' | grep -qx "/swapfile"; then
    info "Swapfile already active, skipping."
    exit 0
fi

if [[ -f /swapfile ]]; then
    error "/swapfile exists but not active (inconsistent state)"
    exit 1
fi

info "[+] Creating swap: $SWAP_SIZE"

# ---- Convert GB -> MB ----
mb=$((${SWAP_SIZE%GB} * 1024))

# ---- Allocate swap ----
fallocate -l "${mb}M" /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

ok "Done created swap: $SWAP_SIZE"
