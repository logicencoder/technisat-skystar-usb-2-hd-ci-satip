# Test Scenarios — TechniSat SkyStar USB 2 HD CI (FTA)

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

Replace `SERVER_IP` with your server address.

---

## Test 1 — USB

```bash
lsusb | grep 14f7
```

**Expected:** `ID 14f7:0001 TechniSat Digital GmbH SkyStar 2 HD CI`

---

## Test 2 — DVB device

```bash
ls /dev/dvb/adapter0/
```

**Expected:** `frontend0`, `dvr0`, `demux0`, `ca0`

If missing: `sudo bash scripts/load-skystar-driver.sh`

---

## Test 3 — Patched driver

```bash
modinfo stb0899 | grep filename
modinfo dvb_usb_az6027 | grep filename
```

**Expected:**
- `stb0899` → `updates/skystar/stb0899.ko`
- `az6027` → `kernel/.../dvb-usb-az6027` (NOT TBS media path)

---

## Test 4 — minisatip running

```bash
./scripts/start-minisatip.sh
pgrep -a minisatip
ss -tlnp | grep 8554
curl -s http://127.0.0.1:8080/ | head -5
```

**Expected:** process running, ports 8554 + 8080 open

---

## Test 5 — FTA DVB-S2 stream (main test)

Test transponder: **12344 H 29900** Astra 23.5°E (CT24, FTA)

```bash
ffprobe -v error -show_entries stream=codec_name \
  "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

**Expected:** `codec_name=h264` (and often `mp2`)

**VLC on any PC:**

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

---

## Test 6 — Reboot

```bash
sudo reboot
```

After reboot without manual hacks:

```bash
ls /dev/dvb/adapter0/frontend0
./scripts/start-minisatip.sh
```

Repeat Test 5.

---

## Test 7 — Kernel update

After new Ubuntu kernel:

```bash
sudo bash scripts/install-skystar-driver.sh
sudo reboot
```

Repeat Tests 2, 3, 5.

---

## Pass/fail summary

| # | Test | Pass |
|---|------|------|
| 1 | USB | `14f7:0001` |
| 2 | DVB | `/dev/dvb/adapter0/frontend0` |
| 3 | Driver | patched stb0899 + stock az6027 |
| 4 | minisatip | ports 8554/8080 |
| 5 | FTA stream | ffprobe h264 |
| 6 | Reboot | works again |
| 7 | Kernel update | rebuild stb0899, still works |

---

## RTSP URL reference

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

| Param | Value |
|-------|-------|
| src | 1 (adapter 0) |
| freq | 12344 MHz |
| pol | h |
| sr | 29900 |
| msys | dvbs2 |
| mtype | 8psk |
| fec | 34 |
