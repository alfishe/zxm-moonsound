# Global Registers Reference

The OPL4's global registers are the control plane for the entire chip — they handle initialization, timing, IRQ management, and the operational mode switches that determine whether the chip behaves as an OPL2, OPL3, or full OPL4. Getting the initialization sequence right is one of the most critical tasks for any OPL4 driver or emulator, because the chip powers up in OPL2 compatibility mode and must be explicitly unlocked to access its full capabilities.

## Power-On State

After a hardware reset, the OPL4 starts in its most restrictive mode:

| Feature | Power-On Default | Required Setting |
|---------|-----------------|-----------------|
| Mode | OPL2 (9 channels, mono) | NEW=1 for OPL3/OPL4 mode |
| Waveforms | Sine only (WS=0) | WS=1 for all 8 waveforms |
| Timers | Stopped | Configure as needed |
| IRQ flags | Clear | Clear with IRQ Reset |
| FM channels | All silent (TL=63, KEY=0) | Configure per voice |
| PCM channels | All silent (KEY=0) | Configure per voice |
| Mix levels | FM and PCM at default | Set via 0xF8/0xF9 |

This conservative default ensures backward compatibility: legacy OPL2 software sees exactly what it expects. The unlock sequence is intentionally multi-step to prevent accidental mode changes from stray register writes.

## The OPL4 Boot Sequence

Every OPL4 driver and emulator must execute this initialization sequence before using the chip's full capabilities. The order matters — certain registers gate access to others:

### Step 1: Enable OPL3 Mode (Register 0x05 via Bank 2)

```
Port 0xC6 ← 0x05    (select register 0x05 in Bank 2)
Port 0xC7 ← 0x03    (set NEW=1 and NEW2=1)
```

This is the master unlock. Both MoonBlaster players and Furnace write 0x03: NEW (bit 0) enables OPL3 mode and NEW2 (bit 1) enables the OPL4 features. Without NEW=1, the chip ignores all OPL3-specific features: stereo panning in register 0xC0, channels 9–17, 4-op mode, and waveforms 4–7 are all inaccessible.

**Critical detail**: Register 0x05 is addressed through Bank 2 (port 0xC6/0xC7), not Bank 1. This catches many first-time programmers — writing 0x05 through Bank 1 targets a completely different register (the reserved area) and has no effect.

### Step 2: Enable Extended Waveforms (Register 0x01 via Bank 1)

```
Port 0xC4 ← 0x01    (select register 0x01 in Bank 1)
Port 0xC5 ← 0x20    (set WS=1, test bits=0)
```

With WS=1, operators can use all 8 waveforms (0–7) via register 0xE0. Without this, every operator produces a sine wave regardless of its waveform select setting. This bit exists because the original OPL2 had no waveform selection — the feature was added in OPL2 and controlled by this enable bit for compatibility.

### Step 3: Clear IRQ Flags (Register 0x04 via Bank 1)

```
Port 0xC4 ← 0x04    (select register 0x04)
Port 0xC5 ← 0x80    (set IRQ Reset=1)
```

This clears any pending timer flags from power-on transients. After this write, the status register should read 0x00 (no flags set). If it doesn't, the chip may not be present or may be malfunctioning.

### Step 4: Configure Timers (Optional)

```
Port 0xC4 ← 0x04
Port 0xC5 ← 0x00    (stop timers, clear masks)
```

If timers are not needed (the MoonBlaster player on ZX Spectrum uses system VBI instead), simply ensure they're stopped.

### Step 5: Silence All Channels

For a clean start, zero out all operator and channel registers:

```
For each operator slot (0x00-0x15 in both banks):
  Register 0x40+slot ← 0x3F    (TL = maximum attenuation)
  Register 0x60+slot ← 0x00    (AR=0, DR=0)
  Register 0x80+slot ← 0x0F    (SL=0, RR=max for fast release)

For each channel (0-8 in Bank 1, 0-8 in Bank 2):
  Register 0xB0+ch ← 0x00      (KEY=0, Block=0, F-Num=0)
  Register 0xC0+ch ← 0x30      (L=1, R=1, FB=0, CNT=0)
```

### Step 6: Configure PCM Memory Type (Register 0x02 via Wave port)

```
Port 0x7E ← 0x02    (select Wave register 0x02)
Port 0x7F ← 0x10    (wave table header base = 0x200000 for waves 384+)
```

This is the value both MoonBlaster players and Furnace write: bits 4:2 = 4 place the tone headers for wave numbers 384–511 at the start of sample RAM (0x200000), while waves 0–383 keep using the ROM's header table. See [PCM Registers](pcm-registers.md#register-0x02--memory-access-mode--wave-table-header-base). Getting this wrong causes the PCM engine to fetch samples from wrong addresses, producing garbage audio.

