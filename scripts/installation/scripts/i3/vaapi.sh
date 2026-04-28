#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

info "[+] Configuring Firefox VA-API..."

FF_DIR="$HOME/.config/mozilla/firefox"
PROFILES_INI="$FF_DIR/profiles.ini"

if [[ -f "$PROFILES_INI" ]]; then
    # Extract default profile path
    ff_profile="$(awk -F= '
        $1=="Path" {path=$2}
        $1=="Default" && $2=="1" {print path}
    ' "$PROFILES_INI" | head -n1)"

    if [[ -n "$ff_profile" ]]; then
        PROFILE_PATH="$FF_DIR/$ff_profile"
        mkdir -p "$PROFILE_PATH"

        USER_JS="$PROFILE_PATH/user.js"

        info "Applying Firefox VA-API config to: $PROFILE_PATH"

        cat >"$USER_JS" <<'EOF'
// GPU acceleration (VA-API)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("layers.acceleration.force-enabled", true);
EOF
    else
        warn "No default Firefox profile found"
    fi
else
    warn "Firefox profile not found (launch Firefox once first)"
fi

# -----------------------------
# Chromium
# -----------------------------
info "[+] Configuring Chromium hardware acceleration..."

CHROMIUM_FLAGS="$HOME/.config/chromium-flags.conf"
mkdir -p "$(dirname "$CHROMIUM_FLAGS")"

cat >"$CHROMIUM_FLAGS" <<'EOF'
--enable-features=VaapiVideoDecoder
--ignore-gpu-blocklist
--enable-gpu-rasterization
--use-gl=desktop
EOF

ok "[✓] GPU hardware acceleration setup complete"
