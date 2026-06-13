# Problem and Solution — TechniSat SkyStar USB 2 HD CI + Sat>IP + DVBViewer

> **Card (exact model):** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**  
> **Hardware details:** [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md)

This document explains **what was wrong**, **why**, and **what we did** — in language a normal person can follow.

---

## The goal

Watch satellite TV on **Windows (DVBViewer Pro)** from a **Linux server** that has a USB satellite tuner connected to the dish.

- Server streams via **Sat>IP** (minisatip)
- Windows receives the stream and **CAM decrypts** subscription channels locally
- Test satellite: **Astra 23.5°E** (e.g. CT24 on DVB-S2 transponder 12344 H 29900)

---

## Hardware change — what triggered the problem

| Before (worked) | After (broken at first) |
|-----------------|-------------------------|
| **TBS 5590** PCIe/USB tuner | **TechniSat SkyStar USB 2 HD CI** |
| USB ID different | USB ID **14f7:0001** |
| Custom TBS drivers (media_build) | Needs **az6027** + **stb0899** drivers |
| minisatip adapter **1** | SkyStar is adapter **0** |

Same LNB cable, same satellite, same Windows client — only the tuner card changed.

---

## Symptoms (what did NOT work)

### On the server

- `lsusb` showed the SkyStar stick — hardware was detected
- Sometimes **no** `/dev/dvb/adapter0/` — driver did not load
- Kernel messages:
  - `dvb_usb_az6027: Unknown symbol stb0899_attach`
  - `disagrees about version of symbol stb0899_attach`
  - `frequency 12344000 out of range`
- Loading wrong driver modules from old **TBS media_build**

### In minisatip / DVBViewer

- minisatip started but **no lock** on DVB-S2 transponders
- **0 packets**, black screen
- Channel **scan** found nothing on DVB-S2
- NIT scan failed or returned empty
- RTSP URL opened but **no video/audio**

### Misleading signs

- Signal strength showed **~2%** in DVBViewer — looked like bad dish/LNB
- In reality, after the fix, **2% still shows** but **everything plays** — the driver reports signal strength incorrectly on this card

---

## Root causes (three separate problems)

### 1. Stock Linux driver bug (main issue)

The SkyStar uses the **STB0899** demodulator chip. The **standard Ubuntu kernel driver** (`stb0899`) has a **long-known bug** for **DVB-S2** on TechniSat **14f7:0001**:

- DVB-S (older transponders) might partially work
- **DVB-S2 does not lock** — exactly what Astra 23.5°E uses for many channels (including CT24)

A **patched driver** exists in the community (OSMC, VDR Portal). It was **never merged** into the official Linux kernel. So every fresh Ubuntu install has the same bug until you apply the patch.

**Fix:** Build and install **patched `stb0899.ko`** into  
`/lib/modules/KERNEL_VERSION/updates/skystar/stb0899.ko`

### 2. TBS driver conflict (second issue)

The server previously ran a **TBS 5590** with custom compiled drivers in:

```
/lib/modules/.../updates/extra/media/
```

When SkyStar was plugged in, Linux preferred those **TBS-built** modules. The SkyStar USB driver (`dvb_usb_az6027`) was compiled against a **different** `stb0899` symbol version → **driver refused to load**.

**Fix:** Move TBS media_build **out** of the module search path (e.g. to `backup/media.disabled.skystar`). Use:

- **Stock kernel** `dvb_usb_az6027`, `dvb_usb`, `stb6100`, `dvb_core`
- **Patched** out-of-tree `stb0899` only

### 3. Configuration mistakes (smaller issues)

| Mistake | Effect |
|---------|--------|
| minisatip `-e 1` (TBS adapter index) | minisatip looked at wrong adapter — SkyStar is **0** |
| `/etc/enigma2/settings` present | Enigma mode → demux error `DMX_SET_SOURCE` on SkyStar |
| USB autosuspend | Stick could disconnect/sleep |
| Aggressive `modprobe -r` in loops | **Kernel hang** — required hard reboot |

---

## What we installed (working combination)

```
USB:     TechniSat SkyStar 2 HD CI (14f7:0001)
         ↓
Driver:  dvb_usb_az6027  (stock Ubuntu kernel)
         stb6100         (stock Ubuntu kernel)
         stb0899         (PATCHED — updates/skystar/)
         ↓
Device:  /dev/dvb/adapter0/frontend0
         ↓
App:     minisatip  (-e 0, RTSP 8554, HTTP 8080)
         ↓
Client:  DVBViewer Pro on Windows (Sat>IP, CAM on PC)
```

---

## Before vs after

| | Before fix | After fix |
|---|------------|-----------|
| DVB-S2 lock on 12344 H | No | **Yes** |
| NIT / scan | Failed / empty | **Finds transponders** |
| RTSP stream | No data | **H.264 + audio** |
| DVBViewer playback | Black screen | **Works** |
| Signal % display | ~2% | Still ~2% (ignore if plays) |
| Kernel symbol errors | Yes | **None** |

---

## What YOU must not undo

These will break the setup again:

1. Putting **TBS media_build** back into `/lib/modules/.../updates/extra/media/`
2. Using **stock unpatched stb0899** and expecting DVB-S2
3. Running **`modprobe -r` in a loop** on DVB modules
4. **USB reset** via sysfs (`echo 1 > remove`)
5. Restoring **`/etc/enigma2/settings`** while using SkyStar without knowing why it was moved

---

## When Ubuntu updates the kernel

Ubuntu updates replace the kernel. The patched `stb0899.ko` is tied to one kernel version.

**After every kernel update:**

```bash
sudo bash scripts/install-skystar-driver.sh
sudo reboot
./scripts/start-minisatip.sh
```

This is normal — not a regression.

---

## Related documents

- [TEST-SCENARIOS.md](TEST-SCENARIOS.md) — verify everything works
- [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md) — install on a new machine
- [SKYSTAR-GUIDE.md](SKYSTAR-GUIDE.md) — daily operations
