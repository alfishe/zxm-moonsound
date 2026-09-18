# Furnace Converter

Converts MoonBlaster `.MFM` (FM + 6 wave tracks) and `.MWM` (24 wave tracks) songs to Furnace `.fur` modules for the Yamaha YMF278B (OPL4).

Code: `src/converters/furnace/` (`converter.py` holds the translation, the `fur_*.py` modules hold the file format) and `src/opl4_wave.py` (wave preset, tone and sample resolution).

## Ground truth

The semantics come from the reference Z80 players, not from the format documents. Several statements in older docs and specs turned out to be wrong.

- **Player sources:** `demo-disks/*/mfm_player.asm` and `mwm_player.asm`. Their tables are in `patch_table.inc` and `freq_table_*.inc`. The sources are CP1251-encoded.
- **Generated tables:** `src/moonblaster_tables.py` is produced from those `.inc` files by `scripts/gen_moonblaster_tables.py`. Do not edit it by hand.
- **Target Furnace:** the installed release is **Furnace 0.6.8.3**. It behaves differently from current GitHub master in places noted below.

## Output file

| Item | Value |
|------|-------|
| Header | `-Furnace module-`, format version **100**; infoSeek = 32 |
| Blocks | `INFO`, `INS2` × instruments, `SMP2` × samples, `PATR` × patterns, `END-` |
| Compression | zlib over the whole file (optional) |
| System | Always OPL4, `0xAE`: 42 channels (logical 0-17 FM, 18-41 PCM) |
| Pointers | Instrument, sample and pattern pointers in `INFO` are absolute file offsets, patched in after the blocks are written |

`INFO` follows the v100 reader in Furnace's `fur.cpp` field by field. Chip flags are the raw old-flags words. There are 20 compat flags, then 28 extended compat flags, virtual tempo and a subsong header.

## Song layout

- **Rows:** a pattern row is the player's 25-step buffer. The pattern length is 16 rows.
- **Pattern data:** pattern pointer + 9 gives the file offset (not +6). This skips a 3-byte chunk header. Every pattern decodes to exactly its byte span except slack at end of file.
- **Positions are unrolled:** Furnace pattern index = position index on every channel, so transposition and pattern breaks are baked in exactly.
- **Timing:** speed1 = speed2 = `xtempo`. Ticks run at **50 Hz** whatever `xhzequal` says, as the ZX Spectrum demo disks play:
  - The MFM demos and moonsound_04-14 call `MBPlayer_play` from every 50 Hz frame interrupt (IM 2), and the player's `xhzequal` code is commented out.
  - moonmusic_01/02 and moonsound_02/03 program OPL4 timer 1 from `xhzequal`: 0 gives 208 × 80.8 µs (59.5 Hz), 1 gives 248 × 80.8 µs (49.9 Hz), and any other value is the count itself. They then run the player only when the frame handler finds the timer flag set. The card leaves the YMF278B IRQ unconnected (the CPLD `C_IRQ`/`C_IRQ0` input is unused), so the flag is polled at 50 Hz, and a 59.5 Hz timer is always ready.
  - `FurnaceConverter(tick_rate=None)` (CLI `--msx-timing`) restores the MSX meaning of the flag: set = 50 Hz, clear = 60 Hz.
- **Command step 24:** written to a dedicated global channel with 3 effect columns. For MFM this is channel 41; for MWM it is channel 0.

| Command | Meaning | Furnace |
|---------|---------|---------|
| 1-23 | Tempo: speed = 25 − cmd | `09xx` + `0Fxx` |
| 24 | End of pattern | `0D00` (omitted on the last position) |
| 25-75 | Transpose = cmd − 52, from the next row | Applied to note values |
| (song end) | `xloop` = 255 means stop; otherwise loop | `FF00`, or `0Bxx` to `xloop` |

- **Tuning:** the song tuning is ~438.6 Hz. MoonBlaster's FM F-number table (C…B = 345…651) is tuned to A4 = 438.22 Hz. With a +0.087 % bias, Furnace's floored F-numbers reproduce all 12 table entries from block 3 up. Song tuning also scales PCM in Furnace, so PCM sample rates are compensated.
- **Notes:** MoonBlaster note byte N maps to Furnace note N−1 (0 = C-0, 48 = C-4).

## MFM

### FM channel allocation

- **Chain count:** `chvol_1` is at file offset `0x24B`.
- **Voice count:** there are `18 − chvol_1` FM steps.
- **4-op voices:** steps `0..chvol_1−1` are 4-op voices on hardware channels 0, 1, 2, 9, 10, 11. Each slave is the master + 3.
- **2-op voices:** the remaining steps take hardware channels in `play_table_wav_2` order: 17, 16, 15, 8, 7, 6, 14, 11, 13, 10, 12, 9, 5, 2, 4, 1, 3, 0.
- **Furnace channels:** hardware channels map to Furnace logical channels via `HW_TO_FURNACE_LOGICAL`, the inverse of Furnace's `outChanMapOPL3`.
- **Hidden channels:** unused channels are hidden.

