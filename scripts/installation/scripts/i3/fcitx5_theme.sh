#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

repo_dir="/tmp/catppuccin-fcitx5"
target_dir="$HOME/.local/share/fcitx5/themes"

info "[+] Installing Catppuccin fcitx5 theme"

# -----------------------------
# 0. Idempotency check
# -----------------------------
if [[ -d "$target_dir/catppuccin-frappe-pink" ]]; then
    ok "[✓] Theme already installed"
    exit 0
fi

# -----------------------------
# 1. Clone repo safely
# -----------------------------
rm -rf "$repo_dir"

if ! git clone https://github.com/catppuccin/fcitx5.git "$repo_dir"; then
    error "[!] Failed to clone repository"
    exit 1
fi

# -----------------------------
# 2. Install correctly
# -----------------------------
mkdir -p "$target_dir"

if [[ -d "$repo_dir/src/" ]]; then
    cp -r $repo_dir/src/* "$target_dir/"
    ok "[✓] Theme installed"
else
    error "[!] Invalid repo structure"
    rm -rf "$repo_dir"
    exit 1
fi

# -----------------------------
# 3. Cleanup
# -----------------------------
rm -rf "$repo_dir"
