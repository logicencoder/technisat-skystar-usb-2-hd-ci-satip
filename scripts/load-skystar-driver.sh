#!/bin/bash
# SkyStar 2 HD CI (14f7:0001) — load driver if missing. NO rmmod (can wedge kernel).
set -euo pipefail

KERNEL="$(uname -r)"
MEDIA_DIR="/lib/modules/${KERNEL}/updates/extra/media"
BACKUP="/home/enigma2/sat_stuff/backup/media.disabled.skystar"

# TBS media_build in updates/ has wrong symbol versions — move out of module path
for dir in "$MEDIA_DIR" "${MEDIA_DIR}.disabled.skystar"; do
  if [[ -d "$dir" && ! -L "$dir" ]]; then
    mkdir -p "$(dirname "$BACKUP")"
    rm -rf "$BACKUP"
    mv "$dir" "$BACKUP"
    depmod -a
    break
  fi
done

rm -f /dev/dvb/adapter0/demux1 /dev/dvb/adapter0/dvr1 2>/dev/null || true

if ! ls /dev/dvb/adapter*/frontend0 &>/dev/null; then
  timeout 15 modprobe dvb_usb_az6027
  sleep 2
fi

if ! ls /dev/dvb/adapter*/frontend0 &>/dev/null; then
  echo "ERROR: SkyStar frontend not found" >&2
  exit 1
fi

chmod 666 /dev/dvb/adapter*/frontend* /dev/dvb/adapter*/dvr* /dev/dvb/adapter*/demux* 2>/dev/null || true
echo "OK: $(ls /dev/dvb/adapter0/)"
