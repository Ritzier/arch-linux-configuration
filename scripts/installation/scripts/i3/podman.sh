#!/usr/bin/env bash
set -euo pipefail

FILE="/etc/containers/registries.conf.d/10-unqualified-search-registries.conf"
CONTENT='unqualified-search-registries = ["docker.io"]'

echo "[+] Checking Podman registries config..."

# 1. ensure directory exists
sudo mkdir -p "$(dirname "$FILE")"

# 2. check file exists and content matches
if [[ -f "$FILE" ]] && [[ "$(cat "$FILE")" == "$CONTENT" ]]; then
    echo "[✓] Registries config already correct, skipping write"
else
    echo "[+] Writing registries config to: $FILE"
    echo "$CONTENT" | sudo tee "$FILE" >/dev/null
fi

# 3. check subuid/subgid (idempotent safe approach)
SUBUID_LINE="--add-subuids 100000-150000"
SUBGID_LINE="--add-subgids 100000-150000"

if getent passwd "$USER" | cut -d: -f1 >/dev/null 2>&1; then
    # check if already applied
    if grep -q "^$USER:" /etc/subuid 2>/dev/null && grep -q "^$USER:" /etc/subgid 2>/dev/null; then
        echo "[✓] subuid/subgid already configured for $USER"
    else
        echo "[+] Configuring subuid/subgid for $USER"
        sudo usermod --add-subuids 100000-150000 --add-subgids 100000-150000 "$USER"
    fi
fi

echo "[✓] Done"
