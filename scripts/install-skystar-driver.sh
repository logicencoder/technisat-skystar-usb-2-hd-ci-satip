#!/bin/bash
# SkyStar USB 2 HD CI — install/reinstall patched stb0899 only
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

disable_tbs_media_build
free_tuner
stop_minisatip

echo "→ Building patched stb0899..."
make -C "$STB0899_DIR" clean
make -C "$STB0899_DIR" -j"$(nproc)"
make -C "$STB0899_DIR" install

install -m 0644 "$REPO_ROOT/scripts/70-skystar-usb.rules" /etc/udev/rules.d/70-skystar-usb.rules
udevadm control --reload-rules
udevadm trigger
depmod -a

echo "→ Patched stb0899 installed."
echo "→ REBOOT recommended, then: scripts/start-minisatip.sh"
