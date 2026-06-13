# Windows 10 / 11 — use Sat>IP, not local drivers

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

TechniSat **stopped updating Windows drivers** years ago (last packages ~2014, Win7/8 era).  
On **Windows 10 and 11** many users get **BSOD / instant reboot** when the card is plugged in or when DVBViewer/ProgDVB starts tuning — especially on **USB 3.x** ports.

**This repo does not fix Windows kernel drivers.** There is no patched `.sys` here.

---

## Recommended: card on Linux, watch on Windows via Sat>IP

**Do not fight broken local drivers.** Use the stack this repo is built for:

```
SkyStar USB  →  Ubuntu PC (patched stb0899 + minisatip)  →  LAN  →  Windows 10/11
                                                                    DVBViewer / TransEdit / VLC
```

| On Windows | Needed? |
|------------|---------|
| TechniSat BDA/USB driver | **No** |
| Sat>IP client (DVBViewer, TransEdit, VLC) | **Yes** |
| Card plugged into Windows PC | **No** |

**Tested:** DVBViewer and TransEdit on Windows over Sat>IP — scan, playback, DiSEqC, full transponder.  
Settings: **[SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)**

Server setup: **[README.md](README.md)** · **[SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md)**

### Quick client setup (Windows)

1. Install **DVBViewer** or **TransEdit** on Windows (no TechniSat driver).
2. Add Sat>IP server: `SERVER_IP:8554` (Linux box running minisatip).
3. Scan / watch FTA — same as local tuner, card stays on Ubuntu.

Example RTSP test in VLC on Windows:

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

---

## Why we do **not** recommend “disable USB 3.x in BIOS”

Forum posts often suggest turning off **xHCI / USB 3.0 / 3.1 / 3.2** in BIOS so the TechniSat driver sees “USB 2.0 only”.

**We do not recommend that** for a daily PC:

- It slows **all** USB devices on the machine (disks, phones, webcams, etc.).
- It is a machine-wide hack for one obsolete tuner.
- It still **may not** stop BSODs — the driver is also incompatible with modern Windows kernels, not only USB speed.

**Better:** leave Windows USB as-is; keep the SkyStar on **Ubuntu + Sat>IP**.

---

## If you still want local Windows drivers (not supported here)

Occasionally people report partial success. **Your mileage may vary** — many still get BSOD.

| Tip | Note |
|-----|------|
| **USB 2.0 port or powered USB 2.0 hub** | Only for the **tuner cable** — does **not** require disabling USB 3.x on the rest of the PC |
| Install **“without HID”** (no remote driver) | HID driver often triggers crashes |
| Device Manager → tuner → disable **power saving** | Sometimes helps wake/tune |
| Win7 drivers on Win10/11 | Unsigned / incompatible — frequent `Kernel Security Check Failure` |

TechniSat has **no official Win10/11 driver**. We cannot maintain or patch closed-source Windows `.sys` files in this project.

---

## Typical BSOD messages (local driver)

Reported by many users worldwide:

- `KERNEL SECURITY CHECK FAILURE`
- `IRQL NOT LESS OR EQUAL`
- Crash within seconds of plug-in or channel change

Same card on **Windows 7** often works; on **Win10/11** often does not — driver age, not necessarily a faulty card.

---

## Summary

| Goal | Do this |
|------|---------|
| Use SkyStar on **Windows 10/11** regularly | **Sat>IP from Ubuntu** ([SATIP-CLIENT-SETTINGS.md](SATIP-CLIENT-SETTINGS.md)) |
| Keep USB 3.x on your PC | **Yes** — no BIOS downgrade needed |
| Fix Windows `.sys` driver in this repo | **Not available** — use Linux server instead |

This is exactly how this project was tested: **Ubuntu 24.04 server** → **Windows clients over the network**.
