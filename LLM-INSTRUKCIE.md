# Inštrukcie pre AI/LLM agentov — SkyStar Sat>IP setup

> **Účel:** Tento súbor existuje aby ďalší LLM **nerozjebal systém**. User ťa sem poslal — prečítaj CELÝ tento súbor pred akoukoľvek zmenou.

---

## Kontext

- Linux server `192.168.1.97`, Ubuntu 24.04, user `enigma2`
- **Aktívna karta:** TechniSat SkyStar USB 2 HD CI (`14f7:0001`)
- **Sat>IP:** minisatip port 8554, web 8080
- **Klient:** DVBViewer na Windows, CAM na Windows
- **TBS 5590:** odstránená, TBS ovládače **vypnuté** v backup

---

## Čo JE opravené (nemeň ak funguje)

1. Patched `stb0899.ko` v `/lib/modules/$(uname -r)/updates/skystar/`
2. Stock kernel `dvb_usb_az6027` (NIE TBS verzia)
3. TBS media_build v `~/sat_stuff/backup/media.disabled.skystar`
4. minisatip `-e 0` (adapter 0)
5. `/etc/enigma2/settings` → `settings.tbs-only.bak`
6. USB autosuspend vypnutý (udev)
7. DVB-S2 funguje (scan, NIT, nové TP, stream)

---

## ABSOLÚTNE ZÁKAZY

```
❌ modprobe -r v slučke (stb0899, az6027, dvb_core, dvb_usb)
❌ echo 1 > /sys/bus/usb/devices/.../remove
❌ Vrátiť updates/extra/media/ pri SkyStar
❌ Build stb0899 z vanilla linux tree bez Ubuntu headers
❌ Meniť -e 1 v minisatip (TBS adapter)
❌ Obnoviť /etc/enigma2/settings pri SkyStar
❌ Commitovať heslá/tokeny (services.yaml sudo_password, .gitpush_secret.txt)
❌ Pushovať linux-6.8 tree alebo .ko binárky do gitu
❌ Blameovať LNB kábel bez dmesg dôkazov
```

---

## Povolený workflow pri probléme

```
1. READ ONLY diagnostika:
   lsusb | grep 14f7
   ls /dev/dvb/adapter0/
   modinfo stb0899 | grep filename
   modinfo dvb_usb_az6027 | grep filename
   lsmod | grep -E 'stb|az6027|dvb'
   sudo dmesg | tail -40
   tail -50 ~/universal-service-manager/logs/minisatip.log

2. Ak moduly zle / symbol error:
   → presuň TBS media do backup (ak späť)
   → rebuild stb0899: cd ~/sat_stuff/skystar-driver-build/stb0899-module && make clean && make && sudo make install
   → REBOOT (preferované)

3. Po reboote:
   sudo modprobe dvb_usb_az6027
   python3 ~/universal-service-manager/usm.py start minisatip

4. Test:
   curl http://192.168.1.97:8080/
   ffprobe rtsp://192.168.1.97:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

---

## Očakávaný stav (healthy)

```bash
$ lsusb | grep 14f7
Bus ... Device ...: ID 14f7:0001 TechniSat Digital GmbH SkyStar 2 HD CI

$ modinfo stb0899 | grep filename
filename: /lib/modules/6.8.0-XXX-generic/updates/skystar/stb0899.ko

$ modinfo dvb_usb_az6027 | grep filename
filename: /lib/modules/6.8.0-XXX-generic/kernel/drivers/media/usb/dvb-usb/dvb-usb-az6027.ko.zst

$ ls /dev/dvb/adapter0/
ca0  demux0  dvr0  frontend0  net0

$ python3 ~/universal-service-manager/usm.py status minisatip
🟢 RUNNING minisatip ... Port: 8554
```

---

## Známe falošné poplachy

| Jav | Realita |
|-----|---------|
| Signál 2 % v DVBViewer | Ovládač zle reportuje strength — OK ak hrá |
| ad_strength=2 v state.json | Rovnaké — ignoruj |
| ffprobe h264 PPS warnings | Normálne pri prvých sekundách streamu |

---

## Súbory ktoré môžeš bezpečne čítať

- `~/sat_stuff/SKYSTAR-NAVOD.md` — hlavný návod
- `~/sat_stuff/minisatip/start-minisatip.sh`
- `~/sat_stuff/minisatip/load-skystar-driver.sh`
- `~/sat_stuff/skystar-driver-build/stb0899-module/stb0899_drv.c` — patch
- `~/universal-service-manager/services.yaml` — **NEcommituj** (obsahuje sudo heslo)

---

## Súbory ktoré môžeš meniť (s opatrnosťou)

- `~/sat_stuff/minisatip/*.sh` — len ak vieš prečo
- `~/sat_stuff/skystar-driver-build/stb0899-module/` — rebuild driver
- `/etc/udev/rules.d/70-skystar-usb.rules` — autosuspend

---

## Súbory/kmene ktoré NEMENIŤ

- `/lib/modules/.../updates/extra/media/` — TBS, zakázané pre SkyStar
- `/etc/enigma2/settings` — enigma režim, zakázané pre SkyStar
- Kernel moduly priamo bez rebuild workflow

---

## Po kernel update VŽDY

```bash
cd ~/sat_stuff/skystar-driver-build/stb0899-module
make clean && make -j$(nproc) && sudo make install
sudo reboot
```

---

## Referencie

- Hlavný návod: `~/sat_stuff/SKYSTAR-NAVOD.md`
- GitHub: https://github.com/logicencoder/skystar-satip-docs
- Patch pôvod: OSMC/VDR fóra (stb0899 I2C DVB-S2 fix pre 14f7:0001)
