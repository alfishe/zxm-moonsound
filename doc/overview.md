# MoonSound Demo Collection - Technical Overview

## Goals

This repository preserves and documents the complete collection of MoonBlaster music demos for ZXM-MoonSound, providing:

1. **Archival** - All demo disk sources from micklab.ru in organized structure
2. **Documentation** - File format specs, hardware details, melody mappings
3. **Reference** - Test material for OPL4 emulator development and verification

## Hardware Architecture

### ZXM-MoonSound Cartridge

The ZXM-MoonSound is a sound expansion for Pentagon-compatible ZX Spectrum clones, based on:

- **Yamaha YMF278B (OPL4)** - Combined FM + PCM synthesizer
  - 18 FM channels (OPL3-compatible)
  - 24 PCM/wavetable channels
  - 512KB sample ROM + optional 512KB RAM

### I/O Ports

| Port | Function |
|------|----------|
| 0xC4 | OPL4 FM Register 1 (address) |
| 0xC5 | OPL4 FM Data 1 |
| 0xC6 | OPL4 FM Register 2 (address) |
| 0xC7 | OPL4 FM Data 2 |
| 0x7E | OPL4 Wave Register (address) |
| 0x7F | OPL4 Wave Data |

### Memory Requirements

The demos use Pentagon 512K extended memory paging:

| Page Value | Memory Bank | Usage |
|------------|-------------|-------|
| 0x10 | Bank 0 (base) | Player code, work area |
| 0x11 | Bank 1 | Music data pack 0 |
| 0x13 | Bank 3 | Music data pack 1 |
| 0x14 | Bank 4 | Music data pack 2 |
| 0x16 | Bank 6 | Music data pack 3 |
| 0x17 | Bank 7 | Music data pack 4, fonts |

**Paging mechanism:** Port 0x7FFD, bits 0-2 select page (0-7), bits 6-7 select 128K bank (Pentagon extension).

## Supported Configurations

### Real Hardware

| System | Support | Notes |
|--------|---------|-------|
| Pentagon 512K | ✅ Full | Primary target |
| Pentagon 1024K | ✅ Full | |
| ZX Spectrum 128K | ❌ No | Insufficient RAM (only 128KB) |
| Scorpion ZS-256 | ❌ No | Different paging (port 0x1FFD) |
| Profi | ❌ No | Different memory map |
| ATM Turbo | ⚠️ Untested | May work with Pentagon mode |

### FPGA Clones

| System | Support | Notes |
|--------|---------|-------|
| ZX Evolution | ✅ Yes | With Pentagon 512K + MoonSound cores |
| ZX-Uno | ✅ Yes | With appropriate cores |
| ZXDOS+ | ✅ Yes | With appropriate cores |
| MiSTer | ⚠️ Partial | Depends on core implementation |

### Emulators

| Emulator | Support | Notes |
|----------|---------|-------|
| Unreal Speccy | ✅ Yes | Pentagon 512K + MoonSound |
| FUSE | ❌ No | No OPL4 emulation |
| Spectaculator | ❌ No | No OPL4 emulation |

## Constraints & Limitations

### No Hardware Detection

The demos contain **no runtime hardware detection**:
- No RAM size probing
- No clone type detection
- No fallback for incompatible systems

Code assumes Pentagon 512K and will crash or corrupt memory on incompatible systems.

### Assembly Target

All demos use `DEVICE ZXSPECTRUM128` directive for sjasmplus assembler. This is an assembly-time setting only and does not affect runtime behavior.

### TR-DOS Dependency

Demos require TR-DOS for disk operations:
- Loading via `CALL 0x3D13`
- Exit via `JP 0x3D2F`

## Building

### Requirements

- **sjasmplus** assembler (included as `sjasmplus.exe` in each demo)
- Windows or Wine (for included assembler) or native sjasmplus build

### Build Steps

```bash
cd demo-disks/mfm_sample_02
wine sjasmplus.exe moonsound_demo.asm
# Or with native sjasmplus:
sjasmplus moonsound_demo.asm
```

Output: `moonsound.bin` - loadable binary for TR-DOS

### Creating TRD Image

The built binary needs to be placed on a TR-DOS disk image (`.trd`). Pre-built images are included in each demo folder.

## File Formats

### MFM (MoonBlaster FM Music)

- Header: `MBMS` signature
- 18 FM channels
- Pattern-based sequencing
- See [`file-formats/mfm-moonblaster.md`](file-formats/mfm-moonblaster.md)

### MWM (MoonBlaster Wave Music)

- Header: `MBMS` signature  
- 24 PCM channels
- Wavetable synthesis with sample ROM
- See [`file-formats/moonblaster.md`](file-formats/moonblaster.md)

## OPL4 Emulation References

For implementing OPL4 emulation, see:

- [`opl4-reference-implementations.md`](opl4-reference-implementations.md) - Comparison of ymfm, Nuked-OPL3, VGMPlay
- [`datasheets/opl4-application-manual.pdf`](datasheets/opl4-application-manual.pdf) - Yamaha YMF278B datasheet
- [`datasheets/yac513.pdf`](datasheets/yac513.pdf) - DAC datasheet

## Demo Controls

All demos use the same control scheme:
- **SPACE** - Next melody
- **CS + CAPS** (or **CAPS SHIFT + 1**) - Exit to TR-DOS

## Source Attribution

All demo sources, music files, and player drivers created by:
- **Mick (Максов И.Н.)** - Demo programming, driver development
- **Various composers** - Original MFM/MWM music (Ys-II, Aleste, Xak, etc.)

Original source: [micklab.ru](http://micklab.ru/My%20Soundcard/ZXMMoonSound.htm)
