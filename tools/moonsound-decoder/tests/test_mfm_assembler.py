"""Tests for MFM assembler - independent from parser."""

import pytest
from src.mfm_assembler import (
    MFMAssembler, MFMAssemblerData,
    AssemblerOperatorPatch, AssemblerInstrument,
    AssemblerEvent, AssemblerRow, AssemblerPattern,
    MBMS_SIGNATURE, MFM_TRACK_INFO_SIZE, MFM_TRAILER_SIZE
)


class TestAssemblerEvent:
    """Test event byte encoding."""

    def test_none_event(self):
        event = AssemblerEvent(event_type='none')
        assert event.to_byte() == 0x00

    def test_empty_row(self):
        event = AssemblerEvent(event_type='empty_row')
        assert event.to_byte() == 0xFF

    def test_note_on_c0(self):
        event = AssemblerEvent(event_type='note_on', note_index=0)
        assert event.to_byte() == 0x01

    def test_note_on_b7(self):
        event = AssemblerEvent(event_type='note_on', note_index=95)
        assert event.to_byte() == 0x60

    def test_note_off(self):
        event = AssemblerEvent(event_type='note_off')
        assert event.to_byte() == 0x61

    def test_instrument_0(self):
        event = AssemblerEvent(event_type='instrument', instrument=0)
        assert event.to_byte() == 0x62

    def test_instrument_23(self):
        event = AssemblerEvent(event_type='instrument', instrument=23)
        assert event.to_byte() == 0x79

    def test_volume_0(self):
        event = AssemblerEvent(event_type='volume', volume=0)
        assert event.to_byte() == 0x7A

    def test_volume_63(self):
        event = AssemblerEvent(event_type='volume', volume=63)
        assert event.to_byte() == 0xB9

    def test_pan_left(self):
        event = AssemblerEvent(event_type='pan', pan=0)
        assert event.to_byte() == 0xBA

    def test_pan_center(self):
        event = AssemblerEvent(event_type='pan', pan=1)
        assert event.to_byte() == 0xBB

    def test_pan_right(self):
        event = AssemblerEvent(event_type='pan', pan=2)
        assert event.to_byte() == 0xBC


class TestAssemblerRow:
    """Test row encoding."""

    def test_empty_row(self):
        row = AssemblerRow(row_index=0, is_empty=True)
        assert row.to_bytes() == bytes([0xFF])

    def test_row_no_events(self):
        row = AssemblerRow(row_index=0, is_empty=False, events=[])
        assert row.to_bytes() == bytes([0xFF])

    def test_row_channel_0_only(self):
        event = AssemblerEvent(event_type='note_on', channel=0, note_index=0)
        row = AssemblerRow(row_index=0, events=[event])
        result = row.to_bytes()

        assert result[0] == 0x01  # Note C-0
        assert result[1] == 0x00  # Mask1: no channels 1-8
        assert result[2] == 0x00  # Mask2: no channels 9-16
        assert result[3] == 0x00  # Mask3: no channels 17-24
        assert len(result) == 4

    def test_row_channel_1(self):
        event = AssemblerEvent(event_type='note_on', channel=1, note_index=12)
        row = AssemblerRow(row_index=0, events=[event])
        result = row.to_bytes()

        assert result[0] == 0x00  # No ch0 event
        assert result[1] == 0x80  # Mask1: channel 1 (MSB)
        assert result[2] == 0x00
        assert result[3] == 0x00
        assert result[4] == 0x0D  # Note C-1
        assert len(result) == 5

    def test_row_multiple_channels(self):
        events = [
            AssemblerEvent(event_type='note_on', channel=0, note_index=0),
            AssemblerEvent(event_type='note_on', channel=1, note_index=12),
            AssemblerEvent(event_type='note_on', channel=8, note_index=24),
        ]
        row = AssemblerRow(row_index=0, events=events)
        result = row.to_bytes()

        assert result[0] == 0x01  # Ch0: C-0
        assert result[1] == 0x81  # Mask1: ch1 (0x80) + ch8 (0x01)
        assert result[2] == 0x00
        assert result[3] == 0x00
        assert result[4] == 0x0D  # Ch1: C-1
        assert result[5] == 0x19  # Ch8: C-2
        assert len(result) == 6


class TestAssemblerPattern:
    """Test pattern encoding."""

    def test_empty_pattern(self):
        pattern = AssemblerPattern(index=0, rows=[])
        assert pattern.to_bytes() == b''

    def test_pattern_single_empty_row(self):
        row = AssemblerRow(row_index=0, is_empty=True)
        pattern = AssemblerPattern(index=0, rows=[row])
        assert pattern.to_bytes() == bytes([0xFF])

    def test_pattern_multiple_rows(self):
        rows = [
            AssemblerRow(row_index=0, is_empty=True),
            AssemblerRow(row_index=1, is_empty=True),
        ]
        pattern = AssemblerPattern(index=0, rows=rows)
        assert pattern.to_bytes() == bytes([0xFF, 0xFF])


class TestAssemblerOperatorPatch:
    """Test operator patch encoding."""

    def test_empty_patch(self):
        patch = AssemblerOperatorPatch()
        result = patch.to_bytes()
        assert len(result) == 11
        assert result == bytes(11)

    def test_patch_with_values(self):
        patch = AssemblerOperatorPatch(
            mod_am_vib_eg_ksr_mult=0xD5,
            car_am_vib_eg_ksr_mult=0x21,
            mod_ksl_tl=0x8A,
            car_ksl_tl=0x05,
            mod_ar_dr=0xF8,
            car_ar_dr=0xC7,
            mod_sl_rr=0x14,
            car_sl_rr=0x24,
            mod_waveform=0x00,
            car_waveform=0x00,
            feedback_connection=0x0D,
        )
        result = patch.to_bytes()

        assert result[0] == 0xD5
        assert result[1] == 0x21
        assert result[10] == 0x0D


