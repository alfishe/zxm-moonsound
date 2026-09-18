"""
MFM (MoonBlaster FM Music) File Parser

Complete parser for MoonBlaster MoonSound FM Music files (.MFM).
All MoonSound files begin with the ASCII signature "MBMS".

File Structure:
  Header:        6 bytes (MBMS + version)
  Track-info:    718 bytes at offset 0x0006
  Trailer:       94 bytes at offset 0x02D4
  Position table: variable at offset 0x0332
  Pattern ptrs:  2 bytes × pattern count
  Pattern data:  variable (16 rows per pattern, bit-packed)

Based on mfm-moonblaster.md specification and reference player analysis.
"""

from dataclasses import dataclass, field
from typing import Dict, Any, List, Optional, Tuple
from enum import IntEnum


MBMS_SIGNATURE = b"MBMS"
MFM_CHANNELS = 18
MFM_PATTERN_CHANNELS = 25  # Channel 0 + 24 mask-covered channels
MFM_ROWS_PER_PATTERN = 16
MFM_INSTRUMENTS = 24
MFM_INSTRUMENT_SIZE = 23
MFM_TRACK_INFO_SIZE = 718
MFM_TRAILER_SIZE = 94
MFM_METADATA_SIZE = 50
# File offset of pattern-pointer value 0 (see _parse_patterns).
PATTERN_BASE_OFFSET = 9

NOTE_NAMES = ['C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-']


class EventType(IntEnum):
    """MFM event types"""
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
class MFMEvent:
    """Single pattern event"""

    event_type: EventType = EventType.NONE
    raw_value: int = 0
    channel: int = 0

    # Event-specific data
    note: Optional[str] = None
    midi_note: Optional[int] = None
    octave: Optional[int] = None
    instrument: Optional[int] = None
    volume: Optional[int] = None
    pan: Optional[str] = None
    pitch_bend: Optional[int] = None
    vibrato: Optional[int] = None
    detune: Optional[int] = None
    effect: Optional[int] = None
    portamento: Optional[int] = None
    tempo: Optional[int] = None

    @classmethod
    def decode(cls, value: int, channel: int = 0) -> 'MFMEvent':
        """Decode event byte to structured event"""
        event = cls(raw_value=value, channel=channel)

        if value == 0x00:
            event.event_type = EventType.NONE
        elif 0x01 <= value <= 0x60:
            event.event_type = EventType.NOTE_ON
            note_num = value - 1
            event.octave = note_num // 12
            semitone = note_num % 12
            event.note = f"{NOTE_NAMES[semitone]}{event.octave}"
            event.midi_note = note_num + 24  # C-0 = MIDI 24
        elif value == 0x61:
            event.event_type = EventType.NOTE_OFF
        elif 0x62 <= value <= 0x79:
            event.event_type = EventType.INSTRUMENT
            event.instrument = value - 0x62
        elif 0x7A <= value <= 0xB9:
            event.event_type = EventType.VOLUME
            event.volume = value - 0x7A  # 0-63
        elif 0xBA <= value <= 0xBC:
            event.event_type = EventType.PAN
            pan_val = value - 0xBA
            event.pan = ['Left', 'Center', 'Right'][pan_val]
        elif 0xC0 <= value <= 0xCF:
            event.event_type = EventType.PITCH_BEND
            event.pitch_bend = value - 0xC0
        elif 0xD0 <= value <= 0xE2:
            event.event_type = EventType.VIBRATO
            event.vibrato = value - 0xD0
        elif 0xE3 <= value <= 0xEF:
            event.event_type = EventType.DETUNE
            event.detune = value - 0xE3
        elif 0xF0 <= value <= 0xF6:
            event.event_type = EventType.EFFECT
            event.effect = value - 0xF0
        elif 0xF7 <= value <= 0xF9:
            event.event_type = EventType.PORTAMENTO
            event.portamento = value - 0xF7
        elif 0xFA <= value <= 0xFF:
            event.event_type = EventType.TEMPO
            event.tempo = value - 0xFA

        return event

    def to_dict(self) -> Dict[str, Any]:
        result = {
            'channel': self.channel,
            'type': self.event_type.name.lower(),
            'raw': f"0x{self.raw_value:02X}",
        }
        if self.note:
            result['note'] = self.note
            result['midi_note'] = self.midi_note
        if self.instrument is not None:
            result['instrument'] = self.instrument
        if self.volume is not None:
            result['volume'] = self.volume
        if self.pan:
            result['pan'] = self.pan
        if self.pitch_bend is not None:
            result['pitch_bend'] = self.pitch_bend
        if self.vibrato is not None:
            result['vibrato'] = self.vibrato
        if self.detune is not None:
            result['detune'] = self.detune
        if self.effect is not None:
            result['effect'] = self.effect
        if self.portamento is not None:
            result['portamento'] = self.portamento
        if self.tempo is not None:
            result['tempo'] = self.tempo
        return result


