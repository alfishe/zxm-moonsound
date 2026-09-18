# PCM Synthesis

The OPL4's PCM engine represents a fundamentally different approach to sound generation than its FM sibling. Where the FM engine creates sound through mathematical interaction of oscillators — producing timbres that are "born digital" and could never exist in the acoustic world — the PCM engine starts with recordings of real instruments and plays them back at controlled pitches, volumes, and durations. This is **wavetable synthesis**, the technology that dominated the sound card market in the mid-1990s, and the OPL4 implements it with 24 simultaneous channels, a 6-stage envelope, LFO modulation, and a hardware pseudo-reverb effect.

## How Wavetable Synthesis Works

The core idea is deceptively simple: record a short snippet of a real instrument (a piano key strike, a violin bow stroke, a trumpet note), store it in digital memory, and play it back at different speeds to produce different pitches. Playing the recording faster raises the pitch; playing it slower lowers it. Loop a portion of the sample to sustain the note indefinitely, and shape the volume with an envelope generator to control attack and decay.

The art lies in the details. A single piano sample played at wildly different speeds starts to sound unnatural — the harmonic content shifts in unrealistic ways. Professional wavetable implementations use **multisampling**: recording the same instrument at many pitches across the keyboard, then selecting the closest sample for each requested note and pitch-shifting it only slightly. The YRW801-M ROM uses this technique, with multiple samples per instrument spread across the pitch range.

## Sample Formats

The OPL4 supports three sample data formats, each stored differently in memory:

### 8-bit (Format 0)

Each sample is a single byte representing a signed amplitude value:

```
Byte N:  [ S7 S6 S5 S4 S3 S2 S1 S0 ]   (signed 8-bit, -128 to +127)
```

8-bit samples provide approximately 48 dB of dynamic range — adequate for simple sound effects and percussion but audibly "gritty" for sustained melodic instruments. The low resolution produces quantization noise that sounds like a constant faint hiss. This format uses the least memory: 44,100 bytes per second of audio at 44.1 kHz.

### 12-bit (Format 1)

The YRW801-M ROM's native format. Two 12-bit samples are packed into 3 bytes using a nibble-sharing scheme:

```
Byte N:    [ A11 A10  A9  A8  A7  A6  A5  A4 ]   Sample A, high 8 bits
Byte N+1:  [  B3  B2  B1  B0  A3  A2  A1  A0 ]   Sample B low 4 (high nibble) + Sample A low 4 (low nibble)
Byte N+2:  [ B11 B10  B9  B8  B7  B6  B5  B4 ]   Sample B, high 8 bits
```

As left-justified 16-bit values: `A = N << 8 | (N+1 & 0x0F) << 4`, `B = N+2 << 8 | (N+1 & 0xF0)`.

12-bit samples provide approximately 72 dB of dynamic range — good enough for most musical applications. The packing is somewhat awkward to decode in software (every other sample requires combining nibbles from two bytes), but the hardware handles it transparently. Memory usage is 66,150 bytes per second (1.5 bytes per sample × 44,100), a 25% savings over 16-bit.

Yamaha chose this format for the ROM as a pragmatic compromise: in 1994, ROM space was expensive, and 12-bit quality was "good enough" for a wavetable ROM that would be mixed with FM and processed through consumer-grade DACs and amplifiers.

### 16-bit (Format 2)

Each sample is a 16-bit signed value stored in big-endian byte order:

```
Byte N:    [ S15 S14 S13 S12 S11 S10 S9 S8 ]   High byte
Byte N+1:  [  S7  S6  S5  S4  S3  S2 S1 S0 ]   Low byte
```

16-bit samples provide approximately 96 dB of dynamic range — CD-quality audio. This format is recommended for user samples loaded into RAM, where the higher quality justifies the increased memory cost (88,200 bytes per second). The quality difference over 12-bit is subtle on most sound systems but noticeable in quiet passages and on high-quality monitoring equipment.

## The Wave Table

