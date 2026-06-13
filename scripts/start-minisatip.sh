#!/bin/bash
# Sat>IP server — SkyStar USB 2 HD CI (14f7:0001), Astra 23.5°E, direct LNB
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN="$ROOT/source/build/minisatip"
if [ ! -x "$BIN" ]; then
  BIN="$ROOT/bin/minisatip"
fi
HTML="$ROOT/html"
CACHE="$ROOT/cache"
IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')
IP=${IP:-192.168.1.97}

mkdir -p "$CACHE"

# SkyStar: do NOT use enigma mode (/etc/enigma2/settings is TBS5590 only)
if [[ -f /etc/enigma2/settings && ! -f /etc/enigma2/settings.tbs-only.bak ]]; then
  python3 - <<'PY'
import yaml, subprocess
from pathlib import Path
p = Path('/home/enigma2/universal-service-manager/services.yaml')
pwd = yaml.safe_load(p.read_text()).get('settings', {}).get('sudo_password', '')
subprocess.run(['sudo', '-S', 'mv', '/etc/enigma2/settings', '/etc/enigma2/settings.tbs-only.bak'],
               input=pwd + '\n', text=True)
PY
fi

if ! ls /dev/dvb/adapter*/frontend0 &>/dev/null; then
  python3 - <<'PY'
import yaml, subprocess
from pathlib import Path
p = Path('/home/enigma2/universal-service-manager/services.yaml')
pwd = yaml.safe_load(p.read_text()).get('settings', {}).get('sudo_password', '')
subprocess.run(['sudo', '-S', 'bash', '/home/enigma2/sat_stuff/minisatip/load-skystar-driver.sh'],
               input=pwd + '\n', text=True, check=True)
PY
fi

exec "$BIN" -f -ll \
  -z "$CACHE" \
  -R "$HTML" \
  -L '*:9750-10600-11700' \
  -d '*:0-0' \
  -e 0 \
  -p "$IP" \
  -w "$IP:8080" \
  -y 8554
