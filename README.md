# skystar-satip-docs

Kompletná dokumentácia a skripty pre **TechniSat SkyStar USB 2 HD CI** + **minisatip** + **DVBViewer** na Ubuntu.

## Prečo tento repozitár existuje

Stock Linux kernel `stb0899` nevie DVB-S2 na karte `14f7:0001`. Riešenie: patched `stb0899` + stock `az6027` + vypnutý TBS media_build.

Tento repo je **backup návodu** pre usera aj pre AI agentov — aby ďalší LLM nerozbil systém.

## Začni tu

| Súbor | Obsah |
|-------|-------|
| [SKYSTAR-NAVOD.md](SKYSTAR-NAVOD.md) | Kompletný návod — štart, diagnostika, kernel update |
| [LLM-INSTRUKCIE.md](LLM-INSTRUKCIE.md) | **Pre AI:** čo robiť a čo NIKDY nerobiť |

## Hardvér / sieť

- Server: Ubuntu 24.04, `192.168.1.97`
- Karta: TechniSat SkyStar USB 2 HD CI (`14f7:0001`)
- Sat>IP: port 8554, web status 8080
- Klient: DVBViewer Pro (Windows), CAM na Windows

## Rýchly štart (po reboote)

```bash
lsusb | grep 14f7
ls /dev/dvb/adapter0/
sudo modprobe dvb_usb_az6027   # ak chýba /dev/dvb
python3 ~/universal-service-manager/usm.py start minisatip
```

## Test stream (CT24, Astra 23.5°E)

```
rtsp://192.168.1.97:8554/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320
```

## Štruktúra repa

```
scripts/                  — load driver, install, minisatip start
stb0899-module/           — patched driver zdroj (build proti Ubuntu headers)
SKYSTAR-NAVOD.md          — hlavný návod
LLM-INSTRUKCIE.md         — pravidlá pre AI agentov
```

## Kernel update

Po každom novom Ubuntu kerneli rebuildni `stb0899`:

```bash
cd stb0899-module && make clean && make -j$(nproc) && sudo make install && sudo reboot
```

Pozri [SKYSTAR-NAVOD.md](SKYSTAR-NAVOD.md) — sekcia „Kernel update“.

## Lokálna kópia na serveri

```
~/sat_stuff/SKYSTAR-NAVOD.md
~/sat_stuff/LLM-INSTRUKCIE.md
~/sat_stuff/skystar-satip-docs/   ← tento git repozitár
```
