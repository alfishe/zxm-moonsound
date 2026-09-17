# MFM Music Sample 2 - Melody Mapping

Mapping of MFM filenames to demo melody numbers, derived from `moonsound_demo.asm`.

## Source Analysis

The demo loads 15 melodies from packed files (`music0.pak` to `music4.pak`) into memory pages.
The `MoonSound_tabl_music` table (lines 228-277) defines each melody's location:

```asm
MoonSound_tabl_music:
    db  page    ; Memory page (0x11, 0x13, 0x14, 0x16, 0x17)
    dw  address ; Load address in page
    dw  size    ; Size in bytes
```

## Melody Mapping

| # | Demo Display | Page | Address | Size (hex) | Size (dec) | MFM File | Match |
|---|--------------|------|---------|------------|------------|----------|-------|
| 1 | 01 | 0x11 | 0xC000 | 0x25C0 | 9664 | ALONEBTL.MFM | 9663 bytes |
| 2 | 02 | 0x11 | 0xE5C0 | 0x0570 | 1392 | DJINGLE1.MFM | 1388 bytes |
| 3 | 03 | 0x11 | 0xEB30 | 0x0420 | 1056 | DJINGLE2.MFM | 1046 bytes |
| 4 | 04 | 0x11 | 0xEF50 | 0x0460 | 1120 | DJINGLE3.MFM | 1106 bytes |
| 5 | 05 | 0x11 | 0xF3B0 | 0x04F0 | 1264 | DJINGLE4.MFM | 1257 bytes |
| 6 | 06 | 0x11 | 0xF8A0 | 0x0660 | 1632 | DJINGLE5.MFM | 1628 bytes |
| 7 | 07 | 0x13 | 0xC000 | 0x1F00 | 7936 | CRYOGENT.MFM | 7924 bytes |
| 8 | 08 | 0x13 | 0xDF00 | 0x1B00 | 6912 | DERTIGAP.MFM | 6909 bytes |
| 9 | 09 | 0x14 | 0xC000 | 0x1990 | 6544 | MEMORY.MFM | 6540 bytes |
| 10 | 10 | 0x14 | 0xD990 | 0x1820 | 6176 | FOUNTAIN.MFM | 6161 bytes |
| 11 | 11 | 0x14 | 0xF1B0 | 0x0520 | 1312 | PATSTORY.MFM | 1299 bytes |
| 12 | 12 | 0x16 | 0xC000 | 0x2A40 | 10816 | JDK2.MFM | 10801 bytes |
| 13 | 13 | 0x16 | 0xEA40 | 0x1190 | 4496 | SALMON.MFM | 4489 bytes |
| 14 | 14 | 0x17 | 0xC000 | 0x1990 | 6544 | FEEDBACK.MFM | 6541 bytes |
| 15 | 15 | 0x17 | 0xD990 | 0x2270 | 8816 | PALACEOD.MFM | 8811 bytes |

## Quick Reference

| Melody # | Filename | Origin |
|----------|----------|--------|
| 1 | ALONEBTL.MFM | Ys-II - Alone Battle |
| 2 | DJINGLE1.MFM | End of Search / Rhumba Version |
| 3 | DJINGLE2.MFM | Jingle |
| 4 | DJINGLE3.MFM | Jingle |
| 5 | DJINGLE4.MFM | Jingle |
| 6 | DJINGLE5.MFM | Jingle |
| 7 | CRYOGENT.MFM | Cryogenity LIVE! |
| 8 | DERTIGAP.MFM | Dertig April 1995 |
| 9 | MEMORY.MFM | Memory |
| 10 | FOUNTAIN.MFM | Fountain |
| 11 | PATSTORY.MFM | Pat Story |
| 12 | JDK2.MFM | JDK Theme 2 |
| 13 | SALMON.MFM | Palace of Salmon |
| 14 | FEEDBACK.MFM | Feedback |
| 15 | PALACEOD.MFM | Palace of Dreams |

## Packed Files Distribution

| Pack File | Melodies | Memory Page |
|-----------|----------|-------------|
| music0.pak | 1-6 | 0x11 |
| music1.pak | 7-8 | 0x13 |
| music2.pak | 9-11 | 0x14 |
| music3.pak | 12-13 | 0x16 |
| music4.pak | 14-15 | 0x17 |

## Notes

- Size differences (5-15 bytes) are due to sector alignment in packed files
- Loop count `cp 15` at line 138 confirms 15 total melodies (0-14 internal, displayed as 1-15)
- Demo uses SPACE to advance to next melody, CS+CAPS to exit
- Melodies 9 and 14 have identical packed size (0x1990) - MEMORY.MFM and FEEDBACK.MFM are within 1 byte of each other (6540 vs 6541)

## Source Files

- `moonsound_demo.asm` - Main demo source with melody table
- `mfm_player.asm` - MoonBlaster player routines
- `string.asm` - String display routines
