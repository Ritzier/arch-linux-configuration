#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config "${CONFIG_FILE}"

# -----------------------------
# Validate config
# -----------------------------
: "${LANG:?LANG is not set in config}"
: "${KEYMAP:?KEYMAP is not set in config}"

info "Configuring system locale and keymap"

# -----------------------------
# 1. Enable locale in locale.gen
# -----------------------------
if grep -q "^#${LANG} UTF-8" /etc/locale.gen; then
    info "Enabling locale in /etc/locale.gen"
    sed -i "s/^#${LANG} UTF-8/${LANG} UTF-8/" /etc/locale.gen
elif grep -q "^${LANG} UTF-8" /etc/locale.gen; then
    info "Locale already enabled"
else
    info "Adding locale to /etc/locale.gen"
    echo "${LANG} UTF-8" >>/etc/locale.gen
fi

# -----------------------------
# 2. Generate locale
# -----------------------------
info "Generating locales"
locale-gen

# -----------------------------
# 3. System locale config
# -----------------------------
info "Setting system LANG"
install -Dm644 /dev/stdin /etc/locale.conf <<EOF
LANG=${LANG}
EOF

# -----------------------------
# 4. Keymap config
# -----------------------------
info "Setting KEYMAP: ${KEYMAP}"
install -Dm644 /dev/stdin /etc/vconsole.conf <<EOF
KEYMAP=${KEYMAP}
EOF

ok "Locale configuration completed"
