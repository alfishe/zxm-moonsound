# PCM Register Reference

The OPL4's PCM (Wave) registers control the 24-channel wavetable synthesis engine and the memory access interface. These registers are accessed through their own dedicated I/O port pair — port 0x7E for the address and 0x7F for data — completely independent of the FM register banks. This separation reflects the PCM engine's fundamentally different architecture: where the FM engine generates sound algorithmically, the PCM engine orchestrates sample playback, envelope shaping, and pitch control for 24 simultaneous voices drawing from external memory.

## Port Access

| Port | Direction | Function |
|------|-----------|----------|
| 0x7E | Write | Wave register address select |
| 0x7F | Write | Wave register data write |
| 0x7F | Read | Wave register data read / Memory data read |

The access protocol follows the same pattern as FM registers: write the register number to 0x7E, then read or write the value through 0x7F. The address port latches the target register, and subsequent data port accesses operate on that register until a new address is written.

### Write Timing

The PCM register interface requires a minimum delay of **12 master clock cycles** (≈0.35 µs) between the address write and the data access. This is the same timing constraint as the FM registers.

## Register Map Overview

The PCM register space spans 0x00–0xF9, organized into functional groups:

| Range | Count | Description |
|-------|-------|-------------|
| 0x00–0x01 | 2 | Wave table header / Expansion |
| 0x02 | 1 | Memory access mode / Memory type / Wave table header base |
| 0x03–0x05 | 3 | Memory address (22-bit) |
| 0x06 | 1 | Memory data port |
| 0x07 | 1 | Reserved |
| 0x08–0x1F | 24 | Channel 0–23: Wave number bits [7:0] |
| 0x20–0x37 | 24 | Channel 0–23: F-Number bits [6:0] / Wave number bit 8 |
| 0x38–0x4F | 24 | Channel 0–23: Octave / Pseudo-reverb / F-Number bits [9:7] |
| 0x50–0x67 | 24 | Channel 0–23: Total Level / Level Direct |
| 0x68–0x7F | 24 | Channel 0–23: Key / Damp / LFO reset / Output channel / Panpot |
| 0x80–0x97 | 24 | Channel 0–23: LFO speed / Vibrato depth |
| 0x98–0xAF | 24 | Channel 0–23: Attack Rate / Decay 1 Rate |
| 0xB0–0xC7 | 24 | Channel 0–23: Decay Level / Decay 2 Rate |
| 0xC8–0xDF | 24 | Channel 0–23: Rate Correction / Release Rate |
| 0xE0–0xF7 | 24 | Channel 0–23: AM (tremolo) depth |
| 0xF8 | 1 | FM Mix control |
| 0xF9 | 1 | PCM Mix control |

Each per-channel register group consists of 24 consecutive addresses, one per channel. Channel N is always at the base address plus N. For example, channel 5's Total Level is at register 0x50 + 5 = 0x55.

## System Registers

### Register 0x00–0x01 — Wave Table Header

| Register | Bit | Description |
|----------|-----|-------------|
| 0x00 | 7:0 | Wave table header address (high) |
| 0x01 | 7:0 | Wave table header address (low) |

These registers configure the base address of the wave table in memory. For standard YRW801-M ROM operation, these should be left at their default (reset) values, which point to the tone header table at the beginning of ROM.

### Register 0x02 — Memory Access Mode / Wave Table Header Base

| Bit | Name | Description |
|-----|------|-------------|
| 7:5 | — | Unused |
| 4:2 | WTH | Wave table header base for wave numbers 384–511, in 512 KB units |
| 1 | MTYPE | Memory type |
| 0 | MEM | Memory access mode enable |

When **MEM** is set to 1, the CPU can read and write sample memory through registers 0x03–0x06. When MEM=0, these registers are inactive and the memory bus is available exclusively for PCM playback. Enabling memory access mode during active PCM playback may cause audible glitches, as the CPU's memory accesses compete with the engine's sample fetches.

