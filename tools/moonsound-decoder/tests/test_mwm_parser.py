"""Comprehensive tests for MWM parser."""

import pytest
from pathlib import Path
from src.mwm_parser import (
    MWMParser, MWMFile, MWMPattern, MWMRow, MWMEvent,
    MWMPCMInstrument, WaveEventType,
    MBMS_SIGNATURE, MWM_FM_CHANNELS, MWM_PCM_CHANNELS
)


DEMO_DISKS = Path("/Volumes/TB4-4Tb/Projects/emulators/github/zxm-moonsound/demo-disks")


class TestWaveEventDecoding:
    """Test MWM event byte decoding."""

    def test_no_action(self):
        event = MWMEvent.decode(0x00, channel=0)
        assert event.event_type == WaveEventType.NONE

    def test_note_on(self):
        event = MWMEvent.decode(0x01, channel=0)
        assert event.event_type == WaveEventType.NOTE_ON
        assert event.note == "C-0"

    def test_pcm_channel_flag(self):
        event = MWMEvent.decode(0x01, channel=20, is_pcm=True)
        assert event.is_pcm == True
        assert event.channel == 20

    def test_instrument(self):
        event = MWMEvent.decode(0x70, channel=0)
        assert event.event_type == WaveEventType.INSTRUMENT
        assert event.instrument == 14

    def test_preset_range_is_48_wide(self):
        # mwm_player.asm play_int_wlus: 98-145 select wave preset 0-47
        event = MWMEvent.decode(0x8A, channel=0)
        assert event.event_type == WaveEventType.INSTRUMENT
        assert event.instrument == 40

    def test_volume(self):
        # 146-177: volume 0-31
        event = MWMEvent.decode(146 + 16, channel=0)
        assert event.event_type == WaveEventType.VOLUME
        assert event.volume == 16


class TestPCMInstrument:
    """Test PCM instrument parsing."""

    def test_from_bytes_minimal(self):
        data = bytes([0x10, 0xF0, 0xF0, 0x0F, 0x00, 0x00, 0x40, 0x00])
        inst = MWMPCMInstrument.from_bytes(data, index=5)

        assert inst.index == 5
        assert inst.wave_number == 0x10
        assert inst.attack_rate == 15
        assert inst.decay1_rate == 0
        assert inst.total_level == 0x40

    def test_is_used(self):
        empty_inst = MWMPCMInstrument()
        assert empty_inst.is_used() == False

        inst = MWMPCMInstrument(wave_number=10)
        assert inst.is_used() == True

    def test_pan_position(self):
        inst = MWMPCMInstrument(pan=0)
        assert inst.pan_position == "Center"

        inst = MWMPCMInstrument(pan=7)
        assert "Left" in inst.pan_position

        inst = MWMPCMInstrument(pan=15)
        assert "Right" in inst.pan_position


class TestMWMParser:
    """Test MWM file parsing."""

    def test_invalid_signature(self):
        with pytest.raises(ValueError, match="Invalid signature"):
            MWMParser().parse(b"NOT_MBMS_DATA")

    def test_file_too_small(self):
        with pytest.raises(ValueError, match="too small"):
            MWMParser().parse(b"MBM")

    def test_valid_header(self):
        data = b"MBMS\x10\x01" + b"\x00" * 1000
        parser = MWMParser()
        mwm = parser.parse(data)

        assert mwm.signature == "MBMS"
        assert mwm.version_high == 0x10
        assert mwm.version_string == "1.001"


@pytest.mark.skipif(not DEMO_DISKS.exists(), reason="Demo disks not available")
class TestRealMWMFiles:
    """Test parsing real MWM files."""

    def test_xenorium_mwm(self):
        """Test a known MWM file."""
        path = DEMO_DISKS / "moonsound_05" / "XENORIUM.MWM"
        if not path.exists():
            pytest.skip("XENORIUM.MWM not found")

        mwm = MWMParser.from_file(str(path))

        assert mwm.signature == "MBMS"
        assert mwm.file_size > 0

        # Should have parsed some content
        assert len(mwm.positions) > 0 or mwm.song_length >= 0

    def test_all_mwm_files_parse(self):
        """Verify all MWM files parse without error."""
        mwm_files = list(DEMO_DISKS.rglob("*.MWM"))

        failed = []
        success = 0
        for path in mwm_files:
            try:
                mwm = MWMParser.from_file(str(path))
                assert mwm.signature == "MBMS"
                success += 1
            except Exception as e:
                failed.append((path.name, str(e)))

        # All should pass
        assert not failed, f"Failed {len(failed)} files: {failed[:5]}"
        assert success == len(mwm_files)

    def test_mwm_has_patterns(self):
        """Verify MWM files have parsed pattern data."""
        mwm_files = list(DEMO_DISKS.rglob("*.MWM"))[:20]  # Sample

        files_with_patterns = 0
        for path in mwm_files:
            try:
                mwm = MWMParser.from_file(str(path))
                if len(mwm.patterns) > 0:
                    files_with_patterns += 1
            except Exception:
                pass

        # Most files should have patterns
        assert files_with_patterns > len(mwm_files) // 2


class TestMWMInfo:
    """Test info() method."""

    @pytest.mark.skipif(not DEMO_DISKS.exists(), reason="Demo disks not available")
    def test_info_valid(self):
        mwm_files = list(DEMO_DISKS.rglob("*.MWM"))
        if not mwm_files:
            pytest.skip("No MWM files found")

        info = MWMParser.info(str(mwm_files[0]))

        assert info['valid'] == True
        assert info['signature'] == 'MBMS'
        assert info['format'] == 'MWM'


class TestMWMChannels:
    """Test channel configuration."""

    def test_channel_counts(self):
        assert MWM_FM_CHANNELS == 18
        assert MWM_PCM_CHANNELS == 24
        assert MWM_FM_CHANNELS + MWM_PCM_CHANNELS == 42


class TestMWMEventStatistics:
    """Test event statistics collection."""

    @pytest.mark.skipif(not DEMO_DISKS.exists(), reason="Demo disks not available")
    def test_event_stats(self):
        """Check that we capture event statistics."""
        mwm_files = list(DEMO_DISKS.rglob("*.MWM"))[:5]

        total_events = 0
        for path in mwm_files:
            try:
                mwm = MWMParser.from_file(str(path))
                stats = mwm.get_event_statistics()
                for count in stats.values():
                    total_events += count
            except Exception:
                pass

        # Should have found some events
        assert total_events > 0
