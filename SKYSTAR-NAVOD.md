# SkyStar USB 2 HD CI + minisatip + DVBViewer — kompletný návod

> **Server:** Ubuntu 24.04, IP `192.168.1.97`, user `enigma2`  
> **Karta:** TechniSat SkyStar USB 2 HD CI (`14f7:0001`)  
> **Klient:** DVBViewer Pro na Windows (~`192.168.1.196`)  
> **Satelit:** Astra 23.5°E (test TP: 12344 H 29900 DVB-S2 8PSK — CT24)  
> **Kernel (aktuálne):** `6.8.0-124-generic`

---

## ⚠️ PRE AI / LLM — PREČÍTAJ NAJPRV (NEPRESKOČ)

Ak si AI agent a user ťa poslal sem: **NEOpravuj naslepo. NEexperimentuj.**

### ZÁKAZY (porušenie môže zaseknúť kernel / rozbiť DVB)

| NIKDY nerob | Prečo |
|-------------|-------|
| `modprobe -r` v slučke na `stb0899`, `dvb_usb_az6027`, `dvb_core` | Zasekne kernel (overené) |
| USB reset cez `/sys/.../remove` alebo `echo 1 > remove` | Odpojí kartu, orphan moduly |
| Vrátiť TBS `media_build` do `/lib/modules/.../updates/extra/media/` pri SkyStar | Symbol mismatch, az6027 nenabehne |
| Použiť `/etc/enigma2/settings` pri SkyStar | `DMX_SET_SOURCE` fail |
| Meniť minisatip `-e 1` (SkyStar je adapter **0**) | minisatip nevidí tuner |
| Buildovať `stb0899` z vanilla linux-6.8 bez Ubuntu headers | Symbol CRC mismatch s `az6027` |
| Commitovať heslá, tokeny, `.gitpush_secret.txt` | Bezpečnosť |

### POVOLENÝ postup pri probléme

1. Diagnostika (`lsusb`, `ls /dev/dvb`, `dmesg`, `modinfo`)
2. Ak moduly zle načítané → **reboot** (nie agresívny rmmod)
3. Po reboote: `sudo modprobe dvb_usb_az6027`
4. Ak nový kernel → rebuild patched `stb0899` (pozri sekciu Kernel update)
5. Spusti minisatip cez USM

### Správna kombinácia modulov

```
stock kernel:  dvb_core, dvb_usb, stb6100, dvb_usb_az6027  (z kernel/)
patched OOT:   stb0899  (z updates/skystar/stb0899.ko)
TBS media:     VYPNUTÉ — v ~/sat_stuff/backup/media.disabled.skystar
```

Overenie:

```bash
modinfo stb0899 | grep filename
# → /lib/modules/$(uname -r)/updates/skystar/stb0899.ko

modinfo dvb_usb_az6027 | grep filename
# → /lib/modules/$(uname -r)/kernel/drivers/media/usb/dvb-usb/dvb-usb-az6027.ko.zst
# NIE updates/extra/media/...
```

---

## V čom bol problém (zhrnutie)

1. **Hlavná príčina:** Stock Linux ovládač `stb0899` má bug pri **DVB-S2** na SkyStar `14f7:0001`. Patch existuje roky, nie je v mainline kerneli.
2. **TBS media_build** v `updates/extra/media/` kolidoval — iné verzie symbolov (`stb0899_attach`).
3. **Drobnosti:** minisatip `-e 1` (TBS adapter), enigma settings, USB autosuspend.

**2 % signál v DVBVieweri** = známy quirk ovládača. Ak lock + scan + obraz fungujú, signál percentuálne klame.

---

## Súborová mapa (všetko dôležité)

| Čo | Cesta |
|----|-------|
| Tento návod | `~/sat_stuff/SKYSTAR-NAVOD.md` |
| LLM pravidlá | `~/sat_stuff/LLM-INSTRUKCIE.md` |
| minisatip start | `~/sat_stuff/minisatip/start-minisatip-free-tuner.sh` |
| minisatip hlavný | `~/sat_stuff/minisatip/start-minisatip.sh` |
| Load driver skript | `~/sat_stuff/minisatip/load-skystar-driver.sh` |
| minisatip binary | `~/sat_stuff/minisatip/source/build/minisatip` |
| USM služba | `~/universal-service-manager/services.yaml` |
| USM log | `~/universal-service-manager/logs/minisatip.log` |
| Patched stb0899 (inštalovaný) | `/lib/modules/$(uname -r)/updates/skystar/stb0899.ko` |
| Patched stb0899 zdroj | `~/sat_stuff/skystar-driver-build/stb0899-module/` |
| Rebuild + install | `~/sat_stuff/skystar-driver-build/build-and-install.sh` |
| Install skript | `~/sat_stuff/skystar-driver-build/install-skystar-driver.sh` |
| TBS moduly (vypnuté) | `~/sat_stuff/backup/media.disabled.skystar` |
| Firmware | `/lib/firmware/dvb-usb-az6027-03.fw` |
| Autoload az6027 | `/etc/modules-load.d/skystar.conf` |
| Blok TBS5590 | `/etc/modprobe.d/skystar-no-tbs.conf` |
| USB autosuspend off | `/etc/udev/rules.d/70-skystar-usb.rules` |
| enigma settings (TBS) | `/etc/enigma2/settings.tbs-only.bak` |
| Sat>IP web | `http://192.168.1.97:8080/` |
| Sat>IP RTSP port | `8554` |

---

## Bežný štart po reboote

