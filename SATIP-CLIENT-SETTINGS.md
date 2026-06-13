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
| Whole transponder | **`-k`** in start script (emulates `pids=all` for TransEdit scan / analyzer) |

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
| src | 1 | Source 1 (= adapter 0) |
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

### 3. Scan FTA transponders

1. Run **transponder scan** or **NIT scan**
2. Select **FTA channels only** if the option exists
3. After scan — free channels (e.g. CT24) should appear

### 4. Watch a channel

- Open any **FTA** channel from the list
- Or manual tune via Sat>IP URL in advanced/stream options

### 5. Known quirk

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

### 2. Scan

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
| Also works | VLC, ffprobe, full transponder (`pids=all` with `-k`) |
| Test satellite | Astra 23.5°E |
| Test TP | 12344 H 29900 DVB-S2 (CT24, FTA) |

---

## Troubleshooting Sat>IP

| Problem | Check |
|---------|--------|
| Client cannot connect | `ss -tlnp \| grep 8554`, firewall, correct IP |
| Connect but black screen | Driver OK? Run [TEST-SCENARIOS.md](TEST-SCENARIOS.md) Test 5 |
| Scan finds nothing | Patched stb0899 loaded? DVB-S2 needs patch |
| TransEdit scan fails | RTSP device added in TransEdit? minisatip running with **`-k`**? |
| 2% signal | Ignore if playback works |

Server-side: [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md)
