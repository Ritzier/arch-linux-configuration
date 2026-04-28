#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

zsh_theme_file="$HOME/.oh-my-zsh/themes/ritz.zsh-theme"
url="https://raw.githubusercontent.com/ritzier/ritz.zsh-theme/master/ritz.zsh-theme"

# Ensure target directory exists
mkdir -p "$(dirname "$zsh_theme_file")"

# Only download if file does not exist
if [[ ! -f "$zsh_theme_file" ]]; then
    info "[+] Installing ritz zsh theme..."
    if curl -fsSL "$url" -o "$zsh_theme_file"; then
        ok "[✓] Theme installed"
    else
        error "[✗] Failed to download theme" >&2
        exit 1
    fi
else
    info "[=] Theme already exists: $zsh_theme_file"
fi
