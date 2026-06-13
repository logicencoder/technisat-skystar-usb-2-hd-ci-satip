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

2. **TBS driver conflict** — TBS-built modules wrong symbol version for SkyStar `az6027`.

3. **Config** — minisatip wrong adapter (`-e 1` vs `-e 0`), enigma settings, USB autosuspend.

---

## Fix

| Change | Result |
|--------|--------|
| Patched `stb0899.ko` | DVB-S2 lock |
| Stock `az6027` + patched `stb0899` | Driver loads |
| TBS media moved out of `updates/` | No symbol errors |
| minisatip `-e 0` | Correct adapter |
| minisatip port 8554 | FTA stream via RTSP |

---

## After fix

- DVB-S2 lock works
- FTA channels stream (e.g. CT24 test TP)
- NIT/scan finds transponders
- ~2% signal display is wrong but playback OK

---

## Do not undo

- Do not put TBS `media_build` back in `updates/extra/media/`
- Do not use stock unpatched `stb0899` for DVB-S2
- Do not run `modprobe -r` loops
- Do not USB reset via sysfs

See [TEST-SCENARIOS.md](TEST-SCENARIOS.md) to verify.
