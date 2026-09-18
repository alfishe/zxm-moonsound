# FM Synthesis

FM synthesis is the OPL4's heritage — a sound generation technique that Yamaha literally invented and refined across six generations of chips, from the original YM2151 (OPM) in 1983 to the YMF278B (OPL4) in 1994. Understanding how FM synthesis works is not just academic: it explains *why* OPL4 patches sound the way they do, why certain parameter changes produce dramatic timbral shifts while others seem to do nothing, and how composers like the MoonBlaster community achieved remarkably expressive music from what appears to be a handful of register values.

## What FM Synthesis Actually Is

Despite its name, FM synthesis as implemented in Yamaha chips is technically **phase modulation** (PM), not frequency modulation. The distinction matters for understanding the mathematics, though the sonic results are similar. In true FM, the modulator signal is added to the carrier's *frequency*. In Yamaha's PM, the modulator signal is added to the carrier's *phase angle*. The practical difference is that PM produces a symmetric spectrum (sidebands appear equally above and below the carrier frequency), while true FM produces an asymmetric one. Yamaha chose PM because it's simpler to implement in digital hardware and produces more musically useful spectra.

The fundamental equation for a single FM operator pair:

```
output(t) = A × sin(2π × fc × t + I × sin(2π × fm × t))
```

Where:
- `fc` = carrier frequency
- `fm` = modulator frequency
- `I` = modulation index (depth)
- `A` = carrier amplitude (envelope)

When the modulation index `I` is 0, the output is a pure sine wave at frequency `fc`. As `I` increases, sidebands appear at frequencies `fc ± n×fm` (where n = 1, 2, 3...), creating an increasingly complex spectrum. This is how FM synthesis produces its characteristic bright, metallic, evolving timbres — by controlling the modulation index over time through the envelope generators.

## The FM Operator

Every sound in the FM engine is built from **operators** — individual oscillators that each generate a waveform, shape it with an envelope, and either produce audio directly or modulate another operator. The OPL4 has 36 operators organized into 18 channels of 2 operators each (or fewer, larger channels when 4-op mode is enabled).

### Phase Generator

The phase generator is the operator's heartbeat. It maintains an internal phase accumulator that increments by a fixed amount every sample period. The increment amount is determined by three parameters:

```
Phase increment = F-Number × 2^(Block-1) × Multiplier / 2^20
```

- **F-Number** (10 bits): Fine pitch control within an octave. The full range 0–1023 spans one octave.
- **Block** (3 bits): Octave selector. Each increment doubles the frequency.
- **Multiplier** (4 bits): Scales the operator's frequency relative to the channel's base pitch.

The **Multiplier** is the key to FM timbral design. Setting the modulator's Multiplier to 1× (same frequency as the carrier) produces a harmonic series based on the fundamental. Setting it to 2× creates even-harmonic content (reminiscent of a clarinet or square wave). Setting it to 3× produces a bright, reedy tone. Non-integer ratios (like using the ×0.5 multiplier) create inharmonic spectra — bell-like or metallic sounds that don't belong to any harmonic series.

### Waveform Selection

The operator's phase angle is fed through a waveform lookup that converts it to an amplitude value. The OPL4 provides 8 waveform types:

```
Waveform 0 (Sine):           ╭─╮   ╭─╮
                             │  │   │  │
                         ────┤  ├───┤  ├───
                             │  │   │  │
                              ╰─╯   ╰─╯

Waveform 1 (Half-sine):      ╭─╮   ╭─╮
                             │  │   │  │
                         ────┤  ├───┤  ├───
                                         

Waveform 2 (Abs-sine):       ╭─╮╭─╮╭─╮╭─╮
                             │  ││  ││  ││  │
                         ────┤  ├┤  ├┤  ├┤  ├──

Waveform 3 (Quarter-sine):   ╭╮  ╭╮  ╭╮
                             ││  ││  ││
                         ────┤├──┤├──┤├───

Waveform 4 (Alt-sine):       ╭─╮       ╭─╮
                             │  │       │  │
                         ────┤  ├───────┤  ├───
                             │  │       │  │
                              ╰─╯       ╰─╯

Waveform 5 (Camel-sine):     ╭─╮╭─╮   ╭─╮╭─╮
                             │  ││  │   │  ││  │
                         ────┤  ├┤  ├───┤  ├┤  ├──

Waveform 6 (Square):        ┌───┐   ┌───┐
                             │   │   │   │
                         ────┤   ├───┤   ├───
                                 │       │
                                 └───┘   └───┘

Waveform 7 (Derived):        ╱╲     ╱╲
                             ╱  ╲   ╱  ╲
                         ───╱    ╲─╱    ╲──
```