### Step 7: Set Mix Levels (Registers 0xF8, 0xF9 via Wave port)

```
Port 0x7E ← 0xF8    Port 0x7F ← 0x00    (FM at full volume, both sides)
Port 0x7E ← 0xF9    Port 0x7F ← 0x00    (PCM at full volume, both sides)
```

Each mix register holds two 3-bit attenuation fields (left in bits 2:0, right in bits 5:3). For songs that use no PCM at all, the PCM mix can be turned down on both sides:

```
Port 0x7E ← 0xF9    Port 0x7F ← 0x3F    (PCM at minimum level)
```

(Note that `.MFM` songs are not FM-only — they carry 6 PCM wave tracks.)

## Timer System

The OPL4 provides two independent programmable timers inherited from the OPL2. These timers can generate periodic interrupts, serving as the timing backbone for music playback software that doesn't have access to a system-level timer.

### Timer 1 (Register 0x02)

| Parameter | Value |
|-----------|-------|
| Clock source | Master ÷ 288 = 117.5 kHz |
| Counter | 8-bit, counts up from preset to 255 |
| Period | (256 − T1) × 80 µs |
| Minimum period | 80 µs (T1 = 255) |
| Maximum period | 20,480 µs (T1 = 0) |

### Timer 2 (Register 0x03)

| Parameter | Value |
|-----------|-------|
| Clock source | Master ÷ 1152 = 29.4 kHz |
| Counter | 8-bit, counts up from preset to 255 |
| Period | (256 − T2) × 320 µs |
| Minimum period | 320 µs (T2 = 255) |
| Maximum period | 81,920 µs (T2 = 0) |

Timer 2 runs at exactly one-quarter the speed of Timer 1, providing a longer period range at the cost of coarser resolution. For music playback at 50 Hz (20 ms per tick), Timer 1 with T1=6 gives a period of 20,000 µs — close to 50 Hz. Timer 2 can't hit 50 Hz exactly but can approximate it.

### Timer Control (Register 0x04)

The timer control register manages starting, stopping, masking, and resetting the timers:

| Bit | Name | Function |
|-----|------|----------|
| 7 | IRQ Reset | Write 1 to clear all timer flags (self-clearing) |
| 6 | T1 Mask | 1 = suppress Timer 1 flag in status register |
| 5 | T2 Mask | 1 = suppress Timer 2 flag in status register |
| 4:2 | — | Reserved |
| 1 | T2 Start | 1 = start Timer 2, 0 = stop |
| 0 | T1 Start | 1 = start Timer 1, 0 = stop |

**Masking vs. stopping**: A masked timer continues to run and overflow internally — its flag simply isn't reported in the status register. This distinction matters for software that uses Timer 1 for music and Timer 2 for other purposes: masking Timer 2 lets it run as a background counter without triggering the main IRQ handler.

### Timer Usage Pattern

The typical timer-driven playback loop:

```
; Initialize Timer 1 for 50 Hz
write_fm_reg(0x02, 6)      ; T1 = 6 → period ≈ 20 ms
write_fm_reg(0x04, 0x80)   ; Clear any pending flags
write_fm_reg(0x04, 0x01)   ; Start Timer 1

; Main loop
loop:
  status = read_port(0xC4)
  if (status & 0x40) == 0:  ; Wait for T1 flag
    goto loop
  write_fm_reg(0x04, 0x80) ; Clear flag
  write_fm_reg(0x04, 0x01) ; Restart Timer 1
  call music_tick()         ; Process one music tick
  goto loop
```

The MoonBlaster player on ZX Spectrum bypasses the OPL4 timers entirely, using the Z80's maskable interrupt (driven by the vertical blank at 50 Hz) to call `MBPlayer_play_music` once per frame. This is simpler and more reliable on the Spectrum since the system already has a stable 50 Hz interrupt source.

## Status Register

The status register is read from port 0xC4 (the same port used for FM Bank 1 address writes — the direction determines the operation):

| Bit | Description |
|-----|-------------|
| 7 | IRQ — any unmasked interrupt pending |
| 6 | Timer 1 overflow flag |
| 5 | Timer 2 overflow flag |
| 4:0 | Read as 0 |

### OPL Detection via Status

The status register is also used for chip detection — identifying whether an OPL chip is present and what type it is:

```
1. Read status → save as S1
2. Write register 0x04 = 0x60    (mask both timers)
3. Write register 0x04 = 0x80    (reset IRQ)
4. Read status → should be 0x00
5. Write register 0x02 = 0xFF    (Timer 1 preset = 255)
6. Write register 0x04 = 0x01    (start Timer 1)
7. Wait ≈ 200 µs (Timer 1 overflows after 80 µs)
8. Read status → save as S2
9. Write register 0x04 = 0x60    (mask timers)
10. Write register 0x04 = 0x80   (reset IRQ)
```

