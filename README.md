# skystar-satip-docs

Complete documentation and scripts for **TechniSat SkyStar USB 2 HD CI** + **minisatip** + **DVBViewer** on Ubuntu.

## Why this repository exists

Stock Linux kernel `stb0899` does not support DVB-S2 on card `14f7:0001`. Fix: patched `stb0899` + stock `az6027` + disabled TBS media_build.

This repo is a **backup of the guide** for the user and for AI agents — so the next LLM does not break the system.

## Start here

| File | Content |
|------|---------|
| [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) | Complete guide — startup, diagnostics, kernel update |
| [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md) | **For AI:** what to do and what NEVER to do |

## Hardware / network

- Server: Ubuntu 24.04, `192.168.1.97`
- Tuner: TechniSat SkyStar USB 2 HD CI (`14f7:0001`)
- Sat>IP: port 8554, web status 8080
- Client: DVBViewer Pro (Windows), CAM on Windows

## Quick start (after reboot)

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/
sudo modprobe dvb_usb_az6027   # if /dev/dvb missing
python3 ~/universal-service-manager/usm.py start minisatip
```

## Test stream (CT24, Astra 23.5°E)

```
rtsp://192.168.1.97:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

## Repository layout

```
scripts/                  — load driver, install, minisatip start
stb0899-module/           — patched driver source (build against Ubuntu headers)
SKYSTAR-GUIDE.md          — main guide
LLM-INSTRUCTIONS.md       — rules for AI agents
```

## Kernel update

After every new Ubuntu kernel, rebuild `stb0899`:

```bash
cd stb0899-module && make clean && make -j$(nproc) && sudo make install && sudo reboot
```

See [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) — "Kernel update" section.

## Local copy on server

```
~/sat_stuff/SKYSTAR-GUIDE.md
~/sat_stuff/LLM-INSTRUCTIONS.md
~/sat_stuff/skystar-satip-docs/   ← this git repository
```
