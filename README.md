# TechniSat SkyStar USB 2 HD CI — Sat>IP (minisatip) FTA

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

Ubuntu driver patch (DVB-S2) + **minisatip Sat>IP server** for **FTA** channels.

**Tested** with **DVBViewer** and **TransEdit** — full transponder scan + **DiSEqC** (Astra 23.5 / 19.2 / 4.8°E).

| Doc | Link |
|-----|------|
| Sat>IP client settings | **[SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)** |
| Card details | [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) |

---

## What this is

| Part | What |
|------|------|
| **Card** | TechniSat SkyStar USB 2 HD CI (`14f7:0001`) |
| **Fix** | Patched `stb0899.ko` for DVB-S2 |
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
pgrep -a minisatip
ffprobe "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

Tests: [TEST-SCENARIOS.md](TEST-SCENARIOS.md)

---

## All docs

| File | Content |
|------|---------|
| [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md) | **Sat>IP — DVBViewer, TransEdit, DiSEqC, VLC** |
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
