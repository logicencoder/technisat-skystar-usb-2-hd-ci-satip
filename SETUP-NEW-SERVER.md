# Setup — TechniSat SkyStar USB 2 HD CI (new server)

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

> **Goal:** Card works on Ubuntu with DVB-S2 + **minisatip** streams **FTA** via Sat>IP/RTSP.  
> **Repo:** https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci

---

## Quick install

```bash
git clone https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci.git
cd technisat-skystar-usb-2-hd-ci
cp config.env.example config.env   # optional
sudo bash scripts/install-new-server.sh
sudo reboot
./scripts/start-minisatip.sh
```

AI assistants: also read [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md).

---

## Hardware

| Item | Detail |
|------|--------|
| Card | **TechniSat SkyStar USB 2 HD CI** · **`14f7:0001`** |
| LNB | Connected (e.g. Astra 23.5°E) |
| OS | Ubuntu 22.04 / 24.04 |
| Output | FTA via Sat>IP — VLC or any Sat>IP client |

No TBS `media_build` in `/lib/modules/.../updates/extra/media/`.

---

## Manual steps (if install script fails)

### 1. Packages

```bash
sudo apt update
sudo apt install -y build-essential "linux-headers-$(uname -r)" git cmake \
  libdvbcsa-dev kmod curl firmware-linux-nonfree
ls /lib/firmware/dvb-usb-az6027-03.fw
```

### 2. Patched stb0899 (DVB-S2)

```bash
sudo bash scripts/install-skystar-driver.sh
```

### 3. minisatip

```bash
bash scripts/build-minisatip.sh
```

### 4. Reboot + verify

```bash
sudo reboot
lsusb | grep 14f7
ls /dev/dvb/adapter0/
modinfo stb0899 | grep updates/skystar
```

### 5. Start + test FTA stream

```bash
./scripts/start-minisatip.sh
ffprobe "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

---

## Watch FTA

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

VLC → Open Network Stream. Web status: `http://SERVER_IP:8080/`

---

## Kernel update

```bash
cd technisat-skystar-usb-2-hd-ci
sudo bash scripts/install-skystar-driver.sh
sudo reboot
```

---

## LLM prompt

```
Card: TechniSat SkyStar USB 2 HD CI — USB 14f7:0001 ONLY
Repo: https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci
Read HARDWARE-IDENTITY.md and LLM-INSTRUCTIONS.md first.
Run: sudo bash scripts/install-new-server.sh && sudo reboot
Then: ./scripts/start-minisatip.sh
FTA only. FORBIDDEN: modprobe -r loops, USB reset, TBS media in updates/extra/
```

See also: [TEST-SCENARIOS.md](TEST-SCENARIOS.md)
