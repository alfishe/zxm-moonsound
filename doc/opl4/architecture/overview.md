# OPL4 Architecture Overview

By 1994, the "wavetable wars" were in full swing. Creative Labs had launched the Sound Blaster AWE32, Roland was pushing its GM-compatible Sound Canvas modules, and Gravis had shaken up the market with its affordable UltraSound. Every sound card manufacturer was racing to deliver General MIDI-compatible wavetable synthesis. Yamaha's answer was the **YMF278B** — internally designated **OPL4** — a chip that took an audacious approach: rather than abandoning FM synthesis for the fashionable sample-based sound, it integrated a complete OPL3-compatible FM engine alongside a 24-channel PCM synthesizer on a single die.

This was not a compromise. It was an acknowledgement that FM synthesis — which Yamaha had pioneered with the DX7 and perfected through six generations of OPL chips — still had unique strengths. Certain timbres, particularly bright metallic sounds, searing leads, and the characteristic "that sounds like a Sega Genesis" aesthetic, are native to FM and difficult to reproduce convincingly with short sample loops. By combining both engines, the OPL4 gave composers and programmers access to **42 simultaneous voices** (18 FM + 24 PCM), a capability that no single competing chip could match.

## Chip Identification

| Parameter | Value |
|-----------|-------|
| Manufacturer | Yamaha |
| Part Number | YMF278B |
| Package | 80-pin QFP |
| Technology | CMOS |
| Year | 1994 |

The "B" suffix in YMF278B denotes the production revision. Earlier YMF278 variants existed in limited quantities; the B revision is the version found in all commercial products including MoonSound cartridges and PC sound cards.

## Functional Blocks

The YMF278B integrates three major subsystems onto a single die, each operating semi-independently but sharing a common register interface and output mixer. Understanding how these blocks divide responsibility is essential for both programming and emulation.

### 1. FM Synthesizer (OPL3-compatible)

The FM section is a complete, register-compatible replica of Yamaha's YMF262 (OPL3). Programs written for the OPL3 — from DOS games to MSX-MUSIC software — run without modification. The FM engine provides:

- **18 channels** in 2-operator mode
- **6 channels** in 4-operator mode (plus 6 remaining 2-op)
- **36 operators** total (2 per channel × 18)
- **8 waveforms** per operator
- **Stereo output** with per-channel panning

Four-operator mode is the OPL3's signature feature: by chaining pairs of 2-op channels into 4-op units, the FM engine can produce far richer timbres. The trade-off is straightforward — enabling a 4-op channel consumes two channel slots, reducing the polyphony from 18 to as few as 15 voices (6 four-op + 6 two-op). The MoonBlaster player exploits this extensively: the CRYOGENT demo, for instance, runs all six possible 4-op chains simultaneously, using them for rich drum beds while reserving three 2-op channels for lead melodies.

### 2. PCM/Wavetable Synthesizer

The PCM section provides General MIDI-compatible wavetable synthesis. Where the FM engine generates sound algorithmically from sine-wave operators, the PCM engine plays back digital audio samples stored in external ROM or RAM, pitch-shifting and enveloping them in real time. This is the technology that made the Sound Blaster AWE32 and Roland Sound Canvas famous — and the OPL4 implements it alongside FM rather than instead of it.

- **24 independent channels**
- **12-bit and 16-bit** sample playback
- **6-stage envelope** (AR, D1R, DL, D2R, RC, RR)
- **LFO** with vibrato and tremolo
- **Stereo panning** (16 positions)
- **Pseudo-reverb** effect

The 6-stage PCM envelope is notably more sophisticated than the FM section's 4-stage ADSR. The additional Decay Level (DL) parameter creates a two-phase decay: D1R controls the initial rapid decay (the percussive "attack" fading), while D2R handles the slow sustain decay. This two-phase approach is critical for realistic piano and string emulation, where the initial hammer strike fades quickly into a gentle sustain that lingers. The Rate Correction (RC) parameter further refines this by allowing higher-pitched notes to decay faster, mimicking the natural behavior of acoustic instruments where shorter strings lose energy more quickly.

### 3. Memory Controller

The memory controller manages sample memory access, handling the constant stream of fetch requests from the 24 PCM channels while also providing a CPU access path for uploading custom samples to RAM. This arbitration is transparent to the programmer — the CPU writes sample data through a pair of registers, and the memory controller interleaves these writes between the PCM engine's read cycles.

- **2MB ROM** interface (YRW801-M wavetable)
- **Up to 2MB RAM** for user samples (mapped from 0x200000, above the ROM)
- **22-bit address bus** (4MB addressable)
- **DMA-like access** for CPU sample upload

