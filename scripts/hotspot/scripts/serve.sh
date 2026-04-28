# 1. Create the AP with `BASE_GATEWAY`
# 2. Run `hostapd` and save the pid to `/tmp/hotspot/hostapd-${IFACE}.pid`
# 3. Run `dnsmasq` and save the pid to `/tmp/hotspot/dnsmasq-${IFACE}.pid`
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

HOSTAPD_PIDFILE="/tmp/hotspot/hostapd-${IFACE}.pid"
DNSMASQ_PIDFILE="/tmp/hotspot/dnsmasq-${IFACE}.pid"

# ----------------------------
# 1. configure AP interface IP
# ----------------------------

# ensure PHY exists
iface_exists "$PHY_DEV" || {
    error "PHY_DEV not found: $PHY_DEV"
    exit 1
}

# create AP interface correctly
if ! iface_exists "$IFACE"; then
    info "Creating AP interface $IFACE"
    iw dev "$PHY_DEV" interface add "$IFACE" type __ap
    ok "Interface created"
fi

ip addr flush dev "$IFACE" || true
ip addr add "${GATEWAY_IP}/24" dev "$IFACE"
ip link set "$IFACE" up

ok "Interface configured ($GATEWAY_IP)"

# ----------------------------
# 2. start hostapd
# ----------------------------
if is_pid_running "$(read_pid "$HOSTAPD_PIDFILE" || echo "")"; then
    error "hostapd already running"
    exit 1
fi

info "Starting hostapd"
hostapd -B -dd -K \
    -P "$HOSTAPD_PIDFILE" \
    "/tmp/hotspot/hostapd.conf" \
    >/tmp/hotspot/hostapd.log 2>&1
ok "hostapd started"

# ----------------------------
# 3. start dnsmasq
# ----------------------------
if is_pid_running "$(read_pid "$DNSMASQ_PIDFILE" || echo "")"; then
    error "dnsmasq already running"
    exit 1
fi

info "Starting dnsmasq"
dnsmasq --conf-file="/tmp/hotspot/dnsmasq.conf" \
    --pid-file="$DNSMASQ_PIDFILE"

ok "dnsmasq started"

# ----------------------------
# 4. verify hostapd stability
# ----------------------------

sleep 3

HOSTAPD_PID="$(read_pid "$HOSTAPD_PIDFILE" || echo "")"

if ! is_pid_running "$HOSTAPD_PID"; then
    error "hostapd died after startup"

    source "$SCRIPT_DIR/stop_serve.sh"

    exit 1
fi

ok "Hotspot is live on $IFACE"
