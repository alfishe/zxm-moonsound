# Moonsound 7 - Melody Mapping

Source: `moonsound_demo.asm`

## Melody Table

| # | Page | Address | Size (hex) | MWM File | Size (bytes) |
|---|------|---------|------------|----------|--------------|
| 1 | 0x11 | 0xC000 | 0x1C00 | ? | ? |
| 2 | 0x11 | 0xDC00 | 0x0EC0 | ALEID.MWM | 3770 |
| 3 | 0x11 | 0xEAC0 | 0x0B30 | ALESTE.MWM | 2862 |
| 4 | 0x13 | 0xC000 | 0x1610 | REGGAE.MWM | 5635 |
| 5 | 0x13 | 0xD610 | 0x0880 | EXTOR1.MWM | 2168 |
| 6 | 0x13 | 0xDE90 | 0x0340 | END13DO.MWM | 827 |
| 7 | 0x13 | 0xE3F0 | 0x0D30 | DISCST-1.MWM | 3374 |
| 8 | 0x13 | 0xF120 | 0x0DC0 | FD_MG_1.MWM | 3520 |
| 9 | 0x14 | 0xC000 | 0x1890 | FF7_SEL.MWM | 6284 |
| 10 | 0x14 | 0xD890 | 0x12D0 | FD_MG_2.MWM | 4802 |
| 11 | 0x14 | 0xEB60 | 0x0DC0 | FD_MG_3.MWM | 3516 |
| 12 | 0x16 | 0xC000 | 0x1850 | FF7.MWM | 6220 |
| 13 | 0x16 | 0xD850 | 0x1370 | FF7_OMOI.MWM | 4969 |
| 14 | 0x16 | 0xEBC0 | 0x1070 | ONEPIAN.MWM | 4196 |
| 15 | 0x17 | 0xC000 | 0x0CD0 | FD_MG_4.MWM | 3271 |
| 16 | 0x17 | 0xCCD0 | 0x0990 | FD_MG_5.MWM | 2437 |
| 17 | 0x17 | 0xD660 | 0x1280 | FD_MG_6.MWM | 4728 |
| 18 | 0x17 | 0xE8E0 | 0x0AC0 | KONAMI_4.MWM | 2752 |

## Notes

- Demo loads 18 MWM (Wave) melodies
- SPACE advances, CS+CAPS exits