| `chvol_1` | Reg 0x104 | Voices | FM steps used | 4-op masters (hw) |
|-----------|-----------|--------|---------------|-------------------|
| 0 | 0x00 | 18 × 2-op | 18 | — |
| 2 | 0x03 | 2 × 4-op + 14 × 2-op | 16 | 0, 1 |
| 3 | 0x07 | 3 × 4-op + 12 × 2-op | 15 | 0, 1, 2 |
| 4 | 0x0F | 4 × 4-op + 10 × 2-op | 14 | 0, 1, 2, 9 |
| 6 | 0x3F | 6 × 4-op + 6 × 2-op | 12 | 0, 1, 2, 9, 10, 11 |

The sample collection uses 0, 2, 3, 4 and 6.

### Instruments

| Furnace ins | Source | Layout |
|-------------|--------|--------|
| 0-23 | 24 × 11-byte 2-op patches at `0x008` | Registers 20/23, 40/43, 60/63, 80/83, E0/E3, C0 |
| 24-35 | 12 × 22-byte 4-op patches at `0x110` | Master pair (10 bytes), slave pair (10 bytes), then C0 and C3 |

- **Operator order (4-op):** operators are stored as [Op1, Op3, Op2, Op4]. This follows Furnace's `orderedOpsL = {0, 2, 1, 3}`.
- **Algorithm (4-op):** `alg = CNT1 | CNT2 << 1`.
- **Feedback (4-op):** taken from the master pair.

### Initial state

| Setting | File offset | Notes |
|---------|-------------|-------|
| Instrument per step | `0x27C` | 1-based |
| Pan per step | `0x218` | 1 = left, 2 = right, 3 = both |
| Detune per step | `0x233` | Signed |

### FM events

| Byte | Meaning | Furnace |
|------|---------|---------|
| 1-96 | Note, a = N−1 + transpose | Note; instrument i (2-op) or 24+i (4-op) |
| 97 | Key off | `OFF` |
| 98-121 | Instrument | Applied on next note; 4-op tracks clamp to 11 |
| 122-185 | Carrier TL (attenuation) | Volume column; ignored on 4-op tracks, like the player |
| 186 / 187 / 188 | Pan: left / right / both | `8000` / `80FF` / `8080` |
| 240-246 | Detune = 2·(N−243) | From the next note |

- **Detune:** the player adds detune to the F-number low byte with a quirk (`inc de`, `e += det`, `dec de`). This is emitted as a per-note `E5xx` fine pitch.
- **Wave tracks:** steps 18-23 are PCM wave tracks and go to Furnace channels 18-23. They use `xwavnrs` at `0x294` (32 entries) and `xwavvols` at `0x2B4`.

## MWM

- **Channels:** tracks 0-23 go to Furnace PCM channels 18-41. FM channels 0-17 are hidden.
- **Track-info fields** (offsets relative to file offset 6):
  - `xwvstpr` at +0x02: initial pan nibble per track.
  - `xbegwav` at +0x64: initial preset per track, 1-based.
  - `xwavnrs` at +0x7C: 48 presets, each mapped to a patch.
  - `xwavvols` at +0xAC: attenuation per preset.
- **Title and kit:** title at `0xE2` (50 bytes); kit name at `0xE2+50` (8 bytes).

## Wave tracks (both formats)

| Byte | Meaning | Furnace |
|------|---------|---------|
| 1-96 | Note | Note + instrument of the resolved voice |
| 97 | Key off | `OFF` |
| 98-145 | Preset | Sets the pending volume: 127 − 2·xwavvols |
| 146-177 | Volume v | Volume column 3 + 4·v |
| 178-192 | Pan nibble (N−185) & 15 | `80xx`; value chosen so Furnace writes the same nibble |
| 193-211 | Note link: N−202 semitones, same split, no retrigger | Pitch macro of the sounding note |
| 212-230 | Pitch bend: F += 2·(N−221) per tick | Pitch macro |
| 231-237 | Detune = 4·(N−234) F-units, from the next note or link | Pitch macro |
| 238-240 | Modulation: per-tick deltas from song table N−238 | Pitch macro |
| 241-242 | Damp | Not translated |

### Voice resolution (`opl4_wave.py`)

`patch = xwavnrs[preset]`:

- **0-174: ROM patch.** The patch has key splits `[bound, tone, tnote, fnums]`, and the first split with a < bound is used. Then n = tnote + a − lo, octave = n // 12 − 5 and F = fnums[n % 12].
- **175: GM drum kit.** Notes a < 36 use the `drum_midi` patch. Otherwise `GM_DRUMS[a−36]` gives a fixed tone and pitch per note.
- **176+: `.MWK` kit wave.** The record gives 8 splits, tone 384+x, and a frequency word from the Amiga, 44.1 kHz or Turbo-R table.

Rate = 22050 · 2^oct · (1024+F)/1024, the chip's own step (ymfm and openMSX: half a sample per 44.1 kHz output at oct 0). Using 44100 here made every PCM note an octave high.

