# FM Register Reference

The OPL4's FM section is register-compatible with the YMF262 (OPL3), using the same dual-bank architecture that Yamaha introduced to extend the original OPL2's 9-channel limit to 18 channels. Understanding this register layout is fundamental to programming FM sound on the OPL4, and it carries subtle complexities that have tripped up emulator authors for decades.

## The Dual-Bank System

The OPL3/OPL4 FM registers are organized into two banks, accessed through two pairs of I/O ports:

| Bank | Address Port | Data Port | Channels |
|------|-------------|-----------|----------|
| Bank 1 | 0xC4 | 0xC5 | 0–8, global controls |
| Bank 2 | 0xC6 | 0xC7 | 9–17, 4-op connection |

To write a register, the programmer first writes the register number to the address port, then writes the value to the data port. The bank is selected by which address port was used — not which data port receives the write. This is a crucial distinction: the MoonBlaster player occasionally writes to port 0xC5 (Bank 1 data) after setting an address through port 0xC6 (Bank 2 address), and the write correctly targets Bank 2. An emulator must track the last address port used and route data writes accordingly.

### Write Timing

After writing to an address port, the programmer must wait at least **12 master clock cycles** (≈0.35 µs) before writing the data. After a data write, the delay before the next address write must be at least **84 master clock cycles** (≈2.48 µs). These delays are necessary because the OPL4 internally processes each write, and issuing a new write before the previous one completes produces undefined behavior. In practice, the Z80's I/O instruction timing naturally satisfies these delays on most systems, but FPGA implementations running at higher bus speeds must insert explicit wait states.

## Global Registers (Bank 1)

These registers control the overall FM engine behavior and are not specific to any individual channel.

### Register 0x01 — Test / Waveform Select Enable

| Bit | Name | Description |
|-----|------|-------------|
| 7:6 | — | Unused |
| 5 | WS | Waveform select enable (1 = all 8 waveforms available) |
| 4:0 | TEST | Test bits (must be 0 for normal operation) |