**WTH** selects where the tone headers for wave numbers 384 and above are read from. Wave numbers 0–383 always use the header table at address 0 (the YRW801-M ROM). With WTH=4 — register value **0x10**, which both MoonBlaster players and Furnace write — headers for waves 384+ are read from **0x200000** (sample RAM), at `0x200000 + 12 × (wave − 384)`.

### Registers 0x03–0x05 — Memory Address

| Register | Bit | Description |
|----------|-----|-------------|
| 0x03 | 5:0 | Memory address bits [21:16] |
| 0x04 | 7:0 | Memory address bits [15:8] |
| 0x05 | 7:0 | Memory address bits [7:0] |

These three registers form the 22-bit memory address for CPU read/write operations. The address auto-increments after each data access through register 0x06, allowing sequential bulk transfers without re-writing the address registers.

### Register 0x06 — Memory Data

| Bit | Name | Description |
|-----|------|-------------|
| 7:0 | DATA | Read/write data byte at current memory address |

Writing to this register stores a byte at the address set by registers 0x03–0x05 and increments the address. Reading returns the byte at the current address and increments. Note: the **first read after setting the address returns invalid data** (a pipeline fill artifact). Correct code performs one dummy read before starting actual data reads.

This register is the bottleneck for sample uploads. Each byte requires a full register write cycle, so uploading a 64KB sample at Z80 speeds takes on the order of a second. The MoonBlaster tracker and MoonService utility handle this during initialization, not during real-time playback.

## Per-Channel Registers

Each of the 24 PCM channels has ten register bytes controlling every aspect of its playback. The registers are organized so that functionally related parameters are grouped together, even though this means a single channel's parameters are spread across ten non-contiguous addresses.

### Register 0x08+ch — Wave Number (Low)

| Bit | Name | Description |
|-----|------|-------------|
| 7:0 | WAVE[7:0] | Wave number, low 8 bits |

The wave number is a **9-bit** value (bit 8 lives in register 0x20+ch) that selects the tone header — and therefore the sample — to play. Wave numbers 0–383 refer to YRW801-M ROM tones; 384–511 refer to user samples in RAM (see register 0x02). Write bit 8 (register 0x20+ch) first, then this register: writing the wave number loads the tone header into the channel.

### Register 0x20+ch — F-Number (Low) / Wave Number Bit 8

| Bit | Name | Description |
|-----|------|-------------|
| 7:1 | F-NUM[6:0] | F-Number, low 7 bits |
| 0 | WAVE[8] | Wave number bit 8 |

### Register 0x38+ch — Octave / Pseudo-Reverb / F-Number (High)

