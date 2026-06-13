#!/bin/bash
# SkyStar USB 2 HD CI — patched stb0899 + reload (bez nebezpečného modprobe -r loop)
set -euo pipefail

KVER="$(uname -r)"
BUILD="/home/enigma2/sat_stuff/skystar-driver-build/stb0899-module"
UPD="/lib/modules/${KVER}/updates/skystar"
MEDIA="/lib/modules/${KVER}/updates/extra/media"
BACKUP="/home/enigma2/sat_stuff/backup/media.disabled.skystar"

for dir in "$MEDIA" "${MEDIA}.disabled.skystar"; do
  if [[ -d "$dir" && ! -L "$dir" ]]; then
    mkdir -p "$(dirname "$BACKUP")"
    rm -rf "$BACKUP"
    mv "$dir" "$BACKUP"
    break
  fi
done

python3 /home/enigma2/universal-service-manager/usm.py stop minisatip 2>/dev/null || true
docker stop le_hscr_sigint 2>/dev/null || true

echo "→ Inštalujem patched stb0899.ko"
install -d "$UPD"
install -m 0644 "$BUILD/stb0899.ko" "$UPD/"
depmod -a

echo "→ USB autosuspend off (udev)"
install -m 0644 /home/enigma2/sat_stuff/skystar-driver-build/70-skystar-usb.rules /etc/udev/rules.d/70-skystar-usb.rules
udevadm control --reload-rules
udevadm trigger

# Nájdi SkyStar USB zariadenie
USB=""
for d in /sys/bus/usb/devices/*-*; do
  [[ -f "$d/idVendor" && -f "$d/idProduct" ]] || continue
  v=$(cat "$d/idVendor" 2>/dev/null || true)
  p=$(cat "$d/idProduct" 2>/dev/null || true)
  if [[ "$v" == "14f7" && "$p" == "0001" ]]; then
    USB=$(basename "$d")
    break
  fi
done

if [[ -z "$USB" ]]; then
  echo "⚠ SkyStar nie je na USB — po reboote: sudo modprobe dvb_usb_az6027"
  exit 0
fi

echo "→ Patched stb0899 nainštalovaný v $UPD"
echo "→ REŠTART PC alebo vytiahni/zapoj SkyStar USB, potom:"
echo "   sudo modprobe dvb_usb_az6027"
echo "   python3 ~/universal-service-manager/usm.py start minisatip"