class TestAssemblerInstrument:
    """Test instrument encoding."""

    def test_empty_instrument(self):
        inst = AssemblerInstrument()
        result = inst.to_bytes()
        assert len(result) == 23

    def test_instrument_with_patches(self):
        primary = AssemblerOperatorPatch(mod_ksl_tl=0x10)
        secondary = AssemblerOperatorPatch(mod_ksl_tl=0x20)
        inst = AssemblerInstrument(primary=primary, secondary=secondary, extra_byte=0x55)
        result = inst.to_bytes()

        assert len(result) == 23
        assert result[2] == 0x10  # Primary mod_ksl_tl
        assert result[13] == 0x20  # Secondary mod_ksl_tl
        assert result[22] == 0x55  # Extra byte


class TestMFMAssembler:
    """Test full file assembly."""

    def test_assemble_minimal(self):
        data = MFMAssemblerData()
        data.positions = [0]
        data.patterns = [AssemblerPattern(index=0, rows=[
            AssemblerRow(row_index=0, is_empty=True)
        ])]

        assembler = MFMAssembler()
        result = assembler.assemble(data)

        # Check header
        assert result[:4] == MBMS_SIGNATURE
        assert result[4] == 0x10  # Version high
        assert result[5] == 0x01  # Version low

    def test_header_size(self):
        data = MFMAssemblerData()
        data.positions = [0]
        data.patterns = []

        assembler = MFMAssembler()
        result = assembler.assemble(data)

        # 6 (header) + 718 (track-info) + 94 (trailer) + 1 (position) = 819
        assert len(result) >= 6 + MFM_TRACK_INFO_SIZE + MFM_TRAILER_SIZE + 1

    def test_track_info_size(self):
        data = MFMAssemblerData()
        data.positions = [0]
        data.patterns = []

        assembler = MFMAssembler()
        result = assembler.assemble(data)

        track_info = result[6:6 + MFM_TRACK_INFO_SIZE]
        assert len(track_info) == MFM_TRACK_INFO_SIZE

    def test_trailer_size(self):
        data = MFMAssemblerData()
        data.positions = [0]
        data.patterns = []

        assembler = MFMAssembler()
        result = assembler.assemble(data)

        trailer_start = 6 + MFM_TRACK_INFO_SIZE
        trailer = result[trailer_start:trailer_start + MFM_TRAILER_SIZE]
        assert len(trailer) == MFM_TRAILER_SIZE

    def test_metadata_in_trailer(self):
        data = MFMAssemblerData()
        data.title = "Test Song"
        data.author = "Test Author"
        data.positions = [0]
        data.patterns = []

        assembler = MFMAssembler()
        result = assembler.assemble(data)

        trailer_start = 6 + MFM_TRACK_INFO_SIZE
        trailer = result[trailer_start:trailer_start + MFM_TRAILER_SIZE]

        assert b"Test Song" in trailer
        assert b"Test Author" in trailer

    def test_positions_after_trailer(self):
        data = MFMAssemblerData()
        data.positions = [0, 1, 2, 3]
        data.patterns = []

        assembler = MFMAssembler()
        result = assembler.assemble(data)

        pos_start = 6 + MFM_TRACK_INFO_SIZE + MFM_TRAILER_SIZE
        positions = result[pos_start:pos_start + 4]

        assert list(positions) == [0, 1, 2, 3]

    def test_raw_block_preservation(self):
        """Test that raw blocks are preserved exactly."""
        data = MFMAssemblerData()
        data.raw_track_info = bytes([i % 256 for i in range(MFM_TRACK_INFO_SIZE)])
        data.raw_trailer = bytes([0xAA] * MFM_TRAILER_SIZE)
        data.positions = [5]
        data.patterns = []

        assembler = MFMAssembler()
        result = assembler.assemble(data)

        # Check track-info preserved
        assert result[6:6 + MFM_TRACK_INFO_SIZE] == data.raw_track_info

        # Check trailer preserved
        trailer_start = 6 + MFM_TRACK_INFO_SIZE
        assert result[trailer_start:trailer_start + MFM_TRAILER_SIZE] == data.raw_trailer


class TestBitMaskEncoding:
    """Test channel bit mask calculations."""

    def test_channel_1_mask(self):
        """Channel 1 should set MSB of mask1."""
        event = AssemblerEvent(event_type='note_on', channel=1, note_index=0)
        row = AssemblerRow(events=[event])
        result = row.to_bytes()

        assert result[1] == 0x80  # 10000000

    def test_channel_8_mask(self):
        """Channel 8 should set LSB of mask1."""
        event = AssemblerEvent(event_type='note_on', channel=8, note_index=0)
        row = AssemblerRow(events=[event])
        result = row.to_bytes()

        assert result[1] == 0x01  # 00000001

    def test_channel_9_mask(self):
        """Channel 9 should set MSB of mask2."""
        event = AssemblerEvent(event_type='note_on', channel=9, note_index=0)
        row = AssemblerRow(events=[event])
        result = row.to_bytes()

        assert result[1] == 0x00  # Mask1 empty
        assert result[2] == 0x80  # Mask2: 10000000

    def test_channel_17_mask(self):
        """Channel 17 should set MSB of mask3."""
        event = AssemblerEvent(event_type='note_on', channel=17, note_index=0)
        row = AssemblerRow(events=[event])
        result = row.to_bytes()

        assert result[1] == 0x00
        assert result[2] == 0x00
        assert result[3] == 0x80  # Mask3: 10000000
