# MoonBlaster File Format Versions

Complete documentation of MoonBlaster music file format versions from 1.0 to 1.4.

## Version History

| Version | Year | Platform | Sound Chips | Extensions | Signature |
|---------|------|----------|-------------|------------|-----------|
| 1.0 | 1992 | MSX | MSX-MUSIC (YM2413) | .MBM | None |
| 1.1 | 1993 | MSX | MSX-MUSIC, MSX-AUDIO | .MBM | None |
| 1.2 | 1993 | MSX | MSX-MUSIC, MSX-AUDIO | .MBM | `MoonBlaster` |
| 1.4 | 1995 | MSX | OPL4 (YMF278B) | .MFM, .MWM, .MWK | `MBMS` |

## Format Family Tree

```
MoonBlaster 1.0 (1992)
    │ MSX-MUSIC only
    │
    ├─► MoonBlaster 1.1 (1993)
    │       MSX-MUSIC + MSX-AUDIO
    │
    └─► MoonBlaster 1.2 (1993)
            │ MSX-MUSIC + MSX-AUDIO
            │ Added "MoonBlaster" signature
            │
            └─► MoonBlaster 1.4 / MoonSound (1995)
                    OPL4 FM + PCM
                    "MBMS" signature
                    Split into FM (.MFM, + 6 wave tracks) and Wave (.MWM)
```

## MoonBlaster 1.0 / 1.1 (MBM)

Original format for MSX-MUSIC (OPLL) and MSX-AUDIO (Y8950).

### File Structure

```
+----------+------------------------------------------+
| Offset   | Content                                  |
+----------+------------------------------------------+
| 0x0000   | Music settings (128 bytes)               |
| 0x0080   | Pattern data (variable)                  |
+----------+------------------------------------------+
```

### Minimum File Size

0x0180 bytes (384 bytes)

### Music Settings Block (128 bytes)

| Offset | Size | Description |
|--------|------|-------------|
| 0x00 | 63 | Voice data for MSX-AUDIO |
| 0x3F | 1 | Number of instruments |
| 0x40 | 9 | Instrument list (channel → instrument mapping) |
| 0x49 | 9 | Channel chip set (MSX-MUSIC/AUDIO assignment) |
| 0x52 | 1 | Tempo |
| 0x53 | 1 | Master volume |
| 0x54 | 14 | Track name |
| 0x62 | 1 | Auto-start flag (0xFF = auto) |
| 0x63 | 1 | Step length (default 16) |

### Channel Chip Set

| Value | Meaning |
|-------|---------|
| 0 | MSX-MUSIC channel |
| 1 | MSX-AUDIO FM channel |
| 2 | MSX-AUDIO PCM channel |
| 3 | MSX-AUDIO rhythm channel |

## MoonBlaster 1.2 (MBM)

Enhanced version with file signature.

### File Signature

Files begin with ASCII string `MoonBlaster` (without null terminator).

### Structure Changes from 1.1

- Added file signature for identification
- Extended instrument definitions
- Improved pattern compression

## MoonBlaster 1.4 / MoonSound (MBMS)

Complete rewrite for the OPL4-based MoonSound cartridge.

### Signature

All MoonSound files use `MBMS` (MoonBlaster MoonSound) signature.

| Byte | Value | Description |
|------|-------|-------------|
| 0-3 | `MBMS` | Magic signature (0x4D424D53) |
| 4 | 0x10 | Version high byte |
| 5 | 0x01 | Version low byte |

### File Extensions

| Extension | Full Name | Channels | Content |
|-----------|-----------|----------|---------|
| .MFM | MoonBlaster FM Music | 18 FM + 6 PCM | FM music with 6 wave tracks |
| .MWM | MoonBlaster Wave Music | 18 FM + 24 PCM | Full music with samples |
| .MWK | MoonBlaster Wave Kit | — | Sample bank |

### MFM File Structure

See [mfm-moonblaster.md](mfm-moonblaster.md) for complete specification.

```
+----------+------------------------------------------+
| Offset   | Content                                  |
+----------+------------------------------------------+
| 0x0000   | Header (6 bytes)                         |
| 0x0006   | Track-info block (718 bytes)             |
| 0x02D4   | Trailer (94 bytes)                       |
| 0x0332   | Position table                           |
| varies   | Pattern pointer table                    |
| varies   | Pattern data                             |
+----------+------------------------------------------+
```

### MWM File Structure

Similar to MFM with additional PCM channel data:

```
+----------+------------------------------------------+
| Offset   | Content                                  |
+----------+------------------------------------------+
| 0x0000   | Header (6 bytes)                         |
| 0x0006   | FM track-info block                      |
| varies   | PCM channel configuration                |
| varies   | Sample bank reference                    |
| varies   | Pattern data (FM + PCM interleaved)      |
+----------+------------------------------------------+
```

### 4-Operator FM Modes

MFM files can use 4-operator synthesis:

| Chain Count | 4-op Channels | 2-op Channels | OPL4 Reg 0x104 |
|-------------|---------------|---------------|----------------|
| 0 | 0 | 18 | 0x00 |
| 2 | 2 (ch 0-3, 1-4) | 14 | 0x03 |
| 4 | 4 (+ ch 2-5, 9-12) | 10 | 0x0F |
| 6 | 6 (all pairs) | 6 | 0x3F |

## Version Detection

```python
def detect_moonblaster_version(data: bytes) -> str:
    """Detect MoonBlaster file version."""
    if data[:4] == b"MBMS":
        return f"1.4 (MoonSound) - v{data[4]>>4}.{data[4]&0xF}{data[5]:02X}"
    elif b"MoonBlaster" in data[:32]:
        return "1.2 (MSX-MUSIC/AUDIO)"
    elif len(data) >= 0x180:
        # Check for valid MBM structure
        if data[0x3F] <= 15 and data[0x52] <= 24:
            return "1.0/1.1 (MSX-MUSIC)"
    return "Unknown"
```

## Event Byte Encoding

All versions use similar event encoding in pattern data:

| Range | Meaning |
|-------|---------|
| 0x00 | No action |
| 0x01-0x60 | Note on (C-0 to B-7, 96 notes) |
| 0x61 | Note off |
| 0x62-0x79 | Instrument select (0-23) |
| 0x7A-0xB9 | Volume (0-63) |
| 0xBA-0xBC | Stereo pan (Left/Center/Right) |
| 0xBD-0xCF | Portamento / Link |
| 0xD0-0xE2 | Pitch bend |
| 0xE3-0xEF | Vibrato |
| 0xF0-0xF6 | Detune |
| 0xF7-0xF9 | Modulation |
| 0xFA-0xFC | Damp |
| 0xFD | Tempo change |
| 0xFE | Position jump |
| 0xFF | Empty row marker |

## Authorship

| Component | Creator |
|-----------|---------|
| MoonBlaster 1.0-1.2 | Remco Schrijvers |
| MoonBlaster 1.4 (Wave/FM) | Remco Schrijvers, Marcel Delorme |
| MoonSound hardware | Henrik Gilvad |

## References

- [Moonblaster file format - MSX Wiki](https://www.msx.org/wiki/Moonblaster_file_format)
- [MBM file format - MSX Resource Center](https://www.msx.org/forum/development/msx-development/mbm-file-format)
- [MSXPlug MBM support](https://www.msx.org/news/music/en/msxplug-version-026-mbm-support)
