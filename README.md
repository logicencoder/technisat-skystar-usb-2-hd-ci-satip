# TechniSat SkyStar USB 2 HD CI — Sat>IP (minisatip) FTA

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

Stock Linux driver is **broken for DVB-S2** on this card — with the **patched `stb0899`** (DVB-S2 + **signal/SNR scale**) the card is **fully functional**. You do **not** need to discard it.

**After patch — tested, working:**

| Feature | Status |
|---------|--------|
| DVB-S2 lock / tune | ✅ |
| FTA playback | ✅ |
| **Signal / SNR display** (DVBViewer, TransEdit, minisatip web) | ✅ |
| **minisatip Sat>IP** (RTSP port 8554) | ✅ |
| **DiSEqC switch** (multi-dish, port switching) | ✅ |
| **DVBViewer** + **TransEdit** (scan, NIT, full transponder) | ✅ |
| VLC / ffprobe | ✅ |

Ubuntu driver patch + **minisatip Sat>IP server** for **FTA** channels.

**Tested** on **Ubuntu 24.04 LTS** · kernel **6.8.0-124-generic** — see **[TESTED-ENVIRONMENT.md](TESTED-ENVIRONMENT.md)**  
**Clients:** **DVBViewer** and **TransEdit** — full transponder scan + **DiSEqC switch** (port switching works).

| Doc | Link |
|-----|------|
| **Tested OS / kernel / stack** | **[TESTED-ENVIRONMENT.md](TESTED-ENVIRONMENT.md)** |
| Sat>IP client settings | **[SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)** |
| **Windows 10/11** | **[WINDOWS-NOTES.md](WINDOWS-NOTES.md)** — use Sat>IP, not local drivers |
| Card details | [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) |

---

## What this is

| Part | What |
|------|------|
| **Card** | TechniSat SkyStar USB 2 HD CI (`14f7:0001`) |
| **Fix** | Patched `stb0899.ko` — **DVB-S2 lock** + **signal/SNR 0–65535 scale** ([PATCHES.md](PATCHES.md)) |
| **Sat>IP server** | minisatip — port **8554**, web **8080** |
| **Channels** | **FTA only** |

---

## Quick install

```bash
git clone https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci-satip.git
cd technisat-skystar-usb-2-hd-ci-satip
sudo bash scripts/install-new-server.sh
sudo reboot
./scripts/start-minisatip.sh
```

---

## Sat>IP — watch FTA

**Server:** `SERVER_IP:8554`  
**Status:** `http://SERVER_IP:8080/`

**RTSP (CT24 test, Astra 23.5°E DVB-S2):**

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

**Clients:** VLC, DVBViewer, TransEdit, any Sat>IP client — see **[SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)**

---

## Verify server

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/
modinfo stb0899 | grep updates/skystar
strings /lib/modules/$(uname -r)/updates/skystar/stb0899.ko | grep stb0899_to_strength_scale
pgrep -a minisatip
ffprobe "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

Tests: [TEST-SCENARIOS.md](TEST-SCENARIOS.md)

---

## All docs

| File | Content |
|------|---------|
| [TESTED-ENVIRONMENT.md](TESTED-ENVIRONMENT.md) | **Ubuntu 24.04, kernel 6.8.0-124, minisatip, clients** |
| [PATCHES.md](PATCHES.md) | **Driver patches — DVB-S2 + signal/SNR (tested)** |
| [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md) | **Sat>IP — DVBViewer, TransEdit, DiSEqC, VLC** |
| [WINDOWS-NOTES.md](WINDOWS-NOTES.md) | **Win10/11 — Sat>IP instead of broken local drivers** |
| [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) | Card name & USB ID |
| [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md) | What was broken & why |
| [TEST-SCENARIOS.md](TEST-SCENARIOS.md) | Tests |
| [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) | Install from zero |
| [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) | Daily use |
| [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md) | AI rules |

---

## Kernel update

```bash
sudo bash scripts/install-skystar-driver.sh
sudo reboot
./scripts/start-minisatip.sh
```

---

## AI prompt

```
Card: TechniSat SkyStar USB 2 HD CI — USB 14f7:0001
Repo: https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci-satip
Read SATIP-CLIENT-SETTINGS.md, HARDWARE-IDENTITY.md, LLM-INSTRUCTIONS.md
Run: sudo bash scripts/install-new-server.sh && sudo reboot
Then: ./scripts/start-minisatip.sh
FTA Sat>IP only — no CAM/codes. FORBIDDEN: modprobe -r loops, TBS media in updates/extra/
```