**Waveform 0 (Sine)** is the default and by far the most commonly used. Pure FM synthesis between two sine waves produces clean, harmonically predictable spectra. Most MoonBlaster patches use sine for all operators.

**Waveform 6 (Square)** is notable for producing a hollow, clarinet-like tone when used as a carrier. As a modulator, it creates very harsh, buzzy modulation — useful for distorted guitar or aggressive synth bass sounds.

**Waveform 2 (Absolute-sine)** effectively doubles the operator's frequency (the negative half-cycle is flipped positive), which can be exploited to reach pitches above the normal F-Number/Block range.

### Envelope Generator

Each operator has its own 4-stage ADSR envelope that shapes its amplitude over time:

```
Level
  │ 
  │    ╱──────╲
  │   ╱        ╲──────────╲
  │  ╱ Attack   Decay      ╲  Release
  │ ╱                       ╲───────╲
  │╱         Sustain Level         ╲
  └────────────────────────────────────── Time
       │         │           │         │
     Key-On    Peak      Key-Off   Silence
```

The envelope does double duty depending on the operator's role:
- **On a carrier**: The envelope directly shapes the note's volume — this is the amplitude contour you hear.
- **On a modulator**: The envelope controls the *modulation depth* over time. A modulator with a fast attack and slow decay creates a sound that starts bright (high modulation = many harmonics) and gradually becomes purer (low modulation = fewer harmonics) — the characteristic "pluck" of many FM sounds.

This modulator-envelope behavior is the fundamental creative tool of FM synthesis. A piano sound, for example, uses a modulator with a fast attack and medium decay: the initial hammer strike generates a burst of harmonic energy (high modulation), which quickly fades to a simpler sustain tone (low modulation). The carrier's envelope independently controls the volume contour (fast attack, long sustain, gradual release).

## Channel Configurations

### 2-Operator Mode

In 2-op mode, each channel has exactly two operators that can be connected in two ways:

**FM Mode (CNT=0)**: Operator 1 (modulator) → Operator 2 (carrier)
```
         ┌──────────┐
    ┌───►│    OP1   │──┐
    │    │Modulator │  │  FM modulation
    │    └──────────┘  │
    │   (feedback)     ▼
    └─────────────  ┌──────────┐
                    │   OP2    │──► Audio Out
                    │ Carrier  │
                    └──────────┘
```

**Additive Mode (CNT=1)**: Both operators output audio independently
```
    ┌──────────┐
    │    OP1   │──► ┐
    └──────────┘    │
                    ├──► Audio Out (sum)
    ┌──────────┐    │
    │    OP2   │──► ┘
    └──────────┘
```

FM mode is the most musically useful configuration — it's where the "FM synthesis" magic happens. Additive mode is a fallback for when you need two independent tones from a single channel (a thin, organ-like sound with two harmonics).

### 4-Operator Mode

When enabled via register 0x104, two adjacent 2-op channels are merged into a single 4-op channel. The four operators can be connected in four different algorithms, each producing a fundamentally different character:

#### Algorithm 0: Full Serial (OP1→OP2→OP3→OP4)

```
OP1 → OP2 → OP3 → OP4 → Out
```

Three stages of FM modulation create the most harmonically complex output. Each modulation stage adds sidebands to the existing spectrum, producing dense, evolving timbres. Best for: electric piano (DX7-style), complex bells, metallic textures.

