# Test Scenarios — TechniSat SkyStar USB 2 HD CI + Sat>IP + DVBViewer

> **Card (exact model):** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**  
> **Hardware details:** [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md)

Run these tests **in order** after install and reboot. Replace `SERVER_IP` with your Linux server address (e.g. `192.168.1.97`).

---

## Test 0 — Prerequisites

| Check | Command / action | Expected |
|-------|------------------|----------|
| **TechniSat SkyStar USB 2 HD CI** plugged in | Visual — USB cable to server | Stick connected |
| LNB cable | Visual | Connected to **TechniSat SkyStar USB 2 HD CI** |
| Dish | Visual | Pointed at your satellite (e.g. Astra 23.5°E) |
| Network | Ping from Windows | `ping SERVER_IP` replies |

---

## Test 1 — USB detection (server)

```bash
lsusb | grep 14f7
```

**Expected:**

```
... ID 14f7:0001 TechniSat Digital GmbH SkyStar 2 HD CI
```

**If fail:** Reseat USB cable, try another port, reboot.

---

## Test 2 — DVB kernel device (server)

```bash
ls -la /dev/dvb/adapter0/
```

**Expected files:** `frontend0`, `dvr0`, `demux0`, `ca0`, `net0`

**If fail:**

```bash
sudo bash scripts/load-skystar-driver.sh
ls -la /dev/dvb/adapter0/
```

**If still fail:** Check `sudo dmesg | tail -40` for symbol errors → see [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md).

---

## Test 3 — Correct drivers loaded (server)

```bash
modinfo stb0899 | grep filename
modinfo dvb_usb_az6027 | grep filename
lsmod | grep -E 'stb0899|az6027'
```

**Expected:**

| Module | Path must contain |
|--------|-------------------|
| stb0899 | `updates/skystar/stb0899.ko` |
| dvb_usb_az6027 | `kernel/.../dvb-usb-az6027` (NOT `updates/extra/media/`) |

**If stb0899 is stock kernel only:** DVB-S2 will NOT work — run `sudo bash scripts/install-skystar-driver.sh` and reboot.

**If symbol error in dmesg:** TBS media_build conflict — run install script, reboot.

---

## Test 4 — minisatip process (server)

```bash
./scripts/start-minisatip.sh
# or in another terminal if already running:
pgrep -a minisatip
ss -tlnp | grep 8554
curl -s http://127.0.0.1:8080/ | head -10
```

**Expected:**

- Process `minisatip` running
- Port **8554** (RTSP) listening
- Port **8080** (HTTP status page) returns HTML

**Alternative (systemd):**

```bash
sudo systemctl start minisatip-skystar
sudo systemctl status minisatip-skystar
```

---

## Test 5 — DVB-S2 RTSP stream (server, CT24 transponder)

This is the **critical test** — DVB-S2 on Astra 23.5°E:

```bash
ffprobe -v error -show_entries stream=codec_name \
  "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

**Expected:** `codec_name=h264` (and often `mp2` for audio)

**Optional — play 10 seconds with VLC/ffplay:**

```bash
ffplay -t 10 "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

**If fail (no codec / timeout):**

- Patched stb0899 not loaded → Test 3
- Wrong adapter → minisatip must use `-e 0`
- No dish lock → check LNB/cable (but fix driver first)

---

## Test 6 — DVBViewer Sat>IP connection (Windows)

1. Open **DVBViewer Pro**
2. Configure **Sat>IP client**
3. Server: `SERVER_IP`, port: **8554**
4. Connect

**Expected:** DVBViewer sees a Sat>IP server / tuner.

**If fail:** Firewall on server — allow TCP/UDP **8554** from Windows IP.

---

## Test 7 — Channel scan / NIT (Windows)

1. In DVBViewer, run **transponder scan** or **NIT scan** on Astra 23.5°E
2. Use your LNB settings (Universal, 9750/10600/11700)

**Expected:**

- Transponders discovered (including DVB-S2)
- Channels listed after scan

**This failed completely before the stb0899 patch.**

---

## Test 8 — Play CT24 (Windows)

Tune **CT24** (or manually open transponder **12344 H 29900 DVB-S2**).

**Expected:**

- Video and audio play
- Signal may show **~2%** — **ignore if picture is OK** (driver quirk)

---

## Test 9 — CAM / encrypted channel (Windows)

1. Insert CAM configuration in DVBViewer (as before with TBS setup)
2. Open an encrypted channel you subscribe to

**Expected:** Decryption on **Windows** (CAM in PC, not Linux OSCam).

---

## Test 10 — Reboot persistence (server)

```bash
sudo reboot
```

After reboot, **without manual fixes:**

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/frontend0
sudo systemctl start minisatip-skystar   # if using systemd
# or: ./scripts/start-minisatip.sh
```

Repeat **Test 5** RTSP ffprobe.

**Expected:** Everything works again after reboot only.

---

## Test 11 — Kernel update (after apt upgrade)

When Ubuntu installs a new kernel:

```bash
uname -r   # note new version
sudo bash scripts/install-skystar-driver.sh
sudo reboot
```

Repeat Tests 2, 3, 5.

**Expected:** Patched stb0899 rebuilt for new kernel, DVB-S2 still works.

---

## Quick pass/fail summary

| # | Test | Pass criteria |
|---|------|----------------|
| 1 | USB | `14f7:0001` in lsusb |
| 2 | DVB device | `/dev/dvb/adapter0/frontend0` exists |
| 3 | Drivers | patched stb0899 + stock az6027 |
| 4 | minisatip | ports 8554/8080 up |
| 5 | RTSP DVB-S2 | ffprobe shows h264 |
| 6 | DVBViewer connect | Sat>IP server visible |
| 7 | Scan/NIT | transponders found |
| 8 | CT24 play | picture + sound |
| 9 | CAM | encrypted channel decodes |
| 10 | Reboot | works without manual driver hacks |
| 11 | Kernel update | rebuild stb0899, still works |

---

## RTSP URL reference

**CT24 / Astra 23.5°E DVB-S2 (test):**

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

**Parameters:**

| Param | Value | Meaning |
|-------|-------|---------|
| src | 1 | First Sat>IP source (adapter 0) |
| freq | 12344 | MHz |
| pol | h | Horizontal |
| sr | 29900 | Symbol rate |
| msys | dvbs2 | DVB-S2 |
| mtype | 8psk | Modulation |
| fec | 34 | FEC 3/4 |
