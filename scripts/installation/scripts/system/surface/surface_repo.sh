#!/usr/bin/env bash
set -Eeuo pipefail

REPO_BLOCK='
[linux-surface]
SigLevel = Optional TrustAll
Server = https://pkg.surfacelinux.com/arch/
'

PACMAN_CONF="/etc/pacman.conf"

# ---- Must be root ----
[[ $EUID -eq 0 ]] || {
    echo "[ERROR] must be run as root"
    exit 1
}

# ---- Check file exists ----
[[ -f "$PACMAN_CONF" ]] || {
    echo "[ERROR] pacman.conf not found"
    exit 1
}

# ---- Check if repo already exists ----
if grep -q "^\[linux-surface\]" "$PACMAN_CONF"; then
    echo "[INFO] linux-surface repo already exists, skipping"
    exit 0
fi

# ---- Backup ----
cp "$PACMAN_CONF" "${PACMAN_CONF}.bak.$(date +%s)"

# ---- Append repo ----
cat >>"$PACMAN_CONF" <<EOF

$REPO_BLOCK
EOF

echo "[OK] linux-surface repo added successfully"