The serial chain means that OP1's influence is processed through three subsequent stages — its contribution is heavily transformed by the time it reaches the output. Small changes to OP1's parameters can produce dramatic timbral shifts.

#### Algorithm 1: OP1 + Serial Chain (OP1 + OP2→OP3→OP4)

```
OP1 ──────────────────┐
                      ├──► Out (sum)
OP2 → OP3 → OP4 ──────┘
```

A three-stage FM chain (OP2→OP3→OP4) summed with a lone carrier OP1. The chain provides the complex, evolving FM component while OP1 contributes a simple (or self-feedback) tone on top. Best for: layered sounds where a clean fundamental sits under a rich FM texture.

#### Algorithm 2: Parallel Pairs (OP1→OP2 + OP3→OP4)

```
OP1 → OP2 ──┐
             ├──► Out (sum)
OP3 → OP4 ──┘
```

Two independent 2-op FM chains summed together. This is functionally equivalent to playing two 2-op channels simultaneously on the same pitch, giving access to richer timbres by layering two different FM tones. Best for: thick unison patches, organ sounds, any timbre that benefits from additive layering.

#### Algorithm 3: OP1 + FM Pair + OP4 (OP1 + OP2→OP3 + OP4)

```
OP1 ────────┐
OP2 → OP3 ──┼──► Out (sum)
OP4 ────────┘
```

Three outputs summed: OP1 alone, the 2-op FM pair OP2→OP3, and OP4 alone. The most additive of the four algorithms — two plain carriers plus one modulated voice. Best for: organ-like tones and sounds that need independent control of several partials.

