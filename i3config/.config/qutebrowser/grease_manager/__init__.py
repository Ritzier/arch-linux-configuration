from qutebrowser.api import cmdutils

from .manager import GreaseManager


@cmdutils.register()
def grease_install():
    """Install grease and update installed grease"""
    GreaseManager().install()