**Samples and instruments.** Each (patch, split) becomes one embedded sample plus one MultiPCM instrument (`INS2` type 28, with `SM` and `MP` features):

- **Sample data:** ROM 8-, 12- or 16-bit data is decoded to 16-bit. For 12-bit, `s0 = b0<<8 | (b1&0x0F)<<4` and `s1 = b2<<8 | (b1&0xF0)`.
- **Loop:** taken from the tone header.
- **C-4 rate:** chosen so that Furnace note a plays at the player's rate.
- **Envelope:** the tone header values, with the patch's register overrides applied (`0x98`, `0xB0`, `0xC8`, `0xE0`, and the LFO/VIB byte).

**Sample sources:**

- **ROM:** `hardware/firmware/YRW801-M - Yamaha - 1993.rom`. Override the path with `FurnaceConverter(rom_path=...)`.
- **Kits:** `<kit>.MWK` is looked up in the song's directory. `convert_file` sets this automatically; otherwise pass `source_path`. If the kit is missing, a warning is added and its waves stay silent.

### Wave pitch effects (`wave_pitch.py`)

Furnace 0.6.8.3 can't express these with effect columns on OPL4 PCM. The slides `01xx`/`02xx`/`03xx`/`E1xx` don't move PCM pitch at all, and `E5xx` is reset by a note on the same row. So every wave note gets its exact pitch path instead:

1. **Simulate.** The player is simulated tick by tick:
   - Each interrupt runs `MBPlayer_play_pitch` first, then the row's events on row ticks.
   - A new note, note off, preset, pan, link or damp stops bend and modulation.
   - Detune starts at 2 × the song's per-track byte (MWM track-info +0x1C, MFM `0x245`).
   - The modulation tables are MWM +0x34 and MFM `0x24C`.
   - The pitch word follows the player exactly, including its octave carry on F-number overflow.
2. **Turn paths into macros.** Each note's per-tick rate becomes an **absolute pitch macro** in 1/128-semitone units against the note's nominal Furnace pitch, on its own instrument.
   - Measured on 0.6.8.3: value *i* applies *i* ticks after key-on, the last value holds, and a legato change doesn't restart it.
   - Samples stay shared, one per voice.
3. **Handle long paths.** A macro holds at most 255 values, so a longer path:
   - loops its periodic tail (modulation), if it has one;
   - else runs at the smallest macro speed *k* that has every pitch change on a multiple of *k* ticks, which is exact (links, which change pitch only on row ticks);
   - else uses the minimum speed with block medians (long bends). A step then lands at most one block early or late, never on a pitch in between.
4. **Fit the instrument cap.** Paths within 2 units (~1.6 cents) share an instrument. A song that would still exceed Furnace's 256-instrument limit is re-converted at 4/8/16 units, and the converter reports a warning. In the collection:
   - `YS4LAVA.MWM` needs 3.1 cents.
   - `FOTI.MWM` needs 6.2 cents.
   - `ALLPART2.MWM` needs 12.5 cents.

## Pattern encoding (`PATR`, Furnace 0.6.8.3)

The note field is used directly as the note (note + octave·12, no +60 as in master's `splitNoteToNote`). The sentinels are:

- note 0 with octave 0 means empty;
- note 100 means `OFF`.

So real notes 0 and 100 are written as 12 / −1 and 88 / +1.

## Verification

| Check | Method | Result |
|-------|--------|--------|
| FM | Original player running in the unreal-ng emulator (`core-tests --gtest_filter='MoonSoundMfm2Guest_Test.*:MoonSoundMfm3Guest_Test.*'` dumps register CSVs), compared with Furnace's `-vgmout` export | 421/428 key-ons identical (tick, hardware channel, block, F-number) across 5 songs. The rest are 2.5-4 cents off, from Furnace float rounding in blocks 1-2. |
| PCM | Every sounding tick of every wave note in Furnace's `-vgmout` export, vs the tick-exact player simulation (`wave_pitch.py`), all 240 songs at 50 Hz. Both sides are decoded with the same chip formula, so a match means Furnace writes the player's octave and F-number | 98.8% of 16.2 M ticks within 2 cents; 217 songs max ≤ 3 cents. Worse cases: instrument-sharing tolerance (≤ 12.5 cents), one-tick-late links in notes over 255 ticks, the `TWINPEAK` octave wrap |
| Batch | All demo-disk MFM/MWM files | 253/253 convert and load; largest sample payload 1.27 MB |

## Not yet translated

- **Wave tracks:** damp (241-242). Bends that run past the top of the OPL4 pitch range (`TWINPEAK.MWM` track 18) wrap the player's 4-bit octave to −8, while Furnace clamps at its maximum.
- **FM tracks:** pitch bend (189-207), modulation (208-226), portamento (227-239) and effects 247-249.
- **Missing kits:** `REMEMBER.MWM` and `SPRING.MWM` reference `HARDBASS.MWK` and `SPRING.MWK`, which are not in the collection.