@dataclass
class MFMRow:
    """Single pattern row.

    A row is the player's 25-entry step buffer: steps 0-17 feed FM voices
    (in allocation order, see MBPlayer_play_table_wav_1/_2), steps 18-23
    are the six PCM wave tracks, step 24 is the command channel. `events`
    holds the FM steps (decoded with the FM taxonomy); `wave_events` maps
    wave track 0-5 -> raw event byte (wave taxonomy, same as .MWM);
    `command` is the raw command byte (0 = none).
    """

    row_index: int = 0
    events: List[MFMEvent] = field(default_factory=list)
    is_empty: bool = False
    wave_events: Dict[int, int] = field(default_factory=dict)
    command: int = 0
    # Original mask values for exact round-trip
    mask1: int = 0
    mask2: int = 0
    mask3: int = 0

    def to_dict(self) -> Dict[str, Any]:
        return {
            'row': self.row_index,
            'empty': self.is_empty,
            'events': [e.to_dict() for e in self.events if e.event_type != EventType.NONE],
        }


@dataclass
class MFMPattern:
    """Pattern data"""

    index: int = 0
    rows: List[MFMRow] = field(default_factory=list)
    raw_size: int = 0
    trailing_bytes: bytes = b""  # Bytes after last complete row (for exact round-trip)

    def to_dict(self) -> Dict[str, Any]:
        return {
            'index': self.index,
            'row_count': len(self.rows),
            'raw_size': self.raw_size,
            'rows': [r.to_dict() for r in self.rows],
        }

    def get_all_events(self) -> List[MFMEvent]:
        """Get all non-empty events in pattern"""
        events = []
        for row in self.rows:
            for event in row.events:
                if event.event_type != EventType.NONE:
                    events.append(event)
        return events


@dataclass
class MFMOperatorPatch:
    """Single operator patch (11 bytes for modulator+carrier pair)"""

    mod_am_vib_eg_ksr_mult: int = 0
    car_am_vib_eg_ksr_mult: int = 0
    mod_ksl_tl: int = 0
    car_ksl_tl: int = 0
    mod_ar_dr: int = 0
    car_ar_dr: int = 0
    mod_sl_rr: int = 0
    car_sl_rr: int = 0
    mod_waveform: int = 0
    car_waveform: int = 0
    feedback_connection: int = 0

    @classmethod
    def from_bytes(cls, data: bytes) -> 'MFMOperatorPatch':
        if len(data) < 11:
            return cls()
        return cls(
            mod_am_vib_eg_ksr_mult=data[0],
            car_am_vib_eg_ksr_mult=data[1],
            mod_ksl_tl=data[2],
            car_ksl_tl=data[3],
            mod_ar_dr=data[4],
            car_ar_dr=data[5],
            mod_sl_rr=data[6],
            car_sl_rr=data[7],
            mod_waveform=data[8],
            car_waveform=data[9],
            feedback_connection=data[10],
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            'modulator': {
                'am': bool(self.mod_am_vib_eg_ksr_mult & 0x80),
                'vibrato': bool(self.mod_am_vib_eg_ksr_mult & 0x40),
                'sustain': bool(self.mod_am_vib_eg_ksr_mult & 0x20),
                'ksr': bool(self.mod_am_vib_eg_ksr_mult & 0x10),
                'multiple': self.mod_am_vib_eg_ksr_mult & 0x0F,
                'ksl': (self.mod_ksl_tl >> 6) & 0x03,
                'total_level': self.mod_ksl_tl & 0x3F,
                'attack': (self.mod_ar_dr >> 4) & 0x0F,
                'decay': self.mod_ar_dr & 0x0F,
                'sustain_level': (self.mod_sl_rr >> 4) & 0x0F,
                'release': self.mod_sl_rr & 0x0F,
                'waveform': self.mod_waveform & 0x07,
            },
            'carrier': {
                'am': bool(self.car_am_vib_eg_ksr_mult & 0x80),
                'vibrato': bool(self.car_am_vib_eg_ksr_mult & 0x40),
                'sustain': bool(self.car_am_vib_eg_ksr_mult & 0x20),
                'ksr': bool(self.car_am_vib_eg_ksr_mult & 0x10),
                'multiple': self.car_am_vib_eg_ksr_mult & 0x0F,
                'ksl': (self.car_ksl_tl >> 6) & 0x03,
                'total_level': self.car_ksl_tl & 0x3F,
                'attack': (self.car_ar_dr >> 4) & 0x0F,
                'decay': self.car_ar_dr & 0x0F,
                'sustain_level': (self.car_sl_rr >> 4) & 0x0F,
                'release': self.car_sl_rr & 0x0F,
                'waveform': self.car_waveform & 0x07,
            },
            'feedback': (self.feedback_connection >> 1) & 0x07,
            'connection': 'Additive' if (self.feedback_connection & 0x01) else 'FM',
        }


