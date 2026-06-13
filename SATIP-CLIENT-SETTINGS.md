# Sat>IP Client Settings — TechniSat SkyStar USB 2 HD CI

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**  
> **Server:** minisatip (Sat>IP) on Ubuntu  
> **Channels:** **FTA only** — no CAM, no codes, no decryption

---

## Server (minisatip) — default settings

These are set by `scripts/start-minisatip.sh`:

| Setting | Value |
|---------|--------|
| Sat>IP / RTSP port | **8554** |
| HTTP status page | **8080** (`http://SERVER_IP:8080/`) |
| DVB adapter | **0** (SkyStar is always adapter 0) |
| LNB | Universal `9750 / 10600 / 11700` MHz |
| Protocol | Sat>IP 1.2 + RTSP |
| Whole transponder | **`-k`** (emulates `pids=all` for TransEdit scan / analyzer) |
| DiSEqC | **`-d '*:2-0'`** (send switch command twice) |
| DiSEqC timing | **`-q '*:25-54-54-25-25-25'`** (pause after switch — physical switch) |

**No satellite map on the server.** minisatip only sends DiSEqC port **`src=1..4`** from the client. You configure which satellite uses which port in **DVBViewer / TransEdit** (see below).

Check server is running:

```bash
pgrep -a minisatip
ss -tlnp | grep -E '8554|8080'
curl -s http://SERVER_IP:8080/ | head -5
```

Firewall (if enabled):

```bash
# allow Sat>IP from your LAN
sudo ufw allow from 192.168.1.0/24 to any port 8554
sudo ufw allow from 192.168.1.0/24 to any port 8080
```

---

## Sat>IP URL format (manual tune)

```
rtsp://SERVER_IP:8554/?src=1&freq=FREQ&pol=POL&sr=SR&msys=MSYS&mtype=MTYPE&fec=FEC&pids=PIDS
```

| Parameter | Example | Meaning |
|-----------|---------|---------|
| src | 1 | **DiSEqC switch port** (1–4), not the DVB adapter number |
| freq | 12344 | Frequency in MHz |
| pol | h or v | Polarisation |
| sr | 29900 | Symbol rate |
| msys | dvbs2 | DVB-S2 (use `dvbs` for DVB-S) |
| mtype | 8psk | Modulation |
| fec | 34 | FEC 3/4 |
| pids | 1310,1320 | Video + audio PIDs |
| pids | all | Full transponder (needs minisatip **`-k`** on server) |

**Example — CT24, Astra 23.5°E (FTA, DVB-S2):**

```
rtsp://192.168.1.97:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

Replace `192.168.1.97` with your server IP.

---

## DiSEqC switch — tested, works

**Tested:** **DiSEqC 1.0 switch** works with **SkyStar + minisatip + Sat>IP** (DVBViewer, TransEdit).  
The server sends the switch command; the **client** chooses **which port** (`src=`).

**Everyone’s wiring is different** — switch OUT 1/2/3 does not necessarily match satellite order.  
**You** set the DiSEqC port in DVBViewer / TransEdit to match **your** dish on each OUT.

### How it works

| Layer | Role |
|-------|------|
| **Server (minisatip)** | Receives `src=1..4` from client → sends DiSEqC to that port. **No satellite map on server.** |
| **DVBViewer** | Per satellite: set **DiSEqC port (1–4)** = which OUT goes to that dish |
| **TransEdit** | Per scan: choose **Pos** (A/A, A/B, B/A, …) = switch port for that satellite |
| **VLC / URL** | Parameter **`src=N`** = DiSEqC port |

Server flags in `scripts/start-minisatip.sh`: **`-d '*:2-0'`**, **`-q '*:25-54-54-25-25-25'`**, **`-k`**.

### Example wiring (one test install — not universal)

Reference from one working setup — **not** a rule for everyone:

| Switch OUT | Satellite (this test) | `src=` | TransEdit Pos | DVBViewer port |
|------------|------------------------|--------|---------------|----------------|
| 1 | Astra 23.5°E | 1 | A/A | 1 |
| 2 | Astra 4.8°E | 2 | B/A | 2 |
| 3 | Astra 19.2°E | 3 | A/B | 3 |

Your 19.2°E might be on OUT2 and 4.8°E on OUT3 — **find your map** by scanning each port.

### Verify (use `src=` for **your** port)

```bash
# N = DiSEqC port for the dish under test; FREQ/SR = known TP on that satellite
ffprobe -v error -show_entries stream=codec_name -of csv=p=0 \
  "rtsp://127.0.0.1:8554/?src=N&freq=FREQ&pol=h&sr=SR&msys=dvbs2&mtype=8psk&fec=23&pids=0,16,17"
```

Example: Astra 23.5°E — 12344 H 29900 (CT24); `src=` = **your** port for the 23.5°E dish.

### Scan tips

- Scan **one satellite at a time** with the correct DiSEqC port / TransEdit Pos **for your wiring**.
- *“Server cannot provide requested transponder”* on some TPs during full scan — normal (one tuner).
- Only **one** client / **one** transponder at a time.

---

## VLC (any OS)

1. **Media → Open Network Stream**
2. Paste RTSP URL (example above)
3. Play

Or command line:

```bash
vlc "rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

