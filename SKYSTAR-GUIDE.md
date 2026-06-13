# SkyStar USB 2 HD CI + minisatip + DVBViewer — Complete Guide

> **Server:** Ubuntu 24.04, IP `192.168.1.97`, user `enigma2`  
> **Tuner:** TechniSat SkyStar USB 2 HD CI (`14f7:0001`)  
> **Client:** DVBViewer Pro on Windows (~`192.168.1.196`)  
> **Satellite:** Astra 23.5°E (test TP: 12344 H 29900 DVB-S2 8PSK — CT24)  
> **Kernel (current):** `6.8.0-124-generic`

---

## ⚠️ FOR AI / LLM — READ FIRST (DO NOT SKIP)

If you are an AI agent and the user sent you here: **Do NOT fix blindly. Do NOT experiment.**

### FORBIDDEN actions (can wedge the kernel / break DVB)

| NEVER do this | Why |
|---------------|-----|
| `modprobe -r` in a loop on `stb0899`, `dvb_usb_az6027`, `dvb_core` | Can wedge the kernel (verified) |
| USB reset via `/sys/.../remove` or `echo 1 > remove` | Disconnects the card, orphan modules |
| Restore TBS `media_build` to `/lib/modules/.../updates/extra/media/` while using SkyStar | Symbol mismatch, az6027 won't load |
| Use `/etc/enigma2/settings` with SkyStar | `DMX_SET_SOURCE` failure |
| Change minisatip to `-e 1` (SkyStar is adapter **0**) | minisatip won't see the tuner |
| Build `stb0899` from vanilla linux-6.8 without Ubuntu headers | Symbol CRC mismatch with `az6027` |
| Commit passwords, tokens, `.gitpush_secret.txt` | Security |

### Allowed troubleshooting workflow

1. Read-only diagnostics (`lsusb`, `ls /dev/dvb`, `dmesg`, `modinfo`)
2. If modules are wrong → **reboot** (not aggressive rmmod)
3. After reboot: `sudo modprobe dvb_usb_az6027`
4. If new kernel → rebuild patched `stb0899` (see Kernel update section)
5. Start minisatip via USM

### Correct module combination

```
stock kernel:  dvb_core, dvb_usb, stb6100, dvb_usb_az6027  (from kernel/)
patched OOT:   stb0899  (from updates/skystar/stb0899.ko)
TBS media:     DISABLED — in ~/sat_stuff/backup/media.disabled.skystar
```

Verify:

```bash
modinfo stb0899 | grep filename
# → /lib/modules/$(uname -r)/updates/skystar/stb0899.ko

modinfo dvb_usb_az6027 | grep filename
# → /lib/modules/$(uname -r)/kernel/drivers/media/usb/dvb-usb/dvb-usb-az6027.ko.zst
# NOT updates/extra/media/...
```

---

## What was wrong (summary)

1. **Root cause:** Stock Linux `stb0899` driver has a **DVB-S2 bug** on SkyStar `14f7:0001`. A patch exists (OSMC/VDR forums) but was never merged into mainline.
2. **TBS media_build** in `updates/extra/media/` conflicted — different symbol versions (`stb0899_attach`).
3. **Minor issues:** minisatip `-e 1` (TBS adapter), enigma settings, USB autosuspend.

**2% signal in DVBViewer** = known driver quirk. If lock + scan + playback work, ignore the percentage.

---

## File map (everything important)

| Item | Path |
|------|------|
| This guide | `~/sat_stuff/SKYSTAR-GUIDE.md` |
| LLM rules | `~/sat_stuff/LLM-INSTRUCTIONS.md` |
| minisatip start | `~/sat_stuff/minisatip/start-minisatip-free-tuner.sh` |
| minisatip main | `~/sat_stuff/minisatip/start-minisatip.sh` |
| Load driver script | `~/sat_stuff/minisatip/load-skystar-driver.sh` |
| minisatip binary | `~/sat_stuff/minisatip/source/build/minisatip` |
| USM service | `~/universal-service-manager/services.yaml` |
| USM log | `~/universal-service-manager/logs/minisatip.log` |
| Patched stb0899 (installed) | `/lib/modules/$(uname -r)/updates/skystar/stb0899.ko` |
| Patched stb0899 source | `~/sat_stuff/skystar-driver-build/stb0899-module/` |
| Rebuild + install | `~/sat_stuff/skystar-driver-build/build-and-install.sh` |
| Install script | `~/sat_stuff/skystar-driver-build/install-skystar-driver.sh` |
| TBS modules (disabled) | `~/sat_stuff/backup/media.disabled.skystar` |
| Firmware | `/lib/firmware/dvb-usb-az6027-03.fw` |
| Autoload az6027 | `/etc/modules-load.d/skystar.conf` |
| Block TBS5590 | `/etc/modprobe.d/skystar-no-tbs.conf` |
| USB autosuspend off | `/etc/udev/rules.d/70-skystar-usb.rules` |
| enigma settings (TBS) | `/etc/enigma2/settings.tbs-only.bak` |
| Sat>IP web | `http://192.168.1.97:8080/` |
| Sat>IP RTSP port | `8554` |

---

## Normal startup after reboot

