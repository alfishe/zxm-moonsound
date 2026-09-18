# MoonSound Decoder Architecture

## Overview

The MoonSound Decoder toolkit parses MoonBlaster MFM/MWM files and converts them to modern tracker formats. The architecture follows a pipeline pattern with strict separation between parsing, intermediate representation, and output generation.

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│  MFM/MWM    │────▶│   Parser     │────▶│  IR (dataclass) │
│  Binary     │     │              │     │                 │
└─────────────┘     └──────────────┘     └────────┬────────┘
                                                  │
                    ┌──────────────┐              │
                    │  Assembler   │◀─────────────┤
                    │  (MFM only)  │              │
                    └──────┬───────┘              │
                           │                      │
                    ┌──────▼───────┐     ┌────────▼────────┐
                    │  MFM Binary  │     │   Converters    │
                    │  (verified)  │     │  .fur / .vgm    │
                    └──────────────┘     └─────────────────┘
```

## Core Principles

1. **Round-trip fidelity**: Parser + Assembler must produce bit-identical output
2. **Semantic parsing**: All fields are decoded to typed values; the parsed file also keeps its `raw` bytes so converters can read fixed player tables (instrument patches, wave presets) by file offset
3. **Separation of concerns**: Parsers, assemblers, and converters are independent modules
4. **Testability**: Each component tested in isolation

## Module Organization

```
src/
├── mfm_parser.py       # MFM binary → MFMParser dataclass
├── mfm_assembler.py    # MFMAssemblerData → MFM binary
├── mfm_verify.py       # Round-trip verification
├── mwm_parser.py       # MWM binary → MWMParser dataclass
├── mwm_verify.py       # MWM parse verification
├── opl4_wave.py        # Wave preset -> OPL4 tone/pitch, ROM + .MWK sample decoding
├── moonblaster_tables.py  # Generated player tables (scripts/gen_moonblaster_tables.py)
├── converters/
│   ├── base.py         # Abstract converter interface
│   ├── furnace/        # Furnace .fur format output
│   └── vgm/            # VGM format output (register log)
└── cli/
    └── convert.py      # Command-line interface
```

## Data Flow

### Parsing Phase
- Binary file → Parser → Intermediate Representation (IR)
- IR is a tree of Python dataclasses
- All numeric values decoded to semantic types (notes, instruments, volumes)

### Conversion Phase
- IR → Converter → Target format
- Converters read IR and produce output format
- No modification of IR during conversion

### Verification Phase (MFM only)
- IR → Assembler → Binary
- Compare against original file
- Must be bit-identical for verification to pass

## Chip Mapping

Details and verification: [furnace-converter.md](furnace-converter.md).

### MFM → OPL4
| MFM Concept | OPL4 | Furnace Equivalent |
|-------------|------|-------------------|
| FM steps 0..17−chvol_1 | Allocated to hw channels by the player (`play_table_wav_1/_2`) | Logical channel via `HW_TO_FURNACE_LOGICAL` |
| 4-op chains (`chvol_1`) | Register 0x104, masters 0/1/2/9/10/11 | 4-op instruments 24-35 on master channels |
| 2-op / 4-op patches | 24 × 11 bytes at 0x008 / 12 × 22 bytes at 0x110 | `INS2` FM instruments |
| Wave steps 18-23 | PCM voices | Channels 18-23, MultiPCM instruments + samples |
| Command step 24 | Tempo / pattern end / transpose | `09xx`/`0Fxx`/`0D00` on a global channel |

### MWM → OPL4 PCM
| MWM Concept | OPL4 | Furnace Equivalent |
|-------------|------|-------------------|
| Tracks 0-23 | PCM voices | Channels 18-41 (FM 0-17 hidden) |
| Wave preset → patch | Key splits → ROM tone or `.MWK` RAM tone | One sample + MultiPCM instrument per (patch, split) |
| Loop points / envelope | Tone header + patch register overrides | Sample loop, `MP` envelope |
