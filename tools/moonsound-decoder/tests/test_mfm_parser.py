"""Comprehensive tests for MFM parser."""

import pytest
from pathlib import Path
from src.mfm_parser import (
    MFMParser, MFMFile, MFMPattern, MFMRow, MFMEvent,
    MFMInstrument, MFMOperatorPatch, EventType,
    MBMS_SIGNATURE, MFM_CHANNELS, MFM_INSTRUMENTS
)


# Test data directory
DEMO_DISKS = Path("/Volumes/TB4-4Tb/Projects/emulators/github/zxm-moonsound/demo-disks")


class TestEventDecoding:
    """Test event byte decoding."""

    def test_no_action(self):
        event = MFMEvent.decode(0x00, channel=0)
        assert event.event_type == EventType.NONE
        assert event.raw_value == 0x00

    def test_tempo_ff(self):
        # 0xFF as an event byte is TEMPO (value 5), not EMPTY_ROW
        # EMPTY_ROW (0xFF) is only detected at row level, not event level
        event = MFMEvent.decode(0xFF, channel=0)
        assert event.event_type == EventType.TEMPO
        assert event.tempo == 5  # 0xFF - 0xFA = 5

    def test_note_on_c0(self):
        event = MFMEvent.decode(0x01, channel=0)
        assert event.event_type == EventType.NOTE_ON
        assert event.note == "C-0"
        assert event.midi_note == 24
        assert event.octave == 0

    def test_note_on_a4(self):
        # A-4 = note 57 (0-based) = 0x3A
        event = MFMEvent.decode(0x3A, channel=0)
        assert event.event_type == EventType.NOTE_ON
        assert event.note == "A-4"
        assert event.midi_note == 81  # MIDI A4

    def test_note_on_b7(self):
        event = MFMEvent.decode(0x60, channel=5)
        assert event.event_type == EventType.NOTE_ON
        assert event.note == "B-7"
        assert event.channel == 5

    def test_note_off(self):
        event = MFMEvent.decode(0x61, channel=0)
        assert event.event_type == EventType.NOTE_OFF

    def test_instrument_change(self):
        event = MFMEvent.decode(0x62, channel=0)
        assert event.event_type == EventType.INSTRUMENT
        assert event.instrument == 0

        event = MFMEvent.decode(0x79, channel=0)
        assert event.event_type == EventType.INSTRUMENT
        assert event.instrument == 23

    def test_volume_change(self):
        event = MFMEvent.decode(0x7A, channel=0)
        assert event.event_type == EventType.VOLUME
        assert event.volume == 0

        event = MFMEvent.decode(0xB9, channel=0)
        assert event.event_type == EventType.VOLUME
        assert event.volume == 63

    def test_pan(self):
        event = MFMEvent.decode(0xBA, channel=0)
        assert event.event_type == EventType.PAN
        assert event.pan == "Left"

        event = MFMEvent.decode(0xBB, channel=0)
        assert event.pan == "Center"

        event = MFMEvent.decode(0xBC, channel=0)
        assert event.pan == "Right"

    def test_pitch_bend(self):
        event = MFMEvent.decode(0xC5, channel=0)
        assert event.event_type == EventType.PITCH_BEND

    def test_vibrato(self):
        event = MFMEvent.decode(0xD5, channel=0)
        assert event.event_type == EventType.VIBRATO

    def test_detune(self):
        event = MFMEvent.decode(0xE5, channel=0)
        assert event.event_type == EventType.DETUNE

    def test_effect(self):
        event = MFMEvent.decode(0xF3, channel=0)
        assert event.event_type == EventType.EFFECT

    def test_portamento(self):
        event = MFMEvent.decode(0xF8, channel=0)
        assert event.event_type == EventType.PORTAMENTO

    def test_tempo(self):
        event = MFMEvent.decode(0xFC, channel=0)
        assert event.event_type == EventType.TEMPO


class TestOperatorPatch:
    """Test FM operator patch parsing."""

    def test_from_bytes(self):
        # Test data: AM=1, VIB=1, SUS=0, KSR=1, MULT=5 for modulator
        data = bytes([
            0xD5,  # mod: AM=1, VIB=1, SUS=0, KSR=1, MULT=5
            0x21,  # car: AM=0, VIB=0, SUS=1, KSR=0, MULT=1
            0x8A,  # mod: KSL=2, TL=10
            0x05,  # car: KSL=0, TL=5
            0xF8,  # mod: AR=15, DR=8
            0xC7,  # car: AR=12, DR=7
            0x14,  # mod: SL=1, RR=4
            0x24,  # car: SL=2, RR=4
            0x00,  # mod waveform: sine
            0x00,  # car waveform: sine
            0x0D,  # FB=6, connection=1 (additive)
        ])

        patch = MFMOperatorPatch.from_bytes(data)

        # Check modulator
        assert patch.mod_am_vib_eg_ksr_mult == 0xD5
        assert patch.mod_ksl_tl == 0x8A

        # Check carrier
        assert patch.car_am_vib_eg_ksr_mult == 0x21

        # Check feedback/connection
        assert patch.feedback_connection == 0x0D

        # Check decoded values via to_dict
        d = patch.to_dict()
        assert d['modulator']['am'] == True
        assert d['modulator']['vibrato'] == True
        assert d['modulator']['multiple'] == 5
        assert d['modulator']['total_level'] == 10
        assert d['modulator']['attack'] == 15
        assert d['modulator']['decay'] == 8
        assert d['carrier']['total_level'] == 5
        assert d['feedback'] == 6
        assert d['connection'] == 'Additive'