```bash
# 1. SkyStar on USB?
lsusb | grep 14f7
# expected: TechniSat Digital GmbH SkyStar 2 HD CI

# 2. DVB device?
ls /dev/dvb/adapter0/
# expected: ca0 demux0 dvr0 frontend0 net0

# 3. If /dev/dvb is missing:
sudo modprobe dvb_usb_az6027
sleep 2
ls /dev/dvb/adapter0/

# 4. Verify patched module
modinfo stb0899 | grep filename
lsmod | grep -E 'stb0899|az6027'

# 5. Start Sat>IP (stops le_hscr if running)
python3 ~/universal-service-manager/usm.py start minisatip

# 6. Status
python3 ~/universal-service-manager/usm.py status minisatip
curl -s http://192.168.1.97:8080/ | head -3
ss -tlnp | grep 8554
```

---

## DVBViewer (Windows)

1. Sat>IP server: `192.168.1.97`, port **8554**
2. CAM decoding on **Windows** (not OSCam on Linux)
3. Scan / NIT — Astra 23.5°E
4. Test stream (CT24):

```
rtsp://192.168.1.97:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

**Note:** `src=1` = first tuner (adapter 0). Signal may show ~2% — ignore if playback works.

---

## USM commands (minisatip)

```bash
python3 ~/universal-service-manager/usm.py start minisatip
python3 ~/universal-service-manager/usm.py stop minisatip
python3 ~/universal-service-manager/usm.py status minisatip
python3 ~/universal-service-manager/usm.py restart minisatip
```

`start-minisatip-free-tuner.sh` before start:
- `docker stop le_hscr_sigint`
- `pkill -f sat_play.conf`
- loads SkyStar driver if missing
- runs minisatip with `-e 0` (adapter 0)

---

## Kernel update (after every new Ubuntu kernel)

After `apt upgrade` when a new kernel appears (e.g. `6.8.0-125-generic`):

```bash
# 1. Reboot into new kernel
sudo reboot

# 2. Verify
uname -r

# 3. Rebuild patched stb0899 against NEW headers
cd ~/sat_stuff/skystar-driver-build/stb0899-module
make clean
make -j$(nproc)
sudo make install

# 4. Ensure TBS media is NOT in updates/
ls /lib/modules/$(uname -r)/updates/extra/media 2>/dev/null && echo "WARNING!" || echo "OK"

# If TBS media exists:
sudo mv /lib/modules/$(uname -r)/updates/extra/media ~/sat_stuff/backup/media.$(uname -r)
sudo depmod -a

# 5. Load + start
sudo modprobe dvb_usb_az6027
python3 ~/universal-service-manager/usm.py start minisatip
```

Or one-shot (then reboot):

```bash
bash ~/sat_stuff/skystar-driver-build/build-and-install.sh
sudo reboot
python3 ~/universal-service-manager/usm.py start minisatip
```

**Stock `az6027` does NOT need patching** — only `stb0899`.

---

## First-time SkyStar setup (clean install)

```bash
# Firmware (if missing)
ls /lib/firmware/dvb-usb-az6027-03.fw

# Move TBS media out of module path (if present)
sudo mv /lib/modules/$(uname -r)/updates/extra/media ~/sat_stuff/backup/media.disabled.skystar 2>/dev/null || true
sudo depmod -a

# Build + install patched stb0899
bash ~/sat_stuff/skystar-driver-build/build-and-install.sh

# udev autosuspend
sudo cp ~/sat_stuff/skystar-driver-build/70-skystar-usb.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

# Remove enigma settings (if present)
sudo mv /etc/enigma2/settings /etc/enigma2/settings.tbs-only.bak 2>/dev/null || true

# Reboot
sudo reboot

# After reboot — normal startup (section above)
```

---

## Diagnostics / troubleshooting

```bash
# Logs
tail -80 ~/universal-service-manager/logs/minisatip.log
sudo dmesg | grep -iE 'az6027|stb0899|14f7|dvb' | tail -40

# Modules
lsmod | grep -E 'stb|az6027|dvb|tbs'
modinfo stb0899 | grep filename
modinfo dvb_usb_az6027 | grep filename

# Processes
pgrep -a minisatip
docker ps | grep le_hscr
ss -tlnp | grep 8554
```

| Symptom | Fix |
|---------|-----|
| `Unknown symbol stb0899_attach` | TBS media back in updates → move to backup, `depmod -a`, **reboot** |
| `disagrees about version of symbol` | Rebuild stb0899 against `uname -r` headers, reboot |
| No `/dev/dvb` | `sudo modprobe dvb_usb_az6027` or reboot + replug USB |
| minisatip no adapter | Check `-e 0` in start-minisatip.sh |
| Tuner busy | `docker stop le_hscr_sigint` |
| 0 lock on DVB-S2 | Verify patched stb0899 (not stock) |
| Card disappears from USB | Replug USB or reboot |
| Kernel wedge | Hard reboot — then **never use rmmod loops** |

---

## Switching back to TBS 5590

```bash
python3 ~/universal-service-manager/usm.py stop minisatip
# Swap USB hardware physically
sudo mv ~/sat_stuff/backup/media.disabled.skystar /lib/modules/$(uname -r)/updates/extra/media
sudo mv /etc/enigma2/settings.tbs-only.bak /etc/enigma2/settings
sudo depmod -a
sudo reboot
# In start-minisatip.sh change -e 0 to -e 1
```

---

## GitHub repository

Documentation and scripts: **https://github.com/logicencoder/skystar-satip-docs**

**New server setup:** see [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) in the repo.

---

*Last updated: June 2026*
