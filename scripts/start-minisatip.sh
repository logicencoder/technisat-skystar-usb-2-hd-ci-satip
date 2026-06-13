#!/bin/bash
# Sat>IP server — SkyStar USB 2 HD CI (14f7:0001)
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

BIN="$(minisatip_bin)" || {
  echo "minisatip not built. Run: bash scripts/build-minisatip.sh" >&2
  exit 1
}

HTML="${SATIP_DIR}/html"
CACHE="${SATIP_DIR}/cache"
IP="$(satip_bind_ip)"
IP=${IP:?Could not detect bind IP — set SATIP_BIND_IP in config.env}

mkdir -p "$CACHE"

# enigma settings break SkyStar demux — move aside if root
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  move_enigma_settings_aside
fi

if ! ls /dev/dvb/adapter*/frontend0 &>/dev/null; then
  bash "$REPO_ROOT/scripts/load-skystar-driver.sh"
fi

# html from minisatip source if not linked
if [[ ! -d "$HTML" && -d "$SATIP_DIR/source/html" ]]; then
  HTML="$SATIP_DIR/source/html"
fi

echo "minisatip: $BIN"
echo "Bind IP: $IP  RTSP: $SATIP_RTSP_PORT  HTTP: $SATIP_HTTP_PORT  adapter: $MINISATIP_ADAPTER"

# -k: emulate pids=all (TransEdit scan / full transponder)
exec "$BIN" -f -ll \
  -k \
  -z "$CACHE" \
  -R "$HTML" \
  -L "$SATIP_LNB" \
  -d '*:0-0' \
  -e "$MINISATIP_ADAPTER" \
  -p "$IP" \
  -w "$IP:$SATIP_HTTP_PORT" \
  -y "$SATIP_RTSP_PORT"
