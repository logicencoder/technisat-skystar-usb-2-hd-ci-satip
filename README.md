# TechniSat SkyStar USB 2 HD CI — Linux driver & FTA Sat>IP

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

Guide for this **exact card** on Ubuntu: patched kernel driver (DVB-S2 fix) + **minisatip** for **FTA** channels over Sat>IP/RTSP.

**FTA only** — free-to-air, no CAM, no decryption, no paid-TV setup.

Details: [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md)

---

## What this is

| Part | What |
|------|------|
| **Hardware** | TechniSat SkyStar USB 2 HD CI (`14f7:0001`) |
| **Problem** | Stock Ubuntu driver — **no DVB-S2 lock** on this card |
| **Fix** | Patched `stb0899.ko` (community patch, not in mainline kernel) |
| **Streaming** | **minisatip** → Sat>IP / RTSP (port 8554) |
| **Channels** | **FTA only** — scan & watch free channels |

---

## Quick install

```bash
git clone https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci.git
cd technisat-skystar-usb-2-hd-ci
sudo bash scripts/install-new-server.sh
sudo reboot
./scripts/start-minisatip.sh
```

---

## Watch FTA (example — CT24, Astra 23.5°E DVB-S2)

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

Open in **VLC** or any **Sat>IP client**. Web status: `http://SERVER_IP:8080/`

**Note:** Signal may show ~2% in some apps — ignore if video plays (driver quirk).

---

## Verify

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/
modinfo stb0899 | grep updates/skystar
ffprobe "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

Full tests: [TEST-SCENARIOS.md](TEST-SCENARIOS.md)

---

## Docs

| File | Content |
|------|---------|
| [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) | Exact card name & USB ID |
| [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md) | What was broken & why |
| [TEST-SCENARIOS.md](TEST-SCENARIOS.md) | Step-by-step tests |
| [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) | Install from zero |
| [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) | Daily use, kernel update |
| [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md) | For AI assistants |

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
Card: TechniSat SkyStar USB 2 HD CI — USB 14f7:0001 ONLY
Repo: https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci
Read HARDWARE-IDENTITY.md and LLM-INSTRUCTIONS.md first.
Run: sudo bash scripts/install-new-server.sh && sudo reboot
Then: ./scripts/start-minisatip.sh
FTA only. FORBIDDEN: modprobe -r loops, USB reset, TBS media in updates/extra/
```
