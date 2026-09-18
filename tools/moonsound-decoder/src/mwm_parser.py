"""
MWM (MoonBlaster Wave Music) File Parser

Complete parser for MoonBlaster MoonSound Wave Music files (.MWM).
MWM files use the same MBMS signature as MFM but include PCM channel data.

MWM provides:
- 18 FM channels (same as MFM)
- 24 PCM/Wave channels
- Sample bank references (.MWK files)

File Structure (MBMS-based):
  Header:        6 bytes (MBMS + version)
  Track-info:    Extended block with FM + PCM config
  Sample refs:   Wave bank references
  Instruments:   FM instruments + PCM instruments
  Patterns:      FM + PCM interleaved events
"""

from dataclasses import dataclass, field
from typing import Dict, Any, List, Optional
from enum import IntEnum


MBMS_SIGNATURE = b"MBMS"
MWM_FM_CHANNELS = 18
MWM_PCM_CHANNELS = 24
MWM_TOTAL_CHANNELS = MWM_FM_CHANNELS + MWM_PCM_CHANNELS
MWM_FM_INSTRUMENTS = 24
MWM_PCM_INSTRUMENTS = 48
MWM_ROWS_PER_PATTERN = 16

# Wave track-info block (at file offset 0x0006) is 220 bytes, followed by a
# 58-byte trailer (info string + kit name), so the position table starts at
# 0x0006 + 220 + 58 = 0x011C - NOT 0x0332 (that's the MFM offset; MFM's
# track-info+trailer blocks are a different, larger size: 718+94 bytes).
MWM_TRACK_INFO_SIZE = 220
MWM_TRAILER_SIZE = 58
MWM_POSITION_TABLE_OFFSET = 6 + MWM_TRACK_INFO_SIZE + MWM_TRAILER_SIZE  # 0x011C
# xtempo lives at track-info offset +0x01A, i.e. absolute 0x0006+0x01A=0x0020.
MWM_TEMPO_OFFSET = 6 + 0x01A

NOTE_NAMES = ['C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-']


class WaveEventType(IntEnum):
    """MWM event types"""
    NONE = 0
    NOTE_ON = 1
    NOTE_OFF = 2
    INSTRUMENT = 3
    VOLUME = 4
    PAN = 5
    PITCH_BEND = 6
    VIBRATO = 7
    DETUNE = 8
    EFFECT = 9
    PORTAMENTO = 10
    TEMPO = 11
    EMPTY_ROW = 12


@dataclass
class MWMEvent:
    """Single pattern event (FM or PCM)"""

    event_type: WaveEventType = WaveEventType.NONE
    raw_value: int = 0
    channel: int = 0
    is_pcm: bool = False

    note: Optional[str] = None
    midi_note: Optional[int] = None
    instrument: Optional[int] = None
    volume: Optional[int] = None
    pan: Optional[int] = None  # 0-14 (15-step MWM pan), not MFM's L/C/R string
    portamento: Optional[int] = None
    pitch_bend: Optional[int] = None

    @classmethod
    def decode(cls, value: int, channel: int = 0, is_pcm: bool = False) -> 'MWMEvent':
        """Decode event byte"""
        event = cls(raw_value=value, channel=channel, is_pcm=is_pcm)

        if value == 0x00:
            event.event_type = WaveEventType.NONE
        elif value == 0xFF:
            event.event_type = WaveEventType.EMPTY_ROW
        elif 0x01 <= value <= 0x60:
            event.event_type = WaveEventType.NOTE_ON
            note_num = value - 1
            octave = note_num // 12
            semitone = note_num % 12
            event.note = f"{NOTE_NAMES[semitone]}{octave}"
            event.midi_note = note_num + 24
        elif value == 0x61:
            event.event_type = WaveEventType.NOTE_OFF
        elif 0x62 <= value <= 0x91:
            # MWM has 48 wave-preset slots (vs. MFM's 24 FM instruments),
            # so this range is twice as wide as the MFM equivalent.
            event.event_type = WaveEventType.INSTRUMENT
            event.instrument = value - 0x62
        elif 0x92 <= value <= 0xB1:
            # 32-step volume (0-31), not MFM's 64-step (0-63).
            event.event_type = WaveEventType.VOLUME
            event.volume = value - 0x92
        elif 0xB2 <= value <= 0xC0:
            # 15-step pan (0-14), not MFM's 3-step L/C/R.
            event.event_type = WaveEventType.PAN
            event.pan = value - 0xB2
        elif 0xC1 <= value <= 0xD3:
            event.event_type = WaveEventType.PORTAMENTO
            event.portamento = value - 0xC1
        elif 0xD4 <= value <= 0xE6:
            # Pitch bend, signed around the middle of the range (-9..+9).
            event.event_type = WaveEventType.PITCH_BEND
            event.pitch_bend = (value - 0xD4) - 9

        return event

    def to_dict(self) -> Dict[str, Any]:
        result = {
            'channel': self.channel,
            'type': self.event_type.name.lower(),
            'is_pcm': self.is_pcm,
            'raw': f"0x{self.raw_value:02X}",
        }
        if self.note:
            result['note'] = self.note
        if self.instrument is not None:
            result['instrument'] = self.instrument
        if self.volume is not None:
            result['volume'] = self.volume
        if self.pan is not None:
            result['pan'] = self.pan
        if self.portamento is not None:
            result['portamento'] = self.portamento
        if self.pitch_bend is not None:
            result['pitch_bend'] = self.pitch_bend
        return result


