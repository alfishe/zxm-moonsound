# Envelope Generators

The envelope generator is the component that breathes life into synthesized sound. Without it, every note would be a flat, unchanging tone that starts and stops abruptly. The envelope shapes a note's volume over time — creating the sharp attack of a piano hammer, the gradual swell of a violin bow, the slow fade of a reverberating bell. The OPL4 contains two different envelope systems: a **4-stage ADSR** for the FM engine and a **6-stage extended envelope** for the PCM engine. Understanding both — and knowing when each matters — is essential for programming expressive patches and for implementing an accurate emulator.

## FM Envelope (4-Stage ADSR)

The FM engine uses a classic Attack-Decay-Sustain-Release envelope, inherited from the OPL2/OPL3 lineage. Each of the 36 FM operators has its own independent envelope generator.

### State Machine

```
Level (dB)
0 dB ─────────╮
              │╲  Decay
       Attack │ ╲──────────────────────────╮
              │                  SL (dB)   │
              │  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤╲  Release
              │         Sustain            │ ╲
              │                            │  ╲
              │                            │   ╲
−96 dB ───────┴────────────────────────────┴────╲─────
              │         │                  │         │
           Key On     Peak              Key Off   Silence
```

### Stages

**Attack (AR)**: The envelope rises from silence (−96 dB) to maximum level (0 dB). The Attack Rate (4 bits, 0–15) determines the speed:

| AR | Approximate Time |
|----|-----------------|
| 0 | Infinite (no attack — operator stays silent) |
| 1 | ~8.5 seconds |
| 4 | ~1 second |
| 8 | ~50 ms |
| 12 | ~4 ms |
| 15 | Instantaneous (<1 ms) |

These times are approximate and depend on Key Scale Rate (KSR) settings.

**Decay (DR)**: After reaching maximum level, the envelope decays toward the Sustain Level. The Decay Rate (4 bits, 0–15) controls the speed. At DR=0, there is no decay — the level holds at maximum.

**Sustain (SL)**: The level at which the decay phase ends. This is specified as **attenuation** (0 = no attenuation = full volume, 15 = maximum attenuation ≈ −45 dB). When the EG type bit (register 0x20, bit 5) is set:
- **EG=1 (Sustain)**: The envelope holds at the sustain level until Key Off. This is the normal behavior for sustained instruments like organ, strings, and brass.
- **EG=0 (Decay to zero)**: The envelope continues decaying past the sustain level to silence, regardless of whether the key is held. This creates a fully percussive envelope suitable for drums, piano, and plucked instruments.

**Release (RR)**: When the key is released, the envelope decays from its current level to silence. The Release Rate (4 bits, 0–15) controls the speed. Fast release (RR=12–15) gives staccato articulation; slow release (RR=1–4) provides legato fade-outs.

### The Dual Role of FM Envelopes

On a **carrier** operator, the envelope directly controls the note's audible volume contour. This is the familiar ADSR shape that musicians know from analog synthesizers.

On a **modulator** operator, the envelope controls the **modulation depth** — the intensity of FM modulation applied to the carrier. This is less intuitive but enormously powerful:

```
Modulator envelope high → Strong modulation → Bright, harmonically rich sound
Modulator envelope low  → Weak modulation   → Dark, simple sound
```

By giving the modulator a fast attack and slow decay, you create a sound that starts bright and gradually becomes darker — the signature "FM pluck" used in countless patches for piano, marimba, and electric bass. The carrier's envelope independently controls the overall volume, so you can have a note that starts bright and loud, fades to dark and quiet, then releases smoothly.

## PCM Envelope (6-Stage)

The PCM engine uses an extended 6-stage envelope designed specifically for realistic instrument emulation. The key innovation over the FM's 4-stage ADSR is the **split decay** — two separate decay rates with a configurable breakpoint — which allows natural two-phase volume contours that a single decay rate cannot achieve.

### State Machine

```
Level (dB)
0 dB ─────────╮
              │╲  D1R (fast)
       Attack │ ╲
              │  ╲─────────────── DL (breakpoint)
              │   ╲╲  D2R (slow)
              │    ╲╲──────────────────────────╮
              │     ╲╲                         │╲  RR
              │      ╲╲     Sustain (D2R)      │ ╲
              │       ╲                        │  ╲
−96 dB ───────┴────────────────────────────────┴────╲─────
              │      │     │                   │         │
           Key On  Peak  DL reached         Key Off   Silence
```

### Stages

**Attack (AR)**: Identical in concept to the FM Attack — the level rises from silence to maximum. The 4-bit AR value (0–15) controls the speed, with 0 meaning no attack and 15 meaning instantaneous.

**Decay 1 (D1R)**: The first decay phase begins immediately after the attack peak. This represents the **initial transient decay** — the rapid volume drop after a percussive onset. A piano hammer's impact, a plucked guitar's initial ring, or a brass tonguing attack all fade quickly from their peak into a more moderate sustain.

