# MoonSound Demo Collection

Complete archive of ZXM-MoonSound: hardware, firmware, software, and music demos.

**Original source:** [micklab.ru/My Soundcard/ZXMMoonSound.htm](http://micklab.ru/My%20Soundcard/ZXMMoonSound.htm)  
**Archived mirror:** [`mirror/index_en.html`](mirror/index_en.html) (English) | [`mirror/index_ru.html`](mirror/index_ru.html) (Russian)

## Repository Structure

```
moonsound-demo/
├── demo-disks/              # 20 demo disks with sources (710 files)
│   ├── mfm_sample_01-04/    # MFM (FM synthesis) demos
│   ├── moonmusic_01-02/     # MWM (wavetable) demos  
│   └── moonsound_01-14/     # MWM demos series
├── converted/furnace/       # All 240 songs as Furnace (.fur) modules
├── doc/                     # Documentation (9 files)
│   ├── datasheets/          # Yamaha OPL2/3/4 PDFs
│   ├── file-formats/        # MFM/MWM format specs
│   ├── overview.md          # Technical overview
│   └── opl4-reference-implementations.md
├── hardware/                # Hardware project (135 files)
│   ├── schematics/          # P-CAD 2002 + PDFs
│   ├── pcb/                 # PCB layouts, Gerbers
│   ├── firmware/            # CPLD + ROM images
│   ├── tools/moonservice/   # Service utility v01-v03a
│   └── images/              # Board photos
├── mirror/                  # Original page mirror (104 files)
│   ├── index_en.html        # English translation
│   ├── index_ru.html        # Original Russian
│   └── file/                # All downloadable content
└── README.md
```

## Hardware

**[`hardware/README.md`](hardware/README.md)** — Complete hardware documentation

### Board Revisions

| Revision | Year | Units | Solder Mask | Notes |
|----------|------|-------|-------------|-------|
| [Rev 00](hardware/schematics/zxm_moonsound_00.pdf) | 2015 | 24 | Green | Original design by Mick |
| [Rev 01](hardware/schematics/zxm_moonsound_01.pdf) | 2016 | — | Red | Production by MV1971 |

### Key Files

| File | Description |
|------|-------------|
| [`hardware/schematics/`](hardware/schematics/) | Schematics (P-CAD 2002) + assembly PDFs |
| [`hardware/pcb/zxm_moonsound_gerber01.rar`](hardware/pcb/) | Gerber files for manufacturing |
| [`hardware/firmware/yrw801m_1993.rar`](hardware/firmware/) | YRW801-M wavetable ROM (2MB) |
| [`hardware/firmware/zxm_moonsound_frm0100.rar`](hardware/firmware/) | CPLD firmware (EPM7032STC44) |
| [`hardware/tools/moonservice/`](hardware/tools/moonservice/) | MoonService utility v01, v02, v03, v03a |

## Hardware Requirements

**Required:**
- **Pentagon 512K** or **Pentagon 1024K** (Russian ZX Spectrum clone)
- **ZXM-MoonSound** card (Yamaha YMF278B / OPL4)
- **Beta Disk** interface (TR-DOS)

**Why Pentagon 512K specifically:**
- Demos use extended memory pages 0x10-0x17 via port 0x7FFD
- Standard 128K only has pages 0x00-0x07 — demos will crash
- No runtime detection — code assumes Pentagon memory model

**NOT compatible with:**
- Original ZX Spectrum 128K (insufficient RAM)
- Scorpion ZS-256 (different extended paging via 0x1FFD)
- Profi (different memory map)

**Compatible FPGA/emulators:**
- ZX Evolution, ZX-Uno, ZXDOS+ (with Pentagon 512K + MoonSound cores)
- Unreal Speccy (with MoonSound emulation)

See [`doc/overview.md`](doc/overview.md) for detailed technical information.

## Demo Disks

**38 MFM tracks** (FM synthesis) + **200+ MWM tracks** (PCM/wavetable)

### MFM Demos (FM Synthesis)

| Folder | Tracks | Description |
|--------|--------|-------------|
| [`mfm_sample_01`](demo-disks/mfm_sample_01/) | 2 | First FM demo (2014) |
| [`mfm_sample_02`](demo-disks/mfm_sample_02/) | 15 | Ys-II, jingles |
| [`mfm_sample_03`](demo-disks/mfm_sample_03/) | 13 | Aleste, Forest |
| [`mfm_sample_04`](demo-disks/mfm_sample_04/) | 8 | Xak, XMAS |

### MWM Demos (Wavetable Synthesis)

| Folder | Tracks | Folder | Tracks |
|--------|--------|--------|--------|
| [`moonmusic_01`](demo-disks/moonmusic_01/) | 12 | [`moonmusic_02`](demo-disks/moonmusic_02/) | 14 |
| [`moonsound_01`](demo-disks/moonsound_01/) | 0 (driver) | [`moonsound_02`](demo-disks/moonsound_02/) | 6 |
| [`moonsound_03`](demo-disks/moonsound_03/) | 6 | [`moonsound_04`](demo-disks/moonsound_04/) | 6 |
| [`moonsound_05`](demo-disks/moonsound_05/) | 14 | [`moonsound_06`](demo-disks/moonsound_06/) | 12 |
| [`moonsound_07`](demo-disks/moonsound_07/) | 18 | [`moonsound_08`](demo-disks/moonsound_08/) | 13 |
| [`moonsound_09`](demo-disks/moonsound_09/) | 19 | [`moonsound_10`](demo-disks/moonsound_10/) | 12 |
| [`moonsound_11`](demo-disks/moonsound_11/) | 30 | [`moonsound_12`](demo-disks/moonsound_12/) | 7 |
| [`moonsound_13`](demo-disks/moonsound_13/) | 19 | [`moonsound_14`](demo-disks/moonsound_14/) | 12 |

### Each Demo Disk Contains

- `moonsound_demo.asm` — Demo source code
- `mfm_player.asm` / `mwm_player.asm` — Player driver
- `*.MFM` / `*.MWM` — Music files
- `melody-mapping.md` — Track order mapping
- `preview.png` — Screenshot

### Furnace Conversions

Every song on the demo disks is also available as a [Furnace](https://github.com/tildearrow/furnace) tracker module (OPL4, samples embedded) in [`converted/furnace/`](converted/furnace/), in folders that mirror `demo-disks/`. The [index](converted/furnace/README.md) maps each module to its source file, disk image and demo melody number.

## Documentation

| Document | Description |
|----------|-------------|
| [`doc/overview.md`](doc/overview.md) | Technical overview, I/O ports, memory map, building |
| [`doc/file-formats/mfm-moonblaster.md`](doc/file-formats/mfm-moonblaster.md) | MFM file format specification |
| [`doc/file-formats/moonblaster.md`](doc/file-formats/moonblaster.md) | MoonBlaster tracker overview |
| [`doc/opl4-reference-implementations.md`](doc/opl4-reference-implementations.md) | OPL4 emulator comparison (ymfm, Nuked, VGMPlay) |

### Datasheets

| Chip | Document |
|------|----------|
| YMF278B (OPL4) | [`doc/datasheets/opl4-application-manual.pdf`](doc/datasheets/opl4-application-manual.pdf) |
| YMF262 (OPL3) | [`doc/datasheets/ymf262-OPL3.pdf`](doc/datasheets/ymf262-OPL3.pdf) |
| YM3812 (OPL2) | [`doc/datasheets/ym3812-OPL2.pdf`](doc/datasheets/ym3812-OPL2.pdf) |
| YAC513 (DAC) | [`doc/datasheets/yac513.pdf`](doc/datasheets/yac513.pdf) |

## File Types

| Extension | Format | Channels | Description |
|-----------|--------|----------|-------------|
| `.MFM` | MoonBlaster FM Music | 18 FM | OPL4 FM synthesis |
| `.MWM` | MoonBlaster Wave Music | 24 PCM | OPL4 wavetable synthesis |

## Mirror

The [`mirror/`](mirror/) folder contains a complete offline copy of the original micklab.ru page with all downloadable files, preserved for archival purposes.

- [`mirror/index_en.html`](mirror/index_en.html) — English translation
- [`mirror/index_ru.html`](mirror/index_ru.html) — Original Russian

## Attribution

| Role | Person | Year |
|------|--------|------|
| Original MoonSound | Henrik Gilvad | 1995 |
| Wozblaster (MSX) | Gustavo Iriarte (Ciro) | 2012 |
| Konami cartridge adaptation | Evgeny Brychkov | 2013 |
| ZXM-MoonSound (ZX Spectrum) | Mick (Максов И.Н.) | 2015 |
| Revision 01 production | Vitaliy Mikhalkov (MV1971) | 2016 |

## License

Hardware designs, firmware, and demo software are preserved here for historical and educational purposes. Original rights belong to their respective authors.
