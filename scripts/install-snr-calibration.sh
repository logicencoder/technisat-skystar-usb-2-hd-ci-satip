#!/bin/bash
# Reinstall stb0899 after SNR calibration patch (Patch 3) — same as install-skystar-driver.sh
set -euo pipefail
exec "$(dirname "$0")/install-skystar-driver.sh" "$@"