**Decay Level (DL)**: The volume level at which the envelope transitions from D1R to D2R. This 4-bit value (0–15) sets the breakpoint:

| DL | Approximate Level |
|----|------------------|
| 0 | 0 dB (maximum — effectively no D1R phase) |
| 1 | −3 dB |
| 2 | −6 dB |
| 3 | −9 dB |
| ... | ... |
| 14 | −42 dB |
| 15 | −∞ (silence — D1R decays all the way to zero) |

DL is the critical parameter that defines the "shape" of the two-phase decay. For a piano, DL might be set to 3–5 (the sustain is noticeably quieter than the initial impact). For an organ, DL=0 (no initial decay at all — the sustain is as loud as the attack).

**Decay 2 (D2R)**: The second decay phase handles the **sustain decay** — the gradual fade of a held note. This is typically much slower than D1R. When D2R=0, the note holds indefinitely at the Decay Level (true sustain). Non-zero D2R values create a gradual fade:

- D2R=1: Very slow fade (tens of seconds)
- D2R=4–6: Medium fade (a few seconds, suitable for piano sustain)
- D2R=15: Rapid fade (the note dies quickly even while held)

**Release (RR)**: When the key is released, the envelope decays from its current level to silence at the Release Rate. This operates identically to the FM release phase. RR=0 means the note continues indefinitely after key-off (rare but possible); RR=15 provides near-instantaneous cutoff.

**Rate Correction (RC)**: This is not a stage but a scaling factor that adjusts **all envelope rates** based on the note's pitch. Higher-pitched notes naturally decay faster in real instruments (shorter strings, smaller resonators), and RC automates this behavior:

| RC | Effect |
|----|--------|
| 0 | No correction — all pitches have identical envelope timing |
| 1–14 | Increasing pitch-dependent rate scaling |
| 15 | Maximum correction — high notes decay much faster than low notes |

With RC>0, a high C will have a noticeably shorter attack and decay than a low C, even with identical AR/D1R/D2R/RR settings. This single parameter eliminates the need to program different envelope settings for each pitch range, which would be impractical on a 24-channel engine.

### The Damp Function

The Damp bit (register 0x68, bit 6) provides a special rapid-mute capability that overrides the normal envelope progression. When DAMP=1:

1. The envelope level drops to silence at a rate faster than any Release Rate
2. The channel effectively silences within a few sample periods (~50–100 µs)
3. The channel is then ready for immediate reassignment to a new note

Damp exists to solve the **note-stealing problem**: when all 24 channels are in use and a new note must play, one channel must be quickly silenced and reassigned. Without Damp, the channel would need to go through its Release phase (which could take hundreds of milliseconds), creating an audible overlap between the old and new notes. Damp forces immediate silence, allowing clean reassignment.

The typical note-stealing sequence is:
```
1. Write DAMP=1 to the victim channel
2. Wait a few microseconds (or one Z80 instruction cycle)
3. Write new wave number, frequency, and envelope parameters
4. Write KEY=1 with DAMP=0 to start the new note
```

## Rate Calculation

Both FM and PCM envelopes use the same underlying rate calculation engine. The effective rate determines how quickly the envelope level changes per sample period.

### Base Rate

The envelope generator works in **attenuation units** (0 = full volume, 511 = silence for FM, or similar scale for PCM). Each rate value (4-bit, 0–15) maps to a base speed at which the attenuation counter increments or decrements:

| Rate | Approximate Speed |
|------|------------------|
| 0 | No change (infinite time) |
| 1–4 | Very slow (seconds to tens of seconds) |
| 5–8 | Moderate (hundreds of milliseconds) |
| 9–12 | Fast (tens of milliseconds) |
| 13–14 | Very fast (milliseconds) |
| 15 | Maximum (near-instantaneous) |

### Key Scale Rate (KSR) — FM

When the KSR bit is set in an FM operator's register 0x20, the effective rate is scaled by the note's pitch. The scaling factor is derived from the Block (octave) and the top bit(s) of the F-Number:

```
Effective rate = Base rate + (key_scale_value >> (3 - KSR_bit))
```

This means higher-pitched notes have faster envelopes when KSR=1. The practical effect is most noticeable on decay and release rates: a high piano note decays much faster than a low one, which matches real piano behavior.

### Rate Correction (RC) — PCM

The PCM engine's Rate Correction serves the same purpose as KSR but with finer control. The 4-bit RC value (0–15) determines how aggressively pitch affects envelope rates:

```
Effective rate = Base rate + (octave × RC) / scaling_factor
```

Higher RC values produce more aggressive pitch-dependent scaling. RC=0 disables the correction entirely, making all pitches behave identically.

## Comparing FM and PCM Envelopes

