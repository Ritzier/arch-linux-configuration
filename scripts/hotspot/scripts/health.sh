#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

DNSMASQ_CONF="$SCRIPT_DIR/../config/dnsmasq.conf"
HOSTAPD_CONF="$SCRIPT_DIR/../config/hostapd.conf"
CONFIG_FILE="$SCRIPT_DIR/../config/hotspot.conf"

load_config "$CONFIG_FILE"

# ----------------------------
# required fields
# ----------------------------
[[ -n "${PHY_DEV:-}" ]] || fail "PHY_DEV missing"
[[ -n "${WAN_DEV:-}" ]] || fail "WAN_DEV missing"
[[ -n "${IFACE:-}" ]] || fail "IFACE missing"
[[ -n "${BASE_SUBNET:-}" ]] || fail "BASE_SUBNET missing"
[[ -n "${GATEWAY_IP:-}" ]] || fail "GATEWAY_IP missing"
[[ -n "${NETMASK:-}" ]] || fail "NETMASK missing"
[[ -n "${SSID:-}" ]] || fail "SSID missing"
[[ -n "${WPA_PASSPHRASE:-}" ]] || fail "WPA_PASSPHRASE missing"

ok "All required fields present"

# ----------------------------
# validate network interfaces
# ----------------------------
ip link show "$PHY_DEV" >/dev/null 2>&1 || fail "PHY_DEV not found: $PHY_DEV"
ip link show "$WAN_DEV" >/dev/null 2>&1 || fail "WAN_DEV not found: $WAN_DEV"

ok "Network interfaces exist"

# ----------------------------
# validate IFACE format (soft AP interface)
# ----------------------------
if [[ ! "$IFACE" =~ ^[a-zA-Z0-9_]+$ ]]; then
    fail "IFACE invalid format: $IFACE"
fi

ok "IFACE format valid"

# ----------------------------
# validate subnet format (basic)
# ----------------------------
if [[ ! "$BASE_SUBNET" =~ ^([0-9]{1,3}\.){2}[0-9]{1,3}$ ]]; then
    fail "BASE_SUBNET invalid: $BASE_SUBNET"
fi

ok "BASE_SUBNET format valid"

# ----------------------------
# validate IP format (simple check)
# ----------------------------
if [[ ! "$GATEWAY_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    fail "GATEWAY_IP invalid: $GATEWAY_IP"
fi

ok "GATEWAY_IP format valid"

# ----------------------------
# validate netmask (strict set)
# ----------------------------
case "$NETMASK" in
255.0.0.0 | 255.255.0.0 | 255.255.255.0 | 255.255.255.128 | 255.255.255.192 | 255.255.255.224 | 255.255.255.240 | 255.255.255.248 | 255.255.255.252)
    ok "NETMASK valid"
    ;;
*)
    fail "NETMASK invalid or unsupported: $NETMASK"
    ;;
esac

# ----------------------------
# SSID checks
# ----------------------------
if [[ ${#SSID} -gt 32 ]]; then
    fail "SSID too long (>32 chars)"
fi

ok "SSID length valid"

# ----------------------------
# WPA password checks
# ----------------------------
if [[ ${#WPA_PASSPHRASE} -lt 8 ]]; then
    fail "WPA_PASSPHRASE too short (<8 chars)"
fi

if [[ ${#WPA_PASSPHRASE} -gt 63 ]]; then
    fail "WPA_PASSPHRASE too long (>63 chars)"
fi

ok "WPA_PASSPHRASE length valid"

# ----------------------------
# final summary
# ----------------------------
ok "Configuration is vail"
