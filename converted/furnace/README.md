# MoonSound Demo Collection — Furnace Conversions

Every MoonBlaster song from [`demo-disks/`](../../demo-disks/) converted to [Furnace](https://github.com/tildearrow/furnace) tracker modules (`.fur`) for the Yamaha YMF278B (OPL4), so the music can be played, studied and edited on a modern machine without MoonSound hardware or an MSX / ZX Spectrum emulator.

- **240 modules:** 38 from `.MFM` (MoonBlaster FM) and 202 from `.MWM` (MoonBlaster Wave), 79.0 MB in total.
- **Converter:** [`tools/moonsound-decoder`](../../tools/moonsound-decoder/), repository commit `ad2b59a`. How it works and how it was verified: [furnace-converter.md](../../tools/moonsound-decoder/doc/furnace-converter.md).
- **Opens in:** Furnace **0.6.8.3** or newer (desktop app: *File → Open*). The files use Furnace's module format version 100, which newer releases load too.

## Folder layout

The folders mirror `demo-disks/`, so every module has the same relative path as its source song with `.fur` instead of `.MFM`/`.MWM`:

```
demo-disks/moonsound_11/GALIOUS.MWM   ->  converted/furnace/moonsound_11/GALIOUS.fur
demo-disks/mfm_sample_02/CRYOGENT.MFM ->  converted/furnace/mfm_sample_02/CRYOGENT.fur
```

`moonsound_01` holds no songs (driver only), so it has no folder here.

## What is inside a module

| Part | MFM songs | MWM songs |
|------|-----------|-----------|
| Chip | OPL4 (`0xAE`), 42 channels | OPL4 (`0xAE`), 42 channels |
| FM (channels 0-17) | 2-op and 4-op voices, allocated like the original player | Unused; hidden in the editor |
| PCM (channels 18-41) | The 6 wave tracks on 18-23 | The 24 wave tracks on 18-41 |
| Instruments | 24 two-op + 12 four-op FM patches, plus one MultiPCM instrument per wave voice | One MultiPCM instrument per wave voice |
| Samples | Waveforms extracted from the YRW-801 ROM (or `.MWK` kit) actually used | Same |
| Patterns | One 16-row pattern per song position (positions unrolled) | Same |
| Timing | Speed = song tempo; 50 Hz ticks, as on the ZX Spectrum (see *Timing* below) | Same |

Samples are embedded in each module, so a module plays on its own without the ROM.

**Timing.** Every module ticks at 50 Hz, because that's how the demo disks play on the ZX Spectrum. The players run once per 50 Hz frame interrupt. Where a player waits for the OPL4 timer (59.5 Hz for songs whose Hz flag is 60), the card never routes that timer's IRQ to the Z80, so the flag is only polled on 50 Hz frames. The *Hz flag* column shows what each song stores (MSX meaning: 60 = NTSC); on the ZX it doesn't change the speed.

## Disk summary

| Disk | Format | Songs | Played by the demo | Disk image | Source folder | Modules |
|------|--------|------:|-------------------:|------------|---------------|---------|
| [mfm_sample_01](#mfm_sample_01) | MFM | 2 | 2 | `mfm_sample.trd` | [`demo-disks/mfm_sample_01/`](../../demo-disks/mfm_sample_01/) | [`mfm_sample_01/`](mfm_sample_01/) |
| [mfm_sample_02](#mfm_sample_02) | MFM | 15 | 15 | `moon8.trd` | [`demo-disks/mfm_sample_02/`](../../demo-disks/mfm_sample_02/) | [`mfm_sample_02/`](mfm_sample_02/) |
| [mfm_sample_03](#mfm_sample_03) | MFM | 13 | 13 | `moons2.trd` | [`demo-disks/mfm_sample_03/`](../../demo-disks/mfm_sample_03/) | [`mfm_sample_03/`](mfm_sample_03/) |
| [mfm_sample_04](#mfm_sample_04) | MFM | 8 | 8 | `moonA.trd` | [`demo-disks/mfm_sample_04/`](../../demo-disks/mfm_sample_04/) | [`mfm_sample_04/`](mfm_sample_04/) |
| [moonmusic_01](#moonmusic_01) | MWM | 12 | 12 | `moon8.trd` | [`demo-disks/moonmusic_01/`](../../demo-disks/moonmusic_01/) | [`moonmusic_01/`](moonmusic_01/) |
| [moonmusic_02](#moonmusic_02) | MWM | 14 | 14 | `moon8.trd` | [`demo-disks/moonmusic_02/`](../../demo-disks/moonmusic_02/) | [`moonmusic_02/`](moonmusic_02/) |
| [moonsound_02](#moonsound_02) | MWM | 6 | 6 | `am9.trd` | [`demo-disks/moonsound_02/`](../../demo-disks/moonsound_02/) | [`moonsound_02/`](moonsound_02/) |
| [moonsound_03](#moonsound_03) | MWM | 6 | 6 | `am9.trd` | [`demo-disks/moonsound_03/`](../../demo-disks/moonsound_03/) | [`moonsound_03/`](moonsound_03/) |
| [moonsound_04](#moonsound_04) | MWM | 6 | 6 | `am9.trd` | [`demo-disks/moonsound_04/`](../../demo-disks/moonsound_04/) | [`moonsound_04/`](moonsound_04/) |
| [moonsound_05](#moonsound_05) | MWM | 14 | 14 | `moon5.trd` | [`demo-disks/moonsound_05/`](../../demo-disks/moonsound_05/) | [`moonsound_05/`](moonsound_05/) |
| [moonsound_06](#moonsound_06) | MWM | 12 | 12 | `moon6.trd` | [`demo-disks/moonsound_06/`](../../demo-disks/moonsound_06/) | [`moonsound_06/`](moonsound_06/) |
| [moonsound_07](#moonsound_07) | MWM | 18 | 17 | `moon7.trd` | [`demo-disks/moonsound_07/`](../../demo-disks/moonsound_07/) | [`moonsound_07/`](moonsound_07/) |
| [moonsound_08](#moonsound_08) | MWM | 13 | 13 | `moon8.trd` | [`demo-disks/moonsound_08/`](../../demo-disks/moonsound_08/) | [`moonsound_08/`](moonsound_08/) |
| [moonsound_09](#moonsound_09) | MWM | 19 | 19 | `moon8.trd` | [`demo-disks/moonsound_09/`](../../demo-disks/moonsound_09/) | [`moonsound_09/`](moonsound_09/) |
| [moonsound_10](#moonsound_10) | MWM | 12 | 12 | `moon8.trd` | [`demo-disks/moonsound_10/`](../../demo-disks/moonsound_10/) | [`moonsound_10/`](moonsound_10/) |
| [moonsound_11](#moonsound_11) | MWM | 30 | 28 | `moon11.trd` | [`demo-disks/moonsound_11/`](../../demo-disks/moonsound_11/) | [`moonsound_11/`](moonsound_11/) |
| [moonsound_12](#moonsound_12) | MWM | 7 | 7 | `moon12.trd` | [`demo-disks/moonsound_12/`](../../demo-disks/moonsound_12/) | [`moonsound_12/`](moonsound_12/) |
| [moonsound_13](#moonsound_13) | MWM | 21 | 19 | `moon13.trd` | [`demo-disks/moonsound_13/`](../../demo-disks/moonsound_13/) | [`moonsound_13/`](moonsound_13/) |
| [moonsound_14](#moonsound_14) | MWM | 12 | 12 | `moon14.trd` | [`demo-disks/moonsound_14/`](../../demo-disks/moonsound_14/) | [`moonsound_14/`](moonsound_14/) |

## Index

Columns:

- **Melody:** the song's number in the disk's own demo program, from the disk's `melody-mapping.md` (— if the demo doesn't play it).
- **Info:** the song's own 50-character info string (title / game / author).
- **Kit:** `NONE` = YRW-801 ROM sounds only; otherwise the `.MWK` sample kit.
- **4-op:** number of 4-operator FM chains (MFM only).
- **Hz flag:** the song's stored base frequency (see *Timing* above).
- **Length:** one pass through the song at the ZX's 50 Hz tick (loops not repeated).
- **Source SHA1:** first 8 hex digits of the source file's SHA-1, to match copies.

### mfm_sample_01

Source: [`demo-disks/mfm_sample_01/`](../../demo-disks/mfm_sample_01/) · disk image [`mfm_sample.trd`](../../demo-disks/mfm_sample_01/mfm_sample.trd) · track order [melody-mapping.md](../../demo-disks/mfm_sample_01/melody-mapping.md) · 2 songs

| Furnace module | Source | Melody | Info | Kit | 4-op | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|---|
| [`BCAREFUL.fur`](mfm_sample_01/BCAREFUL.fur) | [`BCAREFUL.MFM`](../../demo-disks/mfm_sample_01/BCAREFUL.MFM) | 1 | Be Careful / Wanderers From Ys / R. v/d Moosdijk | NONE | 0 | 50 | 35 | 1:21 | `44dc06d7` |
| [`MELODIES.fur`](mfm_sample_01/MELODIES.fur) | [`MELODIES.MFM`](../../demo-disks/mfm_sample_01/MELODIES.MFM) | 2 | MB for MoonSound FM v0.91. Coding by R.Schrijvers | NONE | 0 | 50 | 67 | 1:47 | `f14ff853` |

### mfm_sample_02

Source: [`demo-disks/mfm_sample_02/`](../../demo-disks/mfm_sample_02/) · disk image [`moon8.trd`](../../demo-disks/mfm_sample_02/moon8.trd) · track order [melody-mapping.md](../../demo-disks/mfm_sample_02/melody-mapping.md) · 15 songs

| Furnace module | Source | Melody | Info | Kit | 4-op | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|---|
| [`ALONEBTL.fur`](mfm_sample_02/ALONEBTL.fur) | [`ALONEBTL.MFM`](../../demo-disks/mfm_sample_02/ALONEBTL.MFM) | 1 | Alone Batlle / Ys-II / Bart Roymans Zodiac 1995 | NONE | 4 | 60 | 112 | 3:52 | `353687a8` |
| [`CRYOGENT.fur`](mfm_sample_02/CRYOGENT.fur) | [`CRYOGENT.MFM`](../../demo-disks/mfm_sample_02/CRYOGENT.MFM) | 7 | Cryogenity LIVE! / R. v/d Moosdijk / Zodiac 1995 | NONE | 6 | 60 | 81 | 3:01 | `aba01a0c` |
| [`DERTIGAP.fur`](mfm_sample_02/DERTIGAP.fur) | [`DERTIGAP.MFM`](../../demo-disks/mfm_sample_02/DERTIGAP.MFM) | 8 | Dertig april 1995, Eerste met MoonSound A.Minnaard | NONE | 2 | 50 | 54 | 2:18 | `51364d0e` |
| [`DJINGLE1.fur`](mfm_sample_02/DJINGLE1.fur) | [`DJINGLE1.MFM`](../../demo-disks/mfm_sample_02/DJINGLE1.MFM) | 2 | End of Search / Rhumba Version / R. v/d Moosdijk | NONE | 0 | 50 | 2 | 0:03 | `8bba6504` |
| [`DJINGLE2.fur`](mfm_sample_02/DJINGLE2.fur) | [`DJINGLE2.MFM`](../../demo-disks/mfm_sample_02/DJINGLE2.MFM) | 3 | End of Search / Slow-Age version / Bart Roymans | NONE | 2 | 50 | 2 | 0:06 | `e62eeab2` |
| [`DJINGLE3.fur`](mfm_sample_02/DJINGLE3.fur) | [`DJINGLE3.MFM`](../../demo-disks/mfm_sample_02/DJINGLE3.MFM) | 4 | End of Search / Normal Version / R. v/d Moosdijk | NONE | 6 | 50 | 2 | 0:06 | `8af15746` |
| [`DJINGLE4.fur`](mfm_sample_02/DJINGLE4.fur) | [`DJINGLE4.MFM`](../../demo-disks/mfm_sample_02/DJINGLE4.MFM) | 5 | End of Serach / Happy Version / Bart Roymans | NONE | 2 | 50 | 2 | 0:03 | `2f1451f4` |
| [`DJINGLE5.fur`](mfm_sample_02/DJINGLE5.fur) | [`DJINGLE5.MFM`](../../demo-disks/mfm_sample_02/DJINGLE5.MFM) | 6 | End of Search / Brutal Version / Moosdijk&Roymans | NONE | 4 | 50 | 4 | 0:04 | `dac1fe28` |
| [`FEEDBACK.fur`](mfm_sample_02/FEEDBACK.fur) | [`FEEDBACK.MFM`](../../demo-disks/mfm_sample_02/FEEDBACK.MFM) | 14 | The Feedback Theme / Tecno-Soft / R. v/d Moosdijk | NONE | 6 | 50 | 49 | 1:18 | `7aae473e` |
| [`FOUNTAIN.fur`](mfm_sample_02/FOUNTAIN.fur) | [`FOUNTAIN.MFM`](../../demo-disks/mfm_sample_02/FOUNTAIN.MFM) | 10 | Fountain of Love / Ys-1 / R. v/d Moosdijk Zodiac | NONE | 2 | 50 | 56 | 1:38 | `1a395373` |
| [`JDK2.fur`](mfm_sample_02/JDK2.fur) | [`JDK2.MFM`](../../demo-disks/mfm_sample_02/JDK2.MFM) | 12 | JDK Song II / Ys-III / Bart Roymans Zodiac 1995 | NONE | 6 | 50 | 118 | 4:05 | `18e8f2a4` |
| [`MEMORY.fur`](mfm_sample_02/MEMORY.fur) | [`MEMORY.MFM`](../../demo-disks/mfm_sample_02/MEMORY.MFM) | 9 | In The Memory / Ys-I / R. v/d Moosdijk Zodiac 1995 | NONE | 4 | 50 | 76 | 2:27 | `f9e7a92b` |
| [`PALACEOD.fur`](mfm_sample_02/PALACEOD.fur) | [`PALACEOD.MFM`](../../demo-disks/mfm_sample_02/PALACEOD.MFM) | 15 | Palace of Destruction / Ys I / Nihon Falcom | NONE | 4 | 50 | 51 | 1:30 | `339b0fb2` |
| [`PATSTORY.fur`](mfm_sample_02/PATSTORY.fur) | [`PATSTORY.MFM`](../../demo-disks/mfm_sample_02/PATSTORY.MFM) | 11 | A Pathetic Story / Ys-II / Bart Roymans Zodiac '95 | NONE | 0 | 50 | 4 | 0:10 | `c0fb9d1d` |
| [`SALMON.fur`](mfm_sample_02/SALMON.fur) | [`SALMON.MFM`](../../demo-disks/mfm_sample_02/SALMON.MFM) | 13 | The Palace of Salmon / Ys-II / R. v/d Moosdijk | NONE | 0 | 60 | 38 | 1:25 | `38875019` |

### mfm_sample_03

Source: [`demo-disks/mfm_sample_03/`](../../demo-disks/mfm_sample_03/) · disk image [`moons2.trd`](../../demo-disks/mfm_sample_03/moons2.trd) · track order [melody-mapping.md](../../demo-disks/mfm_sample_03/melody-mapping.md) · 13 songs

| Furnace module | Source | Melody | Info | Kit | 4-op | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|---|
| [`ALESTE.fur`](mfm_sample_03/ALESTE.fur) | [`ALESTE.MFM`](../../demo-disks/mfm_sample_03/ALESTE.MFM) | 1 | Frikandel special (C) Meits 1995 | NONE | 0 | 50 | 17 | 0:27 | `3de635e8` |
| [`FOREST.fur`](mfm_sample_03/FOREST.fur) | [`FOREST.MFM`](../../demo-disks/mfm_sample_03/FOREST.MFM) | 2 | The Forest of Thelonia Bart Roymans PIXE | NONE | 0 | 60 | 52 | 1:56 | `4d131af8` |
| [`HUISHUIS.fur`](mfm_sample_03/HUISHUIS.fur) | [`HUISHUIS.MFM`](../../demo-disks/mfm_sample_03/HUISHUIS.MFM) | 3 | House Riedeltje | NONE | 0 | 50 | 28 | 0:53 | `5f07e595` |
| [`JAMMED2.fur`](mfm_sample_03/JAMMED2.fur) | [`JAMMED2.MFM`](../../demo-disks/mfm_sample_03/JAMMED2.MFM) | 5 | Jammed 2.0 Bart Roymans JVDrums2 | NONE | 0 | 60 | 80 | 3:50 | `0fcc12e1` |
| [`JDKTHEME.fur`](mfm_sample_03/JDKTHEME.fur) | [`JDKTHEME.MFM`](../../demo-disks/mfm_sample_03/JDKTHEME.MFM) | 6 | J.D.K. theme Bart Roymans JVdrums2 | NONE | 0 | 60 | 73 | 3:06 | `60b75f32` |
| [`MATIN.fur`](mfm_sample_03/MATIN.fur) | [`MATIN.MFM`](../../demo-disks/mfm_sample_03/MATIN.MFM) | 7 | Matin Bart Roymans JVdrums2 | NONE | 0 | 60 | 56 | 2:59 | `bd3aea7f` |
| [`MORNGROW.fur`](mfm_sample_03/MORNGROW.fur) | [`MORNGROW.MFM`](../../demo-disks/mfm_sample_03/MORNGROW.MFM) | 8 | The Morning Grow / Ys-I Manga / R. v/d Moosdijk | NONE | 0 | 50 | 86 | 1:44 | `94791cd5` |
| [`PARODIUS.fur`](mfm_sample_03/PARODIUS.fur) | [`PARODIUS.MFM`](../../demo-disks/mfm_sample_03/PARODIUS.MFM) | 9 | Parodius - Bart `n Dave - Parodius | NONE | 3 | 60 | 103 | 3:21 | `6920984e` |
| [`RANDAM.fur`](mfm_sample_03/RANDAM.fur) | [`RANDAM.MFM`](../../demo-disks/mfm_sample_03/RANDAM.MFM) | 12 | Gilian meets Randam BartRoymans Mtdrums1 | NONE | 0 | 60 | 64 | 1:42 | `c3cbda62` |
| [`RELAXED.fur`](mfm_sample_03/RELAXED.fur) | [`RELAXED.MFM`](../../demo-disks/mfm_sample_03/RELAXED.MFM) | 4 | rellaxxedd Bart Roymans RD1 | NONE | 0 | 60 | 16 | 0:40 | `86a644ae` |
| [`RIEDEL.fur`](mfm_sample_03/RIEDEL.fur) | [`RIEDEL.MFM`](../../demo-disks/mfm_sample_03/RIEDEL.MFM) | 10 | MB for MoonSound FM v0.91. Coding by R.Schrijvers | NONE | 0 | 60 | 9 | 0:15 | `e7777018` |
| [`SALMON_1.fur`](mfm_sample_03/SALMON_1.fur) | [`SALMON_1.MFM`](../../demo-disks/mfm_sample_03/SALMON_1.MFM) | 13 | Castle of Salmon Bart Roymans Ys II Final Ch. | NONE | 0 | 60 | 84 | 3:08 | `54dbf479` |
| [`SLOWDOWN.fur`](mfm_sample_03/SLOWDOWN.fur) | [`SLOWDOWN.MFM`](../../demo-disks/mfm_sample_03/SLOWDOWN.MFM) | 11 | Slow Down Town Bart Roymans (c) Compjoetania | NONE | 4 | 60 | 38 | 1:12 | `4ae6c256` |

### mfm_sample_04

Source: [`demo-disks/mfm_sample_04/`](../../demo-disks/mfm_sample_04/) · disk image [`moonA.trd`](../../demo-disks/mfm_sample_04/moonA.trd) · track order [melody-mapping.md](../../demo-disks/mfm_sample_04/melody-mapping.md) · 8 songs

| Furnace module | Source | Melody | Info | Kit | 4-op | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|---|
| [`HAPERT.fur`](mfm_sample_04/HAPERT.fur) | [`HAPERT.MFM`](../../demo-disks/mfm_sample_04/HAPERT.MFM) | 1 | Hapert , city of crime - Bart Roymans | NONE | 0 | 60 | 82 | 3:03 | `8633dd6f` |
| [`LTCII.fur`](mfm_sample_04/LTCII.fur) | [`LTCII.MFM`](../../demo-disks/mfm_sample_04/LTCII.MFM) | 2 | Lotus Turbo Challenge II / R. v/d Moosdijk 1992/95 | NONE | 0 | 50 | 82 | 2:37 | `ee0bf3f6` |
| [`THEME3.fur`](mfm_sample_04/THEME3.fur) | [`THEME3.MFM`](../../demo-disks/mfm_sample_04/THEME3.MFM) | 4 | Theme3 - Bart Roymans - Rockdrm1 | NONE | 0 | 60 | 145 | 6:11 | `24b6c28f` |
| [`THEPAST.fur`](mfm_sample_04/THEPAST.fur) | [`THEPAST.MFM`](../../demo-disks/mfm_sample_04/THEPAST.MFM) | 3 | Past but not forgotten Bart Roymans | NONE | 4 | 60 | 35 | 1:40 | `7751436f` |
| [`XAK_1.fur`](mfm_sample_04/XAK_1.fur) | [`XAK_1.MFM`](../../demo-disks/mfm_sample_04/XAK_1.MFM) | 6 | XAK1 Village (OPL4 Version) (C) Meits 1995 | NONE | 3 | 50 | 22 | 0:42 | `842b81b2` |
| [`XAK_2.fur`](mfm_sample_04/XAK_2.fur) | [`XAK_2.MFM`](../../demo-disks/mfm_sample_04/XAK_2.MFM) | 7 | Heavy Latok in the forest (OPL4 version) Meits | NONE | 6 | 50 | 61 | 1:36 | `2aa5dbcc` |
| [`XMAS.fur`](mfm_sample_04/XMAS.fur) | [`XMAS.MFM`](../../demo-disks/mfm_sample_04/XMAS.MFM) | 5 | X-Mas mix by Chaos^ TeddyWareZ Dec'98 | NONE | 2 | 60 | 125 | 3:00 | `25dc4fc6` |
| [`YSMASK.fur`](mfm_sample_04/YSMASK.fur) | [`YSMASK.MFM`](../../demo-disks/mfm_sample_04/YSMASK.MFM) | 8 | Ys 4,Mask of the Sun Bart Roymans JVDrum | NONE | 0 | 60 | 32 | 1:01 | `3dc6e7b7` |

### moonmusic_01

Source: [`demo-disks/moonmusic_01/`](../../demo-disks/moonmusic_01/) · disk image [`moon8.trd`](../../demo-disks/moonmusic_01/moon8.trd) · track order [melody-mapping.md](../../demo-disks/moonmusic_01/melody-mapping.md) · 12 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`BELAIR.fur`](moonmusic_01/BELAIR.fur) | [`BELAIR.MWM`](../../demo-disks/moonmusic_01/BELAIR.MWM) | 5 | Bel Air House (Antwerpen) Bart Roymans | POWERKIT | 60 | 74 | 2:26 | `e1e9c2ed` |
| [`CHILDREN.fur`](moonmusic_01/CHILDREN.fur) | [`CHILDREN.MWM`](../../demo-disks/moonmusic_01/CHILDREN.MWM) | 1 | Children - Robert Miles - Bart Roymans | POWERKIT | 60 | 91 | 3:12 | `ea81f750` |
| [`CRYSISTE.fur`](moonmusic_01/CRYSISTE.fur) | [`CRYSISTE.MWM`](../../demo-disks/moonmusic_01/CRYSISTE.MWM) | 6 | Cry little sister Bart Roymans | POWERKIT | 60 | 65 | 2:04 | `97f0723a` |
| [`INTRO2.fur`](moonmusic_01/INTRO2.fur) | [`INTRO2.MWM`](../../demo-disks/moonmusic_01/INTRO2.MWM) | 10 | The Intro JV880 / JD990 - Bart Roymans | NONE | 60 | 32 | 1:11 | `ea1fcc0b` |
| [`PALACE2.fur`](moonmusic_01/PALACE2.fur) | [`PALACE2.MWM`](../../demo-disks/moonmusic_01/PALACE2.MWM) | 8 | The Palace Bart Roymans OPL4 | POWERKIT | 60 | 52 | 2:29 | `4917a019` |
| [`PARADISE.fur`](moonmusic_01/PARADISE.fur) | [`PARADISE.MWM`](../../demo-disks/moonmusic_01/PARADISE.MWM) | 7 | Search for a cloud Bart Roymans powerkit1 | NONE | 60 | 40 | 2:08 | `dbf0e1dc` |
| [`ROCKDAWN.fur`](moonmusic_01/ROCKDAWN.fur) | [`ROCKDAWN.MWM`](../../demo-disks/moonmusic_01/ROCKDAWN.MWM) | 2 | Rock Rock Dawn | POWERKIT | 60 | 36 | 1:32 | `0624c0e5` |
| [`SOLVOID.fur`](moonmusic_01/SOLVOID.fur) | [`SOLVOID.MWM`](../../demo-disks/moonmusic_01/SOLVOID.MWM) | 11 | Solitary Void Bart Roymans JVdrums2 | NONE | 60 | 110 | 4:06 | `7775afff` |
| [`STILLBEL.fur`](moonmusic_01/STILLBEL.fur) | [`STILLBEL.MWM`](../../demo-disks/moonmusic_01/STILLBEL.MWM) | 3 | I still Believe Bart Roymans | POWERKIT | 60 | 82 | 3:29 | `baefb027` |
| [`YS2BATTL.fur`](moonmusic_01/YS2BATTL.fur) | [`YS2BATTL.MWM`](../../demo-disks/moonmusic_01/YS2BATTL.MWM) | 9 | Ys2 Battle theme 3 Arr: Bart Roymans | POWERKIT | 60 | 68 | 1:54 | `8b0ca361` |
| [`YS2ROAD.fur`](moonmusic_01/YS2ROAD.fur) | [`YS2ROAD.MWM`](../../demo-disks/moonmusic_01/YS2ROAD.MWM) | 12 | Ys 2 road .. Bart Roymans | NONE | 60 | 46 | 1:35 | `e160753d` |
| [`YS4LAVA.fur`](moonmusic_01/YS4LAVA.fur) ⚠ | [`YS4LAVA.MWM`](../../demo-disks/moonmusic_01/YS4LAVA.MWM) | 4 | The Lava Area, kiss to Eldil.. Bart Roymans | POWERKIT | 60 | 70 | 2:13 | `bcdc60b7` |

### moonmusic_02

Source: [`demo-disks/moonmusic_02/`](../../demo-disks/moonmusic_02/) · disk image [`moon8.trd`](../../demo-disks/moonmusic_02/moon8.trd) · track order [melody-mapping.md](../../demo-disks/moonmusic_02/melody-mapping.md) · 14 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`ALLPART2.fur`](moonmusic_02/ALLPART2.fur) ⚠ | [`ALLPART2.MWM`](../../demo-disks/moonmusic_02/ALLPART2.MWM) | 2 | All there ... 2,Bart Roymans,JVDrums1 | NONE | 60 | 146 | 7:00 | `ed087020` |
| [`CANTKING.fur`](moonmusic_02/CANTKING.fur) | [`CANTKING.MWM`](../../demo-disks/moonmusic_02/CANTKING.MWM) | 3 | I can't just wait to be king Bart Roymans | NONE | 60 | 48 | 1:01 | `ddf55b40` |
| [`CHAOS2.fur`](moonmusic_02/CHAOS2.fur) | [`CHAOS2.MWM`](../../demo-disks/moonmusic_02/CHAOS2.MWM) (= moonsound_06/CHAOS2.MWM) | 10 | "Captain Chaos ][" - OPL4 Version - SoundWave 1997 | NONE | 60 | 44 | 1:10 | `72f0ff03` |
| [`DSLAYER6.fur`](moonmusic_02/DSLAYER6.fur) | [`DSLAYER6.MWM`](../../demo-disks/moonmusic_02/DSLAYER6.MWM) | 1 | Dragon Slayer, The Legend of Heroes Manuel Pazos | NONE | 60 | 64 | 2:43 | `9fbcb3c1` |
| [`FOREVER.fur`](moonmusic_02/FOREVER.fur) | [`FOREVER.MWM`](../../demo-disks/moonmusic_02/FOREVER.MWM) | 11 | Forever Friends - Huey & Zelly - Mayhem '95 | NONE | 60 | 76 | 2:50 | `434d24a0` |
| [`FURELISE.fur`](moonmusic_02/FURELISE.fur) | [`FURELISE.MWM`](../../demo-disks/moonmusic_02/FURELISE.MWM) | 4 | Fur Elise Hans Schoormans | NONE | 60 | 127 | 3:34 | `b04f3eb1` |
| [`INTERNAL.fur`](moonmusic_02/INTERNAL.fur) | [`INTERNAL.MWM`](../../demo-disks/moonmusic_02/INTERNAL.MWM) | 13 | Mayhem Internals - Huey & Zelly - Mayhem '95 | NONE | 60 | 88 | 3:17 | `27f0ec53` |
| [`MIRROMAN.fur`](moonmusic_02/MIRROMAN.fur) | [`MIRROMAN.MWM`](../../demo-disks/moonmusic_02/MIRROMAN.MWM) | 5 | BGM3 Bart Roymans Compjoetania | NONE | 60 | 22 | 0:56 | `171e6d23` |
| [`PALACE.fur`](moonmusic_02/PALACE.fur) | [`PALACE.MWM`](../../demo-disks/moonmusic_02/PALACE.MWM) | 7 | The Palace Bart Roymans OPL4 | NONE | 60 | 52 | 2:29 | `5178b8dc` |
| [`PIANOMAN.fur`](moonmusic_02/PIANOMAN.fur) | [`PIANOMAN.MWM`](../../demo-disks/moonmusic_02/PIANOMAN.MWM) | 8 | Piano Man Hans Schoormans | NONE | 60 | 143 | 5:10 | `2f47e027` |
| [`PROFILE.fur`](moonmusic_02/PROFILE.fur) | [`PROFILE.MWM`](../../demo-disks/moonmusic_02/PROFILE.MWM) | 14 | The Profile - Huey & Zelly - Mayhem '95 | NONE | 60 | 143 | 5:22 | `b7989713` |
| [`QUICKSAA.fur`](moonmusic_02/QUICKSAA.fur) | [`QUICKSAA.MWM`](../../demo-disks/moonmusic_02/QUICKSAA.MWM) | 12 | The Quicksand Valley Ys 4 Bart Roymans | NONE | 60 | 41 | 1:18 | `840a8422` |
| [`SDCHURCH.fur`](moonmusic_02/SDCHURCH.fur) | [`SDCHURCH.MWM`](../../demo-disks/moonmusic_02/SDCHURCH.MWM) | 9 | SD snatcher church BGM Bart Roymans | NONE | 60 | 18 | 0:51 | `3fe15e39` |
| [`THRDWAVE.fur`](moonmusic_02/THRDWAVE.fur) | [`THRDWAVE.MWM`](../../demo-disks/moonmusic_02/THRDWAVE.MWM) | 6 | Leisure Suit Larry Main Theme (my gawd) | NONE | 60 | 29 | 1:04 | `63226290` |

### moonsound_02

Source: [`demo-disks/moonsound_02/`](../../demo-disks/moonsound_02/) · disk image [`am9.trd`](../../demo-disks/moonsound_02/am9.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_02/melody-mapping.md) · 6 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`BONGIE.fur`](moonsound_02/BONGIE.fur) | [`BONGIE.MWM`](../../demo-disks/moonsound_02/BONGIE.MWM) | 1 | Bongie, Bongie By, Qix (Surrec) | NONE | 50 | 73 | 1:56 | `17e2a128` |
| [`JOINTEE.fur`](moonsound_02/JOINTEE.fur) | [`JOINTEE.MWM`](../../demo-disks/moonsound_02/JOINTEE.MWM) | 2 | Jointee By Qix (Surrec) | NONE | 50 | 28 | 0:35 | `1b3413e1` |
| [`PUMPING.fur`](moonsound_02/PUMPING.fur) | [`PUMPING.MWM`](../../demo-disks/moonsound_02/PUMPING.MWM) | 3 | Pumping and Humping | NONE | 50 | 80 | 1:50 | `42a8582b` |
| [`REMEMBER.fur`](moonsound_02/REMEMBER.fur) ⚠ | [`REMEMBER.MWM`](../../demo-disks/moonsound_02/REMEMBER.MWM) | 4 | Remember By Qix (Surrec) | HARDBASS | 50 | 72 | 1:55 | `fd48081d` |
| [`SACRIFIC.fur`](moonsound_02/SACRIFIC.fur) | [`SACRIFIC.MWM`](../../demo-disks/moonsound_02/SACRIFIC.MWM) | 5 | Sacrifice By Qix (Surrec) | NONE | 50 | 116 | 4:56 | `2d1e5014` |
| [`WILLWIND.fur`](moonsound_02/WILLWIND.fur) | [`WILLWIND.MWM`](../../demo-disks/moonsound_02/WILLWIND.MWM) | 6 | "The Will Of The Wind" - OPL4 - SoundWave 1997 | NONE | 50 | 106 | 2:49 | `be3440fd` |

### moonsound_03

Source: [`demo-disks/moonsound_03/`](../../demo-disks/moonsound_03/) · disk image [`am9.trd`](../../demo-disks/moonsound_03/am9.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_03/melody-mapping.md) · 6 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`ADVENTUR.fur`](moonsound_03/ADVENTUR.fur) | [`ADVENTUR.MWM`](../../demo-disks/moonsound_03/ADVENTUR.MWM) | 1 | Adventure By, Qix | NONE | 50 | 124 | 3:58 | `ca294a59` |
| [`CHURCHDE.fur`](moonsound_03/CHURCHDE.fur) | [`CHURCHDE.MWM`](../../demo-disks/moonsound_03/CHURCHDE.MWM) | 2 | Demon's Church By, Qix | NONE | 50 | 129 | 2:45 | `e8046c91` |
| [`FOTI.fur`](moonsound_03/FOTI.fur) ⚠ | [`FOTI.MWM`](../../demo-disks/moonsound_03/FOTI.MWM) | 3 | "Foxes On The Ice" - WJKKIO - OPL4 - SoundWave '97 | NONE | 50 | 52 | 1:39 | `dd1aa1ca` |
| [`JAZZY.fur`](moonsound_03/JAZZY.fur) | [`JAZZY.MWM`](../../demo-disks/moonsound_03/JAZZY.MWM) | 4 | DiscStation Title - Jazzy Version - SoundWave 1998 | NONE | 50 | 40 | 0:38 | `93f44bf1` |
| [`MADNESS2.fur`](moonsound_03/MADNESS2.fur) | [`MADNESS2.MWM`](../../demo-disks/moonsound_03/MADNESS2.MWM) | 5 | House of fun / Madness / Eric | NONE | 50 | 30 | 0:57 | `4c59e03a` |
| [`TRAGEDY.fur`](moonsound_03/TRAGEDY.fur) | [`TRAGEDY.MWM`](../../demo-disks/moonsound_03/TRAGEDY.MWM) | 6 | "Tragedies..." - OPL4 - SoundWave 1997 | NONE | 50 | 41 | 1:31 | `603d445e` |

### moonsound_04

Source: [`demo-disks/moonsound_04/`](../../demo-disks/moonsound_04/) · disk image [`am9.trd`](../../demo-disks/moonsound_04/am9.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_04/melody-mapping.md) · 6 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`DREAMER.fur`](moonsound_04/DREAMER.fur) | [`DREAMER.MWM`](../../demo-disks/moonsound_04/DREAMER.MWM) | 1 | The Sweet Dreamer Meits 2004 | NONE | 50 | 63 | 1:40 | `5e866f6b` |
| [`DREAMTHI.fur`](moonsound_04/DREAMTHI.fur) | [`DREAMTHI.MWM`](../../demo-disks/moonsound_04/DREAMTHI.MWM) | 2 | The Dreamthief Meits 1994 / 2004 | NONE | 50 | 93 | 2:21 | `55ed303b` |
| [`KNOWNEED.fur`](moonsound_04/KNOWNEED.fur) | [`KNOWNEED.MWM`](../../demo-disks/moonsound_04/KNOWNEED.MWM) | 3 | "I know what you need" - Master of Audio 1994-2004 | NONE | 50 | 58 | 1:19 | `a9dc8dd9` |
| [`MILKMAN.fur`](moonsound_04/MILKMAN.fur) | [`MILKMAN.MWM`](../../demo-disks/moonsound_04/MILKMAN.MWM) | 4 | "The Milkman" - Master of Audio 1994-2004 | NONE | 50 | 48 | 1:16 | `a09100d5` |
| [`MIRROR.fur`](moonsound_04/MIRROR.fur) | [`MIRROR.MWM`](../../demo-disks/moonsound_04/MIRROR.MWM) | 5 | The (NEW) Toy Mirror (not even broken) Meits 96 | NONE | 50 | 76 | 2:01 | `6374ef9c` |
| [`SPRING.fur`](moonsound_04/SPRING.fur) ⚠ | [`SPRING.MWM`](../../demo-disks/moonsound_04/SPRING.MWM) | 6 | "Strawberry Spring" - Master of Audio 1994 - 2004 | SPRING | 50 | 59 | 2:21 | `edb1d398` |

### moonsound_05

Source: [`demo-disks/moonsound_05/`](../../demo-disks/moonsound_05/) · disk image [`moon5.trd`](../../demo-disks/moonsound_05/moon5.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_05/melody-mapping.md) · 14 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`ANGELDEA.fur`](moonsound_05/ANGELDEA.fur) | [`ANGELDEA.MWM`](../../demo-disks/moonsound_05/ANGELDEA.MWM) | 2 | Angel of death By, Qix | NONE | 50 | 84 | 2:41 | `1a0f9670` |
| [`ATTACK.fur`](moonsound_05/ATTACK.fur) | [`ATTACK.MWM`](../../demo-disks/moonsound_05/ATTACK.MWM) | 3 | Demon's Attack By, Qix | NONE | 50 | 56 | 1:47 | `3dba489d` |
| [`BEATING.fur`](moonsound_05/BEATING.fur) | [`BEATING.MWM`](../../demo-disks/moonsound_05/BEATING.MWM) | 4 | Beating Demon By, Qix | NONE | 50 | 44 | 1:52 | `786eb29f` |
| [`EXPLOSIO.fur`](moonsound_05/EXPLOSIO.fur) | [`EXPLOSIO.MWM`](../../demo-disks/moonsound_05/EXPLOSIO.MWM) | 1 | Explosion By, Qix | NONE | 50 | 40 | 1:16 | `98b26a60` |
| [`JUBILAT.fur`](moonsound_05/JUBILAT.fur) | [`JUBILAT.MWM`](../../demo-disks/moonsound_05/JUBILAT.MWM) | 7 | Jubilation By, Qix | NONE | 50 | 56 | 1:47 | `17b16d74` |
| [`KILLERS.fur`](moonsound_05/KILLERS.fur) | [`KILLERS.MWM`](../../demo-disks/moonsound_05/KILLERS.MWM) | 8 | Killers By, Qix | NONE | 50 | 41 | 2:08 | `65d82616` |
| [`LOGO.fur`](moonsound_05/LOGO.fur) | [`LOGO.MWM`](../../demo-disks/moonsound_05/LOGO.MWM) | 5 | Logo By, Qix | NONE | 50 | 3 | 0:03 | `715f8135` |
| [`PAIN.fur`](moonsound_05/PAIN.fur) | [`PAIN.MWM`](../../demo-disks/moonsound_05/PAIN.MWM) | 10 | Pain By, Qix | NONE | 50 | 144 | 4:36 | `4fac01cc` |
| [`SILENTS.fur`](moonsound_05/SILENTS.fur) | [`SILENTS.MWM`](../../demo-disks/moonsound_05/SILENTS.MWM) | 6 | Silents and Peace By, Qix | NONE | 50 | 24 | 0:46 | `e44fa6ce` |
| [`SUDDENS.fur`](moonsound_05/SUDDENS.fur) | [`SUDDENS.MWM`](../../demo-disks/moonsound_05/SUDDENS.MWM) | 11 | Sudden Symphonie By, Qix | NONE | 50 | 36 | 1:32 | `e8b65eaa` |
| [`SWITCH.fur`](moonsound_05/SWITCH.fur) | [`SWITCH.MWM`](../../demo-disks/moonsound_05/SWITCH.MWM) | 9 | Switch 50/60 Hz By, Qix | NONE | 50 | 24 | 0:30 | `6c1851c8` |
| [`TARGET.fur`](moonsound_05/TARGET.fur) | [`TARGET.MWM`](../../demo-disks/moonsound_05/TARGET.MWM) | 12 | Target By, Qix | NONE | 50 | 65 | 1:22 | `de61ee5c` |
| [`WATERS.fur`](moonsound_05/WATERS.fur) | [`WATERS.MWM`](../../demo-disks/moonsound_05/WATERS.MWM) | 13 | Waters in Paridise By, Qix | NONE | 50 | 91 | 2:52 | `17a23ff3` |
| [`XENORIUM.fur`](moonsound_05/XENORIUM.fur) | [`XENORIUM.MWM`](../../demo-disks/moonsound_05/XENORIUM.MWM) | 14 | Xenorium 1 By, Qix | NONE | 50 | 140 | 4:28 | `f58898ca` |

### moonsound_06

Source: [`demo-disks/moonsound_06/`](../../demo-disks/moonsound_06/) · disk image [`moon6.trd`](../../demo-disks/moonsound_06/moon6.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_06/melody-mapping.md) · 12 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`ANGEL.fur`](moonsound_06/ANGEL.fur) | [`ANGEL.MWM`](../../demo-disks/moonsound_06/ANGEL.MWM) | 1 | "Angel Of The City" - PM2 - OPL4 - SoundWave 1997 | NONE | 50 | 40 | 1:04 | `80c90b63` |
| [`BDD321.fur`](moonsound_06/BDD321.fur) | [`BDD321.MWM`](../../demo-disks/moonsound_06/BDD321.MWM) | 2 | BDD 321 - guess who '93 - Omega '95 (c) Dreamscape | NONE | 50 | 81 | 2:35 | `46a4898a` |
| [`CHAOS2.fur`](moonsound_06/CHAOS2.fur) | [`CHAOS2.MWM`](../../demo-disks/moonsound_06/CHAOS2.MWM) (= moonmusic_02/CHAOS2.MWM) | 3 | "Captain Chaos ][" - OPL4 Version - SoundWave 1997 | NONE | 60 | 44 | 1:10 | `72f0ff03` |
| [`COPY2.fur`](moonsound_06/COPY2.fur) | [`COPY2.MWM`](../../demo-disks/moonsound_06/COPY2.MWM) | 4 | Copy is CRIME (part 2) - BDD '92/Omega'95 (c) DS | NONE | 50 | 95 | 3:06 | `07a5c8ce` |
| [`DORMIR.fur`](moonsound_06/DORMIR.fur) | [`DORMIR.MWM`](../../demo-disks/moonsound_06/DORMIR.MWM) | 5 | Dormir con angelitos - Hans Cnossen 1996 | NONE | 50 | 48 | 1:32 | `ddeb963a` |
| [`ENDING.fur`](moonsound_06/ENDING.fur) | [`ENDING.MWM`](../../demo-disks/moonsound_06/ENDING.MWM) | 8 | Impaccable end scroll - BDD '92/OmegA '95 (c) DS | NONE | 50 | 84 | 3:08 | `0968a931` |
| [`ENDING32.fur`](moonsound_06/ENDING32.fur) | [`ENDING32.MWM`](../../demo-disks/moonsound_06/ENDING32.MWM) | 6 | Ending 3.2 - BDD '92 - Omega '95 (c) DreamScape | NONE | 50 | 81 | 2:35 | `a565e62e` |
| [`FALLSTAR.fur`](moonsound_06/FALLSTAR.fur) | [`FALLSTAR.MWM`](../../demo-disks/moonsound_06/FALLSTAR.MWM) | 9 | An ordered falling star Near Dark 1996 | NONE | 50 | 85 | 2:41 | `0e02d120` |
| [`FLYING09.fur`](moonsound_06/FLYING09.fur) | [`FLYING09.MWM`](../../demo-disks/moonsound_06/FLYING09.MWM) | 11 | Prepare for take off - Hans Cnossen | NONE | 50 | 32 | 0:51 | `a6ee65c7` |
| [`IMPAC137.fur`](moonsound_06/IMPAC137.fur) | [`IMPAC137.MWM`](../../demo-disks/moonsound_06/IMPAC137.MWM) | 7 | impact 137 - '92 BDD - '95 omega (c) dreamscape | NONE | 50 | 67 | 2:30 | `796fc972` |
| [`MACARENA.fur`](moonsound_06/MACARENA.fur) | [`MACARENA.MWM`](../../demo-disks/moonsound_06/MACARENA.MWM) | 10 | La Macarena - The Ga-version/Hans Cnossen 1995 | NONE | 50 | 150 | 5:07 | `fb547302` |
| [`RANDAR.fur`](moonsound_06/RANDAR.fur) | [`RANDAR.MWM`](../../demo-disks/moonsound_06/RANDAR.MWM) | 12 | "Randar 3" - OPL4 Version - SoundWave 1998 | NONE | 50 | 32 | 0:30 | `913d87de` |

### moonsound_07

Source: [`demo-disks/moonsound_07/`](../../demo-disks/moonsound_07/) · disk image [`moon7.trd`](../../demo-disks/moonsound_07/moon7.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_07/melody-mapping.md) · 18 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`ALEID.fur`](moonsound_07/ALEID.fur) | [`ALEID.MWM`](../../demo-disks/moonsound_07/ALEID.MWM) | 2 | Aleid Kingdom - Arranged by J. Hassink, 31-03-1997 | NONE | 50 | 21 | 0:29 | `62fcd7ff` |
| [`ALESTE.fur`](moonsound_07/ALESTE.fur) | [`ALESTE.MWM`](../../demo-disks/moonsound_07/ALESTE.MWM) | 3 | "Aleste Etude" - OPL4 Version - SoundWave 1998 | NONE | 50 | 32 | 1:11 | `fb8781b5` |
| [`DISCST-1.fur`](moonsound_07/DISCST-1.fur) | [`DISCST-1.MWM`](../../demo-disks/moonsound_07/DISCST-1.MWM) | 7 | DiscStation Menu - Antique Version - SoundWave '96 | NONE | 50 | 32 | 0:46 | `8d272dd8` |
| [`END13DO.fur`](moonsound_07/END13DO.fur) | [`END13DO.MWM`](../../demo-disks/moonsound_07/END13DO.MWM) | 6 | The End "13 In Een Dozijn" By, Qix | NONE | 50 | 7 | 0:19 | `ee3f4b15` |
| [`EXTOR1.fur`](moonsound_07/EXTOR1.fur) | [`EXTOR1.MWM`](../../demo-disks/moonsound_07/EXTOR1.MWM) | 5 | Extor 1 By, Qix | NONE | 50 | 28 | 1:29 | `7331629c` |
| [`FD_MG_1.fur`](moonsound_07/FD_MG_1.fur) | [`FD_MG_1.MWM`](../../demo-disks/moonsound_07/FD_MG_1.MWM) | 8 | Nightfall - MG2 - SoundWave 1998 | NONE | 50 | 48 | 1:09 | `15379fb2` |
| [`FD_MG_2.fur`](moonsound_07/FD_MG_2.fur) | [`FD_MG_2.MWM`](../../demo-disks/moonsound_07/FD_MG_2.MWM) | 10 | End Titles - MG2 - SoundWave 1995/1998 | NONE | 50 | 62 | 1:39 | `8ab5e16a` |
| [`FD_MG_3.fur`](moonsound_07/FD_MG_3.fur) | [`FD_MG_3.MWM`](../../demo-disks/moonsound_07/FD_MG_3.MWM) | 11 | Red Alert - MG - SoundWave 1995/1998 | NONE | 50 | 29 | 0:46 | `605a7058` |
| [`FD_MG_4.fur`](moonsound_07/FD_MG_4.fur) | [`FD_MG_4.MWM`](../../demo-disks/moonsound_07/FD_MG_4.MWM) | 15 | Rendez-Vous - MG2 - SoundWave 1995/1998 | NONE | 50 | 40 | 1:29 | `63bd6fd9` |
| [`FD_MG_5.fur`](moonsound_07/FD_MG_5.fur) | [`FD_MG_5.MWM`](../../demo-disks/moonsound_07/FD_MG_5.MWM) (= moonsound_11/FD_MG_5.MWM) | 16 | Boss Battle - MG - SoundWave 1998 | NONE | 50 | 30 | 0:38 | `640892f4` |
| [`FD_MG_6.fur`](moonsound_07/FD_MG_6.fur) | [`FD_MG_6.MWM`](../../demo-disks/moonsound_07/FD_MG_6.MWM) | 17 | Invasion - MG - SoundWave 1998 | NONE | 50 | 55 | 1:45 | `e7d9dce8` |
| [`FF7.fur`](moonsound_07/FF7.fur) | [`FF7.MWM`](../../demo-disks/moonsound_07/FF7.MWM) | 12 | On Koen's Request: Kalm - OPL4 - SoundWave 1998 | NONE | 50 | 53 | 1:58 | `431dd627` |
| [`FF7_OMOI.fur`](moonsound_07/FF7_OMOI.fur) | [`FF7_OMOI.MWM`](../../demo-disks/moonsound_07/FF7_OMOI.MWM) | 13 | Final Fantasy 7 - Omoi - OPL4 - SoundWave 1998 | NONE | 50 | 64 | 1:49 | `87b92335` |
| [`FF7_SEL.fur`](moonsound_07/FF7_SEL.fur) | [`FF7_SEL.MWM`](../../demo-disks/moonsound_07/FF7_SEL.MWM) | 9 | Final Fantasy 7 - Opening - OPl4 - SoundWave 1998 | NONE | 50 | 32 | 1:32 | `b1f42095` |
| [`KONAMI_1.fur`](moonsound_07/KONAMI_1.fur) | [`KONAMI_1.MWM`](../../demo-disks/moonsound_07/KONAMI_1.MWM) | — | Hinotori's Quest - SoundWave 1998 | NONE | 50 | 58 | 1:13 | `ca82aedb` |
| [`KONAMI_4.fur`](moonsound_07/KONAMI_4.fur) | [`KONAMI_4.MWM`](../../demo-disks/moonsound_07/KONAMI_4.MWM) | 18 | Sneaky Snatchin' - SoundWave 1998 | NONE | 50 | 28 | 0:53 | `4bfa3d20` |
| [`ONEPIAN.fur`](moonsound_07/ONEPIAN.fur) | [`ONEPIAN.MWM`](../../demo-disks/moonsound_07/ONEPIAN.MWM) | 14 | One piano melody By, Qix | NONE | 50 | 72 | 1:55 | `61fe1c25` |
| [`REGGAE.fur`](moonsound_07/REGGAE.fur) | [`REGGAE.MWM`](../../demo-disks/moonsound_07/REGGAE.MWM) | 4 | "Reggae Cooks" - OPL4 Version - SoundWave 1998 | NONE | 50 | 32 | 1:01 | `926dedc2` |

### moonsound_08

Source: [`demo-disks/moonsound_08/`](../../demo-disks/moonsound_08/) · disk image [`moon8.trd`](../../demo-disks/moonsound_08/moon8.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_08/melody-mapping.md) · 13 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`AXELF.fur`](moonsound_08/AXELF.fur) | [`AXELF.MWM`](../../demo-disks/moonsound_08/AXELF.MWM) | 1 | AXELF: Total REMIX version 2.0 Frans J.W.Koller | NONE | 50 | 56 | 1:47 | `debc5df1` |
| [`CYNTHIA.fur`](moonsound_08/CYNTHIA.fur) | [`CYNTHIA.MWM`](../../demo-disks/moonsound_08/CYNTHIA.MWM) | 2 | CYNTHIA: Ode to Cynthia Expries, Frans J.W. Koller | NONE | 50 | 68 | 1:45 | `216d1354` |
| [`DISCUSS.fur`](moonsound_08/DISCUSS.fur) | [`DISCUSS.MWM`](../../demo-disks/moonsound_08/DISCUSS.MWM) | 7 | Diss-Cuss | NONE | 50 | 73 | 2:20 | `9f71f26f` |
| [`ENDLESSN.fur`](moonsound_08/ENDLESSN.fur) | [`ENDLESSN.MWM`](../../demo-disks/moonsound_08/ENDLESSN.MWM) | 11 | Endless Night - DG - Compjoetania | NONE | 50 | 65 | 2:49 | `2fca2e2d` |
| [`MACGYVER.fur`](moonsound_08/MACGYVER.fur) | [`MACGYVER.MWM`](../../demo-disks/moonsound_08/MACGYVER.MWM) | 9 | MACGYVER Hans Schoormans | NONE | 50 | 27 | 0:51 | `cb811839` |
| [`MISTYHEA.fur`](moonsound_08/MISTYHEA.fur) | [`MISTYHEA.MWM`](../../demo-disks/moonsound_08/MISTYHEA.MWM) | 5 | Misty Heart... Dave Groenen....................... | NONE | 50 | 8 | 0:35 | `62b2666e` |
| [`NEOKOBE.fur`](moonsound_08/NEOKOBE.fur) | [`NEOKOBE.MWM`](../../demo-disks/moonsound_08/NEOKOBE.MWM) | 8 | One Night in Neo-Kobe-City / Masahiro Ikariko | NONE | 50 | 92 | 2:56 | `4b16873b` |
| [`POPCORN.fur`](moonsound_08/POPCORN.fur) | [`POPCORN.MWM`](../../demo-disks/moonsound_08/POPCORN.MWM) | 6 | POPCORN: Frans J.W. Koller | NONE | 50 | 76 | 2:01 | `08ed4cfc` |
| [`SILENT.fur`](moonsound_08/SILENT.fur) | [`SILENT.MWM`](../../demo-disks/moonsound_08/SILENT.MWM) | 10 | Silent Waiting... F!R3B0Y | NONE | timer 213 | 92 | 4:25 | `c6280977` |
| [`SNOUT4.fur`](moonsound_08/SNOUT4.fur) | [`SNOUT4.MWM`](../../demo-disks/moonsound_08/SNOUT4.MWM) | 4 | Snoutriedel 4 / R.v/d Moosdijk & A.de Raad / 1996 | NONE | 50 | 45 | 1:26 | `8ba3366a` |
| [`SNOUT5.fur`](moonsound_08/SNOUT5.fur) | [`SNOUT5.MWM`](../../demo-disks/moonsound_08/SNOUT5.MWM) | 3 | Snoutriedel 5 / R.vd. Moosdijk & A.de Raad / 1996 | NONE | 50 | 20 | 0:32 | `1c62d519` |
| [`THEMA1.fur`](moonsound_08/THEMA1.fur) | [`THEMA1.MWM`](../../demo-disks/moonsound_08/THEMA1.MWM) | 12 | THEMA1: M. Holdorp/ F.J.W. Koller | NONE | 50 | 66 | 1:03 | `df85e816` |
| [`TRYOUT1.fur`](moonsound_08/TRYOUT1.fur) | [`TRYOUT1.MWM`](../../demo-disks/moonsound_08/TRYOUT1.MWM) | 13 | First OPL4 24 waves try-out Anne de Raad -FB- 1995 | NONE | 50 | 72 | 2:18 | `6f941ca7` |

### moonsound_09

Source: [`demo-disks/moonsound_09/`](../../demo-disks/moonsound_09/) · disk image [`moon8.trd`](../../demo-disks/moonsound_09/moon8.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_09/melody-mapping.md) · 19 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`CHRISTMA.fur`](moonsound_09/CHRISTMA.fur) | [`CHRISTMA.MWM`](../../demo-disks/moonsound_09/CHRISTMA.MWM) | 3 | +* Merry Christmas and a Happy Newjear *+ By, Qix | NONE | 50 | 35 | 1:52 | `7a576ffd` |
| [`CONCERT.fur`](moonsound_09/CONCERT.fur) | [`CONCERT.MWM`](../../demo-disks/moonsound_09/CONCERT.MWM) | 13 | MB for MoonSound Wave v0.92 Coding by R.Schrijvers | NONE | 50 | 11 | 0:40 | `4afc3744` |
| [`DARKSCRI.fur`](moonsound_09/DARKSCRI.fur) | [`DARKSCRI.MWM`](../../demo-disks/moonsound_09/DARKSCRI.MWM) | 4 | Dark Script By, Qix | NONE | 50 | 72 | 3:50 | `db291727` |
| [`GHOST.fur`](moonsound_09/GHOST.fur) | [`GHOST.MWM`](../../demo-disks/moonsound_09/GHOST.MWM) | 5 | Ghost By, Qix | NONE | 50 | 68 | 2:10 | `7f379e4d` |
| [`HAPPYEND.fur`](moonsound_09/HAPPYEND.fur) | [`HAPPYEND.MWM`](../../demo-disks/moonsound_09/HAPPYEND.MWM) | 6 | Happy Ending By, Qix | NONE | 50 | 52 | 1:39 | `e6beb0f5` |
| [`HEAVEN.fur`](moonsound_09/HEAVEN.fur) | [`HEAVEN.MWM`](../../demo-disks/moonsound_09/HEAVEN.MWM) | 7 | Death in heaven By, Qix | NONE | 50 | 32 | 1:21 | `627bf5e4` |
| [`JARRE.fur`](moonsound_09/JARRE.fur) | [`JARRE.MWM`](../../demo-disks/moonsound_09/JARRE.MWM) | 19 | MB for MoonSound Wave v0.92 Coding by R.Schrijvers | NONE | 50 | 18 | 0:57 | `7b226f3a` |
| [`ONLY_YOU.fur`](moonsound_09/ONLY_YOU.fur) | [`ONLY_YOU.MWM`](../../demo-disks/moonsound_09/ONLY_YOU.MWM) | 1 | Only you can make me... (C) Meits 1996 | NONE | 50 | 72 | 2:05 | `2e77c6de` |
| [`PALACE.fur`](moonsound_09/PALACE.fur) | [`PALACE.MWM`](../../demo-disks/moonsound_09/PALACE.MWM) | 8 | Palace By, Qix | NONE | 50 | 52 | 1:39 | `371d89ef` |
| [`PLUGPRAY.fur`](moonsound_09/PLUGPRAY.fur) | [`PLUGPRAY.MWM`](../../demo-disks/moonsound_09/PLUGPRAY.MWM) | 9 | Plug & Pray / R.vd Moosdijk / ZODIAC (for Sunrise) | NONE | 50 | 52 | 1:39 | `beb0dd8b` |
| [`POPCORN.fur`](moonsound_09/POPCORN.fur) | [`POPCORN.MWM`](../../demo-disks/moonsound_09/POPCORN.MWM) | 10 | MB for MoonSound Wave v0.92 Coding by R.Schrijvers | NONE | 50 | 12 | 0:23 | `01fc3a6f` |
| [`ROMSTAND.fur`](moonsound_09/ROMSTAND.fur) | [`ROMSTAND.MWM`](../../demo-disks/moonsound_09/ROMSTAND.MWM) | 11 | Building the ROM-stand! - Wolf '95 | NONE | 50 | 42 | 1:12 | `1aa52b33` |
| [`SAXOJAM.fur`](moonsound_09/SAXOJAM.fur) | [`SAXOJAM.MWM`](../../demo-disks/moonsound_09/SAXOJAM.MWM) | 12 | Saxo Jam By, Qix | NONE | 50 | 131 | 6:57 | `8892e254` |
| [`SDSNATCH.fur`](moonsound_09/SDSNATCH.fur) | [`SDSNATCH.MWM`](../../demo-disks/moonsound_09/SDSNATCH.MWM) | 14 | SD-Snatcher (Konami) -> OPL4 (C) 1995 Wolf | NONE | 50 | 25 | 0:48 | `a12080fd` |
| [`TWINPEAK.fur`](moonsound_09/TWINPEAK.fur) | [`TWINPEAK.MWM`](../../demo-disks/moonsound_09/TWINPEAK.MWM) | 15 | Twin Peakz (Badalamenti) (C) Wolf/CS | NONE | 50 | 38 | 2:01 | `8f7d338d` |
| [`WALTZMVV.fur`](moonsound_09/WALTZMVV.fur) | [`WALTZMVV.MWM`](../../demo-disks/moonsound_09/WALTZMVV.MWM) | 16 | MB for MoonSound Wave v0.92 Coding by R.Schrijvers | NONE | 50 | 6 | 0:11 | `0cf7f381` |
| [`WISPER.fur`](moonsound_09/WISPER.fur) | [`WISPER.MWM`](../../demo-disks/moonsound_09/WISPER.MWM) | 17 | Wispering By, Qix | NONE | 50 | 96 | 2:50 | `66c708cf` |
| [`WOLFIE.fur`](moonsound_09/WOLFIE.fur) | [`WOLFIE.MWM`](../../demo-disks/moonsound_09/WOLFIE.MWM) | 2 | MB for MoonSound Wave v0.92 Coding by R.Schrijvers | NONE | 50 | 6 | 0:17 | `f4440fcf` |
| [`YO_ANNE.fur`](moonsound_09/YO_ANNE.fur) | [`YO_ANNE.MWM`](../../demo-disks/moonsound_09/YO_ANNE.MWM) | 18 | YO ANNE! JUBA AGAIN! Meits '96 | NONE | 50 | 57 | 1:31 | `08a1ee0c` |

### moonsound_10

Source: [`demo-disks/moonsound_10/`](../../demo-disks/moonsound_10/) · disk image [`moon8.trd`](../../demo-disks/moonsound_10/moon8.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_10/melody-mapping.md) · 12 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`BEACH.fur`](moonsound_10/BEACH.fur) | [`BEACH.MWM`](../../demo-disks/moonsound_10/BEACH.MWM) | 7 | Together on the beach Meits '96 | NONE | 50 | 46 | 1:28 | `a37fdafe` |
| [`FANTASYS.fur`](moonsound_10/FANTASYS.fur) | [`FANTASYS.MWM`](../../demo-disks/moonsound_10/FANTASYS.MWM) | 3 | Same Fantasy's Meits '96 | NONE | 50 | 44 | 1:24 | `689b19b9` |
| [`HANNOBET.fur`](moonsound_10/HANNOBET.fur) | [`HANNOBET.MWM`](../../demo-disks/moonsound_10/HANNOBET.MWM) | 1 | Hanno Betaalt "MoonSound is een domme naam" Meits | NONE | 50 | 48 | 1:19 | `b3ca6125` |
| [`MAG10_12.fur`](moonsound_10/MAG10_12.fur) | [`MAG10_12.MWM`](../../demo-disks/moonsound_10/MAG10_12.MWM) | 2 | Blowing Your Mind - E vd Heide | NONE | 50 | 104 | 2:46 | `35f81dec` |
| [`MAG10_15.fur`](moonsound_10/MAG10_15.fur) | [`MAG10_15.MWM`](../../demo-disks/moonsound_10/MAG10_15.MWM) | 4 | Atmospheric Journey - E vd Heide 1996 | NONE | 50 | 136 | 3:37 | `3b8223a1` |
| [`MAG10_17.fur`](moonsound_10/MAG10_17.fur) | [`MAG10_17.MWM`](../../demo-disks/moonsound_10/MAG10_17.MWM) | 5 | Chords - E vd Heide | NONE | 50 | 60 | 1:36 | `ad71bc03` |
| [`MAG7_2.fur`](moonsound_10/MAG7_2.fur) | [`MAG7_2.MWM`](../../demo-disks/moonsound_10/MAG7_2.MWM) | 6 | The Seventh Collection - E vd Heide | NONE | 50 | 56 | 1:11 | `4895e7b6` |
| [`MAG8_14.fur`](moonsound_10/MAG8_14.fur) | [`MAG8_14.MWM`](../../demo-disks/moonsound_10/MAG8_14.MWM) | 10 | The Feeling - E vd Heide | NONE | 50 | 76 | 1:37 | `3d062a1a` |
| [`M_GEAR.fur`](moonsound_10/M_GEAR.fur) | [`M_GEAR.MWM`](../../demo-disks/moonsound_10/M_GEAR.MWM) | 8 | Meitselgear (1) (C (?)) Meits 1993/'94/'95/'96!! | NONE | 50 | 34 | 1:34 | `ce687dca` |
| [`QLSZMMZ.fur`](moonsound_10/QLSZMMZ.fur) | [`QLSZMMZ.MWM`](../../demo-disks/moonsound_10/QLSZMMZ.MWM) | 11 | 69' STIEM QLSZMMZ OLEV R | NONE | 50 | 65 | 1:34 | `06dc2d04` |
| [`RAVE1.fur`](moonsound_10/RAVE1.fur) | [`RAVE1.MWM`](../../demo-disks/moonsound_10/RAVE1.MWM) | 9 | "Rave Piano #1" - Master of Audio | NONE | 50 | 16 | 0:20 | `2de8a5f1` |
| [`SELECTOR.fur`](moonsound_10/SELECTOR.fur) | [`SELECTOR.MWM`](../../demo-disks/moonsound_10/SELECTOR.MWM) | 12 | "Make up yer mind" - OPL4 Version - SoundWave 1997 | NONE | 50 | 28 | 0:35 | `cec96ad0` |

### moonsound_11

Source: [`demo-disks/moonsound_11/`](../../demo-disks/moonsound_11/) · disk image [`moon11.trd`](../../demo-disks/moonsound_11/moon11.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_11/melody-mapping.md) · 30 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`AMAGO2.fur`](moonsound_11/AMAGO2.fur) | [`AMAGO2.MWM`](../../demo-disks/moonsound_11/AMAGO2.MWM) | 2 | Amago #2 Manuel Pazos | NONE | 50 | 7 | 0:38 | `f6f6c122` |
| [`AMAGO4.fur`](moonsound_11/AMAGO4.fur) | [`AMAGO4.MWM`](../../demo-disks/moonsound_11/AMAGO4.MWM) | 15 | Amago #4 Manuel Pazos | NONE | 50 | 12 | 0:23 | `da615d53` |
| [`AMAGO5.fur`](moonsound_11/AMAGO5.fur) | [`AMAGO5.MWM`](../../demo-disks/moonsound_11/AMAGO5.MWM) | 25 | Amago #5 Manuel Pazos | NONE | 50 | 14 | 0:44 | `a615054b` |
| [`AMAGO6.fur`](moonsound_11/AMAGO6.fur) | [`AMAGO6.MWM`](../../demo-disks/moonsound_11/AMAGO6.MWM) | 6 | AMAGO 6 Manuel Pazos | NONE | 50 | 25 | 0:40 | `37597589` |
| [`APROACH.fur`](moonsound_11/APROACH.fur) | [`APROACH.MWM`](../../demo-disks/moonsound_11/APROACH.MWM) | 3 | Approaching Manuel Pazos | NONE | 50 | 36 | 1:14 | `02a87621` |
| [`BASS.fur`](moonsound_11/BASS.fur) | [`BASS.MWM`](../../demo-disks/moonsound_11/BASS.MWM) | 4 | Bass inspiration Composed by Manuel Pazos | NONE | 50 | 4 | 0:05 | `9d135d1d` |
| [`BLOWING.fur`](moonsound_11/BLOWING.fur) | [`BLOWING.MWM`](../../demo-disks/moonsound_11/BLOWING.MWM) | 16 | Blowing Darkness Manuel Pazos | NONE | 50 | 25 | 1:26 | `91f9892b` |
| [`CEREMONY.fur`](moonsound_11/CEREMONY.fur) | [`CEREMONY.MWM`](../../demo-disks/moonsound_11/CEREMONY.MWM) | 5 | Ceremony Manuel Pazos | NONE | 50 | 12 | 0:19 | `25271349` |
| [`CLOUDS.fur`](moonsound_11/CLOUDS.fur) | [`CLOUDS.MWM`](../../demo-disks/moonsound_11/CLOUDS.MWM) | 8 | Clouds Manuel Pazos | NONE | 50 | 20 | 0:57 | `bf79ade4` |
| [`CREDITOS.fur`](moonsound_11/CREDITOS.fur) | [`CREDITOS.MWM`](../../demo-disks/moonsound_11/CREDITOS.MWM) | 17 | Creditos. Carlos Garcia. Marzo 1996 | NONE | 50 | 5 | 0:14 | `b1c18fd1` |
| [`CUARTA.fur`](moonsound_11/CUARTA.fur) | [`CUARTA.MWM`](../../demo-disks/moonsound_11/CUARTA.MWM) | 26 | 4a. Carlos Garcia, Marzo 1996 Manuel Pazos | NONE | 50 | 42 | 1:47 | `4f9697b0` |
| [`DONTCRY.fur`](moonsound_11/DONTCRY.fur) | [`DONTCRY.MWM`](../../demo-disks/moonsound_11/DONTCRY.MWM) | 9 | Don't cry little sister,he'll be back Manuel Pazos | NONE | 50 | 16 | 1:01 | `5b141ee9` |
| [`ECHOS.fur`](moonsound_11/ECHOS.fur) | [`ECHOS.MWM`](../../demo-disks/moonsound_11/ECHOS.MWM) | 10 | Echos Manuel Pazos | NONE | 50 | 24 | 1:01 | `9a380e39` |
| [`FD_MG_5.fur`](moonsound_11/FD_MG_5.fur) | [`FD_MG_5.MWM`](../../demo-disks/moonsound_11/FD_MG_5.MWM) (= moonsound_07/FD_MG_5.MWM) | 24 | Boss Battle - MG - SoundWave 1998 | NONE | 50 | 30 | 0:38 | `640892f4` |
| [`GALIOUS.fur`](moonsound_11/GALIOUS.fur) | [`GALIOUS.MWM`](../../demo-disks/moonsound_11/GALIOUS.MWM) | 11 | The Maze of Galious Inner Castle Manuel Pazos | NONE | 50 | 52 | 1:39 | `a0b9f9b5` |
| [`GALIOUS2.fur`](moonsound_11/GALIOUS2.fur) | [`GALIOUS2.MWM`](../../demo-disks/moonsound_11/GALIOUS2.MWM) | 18 | The Maze of Galious World BGM Manuel Pazos | NONE | 50 | 20 | 0:38 | `172dcd42` |
| [`GO.fur`](moonsound_11/GO.fur) | [`GO.MWM`](../../demo-disks/moonsound_11/GO.MWM) | 30 | SPELLEKE... G A M E O V E R (c) 1995 WOLF | NONE | 50 | 20 | 0:52 | `a5ff88ed` |
| [`IMPAC196.fur`](moonsound_11/IMPAC196.fur) | [`IMPAC196.MWM`](../../demo-disks/moonsound_11/IMPAC196.MWM) | — | iMpAcT 196 - BDD '92 - Omega '95 (c) Dreamscape | NONE | 50 | 85 | 2:43 | `af63131e` |
| [`ITIY2.fur`](moonsound_11/ITIY2.fur) | [`ITIY2.MWM`](../../demo-disks/moonsound_11/ITIY2.MWM) | 12 | ITIY #2 Manuel Pazos | NONE | 50 | 41 | 2:50 | `91972134` |
| [`LOOP.fur`](moonsound_11/LOOP.fur) | [`LOOP.MWM`](../../demo-disks/moonsound_11/LOOP.MWM) | — | Loop Manuel Pazos | NONE | 50 | 4 | 0:06 | `1997b574` |
| [`MAE.fur`](moonsound_11/MAE.fur) | [`MAE.MWM`](../../demo-disks/moonsound_11/MAE.MWM) | 19 | MAE Manuel Pazos | NONE | 50 | 26 | 1:23 | `aee88cef` |
| [`MAE2.fur`](moonsound_11/MAE2.fur) | [`MAE2.MWM`](../../demo-disks/moonsound_11/MAE2.MWM) | 14 | MAE #2 Manuel Pazos | NONE | 50 | 18 | 1:03 | `46f1386f` |
| [`MAKING1.fur`](moonsound_11/MAKING1.fur) | [`MAKING1.MWM`](../../demo-disks/moonsound_11/MAKING1.MWM) | 13 |  | NONE | 50 | 12 | 0:30 | `059970ea` |
| [`MISION.fur`](moonsound_11/MISION.fur) | [`MISION.MWM`](../../demo-disks/moonsound_11/MISION.MWM) | 7 | Mision imposible Manuel Pazos | NONE | 50 | 16 | 0:40 | `3cf82b3d` |
| [`NERTY.fur`](moonsound_11/NERTY.fur) | [`NERTY.MWM`](../../demo-disks/moonsound_11/NERTY.MWM) | 20 | Nerty Manuel Pazos | NONE | 50 | 16 | 0:30 | `7fc020a9` |
| [`NONAMED.fur`](moonsound_11/NONAMED.fur) | [`NONAMED.MWM`](../../demo-disks/moonsound_11/NONAMED.MWM) | 28 |  | NONE | 50 | 10 | 0:21 | `846250f4` |
| [`PARO14.fur`](moonsound_11/PARO14.fur) | [`PARO14.MWM`](../../demo-disks/moonsound_11/PARO14.MWM) | 21 | Parodius (BGM#14) Manuel Pazos | NONE | 50 | 12 | 0:19 | `68f12ff9` |
| [`PARO14B.fur`](moonsound_11/PARO14B.fur) | [`PARO14B.MWM`](../../demo-disks/moonsound_11/PARO14B.MWM) | 29 | Parodius (BGM#14) Manuel Pazos | NONE | 50 | 12 | 0:19 | `d7f11b82` |
| [`SACRA.fur`](moonsound_11/SACRA.fur) | [`SACRA.MWM`](../../demo-disks/moonsound_11/SACRA.MWM) | 22 | Musica Sacra Manuel Pazos | NONE | 50 | 18 | 0:40 | `d4bbc892` |
| [`TEARSYLP.fur`](moonsound_11/TEARSYLP.fur) | [`TEARSYLP.MWM`](../../demo-disks/moonsound_11/TEARSYLP.MWM) | 23 | Tears of Sylph Manuel Pazos | NONE | 50 | 5 | 0:17 | `41bde425` |

### moonsound_12

Source: [`demo-disks/moonsound_12/`](../../demo-disks/moonsound_12/) · disk image [`moon12.trd`](../../demo-disks/moonsound_12/moon12.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_12/melody-mapping.md) · 7 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`COPYRIGH.fur`](moonsound_12/COPYRIGH.fur) | [`COPYRIGH.MWM`](../../demo-disks/moonsound_12/COPYRIGH.MWM) | 3 | Copyright - BDD '92 - Omega '95 (C) Dreamscape | NONE | 50 | 88 | 3:32 | `8148dac3` |
| [`IMPAC187.fur`](moonsound_12/IMPAC187.fur) | [`IMPAC187.MWM`](../../demo-disks/moonsound_12/IMPAC187.MWM) | 1 | iMpAcT 187 - BDD '93 - oMEGA '95 (c) DreamScape | NONE | 50 | 81 | 2:37 | `78d7f38c` |
| [`KONAMI_2.fur`](moonsound_12/KONAMI_2.fur) | [`KONAMI_2.MWM`](../../demo-disks/moonsound_12/KONAMI_2.MWM) | 2 | Return of FireBird - SoundWave 1998 | NONE | 50 | 43 | 1:45 | `a8aed4a4` |
| [`KONAMI_3.fur`](moonsound_12/KONAMI_3.fur) | [`KONAMI_3.MWM`](../../demo-disks/moonsound_12/KONAMI_3.MWM) | 4 | Metalion - Gradius 2 - SoundWave 1998 | NONE | 50 | 56 | 1:58 | `d2ba0fc1` |
| [`THEME2.fur`](moonsound_12/THEME2.fur) | [`THEME2.MWM`](../../demo-disks/moonsound_12/THEME2.MWM) | 7 | BDD's Theme #2 - BDD'91/Omega'95 (C) dreamscape | NONE | 50 | 90 | 2:52 | `98c2d22a` |
| [`TURRICAN.fur`](moonsound_12/TURRICAN.fur) | [`TURRICAN.MWM`](../../demo-disks/moonsound_12/TURRICAN.MWM) | 6 | Turrican II - Metalslave '92 - Omega '95 (c) DS | NONE | 50 | 77 | 2:57 | `53c7f286` |
| [`VROLIKE.fur`](moonsound_12/VROLIKE.fur) | [`VROLIKE.MWM`](../../demo-disks/moonsound_12/VROLIKE.MWM) | 5 | Vrolike - BDD '92 - oMeGa '95 (C) Dreamscape | NONE | 60 | 88 | 3:17 | `74e04f56` |

### moonsound_13

Source: [`demo-disks/moonsound_13/`](../../demo-disks/moonsound_13/) · disk image [`moon13.trd`](../../demo-disks/moonsound_13/moon13.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_13/melody-mapping.md) · 21 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`BONE.fur`](moonsound_13/BONE.fur) | [`BONE.MWM`](../../demo-disks/moonsound_13/BONE.MWM) | 1 | GIVE THA DOG A BONE MEITS 1995 | NONE | 50 | 48 | 1:16 | `cc4ff73e` |
| [`CLODHOPP.fur`](moonsound_13/CLODHOPP.fur) | [`CLODHOPP.MWM`](../../demo-disks/moonsound_13/CLODHOPP.MWM) (= moonsound_13/INTRO.MWM) | — | One hell of an intro Meits 1995 | NONE | 50 | 80 | 1:25 | `e287ba92` |
| [`DRAAIKOE.fur`](moonsound_13/DRAAIKOE.fur) | [`DRAAIKOE.MWM`](../../demo-disks/moonsound_13/DRAAIKOE.MWM) | 3 | DRAAIKOEkoekswals,Valencia,Allerhande.F.J.W.Koller | NONE | 50 | 80 | 1:42 | `f500675d` |
| [`FEED.fur`](moonsound_13/FEED.fur) | [`FEED.MWM`](../../demo-disks/moonsound_13/FEED.MWM) | 4 | Give me my feed back !! Meits 1995 | NONE | 50 | 40 | 1:04 | `7762281c` |
| [`FRIK.fur`](moonsound_13/FRIK.fur) | [`FRIK.MWM`](../../demo-disks/moonsound_13/FRIK.MWM) | 5 | Frikandel special (C) Meits 1995 | NONE | 50 | 17 | 0:27 | `243219c3` |
| [`GRAGA.fur`](moonsound_13/GRAGA.fur) | [`GRAGA.MWM`](../../demo-disks/moonsound_13/GRAGA.MWM) | 6 | Gradius Gaiden! -Konami Man 97 | NONE | 50 | 9 | 0:16 | `6c7b58a6` |
| [`HAPPYJOY.fur`](moonsound_13/HAPPYJOY.fur) | [`HAPPYJOY.MWM`](../../demo-disks/moonsound_13/HAPPYJOY.MWM) | 2 | Happy, happy, joy, joy... Jelle Jelsma '96 | NONE | 50 | 44 | 1:11 | `5cdf0c89` |
| [`HEAVY.fur`](moonsound_13/HEAVY.fur) | [`HEAVY.MWM`](../../demo-disks/moonsound_13/HEAVY.MWM) | 8 | Heavy Latok in the forest Meits 1995 | NONE | 50 | 61 | 1:36 | `3aed09cb` |
| [`INDIS.fur`](moonsound_13/INDIS.fur) | [`INDIS.MWM`](../../demo-disks/moonsound_13/INDIS.MWM) | 9 | Indisposed Pancakes (C) Meits 1995 | NONE | 50 | 36 | 0:58 | `81e66960` |
| [`INTEXTRO.fur`](moonsound_13/INTEXTRO.fur) | [`INTEXTRO.MWM`](../../demo-disks/moonsound_13/INTEXTRO.MWM) | 10 | Tha final chapter intro/extro BGM Jelle Jelsma | NONE | 50 | 14 | 0:35 | `52907b74` |
| [`INTRO.fur`](moonsound_13/INTRO.fur) | [`INTRO.MWM`](../../demo-disks/moonsound_13/INTRO.MWM) (= moonsound_13/CLODHOPP.MWM) | 7 | One hell of an intro Meits 1995 | NONE | 50 | 80 | 1:25 | `e287ba92` |
| [`JJLJDG.fur`](moonsound_13/JJLJDG.fur) | [`JJLJDG.MWM`](../../demo-disks/moonsound_13/JJLJDG.MWM) | 11 | J.J.L.J.D.G. Meits '96 | NONE | 50 | 44 | 0:56 | `a18a0cb7` |
| [`LAYDOCK.fur`](moonsound_13/LAYDOCK.fur) | [`LAYDOCK.MWM`](../../demo-disks/moonsound_13/LAYDOCK.MWM) | 12 | S-U-P-E-R LAYDOCK DEMO BGM MEITS '95 | NONE | 50 | 48 | 1:12 | `a5407915` |
| [`MOA.fur`](moonsound_13/MOA.fur) | [`MOA.MWM`](../../demo-disks/moonsound_13/MOA.MWM) | 13 | MOA-SOUND-A-LIKE Meits 1995 | NONE | 50 | 34 | 0:43 | `6c9e7434` |
| [`MUSIC.fur`](moonsound_13/MUSIC.fur) | [`MUSIC.MWM`](../../demo-disks/moonsound_13/MUSIC.MWM) | — | ANALOGY (Intro Logo) Manuel Pazos | NONE | 50 | 3 | 0:05 | `1f64b09c` |
| [`PIPPOLS.fur`](moonsound_13/PIPPOLS.fur) | [`PIPPOLS.MWM`](../../demo-disks/moonsound_13/PIPPOLS.MWM) | 17 | ALWAYS PIPPOLS COVERS ! (C) MEITS 1995 | NONE | 50 | 68 | 1:28 | `740d1a66` |
| [`POPTUNED.fur`](moonsound_13/POPTUNED.fur) | [`POPTUNED.MWM`](../../demo-disks/moonsound_13/POPTUNED.MWM) | 18 | POPTUNED: -MSX- Radio Frans J.W.Koller | NONE | 50 | 62 | 1:39 | `5e1519c1` |
| [`PRELUDIA.fur`](moonsound_13/PRELUDIA.fur) | [`PRELUDIA.MWM`](../../demo-disks/moonsound_13/PRELUDIA.MWM) | 14 | PRELUDIA van Joh. Seb. Bach Bewerkt:F.J.W. Koller | NONE | 50 | 13 | 0:23 | `caa5798c` |
| [`SHIVAN.fur`](moonsound_13/SHIVAN.fur) | [`SHIVAN.MWM`](../../demo-disks/moonsound_13/SHIVAN.MWM) | 15 | Shivan Dragon (OPL4 conversion) Jelle Jelsma '95 | NONE | 50 | 36 | 0:57 | `cf43377e` |
| [`SPAIN.fur`](moonsound_13/SPAIN.fur) | [`SPAIN.MWM`](../../demo-disks/moonsound_13/SPAIN.MWM) | 16 | Manuel Pazos | NONE | 50 | 12 | 0:34 | `ad31261b` |
| [`SPAIN2.fur`](moonsound_13/SPAIN2.fur) | [`SPAIN2.MWM`](../../demo-disks/moonsound_13/SPAIN2.MWM) | 19 | Spain Manuel Pazos | NONE | 50 | 28 | 1:20 | `2b333d5d` |

### moonsound_14

Source: [`demo-disks/moonsound_14/`](../../demo-disks/moonsound_14/) · disk image [`moon14.trd`](../../demo-disks/moonsound_14/moon14.trd) · track order [melody-mapping.md](../../demo-disks/moonsound_14/melody-mapping.md) · 12 songs

| Furnace module | Source | Melody | Info | Kit | Hz flag | Positions | Length | Source SHA1 |
|---|---|---|---|---|---|---|---|---|
| [`AMAZED.fur`](moonsound_14/AMAZED.fur) | [`AMAZED.MWM`](../../demo-disks/moonsound_14/AMAZED.MWM) | 1 | Amazed (The Offspring) Near Dark 1997 | TALL_ONE | 50 | 149 | 4:21 | `407038b2` |
| [`BONUS_1.fur`](moonsound_14/BONUS_1.fur) | [`BONUS_1.MWM`](../../demo-disks/moonsound_14/BONUS_1.MWM) | 2 | Eleanor (The Gathering) Alto BONUS #1 Near Dark 96 | TALL_ONE | 50 | 137 | 5:43 | `dbd8ae1e` |
| [`BONUS_2.fur`](moonsound_14/BONUS_2.fur) | [`BONUS_2.MWM`](../../demo-disks/moonsound_14/BONUS_2.MWM) | 3 | The Mirror Waters (Gathering) Bonus #2 Near Dark | TALL_ONE | 50 | 171 | 7:28 | `d212a460` |
| [`CLOSEFAR.fur`](moonsound_14/CLOSEFAR.fur) | [`CLOSEFAR.MWM`](../../demo-disks/moonsound_14/CLOSEFAR.MWM) | 4 | Close, but far away Near Dark 1997 | TALL_ONE | 50 | 60 | 1:36 | `d2cd8230` |
| [`DARKNESS.fur`](moonsound_14/DARKNESS.fur) | [`DARKNESS.MWM`](../../demo-disks/moonsound_14/DARKNESS.MWM) | 5 | Darkness Near Dark 1997 | TALL_ONE | 50 | 50 | 1:40 | `e24ed59b` |
| [`DROWNED.fur`](moonsound_14/DROWNED.fur) | [`DROWNED.MWM`](../../demo-disks/moonsound_14/DROWNED.MWM) | 6 | Drowned Maid (Amorphis) Near Dark 1997 | TALL_ONE | 50 | 140 | 4:29 | `06fe4335` |
| [`EMPTYNES.fur`](moonsound_14/EMPTYNES.fur) | [`EMPTYNES.MWM`](../../demo-disks/moonsound_14/EMPTYNES.MWM) | 7 | Complete Emptyness Near Dark 1997 | TALL_ONE | 50 | 72 | 1:43 | `22ed9666` |
| [`FOLKNORT.fur`](moonsound_14/FOLKNORT.fur) | [`FOLKNORT.MWM`](../../demo-disks/moonsound_14/FOLKNORT.MWM) | 8 | Folk of the North (Amorphis) Near Dark 1997 | TALL_ONE | 50 | 35 | 1:17 | `bbf5ef4d` |
| [`GONEAWAY.fur`](moonsound_14/GONEAWAY.fur) | [`GONEAWAY.MWM`](../../demo-disks/moonsound_14/GONEAWAY.MWM) | 9 | Gone Away (The Offspring) Near Dark 1997 | TALL_ONE | 50 | 120 | 4:09 | `8ba74a8f` |
| [`LOVE_JO.fur`](moonsound_14/LOVE_JO.fur) | [`LOVE_JO.MWM`](../../demo-disks/moonsound_14/LOVE_JO.MWM) | 11 | Love 'JO' to death (Type O Negative)Near Dark 1997 | TALL_ONE | 50 | 110 | 7:06 | `54c60f74` |
| [`MONSUNP2.fur`](moonsound_14/MONSUNP2.fur) | [`MONSUNP2.MWM`](../../demo-disks/moonsound_14/MONSUNP2.MWM) | 10 | Part of Moon and sun part II (Amorphis) Near Dark | TALL_ONE | 50 | 53 | 1:27 | `59a0067f` |
| [`SELECTOR.fur`](moonsound_14/SELECTOR.fur) | [`SELECTOR.MWM`](../../demo-disks/moonsound_14/SELECTOR.MWM) | 12 | Graveyard (The "Fuck-error") Near Dark 1997 | TALL_ONE | 50 | 9 | 0:10 | `7d49056a` |

## Notes

**Identical sources.** These files are byte-identical copies on more than one disk; each copy has its own module:

- `moonmusic_02/CHAOS2.MWM` = `moonsound_06/CHAOS2.MWM`
- `moonsound_07/FD_MG_5.MWM` = `moonsound_11/FD_MG_5.MWM`
- `moonsound_13/CLODHOPP.MWM` = `moonsound_13/INTRO.MWM`

**Conversion warnings** (⚠ in the index):

- `moonmusic_01/YS4LAVA.MWM`: pitch paths merged at 3.1-cent tolerance to stay within 256 instruments
- `moonmusic_02/ALLPART2.MWM`: pitch paths merged at 12.5-cent tolerance to stay within 256 instruments
- `moonsound_02/REMEMBER.MWM`: sample kit HARDBASS.MWK not found - kit waves will be silent
- `moonsound_03/FOTI.MWM`: pitch paths merged at 6.2-cent tolerance to stay within 256 instruments
- `moonsound_04/SPRING.MWM`: sample kit SPRING.MWK not found - kit waves will be silent

**Not yet translated.** Wave tracks (PCM) are complete apart from *damp*: their note links, pitch bends, detune and modulation are reproduced tick by tick as per-note pitch macros. On the FM side, MFM pitch bends, modulation and portamento are not converted yet, so FM passages that rely on them sound plainer than on real hardware. See [furnace-converter.md](../../tools/moonsound-decoder/doc/furnace-converter.md#not-yet-translated).

## Accuracy

The converter reproduces the original Z80 players' behaviour and was checked against them, not only against the file-format docs:

- **FM:** 421 of 428 key-ons in five songs match the original player running in an emulator exactly (same tick, channel, block and F-number); the rest are within 4 cents.
- **PCM:** every tick of every sounding wave note is compared with a tick-exact simulation of the player (pitch bends, links, detune and vibrato included), using Furnace's own register output. Over all 240 songs, 98.8% of 16.2 million sounding ticks are within 2 cents, and 217 songs never exceed 3 cents. The rest are songs that needed a coarser instrument-sharing tolerance (up to 12.5 cents, `ALLPART2`), note links inside notes longer than 255 ticks that land one tick late, and one bend in `TWINPEAK` that runs off the top of the chip's pitch range.

## Regenerating

From `tools/moonsound-decoder`:

```bash
python3 scripts/export_furnace_collection.py
```

This rewrites every module, this README and [`../README.md`](../README.md). It needs the YRW-801 ROM image at `hardware/firmware/YRW801-M - Yamaha - 1993.rom` and reads `.MWK` kits from each song's disk folder.

## Rights

The music belongs to its original composers (named in each song's info string); the embedded samples come from the Yamaha YRW-801 ROM or the MoonBlaster sample kits on the disks. Like the rest of this archive, the conversions are provided for historical and educational purposes.