| Feature | FM (4-Stage) | PCM (6-Stage) |
|---------|-------------|---------------|
| **Stages** | Attack, Decay, Sustain, Release | Attack, D1R, DL, D2R, RC, Release |
| **Decay phases** | 1 (single decay rate) | 2 (D1R fast + D2R slow, with DL breakpoint) |
| **Sustain** | Configurable via EG bit | Always sustains at DL (D2R=0) or fades (D2R>0) |
| **Pitch scaling** | KSR bit (on/off) | RC value (0–15, continuous control) |
| **Rapid mute** | No direct equivalent | DAMP function |
| **Per-operator** | Yes (36 independent envelopes) | Per-channel (24 envelopes) |
| **Total Level** | 6-bit (64 steps, 0.75 dB) | 7-bit (128 steps, 0.375 dB) |

### When Each Matters

The FM envelope's simplicity is actually an advantage for FM synthesis. Because the modulator's envelope controls *modulation depth* rather than audible volume, the musical meaning of each stage is different from what ADSR means on a subtractive synthesizer. A fast modulator decay creates the classic "FM pluck" — you don't need two decay phases for this because the single decay rate maps directly to the timbral evolution you want.

The PCM envelope's complexity is necessary because it controls the *volume* of a recorded sample, and real instruments have two-phase volume contours. Consider a piano note:

```
Real piano:     ╱╲───────────────────────────╲
               ╱  ╲   Slow sustain decay      ╲
              ╱    ╲──────────────────────────  ╲  Release
             ╱ Fast initial                      ╲
            ╱  decay                              ╲
           ╱                                       ╲
          ╱                                         ╲
```

A 4-stage ADSR can only approximate this with a single decay rate — it can get the initial decay right (fast) or the sustain decay right (slow), but not both simultaneously. The PCM envelope's D1R/DL/D2R split handles this naturally: D1R captures the fast initial decay, DL sets the level where the slow sustain begins, and D2R provides the gentle sustain fade.

## Total Level

Both engines have a **Total Level** control that sets the channel's (or operator's) master attenuation, independent of the envelope. The envelope shapes the *contour*; Total Level sets the *ceiling*.

### FM Total Level
- 6-bit (0–63)
- 0.75 dB per step
- Range: 0 dB (TL=0) to −47.25 dB (TL=63)
- Per-operator (modulator TL = modulation depth, carrier TL = volume)

### PCM Total Level
- 7-bit (0–127)
- ~0.375 dB per step
- Range: 0 dB (TL=0) to approximately −47.6 dB (TL=127)
- Per-channel (controls final output volume)
- **Level Direct (LD)** bit controls whether TL changes are applied immediately (LD=1) or smoothly interpolated (LD=0)

The PCM's LD bit is a practical concern for real-time volume changes during music playback. With LD=0, changing TL mid-note produces a smooth volume transition without clicks. With LD=1, the change is instantaneous — useful for sound effects or when the TL change coincides with a new note onset.

## Emulation Considerations

Envelope generation is one of the most critical aspects of OPL4 emulation accuracy. The ValleyBell fixes for VGMPlay specifically addressed envelope bugs that caused audible problems in real music:

### Known Pitfalls

1. **Attack phase non-linearity**: The OPL4's attack phase does not rise linearly. It uses an exponential curve that starts slow, accelerates, and then levels off near the peak. Emulating this as a linear ramp produces attacks that sound "wrong" — too sharp at the beginning and too rounded at the peak.

2. **Decay/Release rate tables**: The mapping from 4-bit rate values to actual attenuation-per-sample amounts is not a simple formula. The OPL4 uses internal lookup tables that include quantized rate values and cycle-dependent stepping patterns. The ymfm library implements these tables accurately; simpler emulators often approximate them.

3. **Key-on restart behavior**: When a Key-On is received while a note is already sounding (re-triggering), the envelope restarts from the Attack phase at the *current* attenuation level, not from silence. This means a re-triggered note during its sustain phase will have a shorter attack than a note triggered from silence, because it has less distance to travel to reach maximum level.

4. **Damp timing**: The Damp function must silence the channel within a well-defined time window. Too slow, and note-stealing produces overlapping artifacts. Too fast, and channels that are damped and immediately re-triggered may not fully reset.

5. **Rate Correction interaction**: The RC value's interaction with the octave register must be computed correctly, especially at extreme pitches. Some emulators miscalculate the effective rate for very high or very low octave values, producing envelopes that are too fast or too slow at pitch extremes.

## See Also

- [FM Synthesis](fm-synthesis.md) — FM synthesis theory and operator architecture
- [PCM Synthesis](pcm-synthesis.md) — PCM/wavetable synthesis details
- [FM Registers](../registers/fm-registers.md) — FM envelope register reference
- [PCM Registers](../registers/pcm-registers.md) — PCM envelope register reference
