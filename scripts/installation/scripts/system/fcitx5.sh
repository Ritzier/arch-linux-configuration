#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# require_package fcitx5-im fcitx5-chinese-addons
# Extract `fcitx5-im`
require_package fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-chinese-addons

info "[+] Configuring Fcitx5 environment (system-wide)"

conf_file="/etc/environment.d/90-fcitx5.conf"

# -----------------------------
# Fcitx5 environment variables
# -----------------------------
cat >"$conf_file" <<'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
EOF

ok "[✓] Fcitx5 environment configured: $conf_file"
