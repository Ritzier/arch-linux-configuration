#!/usr/bin/env bash

# TODO: configuration with customize config

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

tee /etc/systemd/zram-generator.conf >/dev/null <<'EOF' >/dev/null
[zram0]
zram-size = ram / 2
compression-algorithm = lz4
swap-priority = 100
EOF

tee /etc/sysctl.d/99-swappiness.conf <<'EOF' >/dev/null
vm.swappiness=80
vm.vfs_cache_pressure=30
EOF

sysctl --system >/dev/null 2>&1
