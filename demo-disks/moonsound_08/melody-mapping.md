# Moonsound 8 - Melody Mapping

Source: `moonsound_demo.asm`

## Melody Table

| # | Page | Address | Size (hex) | MWM File | Size (bytes) |
|---|------|---------|------------|----------|--------------|
| 1 | 0x11 | 0xC000 | 0x1700 | AXELF.MWM | 5874 |
| 2 | 0x11 | 0xD700 | 0x1C80 | CYNTHIA.MWM | 7290 |
| 3 | 0x11 | 0xF380 | 0x0830 | SNOUT5.MWM | 2083 |
| 4 | 0x13 | 0xC000 | 0x0E00 | SNOUT4.MWM | 3583 |
| 5 | 0x13 | 0xCE00 | 0x0370 | MISTYHEA.MWM | 877 |
| 6 | 0x13 | 0xD170 | 0x27F0 | POPCORN.MWM | 10222 |
| 7 | 0x14 | 0xC000 | 0x14A0 | DISCUSS.MWM | 5268 |
| 8 | 0x14 | 0xD4A0 | 0x2A80 | NEOKOBE.MWM | 10873 |
| 9 | 0x16 | 0xC000 | 0x0EA0 | MACGYVER.MWM | 3731 |
| 10 | 0x16 | 0xCEA0 | 0x2D50 | SILENT.MWM | 11585 |
| 11 | 0x17 | 0xC000 | 0x0E00 | ENDLESSN.MWM | 3571 |
| 12 | 0x17 | 0xCE00 | 0x0C90 | THEMA1.MWM | 3212 |
| 13 | 0x17 | 0xDA90 | 0x1F10 | TRYOUT1.MWM | 7951 |

## Notes

- Demo loads 13 MWM (Wave) melodies
- SPACE advances, CS+CAPS exits