---

## DVBViewer Pro (Windows) — Sat>IP, FTA only

> **Tested** with this setup for **FTA channels only**.  
> **No CAM. No codes. No paid/decrypted channels.** This guide does not cover decryption.

### 1. Add Sat>IP server

1. Open **DVBViewer Pro**
2. Go to **Network / Sat>IP** settings (or tuner configuration)
3. Add new **Sat>IP server**:
   - **IP address:** your Linux server IP (e.g. `192.168.1.97`)
   - **Port:** `8554`
   - Protocol: **Sat>IP** (auto-detect is OK)

### 2. LNB / satellite

- **Satellite:** Astra 23.5°E (or your dish position)
- **LNB type:** Universal
- **Low LO:** 9750 MHz
- **High LO:** 10600 MHz
- **Switch:** 11700 MHz

(Same as minisatip `-L '*:9750-10600-11700'` on server.)

### 3. DiSEqC (multi-dish switch)

**Tested** — port switching works. For **each satellite**, set **DiSEqC port (1–4)** in DVBViewer to match **your** switch OUT → dish wiring.  
Same Sat>IP server (`IP:8554`); DVBViewer sends the port on each tune.

One test example (not universal): 23.5°E→port 1, 4.8°E→port 2, 19.2°E→port 3 — see [DiSEqC section](SATIP-CLIENT-SETTINGS.md#diseqc-switch--tested-works).

### 4. Scan FTA transponders

1. Run **transponder scan** or **NIT scan**
2. Select **FTA channels only** if the option exists
3. After scan — free channels (e.g. CT24) should appear

### 5. Watch a channel

- Open any **FTA** channel from the list
- Or manual tune via Sat>IP URL in advanced/stream options

### 6. Known quirk

- Signal strength may show **~2%** — **ignore if picture plays**
- This is a driver reporting issue on **TechniSat SkyStar USB 2 HD CI**, not bad LNB

### What we do NOT document here

- CAM setup
- CI module configuration
- Subscription / encrypted channels
- Keys, OSCam, or any decryption

---

## TransEdit (DVBViewer add-on) — Sat>IP scan

> **Tested** — transponder scan, NIT scan, full transponder (`pids=all`).

TransEdit is **separate** from DVBViewer. Sat>IP in DVBViewer does not configure TransEdit.

### 1. Add RTSP device

1. Open **TransEdit**
2. **Settings → Hardware → Add → RTSP Network Device (Sat>IP)**
3. **IP:** server IP (e.g. `192.168.1.97`), **port:** `8554`
4. **LNB:** Universal (9750 / 10600 / 11700) — same as DVBViewer
5. **DVB-S2:** tick for DVB-S2 transponders
6. **Usage:** Scan or Any
7. If scan fails on UDP — try **Protocol: TCP**

### 2. DiSEqC Pos (per satellite)

**Tested** — switch works over Sat>IP. Before scan, pick **Pos** (A/A, A/B, B/A, …) for **your** wiring — the switch port for that satellite.  
Pos labels depend on switch type; discover your map by scanning or switch labels.

One test example (not for everyone): 23.5°E→A/A, 4.8°E→B/A, 19.2°E→A/B.

### 3. Scan

Select the **RTSP (Sat>IP)** device before scan (not local USB/BDA hardware).

Server must run minisatip with **`-k`** (included in `scripts/start-minisatip.sh`).

---

## Generic Sat>IP client (TVHeadend, vdr, etc.)

| Field | Value |
|-------|--------|
| Host | Server IP |
| Port | 8554 |
| Tuner count | 1 |
| Delivery system | DVB-S / DVB-S2 |

Use SSDP discovery if supported — minisatip announces on the network by default.

Disable SSDP if needed: add `-G` to minisatip start flags in `scripts/start-minisatip.sh`.

---

## Tested setup (reference)

| Item | Value |
|------|--------|
| Card | TechniSat SkyStar USB 2 HD CI (`14f7:0001`) |
| Server | Ubuntu 24.04, minisatip |
| Client tested | **DVBViewer Pro**, **TransEdit** (Windows) — FTA |
| DiSEqC | **Switch tested** — port switching works; **client** maps port → dish |
| Also works | VLC, ffprobe, full transponder (`pids=all` with `-k`) |
| Test example | Astra 23.5°E — 12344 H 29900 (CT24 FTA) |

---

## Troubleshooting Sat>IP

| Problem | Check |
|---------|--------|
| Client cannot connect | `ss -tlnp \| grep 8554`, firewall, correct IP |
| Connect but black screen | Driver OK? Run [TEST-SCENARIOS.md](TEST-SCENARIOS.md) Test 5 |
| Scan finds nothing | Patched stb0899 loaded? DVB-S2 needs patch |
| TransEdit scan fails | RTSP device? **`-k`**? Correct **DiSEqC Pos** for *your* wiring? |
| Wrong satellite / no lock | Wrong **DiSEqC port** in client — check OUT→dish on physical switch |
| “Cannot provide transponder” | Single tuner — scan one sat at a time; some TPs weak — retry |
| 2% signal | Ignore if playback works |

Server-side: [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md)
