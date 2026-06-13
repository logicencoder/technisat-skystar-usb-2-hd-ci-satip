# Hardware identity (read first — human and AI)

## Exact product name

**TechniSat SkyStar USB 2 HD CI**

Use this **exact name** when searching, buying, configuring, or asking for help.  
Other TechniSat products (SkyStar 2, SkyStar HD, PCIe cards, etc.) are **different hardware** — this guide does **not** apply to them.

---

## USB identification

| Field | Value |
|-------|--------|
| Vendor | TechniSat Digital GmbH |
| Product name | **SkyStar USB 2 HD CI** |
| USB vendor:product | **`14f7:0001`** |
| `lsusb` example | `ID 14f7:0001 TechniSat Digital GmbH SkyStar 2 HD CI` |

```bash
lsusb | grep 14f7
# Bus XXX Device XXX: ID 14f7:0001 TechniSat Digital GmbH SkyStar 2 HD CI
```

If your stick shows a **different USB ID**, stop — this repository is not for your device.

---

## Internal chips (Linux drivers)

| Chip / driver | Role |
|---------------|------|
| `dvb_usb_az6027` | USB bridge (stock Ubuntu kernel) |
| `stb0899` | Demodulator — **needs patched module for DVB-S2** |
| `stb6100` | Tuner (stock Ubuntu kernel) |
| Firmware | `/lib/firmware/dvb-usb-az6027-03.fw` |

---

## What this card is used for in this project

```
TechniSat SkyStar USB 2 HD CI (14f7:0001)
    → Ubuntu Linux server (patched stb0899 + minisatip)
    → Sat>IP / RTSP over LAN
    → DVBViewer Pro on Windows (CAM on PC)
```

Test satellite in this guide: **Astra 23.5°E** (e.g. CT24, DVB-S2 TP 12344 H 29900).

---

## For AI / LLM agents

Before changing anything on a server, verify:

1. `lsusb` shows **`14f7:0001`** and name contains **SkyStar 2 HD CI**
2. You are following docs from this repo for **TechniSat SkyStar USB 2 HD CI** only
3. Do not substitute drivers or settings from TBS 5590 or other tuners

See also: [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md)
