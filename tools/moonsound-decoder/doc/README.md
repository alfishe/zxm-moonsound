# MoonSound Decoder Documentation

## Architecture

- [architecture.md](architecture.md) — System overview, data flow, module organization

## Converters

- [furnace-converter.md](furnace-converter.md) — Furnace .fur format export
- [vgm-converter.md](vgm-converter.md) — VGM format (bidirectional)

## Module Reference

### Core Parsers
| Module | Description |
|--------|-------------|
| `mfm_parser.py` | MoonBlaster MFM file parser (FM) |
| `mwm_parser.py` | MoonBlaster MWM file parser (PCM) |
| `mfm_assembler.py` | MFM binary reassembler |
| `mfm_verify.py` | Round-trip verification |

### Converters
| Module | Direction | Description |
|--------|-----------|-------------|
| `converters/furnace/` | MFM→FUR | Furnace tracker export |
| `converters/vgm/` | MFM↔VGM | VGM export and import |

### CLI
| Command | Description |
|---------|-------------|
| `furnace <input>` | Convert to Furnace .fur |
| `vgm <input>` | Convert to VGM |
| `import-vgm <input>` | Import VGM to MFM |

## Usage

```bash
# Convert single file to Furnace
python -m src.cli.convert furnace song.MFM -o song.fur

# Convert directory to VGM
python -m src.cli.convert vgm ./demo-disks/ -o ./vgm-output/

# Import VGM back to MFM
python -m src.cli.convert import-vgm game.vgm -o game.MFM

# Run all tests
pytest tests/
```

## Data Flow

```
┌─────────────┐
│  MFM/MWM    │
│  (Binary)   │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│   Parser    │────▶│     IR      │
│             │     │ (dataclass) │
└─────────────┘     └──────┬──────┘
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Assembler  │     │   Furnace   │     │    VGM      │
│  (MFM out)  │     │  Converter  │     │  Converter  │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  MFM Binary │     │    .fur     │     │    .vgm     │
│  (verified) │     │   (edit)    │     │  (playback) │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │ VGM Import  │
                                        │   → MFM     │
                                        └─────────────┘
```
