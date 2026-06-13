# Problem and Solution — TechniSat SkyStar USB 2 HD CI

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

---

## Goal

Make **TechniSat SkyStar USB 2 HD CI** work on Ubuntu Linux with **DVB-S2**, stream **FTA** channels via **minisatip** (Sat>IP/RTSP).

---

## What did not work (before fix)

| Symptom | Detail |
|---------|--------|
| No DVB-S2 lock | e.g. 12344 H 29900 Astra 23.5°E — 0 lock, 0 packets |
| Scan empty | No useful transponders on DVB-S2 |
| Driver errors | `Unknown symbol stb0899_attach`, symbol version mismatch |
| Wrong modules | Old TBS `media_build` in `/lib/modules/.../updates/extra/media/` |

---

## Why

1. **Stock `stb0899` driver** — DVB-S2 bug on **TechniSat SkyStar USB 2 HD CI** (`14f7:0001`). Community patch exists, not in mainline kernel.

2. **Signal / SNR reporting** — stock driver returns small values (~177–500), not DVB API 0–65535. Sat>IP clients showed **~1–2 %** with good picture. **Fixed in repo** — see [PATCHES.md](PATCHES.md).

3. **TBS driver conflict** — TBS-built modules wrong symbol version for SkyStar `az6027`.

4. **Config** — minisatip wrong adapter (`-e 1` vs `-e 0`), enigma settings, USB autosuspend.

---

## Fix

| Change | Result |
|--------|--------|
| Patched `stb0899.ko` (DVB-S2) | DVB-S2 lock |
| Same module — signal/SNR scale patch | Realistic **0–100 %** in DVBViewer / TransEdit / minisatip |
| Stock `az6027` + patched `stb0899` | Driver loads |
| TBS media moved out of `updates/` | No symbol errors |
| minisatip `-e 0` | Correct adapter |
| minisatip port 8554 | FTA stream via RTSP |

---

## After fix — card fully functional

With the patched driver + minisatip, **TechniSat SkyStar USB 2 HD CI** is **fully usable** on Ubuntu.  
**Do not throw the card away** — stock kernel DVB-S2 is broken; **after the patch everything tested works.**

| What | Works |
|------|--------|
| DVB-S2 lock / tune | ✅ |
| FTA channels (local + Sat>IP) | ✅ |
| **minisatip Sat>IP** (RTSP 8554, web 8080) | ✅ |
| **DiSEqC switch** (multi-dish port switching) | ✅ |
| **DVBViewer** Sat>IP client | ✅ |
| **TransEdit** scan / NIT / full transponder | ✅ |
| **Signal / SNR meters** (Sat>IP clients) | ✅ |
| VLC, ffprobe | ✅ |

Details:

- DVB-S2 lock works
- FTA channels stream (e.g. CT24 test TP)
- NIT/scan finds transponders
- Sat>IP to Windows/Linux clients
- DiSEqC — client sets port; server sends switch command
- Signal/SNR display correct after **patched driver from this repo** ([PATCHES.md](PATCHES.md))

---

## Do not undo

- Do not put TBS `media_build` back in `updates/extra/media/`
- Do not use stock unpatched `stb0899` for DVB-S2
- Do not run `modprobe -r` loops
- Do not USB reset via sysfs

See [TEST-SCENARIOS.md](TEST-SCENARIOS.md) to verify.