```bash
# 1. SkyStar na USB?
lsusb | grep 14f7
# očakávané: TechniSat Digital GmbH SkyStar 2 HD CI

# 2. DVB zariadenie?
ls /dev/dvb/adapter0/
# očakávané: ca0 demux0 dvr0 frontend0 net0

# 3. Ak chýba /dev/dvb:
sudo modprobe dvb_usb_az6027
sleep 2
ls /dev/dvb/adapter0/

# 4. Over patched modul
modinfo stb0899 | grep filename
lsmod | grep -E 'stb0899|az6027'

# 5. Spusti Sat>IP (zastaví le_hscr ak beží)
python3 ~/universal-service-manager/usm.py start minisatip

# 6. Stav
python3 ~/universal-service-manager/usm.py status minisatip
curl -s http://192.168.1.97:8080/ | head -3
ss -tlnp | grep 8554
```

---

## DVBViewer (Windows)

1. Sat>IP server: `192.168.1.97`, port **8554**
2. CAM dekódovanie na **Windows** (nie OSCam na Linuxe)
3. Scan / NIT — Astra 23.5°E
4. Test stream (CT24):

```
rtsp://192.168.1.97:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

**Poznámka:** `src=1` = prvý tuner (adapter 0). Signál môže ukazovať ~2 % — ignoruj ak hrá.

---

## USM príkazy (minisatip)

```bash
python3 ~/universal-service-manager/usm.py start minisatip
python3 ~/universal-service-manager/usm.py stop minisatip
python3 ~/universal-service-manager/usm.py status minisatip
python3 ~/universal-service-manager/usm.py restart minisatip
```

`start-minisatip-free-tuner.sh` pred spustením:
- `docker stop le_hscr_sigint`
- `pkill -f sat_play.conf`
- načíta SkyStar driver ak chýba
- spustí minisatip s `-e 0` (adapter 0)

---

## Kernel update (Ubuntu upgrade) — PO KAŽDOM NOVOM KERNELI

Po `apt upgrade` ak pribudne nový kernel (napr. `6.8.0-125-generic`):

```bash
# 1. Reboot do nového kernelu
sudo reboot

# 2. Over
uname -r

# 3. Rebuild patched stb0899 proti NOVÝM headers
cd ~/sat_stuff/skystar-driver-build/stb0899-module
make clean
make -j$(nproc)
sudo make install

# 4. Skontroluj TBS media — nesmie byť v updates/
ls /lib/modules/$(uname -r)/updates/extra/media 2>/dev/null && echo "POZOR!" || echo "OK"

# Ak TBS media existuje:
sudo mv /lib/modules/$(uname -r)/updates/extra/media ~/sat_stuff/backup/media.$(uname -r)
sudo depmod -a

# 5. Načítaj + spusti
sudo modprobe dvb_usb_az6027
python3 ~/universal-service-manager/usm.py start minisatip
```

Alebo jedným príkazom (potom reboot):

```bash
bash ~/sat_stuff/skystar-driver-build/build-and-install.sh
sudo reboot
python3 ~/universal-service-manager/usm.py start minisatip
```

**Stock `az6027` netreba patchovať** — len `stb0899`.

---

## Prvá inštalácia SkyStar (clean setup)

```bash
# Firmware (ak chýba)
ls /lib/firmware/dvb-usb-az6027-03.fw

# Presuň TBS media mimo module path (ak existuje)
sudo mv /lib/modules/$(uname -r)/updates/extra/media ~/sat_stuff/backup/media.disabled.skystar 2>/dev/null || true
sudo depmod -a

# Build + install patched stb0899
bash ~/sat_stuff/skystar-driver-build/build-and-install.sh

# udev autosuspend
sudo cp ~/sat_stuff/skystar-driver-build/70-skystar-usb.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

# enigma settings preč (ak existuje)
sudo mv /etc/enigma2/settings /etc/enigma2/settings.tbs-only.bak 2>/dev/null || true

# Reboot
sudo reboot

# Po reboote — bežný štart (sekcia vyššie)
```

---

## Diagnostika / troubleshooting

```bash
# Logy
tail -80 ~/universal-service-manager/logs/minisatip.log
sudo dmesg | grep -iE 'az6027|stb0899|14f7|dvb' | tail -40

# Moduly
lsmod | grep -E 'stb|az6027|dvb|tbs'
modinfo stb0899 | grep filename
modinfo dvb_usb_az6027 | grep filename

# Procesy
pgrep -a minisatip
docker ps | grep le_hscr
ss -tlnp | grep 8554
```

| Symptóm | Riešenie |
|---------|----------|
| `Unknown symbol stb0899_attach` | TBS media späť v updates → presuň do backup, `depmod -a`, **reboot** |
| `disagrees about version of symbol` | Rebuild stb0899 proti `uname -r` headers, reboot |
| Žiadne `/dev/dvb` | `sudo modprobe dvb_usb_az6027` alebo reboot + replug USB |
| minisatip no adapter | Over `-e 0` v start-minisatip.sh |
| Tuner busy | `docker stop le_hscr_sigint` |
| 0 lock na DVB-S2 | Over patched stb0899 (nie stock) |
| Karta mizne z USB | Replug USB alebo reboot |
| Kernel wedge | Hard reboot — potom **nepoužívaj rmmod slučky** |

---

## Návrat na TBS 5590 (ak prepneš hardvér)

```bash
python3 ~/universal-service-manager/usm.py stop minisatip
# Vymeniť USB kartu fyzicky
sudo mv ~/sat_stuff/backup/media.disabled.skystar /lib/modules/$(uname -r)/updates/extra/media
sudo mv /etc/enigma2/settings.tbs-only.bak /etc/enigma2/settings
sudo depmod -a
sudo reboot
# V start-minisatip.sh zmeň -e 0 na -e 1
```

---

## GitHub repozitár

Dokumentácia a skripty: **https://github.com/logicencoder/skystar-satip-docs**

---

*Posledná aktualizácia: jún 2026*