Interpret results:

| S2 & 0xE0 | Chip Type |
|-----------|-----------|
| 0xC0 | OPL2 or OPL3 or OPL4 detected |
| other | No OPL chip present |

To distinguish OPL2 from OPL3/OPL4, check if OPL3 mode can be enabled and verify the presence of extended features. OPL3 vs. OPL4 can be distinguished by checking whether the Wave registers (port 0x7E/0x7F) respond.

## Rhythm Mode (Register 0xBD)

Rhythm mode is an FM-only feature that converts channels 6, 7, and 8 into five percussion instruments. It's listed here as a global register because it affects the entire FM engine's channel allocation.

| Bit | Instrument | Operators Used |
|-----|-----------|---------------|
| 4 | Bass Drum | Ch 6 Op1 + Op2 (2 operators) |
| 3 | Snare Drum | Ch 7 Op2 (1 operator) |
| 2 | Tom-Tom | Ch 8 Op1 (1 operator) |
| 1 | Cymbal | Ch 8 Op2 (1 operator) |
| 0 | Hi-Hat | Ch 7 Op1 (1 operator) |

When rhythm mode is enabled (bit 5 = 1):
- Channels 6, 7, 8 are no longer available for melodic use (reducing polyphony from 18 to 15)
- The frequency registers for channels 7 and 8 still control the **pitch** of the drum sounds
- The operators retain their envelope and waveform settings, so the drum timbres are fully programmable
- Snare and Hi-Hat use noise generation in their signal path for realistic drum character
- Cymbal and Hi-Hat use phase-modulation ring-mod for metallic timbres

The MoonBlaster FM player doesn't use OPL rhythm mode. Instead, it synthesizes drum sounds using regular FM channels — typically the 4-op chains — which provides more flexibility at the cost of consuming more channel slots.

## FM/PCM Mix Architecture

The mix control registers (0xF8 and 0xF9) are located in the Wave register space but affect the final output stage where both engines' outputs are combined. This placement makes sense architecturally: the mixer sits after both synthesis engines, and the PCM register interface provides a convenient access path.

```
FM Engine Output ──→ [ ×FM_MIX atten ] ──┐
                                           ├──→ [ Sum ] ──→ DAC
PCM Engine Output ──→ [ ×PCM_MIX atten ] ─┘
```

The 3-bit attenuation values provide coarse volume control:

| Value | Approximate Attenuation |
|-------|------------------------|
| 0 | 0 dB (full volume) |
| 1 | −3 dB |
| 2 | −6 dB |
| 3 | −9 dB |
| 4 | −12 dB |
| 5 | −15 dB |
| 6 | −18 dB |
| 7 | −21 dB (nearly silent) |

Note that value 7 is not true silence — approximately −21 dB of signal still passes through. For complete muting, the individual channel volumes must also be set to zero.

## Register Write Best Practices

### Avoiding Clicks and Pops

Abrupt register changes can produce audible artifacts. The recommended practices are:

1. **Volume changes**: Use the PCM engine's Level Direct (LD) bit wisely. Set LD=0 for smooth transitions during music playback; LD=1 only when immediate changes are needed.
2. **FM key-off before parameter changes**: Always key-off a channel before changing its frequency or instrument parameters. Writing a new frequency while KEY=1 produces an audible pitch glitch.
3. **DAMP before PCM reassignment**: Always DAMP a PCM channel before assigning it a new wave number. The DAMP provides a clean cutoff faster than any release rate.

### Register Write Ordering

For FM channels, the safest write order is:
1. Operator parameters (0x20, 0x40, 0x60, 0x80, 0xE0)
2. Channel connection (0xC0)
3. Frequency (0xA0, then 0xB0)
4. Key-on (write 0xB0 with KEY=1)

Writing 0xB0 last ensures that all parameters are configured before the note begins sounding.

For PCM channels:
1. DAMP any existing note (write 0x68 with DAMP=1)
2. Wave number and F-Number (0x08, 0x20)
3. Octave (0x38)
4. Volume (0x50)
5. Envelope (0x80, 0x98, 0xB0)
6. Key-on with full control byte (0x68 with KEY=1, DAMP=0, LFO, VIB, AM, Pan)

## See Also

- [FM Registers](fm-registers.md) — FM register reference
- [PCM Registers](pcm-registers.md) — PCM register reference
- [Overview](../architecture/overview.md) — Chip architecture
- [Envelope](../synthesis/envelope.md) — Envelope generator details
