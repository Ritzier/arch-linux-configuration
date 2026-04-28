#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

conf_file="/etc/sysctl.d/70-network.conf"

info "Writing MAX PERFORMANCE network sysctl configuration..."

install -Dm644 /dev/stdin "$conf_file" <<'EOF' >/dev/null
# =========================
# MAX PERFORMANCE NETWORK PROFILE (AGGRESSIVE)
# =========================

# --- Queueing / congestion ---
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# --- TCP fast path ---
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 1

# ⚠️ Reduced latency optimizations (aggressive)
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_slow_start_after_idle = 0

# --- Connection handling (high concurrency) ---
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_max_tw_buckets = 2000000

# --- Keepalive (faster failure detection) ---
net.ipv4.tcp_keepalive_time = 120
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 5

# --- Buffer scaling (HIGH throughput) ---
net.core.rmem_default = 4194304
net.core.rmem_max = 134217728
net.core.wmem_default = 4194304
net.core.wmem_max = 134217728
net.core.optmem_max = 65536

net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384

# --- Queue / packet scheduling ---
net.core.netdev_max_backlog = 16384
net.core.netdev_budget = 600

# --- Security trade-off (slightly relaxed for speed) ---
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0

# --- IPv6 ---
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

EOF

info "Applying sysctl settings..."

sysctl --system >/dev/null 2>&1

ok "MAX PERFORMANCE network profile applied"
