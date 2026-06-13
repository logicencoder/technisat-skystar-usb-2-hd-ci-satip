# TechniSat SkyStar USB 2 HD CI → Sat>IP (minisatip) → DVBViewer on Windows

> **Card (exact model):** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`** · TechniSat Digital GmbH  
> **Hardware details:** [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md)

**Ubuntu server + TechniSat SkyStar USB 2 HD CI + minisatip + DVBViewer Pro**

This repository is a **complete, tested setup guide** for watching satellite TV (including **DVB-S2**) on Windows via Sat>IP, using the **TechniSat SkyStar USB 2 HD CI** on a Linux server.

Written for **normal users** and for **AI assistants** — both should read [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) first.

---

## What this setup does (in plain language)

1. **Linux server** (Ubuntu) has the **TechniSat SkyStar USB 2 HD CI** plugged in with the dish/LNB cable.
2. **minisatip** on the server tunes transponders and streams TV over the network (Sat>IP / RTSP).
3. **DVBViewer Pro** on your **Windows PC** connects to the server, scans channels, and decodes paid channels with your **CAM on Windows** (not on the server).

No Enigma2 box mode. No OSCam on the server required for the basic workflow.

---

## What was broken before (real problem we solved)

We switched from a **TBS 5590** card (which worked) to the **TechniSat SkyStar USB 2 HD CI** (`USB 14f7:0001`). After the switch:

| Symptom | What you saw |
|---------|----------------|
| No DVB-S2 lock | Transponders like **12344 H 29900** (DVB-S2, CT24 on Astra 23.5°E) — **no lock, 0 packets** |
| Scan useless | Channel scan / NIT found nothing useful on DVB-S2 |
| minisatip empty | RTSP connected but no picture |
| Wrong signal display | Sometimes **~2% signal** even when it later worked (driver quirk) |
| Driver errors | Kernel log: `Unknown symbol stb0899_attach`, `frequency out of range` |
| System conflicts | Old **TBS media_build** drivers fighting the **TechniSat SkyStar USB 2 HD CI** driver |

### Root cause (why it failed)

1. **Main bug:** The **stock Linux `stb0899` driver** has a known bug for **DVB-S2 on TechniSat SkyStar USB 2 HD CI (`14f7:0001`)**. A patch exists (OSMC/VDR community) but was **never merged into the mainline kernel**. Without the patch, DVB-S2 does not work on this card.

2. **Second problem:** Leftover **TBS 5590 custom drivers** in `/lib/modules/.../updates/extra/media/` caused **symbol version conflicts** — the SkyStar USB driver (`az6027`) could not load against the wrong `stb0899`.

3. **Smaller issues:** wrong minisatip adapter number (`-e 1` vs `-e 0`), Enigma2 settings file breaking demux, USB autosuspend, unsafe `modprobe -r` loops wedging the kernel.

### What we changed (why it works now)

| Fix | Why |
|-----|-----|
| **Patched `stb0899.ko`** built against your Ubuntu kernel | DVB-S2 lock on **TechniSat SkyStar USB 2 HD CI** |
| **Stock kernel `az6027`** + patched `stb0899` together | Correct driver combination |
| **TBS media_build moved out** of module path | No symbol conflicts |
| minisatip **`-e 0`** | **TechniSat SkyStar USB 2 HD CI** is DVB adapter **0** |
| **Enigma settings** moved aside | Demux works in normal mode |
| **USB autosuspend off** | Card stays alive |
| **minisatip** on port **8554**, web **8080** | DVBViewer Sat>IP client |

After these fixes: **scan works, NIT finds transponders, DVB-S2 plays, CAM on Windows works.**

Full story: [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md)

---

## Quick install (new Ubuntu server)

```bash
git clone https://github.com/logicencoder/technisat-skystar-satip-minisatip-dvbviewer-ubuntu.git
cd technisat-skystar-satip-minisatip-dvbviewer-ubuntu
sudo bash scripts/install-new-server.sh
sudo reboot
./scripts/start-minisatip.sh
```

Or auto-start: `sudo systemctl enable --now minisatip-skystar`

**Detailed walkthrough:** [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md)

---

## Test everything

**[TEST-SCENARIOS.md](TEST-SCENARIOS.md)** — 11 step-by-step tests (USB, driver, RTSP, DVBViewer, CAM, reboot).

Quick check:

```bash
lsusb | grep 14f7   # TechniSat SkyStar USB 2 HD CI
ls /dev/dvb/adapter0/
modinfo stb0899 | grep updates/skystar
pgrep -a minisatip
```

---

## Hardware & network (reference)

| Item | Value |
|------|--------|
| **Tuner (exact)** | **TechniSat SkyStar USB 2 HD CI** |
| USB ID | **`14f7:0001`** |
| Server | Ubuntu 24.04 (example IP `192.168.1.97`) |
| Satellite | Astra **23.5°E** |
| Windows | DVBViewer Pro + CAM |
| Sat>IP RTSP | port **8554** |
| Web status | `http://SERVER_IP:8080/` |

**Test transponder (DVB-S2):** 12344 MHz H, SR 29900, 8PSK — CT24

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

---

## Documentation map

| Document | For |
|----------|-----|
| [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) | **Exact card name & USB ID** — human + AI |
| [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md) | What was wrong and why |
| [TEST-SCENARIOS.md](TEST-SCENARIOS.md) | Verify everything works |
| [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) | Install from zero |
| [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) | Daily use, kernel updates |
| [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md) | AI safety rules |

---

## After Ubuntu kernel update

```bash
cd technisat-skystar-satip-minisatip-dvbviewer-ubuntu
sudo bash scripts/install-skystar-driver.sh
sudo reboot
./scripts/start-minisatip.sh
```

Only **`stb0899`** needs rebuild for **TechniSat SkyStar USB 2 HD CI** — not `az6027`.

---

## For AI assistants

```
Hardware: TechniSat SkyStar USB 2 HD CI — USB 14f7:0001 ONLY
Clone: https://github.com/logicencoder/technisat-skystar-satip-minisatip-dvbviewer-ubuntu
Read: HARDWARE-IDENTITY.md, PROBLEM-AND-SOLUTION.md, LLM-INSTRUCTIONS.md
Run: sudo bash scripts/install-new-server.sh && sudo reboot
Then: ./scripts/start-minisatip.sh
FORBIDDEN: modprobe -r loops, USB reset, TBS media in updates/extra/
```

---

## Credits

- **Card:** TechniSat SkyStar USB 2 HD CI (`14f7:0001`)
- **minisatip:** https://github.com/catalinii/minisatip
- **stb0899 DVB-S2 patch:** community (OSMC/VDR), not in mainline kernel
- **Tested:** Ubuntu 24.04, kernel 6.8.x
