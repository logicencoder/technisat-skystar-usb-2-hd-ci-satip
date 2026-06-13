# TechniSat SkyStar USB 2 HD CI — Reference Guide

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

Daily use, troubleshooting, kernel updates. **FTA only.**

---

## ⚠️ For AI / LLM — read first

See [LLM-INSTRUCTIONS.md](LLM-INSTRUCTIONS.md). **Do not** run `modprobe -r` loops or restore TBS media to `updates/extra/`.

---

## Correct drivers

```
stock kernel:  dvb_core, dvb_usb, stb6100, dvb_usb_az6027
patched OOT:   stb0899  → updates/skystar/stb0899.ko
TBS media:     DISABLED (backup/ folder)
```

```bash
modinfo stb0899 | grep filename
modinfo dvb_usb_az6027 | grep filename
```

---

## Start minisatip

```bash
./scripts/start-minisatip.sh
# or:
sudo systemctl start minisatip-skystar
```

Ports: RTSP **8554**, web **8080**. Adapter: **0** (`-e 0`).

---

## FTA test stream (Astra 23.5°E CT24, DVB-S2)

```
rtsp://SERVER_IP:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

~2% signal in some clients = driver quirk. Ignore if video plays.

---

## Normal startup after reboot

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/
sudo modprobe dvb_usb_az6027    # if needed
./scripts/start-minisatip.sh
```

---

## Kernel update

```bash
sudo bash scripts/install-skystar-driver.sh
sudo reboot
./scripts/start-minisatip.sh
```

Only **stb0899** needs rebuild.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Unknown symbol stb0899_attach` | Move TBS media out of updates/, reboot |
| No DVB-S2 lock | Rebuild patched stb0899 |
| No `/dev/dvb` | `sudo bash scripts/load-skystar-driver.sh` |
| Kernel hang | Reboot — never use rmmod loops |

Full tests: [TEST-SCENARIOS.md](TEST-SCENARIOS.md)  
Full story: [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md)

---

## Repo

https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci-satip
