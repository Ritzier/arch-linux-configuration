#!/usr/bin/env bash
set -euo pipefail

PACKAGE_FILE="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

[[ -f "$PACKAGE_FILE" ]] || {
    error "Package list not found: $PACKAGE_FILE"
    exit 1
}

# Read package list (strip comments and empty lines)
packages=()
while IFS= read -r pkg; do
    [[ -n "$pkg" ]] && packages+=("$pkg")
done < <(sed 's/#.*//' "$PACKAGE_FILE" | xargs -n1)

info "Total packages listed: ${#packages[@]}"

missing=()

# Check installed packages
for pkg in "${packages[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        missing+=("$pkg")
    fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
    info "All packages already installed."
    exit 0
fi

info "Missing packages: ${missing[*]}"

# ---- Install missing packages ----
paru -S --needed --noconfirm "${missing[@]}"

info "Done"
