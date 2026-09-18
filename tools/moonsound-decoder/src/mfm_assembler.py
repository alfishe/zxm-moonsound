"""MFM file assembler - standalone, no parser imports."""

from dataclasses import dataclass, field
from typing import List, Optional
import struct


MBMS_SIGNATURE = b"MBMS"
MFM_CHANNELS = 18
MFM_INSTRUMENTS = 24
MFM_OPERATOR_PATCH_SIZE = 11
MFM_INSTRUMENT_SIZE = 23  # 2 * 11 + 1 extra byte
MFM_TRACK_INFO_SIZE = 718
MFM_TRAILER_SIZE = 94
MFM_METADATA_SIZE = 86


@dataclass
class AssemblerOperatorPatch:
    """FM operator patch data for assembler."""
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

    def to_bytes(self) -> bytes:
        """Encode to 11 bytes."""
        return bytes([
            self.mod_am_vib_eg_ksr_mult,
            self.car_am_vib_eg_ksr_mult,
            self.mod_ksl_tl,
            self.car_ksl_tl,
            self.mod_ar_dr,
            self.car_ar_dr,
            self.mod_sl_rr,
            self.car_sl_rr,
            self.mod_waveform,
            self.car_waveform,
            self.feedback_connection,
        ])


@dataclass
class AssemblerInstrument:
    """FM instrument for assembler."""
    primary: AssemblerOperatorPatch = field(default_factory=AssemblerOperatorPatch)
    secondary: AssemblerOperatorPatch = field(default_factory=AssemblerOperatorPatch)
    extra_byte: int = 0

    def to_bytes(self) -> bytes:
        """Encode to 23 bytes."""
        return self.primary.to_bytes() + self.secondary.to_bytes() + bytes([self.extra_byte])


@dataclass
class AssemblerEvent:
    """Single event for assembler."""
    event_type: str  # 'none', 'note_on', 'note_off', 'instrument', 'volume', etc.
    channel: int = 0
    raw_value: int = 0

    # Event-specific data
    note_index: int = 0  # 0-95 for notes
    instrument: int = 0  # 0-23
    volume: int = 0  # 0-63
    pan: int = 0  # 0=left, 1=center, 2=right
    pitch_bend: int = 0
    vibrato: int = 0
    detune: int = 0
    portamento: int = 0
    effect: int = 0
    tempo: int = 0

    def to_byte(self) -> int:
        """Encode event to single byte."""
        if self.event_type == 'raw':
            # Direct pass-through for round-trip verification
            return self.raw_value
        elif self.event_type == 'none':
            return 0x00
        elif self.event_type == 'empty_row':
            return 0xFF
        elif self.event_type == 'note_on':
            return 0x01 + self.note_index  # 0x01-0x60
        elif self.event_type == 'note_off':
            return 0x61
        elif self.event_type == 'instrument':
            return 0x62 + self.instrument  # 0x62-0x79
        elif self.event_type == 'volume':
            return 0x7A + self.volume  # 0x7A-0xB9
        elif self.event_type == 'pan':
            return 0xBA + self.pan  # 0xBA-0xBC
        elif self.event_type == 'pitch_bend':
            return 0xBD + self.pitch_bend  # 0xBD-0xCF
        elif self.event_type == 'vibrato':
            return 0xD0 + self.vibrato  # 0xD0-0xE2
        elif self.event_type == 'detune':
            return 0xE3 + self.detune  # 0xE3-0xEF
        elif self.event_type == 'portamento':
            return 0xF0 + self.portamento  # 0xF0-0xF6
        elif self.event_type == 'effect':
            return 0xF7 + self.effect  # 0xF7-0xFB
        elif self.event_type == 'tempo':
            return 0xFA + self.tempo  # 0xFA-0xFF
        else:
            return self.raw_value


