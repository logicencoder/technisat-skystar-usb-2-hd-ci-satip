# Setup a NEW server from scratch (LLM / human guide)

> **Goal:** TechniSat SkyStar USB 2 HD CI (`14f7:0001`) streaming via **minisatip** to **DVBViewer** on Windows.  
> **Repo:** https://github.com/logicencoder/skystar-satip-docs

---

## For AI agents — read this file end-to-end before changing anything

Also read: [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md)

**One-command install (Ubuntu, root):**

```bash
git clone https://github.com/logicencoder/skystar-satip-docs.git
cd skystar-satip-docs
cp config.env.example config.env   # optional edits
sudo bash scripts/install-new-server.sh
sudo reboot
# after reboot:
./scripts/start-minisatip.sh
# or: sudo systemctl start minisatip-skystar
```

That script does **everything**: packages, patched `stb0899` build, udev, modprobe, minisatip build, systemd enable.

---

## Hardware requirements

| Item | Detail |
|------|--------|
| Tuner | TechniSat **SkyStar USB 2 HD CI** USB `14f7:0001` |
| LNB | Connected to tuner (e.g. Astra 23.5°E) |
| OS | Ubuntu 22.04 / 24.04 (or Debian with kernel headers) |
| Client | DVBViewer Pro on Windows (CAM on Windows) |

**Do NOT use** TBS 5590 `media_build` in `/lib/modules/.../updates/extra/media/` at the same time.

---

## Step-by-step (manual, if install script fails)

### 1. Clone repo

```bash
git clone https://github.com/logicencoder/skystar-satip-docs.git
cd skystar-satip-docs
cp config.env.example config.env
```

Edit `config.env` if needed:
- `SATIP_BIND_IP` — server IP (auto-detected if empty)
- `TUNER_HOLD_DOCKER` — docker container name that holds tuner (or empty)

### 2. Install packages

```bash
sudo apt update
sudo apt install -y build-essential "linux-headers-$(uname -r)" git cmake \
  libdvbcsa-dev kmod curl firmware-linux-nonfree
```

Verify firmware:

```bash
ls /lib/firmware/dvb-usb-az6027-03.fw
```

### 3. Build + install patched stb0899 (required for DVB-S2)

```bash
sudo bash scripts/install-skystar-driver.sh
```

This installs to `/lib/modules/$(uname -r)/updates/skystar/stb0899.ko`.

**Why patched?** Stock kernel `stb0899` does not lock DVB-S2 on SkyStar `14f7:0001`.

### 4. Build minisatip

```bash
bash scripts/build-minisatip.sh
```

Binary: `minisatip/build/minisatip`

### 5. Reboot

```bash
sudo reboot
```

### 6. Verify driver after reboot

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/
modinfo stb0899 | grep filename
# must show: updates/skystar/stb0899.ko
modinfo dvb_usb_az6027 | grep filename
# must show: kernel/.../dvb-usb-az6027.ko (NOT TBS media_build path)

# if no /dev/dvb:
sudo bash scripts/load-skystar-driver.sh
```

### 7. Start Sat>IP

```bash
./scripts/start-minisatip.sh
# background via systemd:
sudo systemctl start minisatip-skystar
sudo systemctl status minisatip-skystar
```

### 8. DVBViewer (Windows)

- Sat>IP server: `YOUR_SERVER_IP`, port **8554**
- Web status: `http://YOUR_SERVER_IP:8080/`
- Test stream (CT24, Astra 23.5°E DVB-S2):

```
rtsp://YOUR_SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

- CAM decoding on **Windows**, not on Linux server
- **2% signal** in DVBViewer is a known driver quirk — ignore if scan/playback work

---

## After Ubuntu kernel update

Every new kernel requires rebuilding patched `stb0899`:

```bash
cd skystar-satip-docs
sudo bash scripts/install-skystar-driver.sh
sudo reboot
./scripts/start-minisatip.sh
```

Stock `az6027` from the new kernel is fine — only `stb0899` needs rebuild.

---

## Repository layout

```
skystar-satip-docs/
├── SETUP-NEW-SERVER.md      ← this file (start here on new server)
├── LLM-INSTRUCTIONS.md      ← AI safety rules
├── SKYSTAR-GUIDE.md         ← full reference / troubleshooting
├── config.env.example       ← copy to config.env
├── scripts/
│   ├── install-new-server.sh   ← full automated setup
│   ├── install-skystar-driver.sh
│   ├── build-minisatip.sh
│   ├── load-skystar-driver.sh
│   ├── start-minisatip.sh
│   ├── free-tuner.sh
│   └── lib/common.sh
├── stb0899-module/          ← patched driver source
└── systemd/minisatip-skystar.service
```

After install, created locally (not in git):

```
minisatip/build/minisatip    ← built binary
minisatip/cache/             ← runtime cache
backup/                      ← TBS media_build if moved aside
config.env                   ← your settings
```

---

## Healthy system checklist

```bash
lsusb | grep 14f7                                    # SkyStar present
ls /dev/dvb/adapter0/frontend0                     # DVB device
modinfo stb0899 | grep updates/skystar             # patched module
modinfo dvb_usb_az6027 | grep kernel/              # stock az6027
pgrep -a minisatip                                   # running
curl -s http://127.0.0.1:8080/ | head -3             # web UI
ss -tlnp | grep 8554                                 # RTSP port
```

---

## Common failures

| Symptom | Fix |
|---------|-----|
| `Unknown symbol stb0899_attach` | TBS media in `updates/extra/media` → run install script (moves to backup), reboot |
| No DVB-S2 lock | Patched stb0899 not loaded — rebuild + reboot |
| No `/dev/dvb` | `sudo bash scripts/load-skystar-driver.sh` or replug USB |
| minisatip not found | `bash scripts/build-minisatip.sh` |
| Kernel hang after rmmod | **Never** use modprobe -r loops — reboot instead |

---

## Optional: enigma2 server with USM (192.168.1.97 setup)

On the original enigma2 server, minisatip is managed by USM. On a **new** server use **systemd** (`minisatip-skystar.service`) instead.

If USM exists, set in `config.env`:

```bash
USM_PATH=/home/enigma2/universal-service-manager/usm.py
```

---

## LLM prompt for new server

```
Clone https://github.com/logicencoder/skystar-satip-docs
Read SETUP-NEW-SERVER.md and LLM-INSTRUCTIONS.md completely before any changes.
Run: sudo bash scripts/install-new-server.sh && sudo reboot
Then: ./scripts/start-minisatip.sh
Do NOT use modprobe -r loops. Do NOT restore TBS media_build to updates/extra/.
SkyStar is adapter 0. Patched stb0899 is mandatory for DVB-S2.
```