The wave table is the lookup mechanism that connects a **wave number** (a simple index) to the physical sample data in memory. When a PCM channel is assigned a wave number, the hardware reads a 12-byte header (called a **tone header** in Yamaha's documentation) that contains everything needed to play the sample.

### Wave Number Resolution

```
Wave Number (0-511)
       │
       ▼
┌──────────────────┐
│ Tone Header      │
│ (12 bytes)       │
│                  │
│ • Format (8/12/16)│
│ • Start Address   │
│ • Loop Start      │
│ • Loop End        │
│ • LFO defaults    │
└──────────────────┘
       │
       ▼
┌──────────────────┐
│ Sample Data      │
│ (variable size)  │
│                  │
│ Raw audio bytes  │
│ at Start Address │
└──────────────────┘
```

For ROM instruments (wave numbers 0–383), the tone headers are stored at the beginning of the ROM at address `wave_number × 12`. The hardware reads these automatically — no CPU intervention is needed. For user instruments (wave numbers 384+), the programmer must write tone headers into the appropriate memory locations using the CPU memory access interface before they can be used.

### Tone Header Structure

Each tone header is 12 bytes:

| Byte | Content | Description |
|------|---------|-------------|
| 0 | Format + Address | Bits 7:6 = format (00=8-bit, 01=12-bit, 10=16-bit), bits 5:0 = start address [21:16] |
| 1–2 | Start Address | Start address [15:8], [7:0] |
| 3–4 | Loop Start | 16-bit big-endian offset from the start to the loop start point |
| 5–6 | End | 16-bit big-endian, stored as 0x10000 − length |
| 7 | LFO/VIB | LFO speed (bits 5:3), Vibrato depth (bits 2:0) |
| 8 | AR/D1R | Attack Rate (bits 7:4), Decay 1 Rate (bits 3:0) |
| 9 | DL/D2R | Decay Level (bits 7:4), Decay 2 Rate (bits 3:0) |
| 10 | RC/RR | Rate Correction (bits 7:4), Release Rate (bits 3:0) |
| 11 | AM | Tremolo depth (bits 2:0) |

Playback runs from the start to the end and then loops between the loop start and the end indefinitely; one-shot samples simply use a tiny loop at the very end. Bytes 7–11 are loaded into the channel's registers 0x80/0x98/0xB0/0xC8/0xE0 when the wave number is written.

The loop start and end offsets are measured in **sample units**, not bytes. For 8-bit samples, one sample = one byte. For 12-bit samples, one sample = 1.5 bytes (two samples = 3 bytes). For 16-bit samples, one sample = 2 bytes. The hardware handles the byte-to-sample address conversion automatically.

## Pitch Control

The PCM engine uses a system conceptually similar to the FM engine's F-Number/Block system, but adapted for sample playback. Instead of controlling an oscillator's phase increment, the F-Number and Octave control the **sample address increment** — how quickly the engine steps through the sample data.

### F-Number and Octave

The 10-bit F-Number is a mantissa that provides fine pitch control within an octave, and the 4-bit signed Octave (−8 to +7) is the exponent:

```
Address increment per output sample = 2^Octave × (1024 + F-Number) / 1024
Playback rate = 44100 × 2^Octave × (1024 + F-Number) / 1024   (33.8688 MHz clock)
```

With F-Number = 0 and Octave = 0 the sample advances one point per output sample (44.1 kHz). Increasing Octave by 1 doubles the playback speed, raising the pitch by one octave; the F-Number sweeps the rate across one octave above that (F-Number 1023 ≈ 2×).

The negative Octave range (−8 to −1) provides sub-rate playback for pitches far below the sample's native pitch. At Octave = −8 with a minimum F-Number, the playback rate is extremely slow — useful for bass instruments or special effects, but the quality degrades as the pitch moves further from the sample's native recording pitch.

### Pitch Accuracy

The 10-bit F-Number provides approximately **1.7-cent** pitch resolution per step within an octave. This is finer than the human ear's pitch discrimination threshold (approximately 5 cents for most listeners), so the pitch quantization is effectively inaudible. Combined with octave control, the total pitch range spans from sub-audible frequencies to well above the audible range.

## Sample Interpolation

When the playback rate differs from the sample's recorded rate (which is almost always the case), the output sample positions don't align with the stored sample positions. The engine must estimate the amplitude between two stored samples. The OPL4 uses **linear interpolation**: it draws a straight line between two adjacent sample points and picks the value at the fractional position.

```
Stored samples:    A ·         · B
                   │           │
Linear interp:    A · · · · · · B     (intermediate values calculated)
                   │   ↑       │
                   │   │       │
                   └───┼───────┘
                       │
               Fractional position (from F-Number accumulator)
```

Linear interpolation is a reasonable quality/cost trade-off. It's far better than no interpolation (which produces harsh stepping artifacts), though it does introduce a slight high-frequency roll-off. More sophisticated methods like cubic interpolation would preserve high frequencies better but require reading four sample points per output sample instead of two — a significant increase in memory bandwidth that the OPL4's memory controller cannot easily sustain across 24 simultaneous channels.

## Sample Looping

Most musical instruments sustain for as long as a key is held, but storing an entire sustained note (potentially seconds of audio) would consume enormous amounts of memory. The solution is **looping**: the sample plays forward normally until it reaches the loop end point, then jumps back to the loop start point and repeats this segment indefinitely.

```
Sample data:

 │ Attack portion │    Loop region     │
 │ (plays once)   │  (repeats forever) │
 │                │                    │
 ◄────────────────►◄──────────────────►
 Start         LoopStart          LoopEnd
 Address       (offset)           (offset)
```

The challenge of looping is finding a segment that repeats seamlessly. If the waveform at the loop start doesn't match the waveform at the loop end, there will be an audible click or pop at each loop boundary. The YRW801-M ROM samples have been carefully edited to minimize loop artifacts, but perfect loops are nearly impossible for complex timbres — there's always a slight periodic "breathing" character to looped samples if you listen closely.

There is no loop-enable bit: every tone loops between its loop start and end. One-shot sounds (percussion, short effects) are stored with a tiny, silent loop at the very end, so they effectively play through once and stop.

## LFO (Low-Frequency Oscillator)

The PCM engine's LFO provides two modulation effects: **vibrato** (pitch modulation) and **tremolo** (amplitude modulation). Unlike the FM engine's global vibrato/tremolo, the PCM LFO settings are per-channel, with speeds and depths configured independently for each voice.

### Vibrato

When the vibrato depth is non-zero, the LFO periodically varies the F-Number, creating a pitch wobble. The depth comes from tone header byte 7 (bits 2:0) and can be overridden per channel in register 0x80+ch (VIB, bits 2:0); it provides 8 levels of depth:

| Depth | Approximate Deviation |
|-------|----------------------|
| 0 | None |
| 1 | ±3.4 cents |
| 2 | ±6.7 cents |
| 3 | ±13.5 cents |
| 4 | ±26.8 cents |
| 5 | ±53.7 cents (quarter-tone) |
| 6 | ±107 cents (semitone) |
| 7 | ±214 cents (whole tone) |

Depths 1–3 are typical for natural-sounding vibrato. Depths 5–7 produce extreme pitch bending more suitable for special effects than musical performance.

### Tremolo

When the AM depth is non-zero, the LFO modulates the channel's attenuation, creating volume pulsation. The depth comes from tone header byte 11 and can be overridden in register 0xE0+ch (bits 2:0):

| Depth | Approximate Variation |
|-------|----------------------|
| 0 | None |
| 1–7 | Increasing amplitude modulation depth |

### LFO Speeds

Both vibrato and tremolo share the same LFO oscillator per channel. The speed is set via the LFO field (bits 5:3) of register 0x80+ch (tone header byte 7 by default):

| Speed | Frequency | Character |
|-------|-----------|-----------|
| 0 | 0.168 Hz | Very slow, breathing-like |
| 1 | 2.019 Hz | Slow, gentle |
| 2 | 3.196 Hz | Moderate, natural vibrato |
| 3 | 4.206 Hz | Fast, expressive |
| 4 | 5.215 Hz | Very fast, anxious |
| 5 | 5.888 Hz | Rapid, trembling |
| 6 | 6.224 Hz | Near-standard vibrato |
| 7 | 7.066 Hz | Maximum, machine-gun |

Speeds 2–4 correspond to the natural vibrato range of human performers (singers, violinists, wind players). Speed 0 is so slow it produces more of a gentle pitch drift than a perceptible vibrato.

## Pseudo-Reverb

The pseudo-reverb is a unique OPL4 feature that provides a simple reverb-like effect without any external delay line or buffer memory. When enabled for a channel, the PCM engine continues playing the sample beyond the loop end point (into the "tail" region of memory) at a reduced level, creating a decaying echo that approximates early reflections.

This is not true reverb — it doesn't simulate room acoustics or use convolution. It simply extends the sample playback past its normal loop boundary, allowing the natural decay of the recorded sample to serve as a reverb tail. The effect works best with samples that have been specifically recorded or edited to include a natural decay after the loop region.

The pseudo-reverb is enabled per channel by the PR bit (bit 3) of register 0x38+ch. It adds minimal processing overhead since it reuses the existing sample playback pipeline.

## The YRW801-M ROM

The YRW801-M is Yamaha's standard General MIDI wavetable ROM, used across multiple OPL4 products including the MoonSound, various PC sound cards, and industrial MIDI synthesizer modules.

### Contents

The ROM contains 384 tone entries covering:

| Category | GM Numbers | Examples |
|----------|-----------|---------|
| Piano | 1–8 | Acoustic Grand, Electric Piano, Honky-Tonk |
| Chromatic Perc | 9–16 | Celesta, Glockenspiel, Music Box, Vibraphone |
| Organ | 17–24 | Drawbar Organ, Percussive Organ, Church Organ |
| Guitar | 25–32 | Nylon Guitar, Steel Guitar, Jazz Guitar |
| Bass | 33–40 | Acoustic Bass, Fingered Bass, Slap Bass |
| Strings | 41–48 | Violin, Viola, Cello, Orchestral Strings |
| Ensemble | 49–56 | String Ensemble, Synth Strings, Choir |
| Brass | 57–64 | Trumpet, Trombone, French Horn, Brass Section |
| Reed | 65–72 | Soprano Sax, Alto Sax, Oboe, Clarinet |
| Pipe | 73–80 | Piccolo, Flute, Recorder, Pan Flute |
| Synth Lead | 81–88 | Square Lead, Sawtooth Lead, Calliope |
| Synth Pad | 89–96 | New Age Pad, Warm Pad, Polysynth |
| Synth Effects | 97–104 | Rain, Soundtrack, Crystal, Atmosphere |
| Ethnic | 105–112 | Sitar, Banjo, Shamisen, Koto |
| Percussive | 113–120 | Tinkle Bell, Agogo, Steel Drums, Taiko |
| Sound Effects | 121–128 | Guitar Fret Noise, Seashore, Telephone, Helicopter |
| Drums | — | Standard Kit, Room Kit, Power Kit, etc. |

### Quality Characteristics

The YRW801-M samples were state-of-the-art for 1993 but sound dated by modern standards. Characteristics include:
- **12-bit resolution**: Good but not CD quality. A faint graininess is audible in quiet passages.
- **Short loop segments**: Most samples loop after 0.5–2 seconds. The repetition is audible on sustained notes.
- **Limited multisampling**: Most instruments use 2–4 velocity/pitch splits. Wide pitch-shifting produces noticeable timbre shifts.
- **Generous percussion**: The drum samples are a highlight — punchy, characterful, and well-looped.

For the MoonBlaster community, these limitations are part of the charm. The YRW801-M has a distinctive "sound" that is immediately recognizable to anyone who grew up with MoonSound or Yamaha DB50XG sound cards.

## End-to-End: What Happens When You Play a Note

Here is the complete sequence of events when the CPU triggers a PCM note, from register write to audio output:

**1. Channel Preparation**
```
Register 0x68+ch ← KEY=0    (stop any previous note; DAMP=1 for an immediate cut)
```

**2. Sample Selection**
```
Register 0x20+ch ← F-Num[6:0] << 1 | Wave[8]
Register 0x08+ch ← Wave[7:0]                    (loads the tone header)
```
Writing the wave number makes the hardware read the tone header for that wave. This tells it the sample format, start address, loop points, and default LFO/envelope settings.

**3. Pitch Configuration**
```
Register 0x38+ch ← Octave << 4 | PR << 3 | F-Num[9:7]
```
The address generator begins computing step increments based on F-Number and Octave.

**4. Volume and Envelope (optional overrides of the tone header)**
```
Register 0x50+ch ← TL << 1 | LD   (master volume)
Register 0x80+ch ← LFO | VIB      (LFO speed + vibrato depth)
Register 0x98+ch ← AR | D1R       (attack + initial decay)
Register 0xB0+ch ← DL | D2R       (sustain level + sustain decay)
Register 0xC8+ch ← RC | RR        (rate correction + release)
Register 0xE0+ch ← AM             (tremolo depth)
```

**5. Key On**
```
Register 0x68+ch ← KEY=1, DAMP=0, LFO reset, output channel, Pan
```
The envelope begins its Attack phase. The address generator starts stepping through sample memory. Each output sample period (every 22.7 µs at 44.1 kHz):

1. The address generator computes the current sample position
2. The memory controller fetches the sample byte(s) at that position
3. The interpolator blends between adjacent samples for smooth pitch shifting
4. The envelope generator applies the current attenuation level
5. The LFO modulates pitch (vibrato) and/or amplitude (tremolo)
6. The Total Level applies master attenuation
7. The panning circuit routes the result to left/right output channels
8. The mixer combines this channel's output with all other active channels and the FM engine's output

This entire pipeline operates for all 24 channels simultaneously, producing one stereo output sample every 22.7 µs.

**6. Key Off**
```
Register 0x68+ch ← KEY=0    (begin release phase)
```
The envelope transitions to the Release phase, decaying to silence at the RR rate. The sample continues playing during release, gradually fading out.

## See Also

- [PCM Registers](../registers/pcm-registers.md) — Complete PCM register reference
- [Memory Map](../architecture/memory-map.md) — Address space and wave table
- [Envelope](envelope.md) — Envelope generator details
- [FM Synthesis](fm-synthesis.md) — FM synthesis deep-dive
- [Block Diagram](../architecture/block-diagram.md) — Visual architecture
