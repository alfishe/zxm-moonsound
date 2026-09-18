# OPL4 Memory Map

The OPL4's memory system is one of its most distinctive features. Unlike the FM engine, which generates sound algorithmically from internal logic, the PCM engine depends entirely on external memory for its raw material. Every note played on a PCM channel requires continuous memory access — fetching sample data point by point as the note sounds. The memory map defines how the OPL4 addresses this external storage and how the CPU can upload custom samples alongside the built-in ROM instruments.

## Address Space Overview

The YMF278B uses a 22-bit address bus, providing a flat 4MB address space. This space is shared between ROM and RAM: on MoonSound-compatible cards the 2 MB YRW801-M ROM fills the lower half and sample RAM is mapped from 0x200000.

```
22-bit Address Space (4,194,304 bytes)
═══════════════════════════════════════════════════════════════

0x000000 ┌──────────────────────────────────────────┐
         │                                          │
         │        Sample ROM (YRW801-M)             │
         │        2 MB = 2,097,152 bytes            │
         │                                          │
         │   384 tone headers, 12-bit samples       │
         │   General MIDI compatible                │
         │                                          │
0x200000 ├──────────────────────────────────────────┤
         │                                          │
         │        Sample RAM (SRAM)                 │
         │        Up to 2 MB (ZXM: 1 MB)           │
         │                                          │
         │   User instruments, 8/12/16-bit          │
         │   Custom drum kits, vocal samples        │
         │                                          │
0x300000 ├──────────────────────────────────────────┤  ← ZXM-MoonSound RAM end
         │                                          │
         │        Unmapped (if RAM < 2 MB)          │
         │                                          │
0x3FFFFF └──────────────────────────────────────────┘
```

### ZXM-MoonSound Configuration

On the ZXM-MoonSound card:

| Region | Start | End | Size | Contents |
|--------|-------|-----|------|----------|
| ROM | 0x000000 | 0x1FFFFF | 2 MB | YRW801-M General MIDI samples |
| RAM | 0x200000 | 0x2FFFFF | 1 MB | User sample SRAM |
| Unused | 0x300000 | 0x3FFFFF | 1 MB | Beyond installed RAM |