The algorithm number is `master CNT | slave CNT << 1` (see [FM Registers](../registers/fm-registers.md#register-0x104--4-op-channel-enable)).

## Feedback

Feedback is the FM operator's self-modulation circuit. When enabled on Operator 1, a fraction of OP1's output is fed back into its own phase input, creating a recursive modulation loop. This effectively turns a single operator into a harmonically rich source without needing a second operator.

The feedback level is controlled by a 3-bit value (0–7) in the channel's 0xC0 register. The modulation depth increases exponentially with the feedback value:

| FB Value | Modulation | Resulting Character |
|----------|-----------|-------------------|
| 0 | None | Pure waveform (sine if WS=0) |
| 1 | π/16 | Slight harmonic enrichment, subtle warmth |
| 2 | π/8 | Noticeable harmonics, slightly buzzy |
| 3 | π/4 | Moderate richness, string-like quality |
| 4 | π/2 | Strong harmonics, sawtooth-like character |
| 5 | π | Very rich spectrum, approaching noise |
| 6 | 2π | Near-chaotic, suitable for noise percussion |
| 7 | 4π | Fully chaotic, white-noise-like output |

Feedback is an essential component of many FM patches:
- **Bass sounds** typically use FB=3–4 on the modulator for a warm, rich character.
- **Brass sounds** use FB=5–6 for that characteristic bright, buzzy attack.
- **Snare and hi-hat** patches in rhythm mode rely on FB=7 for noise generation.
- **Clean pads** use FB=0–1 for smooth, mellow tones.

The CRYOGENT.MFM demo's lead patches use FB=7 on Operator 1 with both AM and VIB enabled — an aggressive configuration that produces the characteristically bright, edgy lead tones.

## Frequency and Pitch

The FM engine's pitch system uses two components: a 10-bit F-Number for fine tuning and a 3-bit Block for octave selection.

### F-Number to Note Mapping

Common F-Number values for musical notes (Block 4 ≈ middle octave):

| Note | F-Number | Note | F-Number |
|------|----------|------|----------|
| C | 343 | F# | 484 |
| C# | 363 | G | 513 |
| D | 385 | G# | 544 |
| D# | 408 | A | 577 |
| E | 432 | A# | 611 |
| F | 457 | B | 647 |

To play the same note in a different octave, keep the F-Number and change the Block. Block 4 is roughly the middle octave (around middle C). Block 0 is four octaves lower; Block 7 is three octaves higher.

### Vibrato

When the VIB bit is set in an operator's register 0x20, the FM engine applies a low-frequency periodic variation to the operator's phase, creating a pitch wobble. The vibrato depth is set globally via register 0xBD:

- **VIB Depth = 0**: ±7 cents (barely perceptible, useful for subtle animation)
- **VIB Depth = 1**: ±14 cents (noticeable, suitable for expressive vibrato)

The vibrato rate is fixed at approximately 6.1 Hz — a natural vibrato speed similar to what a singer or violinist would produce.

### Tremolo

Similarly, the AM bit applies an amplitude modulation (tremolo) effect:

- **AM Depth = 0**: 1 dB variation (subtle shimmer)
- **AM Depth = 1**: 4.8 dB variation (pronounced pulsation)

Tremolo shares the same oscillator as vibrato (6.1 Hz), so both effects pulse in sync when both are enabled. This can produce very expressive tones — the combination of pitch and volume wobble mimics the natural instability of a human voice or bowed string.

## Rhythm / Percussion Mode

The OPL4 can dedicate channels 6–8 to five hardware percussion instruments, each using specialized signal-processing circuits that can't be replicated with standard FM algorithms:

### Bass Drum (2 operators)
Uses channels 6's OP1 and OP2 in normal FM configuration. The frequency and envelope create a punchy, resonant kick. The carrier's frequency sets the fundamental pitch; the modulator adds harmonic "click" to the attack.

### Snare Drum (1 operator)
Uses channel 7's OP2 with a noise generator mixed into the phase. The operator's frequency sets the resonant pitch of the snare body, while the noise component provides the "snare wire" character. Higher frequencies produce a tighter, more metallic snare.

### Tom-Tom (1 operator)
Uses channel 8's OP1. A simple single-operator percussive tone — the frequency directly sets the pitch. Without the noise generator, it produces a clean, tonal drum sound.

### Cymbal (1 operator)
Uses channel 8's OP2 with a phase-modulation ring-mod circuit that creates metallic, inharmonic spectra. The frequency affects the spectral density of the cymbal — higher frequencies produce a brighter, more "splashy" cymbal.

### Hi-Hat (1 operator)
Uses channel 7's OP1 with the same ring-mod circuit as the cymbal but typically at a higher frequency and with a shorter envelope. The shared circuit between hi-hat and cymbal creates a natural timbral relationship between the two — they sound like they belong to the same kit.

## Practical Patch Design

Building an FM patch from scratch follows a consistent workflow:

1. **Start with the carrier**: Set OP2 to sine (WS=0), moderate TL (around 20–30), and a natural envelope (AR=12, DR=6, SL=3, RR=6). You should hear a clean sine tone.

2. **Add the modulator**: Set OP1's frequency multiplier to choose the harmonic relationship (MULT=1 for fundamental, 2 for octave). Start with a high TL (40+) for subtle modulation and gradually lower it to hear the spectrum fill out.

3. **Shape the modulator's envelope**: A fast AR on the modulator with a slower DR creates the classic "bright attack, mellow sustain" FM sound. A slow AR creates an inverse effect — the sound starts pure and becomes brighter over time (a "reversed" character useful for pads).

4. **Add feedback**: Start at FB=0 and increment until the desired richness is achieved. Each step adds noticeable harmonic content.

5. **Experiment with waveforms**: Try non-sine waveforms on the modulator for radically different spectra. Square-wave modulation (WS=6) produces a distinctly different harmonic series than sine modulation.

6. **Fine-tune with Key Scale**: Enable KSR on the modulator so higher notes have shorter modulation envelopes, mimicking natural instrument behavior. Add KSL to reduce volume for high notes.

## See Also

- [FM Registers](../registers/fm-registers.md) — Complete FM register reference
- [Envelope](envelope.md) — Envelope generator details
- [PCM Synthesis](pcm-synthesis.md) — PCM/wavetable synthesis
- [Block Diagram](../architecture/block-diagram.md) — Visual architecture
