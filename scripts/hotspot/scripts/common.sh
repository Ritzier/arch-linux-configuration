#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Colors
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ----------------------------
# Logging
# ----------------------------
_ts() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
    local level="$1"
    shift
    printf "[%s] [%s] %b%s%b\n" "$(_ts)" "$level" "$2" "$*" "$NC"
}

info() { printf "[%s] [INFO]  ${BLUE}%s${NC}\n" "$(_ts)" "$*"; }
ok() { printf "[%s] [OK]    ${GREEN}%s${NC}\n" "$(_ts)" "$*"; }
warn() { printf "[%s] [WARN]  ${YELLOW}%s${NC}\n" "$(_ts)" "$*"; }
error() { printf "[%s] [ERROR] ${RED}%s${NC}\n" "$(_ts)" "$*" >&2; }

# ----------------------------
# Load config (shared)
# ----------------------------
load_config() {
    local config_file="$1"

    [[ -f "$config_file" ]] || {
        error "config file not found: $config_file"
        return 1
    }

    # shellcheck disable=SC1090
    source "$config_file"
}

# ----------------------------
# PID helpers
# ----------------------------
is_pid_running() {
    local pid="$1"
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

read_pid() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    cat "$file" 2>/dev/null || return 1
}

stop_by_pidfile() {
    local name="$1"
    local file="$2"

    if [[ ! -f "$file" ]]; then
        info "$name not running"
        return 0
    fi

    local pid
    pid=$(read_pid "$file" || true)

    if is_pid_running "$pid"; then
        info "Stopping $name (pid=$pid)"
        kill "$pid" || warn "Failed to kill $name"
    else
        warn "Stale $name PID file"
    fi

    rm -f "$file"
    ok "$name stopped"
}

# ----------------------------
# Interface helpers
# ----------------------------
iface_exists() {
    ip link show "$1" >/dev/null 2>&1
}
