# Moonsound 12 - Melody Mapping

Source: `moonsound_demo.asm`

## Melody Table

| # | Page | Address | Size (hex) | MWM File | Size (bytes) |
|---|------|---------|------------|----------|--------------|
| 1 | 0x11 | 0xC000 | 0x2680 | IMPAC187.MWM | 9856 |
| 2 | 0x11 | 0xE680 | 0x1780 | KONAMI_2.MWM | 6016 |
| 3 | 0x13 | 0xC000 | 0x3700 | COPYRIGH.MWM | 14080 |
| 4 | 0x14 | 0xC000 | 0x1730 | KONAMI_3.MWM | 5927 |
| 5 | 0x14 | 0xD730 | 0x2780 | VROLIKE.MWM | 10112 |
| 6 | 0x16 | 0xC000 | 0x3700 | TURRICAN.MWM | 14080 |
| 7 | 0x17 | 0xC000 | 0x2F00 | THEME2.MWM | 12032 |

## Notes

- Demo loads 7 MWM (Wave) melodies
- SPACE advances, CS+CAPS exits