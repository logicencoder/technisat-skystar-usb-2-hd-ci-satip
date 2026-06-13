# Patched `stb0899` for TechniSat SkyStar USB 2 HD CI (`14f7:0001`)

Out-of-tree kernel module. **Three fixes** in `stb0899_drv.c`:

1. **DVB-S2 lock** — community patch (required for this card)
2. **Signal / SNR scale** — `stb0899_to_strength_scale()`, `stb0899_to_snr_scale()` → DVB API 0–65535
3. **DVB-S2 SNR calibration** — `stb0899_calibrate_snr_db10()` (+6 dB vs chip underestimate)

Build & install from repo root:

```bash
sudo bash scripts/install-skystar-driver.sh
```

Details: [../PATCHES.md](../PATCHES.md)
