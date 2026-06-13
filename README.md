# TechniSat SkyStar USB → Sat>IP (minisatip) → DVBViewer on Windows

**Ubuntu server + TechniSat SkyStar USB 2 HD CI + minisatip + DVBViewer Pro**

This repository is a **complete, tested setup guide** for watching satellite TV (including **DVB-S2**) on Windows via Sat>IP, using a TechniSat SkyStar USB tuner on a Linux server.

It is written for **normal users** who want to install it themselves, and for **developers/AI** who must not break a working system while fixing it.

---

## What this setup does (in plain language)

1. **Linux server** (Ubuntu) has the SkyStar USB stick plugged in with the dish/LNB cable.
2. **minisatip** on the server tunes transponders and streams TV over the network (Sat>IP / RTSP).
3. **DVBViewer Pro** on your **Windows PC** connects to the server, scans channels, and decodes paid channels with your **CAM on Windows** (not on the server).

No Enigma2 box mode. No OSCam on the server required for the basic workflow.

---

## What was broken before (real problem we solved)

We switched from a **TBS 5590** card (which worked) to a **TechniSat SkyStar USB 2 HD CI** (`USB 14f7:0001`). After the switch:

| Symptom | What you saw |
|---------|----------------|
| No DVB-S2 lock | Transponders like **12344 H 29900** (DVB-S2, CT24 on Astra 23.5°E) — **no lock, 0 packets** |
| Scan useless | Channel scan / NIT found nothing useful on DVB-S2 |
| minisatip empty | RTSP connected but no picture |
| Wrong signal display | Sometimes **~2% signal** even when it later worked (driver quirk) |
| Driver errors | Kernel log: `Unknown symbol stb0899_attach`, `frequency out of range` |
| System conflicts | Old **TBS media_build** drivers fighting the SkyStar driver |

### Root cause (why it failed)

1. **Main bug:** The **stock Linux `stb0899` driver** has a known bug for **DVB-S2 on SkyStar 14f7:0001**. A patch exists (OSMC/VDR community) but was **never merged into the mainline kernel**. Without the patch, DVB-S2 simply does not work on this stick.

2. **Second problem:** Leftover **TBS 5590 custom drivers** in `/lib/modules/.../updates/extra/media/` caused **symbol version conflicts** — the SkyStar USB driver (`az6027`) could not load against the wrong `stb0899`.

3. **Smaller issues:** wrong minisatip adapter number (`-e 1` vs `-e 0`), Enigma2 settings file breaking demux, USB autosuspend, unsafe `modprobe -r` loops wedging the kernel.

### What we changed (why it works now)

| Fix | Why |
|-----|-----|
| **Patched `stb0899.ko`** built against your Ubuntu kernel | DVB-S2 lock on SkyStar |
| **Stock kernel `az6027`** + patched `stb0899` together | Correct driver combination |
| **TBS media_build moved out** of module path | No symbol conflicts |
| minisatip **`-e 0`** | SkyStar is DVB adapter **0** |
| **Enigma settings** moved aside | SkyStar demux works in normal mode |
| **USB autosuspend off** | Stick stays alive |
| **minisatip** on port **8554**, web **8080** | DVBViewer Sat>IP client |

After these fixes: **scan works, NIT finds transponders, DVB-S2 plays, CAM on Windows works.**

---

## Quick install (new Ubuntu server)

```bash
git clone https://github.com/logicencoder/technisat-skystar-satip-minisatip-dvbviewer-ubuntu.git
cd technisat-skystar-satip-minisatip-dvbviewer-ubuntu
sudo bash scripts/install-new-server.sh
sudo reboot
./scripts/start-minisatip.sh
```

Or enable auto-start:

```bash
sudo systemctl start minisatip-skystar
sudo systemctl enable minisatip-skystar
```

**Detailed walkthrough:** [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md)

---

## Test everything (copy-paste checklist)

See **[TEST-SCENARIOS.md](TEST-SCENARIOS.md)** for the full list. Short version:

### On the Linux server

```bash
# 1. USB stick visible
lsusb | grep 14f7

# 2. DVB device exists
ls /dev/dvb/adapter0/

# 3. Correct patched driver loaded
modinfo stb0899 | grep filename
# → .../updates/skystar/stb0899.ko

# 4. minisatip running
pgrep -a minisatip
curl -s http://127.0.0.1:8080/ | head -5

# 5. RTSP stream test (CT24, Astra 23.5°E DVB-S2)
ffprobe "rtsp://127.0.0.1:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
```

### On Windows (DVBViewer)

1. Add Sat>IP server: **your server IP**, port **8554**
2. Run **channel scan** / NIT on Astra 23.5°E — should find transponders
3. Open **CT24** (or any DVB-S2 channel) — picture + sound
4. **CAM** in DVBViewer decodes subscription channels
5. Ignore **~2% signal** if lock and playback are OK

---

## Hardware & network (reference setup)

| Item | Example |
|------|---------|
| Server | Ubuntu 24.04, any IP (e.g. `192.168.1.97`) |
| Tuner | TechniSat **SkyStar USB 2 HD CI** `14f7:0001` |
| Satellite | Astra **23.5°E** (test TP below) |
| Windows PC | DVBViewer Pro, CAM for decryption |
| Sat>IP RTSP | port **8554** |
| Status web page | `http://SERVER_IP:8080/` |

**Test transponder (DVB-S2):** 12344 MHz, Horizontal, SR 29900, 8PSK, FEC 3/4

**RTSP URL template:**

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

---

## Documentation map

| Document | Who is it for |
|----------|----------------|
| **README.md** (this file) | Everyone — start here |
| [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md) | Full story: symptoms, causes, fixes |
| [TEST-SCENARIOS.md](TEST-SCENARIOS.md) | Step-by-step tests after install |
| [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) | Install from zero on a new machine |
| [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) | Daily use, kernel updates, troubleshooting |
| [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md) | Rules for AI assistants (do not break the system) |

---

## After Ubuntu kernel update

When Ubuntu installs a new kernel, rebuild the patched driver:

```bash
cd technisat-skystar-satip-minisatip-dvbviewer-ubuntu
sudo bash scripts/install-skystar-driver.sh
sudo reboot
./scripts/start-minisatip.sh
```

Only **`stb0899`** needs rebuild — not `az6027`.

---

## For AI assistants (optional)

If you use Cursor/ChatGPT to manage the server, give it this **after** pointing to this repo:

```
Clone https://github.com/logicencoder/technisat-skystar-satip-minisatip-dvbviewer-ubuntu
Read PROBLEM-AND-SOLUTION.md, SETUP-NEW-SERVER.md and LLM-INSTRUCTIONS.md first.
Run: sudo bash scripts/install-new-server.sh && sudo reboot
Then: ./scripts/start-minisatip.sh
FORBIDDEN: modprobe -r loops, USB reset, TBS media in updates/extra/
```

---

## License / credits

- **minisatip:** https://github.com/catalinii/minisatip  
- **stb0899 DVB-S2 patch:** community fix (OSMC/VDR forums), not in mainline kernel  
- **This guide:** tested on Ubuntu 24.04, kernel 6.8.x, SkyStar `14f7:0001`
