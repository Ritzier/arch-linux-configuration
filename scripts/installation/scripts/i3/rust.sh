#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

info "[+] Setting up Rust toolchain"

command -v rustup >/dev/null || {
    error "[!] rustup not installed"
    exit 1
}

# -----------------------------
# Toolchains
# -----------------------------
rustup toolchain install stable
rustup toolchain install nightly

rustup default stable

# -----------------------------
# WASM target
# -----------------------------
rustup target add wasm32-unknown-unknown

# -----------------------------
# cargo-binstall (safe install)
# -----------------------------
if ! command -v cargo-binstall >/dev/null; then
    info "[+] Installing cargo-binstall"
    sudo pacman -Syu --needed --noconfirm cargo-binstall
    cargo install cargo-binstall
fi

# -----------------------------
# Rust tools
# -----------------------------
cargo binstall cargo-leptos leptosfmt -y

# Lspmux
systemctl --user daemon-reload
systemctl --user enable --now lspmux