@dataclass
class MWMRow:
    """Single pattern row"""
    row_index: int = 0
    events: List[MWMEvent] = field(default_factory=list)
    is_empty: bool = False

    def to_dict(self) -> Dict[str, Any]:
        return {
            'row': self.row_index,
            'empty': self.is_empty,
            'events': [e.to_dict() for e in self.events if e.event_type != WaveEventType.NONE],
        }


@dataclass
class MWMPattern:
    """Pattern data"""
    index: int = 0
    rows: List[MWMRow] = field(default_factory=list)
    raw_size: int = 0
    raw_data: bytes = b""  # Original bytes for exact round-trip

    def to_dict(self) -> Dict[str, Any]:
        return {
            'index': self.index,
            'row_count': len(self.rows),
            'raw_size': self.raw_size,
            'rows': [r.to_dict() for r in self.rows],
        }

    def get_all_events(self) -> List[MWMEvent]:
        events = []
        for row in self.rows:
            for event in row.events:
                if event.event_type != WaveEventType.NONE:
                    events.append(event)
        return events


@dataclass
class MWMPCMInstrument:
    """PCM instrument with envelope"""

    index: int = 0
    wave_number: int = 0

    attack_rate: int = 15
    decay1_rate: int = 0
    decay_level: int = 15
    decay2_rate: int = 0
    rate_correction: int = 0
    release_rate: int = 15

    lfo_speed: int = 0
    vibrato_depth: int = 0
    tremolo_depth: int = 0

    total_level: int = 0
    pan: int = 0

    @classmethod
    def from_bytes(cls, data: bytes, index: int = 0) -> 'MWMPCMInstrument':
        if len(data) < 8:
            return cls(index=index)

        inst = cls(index=index)
        inst.wave_number = data[0]

        if len(data) > 1:
            inst.attack_rate = (data[1] >> 4) & 0x0F
            inst.decay1_rate = data[1] & 0x0F
        if len(data) > 2:
            inst.decay_level = (data[2] >> 4) & 0x0F
            inst.decay2_rate = data[2] & 0x0F
        if len(data) > 3:
            inst.rate_correction = (data[3] >> 4) & 0x0F
            inst.release_rate = data[3] & 0x0F
        if len(data) > 4:
            inst.lfo_speed = (data[4] >> 4) & 0x07
            inst.vibrato_depth = data[4] & 0x07
        if len(data) > 5:
            inst.tremolo_depth = (data[5] >> 4) & 0x07
        if len(data) > 6:
            inst.total_level = data[6] & 0x7F
        if len(data) > 7:
            inst.pan = data[7] & 0x0F

        return inst

    def is_used(self) -> bool:
        return self.wave_number > 0 or self.attack_rate < 15

    @property
    def pan_position(self) -> str:
        if self.pan == 0:
            return "Center"
        elif self.pan <= 7:
            return f"Left {(8 - self.pan) * 12.5:.0f}%"
        else:
            return f"Right {(self.pan - 7) * 12.5:.0f}%"

    def to_dict(self) -> Dict[str, Any]:
        return {
            'index': self.index,
            'wave_number': self.wave_number,
            'envelope': {
                'attack': self.attack_rate,
                'decay1': self.decay1_rate,
                'level': self.decay_level,
                'decay2': self.decay2_rate,
                'rate_correction': self.rate_correction,
                'release': self.release_rate,
            },
            'lfo': {
                'speed': self.lfo_speed,
                'vibrato': self.vibrato_depth,
                'tremolo': self.tremolo_depth,
            },
            'total_level': self.total_level,
            'pan': self.pan_position,
        }


