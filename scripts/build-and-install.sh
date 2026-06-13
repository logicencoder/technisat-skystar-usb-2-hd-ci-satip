#!/bin/bash
# Build and install patched stb0899 (DVB-S2 fix) + system config
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
sudo bash "$ROOT/scripts/install-skystar-driver.sh"
