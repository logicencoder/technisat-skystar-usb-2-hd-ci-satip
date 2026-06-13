# Tested environment — TechniSat SkyStar USB 2 HD CI

> Reference stack where **everything in this repo was tested end-to-end**.

---

## Server (Linux / Sat>IP)

| Item | Tested value |
|------|----------------|
| **OS** | **Ubuntu 24.04.4 LTS** (Noble Numbat) |
| **Kernel** | **6.8.0-124-generic** |
| **Architecture** | x86_64 |
| **Card** | TechniSat SkyStar USB 2 HD CI · USB **`14f7:0001`** |
| **Driver** | Patched `stb0899.ko` → `/lib/modules/$(uname -r)/updates/skystar/` ([PATCHES.md](PATCHES.md)) |
| **USB bridge** | Stock kernel `dvb_usb_az6027` |
| **Sat>IP server** | **minisatip** (built from [catalinii/minisatip](https://github.com/catalinii/minisatip)) |
| **RTSP port** | **8554** |
| **Web / status** | **8080** (`/state.json`) |

Check your server matches:

```bash
lsb_release -ds          # Ubuntu 24.04.x LTS
uname -r                 # e.g. 6.8.0-124-generic
lsusb | grep 14f7        # 14f7:0001 SkyStar 2 HD CI
modinfo stb0899 | grep filename
pgrep -a minisatip
```

---

## Clients (Windows — Sat>IP)

| Software | Tested |
|----------|--------|
| **DVBViewer Pro** | ✅ Sat>IP FTA — scan, playback, NIT, DiSEqC |
| **TransEdit** | ✅ RTSP device, transponder/NIT scan, full transponder (`-k`) |
| **VLC** | ✅ RTSP URL |
| **ffprobe** | ✅ stream probe from server |

Settings: [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)

---

## Other Ubuntu versions

| OS | Expected |
|----|----------|
| **Ubuntu 24.04 LTS** | ✅ **Primary tested** — use `linux-headers-$(uname -r)` + `install-skystar-driver.sh` |
| **Ubuntu 22.04 LTS** | Should work the same way (not re-tested on every release) — rebuild `stb0899` after kernel updates |

The patched module is **per kernel version**. After `apt upgrade` installs a new kernel:

```bash
sudo bash scripts/install-skystar-driver.sh
sudo reboot
```

---

## What we do **not** pin

- Exact minisatip git commit (build from upstream via `scripts/build-minisatip.sh`)
- Exact DVBViewer / TransEdit build numbers — any recent Sat>IP-capable version

---

## Satellites / hardware (example only)

DiSEqC switch and dish wiring are **per installation**. See [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md) — server does not map satellites; client sends `src=` / DiSEqC port.

Test transponder used in docs: **Astra 23.5°E — 12344 H 29900 DVB-S2** (CT24 FTA).
