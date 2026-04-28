THEMES = {
    "mocha": "themes.mocha",
}


def load_theme(c, name: str):
    if name not in THEMES:
        raise ValueError(f"Unknown theme: {name}")

    module = __import__(THEMES[name], fromlist=["apply"])
    module.apply(c)
