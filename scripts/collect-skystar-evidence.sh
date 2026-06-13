#!/bin/bash
# Collect Ubuntu evidence for blog / HackerNoon screenshots — run while a TP is locked
set -euo pipefail
OUT=~/skystar-evidence-$(date +%Y%m%d-%H%M)
mkdir -p "$OUT"

{
  echo "=== SYSTEM ==="
  uname -r; lsb_release -ds
  echo "=== USB ==="
  lsusb | grep 14f7 || echo "(14f7:0001 not found)"
  echo "=== DVB ==="
  ls -la /dev/dvb/adapter0/ 2>/dev/null || echo "(no adapter0)"
  echo "=== MODULES ==="
  modinfo stb0899 | grep -E 'filename|version|description'
  modinfo dvb_usb_az6027 | grep filename
  strings /lib/modules/$(uname -r)/updates/skystar/stb0899.ko 2>/dev/null | grep stb0899_to_strength || true
  echo "=== MINISATIP ==="
  pgrep -a minisatip || echo "(minisatip not running)"
  ss -tlnp | grep -E '8554|8080' || true
  echo "=== STATE.JSON (compact — use for blog screenshot) ==="
  curl -s http://127.0.0.1:8080/state.json | python3 -c "
import json,sys
j=json.load(sys.stdin)
i=0
print('adapter', i, j.get('ad_adapter_names',[''])[i])
print('enabled', j.get('ad_enabled',[0])[i])
print('freq_mhz', j.get('ad_freq',[0])[i])
print('sr', j.get('ad_sr',[0])[i])
print('pol', j.get('ad_pol',[0])[i])
print('strength_0_255', j.get('ad_strength',[0])[i])
print('snr_0_255', j.get('ad_snr',[0])[i])
print('channel', j.get('ad_channel',[''])[i])
print('pids', j.get('ad_pids',[''])[i])
print('minisatip', j.get('version',''))
print('client', j.get('st_rhost',[''])[0] or '(none)', 'play=', j.get('st_play',[0])[0])
" 2>/dev/null || echo "(no state.json)"
  echo "=== STATE.JSON (full) ==="
  curl -s http://127.0.0.1:8080/state.json | python3 -m json.tool 2>/dev/null || echo "(no state.json)"
  echo "=== FFPROBE SINGLE (CT24) ==="
  ffprobe -v error -show_entries stream=codec_name \
    "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320" 2>&1 || true
  echo "=== FFPROBE FULL TP (clean summary) ==="
  timeout 15 ffprobe -v error -show_entries stream=codec_type -of csv=p=0 \
    "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=all" \
    2>/dev/null | sort | uniq -c || true
  echo "=== DMESG ==="
  sudo dmesg | grep -iE 'dvb|stb0899|az6027|14f7' | tail -40
} | tee "$OUT/report.txt"

echo ""
echo "Saved: $OUT/report.txt"
echo "Next: screenshot DVBViewer + TransEdit on Windows while this TP is locked."
