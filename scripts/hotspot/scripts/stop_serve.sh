#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

CONFIG_FILE="$SCRIPT_DIR/../config/hotspot.conf"
load_config "$CONFIG_FILE"

TEMP="/tmp/hotspot"

HOSTAPD_PIDFILE="$TEMP/hostapd-${IFACE}.pid"
DNSMASQ_PIDFILE="$TEMP/dnsmasq-${IFACE}.pid"

info "Starting cleanup (iface=$IFACE)"

stop_by_pidfile "hostapd" "$HOSTAPD_PIDFILE"
stop_by_pidfile "dnsmasq" "$DNSMASQ_PIDFILE"

# ----------------------------
# remove interface
# ----------------------------
if iface_exists "$IFACE"; then
    info "Bringing down $IFACE"
    ip link set "$IFACE" down || warn "Failed to down $IFACE"

    info "Deleting $IFACE"
    iw dev "$IFACE" del || warn "Failed to delete $IFACE"

    ok "Interface $IFACE removed"
else
    info "Interface $IFACE does not exist"
fi

ok "Cleanup complete"
