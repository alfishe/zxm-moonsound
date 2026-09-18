# OPL4 (Yamaha YMF278B) Documentation

Comprehensive documentation for the Yamaha YMF278B OPL4 sound chip as used in the ZXM-MoonSound ZX-BUS sound card.

## Overview

The OPL4 is a multi-function sound synthesizer combining:

- **FM Synthesis** — OPL3-compatible, 18 channels (or 6×4-op + 6×2-op)
- **PCM/Wavetable Synthesis** — 24 channels, 12/16-bit samples
- **Sample Memory** — 2MB ROM (YRW801-M) + up to 2MB RAM

## Documentation Structure

### Architecture
- [Overview](architecture/overview.md) — Chip capabilities and features
- [Block Diagram](architecture/block-diagram.md) — Internal architecture with Mermaid diagrams
- [Memory Map](architecture/memory-map.md) — Address spaces and memory organization

### Register Reference
- [FM Registers](registers/fm-registers.md) — Complete FM register map
- [PCM Registers](registers/pcm-registers.md) — Complete PCM/Wave register map
- [Global Registers](registers/global-registers.md) — Timers, control, status

### Synthesis Details
- [FM Synthesis](synthesis/fm-synthesis.md) — Two-operator FM, waveforms, algorithms
- [PCM Synthesis](synthesis/pcm-synthesis.md) — Sample playback, interpolation
- [Envelope](synthesis/envelope.md) — ADSR envelope generators

## I/O Port Map (ZXM-MoonSound)

| Port | Read | Write | Description |
|------|------|-------|-------------|
| 0xC4 | Status | FM Register (Bank 1) | FM address port |
| 0xC5 | — | FM Data | FM data port |
| 0xC6 | — | FM Register (Bank 2) | FM address port (OPL3 extension) |
| 0xC7 | — | FM Data | FM data port (OPL3 extension) |
| 0x7E | — | Wave Register | PCM address port |
| 0x7F | Memory Data | Wave Data | PCM data port / memory access |

## Quick Reference

### FM Synthesis

| Feature | Value |
|---------|-------|
| Channels | 18 (2-op) or 6+6 (4-op + 2-op) |
| Operators | 36 total |
| Waveforms | 8 per operator |
| Connection modes | FM (modulator→carrier) or Additive |
| Feedback levels | 8 (0=none, 1-7 = π/16 to 4π) |

### PCM Synthesis

| Feature | Value |
|---------|-------|
| Channels | 24 |
| Sample formats | 8-bit, 12-bit, 16-bit |
| Sample ROM | 2MB (YRW801-M General MIDI) |
| Sample RAM | Up to 2MB |
| Envelope | AR, D1R, DL, D2R, RC, RR |
| LFO | 8 speeds, vibrato + tremolo |

## Reference Implementations

| Project | License | Notes |
|---------|---------|-------|
| [ymfm](https://github.com/aaronsgiles/ymfm) | BSD-3 | Reference quality, C++ |
| [openMSX](https://github.com/openMSX/openMSX) | GPL-2 | MSX emulator, well-tested |
| [VGMPlay](https://github.com/vgmrips/vgmplay) | GPL-2 | ValleyBell's fixes for OPL4 |
| [Nuked-OPL3](https://github.com/nukeykt/Nuked-OPL3) | LGPL-2.1 | Cycle-accurate OPL3 |

## See Also

- [MFM / MWM File Format](../file-formats/mfm-moonblaster.md) — MoonBlaster FM and Wave Music
- [MoonBlaster 1.4 File Formats](../file-formats/moonblaster.md) — Original MSX MoonBlaster (MBM) formats
- [YMF278B Datasheet](../datasheets/opl4-application-manual.pdf) — Official Yamaha documentation