The YRW801-M ROM contains 384 General MIDI-compatible instrument samples (waveforms plus tone headers) that provide a baseline sound set without any user intervention. The RAM interface extends this with up to 2MB of user-supplied samples — enough for custom drum kits, vocal samples, or entirely bespoke instrument libraries. On the ZXM-MoonSound, 1MB of SRAM provides a practical balance between capacity and cost.

## Signal Flow

The following diagram traces how data flows from the CPU through the chip to the audio output. Understanding this path is the key to understanding OPL4 programming: every register write ultimately affects some point in this chain.

```
                    ┌─────────────────────────────────────────┐
                    │              YMF278B (OPL4)             │
                    │                                         │
   ┌────────────┐   │   ┌───────────┐      ┌───────────┐     │   ┌────────┐
   │  CPU Bus   │───┼──►│ Register  │─────►│    FM     │─────┼──►│        │
   │  (Z80)     │   │   │  File     │      │ Synthesis │     │   │  DAC   │
   └────────────┘   │   └───────────┘      └───────────┘     │   │YAC513  │
                    │         │                  │           │   │        │
                    │         │            ┌─────┴─────┐     │   │  L/R   │
                    │         │            │   Mixer   │─────┼──►│ Audio  │
                    │         │            └─────┬─────┘     │   │  Out   │
                    │         │                  │           │   └────────┘
                    │         ▼            ┌─────┴─────┐     │
                    │   ┌───────────┐      │    PCM    │     │
   ┌────────────┐   │   │  Memory   │─────►│ Synthesis │─────┘
   │Sample ROM  │───┼──►│Controller │      └───────────┘
   │ (YRW801)   │   │   └───────────┘
   └────────────┘   │         ▲
                    │         │
   ┌────────────┐   │         │
   │Sample RAM  │───┼─────────┘
   │ (SRAM)     │   │
   └────────────┘   │
                    └─────────────────────────────────────────┘
```

The CPU communicates with the OPL4 through six I/O ports (three address/data pairs). Register writes are latched into the register file, which feeds configuration to both synthesis engines. The FM engine generates sound purely from its internal operator pipeline — it needs no external memory. The PCM engine, by contrast, continuously fetches sample data from ROM/RAM through the memory controller. Both engines' outputs are mixed internally and sent to the external YAC513 DAC as a stereo pair.

The mixer stage is simple but important: registers 0xF8 and 0xF9 control the relative levels of FM and PCM in the final mix. This allows the programmer to balance the two engines' contributions, or to mute one entirely. Note that MoonBlaster `.MFM` songs are not FM-only: besides the 18 FM channels their patterns drive 6 PCM wave tracks, so both engines contribute to the mix.

## Clock System

| Clock | Frequency | Derived From |
|-------|-----------|--------------| 
| Master | 33.8688 MHz | External crystal |
| FM | 49.516 kHz | Master ÷ 684 |
| PCM | 44.1 kHz | Master ÷ 768 |

The master clock frequency of 33.8688 MHz is not arbitrary — it is exactly **768 × 44,100 Hz**, chosen specifically so that the PCM engine can derive a clean 44.1 kHz sample rate (CD quality) through integer division. The FM engine runs at 33.8688 MHz ÷ 684 ≈ 49.516 kHz, close to (but not exactly) the 49.716 kHz of an OPL3 on its usual 14.318 MHz clock, so OPL3 F-Numbers play about 7 cents flat on OPL4.

The different sample rates of the FM and PCM engines mean the internal mixer must handle resampling. In practice, the OPL4 runs its output at the PCM rate (44.1 kHz) and the FM output is resampled to match. This is a subtle but important detail for emulator authors: the FM engine's time base is *not* the output sample rate, and naive sample-per-sample generation will introduce timing drift. The ymfm library handles this by computing FM output at the FM rate and resampling to the output rate.

## Key Specifications

### FM Section

| Parameter | Value |
|-----------|-------|
| Channels | 18 (2-op) or 6+6 (4-op + 2-op) |
| Operators per channel | 2 or 4 |
| Waveforms | 8 (sine, half-sine, abs-sine, pulse, etc.) |
| Envelope stages | 4 (Attack, Decay, Sustain, Release) |
| Frequency resolution | 10-bit F-number + 3-bit block |
| Output | 16-bit stereo |

The 10-bit F-number combined with 3-bit block gives the FM engine a frequency range spanning approximately 0.047 Hz to 6208 Hz in fundamental frequency. The "block" (also called octave) acts as a power-of-two multiplier, while the F-number provides fine pitch resolution within each octave. Each operator also has a frequency multiplier (0.5×, 1× through 15×) that further extends the harmonic range.

