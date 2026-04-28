#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Colors
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ----------------------------
# Logging
# ----------------------------
log() {
    local level="$1"
    shift
    printf "[%s] %b%s%b\n" "$level" "$2" "$*" "$NC"
}

info() { printf "[INFO]  ${BLUE}%s${NC}\n" "$*"; }
ok() { printf "[OK] ${GREEN}%s${NC}\n" "$*"; }
warn() { printf "[WARN]  ${YELLOW}%s${NC}\n" "$*"; }
error() { printf "[ERROR] ${RED}%s${NC}\n" "$*" >&2; }

fail() {
    printf "[FAIL] ${RED}%s${NC}\n" "$*"
    exit 1
}

# ----------------------------
# Load config (shared)
# ----------------------------
load_config() {
    local config_file="$1"

    [[ -f "$config_file" ]] || {
        error "config file not found: $config_file"
        return 1
    }

    # shellcheck disable=SC1090
    source "$config_file"
}

# ----------------------------
# Package check
# ----------------------------
require_package() {
    local missing=()
    for pkg in "$@"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "Missing packages: ${missing[*]}"
        info "Installing: ${missing[*]}"
        pacman -S --noconfirm "${missing[@]}" || fail "Failed to install packages: ${missing[*]}"
        ok "Installed: ${missing[*]}"
    else
        info "All required packages already installed: $*"
    fi
}
