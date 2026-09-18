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
2. **No raw byte storage**: All fields must be semantically parsed
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

### MFM → OPL4 FM
| MFM Concept | OPL4 Register | Furnace Equivalent |
|-------------|---------------|-------------------|
| Channel 0-17 | 2-op FM voices | OPL4 FM channels |
| 4-op chains | 0x104 connection | 4-op mode flag |
| Instrument | Operator params | FM instrument macro |
| Note | F-num + block | Note + octave |

### MWM → OPL4 PCM
| MWM Concept | OPL4 Register | Furnace Equivalent |
|-------------|---------------|-------------------|
| Sample slot | Wave table RAM | Sample instrument |
| Channel 0-23 | PCM voices | OPL4 PCM channels |
| Loop points | Start/end addr | Sample loop |
