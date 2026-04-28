#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config "${CONFIG_FILE}"

# ---- Validate required variables ----
: "${GPU:?GPU is not set in config}"

# -----------------------------
# GPU package selection
# -----------------------------
packages=()
libva_driver=""

case "$GPU" in

nvidia)
    info "Nvidia GPU stack..."

    packages+=(
        nvidia-open-dkms
        nvidia-utils
        nvidia-settings
        libva
        libva-utils
    )
    libva_driver="nvidia"
    ;;

amd)
    info "[+] AMD GPU stack..."

    packages+=(
        mesa
        libva
        libva-utils
        libva-mesa-driver
        vulkan-radeon
    )

    libva_driver="radeonsi"
    ;;

intel)
    info "[+] Intel GPU stack..."

    packages+=(
        mesa
        libva
        libva-utils
        intel-media-driver
        vulkan-intel
    )

    libva_driver="iHD"
    ;;

*)
    error "[!] Unknown GPU: $GPU"
    exit 1
    ;;
esac

# -----------------------------
# Package validation / install
# -----------------------------
require_package "${packages[@]}"

# -----------------------------
# VA-API configuration
# -----------------------------
mkdir -p /etc/environment.d

install -Dm644 /dev/stdin /etc/environment.d/90-gpu.conf <<EOF
LIBVA_DRIVER_NAME=${libva_driver}
EOF

# -----------------------------
# NVIDIA DRM configuration
# -----------------------------
if [ "$GPU" = "nvidia" ]; then
    info "Enabling NVIDIA DRM modeset..."

    cat >/etc/modprobe.d/nvidia-drm.conf <<EOF
options nvidia_drm modeset=1
EOF
else
    # ensure cleanup of NVIDIA-specific config if switching GPU
    rm -f /etc/modprobe.d/nvidia-drm.conf
fi
