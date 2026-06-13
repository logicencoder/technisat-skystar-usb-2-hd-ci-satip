# skystar-satip-docs

Complete **self-contained** setup for **TechniSat SkyStar USB 2 HD CI** + **minisatip** + **DVBViewer** on Ubuntu.

## New server — start here

```bash
git clone https://github.com/logicencoder/skystar-satip-docs.git
cd skystar-satip-docs
sudo bash scripts/install-new-server.sh
sudo reboot
./scripts/start-minisatip.sh
```

**Full guide:** [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md)

## Documentation

| File | Purpose |
|------|---------|
| [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) | **Complete install from scratch** (human + LLM) |
| [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md) | AI safety rules — read before any changes |
| [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) | Reference, troubleshooting, kernel updates |

## What the install script does

- Installs build packages + firmware
- Disables conflicting TBS `media_build`
- Builds + installs **patched stb0899** (required for DVB-S2)
- Configures udev, modprobe, modules-load
- Builds **minisatip** from upstream GitHub
- Enables **systemd** service `minisatip-skystar`

## Hardware

- Tuner: TechniSat SkyStar USB 2 HD CI (`14f7:0001`)
- Sat>IP port: 8554, web: 8080
- Client: DVBViewer Pro (Windows), CAM on Windows

## Test stream (Astra 23.5°E CT24)

```
rtsp://YOUR_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

## LLM prompt (copy-paste)

```
Clone https://github.com/logicencoder/skystar-satip-docs
Read SETUP-NEW-SERVER.md and LLM-INSTRUCTIONS.md first.
Run: sudo bash scripts/install-new-server.sh && sudo reboot
Then: ./scripts/start-minisatip.sh
FORBIDDEN: modprobe -r loops, USB reset, TBS media in updates/extra/
```
