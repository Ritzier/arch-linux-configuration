#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/../config/surface_system.conf"
PACKAGES="$SCRIPT_DIR/../packages/surface_system"

# Load `common` utils
source "$SCRIPT_DIR/system/common.sh"

# Load `config`
load_config "$CONFIG"

# Required fields
FIELDS=(
    HOSTNAME
    SWAP_SIZE
    EFINAME
    LOGIN_MANAGER
    GPU
    SERVICES
    LANG
    KEYMAP
    TIMEZONE
)
for f in "${FIELDS[@]}"; do
    [[ -n "${!f:-}" ]] || fail "missing field: $f "
done

# Surface Pacman Repo
bash "$SCRIPT_DIR/system/surface/surface_repo"

# ---- Install packages ----
bash "$SCRIPT_DIR/system/packages.sh" "$PACKAGES"

# ---- Hostname ----
bash "$SCRIPT_DIR/system/hostname.sh" "$CONFIG"

# ---- Swap ----
bash "$SCRIPT_DIR/system/swap.sh" "$CONFIG"

# ---- GPU ----
bash "$SCRIPT_DIR/system/gpu.sh" "$CONFIG"

# ---- ZRAM ----
bash "$SCRIPT_DIR/system/zram.sh"

# ---- EFI (surface) ----
bash "$SCRIPT_DIR/system/surface/efibootmgr.sh" "$CONFIG"

# ---- Network ----
bash "$SCRIPT_DIR/system/network_performance.sh"

# ---- Hard Disk Scheduler ----
bash "$SCRIPT_DIR/system/hard_disk_scheduler.sh"

# ---- Login Manager ----
bash "$SCRIPT_DIR/system/login_manager.sh" "$CONFIG"

# ---- Lang ----
bash "$SCRIPT_DIR/system/lang.sh" "$CONFIG"

# ---- TIMEZONE ----
bash "$SCRIPT_DIR/system/timedatectl.sh" "$CONFIG"

# ---- Fcitx5 ----
bash "$SCRIPT_DIR/system/fcitx5.sh" "$CONFIG"

# ---- Systemctl ----
bash "$SCRIPT_DIR/system/systemctl.sh" "$CONFIG"