@dataclass
class AssemblerRow:
    """Pattern row for assembler."""
    row_index: int = 0
    is_empty: bool = False
    events: List[AssemblerEvent] = field(default_factory=list)
    # Original masks for exact round-trip (mask3 has unused bits in MFM)
    mask1: int = 0
    mask2: int = 0
    mask3: int = 0
    use_original_masks: bool = False  # If True, use stored masks instead of computing

    def to_bytes(self) -> bytes:
        """Encode row to bytes."""
        if self.is_empty:
            return bytes([0xFF])

        # Find which channels have events
        channel_events = {}
        for event in self.events:
            if event.event_type != 'none':
                channel_events[event.channel] = event

        if not channel_events:
            return bytes([0xFF])

        result = bytearray()

        # Channel 0 event (always first if present)
        if 0 in channel_events:
            result.append(channel_events[0].to_byte())
        else:
            result.append(0x00)

        # Use original masks for exact round-trip, or compute from events
        if self.use_original_masks:
            mask1 = self.mask1
            mask2 = self.mask2
            mask3 = self.mask3
        else:
            mask1 = 0
            mask2 = 0
            mask3 = 0
            for ch in range(1, 9):
                if ch in channel_events:
                    mask1 |= (0x80 >> (ch - 1))
            for ch in range(9, 17):
                if ch in channel_events:
                    mask2 |= (0x80 >> (ch - 9))
            # MFM has only 18 channels (0-17), so mask3 only uses bit 7 for ch17
            if 17 in channel_events:
                mask3 |= 0x80

        result.append(mask1)
        result.append(mask2)
        result.append(mask3)

        # Append event bytes in channel order (MFM uses ch 1-17)
        for ch in range(1, 18):
            if ch in channel_events:
                result.append(channel_events[ch].to_byte())

        return bytes(result)


@dataclass
class AssemblerPattern:
    """Pattern for assembler."""
    index: int = 0
    rows: List[AssemblerRow] = field(default_factory=list)
    trailing_bytes: bytes = b""  # Bytes after last complete row

    def to_bytes(self) -> bytes:
        """Encode pattern to bytes."""
        result = bytearray()
        for row in self.rows:
            result.extend(row.to_bytes())
        # Append trailing bytes for exact match
        if self.trailing_bytes:
            result.extend(self.trailing_bytes)
        return bytes(result)


@dataclass
class MFMAssemblerData:
    """Complete MFM file data for assembly."""
    # Header
    version_high: int = 0x10
    version_low: int = 0x01

    # Track info
    song_length: int = 0  # 0-based, actual length is song_length + 1
    loop_position: int = 0xFF
    tempo: int = 8
    four_op_chain_count: int = 0

    # Metadata
    title: str = ""
    game: str = ""
    author: str = ""
    sample_kit: str = ""

    # Content
    instruments: List[AssemblerInstrument] = field(default_factory=list)
    positions: List[int] = field(default_factory=list)
    patterns: List[AssemblerPattern] = field(default_factory=list)

    # Raw track-info block (if preserving original)
    raw_track_info: Optional[bytes] = None
    raw_trailer: Optional[bytes] = None


