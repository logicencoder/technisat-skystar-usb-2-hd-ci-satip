#!/bin/bash
# Quick check: is Patch 3 (SNR +6dB calibration) installed and loaded?
set -euo pipefail
KO="/lib/modules/$(uname -r)/updates/skystar/stb0899.ko"
echo "=== modinfo ==="
modinfo stb0899 2>/dev/null | grep -E 'filename|description|srcversion' || echo "stb0899 not loaded"
echo ""
echo "=== Patch 3 installed? ==="
if [[ -f "$KO" ]]; then
  ls -la "$KO"
  DESC="$(modinfo -F description stb0899 2>/dev/null || true)"
  if [[ "$DESC" == *"SNR +6dB"* ]]; then
    echo "OK: loaded module has Patch 3 ($DESC)"
  elif strings "$KO" 2>/dev/null | grep -q stb0899_calibrate_snr_db10; then
    echo "OK: Patch 3 symbol in $KO (reboot if SNR still ~25%)"
  else
    echo "MISSING: Patch 3 — run: sudo bash scripts/install-skystar-driver.sh && sudo reboot"
  fi
else
  echo "MISSING: $KO"
fi
echo ""
echo "=== live SNR (minisatip) ==="
curl -s http://127.0.0.1:8080/state.json 2>/dev/null | python3 -c "
import json,sys
j=json.load(sys.stdin); i=0
s,n=j['ad_strength'][i],j['ad_snr'][i]
cn=n*256*200/65535/10
print('strength', s, f'({s/255*100:.0f}%)')
print('snr', n, f'({n/255*100:.0f}%)')
print('approx C/N', f'~{cn:.1f} dB')
if n >= 120:
    print('RESULT: Patch 3 OK (SNR ~50%+ / ~10+ dB)')
elif n >= 80:
    print('RESULT: SNR improved but check TransEdit MER')
else:
    print('RESULT: SNR still low — reboot after driver install?')
" 2>/dev/null || echo "(minisatip not running)"
