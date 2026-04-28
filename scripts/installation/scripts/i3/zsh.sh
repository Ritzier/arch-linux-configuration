#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

info "[+] Installing Oh My Zsh"

command -v curl >/dev/null || {
    error "[!] curl missing"
    exit 1
}

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "[✓] Already installed"
    exit 0
fi

RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ok "ZSH configuration"
