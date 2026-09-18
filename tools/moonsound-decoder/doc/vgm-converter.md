# VGM Converter Design

## Overview

Bidirectional converter between MFM/MWM and VGM (Video Game Music) format. VGM is a register-log format that captures exact chip register writes with timing.

## Conversion Directions

```
┌─────────┐                    ┌─────────┐
│   MFM   │ ──── export ────▶  │   VGM   │
│   MWM   │ ◀─── import ────   │         │
└─────────┘                    └─────────┘
```

### MFM → VGM (Export)
- Expands pattern data to linear register writes
- Calculates note frequencies (F-num, block)
- Generates OPL4 FM register commands
- Adds timing based on tempo/speed

### VGM → MFM (Import)
- Analyzes register writes to detect patterns
- Groups writes into tracker rows
- Extracts instruments from operator settings
- Reconstructs pattern structure

> **Status:** export writes FM only (primary 2-op patch per channel, MIDI-style
> tuning) and does not yet use the corrected MFM layout the Furnace converter
> uses (12 4-op patches at 0x110, player channel allocation, 438.2 Hz table
> tuning, PCM wave tracks). See [furnace-converter.md](furnace-converter.md).

## VGM Format

### Header (version 1.51+)
```
Offset  Size  Description
0x00    4     "Vgm " magic
0x04    4     EOF offset - 4
0x08    4     Version (written as 0x00000171)
0x0C    4     SN76489 clock (0 = unused)
...
0x34    4     VGM data offset (relative to 0x34)
0x5C    4     YMF262 clock (OPL3) - not used by this converter
0x60    4     YMF278B clock (OPL4), 33868800
```

### Data Commands
| Command | Bytes | Description |
|---------|-------|-------------|
| 0x5E xx yy | 3 | YMF262 write, port 0 (not emitted) |
| 0x5F xx yy | 3 | YMF262 write, port 1 (not emitted) |
| 0xD0 pp aa dd | 4 | YMF278B write (pp 0/1 = FM banks, 2 = PCM) |
| 0x61 nn nn | 3 | Wait n samples |
| 0x62 | 1 | Wait 735 samples (1/60s) |
| 0x63 | 1 | Wait 882 samples (1/50s) |
| 0x66 | 1 | End of data |

## OPL4 Register Mapping

### FM Registers (OPL3-compatible)
| Register | Channel | Description |
|----------|---------|-------------|
| 0x20-0x35 | 0-17 | AM/VIB/EG/KSR/MULT |
| 0x40-0x55 | 0-17 | KSL/TL |
| 0x60-0x75 | 0-17 | AR/DR |
| 0x80-0x95 | 0-17 | SL/RR |
| 0xA0-0xA8 | 0-8 | F-num low |
| 0xB0-0xB8 | 0-8 | Key-on/Block/F-num high |
| 0xC0-0xC8 | 0-8 | FB/Connection |
| 0xE0-0xF5 | 0-17 | Waveform |
| 0x104 | - | 4-op connection |

### Note Frequency Calculation
```
F-num = (freq * 2^20) / (clock / 288)
Block = octave (0-7)
```

## Module Components

### vgm_writer.py
Exports MFM to VGM format.

```python
class VGMWriter:
    def write(self, mfm: MFMParser) -> bytes
    # internal: _build_file(), _write_opl4_fm(port, reg, val), _write_wait(samples),
    #           _note_to_fnum(note_index), _write_instrument_to_channel(...)
```

### vgm_reader.py
Parses VGM files for import.

```python
class VGMReader:
    def read(self, data: bytes) -> VGMData
    def get_opl4_fm_writes(self) -> List[Tuple[int, int, int, int]]
    def get_opl4_pcm_writes(self) -> List[Tuple[int, int, int, int]]
    # internal: _parse_header(), _parse_commands()
```

### vgm_to_mfm.py
Converts VGM back to MFM format (pattern reconstruction).

```python
class VGMToMFM:
    def convert(self, vgm: VGMData) -> MFMAssemblerData
    # internal: _detect_tempo(vgm), _process_fm_write(...), _fnum_to_note(fnum, block),
    #           _build_instrument_from_ops(ops), _build_mfm_data(vgm)
```

## VGM → MFM Reconstruction Algorithm

### 1. Tempo Detection
- Analyze wait command patterns
- Find consistent frame intervals
- Map to MFM tempo value (1-15)

### 2. Instrument Extraction
- Group operator register writes by time
- Detect instrument changes (multiple ops written together)
- Build instrument table from unique configurations

### 3. Pattern Reconstruction
- Segment writes into rows based on timing
- Detect repeated sections (patterns)
- Build position table from pattern order

### 4. Limitations
- VGM may have effects not representable in MFM
- Fine pitch bends may be quantized
- Continuous register changes become discrete events

## Testing

1. **Round-trip**: MFM → VGM → MFM (verify playback equivalence)
2. **External VGM**: Import VGM from other sources, verify valid MFM output
3. **Emulator playback**: Compare audio output between formats