### PCM Section

| Parameter | Value |
|-----------|-------|
| Channels | 24 |
| Sample formats | 8-bit, 12-bit, 16-bit |
| Sample rate | 44.1 kHz playback |
| Envelope stages | 6 (AR, D1R, DL, D2R, RC, RR) |
| LFO | 8 speed settings |
| Vibrato depth | 8 levels |
| Tremolo depth | 8 levels |
| Pan positions | 16 |
| Output | 16-bit stereo |

The 12-bit sample format is unique to the OPL4 family and is used by the YRW801-M ROM samples. It stores each sample as a 12-bit value packed into 1.5 bytes (two samples per 3 bytes), providing a reasonable quality-to-storage trade-off that was important when ROM space was expensive. The 16-bit format provides full CD-quality resolution for user samples loaded into RAM.

### Memory

| Parameter | Value |
|-----------|-------|
| Address bus | 22-bit (4MB) |
| ROM capacity | 2MB (YRW801-M) |
| RAM capacity | Up to 2MB (alongside the ROM) |
| Wave table entries | 512 ROM + RAM samples |

The 22-bit address bus provides a 4MB total address space. The 2MB ROM occupies the bottom half (0x000000–0x1FFFFF) and RAM starts at 0x200000. On the ZXM-MoonSound, the 1MB SRAM occupies 0x200000–0x2FFFFF. Register 0x02 tells the chip to read the tone headers of wave numbers 384+ from RAM; this memory map is critical for correct sample playback — an incorrectly configured memory map will cause the PCM engine to fetch garbage data.

## Compatibility

The OPL4 maintains a carefully engineered compatibility chain with Yamaha's earlier FM chips. This backward compatibility was commercially essential — it meant that any software written for earlier OPL chips could run on OPL4 hardware without modification:

| Chip | Compatibility |
|------|---------------|
| YM3812 (OPL2) | Full (9 channels, 2-op) |
| YMF262 (OPL3) | Full (18 channels, 4-op support) |
| YM2413 (OPLL) | Register mapping differs |

The OPL2 compatibility means the chip can play any AdLib-era DOS game. The OPL3 compatibility extends this to the entire library of Sound Blaster Pro-era software. The OPLL (used in MSX-MUSIC) uses a different register layout and is *not* register-compatible, though the underlying synthesis is similar. Software targeting MSX-MUSIC must be rewritten to use OPL4's register scheme.

## ZXM-MoonSound Implementation

The ZXM-MoonSound ZX-BUS card adapts the OPL4 to the ZX Spectrum ecosystem. The design, by Mick (Максов И.Н.), makes several pragmatic engineering choices worth understanding:

- **YMF278B** OPL4 sound chip
- **YRW801-M** 2MB sample ROM
- **1MB SRAM** for user samples
- **YAC513** stereo DAC
- **EPM7032STC44** CPLD for bus interface
- **AM29F016D** flash for ROM storage

The **EPM7032STC44** CPLD handles the critical task of translating between the ZX Bus signals and the OPL4's native bus interface. The ZX Spectrum's Z80 uses a different I/O timing and address decoding scheme than the MSX systems the OPL4 was designed for, so the CPLD implements the necessary glue logic: address decoding for the six I/O ports (0xC4–0xC7 and 0x7E–0x7F), wait-state generation to meet the OPL4's timing requirements, and bus direction control.

The **AM29F016D** flash ROM is used instead of a mask-programmed YRW801-M ROM. This allows the sample ROM contents to be updated in the field — the Revision 01 board can be reprogrammed directly through the YMF278B's memory interface using the MoonService utility, eliminating the need for an external flash programmer. The ROM image is the standard YRW801-M General MIDI wavetable set, containing 384 instrument samples suitable for MoonBlaster Wave playback.

The **YAC513** is Yamaha's companion DAC for the OPL4, providing 16-bit stereo conversion at up to 50 kHz. It accepts the OPL4's serial digital output and produces line-level analog audio. The ZXM-MoonSound routes this to three output options: a 3.5mm headphone jack, dual RCA connectors, and a 4-pin header for internal connection to a mixer or amplifier.

## See Also

- [Block Diagram](block-diagram.md) — Detailed internal architecture with Mermaid diagrams
- [Memory Map](memory-map.md) — Address space organization and wave table structure
- [FM Registers](../registers/fm-registers.md) — FM register reference
- [PCM Registers](../registers/pcm-registers.md) — PCM register reference
