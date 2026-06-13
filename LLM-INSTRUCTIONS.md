# LLM Instructions — TechniSat SkyStar USB 2 HD CI

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`** ONLY  
> **Repo:** https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci  
> **Scope:** FTA Sat>IP via minisatip — **no CAM, no decryption setup**

Read [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md) before any changes.

---

## New server

```bash
git clone https://github.com/logicencoder/technisat-skystar-usb-2-hd-ci.git
cd technisat-skystar-usb-2-hd-ci
sudo bash scripts/install-new-server.sh
sudo reboot
./scripts/start-minisatip.sh
```

---

## What is fixed (do not break)

1. Patched `stb0899.ko` in `updates/skystar/`
2. Stock kernel `dvb_usb_az6027`
3. TBS media_build in `backup/` — NOT in `updates/extra/`
4. minisatip `-e 0`
5. DVB-S2 FTA streaming works

---

## FORBIDDEN

```
❌ modprobe -r loops
❌ USB reset via sysfs
❌ TBS media back in updates/extra/
❌ Stock unpatched stb0899 for DVB-S2
❌ minisatip -e 1 (card is adapter 0)
❌ Commit passwords/tokens
```

---

## Diagnostics (read-only first)

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/
modinfo stb0899 | grep filename
modinfo dvb_usb_az6027 | grep filename
sudo dmesg | tail -40
pgrep -a minisatip
```

---

## Healthy state

```bash
# USB: 14f7:0001 TechniSat SkyStar USB 2 HD CI
# stb0899: updates/skystar/stb0899.ko
# az6027: kernel/.../dvb-usb-az6027
# ffprobe RTSP → codec_name=h264
```

---

## References

- [HARDWARE-IDENTITY.md](HARDWARE-IDENTITY.md)
- [SETUP-NEW-SERVER.md](SETUP-NEW-SERVER.md)
- [TEST-SCENARIOS.md](TEST-SCENARIOS.md)
- [PROBLEM-AND-SOLUTION.md](PROBLEM-AND-SOLUTION.md)