| Bit | Name | Description |
|-----|------|-------------|
| 7:4 | OCT | Octave (signed, −8 to +7 in two's complement) |
| 3 | PR | Pseudo-reverb |
| 2:0 | F-NUM[9:7] | F-Number, high 3 bits |

The F-Number is a 10-bit mantissa (bits 6:0 from register 0x20+ch, bits 9:7 from this register) and the Octave a signed exponent. At the standard 33.8688 MHz clock the playback rate is:

```
Playback rate = 44100 × 2^OCT × (1024 + F-Number) / 1024   [samples per second]
```

So OCT=0, F-Number=0 plays one sample per output sample (44.1 kHz), each octave step doubles or halves the rate, and the F-Number spans one octave above that (F-Number 1023 ≈ 2×). The Octave is signed: negative values slow playback below 44.1 kHz, positive values speed it up.

The **pseudo-reverb** bit (PR) enables a hardware reverb-like tail. This is a hardware-level effect — no additional processing or delay buffers are needed.

### Register 0x50+ch — Total Level / Level Direct

| Bit | Name | Description |
|-----|------|-------------|
| 7:1 | TL | Total Level (0=max volume, 127=silence; ≈0.375 dB/step) |
| 0 | LD | Level Direct: 1 = apply TL immediately |

**Total Level** is the channel's master volume control, applied as attenuation after the envelope generator. It provides 128 steps of attenuation, from full volume (TL=0) to silence (TL=127). This is independent of the envelope — TL sets the ceiling, and the envelope shapes the volume within that ceiling.

The **Level Direct** (LD) bit controls how TL changes take effect. When LD=1, changing TL takes effect immediately without any interpolation or ramping. When LD=0, the hardware smoothly transitions to the new TL value, preventing clicks from abrupt volume changes. The MoonBlaster Wave player writes `xwavvols × 4 | 1` (LD=1); Furnace also defaults to LD=1.

### Register 0x68+ch — Key / Damp / LFO Reset / Output Channel / Pan

| Bit | Name | Description |
|-----|------|-------------|
| 7 | KEY | Key On/Off (1=on, 0=off) |
| 6 | DAMP | Damp (1=rapid mute) |
| 5 | LFO RST | LFO reset |
| 4 | CH | Output channel select |
| 3:0 | PAN | Panpot |

The **KEY** bit triggers the envelope: KEY=1 starts the Attack phase, KEY=0 starts the Release phase. This is analogous to the FM KEY bit in register 0xB0.

The **DAMP** bit provides rapid muting — much faster than even the fastest Release Rate. When DAMP is asserted, the channel's output drops to zero quickly, regardless of the envelope's current state. This is useful for clean note-stealing: before reassigning a channel to a new note, the old note can be silenced to prevent overlap artifacts.

The **panpot** is a 4-bit two's-complement-style position: **0 = center**, 1–7 move progressively to the right (7 = hardest right), 9–15 cover the left side (9 = hardest left, 15 = just left of center), and 8 silences both outputs (Furnace uses it to mute a channel). The MoonBlaster Wave player's pan events 178–192 write `(event − 185) & 15`, i.e. −7…+7 from hard left to hard right. This fine-grained panning is far more nuanced than the FM engine's simple left/right/both switching.

### Register 0x80+ch — LFO Speed / Vibrato Depth

| Bit | Name | Description |
|-----|------|-------------|
| 7:6 | — | Unused |
| 5:3 | LFO | LFO speed (0–7) |
| 2:0 | VIB | Vibrato (pitch modulation) depth (0–7) |

| LFO | Frequency |
|-----|-----------|
| 0 | 0.168 Hz |
| 1 | 2.019 Hz |
| 2 | 3.196 Hz |
| 3 | 4.206 Hz |
| 4 | 5.215 Hz |
| 5 | 5.888 Hz |
| 6 | 6.224 Hz |
| 7 | 7.066 Hz |

### Register 0x98+ch — Attack Rate / Decay 1 Rate

| Bit | Name | Description |
|-----|------|-------------|
| 7:4 | AR | Attack Rate (0=off, 15=fastest) |
| 3:0 | D1R | Decay 1 Rate (0=off, 15=fastest) |

These are the first two stages of the PCM envelope. **AR** controls the time from silence to maximum level when KEY is asserted. **D1R** controls the rate of the initial decay — the rapid volume drop after the attack peak. Together, they shape the percussive "onset" of a note: a piano hammer strike, a plucked string's initial transient, or the sharp attack of a brass note.

The actual envelope timing depends not only on these 4-bit rate values but also on the **Rate Correction** (RC) value from register 0xC8, which adjusts rates based on the note's pitch.

### Register 0xB0+ch — Decay Level / Decay 2 Rate

| Bit | Name | Description |
|-----|------|-------------|
| 7:4 | DL | Decay Level (0=max volume, 15=silence; breakpoint between D1R and D2R) |
| 3:0 | D2R | Decay 2 Rate (0=off/sustain forever, 15=fastest) |

The **Decay Level** is the threshold where the envelope transitions from Decay 1 to Decay 2. Musically, DL represents the boundary between the note's initial transient and its sustain: a piano note's hammer impact decays quickly (D1R) to a sustain level (DL) that then fades slowly (D2R).

When **D2R** is 0, the envelope holds indefinitely at the Decay Level until the key is released. A non-zero D2R creates a gradual fade during the sustain phase.

### Register 0xC8+ch — Rate Correction / Release Rate

| Bit | Name | Description |
|-----|------|-------------|
| 7:4 | RC | Rate Correction (0=none, 15=maximum pitch-dependent scaling) |
| 3:0 | RR | Release Rate (0=off, 15=fastest) |

**Rate Correction** scales all envelope rates based on the note's pitch, so higher notes get faster envelopes with RC>0. The **Release Rate** controls how quickly the note fades to silence after KEY is de-asserted.

### Register 0xE0+ch — AM Depth

| Bit | Name | Description |
|-----|------|-------------|
| 7:3 | — | Unused |
| 2:0 | AM | Tremolo (amplitude modulation) depth (0–7) |

Registers 0x80, 0x98, 0xB0, 0xC8 and 0xE0 correspond one-to-one to tone header bytes 7–11 (see [Memory Map](../architecture/memory-map.md)); loading a wave number fills them from the header, and writing them afterwards overrides the header values for that note. The MoonBlaster Wave player does exactly this with its per-patch register overrides.

## Mix Control Registers

These two registers control the relative volume of the FM and PCM engines in the final output mix. They are the only PCM-side registers that affect the FM engine's output.

### Register 0xF8 — FM Mix Control

| Bit | Name | Description |
|-----|------|-------------|
| 7:6 | — | Unused |
| 5:3 | FM_R | FM output level, right (0=max) |
| 2:0 | FM_L | FM output level, left (0=max) |

### Register 0xF9 — PCM Mix Control

| Bit | Name | Description |
|-----|------|-------------|
| 7:6 | — | Unused |
| 5:3 | PCM_R | PCM output level, right (0=max) |
| 2:0 | PCM_L | PCM output level, left (0=max) |

These 3-bit values control the attenuation of each engine's contribution to the final mix, per stereo side. Value 0 is full volume; each increment adds approximately 3 dB of attenuation, with 7 providing approximately 21 dB of reduction (not complete silence, but very quiet).

Note that `.MFM` songs are not FM-only: besides the 18 FM channels their pattern rows carry 6 PCM wave tracks, so both engines are in use for MFM as well as MWM playback.

## Practical Programming Notes

### Initializing a PCM Channel

The typical sequence to start a note on a PCM channel (this is the order Furnace uses):

```
1. Write register 0x68+ch with KEY=0 to stop any previous note
2. Write register 0x20+ch with F-Number[6:0] and wave number bit 8
3. Write register 0x08+ch with wave number [7:0]   (loads the tone header)
4. Optionally override 0x80+ch (LFO/VIB), 0x98+ch (AR/D1R), 0xB0+ch (DL/D2R),
   0xC8+ch (RC/RR), 0xE0+ch (AM)
5. Write register 0x50+ch with TL and LD
6. Write register 0x38+ch with octave, pseudo-reverb and F-Number[9:7]
7. Write register 0x68+ch with KEY=1, DAMP=0, LFO reset, output channel, pan
```

Keying the channel off first gives a clean restart; DAMP can be used instead when an immediate cut of the previous note is wanted.

### Status Register (Read from 0x7E)

Reading port 0x7E returns the PCM engine's status:

| Bit | Name | Description |
|-----|------|-------------|
| 7 | BUSY | Memory access busy (1=controller processing) |
| 6 | LD | Load in progress |
| 5:2 | — | Unused |
| 1 | T1 | Timer 1 flag (mirrors FM status) |
| 0 | T2 | Timer 2 flag (mirrors FM status) |

The **BUSY** bit must be checked before writing to memory access registers (0x03–0x06). Writing while BUSY=1 produces undefined behavior. The standard practice is to poll BUSY in a tight loop before each memory byte transfer — this is the main bottleneck for sample upload speed.

## See Also

- [Overview](../architecture/overview.md) — Chip capabilities and architecture
- [Memory Map](../architecture/memory-map.md) — Address space and wave table details
- [FM Registers](fm-registers.md) — FM register reference
- [Global Registers](global-registers.md) — Timers, control, and status
- [PCM Synthesis](../synthesis/pcm-synthesis.md) — PCM synthesis deep-dive
- [Envelope](../synthesis/envelope.md) — Envelope generator details
