from .registry import load_theme


def setup(c, name: str = "mocha"):
    load_theme(c, name)