Register 0x02 bits 4:2 (the wave table header base, in 512 KB units) tell the chip where to find the tone headers for wave numbers 384–511. Both MoonBlaster players and Furnace write 0x10 (base = 4 × 512 KB = 0x200000), so RAM tone headers live at the start of sample RAM. See [PCM Registers](../registers/pcm-registers.md#register-0x02--memory-access-mode--wave-table-header-base).

## Wave Table

The wave table is the central lookup structure that connects wave numbers to sample data. When a PCM channel begins playing a note, the first thing the hardware does is read the wave table entry for the assigned wave number. This 12-byte header contains everything the channel needs: sample format, start address, loop points, and LFO defaults.

### Wave Table Location

The wave table occupies a fixed region at the beginning of the address space. For ROM instruments, the wave table headers are pre-programmed into the ROM alongside the sample data. For user instruments in RAM, the programmer must write wave table headers into the appropriate memory locations through the CPU memory access interface.

| Source | Wave Numbers | Wave Table Address |
|--------|-------------|-------------------|
| ROM (YRW801-M) | 0 – 383 | `N × 12` (header table at the start of ROM) |
| User (RAM) | 384 – 511 | `0x200000 + (N − 384) × 12` (with register 0x02 = 0x10) |

### Wave Table Entry Format (12 bytes)

Each wave table entry is 12 bytes and describes a single instrument sample:

```
Byte 0:    Format and Start Address [21:16]
           ┌───┬───┬───┬───┬───┬───┬───┬───┐
           │ 7 │ 6 │ 5 │ 4 │ 3 │ 2 │ 1 │ 0 │
           ├───┴───┼───┴───┴───┴───┴───┴───┤
           │  FMT  │     SA[21:16]         │
           └───────┴───────────────────────┘
             FMT: 00 = 8-bit
                  01 = 12-bit
                  10 = 16-bit
                  11 = reserved

Bytes 1-2: Sample Start Address [15:8], [7:0]
           Together with byte 0 bits 5:0, the 22-bit physical
           address of the first sample point.

Bytes 3-4: Loop Start (16-bit, big-endian)
           Offset from the sample start to the loop start
           point, in samples.

Bytes 5-6: End (16-bit, big-endian)
           Stored as 0x10000 − length (two's complement of the
           sample length). Playback runs to the end and then
           loops [loop start, end) forever; one-shot samples
           use a tiny loop at the very end.

Byte 7:    LFO speed [5:3] / Vibrato depth [2:0]   → reg 0x80+ch
Byte 8:    Attack Rate [7:4] / Decay 1 Rate [3:0]   → reg 0x98+ch
Byte 9:    Decay Level [7:4] / Decay 2 Rate [3:0]   → reg 0xB0+ch
Byte 10:   Rate Correction [7:4] / Release Rate [3:0] → reg 0xC8+ch
Byte 11:   AM (tremolo) depth [2:0]                  → reg 0xE0+ch
```

For example, YRW801-M tone 0's header is `40 18 00 00 00 FF D6 00 F0 00 0F 00`: 12-bit, start 0x001800, loop 0, length 0x2A = 42 samples, AR/D1R = F/0, RC/RR = 0/F.

### Sample Format Details

The three supported sample formats represent different trade-offs between quality and memory usage:

| Format | Bits/Sample | Bytes/Sample | Dynamic Range | Usage |
|--------|-------------|-------------|---------------|-------|
| 8-bit | 8 | 1.0 | ~48 dB | Low-quality effects, percussion |
| 12-bit | 12 | 1.5 | ~72 dB | ROM instruments (YRW801-M) |
| 16-bit | 16 | 2.0 | ~96 dB | High-quality user samples |

The **12-bit format** deserves special attention because it is the YRW801-M ROM's native format. Two 12-bit samples are packed into 3 bytes:

```
Byte N:     Sample A, bits [11:4]
Byte N+1:   Sample B[3:0] (bits 7:4) | Sample A[3:0] (bits 3:0)
Byte N+2:   Sample B, bits [11:4]

As left-justified 16-bit values:
  A = byte[N]   << 8 | (byte[N+1] & 0x0F) << 4
  B = byte[N+2] << 8 | (byte[N+1] & 0xF0)
```

This packing scheme was a pragmatic choice for 1994: 12-bit resolution provides quality comparable to telephone-grade digital audio (better than 8-bit µ-law), while using only 75% of the memory that 16-bit would require. For a 2 MB ROM of instrument samples, this 25% savings was significant.

## CPU Memory Access

The CPU can read and write sample memory through a set of dedicated registers (0x02–0x06 in the Wave register space). This interface provides a sequential access mode — the programmer sets a start address, then reads or writes data bytes one at a time, with the address auto-incrementing after each access.

### Memory Access Registers

| Register | Bits | Description |
|----------|------|-------------|
| 0x02 | 4:2 = Wave table header base, 1 = Memory type, 0 = Memory access mode | Memory configuration |
| 0x03 | 5:0 = Address [21:16] | Memory address high |
| 0x04 | 7:0 = Address [15:8] | Memory address mid |
| 0x05 | 7:0 = Address [7:0] | Memory address low |
| 0x06 | 7:0 = Data | Memory data (read/write) |

### Access Procedure

To upload a custom sample to RAM:

```
1. Write register 0x02 to enable memory access mode
2. Write registers 0x03-0x05 to set the start address
3. Write register 0x06 repeatedly with sample data bytes
   (address auto-increments after each write)
4. Write register 0x02 to disable memory access mode
```

To read back sample data (or verify a write):

```
1. Enable memory access mode (register 0x02)
2. Set address (registers 0x03-0x05)
3. Read register 0x06 — first read returns invalid data (pipeline fill)
4. Read register 0x06 again — subsequent reads return valid data
   (address auto-increments after each read)
5. Disable memory access mode (register 0x02)
```

The first read returning invalid data is a well-known hardware quirk — the memory controller needs one cycle to fill its read pipeline. All correct driver implementations perform a dummy read before starting actual data reads.

### Memory Access Arbitration

During memory access mode, the CPU has priority over the PCM engine's sample fetches. This means **PCM playback may glitch during active memory access**. The recommended practice is to upload samples while no PCM channels are sounding, or to accept brief audio artifacts during upload. The MoonService utility and MoonBlaster tracker both follow this approach — samples are loaded during initialization, before playback begins.

## YRW801-M ROM Organization

The YRW801-M is Yamaha's 2 MB General MIDI wavetable ROM. It starts with a table of 384 tone headers; tones 0–329 are real samples (almost all 12-bit), tone 330 is a small 8-bit block and tones 331–383 are empty (all-zero headers).

### ROM Structure

```
0x000000  ┌──────────────────────────────┐
          │  Tone Headers (384 entries)  │
          │  12 bytes × 384 = 4,608 B   │
0x001200  ├──────────────────────────────┤
          │  Copyright text              │
          ├──────────────────────────────┤
          │  Sample Data                 │
          │  12-bit packed format        │
          │                              │
          │  Piano, strings, brass,      │
          │  woodwinds, synth leads,     │
          │  percussion, effects...      │
          │                              │
0x1FFFFF  └──────────────────────────────┘
```

The tone headers at the beginning of ROM serve as the wave table for ROM instruments. When a PCM channel is assigned wave number N (where N ≤ 383), the hardware reads the tone header at ROM address `N × 12` to determine where the sample data starts, its format, and loop points.

### General MIDI Mapping

The YRW801-M doesn't have a simple 1:1 mapping from GM program number to wave number. Each GM instrument may use multiple waves across the keyboard (split points), and some waves are shared between instruments (e.g., the same string sample might be used in both "Violin" and "Orchestral Strings" programs). The complete mapping is defined in the tone header data within the ROM and is typically documented in Yamaha's application notes.

## Practical Considerations for Emulation

Emulating the OPL4 memory subsystem requires attention to several details:

1. **Address wrapping**: The 22-bit address space wraps at 0x3FFFFF. Addresses beyond this are ANDed with 0x3FFFFF.

2. **ROM/RAM boundary**: The PCM engine does not distinguish between ROM and RAM — it simply fetches from the addressed location. The emulator must present the ROM image at the correct base address and map RAM appropriately.

3. **12-bit unpacking**: The 12-bit sample format must be correctly unpacked during sample fetch. Getting the nibble packing wrong produces characteristic buzzing artifacts.

4. **Wave table indirection**: The emulator must correctly resolve wave numbers through the tone header structure. The header's start address, loop points, and format bits must all be decoded to produce correct playback.

5. **Memory access timing**: During CPU memory access mode, the auto-increment behavior and the initial dummy read must be emulated for correct driver interaction.

## See Also

- [Overview](overview.md) — Chip capabilities and architecture
- [Block Diagram](block-diagram.md) — Internal architecture diagrams
- [PCM Registers](../registers/pcm-registers.md) — Memory access register details
- [PCM Synthesis](../synthesis/pcm-synthesis.md) — How samples are played back
