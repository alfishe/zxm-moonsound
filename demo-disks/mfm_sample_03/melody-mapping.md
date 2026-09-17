# MFM Music Sample 3 - Melody Mapping

Mapping of MFM filenames to demo melody numbers, derived from `moonsound_demo.asm`.

## Source Analysis

The demo loads 13 melodies from packed files (`music0.pak` to `music4.pak`) into memory pages.
The `MoonSound_tabl_music` table (lines 268-311) defines each melody's location:

```asm
MoonSound_tabl_music:
    db  page    ; Memory page (0x11, 0x13, 0x14, 0x16, 0x17)
    dw  address ; Load address in page
    dw  size    ; Size in bytes
```

## Melody Mapping

| # | Demo Display | Page | Address | Size (hex) | Size (dec) | MFM File | Match |
|---|--------------|------|---------|------------|------------|----------|-------|
| 1 | 01 | 0x11 | 0xC000 | 0x1030 | 4144 | ALESTE.MFM | 4143 bytes |
| 2 | 02 | 0x11 | 0xD030 | 0x1560 | 5472 | FOREST.MFM | 5472 bytes ✓ |
| 3 | 03 | 0x11 | 0xE590 | 0x0CA0 | 3232 | HUISHUIS.MFM | 3222 bytes |
| 4 | 04 | 0x11 | 0xF230 | 0x04B0 | 1200 | RELAXED.MFM | 1197 bytes |
| 5 | 05 | 0x13 | 0xC000 | 0x1E80 | 7808 | JAMMED2.MFM | 7798 bytes |
| 6 | 06 | 0x13 | 0xDE80 | 0x1970 | 6512 | JDKTHEME.MFM | 6511 bytes |
| 7 | 07 | 0x14 | 0xC000 | 0x0FA0 | 4000 | MATIN.MFM | 4000 bytes ✓ |
| 8 | 08 | 0x14 | 0xCFA0 | 0x2770 | 10096 | MORNGROW.MFM | 10086 bytes |
| 9 | 09 | 0x16 | 0xC000 | 0x27D0 | 10192 | PARODIUS.MFM | 10182 bytes |
| 10 | 10 | 0x16 | 0xE7D0 | 0x09D0 | 2512 | RIEDEL.MFM | 2509 bytes |
| 11 | 11 | 0x16 | 0xF1A0 | 0x0C80 | 3200 | SLOWDOWN.MFM | 3199 bytes |
| 12 | 12 | 0x17 | 0xC000 | 0x1EF0 | 7920 | RANDAM.MFM | 7909 bytes |
| 13 | 13 | 0x17 | 0xDEF0 | 0x1770 | 6000 | SALMON_1.MFM | 6000 bytes ✓ |

## Quick Reference

| Melody # | Filename |
|----------|----------|
| 1 | ALESTE.MFM |
| 2 | FOREST.MFM |
| 3 | HUISHUIS.MFM |
| 4 | RELAXED.MFM |
| 5 | JAMMED2.MFM |
| 6 | JDKTHEME.MFM |
| 7 | MATIN.MFM |
| 8 | MORNGROW.MFM |
| 9 | PARODIUS.MFM |
| 10 | RIEDEL.MFM |
| 11 | SLOWDOWN.MFM |
| 12 | RANDAM.MFM |
| 13 | SALMON_1.MFM |

## Packed Files Distribution

| Pack File | Melodies | Memory Page |
|-----------|----------|-------------|
| music0.pak | 1-4 | 0x11 |
| music1.pak | 5-6 | 0x13 |
| music2.pak | 7-8 | 0x14 |
| music3.pak | 9-11 | 0x16 |
| music4.pak | 12-13 | 0x17 |

## Notes

- Size differences (1-10 bytes) are due to sector alignment in packed files
- Exact matches (✓) confirm the mapping methodology
- Demo uses SPACE to advance to next melody, CS+CAPS to exit
- Melody number displayed on screen (lines 379-390 in asm)
- Loop count `cp 13` at line 178 confirms 13 total melodies (0-12 internal, displayed as 1-13)

## Source Files

- `moonsound_demo.asm` - Main demo source with melody table
- `mfm_player.asm` - MoonBlaster player routines
- `cat_data.asm` - Animation data (cat sprite)
- `analyzer.asm` - Spectrum analyzer visualization
