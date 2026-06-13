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

### Test 5b — Full transponder (`pids=all`)

Requires minisatip **`-k`** (default in `scripts/start-minisatip.sh`):

```bash
timeout 10 ffprobe -v error -show_entries stream=codec_type -of csv=p=0 \
  "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=all"
```

**Expected:** multiple streams (e.g. `video`, `audio`) — used by **TransEdit** scan/analyzer.

**VLC on any PC** — see [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)

**DVBViewer (Windows)** — Sat>IP FTA tested. Settings in same doc.

---

## Test 6 — DVBViewer Sat>IP (optional, FTA)

1. Add Sat>IP server: `SERVER_IP:8554`
2. Scan Astra 23.5°E — FTA transponders should appear
3. Play CT24 (FTA)

Full DVBViewer steps: [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)

---

## Test 6b — TransEdit Sat>IP (optional, FTA)

1. **Settings → Hardware → Add → RTSP Network Device (Sat>IP)**
2. IP `SERVER_IP`, port `8554` — select this device for scan
3. Scan Astra 23.5°E — transponder + NIT scan should work (full transponder)

Full TransEdit steps: [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)

---

## Test 6c — DiSEqC switch (optional)

**Tested:** DiSEqC port switching works via Sat>IP (`src=` in URL).  
Map **OUT → satellite** in **your** DVBViewer / TransEdit — everyone’s wiring differs.

```bash
# N = DiSEqC port for the dish you want; FREQ/SR = known TP on that satellite
ffprobe -v error -show_entries stream=codec_name -of csv=p=0 \
  "rtsp://127.0.0.1:8554/?src=N&freq=FREQ&pol=h&sr=SR&msys=dvbs2&mtype=8psk&fec=23&pids=0,16,17"
```

Example TP for 23.5°E: `src=N` (your port for 23.5), freq=12344, sr=29900.

Details: [SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md#diseqc-switch--tested-works)

---

## Test 7 — Reboot

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

## Test 8 — Kernel update

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
| 5b | Full transponder | `pids=all` streams |
| 6 | DVBViewer Sat>IP FTA | scan + play (optional) |
| 6b | TransEdit Sat>IP | scan + NIT (optional) |
| 6c | DiSEqC switch | port switching via `src=` (optional) |
| 7 | Reboot | works again |
| 8 | Kernel update | rebuild stb0899, still works |

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
