# MoonSound Python Tools

Python library and CLI for parsing and analyzing MoonSound/OPL4 audio files.

## Features

- **OPL4 FM Decoder** - Decode OPL3-compatible FM synthesis registers
- **OPL4 PCM Decoder** - Decode PCM/wavetable synthesis registers  
- **MFM Parser** - Parse MoonBlaster FM Music files
- **MWM Parser** - Parse MoonBlaster Wave Music files
- **CLI Tool** - Command-line interface for file analysis

## Installation

```bash
# From source
cd tools/moonsound-decoder
pip install -e .

# With development dependencies
pip install -e ".[dev]"
```

## Usage

### Command Line

```bash
# Show file information
moonsound info melody.mfm

# Parse file to JSON
moonsound parse song.mwm --output json

# List instruments
moonsound instruments track.mfm
```

### Python API

```python
from src import MFMParser, MWMParser
from src import OPL4FMDecoder, OPL4PCMDecoder

# Parse MFM file
mfm = MFMParser.from_file("melody.mfm")
print(f"Instruments: {len(mfm.instruments)}")

# Parse MWM file  
mwm = MWMParser.from_file("song.mwm")
print(f"Samples: {len(mwm.samples)}")

# Decode FM registers
fm = OPL4FMDecoder()
fm.write_register(bank=0, register=0xB0, value=0x31)  # Key-on channel 0
print(fm.channels[0].to_dict())

# Decode PCM registers
pcm = OPL4PCMDecoder()
pcm.write_register(register=0x68, value=0x80)  # Key-on channel 0
print(pcm.channels[0].to_dict())
```

## File Formats

### MFM (MoonBlaster FM Music)

FM synthesis music for OPL4's OPL3-compatible section:
- 18 FM channels (2-operator)
- 24 instruments per file
- Pattern-based sequencing

### MWM (MoonBlaster Wave Music)

PCM/wavetable music for OPL4's PCM section:
- 24 PCM channels
- Sample bank references (ROM or RAM)
- 6-stage envelope (AR, D1R, DL, D2R, RC, RR)

## OPL4 Register Decoding

The library provides full decoding of YMF278B (OPL4) registers:

### FM Registers (ports 0xC4-0xC7)

| Register | Description |
|----------|-------------|
| 0x20-0x35 | AM/VIB/EG/KSR/MULT |
| 0x40-0x55 | KSL/Total Level |
| 0x60-0x75 | Attack/Decay Rate |
| 0x80-0x95 | Sustain/Release |
| 0xA0-0xA8 | F-Number Low |
| 0xB0-0xB8 | Key-On/Block/F-Num High |
| 0xC0-0xC8 | Feedback/Connection/Pan |
| 0xE0-0xF5 | Waveform Select |

### PCM Registers (ports 0x7E-0x7F)

| Register | Description |
|----------|-------------|
| 0x08-0x1F | Wave Number |
| 0x20-0x37 | F-Number Low |
| 0x38-0x4F | Octave/F-Num High/Reverb |
| 0x50-0x67 | Total Level |
| 0x68-0x7F | Key/Damp/LFO/Pan |
| 0x80-0x97 | AR/D1R |
| 0x98-0xAF | DL/D2R |
| 0xB0-0xC7 | RC/RR |

## Development

```bash
# Run tests
pytest

# Run tests with coverage
pytest --cov=moonsound

# Type checking
mypy src/moonsound

# Linting
ruff check src/moonsound
```

## License

MIT License - see repository root for details.

## References

- [YMF278B Datasheet](../../doc/datasheets/) - Yamaha OPL4 documentation
- [OPL4 Register Reference](../../doc/opl4/registers/) - Detailed register maps
- [MoonBlaster Documentation](../../doc/file-formats/) - File format specifications
