#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/hotspot.conf"
source "$SCRIPT_DIR/common.sh"

load_config "$CONFIG_FILE"

info "Setting up IPv4 forwarding + NAT"

# ----------------------------
# 1. Enable IPv4 forwarding (runtime)
# ----------------------------
sysctl -w net.ipv4.ip_forward=1 >/dev/null
ok "IPv4 forwarding enabled (runtime)"

# ----------------------------
# 2. Persist sysctl (safe write)
# ----------------------------
SYSCTL_FILE="/etc/sysctl.d/99-ipforward.conf"

if ! grep -q "net.ipv4.ip_forward=1" "$SYSCTL_FILE" 2>/dev/null; then
    info "net.ipv4.ip_forward=1" | sudo tee "$SYSCTL_FILE" >/dev/null
    ok "IPv4 forwarding persisted"
else
    ok "IPv4 forwarding already persisted"
fi

# ----------------------------
# 3. Create nftables table (idempotent)
# ----------------------------
if ! nft list tables | grep -q "ip hotspot"; then
    nft add table ip hotspot
    ok "nft table created"
else
    ok "nft table already exists"
fi

# ----------------------------
# 4. Ensure table + chain exists
# ----------------------------
if ! nft list table ip hotspot >/dev/null 2>&1; then
    nft add table ip hotspot
    ok "table created"
else
    ok "table exists"
fi

if ! nft list chain ip hotspot postrouting >/dev/null 2>&1; then
    nft add chain ip hotspot postrouting "{ type nat hook postrouting priority srcnat; }"
    ok "chain created"
else
    ok "chain exists"
fi

# ----------------------------
# 5. Add masquerade rule (idempotent, no grep)
# ----------------------------
nft list chain ip hotspot postrouting | grep -q "masquerade" && {
    ok "masquerade already exists"
} || {
    nft add rule ip hotspot postrouting oifname "$WAN_DEV" masquerade
    ok "masquerade added"
}

# ----------------------------
# 7. Enable service
# ----------------------------
# systemctl enable --now nftables >/dev/null 2>&1 || true

ok "NAT setup complete"