@dataclass
class MFMInstrument:
    """FM instrument (23 bytes: two 11-byte patches + 1 extra)"""

    index: int = 0
    primary: MFMOperatorPatch = field(default_factory=MFMOperatorPatch)
    secondary: MFMOperatorPatch = field(default_factory=MFMOperatorPatch)
    extra_byte: int = 0

    @classmethod
    def from_bytes(cls, data: bytes, index: int = 0) -> 'MFMInstrument':
        if len(data) < MFM_INSTRUMENT_SIZE:
            return cls(index=index)
        return cls(
            index=index,
            primary=MFMOperatorPatch.from_bytes(data[0:11]),
            secondary=MFMOperatorPatch.from_bytes(data[11:22]),
            extra_byte=data[22] if len(data) > 22 else 0,
        )

    def is_used(self) -> bool:
        return (self.primary.mod_ksl_tl > 0 or
                self.primary.car_ksl_tl > 0 or
                self.primary.mod_ar_dr > 0)

    def to_dict(self) -> Dict[str, Any]:
        return {
            'index': self.index,
            'primary': self.primary.to_dict(),
            'secondary': self.secondary.to_dict(),
            'is_4op': self.secondary.mod_ar_dr > 0 or self.secondary.car_ar_dr > 0,
        }


@dataclass
class MFMFile:
    """Complete MFM file structure"""
    raw: bytes = b''  # whole file, for table lookups by the converters

    # Header
    signature: str = ""
    version_high: int = 0
    version_low: int = 0

    # Track info
    song_length: int = 0
    loop_position: int = 0
    tempo: int = 0
    hz_equalizer: int = 0
    four_op_chain_count: int = 0

    # Metadata
    title: str = ""
    author: str = ""
    game: str = ""
    sample_kit: str = ""

    # Data
    instruments: List[MFMInstrument] = field(default_factory=list)
    positions: List[int] = field(default_factory=list)
    patterns: List[MFMPattern] = field(default_factory=list)

    # File info
    file_size: int = 0
    format_type: str = "MFM"

    @property
    def version_string(self) -> str:
        return f"{self.version_high >> 4}.{self.version_high & 0x0F}{self.version_low:02X}"

    @property
    def two_op_channel_count(self) -> int:
        return 18 - (2 * self.four_op_chain_count)

    def get_all_note_events(self) -> List[MFMEvent]:
        """Get all note-on events in song order"""
        events = []
        for pos_idx in self.positions:
            if pos_idx < len(self.patterns):
                pattern = self.patterns[pos_idx]
                for event in pattern.get_all_events():
                    if event.event_type == EventType.NOTE_ON:
                        events.append(event)
        return events

    def get_event_statistics(self) -> Dict[str, int]:
        """Count events by type"""
        stats = {t.name.lower(): 0 for t in EventType}
        for pattern in self.patterns:
            for event in pattern.get_all_events():
                stats[event.event_type.name.lower()] += 1
        return stats

    def to_dict(self, include_patterns: bool = True) -> Dict[str, Any]:
        used_instruments = [i for i in self.instruments if i.is_used()]
        result = {
            'header': {
                'signature': self.signature,
                'version': self.version_string,
                'format': self.format_type,
            },
            'metadata': {
                'title': self.title,
                'author': self.author,
                'game': self.game,
                'sample_kit': self.sample_kit,
            },
            'song': {
                'length': self.song_length + 1,
                'loop_position': self.loop_position if self.loop_position != 0xFF else None,
                'tempo': self.tempo,
                'hz_equalizer': self.hz_equalizer,
            },
            'channels': {
                'total_fm': MFM_CHANNELS,
                'four_op_chains': self.four_op_chain_count,
                'two_op_channels': self.two_op_channel_count,
            },
            'statistics': {
                'file_size': self.file_size,
                'instrument_count': len(used_instruments),
                'instrument_slots': MFM_INSTRUMENTS,
                'pattern_count': len(self.patterns),
                'position_count': len(self.positions),
                'events': self.get_event_statistics(),
            },
            'instruments': [i.to_dict() for i in used_instruments],
            'positions': self.positions,
        }
        if include_patterns:
            result['patterns'] = [p.to_dict() for p in self.patterns]
        return result