@dataclass
class MWMFile:
    """Complete MWM file structure"""
    raw: bytes = b''  # whole file, for table lookups by the converters

    signature: str = ""
    version_high: int = 0
    version_low: int = 0

    song_length: int = 0
    loop_position: int = 0
    tempo: int = 0
    hz_equalizer: int = 0  # xhzequal: 0 = 60 Hz NTSC, 1 = 50 Hz PAL

    title: str = ""
    author: str = ""
    sample_kit: str = ""

    fm_instruments: List[Any] = field(default_factory=list)
    pcm_instruments: List[MWMPCMInstrument] = field(default_factory=list)
    positions: List[int] = field(default_factory=list)
    patterns: List[MWMPattern] = field(default_factory=list)

    file_size: int = 0
    format_type: str = "MWM"

    @property
    def version_string(self) -> str:
        return f"{self.version_high >> 4}.{self.version_high & 0x0F}{self.version_low:02X}"

    def get_event_statistics(self) -> Dict[str, int]:
        stats = {t.name.lower(): 0 for t in WaveEventType}
        for pattern in self.patterns:
            for event in pattern.get_all_events():
                stats[event.event_type.name.lower()] += 1
        return stats

    def to_dict(self, include_patterns: bool = True) -> Dict[str, Any]:
        used_pcm = [i for i in self.pcm_instruments if i.is_used()]
        result = {
            'header': {
                'signature': self.signature,
                'version': self.version_string,
                'format': self.format_type,
            },
            'metadata': {
                'title': self.title,
                'author': self.author,
                'sample_kit': self.sample_kit,
            },
            'song': {
                'length': self.song_length + 1,
                'loop_position': self.loop_position if self.loop_position != 0xFF else None,
                'tempo': self.tempo,
            },
            'channels': {
                'fm': MWM_FM_CHANNELS,
                'pcm': MWM_PCM_CHANNELS,
                'total': MWM_TOTAL_CHANNELS,
            },
            'statistics': {
                'file_size': self.file_size,
                'fm_instrument_count': len(self.fm_instruments),
                'pcm_instrument_count': len(used_pcm),
                'pattern_count': len(self.patterns),
                'position_count': len(self.positions),
                'events': self.get_event_statistics(),
            },
            'pcm_instruments': [i.to_dict() for i in used_pcm],
            'positions': self.positions,
        }
        if include_patterns:
            result['patterns'] = [p.to_dict() for p in self.patterns]
        return result