class MFMAssembler:
    """Assembles MFM binary from structured data."""

    def __init__(self):
        self.data: Optional[MFMAssemblerData] = None

    def assemble(self, data: MFMAssemblerData) -> bytes:
        """Assemble complete MFM file."""
        self.data = data

        result = bytearray()

        # Header (6 bytes)
        result.extend(self._assemble_header())

        # Track-info block (718 bytes)
        result.extend(self._assemble_track_info())

        # Trailer (94 bytes)
        result.extend(self._assemble_trailer())

        # Position table
        result.extend(self._assemble_positions())

        # Pattern pointer table + pattern data
        pattern_section = self._assemble_patterns()
        result.extend(pattern_section)

        return bytes(result)

    def _assemble_header(self) -> bytes:
        """Assemble 6-byte header."""
        return MBMS_SIGNATURE + bytes([self.data.version_high, self.data.version_low])

    def _assemble_track_info(self) -> bytes:
        """Assemble 718-byte track-info block."""
        if self.data.raw_track_info and len(self.data.raw_track_info) == MFM_TRACK_INFO_SIZE:
            return self.data.raw_track_info

        block = bytearray(MFM_TRACK_INFO_SIZE)

        # Song length at offset 0
        block[0] = self.data.song_length

        # Loop position at offset 1
        block[1] = self.data.loop_position

        # Tempo at offset 2
        block[2] = self.data.tempo

        # 4-op chain count at offset 0x245 (581)
        if len(block) > 0x245:
            block[0x245] = self.data.four_op_chain_count

        # Instruments at offset 0x0022 (34), each 23 bytes
        inst_offset = 0x0022
        for i, inst in enumerate(self.data.instruments[:MFM_INSTRUMENTS]):
            inst_bytes = inst.to_bytes()
            end = inst_offset + MFM_INSTRUMENT_SIZE
            if end <= len(block):
                block[inst_offset:end] = inst_bytes
            inst_offset += MFM_INSTRUMENT_SIZE

        return bytes(block)

    def _assemble_trailer(self) -> bytes:
        """Assemble 94-byte trailer."""
        if self.data.raw_trailer and len(self.data.raw_trailer) == MFM_TRAILER_SIZE:
            return self.data.raw_trailer

        trailer = bytearray(MFM_TRAILER_SIZE)

        # Metadata (86 bytes)
        metadata = ""
        if self.data.title:
            metadata = self.data.title
            if self.data.game:
                metadata += " / " + self.data.game
            if self.data.author:
                metadata += " / " + self.data.author

        metadata_bytes = metadata.encode('ascii', errors='replace')[:MFM_METADATA_SIZE]
        trailer[:len(metadata_bytes)] = metadata_bytes

        # Sample kit name at offset 86-94
        kit = self.data.sample_kit or "NONE"
        kit_bytes = kit.encode('ascii', errors='replace')[:8]
        trailer[86:86 + len(kit_bytes)] = kit_bytes

        return bytes(trailer)

    def _assemble_positions(self) -> bytes:
        """Assemble position table."""
        return bytes(self.data.positions)

    def _assemble_patterns(self) -> bytes:
        """Assemble pattern pointer table and pattern data."""
        # First encode all patterns
        pattern_bytes = []
        for pattern in self.data.patterns:
            pattern_bytes.append(pattern.to_bytes())

        # Calculate pointer table size
        num_patterns = len(self.data.patterns)
        pointer_table_size = num_patterns * 2

        # Pointers are relative to track-block base (file offset 6), not pattern data start
        # track-block contains: track-info + trailer + positions + pointer_table + pattern_data
        positions_size = len(self.data.positions)
        base_offset = MFM_TRACK_INFO_SIZE + MFM_TRAILER_SIZE + positions_size + pointer_table_size

        # Build pointer table
        pointers = bytearray()
        current_offset = base_offset

        for pb in pattern_bytes:
            # Pointer format: 14-bit offset in bits 13:0
            pointers.extend(struct.pack('<H', current_offset & 0x3FFF))
            current_offset += len(pb)

        # Combine pointer table + pattern data
        result = pointers
        for pb in pattern_bytes:
            result.extend(pb)

        return bytes(result)

    @classmethod
    def from_raw_blocks(cls, header: bytes, track_info: bytes, trailer: bytes,
                        positions: List[int], patterns: List[AssemblerPattern]) -> bytes:
        """Assemble from raw blocks (for round-trip testing)."""
        data = MFMAssemblerData()
        data.version_high = header[4] if len(header) > 4 else 0x10
        data.version_low = header[5] if len(header) > 5 else 0x01
        data.raw_track_info = track_info
        data.raw_trailer = trailer
        data.positions = positions
        data.patterns = patterns

        assembler = cls()
        return assembler.assemble(data)
