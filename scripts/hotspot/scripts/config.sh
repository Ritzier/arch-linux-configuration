SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

DNSMASQ_CONF="$SCRIPT_DIR/../config/dnsmasq.conf"
HOSTAPD_CONF="$SCRIPT_DIR/../config/hostapd.conf"
HOTSPOT_CONF="$SCRIPT_DIR/../config/hotspot.conf"

# Hostapd
build_hostapd_config() {
    local hotspot_conf="$HOTSPOT_CONF"
    local template="$HOSTAPD_CONF"
    local out_dir="/tmp/hotspot"
    local out_file="$out_dir/hostapd.conf"

    mkdir -p "$out_dir"

    # ----------------------------
    # parse hotspot.conf
    # ----------------------------
    local ssid pass iface

    ssid=$(grep -E "^SSID=" "$hotspot_conf" | cut -d= -f2-)
    pass=$(grep -E "^WPA_PASSPHRASE=" "$hotspot_conf" | cut -d= -f2-)
    iface=$(grep -E "^IFACE=" "$hotspot_conf" | cut -d= -f2-)

    if [[ -z "${ssid:-}" || -z "${pass:-}" ]]; then
        error "Missing SSID or WPA_PASSPHRASE in hotspot.conf" >&2
        return 1
    fi

    # ----------------------------
    # generate config
    # ----------------------------
    {
        echo "# AUTO-GENERATED FILE - DO NOT EDIT"
        echo "# generated at $(date -Iseconds)"
        echo

        # override section
        echo "ssid=$ssid"
        echo "sae_password=$pass"
        echo "interface=$iface"
        echo

        # append original template
        cat "$template"
    } >"$out_file"

    ok "[OK] hostapd config generated: $out_file"
}

# Dnsmasq
build_dnsmasq_config() {
    local hotspot_conf="$HOTSPOT_CONF"
    local template="$DNSMASQ_CONF"
    local out_dir="/tmp/hotspot"
    local out_file="$out_dir/dnsmasq.conf"

    mkdir -p "$out_dir"

    # ----------------------------
    # read config
    # ----------------------------
    local base_subnet gateway_ip netmask iface

    base_subnet=$(grep -E "^BASE_SUBNET=" "$hotspot_conf" | cut -d= -f2-)
    gateway_ip=$(grep -E "^GATEWAY_IP=" "$hotspot_conf" | cut -d= -f2-)
    netmask=$(grep -E "^NETMASK=" "$hotspot_conf" | cut -d= -f2-)
    iface=$(grep -E "^IFACE=" "$hotspot_conf" | cut -d= -f2-)

    if [[ -z "${base_subnet:-}" || -z "${gateway_ip:-}" || -z "${iface:-}" ]]; then
        error "Missing required fields in hotspot.conf" >&2
        return 1
    fi

    # ----------------------------
    # render
    # ----------------------------
    {
        # header injection
        echo "# AUTO-GENERATED dnsmasq config"
        echo "# generated at $(date -Iseconds)"
        echo

        echo "interface=$iface"
        echo

        # template substitution
        sed \
            -e "s|__BASE_SUBNET__|$base_subnet|g" \
            -e "s|__GATEWAY_IP__|$gateway_ip|g" \
            -e "s|__NETMASK__|$netmask|g" \
            "$template"

    } >"$out_file"

    ok "[OK] dnsmasq config generated: $out_file"
}

build_hostapd_config
build_dnsmasq_config
