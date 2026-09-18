# Furnace Converter Design

## Overview

Converts MFM/MWM files to Furnace tracker `.fur` format, preserving pattern structure, instruments, and playback characteristics.

## Furnace .fur Format

### File Structure
```
┌────────────────────────────────┐
│ Header: "-Furnace MODULE-"     │  16 bytes
├────────────────────────────────┤
│ Format version (u16 LE)        │  2 bytes
├────────────────────────────────┤
│ INFO block                     │  Song metadata, chip config
├────────────────────────────────┤
│ INST blocks                    │  Instrument definitions
├────────────────────────────────┤
│ WAVETABLE blocks               │  (not used for OPL4 FM)
├────────────────────────────────┤
│ SAMPLE blocks                  │  PCM samples (MWM)
├────────────────────────────────┤
│ PATTERN blocks                 │  Pattern data
├────────────────────────────────┤
│ END block                      │
└────────────────────────────────┘
```

### Block Format (version ≥100)
```
┌──────────────┬──────────────┬──────────────────┐
│ Block ID     │ Block Size   │ Block Data       │
│ 4 bytes      │ 4 bytes LE   │ variable         │
└──────────────┴──────────────┴──────────────────┘
```

## Chip Configuration

### OPL4 in Furnace
- System ID: `0xae` (OPL4)
- FM channels: 18 (2-op) or fewer with 4-op mode
- PCM channels: 24
- Clock: 33868800 Hz (standard)

### 4-op Chain Mapping
| MFM chains | OPL4 0x104 | Furnace config |
|------------|------------|----------------|
| 0 | 0x00 | 18× 2-op |
| 2 | 0x03 | 2× 4-op + 14× 2-op |
| 4 | 0x0F | 4× 4-op + 10× 2-op |
| 6 | 0x3F | 6× 4-op + 6× 2-op |

## Module Components

### fur_writer.py
Main entry point for .fur generation.

```python
class FurWriter:
    def __init__(self, version: int = 181)
    def write(self, song: FurSong) -> bytes
    def write_block(self, block_id: str, data: bytes) -> bytes
```

### fur_song.py
Song-level data structure matching Furnace INFO block.

```python
@dataclass
class FurSong:
    name: str
    author: str
    tempo: int
    speed: int
    pattern_length: int
    orders: List[List[int]]  # [channel][position] → pattern index
    chips: List[FurChip]
    instruments: List[FurInstrument]
    patterns: List[FurPattern]
```

### fur_instrument.py
FM instrument definition for OPL4.

```python
@dataclass
class FurFMOperator:
    am: int      # Amplitude modulation
    vib: int     # Vibrato
    sus: int     # Sustain
    ksr: int     # Key scale rate
    mult: int    # Frequency multiplier
    ksl: int     # Key scale level
    tl: int      # Total level (volume)
    ar: int      # Attack rate
    dr: int      # Decay rate
    sl: int      # Sustain level
    rr: int      # Release rate
    ws: int      # Waveform select

@dataclass  
class FurFMInstrument:
    name: str
    operators: List[FurFMOperator]  # 2 or 4 operators
    feedback: int
    connection: int  # algorithm
    four_op: bool
```

### fur_pattern.py
Pattern data structure.

```python
@dataclass
class FurPatternRow:
    note: int      # 0-119, 180=note off, 0=empty
    octave: int    # derived from note
    instrument: int
    volume: int
    effects: List[Tuple[int, int]]  # (effect_type, value)

@dataclass
class FurPattern:
    channel: int
    index: int
    rows: List[FurPatternRow]
```

### opl4_mapping.py
MFM/MWM to Furnace OPL4 translation.

```python
def mfm_note_to_furnace(note_index: int) -> Tuple[int, int]:
    """Convert MFM note (0-95) to Furnace (note, octave)."""
    
def mfm_instrument_to_furnace(inst: MFMInstrument) -> FurFMInstrument:
    """Convert MFM FM instrument to Furnace format."""
    
def mfm_effect_to_furnace(event_type: str, value: int) -> Tuple[int, int]:
    """Map MFM effects to Furnace effect codes."""
```

## Effect Mapping

| MFM Effect | Value Range | Furnace Effect | Code |
|------------|-------------|----------------|------|
| Volume | 0x7A-0xB9 | Volume | 0Cxx |
| Note Off | 0x61 | Note Off | === |
| Tempo | 0xFA-0xFF | Speed | 0Fxx |
| Vibrato | 0xD0-0xE2 | Vibrato | 04xy |
| Portamento | 0xF0-0xF6 | Porta | 03xx |
| Detune | 0xE3-0xEF | Fine tune | E5xx |
| Pan | 0xBA-0xBC | Panning | 80xx |

## Conversion Pipeline

```
MFMParser.from_file("song.mfm")
    │
    ▼
MFMToFurnace.convert(mfm: MFMParser) → FurSong
    │
    ├── map_metadata()      # title, author, tempo
    ├── map_instruments()   # FM operator params
    ├── map_patterns()      # note/effect translation
    └── configure_chip()    # OPL4, 4-op mode
    │
    ▼
FurWriter.write(song: FurSong) → bytes
    │
    ▼
output.fur
```

## Testing Strategy

1. **Unit tests**: Individual mapping functions
2. **Integration tests**: Full MFM→.fur conversion
3. **Validation**: Load generated .fur in Furnace, verify playback