class MFMParser:
    """Parser for MoonBlaster FM Music files"""

    def __init__(self):
        self.file: Optional[MFMFile] = None
        self._data: bytes = b""

    def parse(self, data: bytes) -> MFMFile:
        """Parse MFM file from bytes"""
        self._data = data
        self.file = MFMFile()
        self.file.file_size = len(data)
        self.file.raw = bytes(data)

        if len(data) < 6:
            raise ValueError("File too small to be valid MFM")

        if data[:4] != MBMS_SIGNATURE:
            raise ValueError(f"Invalid signature: expected MBMS, got {data[:4]}")

        self.file.signature = "MBMS"
        self.file.version_high = data[4]
        self.file.version_low = data[5]

        # Parse track-info block (starts at offset 6)
        if len(data) >= 6 + MFM_TRACK_INFO_SIZE:
            self._parse_track_info(data, 6)

        # Parse trailer (at offset 0x02D4)
        if len(data) >= 0x02D4 + MFM_TRAILER_SIZE:
            self._parse_trailer(data, 0x02D4)

        # Parse position table (at offset 0x0332)
        if len(data) >= 0x0332:
            self._parse_positions(data, 0x0332)

        # Parse pattern pointers and data
        if self.file.positions:
            self._parse_patterns(data)

        return self.file

    def _parse_track_info(self, data: bytes, offset: int) -> None:
        """Parse 718-byte track-info block"""
        block = data[offset:offset + MFM_TRACK_INFO_SIZE]

        self.file.song_length = block[0]
        self.file.loop_position = block[1]

        # FM instruments (24 × 23 bytes at offset 2)
        inst_offset = 2
        for i in range(MFM_INSTRUMENTS):
            start = inst_offset + (i * MFM_INSTRUMENT_SIZE)
            end = start + MFM_INSTRUMENT_SIZE
            if end <= len(block):
                inst = MFMInstrument.from_bytes(block[start:end], i)
                self.file.instruments.append(inst)

        if len(block) > 0x22A:
            self.file.tempo = block[0x22A]
        if len(block) > 0x22B:
            self.file.hz_equalizer = block[0x22B]
        if len(block) > 0x245:
            self.file.four_op_chain_count = block[0x245]

    def _parse_trailer(self, data: bytes, offset: int) -> None:
        """Parse 94-byte trailer"""
        trailer = data[offset:offset + MFM_TRAILER_SIZE]

        if len(trailer) >= MFM_METADATA_SIZE:
            metadata_raw = trailer[:MFM_METADATA_SIZE]
            try:
                metadata = metadata_raw.decode('ascii', errors='replace').strip()
                parts = metadata.split(' / ')
                if len(parts) >= 3:
                    self.file.title = parts[0].strip()
                    self.file.game = parts[1].strip()
                    self.file.author = parts[2].strip()
                elif len(parts) == 2:
                    self.file.title = parts[0].strip()
                    self.file.author = parts[1].strip()
                else:
                    self.file.title = metadata
            except Exception:
                pass

        if len(trailer) >= 94:
            kit_raw = trailer[86:94]
            try:
                self.file.sample_kit = kit_raw.decode('ascii', errors='replace').strip()
                if self.file.sample_kit == "NONE":
                    self.file.sample_kit = ""
            except Exception:
                pass

    def _parse_positions(self, data: bytes, offset: int) -> None:
        """Parse position table"""
        count = self.file.song_length + 1
        for i in range(count):
            if offset + i < len(data):
                self.file.positions.append(data[offset + i])

    def _parse_patterns(self, data: bytes) -> None:
        """Parse pattern pointer table and pattern data"""
        if not self.file.positions:
            return

        # Pattern count is max(positions) + 1
        pattern_count = max(self.file.positions) + 1

        # Position table ends, pattern pointers begin
        pos_table_end = 0x0332 + len(self.file.positions)
        ptr_table_offset = pos_table_end

        # Read pattern pointers (2 bytes each, little-endian)
        pattern_offsets = []
        for i in range(pattern_count):
            ptr_offset = ptr_table_offset + (i * 2)
            if ptr_offset + 2 <= len(data):
                ptr = data[ptr_offset] | (data[ptr_offset + 1] << 8)
                # bits 13:0 = offset relative to track-block base (file offset 6)
                # Pattern base is file offset +9, not +6 as older docs
                # claimed: verified by decoding every pattern of the
                # sample collection - only +9 makes all 16-row patterns
                # consume exactly their byte span with valid command-
                # channel values (153/153 vs <=31/153 for any other base).
                file_offset = (ptr & 0x3FFF) + PATTERN_BASE_OFFSET
                pattern_offsets.append(file_offset)

        # Parse each pattern
        for i, offset in enumerate(pattern_offsets):
            # Determine pattern size from next pointer or EOF
            if i + 1 < len(pattern_offsets):
                next_offset = pattern_offsets[i + 1]
                size = next_offset - offset
            else:
                size = len(data) - offset

            if offset < len(data) and size > 0:
                pattern = self._parse_pattern(data, offset, size, i)
                self.file.patterns.append(pattern)

    def _parse_pattern(self, data: bytes, offset: int, size: int, index: int) -> MFMPattern:
        """Parse a single pattern: exactly 16 rows (the player's step
        counter wraps with `and 0Fh`).

        Mirrors the reference row unpacker (mfm_player.asm, after
        MBPlayer_play_step): byte 0 -> step 0, then three mask bytes whose
        bits (MSB first) select steps 1-24, each set bit consuming one
        event byte. ALL 24 mask bits must consume their byte - steps 18-23
        (wave tracks) and 24 (command channel) included. Skipping them
        (as an earlier version did, treating mask3 bits 6-0 as unused)
        desynchronised every subsequent row of the pattern.
        """
        pattern = MFMPattern(index=index, raw_size=size)
        pattern_data = data[offset:offset + size]
        pattern.raw_data = pattern_data  # Keep for reference

        pos = 0
        for row_idx in range(MFM_ROWS_PER_PATTERN):
            row = MFMRow(row_index=row_idx)

            if pos >= len(pattern_data):
                row.is_empty = True
                pattern.rows.append(row)
                continue

            if pattern_data[pos] == 0xFF:
                row.is_empty = True
                pos += 1
                pattern.rows.append(row)
                continue

            steps = [0] * 25
            steps[0] = pattern_data[pos]
            pos += 1
            masks = list(pattern_data[pos:pos + 3]) + [0] * (3 - len(pattern_data[pos:pos + 3]))
            row.mask1, row.mask2, row.mask3 = masks
            pos += 3

            for group, mask in enumerate(masks):
                for bit in range(8):
                    if mask & (0x80 >> bit):
                        if pos < len(pattern_data):
                            steps[1 + group * 8 + bit] = pattern_data[pos]
                        pos += 1

            for ch in range(MFM_CHANNELS):
                if steps[ch]:
                    row.events.append(MFMEvent.decode(steps[ch], channel=ch))
            for wave_track in range(6):
                if steps[18 + wave_track]:
                    row.wave_events[wave_track] = steps[18 + wave_track]
            row.command = steps[24]

            pattern.rows.append(row)

        if pos < len(pattern_data):
            pattern.trailing_bytes = pattern_data[pos:]

        return pattern

    @classmethod
    def from_file(cls, path: str) -> MFMFile:
        """Parse MFM file from path"""
        parser = cls()
        with open(path, 'rb') as f:
            return parser.parse(f.read())

    @classmethod
    def info(cls, path: str) -> Dict[str, Any]:
        """Get detailed file info"""
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
            result['format'] = 'MFM'
            result['format_name'] = 'MoonBlaster MoonSound FM Music'

            if len(data) >= 0x02D4 + MFM_METADATA_SIZE:
                metadata_raw = data[0x02D4:0x02D4 + MFM_METADATA_SIZE]
                try:
                    result['metadata'] = metadata_raw.decode('ascii', errors='replace').strip()
                except Exception:
                    pass

            if len(data) >= 8:
                result['song_length'] = data[6] + 1
                result['loop_position'] = data[7] if data[7] != 0xFF else None

            if len(data) >= 0x230:
                result['tempo'] = data[0x230]

            if len(data) >= 0x24C:
                result['four_op_chains'] = data[0x24B]
        else:
            result['error'] = f'Unknown signature: {data[:4]}'

        return result
