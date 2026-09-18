"""Tests for OPL4 FM decoder."""

import pytest
from src.opl4_fm import OPL4FMDecoder, FMChannel, FMOperator, FMGlobalState


class TestFMOperator:
    """Test FM operator decoding."""

    def test_decode_reg20(self):
        """Test AM/VIB/EG/KSR/MULT decoding."""
        op = FMOperator()
        op.decode_reg20(0xF5)  # All flags + mult=5

        assert op.tremolo is True
        assert op.vibrato is True
        assert op.sustain is True
        assert op.ksr is True
        assert op.multiple == 5

    def test_decode_reg40(self):
        """Test KSL/TL decoding."""
        op = FMOperator()
        op.decode_reg40(0xC0 | 0x20)  # KSL=3, TL=32

        assert op.key_scale_level == 3
        assert op.total_level == 32
        assert op.attenuation_db == 24.0  # 32 * 0.75

    def test_decode_reg60(self):
        """Test AR/DR decoding."""
        op = FMOperator()
        op.decode_reg60(0xF8)  # AR=15, DR=8

        assert op.attack_rate == 15
        assert op.decay_rate == 8

    def test_decode_reg80(self):
        """Test SL/RR decoding."""
        op = FMOperator()
        op.decode_reg80(0xA5)  # SL=10, RR=5

        assert op.sustain_level == 10
        assert op.release_rate == 5

    def test_decode_regE0(self):
        """Test waveform select decoding."""
        op = FMOperator()
        op.decode_regE0(0x06)  # Square wave

        assert op.waveform == 6
        assert op.waveform_name == "Square"

    def test_multiple_ratio(self):
        """Test frequency multiplier lookup."""
        op = FMOperator()

        op.multiple = 0
        assert op.multiple_ratio == 0.5

        op.multiple = 1
        assert op.multiple_ratio == 1

        op.multiple = 10
        assert op.multiple_ratio == 10


class TestFMChannel:
    """Test FM channel decoding."""

    def test_decode_regA0_B0(self):
        """Test F-Number and Block decoding."""
        ch = FMChannel()
        ch.decode_regA0(0x80)  # F-Num low = 128
        ch.decode_regB0(0x25)  # Key-on, Block=1, F-Num high=1

        assert ch.key_on is True
        assert ch.block == 1
        assert ch.f_number == 384  # 0x180

    def test_decode_regC0(self):
        """Test Feedback/Connection/Pan decoding."""
        ch = FMChannel()
        ch.decode_regC0(0x31)  # Center (both outputs), FB=0, Additive (0x31 = 0b00110001)

        assert ch.pan_right is True
        assert ch.pan_left is True  # bit 5 is set
        assert ch.feedback == 0
        assert ch.connection == 1
        assert ch.connection_type == "Additive"

    def test_pan_position(self):
        """Test pan position interpretation."""
        ch = FMChannel()

        ch.pan_left = True
        ch.pan_right = True
        assert ch.pan_position == "Center"

        ch.pan_left = True
        ch.pan_right = False
        assert ch.pan_position == "Left"

        ch.pan_left = False
        ch.pan_right = True
        assert ch.pan_position == "Right"

        ch.pan_left = False
        ch.pan_right = False
        assert ch.pan_position == "Mute"

    def test_note_frequency(self):
        """Test frequency calculation."""
        ch = FMChannel()
        ch.f_number = 580  # Approx A-4 (440 Hz)
        ch.block = 4

        freq = ch.note_frequency
        assert 400 < freq < 500  # Should be around 440 Hz


class TestFMGlobalState:
    """Test global FM state decoding."""

    def test_decode_regBD(self):
        """Test rhythm mode register."""
        state = FMGlobalState()
        state.decode_regBD(0xFF)

        assert state.am_depth is True
        assert state.vib_depth is True
        assert state.rhythm_mode is True
        assert state.bass_drum is True
        assert state.snare_drum is True
        assert state.tom_tom is True
        assert state.cymbal is True
        assert state.hi_hat is True

    def test_decode_reg104(self):
        """Test 4-op mode register."""
        state = FMGlobalState()
        state.decode_reg104(0x03)  # Channels 0+3 and 1+4

        assert state.four_op_mask == 0x03
        assert 0 in state.four_op_channels
        assert 1 in state.four_op_channels


class TestOPL4FMDecoder:
    """Test full FM decoder."""

    def test_write_register(self):
        """Test register write routing."""
        decoder = OPL4FMDecoder()

        # Write to channel 0 F-Number
        decoder.write_register(0, 0xA0, 0x80)
        decoder.write_register(0, 0xB0, 0x25)

        assert decoder.channels[0].f_number == 384
        assert decoder.channels[0].key_on is True

    def test_reset(self):
        """Test decoder reset."""
        decoder = OPL4FMDecoder()
        decoder.write_register(0, 0xB0, 0x20)  # Key-on

        decoder.reset()

        assert decoder.channels[0].key_on is False

    def test_to_dict(self):
        """Test dictionary export."""
        decoder = OPL4FMDecoder()
        data = decoder.to_dict()

        assert 'global' in data
        assert 'channels' in data
        assert len(data['channels']) == 18
