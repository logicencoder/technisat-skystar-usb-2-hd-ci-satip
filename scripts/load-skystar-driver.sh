#!/bin/bash
# SkyStar 2 HD CI (14f7:0001) — load driver if missing. NO rmmod (can wedge kernel).
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

disable_tbs_media_build
rm -f /dev/dvb/adapter0/demux1 /dev/dvb/adapter0/dvr1 2>/dev/null || true

if ! ls /dev/dvb/adapter*/frontend0 &>/dev/null; then
  timeout 15 modprobe dvb_usb_az6027
  sleep 2
fi

if ! ls /dev/dvb/adapter*/frontend0 &>/dev/null; then
  echo "ERROR: SkyStar frontend not found. Check: lsusb | grep 14f7" >&2
  exit 1
fi

modinfo stb0899 | grep -q 'updates/skystar' || {
  echo "WARNING: patched stb0899 not loaded. Expected updates/skystar/stb0899.ko" >&2
  echo "  Run: sudo bash scripts/install-new-server.sh" >&2
}

chmod 666 /dev/dvb/adapter*/frontend* /dev/dvb/adapter*/dvr* /dev/dvb/adapter*/demux* 2>/dev/null || true
echo "OK: $(ls /dev/dvb/adapter0/)"
