# Instructions for AI/LLM Agents — TechniSat SkyStar USB 2 HD CI + Sat>IP

> **MANDATORY hardware (exact model):** **TechniSat SkyStar USB 2 HD CI**  
> **USB ID:** `14f7:0001` (TechniSat Digital GmbH)  
> **Full specs:** [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md)

> **Purpose:** This file exists so the next LLM **does not break the system**. Read this ENTIRE file before making any changes.  
> **This guide applies ONLY to TechniSat SkyStar USB 2 HD CI — not other SkyStar or TechniSat models.**

---

## New server? Start here

**If this is a fresh machine (not the original enigma2 server):**

1. Read [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) — complete install from zero
2. Run: `sudo bash scripts/install-new-server.sh && sudo reboot`
3. Then: `./scripts/start-minisatip.sh`

**Do not improvise.** Follow the scripts in the repo.

---

- Linux server `192.168.1.97`, Ubuntu 24.04, user `enigma2`
- **Active tuner:** **TechniSat SkyStar USB 2 HD CI** (`14f7:0001`)
- **Sat>IP:** minisatip port 8554, web 8080
- **Client:** DVBViewer on Windows, CAM on Windows
- **TBS 5590:** removed, TBS drivers **disabled** in backup

---

## What IS fixed (do not change if working)

1. Patched `stb0899.ko` in `/lib/modules/$(uname -r)/updates/skystar/`
2. Stock kernel `dvb_usb_az6027` (NOT TBS version)
3. TBS media_build in `~/sat_stuff/backup/media.disabled.skystar`
4. minisatip `-e 0` (adapter 0)
5. `/etc/enigma2/settings` → `settings.tbs-only.bak`
6. USB autosuspend disabled (udev)
7. DVB-S2 works (scan, NIT, new transponders, stream)

---

## ABSOLUTE PROHIBITIONS

```
❌ modprobe -r in a loop (stb0899, az6027, dvb_core, dvb_usb)
❌ echo 1 > /sys/bus/usb/devices/.../remove
❌ Restore updates/extra/media/ while using SkyStar
❌ Build stb0899 from vanilla linux tree without Ubuntu headers
❌ Change minisatip to -e 1 (TBS adapter)
❌ Restore /etc/enigma2/settings with SkyStar
❌ Commit passwords/tokens (services.yaml sudo_password, .gitpush_secret.txt)
❌ Push linux-6.8 tree or .ko binaries to git
❌ Blame the LNB cable without dmesg evidence
```

---

## Allowed workflow when something breaks

```
1. READ ONLY diagnostics:
   lsusb | grep 14f7
   ls /dev/dvb/adapter0/
   modinfo stb0899 | grep filename
   modinfo dvb_usb_az6027 | grep filename
   lsmod | grep -E 'stb|az6027|dvb'
   sudo dmesg | tail -40
   tail -50 ~/universal-service-manager/logs/minisatip.log

2. If modules wrong / symbol error:
   → move TBS media to backup (if restored)
   → rebuild stb0899: cd ~/sat_stuff/skystar-driver-build/stb0899-module && make clean && make && sudo make install
   → REBOOT (preferred)

3. After reboot:
   sudo modprobe dvb_usb_az6027
   python3 ~/universal-service-manager/usm.py start minisatip

4. Test:
   curl http://192.168.1.97:8080/
   ffprobe rtsp://192.168.1.97:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

---

## Expected healthy state

```bash
$ lsusb | grep 14f7
Bus ... Device ...: ID 14f7:0001 TechniSat Digital GmbH SkyStar 2 HD CI

$ modinfo stb0899 | grep filename
filename: /lib/modules/6.8.0-XXX-generic/updates/skystar/stb0899.ko

$ modinfo dvb_usb_az6027 | grep filename
filename: /lib/modules/6.8.0-XXX-generic/kernel/drivers/media/usb/dvb-usb/dvb-usb-az6027.ko.zst

$ ls /dev/dvb/adapter0/
ca0  demux0  dvr0  frontend0  net0

$ python3 ~/universal-service-manager/usm.py status minisatip
🟢 RUNNING minisatip ... Port: 8554
```

---

## Known false alarms

| Observation | Reality |
|-------------|---------|
| 2% signal in DVBViewer | Driver reports strength incorrectly — OK if playback works |
| ad_strength=2 in state.json | Same — ignore |
| ffprobe h264 PPS warnings | Normal during first seconds of stream |

---

## Files you may read safely

- `~/sat_stuff/SKYSTAR-GUIDE.md` — main guide
- `~/sat_stuff/minisatip/start-minisatip.sh`
- `~/sat_stuff/minisatip/load-skystar-driver.sh`
- `~/sat_stuff/skystar-driver-build/stb0899-module/stb0899_drv.c` — patch
- `~/universal-service-manager/services.yaml` — **DO NOT commit** (contains sudo password)

---

## Files you may edit (with caution)

- `~/sat_stuff/minisatip/*.sh` — only if you know why
- `~/sat_stuff/skystar-driver-build/stb0899-module/` — driver rebuild
- `/etc/udev/rules.d/70-skystar-usb.rules` — autosuspend

---

## Files/paths you must NOT change

- `/lib/modules/.../updates/extra/media/` — TBS, forbidden with SkyStar
- `/etc/enigma2/settings` — enigma mode, forbidden with SkyStar
- Kernel modules directly without rebuild workflow

---

## After kernel update ALWAYS

```bash
cd ~/sat_stuff/skystar-driver-build/stb0899-module
make clean && make -j$(nproc) && sudo make install
sudo reboot
```

---

## References

- **Hardware:** [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) — **TechniSat SkyStar USB 2 HD CI**
- Main guide: [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md)
- GitHub: https://github.com/logicencoder/technisat-skystar-satip-minisatip-dvbviewer-ubuntu
- Patch origin: OSMC/VDR forums (stb0899 DVB-S2 fix for **TechniSat SkyStar USB 2 HD CI** `14f7:0001`)
