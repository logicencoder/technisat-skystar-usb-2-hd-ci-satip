#!/bin/bash
# Run server-side Tests 1–5c from TEST-SCENARIOS.md (pass/fail summary)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0
ok()  { echo "  PASS: $1"; PASS=$((PASS + 1)); }
bad() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Test 1 — USB ==="
if lsusb | grep -q '14f7:0001'; then
  lsusb | grep 14f7
  ok "USB 14f7:0001"
else
  bad "USB 14f7:0001 not found"
fi

echo ""
echo "=== Test 2 — DVB nodes ==="
if [[ -e /dev/dvb/adapter0/frontend0 ]]; then
  ls /dev/dvb/adapter0/
  ok "frontend0 exists"
else
  bad "/dev/dvb/adapter0/frontend0 missing"
fi

echo ""
echo "=== Test 3 — Patched stb0899 ==="
if modinfo stb0899 2>/dev/null | grep -q 'updates/skystar'; then
  modinfo stb0899 | grep filename
  ok "stb0899 from updates/skystar"
else
  bad "stb0899 not from updates/skystar"
fi
if strings "/lib/modules/$(uname -r)/updates/skystar/stb0899.ko" 2>/dev/null | grep -q stb0899_to_strength_scale; then
  ok "signal scale symbol present"
else
  bad "stb0899_to_strength_scale missing"
fi

echo ""
echo "=== Test 4 — minisatip ==="
if pgrep -a minisatip >/dev/null; then
  pgrep -a minisatip
  ss -tlnp | grep -E '8554|8080' || true
  if pgrep -a minisatip | grep -q '\-k'; then ok "minisatip -k"; else bad "minisatip missing -k"; fi
  if pgrep -a minisatip | grep -q '\-e 0'; then ok "minisatip -e 0"; else bad "minisatip missing -e 0"; fi
  ok "minisatip running"
else
  echo "Starting minisatip..."
  "$ROOT/scripts/start-minisatip.sh" || true
  sleep 2
  if pgrep minisatip >/dev/null; then ok "minisatip started"; else bad "minisatip not running"; fi
fi

echo ""
echo "=== Test 5 — FTA DVB-S2 stream (CT24) ==="
URL='rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320'
OUT=$(ffprobe -v error -show_entries stream=codec_name -of csv=p=0 "$URL" 2>&1 || true)
echo "$OUT"
if echo "$OUT" | grep -q h264; then ok "h264 video"; else bad "no h264"; fi

echo ""
echo "=== Test 5b — Full transponder (pids=all, needs -k) ==="
TP=$(timeout 15 ffprobe -v error -show_entries stream=codec_type -of csv=p=0 \
  "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=all" \
  2>/dev/null | sort | uniq -c || true)
echo "$TP"
if echo "$TP" | grep -q video; then ok "full TP video streams"; else bad "no video in pids=all"; fi

echo ""
echo "=== Test 5c — Signal / SNR (state.json) ==="
STATE=$(curl -s http://127.0.0.1:8080/state.json 2>/dev/null || true)
if [[ -n "$STATE" ]]; then
  echo "$STATE" | python3 -c "
import json,sys
j=json.load(sys.stdin)
i=0
print('freq', j['ad_freq'][i], 'sr', j['ad_sr'][i])
print('strength', j['ad_strength'][i], 'snr', j['ad_snr'][i])
print('channel', j['ad_channel'][i])
" 2>/dev/null || true
  STR=$(echo "$STATE" | python3 -c "import json,sys; print(json.load(sys.stdin)['ad_strength'][0])" 2>/dev/null || echo 0)
  if [[ "$STR" -gt 10 ]]; then ok "strength > 10 (not 1-2% bug)"; else bad "strength still low ($STR)"; fi
else
  bad "no state.json (tune a TP first)"
fi

echo ""
echo "=== Summary ==="
echo "PASS: $PASS  FAIL: $FAIL"
[[ "$FAIL" -eq 0 ]]
