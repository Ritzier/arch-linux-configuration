def setup(config):
    # Movement
    config.bind("m", "scroll left")
    config.bind("h", "scroll down")
    config.bind("t", "scroll up")
    config.bind("s", "scroll right")

    # Movement (caret)
    config.bind("m", "move-to-prev-char", mode="caret")
    config.bind("h", "move-to-next-line", mode="caret")
    config.bind("t", "move-to-prev-line", mode="caret")
    config.bind("s", "move-to-next-char", mode="caret")

    config.bind("M", "scroll left", mode="caret")
    config.bind("H", "scroll down", mode="caret")
    config.bind("T", "scroll up", mode="caret")
    config.bind("S", "scroll right", mode="caret")

    # Buffer movement
    config.bind("<Alt-h>", "tab-next")
    config.bind("<Alt-t>", "tab-prev")
    # Close buffer
    config.unbind("d")
    config.bind("<Ctrl-x>", "tab-close")
    config.bind("<Ctrl-Shift-x>", "tab-only")

    # Toggle `tabs` bar and `status` bar
    config.bind("<Ctrl-d>", "config-cycle tabs.show never always")
    config.bind("<Ctrl-.>", "config-cycle statusbar.show never always")