The **WS** bit is easy to overlook but critically important. When WS=0 (default after reset), all operators are locked to waveform 0 (sine wave), and the waveform select registers (0xE0–0xF5) are ignored. OPL3/OPL4 software must set WS=1 during initialization to access the full range of waveforms. (The MoonBlaster player's `MBPlayer_init_opl4` does not write register 0x01; it writes 0x105, 0x08, 0x104 and wave register 0x02.)

### Register 0x02 — Timer 1

| Bit | Name | Description |
|-----|------|-------------|
| 7:0 | T1 | Timer 1 preset value (period = (256 − T1) × 80 µs) |

Timer 1 counts at a rate derived from the master clock. When it overflows (reaches 256), it sets the corresponding flag in the status register and optionally generates an IRQ. The effective period ranges from 80 µs (T1=255) to 20,480 µs (T1=0). This timer is typically used for music playback timing, though the MoonBlaster player on ZX Spectrum uses the system's vertical blank interrupt instead.

### Register 0x03 — Timer 2

| Bit | Name | Description |
|-----|------|-------------|
| 7:0 | T2 | Timer 2 preset value (period = (256 − T2) × 320 µs) |

Timer 2 is identical in function to Timer 1 but runs at one-quarter the speed, providing a period range of 320 µs to 81,920 µs.

### Register 0x04 — Timer Control / IRQ

| Bit | Name | Description |
|-----|------|-------------|
| 7 | IRQ Reset | Write 1 to clear all IRQ flags |
| 6 | T1 Mask | 1 = mask Timer 1 overflow |
| 5 | T2 Mask | 1 = mask Timer 2 overflow |
| 4:2 | — | Unused |
| 1 | T2 Start | 1 = start Timer 2 |
| 0 | T1 Start | 1 = start Timer 1 |

The masking mechanism is often misunderstood. Masking a timer prevents its flag from being visible in the status register but does **not** stop the timer from counting. A masked timer still overflows and resets — its flag is simply suppressed. To completely stop a timer, clear its Start bit.

### Register 0x05 — OPL3 Mode Enable (Bank 2 only!)

| Bit | Name | Description |
|-----|------|-------------|
| 7:2 | — | Unused |
| 1 | NEW2 | OPL4 mode enable (PCM section) |
| 0 | NEW | OPL3 mode enable |

This register (0x105) is **written through Bank 2** (address via port 0xC6, data via 0xC7) despite being described as a "global" register. Setting NEW=1 enables OPL3 features: 18 channels, 4-operator mode, stereo panning, and the extended waveform set. Without NEW=1, the chip operates in OPL2 compatibility mode with only 9 channels and mono output.

**Boot sequence note**: NEW must be set to 1 *before* writing any OPL3-specific registers. The standard initialization sequence is:
1. Write 0x05 via Bank 2 with NEW=1, NEW2=1 (value 0x03 — what both MoonBlaster players and Furnace write)
2. Write 0x01 via Bank 1 with WS=1
3. Write 0x04 via Bank 1 to configure timers and clear IRQs
4. Configure channels and operators

### Register 0x08 — CSW / Note-Sel

| Bit | Name | Description |
|-----|------|-------------|
| 7 | CSW | Composite Sine Wave speech synthesis mode |
| 6 | NOTE-SEL | Note select for key scaling rate |
| 5:0 | — | Unused |

NOTE-SEL changes how the key scale rate (KSR) is computed from the frequency registers. When NOTE-SEL=0, the key scaling rate is derived from the top bit of the F-Number and the Block. When NOTE-SEL=1, it uses the top two bits of F-Number. The practical effect is a trade-off between pitch resolution in key scaling: NOTE-SEL=0 gives coarser but more predictable scaling, while NOTE-SEL=1 provides finer pitch-dependent rate variation.

CSW mode is a legacy feature from the OPL2 used for speech synthesis and is not used in practice on the OPL4.

### Register 0xBD — Rhythm / Depth Control

| Bit | Name | Description |
|-----|------|-------------|
| 7 | AM Depth | Tremolo depth: 0 = 1 dB, 1 = 4.8 dB |
| 6 | VIB Depth | Vibrato depth: 0 = 7 cent, 1 = 14 cent |
| 5 | Rhythm | 1 = Rhythm mode (channels 6-8 become percussion) |
| 4 | BD | Bass Drum key-on |
| 3 | SD | Snare Drum key-on |
| 2 | TOM | Tom-Tom key-on |
| 1 | CY | Cymbal key-on |
| 0 | HH | Hi-Hat key-on |

Rhythm mode repurposes channels 6, 7, and 8 as five percussion instruments. The operators of these three channels are rewired internally to produce bass drum (2 ops), snare (1 op), tom-tom (1 op), cymbal (1 op), and hi-hat (1 op). The key-on bits in this register control the percussion instruments directly — they do not use the normal channel key-on mechanism. This mode reduces the available melodic channels from 18 to 15 but provides dedicated percussion with specialized noise and ring-modulation circuits that produce more realistic drum sounds than FM melody voices can achieve.

## Per-Operator Registers

Each FM channel has 2 operators (or 4 in 4-op mode). Operators are addressed using a mapping table — the register address encodes both the operator slot and the channel number. Each bank addresses 18 operator slots.

### Operator Slot Mapping

The offset added to the base register address for each operator slot:

| Offset | Bank 1 Channel (Op) | Bank 2 Channel (Op) |
|--------|---------------------|---------------------|
| 0x00 | Ch 0 (Op 1) | Ch 9 (Op 1) |
| 0x01 | Ch 1 (Op 1) | Ch 10 (Op 1) |
| 0x02 | Ch 2 (Op 1) | Ch 11 (Op 1) |
| 0x03 | Ch 0 (Op 2) | Ch 9 (Op 2) |
| 0x04 | Ch 1 (Op 2) | Ch 10 (Op 2) |
| 0x05 | Ch 2 (Op 2) | Ch 11 (Op 2) |
| 0x08 | Ch 3 (Op 1) | Ch 12 (Op 1) |
| 0x09 | Ch 4 (Op 1) | Ch 13 (Op 1) |
| 0x0A | Ch 5 (Op 1) | Ch 14 (Op 1) |
| 0x0B | Ch 3 (Op 2) | Ch 12 (Op 2) |
| 0x0C | Ch 4 (Op 2) | Ch 13 (Op 2) |
| 0x0D | Ch 5 (Op 2) | Ch 14 (Op 2) |
| 0x10 | Ch 6 (Op 1) | Ch 15 (Op 1) |
| 0x11 | Ch 7 (Op 1) | Ch 16 (Op 1) |
| 0x12 | Ch 8 (Op 1) | Ch 17 (Op 1) |
| 0x13 | Ch 6 (Op 2) | Ch 15 (Op 2) |
| 0x14 | Ch 7 (Op 2) | Ch 16 (Op 2) |
| 0x15 | Ch 8 (Op 2) | Ch 17 (Op 2) |

The gap at offsets 0x06–0x07 and 0x0E–0x0F is a historical artifact of the OPL2's internal architecture — these slots correspond to hardware pipeline stages that don't map to user-accessible operators.

### Register 0x20+offset — Tremolo / Vibrato / Sustain / KSR / Multiplier

| Bit | Name | Description |
|-----|------|-------------|
| 7 | AM | Tremolo enable (1 = amplitude modulation active) |
| 6 | VIB | Vibrato enable (1 = frequency modulation active) |
| 5 | EG | Envelope type: 1 = sustain (hold at sustain level), 0 = decay to zero |
| 4 | KSR | Key scale rate: 1 = scale envelope rate with pitch |
| 3:0 | MULT | Frequency multiplier (see table below) |

**Frequency Multiplier values:**

| MULT | Factor | MULT | Factor |
|------|--------|------|--------|
| 0 | ×0.5 | 8 | ×8 |
| 1 | ×1 | 9 | ×9 |
| 2 | ×2 | 10 | ×10 |
| 3 | ×3 | 11 | ×10 |
| 4 | ×4 | 12 | ×12 |
| 5 | ×5 | 13 | ×12 |
| 6 | ×6 | 14 | ×15 |
| 7 | ×7 | 15 | ×15 |

Note the irregularity at values 10–15: several multipliers repeat. This is a quirk of the OPL2 design that was preserved for compatibility. The ×0.5 multiplier at MULT=0 allows the operator to oscillate at half the channel's base frequency, useful for sub-octave effects.

### Register 0x40+offset — Key Scale Level / Total Level

| Bit | Name | Description |
|-----|------|-------------|
| 7:6 | KSL | Key scale level (0=none, 1=1.5dB/oct, 2=3dB/oct, 3=6dB/oct) |
| 5:0 | TL | Total Level (0=max volume, 63=silence; 0.75 dB/step) |

**Total Level** is the operator's master attenuation. For a carrier operator, this directly controls the note's volume. For a modulator, it controls the modulation depth — higher TL means less modulation, producing a purer tone closer to a sine wave. TL=0 is maximum volume/modulation; TL=63 is silence/no modulation.

**Key Scale Level** automatically reduces the volume for higher-pitched notes, mimicking the natural tendency of acoustic instruments to produce less energy at high frequencies. At KSL=3 (6 dB/octave), the volume drops by half with each octave increase.

### Register 0x60+offset — Attack Rate / Decay Rate

| Bit | Name | Description |
|-----|------|-------------|
| 7:4 | AR | Attack Rate (0=slowest, 15=instantaneous) |
| 3:0 | DR | Decay Rate (0=no decay, 15=fastest decay) |

The **Attack Rate** controls how quickly the operator's envelope rises from silence to full volume when a key is pressed. An AR of 15 produces an instant attack suitable for percussive sounds; lower values create gradual fade-ins for pad-like timbres. An AR of 0 means no attack at all — the operator stays silent.

The **Decay Rate** controls how quickly the envelope falls from the peak to the sustain level. Combined with the Sustain Level (SL in register 0x80), this shapes the characteristic "punch" of a sound: a high DR with a low SL creates a sharp percussive transient, while a low DR with a high SL produces a gentle fade into a loud sustain.

### Register 0x80+offset — Sustain Level / Release Rate

| Bit | Name | Description |
|-----|------|-------------|
| 7:4 | SL | Sustain Level (0=max volume, 15=silence; 3 dB/step) |
| 3:0 | RR | Release Rate (0=slowest release, 15=fastest) |

**Sustain Level** is the level at which the decay phase ends and the sustain phase begins. Despite the counterintuitive numbering (0 = loudest), this maps directly to attenuation: SL=0 means the note sustains at full volume (no decay), while SL=15 means the note decays all the way to silence before "sustaining" — effectively creating a fully percussive envelope.

The **Release Rate** controls how quickly the note fades to silence after the key is released. A high RR causes an abrupt cutoff (staccato); a low RR creates a lingering fade (legato). For organ-like patches, RR is set high to give clean note releases; for string pads, RR is set low for a natural fade-out.

### Register 0xE0+offset — Waveform Select

| Bit | Name | Description |
|-----|------|-------------|
| 7:3 | — | Unused |
| 2:0 | WS | Waveform (0–7, see table below) |

**Requires register 0x01 bit 5 (WSE) = 1 to function. Otherwise, waveform 0 (sine) is always used.**

| WS | Waveform | Shape | Typical Use |
|----|----------|-------|-------------|
| 0 | Sine | Full sine wave | Clean tones, base waveform |
| 1 | Half-sine | Positive half only, silent on negative | Brighter, more harmonics |
| 2 | Absolute-sine | Full-wave rectified (positive only) | Octave doubling effect |
| 3 | Quarter-sine | Rising quarter then silent | Narrow pulse, bright |
| 4 | Alternating sine | Even periods only, odd silent | Softer tone |
| 5 | Camel sine | Absolute value of even periods | Even harmonics only |
| 6 | Square | Hard clipped to +1/−1 | Hollow, clarinet-like |
| 7 | Derived square | Log of absolute sine | Distorted, aggressive |

Waveforms 4–7 are OPL3/OPL4 additions — the OPL2 only had waveforms 0–3. The choice of operator waveform has a dramatic effect on FM timbre: modulating a sine carrier with a square modulator produces a very different spectrum than sine-on-sine modulation. The MoonBlaster patches generally use waveform 0 (sine) for most operators, relying on FM modulation depth and feedback rather than exotic waveforms for timbral variation.

## Per-Channel Registers

Channel registers control parameters that apply to the entire channel rather than individual operators: frequency, key-on/off, connection mode, and stereo panning.

### Register 0xA0+ch — F-Number (Low 8 bits)

| Bit | Name | Description |
|-----|------|-------------|
| 7:0 | F-NUM[7:0] | Lower 8 bits of the 10-bit F-Number |

### Register 0xB0+ch — Key-On / Block / F-Number (High)

| Bit | Name | Description |
|-----|------|-------------|
| 7:6 | — | Unused |
| 5 | KEY | Key On (1 = note on, 0 = note off) |
| 4:2 | BLOCK | Block / Octave (0–7) |
| 1:0 | F-NUM[9:8] | Upper 2 bits of the 10-bit F-Number |

The **KEY** bit is the trigger for note events. Writing KEY=1 starts the attack phase of all operators on the channel; writing KEY=0 begins the release phase. For 4-op channels, writing KEY on the **master channel** keys on all four operators — the slave channel's KEY bit is not used.

The relationship between F-Number, Block, and the resulting frequency is:

```
Frequency = F-Number × Master_Clock / (684 × 2^(20-Block))
          = F-Number × 33868800 / (684 × 2^(20-Block))
          = F-Number × 49516 / 2^(20-Block)
```

For A-440 Hz (concert pitch A), the F-Number/Block combination is approximately F-Number=582, Block=4. (MoonBlaster's frequency table uses F-Number=580 for A, i.e. A4 ≈ 438.2 Hz on OPL4.) Each octave doubles the frequency, so moving Block up by 1 raises the pitch one octave without changing the F-Number.

### Register 0xC0+ch — Feedback / Connection / Panning

| Bit | Name | Description |
|-----|------|-------------|
| 7:6 | — | Unused |
| 5 | R | Right speaker enable |
| 4 | L | Left speaker enable |
| 3:1 | FB | Feedback level (0=none, 1–7 = π/16 to 4π) |
| 0 | CNT | Connection: 0=FM (Op1 modulates Op2), 1=Additive (both output) |

The stereo panning is simple on/off per speaker — there are no intermediate pan positions in the FM section. L=1,R=1 outputs to both channels (center); L=1,R=0 is hard left; L=0,R=1 is hard right; L=0,R=0 mutes the channel entirely.

**Feedback** applies only to Operator 1 of the channel. The feedback value selects the fraction of OP1's output that is fed back to its own phase input:

| FB | Modulation Depth |
|----|-----------------|
| 0 | No feedback |
| 1 | π/16 |
| 2 | π/8 |
| 3 | π/4 |
| 4 | π/2 |
| 5 | π |
| 6 | 2π |
| 7 | 4π |

At FB=7, the self-modulation is so strong that the operator produces a nearly chaotic waveform — useful for noise-like percussion but generally too harsh for melodic use.

## 4-Operator Connection (Bank 2)

### Register 0x104 — 4-Op Channel Enable

| Bit | Name | Description |
|-----|------|-------------|
| 5 | CH11_EN | Channels 11+14 form a 4-op pair |
| 4 | CH10_EN | Channels 10+13 form a 4-op pair |
| 3 | CH9_EN | Channels 9+12 form a 4-op pair |
| 2 | CH2_EN | Channels 2+5 form a 4-op pair |
| 1 | CH1_EN | Channels 1+4 form a 4-op pair |
| 0 | CH0_EN | Channels 0+3 form a 4-op pair |

When a bit is set, the corresponding master/slave channel pair is linked into a 4-op channel. The **master channel** (lower-numbered) controls key-on, frequency, and panning for all four operators. The slave channel's frequency and key-on registers are ignored, but its CNT bit in register 0xC0 selects the 4-op algorithm (combined with the master's CNT bit).

The 4-op algorithm is selected by the combination of the master's and slave's CNT bits:

| Master CNT | Slave CNT | Algorithm | Description |
|------------|-----------|-----------|-------------|
| 0 | 0 | 0 | Serial: OP1→OP2→OP3→OP4 (output: OP4) |
| 1 | 0 | 1 | OP1 + (OP2→OP3→OP4) (outputs: OP1, OP4) |
| 0 | 1 | 2 | (OP1→OP2) + (OP3→OP4) (outputs: OP2, OP4) |
| 1 | 1 | 3 | OP1 + (OP2→OP3) + OP4 (outputs: OP1, OP3, OP4) |

(Algorithm number = master CNT | slave CNT << 1; the output routing matches Furnace's `isOutputL` table.)

The MoonBlaster player writes this register during initialization based on the song's `chvol_1` parameter. For CRYOGENT.MFM with `chvol_1`=6, all six possible 4-op pairs are enabled (register 0x104 = 0x3F), leaving only channels 6, 7, 8, 15, 16, 17 as independent 2-op voices.

### Register 0x105 — NEW / NEW2

This is the same register as [Register 0x05 (Bank 2)](#register-0x05--opl3-mode-enable-bank-2-only) above: bit 0 = NEW (OPL3 mode), bit 1 = NEW2 (OPL4 mode). Write 0x03 during initialization.

## Status Register (Read from port 0xC4)

| Bit | Name | Description |
|-----|------|-------------|
| 7 | IRQ | Any unmasked IRQ pending |
| 6 | T1 Flag | Timer 1 overflow |
| 5 | T2 Flag | Timer 2 overflow |
| 4:0 | — | Unused (read as 0) |

Reading the status register is the primary way to detect the OPL4's presence and poll timer state. The standard detection sequence writes known timer values, starts the timer, and checks if the flag sets — this reliably distinguishes OPL3/OPL4 from earlier chips.

## See Also

- [Overview](../architecture/overview.md) — Chip capabilities and architecture
- [PCM Registers](pcm-registers.md) — PCM/Wave register reference
- [Global Registers](global-registers.md) — Timers, control, and status details
- [FM Synthesis](../synthesis/fm-synthesis.md) — FM synthesis theory and algorithms
- [Envelope](../synthesis/envelope.md) — Envelope generator details
