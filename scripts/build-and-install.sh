#!/bin/bash
# SkyStar — skompiluj a nainštaluj patched stb0899 (DVB-S2 fix)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LINUX="$ROOT/linux-6.8/drivers/media/dvb-frontends"
MOD="$ROOT/stb0899-module"

cp "$LINUX/stb0899_drv.c" "$LINUX/stb0899_algo.c" "$LINUX/stb0899_drv.h" \
   "$LINUX/stb0899_priv.h" "$LINUX/stb0899_cfg.h" "$LINUX/stb0899_reg.h" "$MOD/"

make -C "$MOD" -j"$(nproc)"
sudo make -C "$MOD" install
sudo bash "$ROOT/install-skystar-driver.sh"
