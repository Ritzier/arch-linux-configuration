#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/hotspot.conf"

source "$SCRIPT_DIR/common.sh"
load_config "$CONFIG_FILE"

TEMP="/tmp/hotspot"

HOSTAPD_PIDFILE="$TEMP/hostapd-${IFACE}.pid"
DNSMASQ_PIDFILE="$TEMP/dnsmasq-${IFACE}.pid"

if is_pid_running "$(read_pid "$HOSTAPD_PIDFILE" || echo "")"; then
    info "hostapd running"
    return 0
fi

if is_pid_running "$(read_pid "$DNSMASQ_PIDFILE" || echo "")"; then
    info "dnsmasq running"
    return 0
fi

return 1
