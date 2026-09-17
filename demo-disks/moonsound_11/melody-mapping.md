# Moonsound 11 - Melody Mapping

Source: `moonsound_demo.asm`

## Melody Table

| # | Page | Address | Size (hex) | MWM File | Size (bytes) |
|---|------|---------|------------|----------|--------------|
| 1 | 0x11 | 0xC000 | 0x2C20 | ? | ? |
| 2 | 0x11 | 0xEC20 | 0x03D0 | AMAGO2.MWM | 973 |
| 3 | 0x11 | 0xEFF0 | 0x08B0 | APROACH.MWM | 2223 |
| 4 | 0x11 | 0xF8A0 | 0x0280 | BASS.MWM | 630 |
| 5 | 0x11 | 0xFB20 | 0x0390 | CEREMONY.MWM | 908 |
| 6 | 0x13 | 0xC000 | 0x06E0 | AMAGO6.MWM | 1756 |
| 7 | 0x13 | 0xC710 | 0x0600 | MISION.MWM | 1535 |
| 8 | 0x13 | 0xCD10 | 0x06D0 | CLOUDS.MWM | 1743 |
| 9 | 0x13 | 0xD3E0 | 0x06B0 | DONTCRY.MWM | 1706 |
| 10 | 0x13 | 0xDA90 | 0x07D0 | ECHOS.MWM | 2000 |
| 11 | 0x13 | 0xE260 | 0x0BF0 | GALIOUS.MWM | 3055 |
| 12 | 0x13 | 0xEE50 | 0x07E0 | ITIY2.MWM | 2008 |
| 13 | 0x13 | 0xF630 | 0x02F0 | MAKING1.MWM | 753 |
| 14 | 0x13 | 0xF920 | 0x05A0 | MAE2.MWM | 1440 |
| 15 | 0x14 | 0xC000 | 0x0350 | AMAGO4.MWM | 840 |
| 16 | 0x14 | 0xC350 | 0x07A0 | BLOWING.MWM | 1940 |
| 17 | 0x14 | 0xCAF0 | 0x03C0 | CREDITOS.MWM | 947 |
| 18 | 0x14 | 0xCEB0 | 0x06E0 | GALIOUS2.MWM | 1755 |
| 19 | 0x14 | 0xD590 | 0x0A70 | MAE.MWM | 2666 |
| 20 | 0x14 | 0xE000 | 0x0430 | NERTY.MWM | 1064 |
| 21 | 0x14 | 0xE430 | 0x0790 | PARO14.MWM | 1927 |
| 22 | 0x14 | 0xEBC0 | 0x0690 | SACRA.MWM | 1669 |
| 23 | 0x14 | 0xF250 | 0x0370 | TEARSYLP.MWM | 872 |
| 24 | 0x14 | 0xF5C0 | 0x0990 | FD_MG_5.MWM | 2437 |
| 25 | 0x16 | 0xC000 | 0x04B0 | AMAGO5.MWM | 1193 |
| 26 | 0x16 | 0xC4B0 | 0x0C20 | CUARTA.MWM | 3104 |
| 27 | 0x16 | 0xD0D0 | 0x0300 | ? | ? |
| 28 | 0x16 | 0xD3D0 | 0x0250 | NONAMED.MWM | 585 |
| 29 | 0x16 | 0xD620 | 0x08B0 | PARO14B.MWM | 2211 |
| 30 | 0x16 | 0xDED0 | 0x0CE0 | GO.MWM | 3288 |

## Notes

- Demo loads 30 MWM (Wave) melodies
- SPACE advances, CS+CAPS exits