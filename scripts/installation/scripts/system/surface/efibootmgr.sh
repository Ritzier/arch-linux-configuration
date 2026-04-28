#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Check packages
require_package efibootmgr

load_config "${CONFIG_FILE}"

# ---- Validate required variables ----
: "${EFINAME:?EFINAME is not set in config}"
: "${UCODE:?UCODE is not set in config}"

# ---- Check if $EFINAME already exists ----
if efibootmgr | grep -q "$EFINAME"; then
    info "EFI entry '$EFINAME' already exists"
    exit 0
fi

# ---- Extract UUIDs ----
root_uuid="$(findmnt -no UUID /)"
boot_uuid="$(findmnt -no UUID /boot)"

if [[ -z "$root_uuid" || -z "$boot_uuid" ]]; then
    error "Failed to extract UUIDs from /etc/fstab"
    exit 1
fi

# 3. Resolve partition
boot_part="$(blkid -U "$boot_uuid" 2>/dev/null || true)"

if [[ -z "$boot_part" ]]; then
    error "Cannot resolve boot partition"
    exit 1
fi

# Get parent disk
disk_name="$(lsblk -no PKNAME "$boot_part")"
[[ -n "$disk_name" ]] || {
    error "Failed to resolve parent disk"
    exit 1
}
disk="/dev/$disk_name"

# extract partition number without PARTNUM
part="$(basename "$boot_part" | grep -o '[0-9]*$')"

if [[ -z "$part" ]]; then
    error "Failed to determine partition number"
    exit 1
fi

info "disk: $disk"
info "part: $part"

# ---- Build initrd + kernel parmas ----
required_files=(
    "vmlinuz-linux-surface"
    "initramfs-linux-surface.img"
)

initrds=()
cmdline="root=UUID=$root_uuid rw"

# Microcode (must be first)
case "$UCODE" in
intel) initrds+=("\\intel-ucode.img") required_files+=("intel-ucode.img") ;;
amd) initrds+=("\\amd-ucode.img") required_files+=("amd-ucode.img") ;;
esac

# Check files
for f in "${required_files[@]}"; do
    [[ -f "/boot/$f" ]] || {
        error "Missing EFI file: $f"
        exit 1
    }
done

# Main initramfs
initrds+=('\initramfs-linux-surface.img')

# Nvidia DRM
if [[ "${GPU:-}" == "nvidia" ]]; then
    cmdline+=" nvidia-drm.modeset=1"
fi

initrd_args=""
for img in "${initrds[@]}"; do
    initrd_args+="initrd=${img} "
done

echo "[INFO] cmdline: $cmdline"
echo "[INFO] initrds: ${initrds[*]}"

efibootmgr --create \
    --disk "$disk" \
    --part "$part" \
    --label "$EFINAME" \
    --loader '\vmlinuz-linux-surface' \
    --unicode "${cmdline} ${initrd_args}" \
    --verbose
