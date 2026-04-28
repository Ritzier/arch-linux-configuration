set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    error "[!] This script must be run as root" >&2
    exit 1
fi