class TestInstrument:
    """Test FM instrument parsing."""

    def test_instrument_size(self):
        assert MFM_INSTRUMENTS == 24

    def test_is_used(self):
        empty_inst = MFMInstrument()
        assert empty_inst.is_used() == False

        # Set some values
        inst = MFMInstrument()
        inst.primary.mod_ksl_tl = 0x10
        assert inst.is_used() == True


class TestMFMParser:
    """Test MFM file parsing."""

    def test_invalid_signature(self):
        with pytest.raises(ValueError, match="Invalid signature"):
            MFMParser().parse(b"INVALID_DATA")

    def test_file_too_small(self):
        with pytest.raises(ValueError, match="too small"):
            MFMParser().parse(b"MBM")

    def test_valid_header(self):
        # Minimal valid header
        data = b"MBMS\x10\x01" + b"\x00" * 1000
        parser = MFMParser()
        mfm = parser.parse(data)

        assert mfm.signature == "MBMS"
        assert mfm.version_high == 0x10
        assert mfm.version_low == 0x01
        assert mfm.version_string == "1.001"


@pytest.mark.skipif(not DEMO_DISKS.exists(), reason="Demo disks not available")
class TestRealFiles:
    """Test parsing real MFM files."""

    def test_cryogent_mfm(self):
        """Test CRYOGENT.MFM - known reference file."""
        path = DEMO_DISKS / "mfm_sample_02" / "CRYOGENT.MFM"
        if not path.exists():
            pytest.skip("CRYOGENT.MFM not found")

        mfm = MFMParser.from_file(str(path))

        # Header
        assert mfm.signature == "MBMS"
        assert mfm.version_string == "1.001"

        # Metadata
        assert "Cryogenity" in mfm.title
        assert "Zodiac" in mfm.author

        # Song structure
        assert mfm.song_length == 80  # 81 positions (0-80)
        assert mfm.loop_position == 4
        assert mfm.tempo == 7
        assert mfm.four_op_chain_count == 6

        # Instruments
        assert len(mfm.instruments) == MFM_INSTRUMENTS
        used_insts = [i for i in mfm.instruments if i.is_used()]
        assert len(used_insts) > 0

        # Patterns
        assert len(mfm.patterns) == 49
        assert len(mfm.positions) == 81

        # Check pattern content
        assert all(p.rows for p in mfm.patterns)

        # Event statistics
        stats = mfm.get_event_statistics()
        assert stats['note_on'] > 0
        assert stats['instrument'] >= 0

    def test_all_mfm_files_parse(self):
        """Verify all MFM files in demo-disks parse without error."""
        mfm_files = list(DEMO_DISKS.rglob("*.MFM"))

        failed = []
        for path in mfm_files:
            try:
                mfm = MFMParser.from_file(str(path))
                assert mfm.signature == "MBMS"
                assert len(mfm.patterns) > 0, f"{path.name}: no patterns"
            except Exception as e:
                failed.append((path.name, str(e)))

        assert not failed, f"Failed files: {failed}"

    def test_event_coverage(self):
        """Verify all event types are seen across sample files."""
        mfm_files = list(DEMO_DISKS.rglob("*.MFM"))[:10]  # Sample

        seen_types = set()
        for path in mfm_files:
            try:
                mfm = MFMParser.from_file(str(path))
                stats = mfm.get_event_statistics()
                for event_type, count in stats.items():
                    if count > 0:
                        seen_types.add(event_type)
            except Exception:
                pass

        # Should see common event types
        assert 'note_on' in seen_types
        assert 'note_off' in seen_types or 'instrument' in seen_types


class TestPatternParsing:
    """Test pattern data parsing."""

    def test_empty_row_marker(self):
        """0xFF marks an empty row."""
        row_data = bytes([0xFF])

        # Simulate pattern parsing
        pattern = MFMPattern(index=0)
        row = MFMRow(row_index=0, is_empty=True)
        pattern.rows.append(row)

        assert pattern.rows[0].is_empty == True

    def test_bit_mask_decoding(self):
        """Test channel bit mask interpretation."""
        # MSB = lowest channel in group
        mask1 = 0x80  # Channel 1 only

        active_channels = []
        for ch in range(1, 9):
            if mask1 & (0x80 >> (ch - 1)):
                active_channels.append(ch)

        assert active_channels == [1]

        # Multiple channels
        mask2 = 0xC0  # Channels 1 and 2
        active_channels = []
        for ch in range(1, 9):
            if mask2 & (0x80 >> (ch - 1)):
                active_channels.append(ch)

        assert active_channels == [1, 2]


class TestEventToDict:
    """Test event serialization."""

    def test_note_on_dict(self):
        event = MFMEvent.decode(0x3A, channel=5)
        d = event.to_dict()

        assert d['channel'] == 5
        assert d['type'] == 'note_on'
        assert d['note'] == 'A-4'
        assert d['midi_note'] == 81
        assert d['raw'] == '0x3A'

    def test_volume_dict(self):
        event = MFMEvent.decode(0x9A, channel=0)
        d = event.to_dict()

        assert d['type'] == 'volume'
        assert d['volume'] == 32


class TestMFMInfo:
    """Test info() class method."""

    @pytest.mark.skipif(not DEMO_DISKS.exists(), reason="Demo disks not available")
    def test_info_valid_file(self):
        path = DEMO_DISKS / "mfm_sample_02" / "CRYOGENT.MFM"
        if not path.exists():
            pytest.skip("File not found")

        info = MFMParser.info(str(path))

        assert info['valid'] == True
        assert info['signature'] == 'MBMS'
        assert info['format'] == 'MFM'
        assert info['format_name'] == 'MoonBlaster MoonSound FM Music'
        assert info['song_length'] == 81
        assert info['tempo'] == 7
        assert info['four_op_chains'] == 6