class MWMParser:
    """Parser for MoonBlaster Wave Music files"""

    MWM_PCM_INST_SIZE = 12

    def __init__(self):
        self.file: Optional[MWMFile] = None

    def parse(self, data: bytes) -> MWMFile:
        """Parse MWM file from bytes"""
        self.file = MWMFile()
        self.file.file_size = len(data)
        self.file.raw = bytes(data)

        if len(data) < 6:
            raise ValueError("File too small to be valid MWM")

        if data[:4] != MBMS_SIGNATURE:
            raise ValueError(f"Invalid signature: expected MBMS, got {data[:4]}")

        self.file.signature = "MBMS"
        self.file.version_high = data[4]
        self.file.version_low = data[5]

        self._parse_header(data)
        self._parse_instruments(data)
        self._parse_positions(data)
        self._parse_patterns(data)

        return self.file

    def _parse_header(self, data: bytes) -> None:
        """Parse MWM header"""
        if len(data) < 8:
            return

        self.file.song_length = data[6]
        self.file.loop_position = data[7]

        if len(data) > MWM_TEMPO_OFFSET:
            self.file.tempo = data[MWM_TEMPO_OFFSET]
        # xhzequal is the byte right after xtempo (track-info +0x01B)
        if len(data) > MWM_TEMPO_OFFSET + 1:
            self.file.hz_equalizer = data[MWM_TEMPO_OFFSET + 1]

        # Note: MWM files don't have metadata at 0x2D4 like MFM files
        # That offset contains pattern data in MWM format
        # Title/author fields remain empty unless we find another source

    def _parse_instruments(self, data: bytes) -> None:
        """Parse PCM instruments"""
        pcm_inst_offset = 0x100

        for i in range(MWM_PCM_INSTRUMENTS):
            start = pcm_inst_offset + (i * self.MWM_PCM_INST_SIZE)
            end = start + self.MWM_PCM_INST_SIZE
            if end <= len(data):
                inst = MWMPCMInstrument.from_bytes(data[start:end], i)
                self.file.pcm_instruments.append(inst)

    def _parse_positions(self, data: bytes) -> None:
        """Parse position table.

        MWM's track-info (220B) + trailer (58B) are much shorter than
        MFM's (718B + 94B), so the position table starts at a different,
        earlier absolute offset (0x011C, not MFM's 0x0332).
        """
        if len(data) < MWM_POSITION_TABLE_OFFSET:
            return

        count = self.file.song_length + 1
        offset = MWM_POSITION_TABLE_OFFSET

        for i in range(count):
            if offset + i < len(data):
                self.file.positions.append(data[offset + i])

    def _parse_patterns(self, data: bytes) -> None:
        """Parse pattern data"""
        if not self.file.positions:
            return

        pattern_count = max(self.file.positions) + 1 if self.file.positions else 0

        pos_table_end = MWM_POSITION_TABLE_OFFSET + len(self.file.positions)
        ptr_table_offset = pos_table_end

        pattern_offsets = []
        for i in range(pattern_count):
            ptr_offset = ptr_table_offset + (i * 2)
            if ptr_offset + 2 <= len(data):
                ptr = data[ptr_offset] | (data[ptr_offset + 1] << 8)
                # Pattern base is +9 (same as .MFM): verified across the
                # sample collection - only +9 decodes all 391 patterns to
                # exactly their byte span with valid command values.
                file_offset = (ptr & 0x3FFF) + 9
                pattern_offsets.append(file_offset)

        for i, offset in enumerate(pattern_offsets):
            if i + 1 < len(pattern_offsets):
                size = pattern_offsets[i + 1] - offset
            else:
                size = len(data) - offset

            if offset < len(data) and size > 0:
                pattern = self._parse_pattern(data, offset, size, i)
                self.file.patterns.append(pattern)

    def _parse_pattern(self, data: bytes, offset: int, size: int, index: int) -> MWMPattern:
        """Parse single pattern"""
        pattern = MWMPattern(index=index, raw_size=size)
        pattern_data = data[offset:offset + size]
        pattern.raw_data = pattern_data  # Store for exact round-trip

        pos = 0
        for row_idx in range(MWM_ROWS_PER_PATTERN):
            if pos >= len(pattern_data):
                break

            row = MWMRow(row_index=row_idx)

            if pattern_data[pos] == 0xFF:
                row.is_empty = True
                pos += 1
                pattern.rows.append(row)
                continue

            ch0_event = MWMEvent.decode(pattern_data[pos], channel=0)
            row.events.append(ch0_event)
            pos += 1

            if pos + 3 > len(pattern_data):
                pattern.rows.append(row)
                continue

            mask1 = pattern_data[pos]
            mask2 = pattern_data[pos + 1]
            mask3 = pattern_data[pos + 2]
            pos += 3

            for ch in range(1, 9):
                if mask1 & (0x80 >> (ch - 1)):
                    if pos < len(pattern_data):
                        event = MWMEvent.decode(pattern_data[pos], channel=ch, is_pcm=False)
                        row.events.append(event)
                        pos += 1

            for ch in range(9, 17):
                if mask2 & (0x80 >> (ch - 9)):
                    if pos < len(pattern_data):
                        event = MWMEvent.decode(pattern_data[pos], channel=ch, is_pcm=False)
                        row.events.append(event)
                        pos += 1

            for ch in range(17, 25):
                if mask3 & (0x80 >> (ch - 17)):
                    if pos < len(pattern_data):
                        event = MWMEvent.decode(pattern_data[pos], channel=ch, is_pcm=ch > 18)
                        row.events.append(event)
                        pos += 1

            pattern.rows.append(row)

        return pattern

    @classmethod
    def from_file(cls, path: str) -> MWMFile:
        """Parse MWM file from path"""
        parser = cls()
        with open(path, 'rb') as f:
            return parser.parse(f.read())

    @classmethod
    def info(cls, path: str) -> Dict[str, Any]:
        """Get file info"""
        with open(path, 'rb') as f:
            data = f.read()

        result = {
            'path': path,
            'size': len(data),
            'valid': False,
            'format': 'unknown',
        }

        if len(data) < 6:
            result['error'] = 'File too small'
            return result

        if data[:4] == MBMS_SIGNATURE:
            result['valid'] = True
            result['signature'] = 'MBMS'
            result['version'] = f"{data[4] >> 4}.{data[4] & 0x0F}{data[5]:02X}"
            result['format'] = 'MWM'
            result['format_name'] = 'MoonBlaster MoonSound Wave Music'

            if len(data) >= 8:
                result['song_length'] = data[6] + 1
                result['loop_position'] = data[7] if data[7] != 0xFF else None
        else:
            result['error'] = f'Unknown signature: {data[:4]}'

        return result
