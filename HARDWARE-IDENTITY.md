# Hardware identity — TechniSat SkyStar USB 2 HD CI

## Exact product name

**TechniSat SkyStar USB 2 HD CI**

This repository is **only** for this card. Other TechniSat products are different hardware.

---

## USB identification

| Field | Value |
|-------|--------|
| Product | **TechniSat SkyStar USB 2 HD CI** |
| USB ID | **`14f7:0001`** |
| Vendor | TechniSat Digital GmbH |

```bash
lsusb | grep 14f7
# ID 14f7:0001 TechniSat Digital GmbH SkyStar 2 HD CI
```

Wrong USB ID → this guide does not apply.

---

## Linux drivers

| Component | Source |
|-----------|--------|
| `dvb_usb_az6027` | Stock Ubuntu kernel |
| `stb6100` | Stock Ubuntu kernel |
| `stb0899` | **Patched** — `updates/skystar/stb0899.ko` (**DVB-S2** + **signal/SNR scale** — [PATCHES.md](PATCHES.md)) |
| Firmware | `/lib/firmware/dvb-usb-az6027-03.fw` |

---

## What this project does

```
TechniSat SkyStar USB 2 HD CI (14f7:0001)
  → Ubuntu + patched stb0899 (DVB-S2 + signal/SNR)
  → minisatip Sat>IP server (port 8554)
  → FTA channels (VLC, DVBViewer Sat>IP — no codes)
```

**FTA only.** Client settings: [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)  
Windows 10/11: [WINDOWS-NOTES.md](WINDOWS-NOTES.md)

---

## For AI / LLM

1. Confirm `lsusb` shows **`14f7:0001`**
2. Card name: **TechniSat SkyStar USB 2 HD CI**
3. Read [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md) before changing the system
