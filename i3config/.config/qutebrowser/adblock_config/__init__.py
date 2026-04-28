# Install pip dependency
# `pip install adblock`


def setup(c):
    # =========================
    # Core Adblocking
    # =========================

    # Use modern Brave-based adblock engine
    c.content.blocking.method = "both"  # "adblock" + "hosts" fallback

    # Enable blocking everywhere
    c.content.blocking.enabled = True

    # =========================
    # Filter Lists
    # =========================

    c.content.blocking.adblock.lists = [
        # Core ads
        "https://easylist.to/easylist/easylist.txt",
        # Privacy / trackers
        "https://easylist.to/easylist/easyprivacy.txt",
        # Malware / annoyances
        "https://easylist.to/easylist/fanboy-annoyance.txt",
        # Optional: stronger blocking (can break sites)
        "https://easylist-downloads.adblockplus.org/ublock-filters.txt",
    ]

    # =========================
    # Privacy Hardening
    # =========================

    # Block 3rd-party cookies
    c.content.cookies.accept = "no-3rdparty"

    # Disable referer leaking (strict)
    c.content.headers.referer = "same-domain"

    # Enable Do Not Track
    c.content.headers.do_not_track = True

    # Block WebRTC IP leaks
    c.content.webrtc_ip_handling_policy = "default-public-interface-only"

    # =========================
    # JavaScript Controls
    # =========================

    # Keep JS enabled (most sites need it)
    c.content.javascript.enabled = True

    # Example: disable JS for shady domains
    # config.set("content.javascript.enabled", False, "example.com")

    # =========================
    # Cosmetic Workarounds
    # =========================

    # Block annoying autoplay media
    c.content.autoplay = False

    # Optional: disable notifications
    c.content.notifications.enabled = False

    # =========================
    # Performance Tweaks
    # =========================

    # Reduce unnecessary prefetching (less tracking)
    # c.content.prefetch = False
