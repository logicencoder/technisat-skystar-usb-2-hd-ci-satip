# Patched `stb0899` driver — what is in this repo

> **Card:** **TechniSat SkyStar USB 2 HD CI** · USB **`14f7:0001`**

Source: [`stb0899-module/`](stb0899-module/) — built by `scripts/install-skystar-driver.sh`  
Install path: `/lib/modules/$(uname -r)/updates/skystar/stb0899.ko`

This is **not** the stock Ubuntu kernel driver. The repo ships **one out-of-tree module** with **three fixes** applied on top of the community DVB-S2 patch.

---

## Patch 1 — DVB-S2 lock (required)

| | |
|--|--|
| **Problem** | Stock Linux `stb0899` cannot lock **DVB-S2** on TechniSat **`14f7:0001`** — no tune, empty scan |
| **Fix** | Community demod patch (OSMC / VDR Portal lineage), never merged to mainline |
| **Tested** | ✅ DVB-S2 tune, FTA playback, minisatip Sat>IP, DVBViewer, TransEdit |

Without this patch the card is **useless for DVB-S2**.

---

## Patch 2 — Signal strength & SNR scale (included, tested)

| | |
|--|--|
| **Problem** | Stock driver returns **small raw values** (~177–500) instead of DVB API **0–65535**. minisatip divides by 256 (`>> 8`) for Sat>IP → clients showed **~1–2 %** while video played fine |
| **Fix** | `stb0899_to_strength_scale()` and `stb0899_to_snr_scale()` in `stb0899_drv.c` — map RF level and C/N to **0–65535** |
| **Tested** | ✅ DVBViewer & TransEdit show **realistic signal/SNR** after reinstall + reboot |

Functions (search in source):

```c
stb0899_to_strength_scale()  /* dBm/10 → 0..65535 */
stb0899_to_snr_scale()       /* C/N dB/10 → 0..65535 */
```

### Without minisatip (direct DVB apps)

The patch uses the **standard Linux DVB scale (0–65535)**. TVHeadend, VDR, Kaffeine, etc. should show **normal 0–100 %** — not 500 % and not 2 %.

Only **minisatip** does an extra `>> 8` internally for the Sat>IP protocol (0–255 wire format). That is **not** in the driver.

---

## Patch 3 — DVB-S2 SNR calibration (+6 dB, tested)

| | |
|--|--|
| **Problem** | After Patch 2, signal % looked realistic (~70 %) but **SNR stuck ~25 %** while TransEdit MER on the same TP showed **~11–12 dB**. STB0899 `UWP_ESN0` hardware estimate runs **~6 dB low** vs analyzer tools |
| **Fix** | `stb0899_calibrate_snr_db10()` — adds **+6.0 dB** to DVB-S2 Es/N0 before `stb0899_to_snr_scale()` |
| **Tested** | ✅ minisatip / DVBViewer SNR now tracks TransEdit MER on Astra 23.5°E / 19.2°E TPs |

```c
stb0899_calibrate_snr_db10()  /* +60 in dB/10 units, cap 20 dB */
```

Verify symbol:

```bash
strings /lib/modules/$(uname -r)/updates/skystar/stb0899.ko | grep stb0899_calibrate_snr
```

**Note:** Strength (Patch 2) unchanged. Calibration applies to **DVB-S2 Es/N0 path only** (not `est==1/2` saturation cases).

---

## Install / reinstall

```bash
sudo bash scripts/install-skystar-driver.sh
sudo reboot
./scripts/start-minisatip.sh
```

After kernel update — run the same (`install-skystar-driver.sh` rebuilds from `stb0899-module/`).

---

## Verify patches are active

```bash
modinfo stb0899 | grep updates/skystar
strings /lib/modules/$(uname -r)/updates/skystar/stb0899.ko | grep -E 'stb0899_to_strength_scale|stb0899_calibrate_snr'
```

With a locked transponder:

```bash
curl -s http://127.0.0.1:8080/state.json | python3 -m json.tool
```

**Expected:** `strength` ~60–80 % and `snr` ~45–55 % on a good DVB-S2 TP (aligned with ~11 dB MER), **not** stuck at 1–2 or ~25 % SNR alone.

Full test: [TEST-SCENARIOS.md](TEST-SCENARIOS.md) Test 5c.

---

## Do not use

- Stock unpatched `stb0899` from the kernel for DVB-S2 on this card
- minisatip `-M 0,0` to fake 100 % — proper fix is this driver patch (included in repo)
