"""Tests for VGM converter."""

import pytest
from pathlib import Path

from src.mfm_parser import MFMParser
from src.converters.vgm import VGMConverter, VGMReader


# Find test data
DEMO_DIR = Path(__file__).parent.parent.parent.parent.parent / "demo-disks"
MFM_FILES = list(DEMO_DIR.rglob("*.MFM")) if DEMO_DIR.exists() else []


class TestVGMWriter:
    """Test VGM export."""

    def test_export_single_file(self):
        """Test exporting a single MFM to VGM."""
        if not MFM_FILES:
            pytest.skip("No test MFM files found")

        mfm_path = MFM_FILES[0]
        mfm = MFMParser.from_file(str(mfm_path))

        converter = VGMConverter()
        vgm_data = converter.convert_mfm(mfm)

        assert len(vgm_data) > 0
        assert vgm_data[:4] == b"Vgm "

    def test_vgm_header(self):
        """Test VGM header structure."""
        if not MFM_FILES:
            pytest.skip("No test MFM files found")

        mfm = MFMParser.from_file(str(MFM_FILES[0]))
        converter = VGMConverter()
        vgm_data = converter.convert_mfm(mfm)

        # Parse header
        reader = VGMReader()
        parsed = reader.read(vgm_data)

        assert parsed.version > 0
        assert parsed.opl4_clock > 0

    def test_vgm_has_commands(self):
        """Test VGM contains commands."""
        if not MFM_FILES:
            pytest.skip("No test MFM files found")

        mfm = MFMParser.from_file(str(MFM_FILES[0]))
        converter = VGMConverter()
        vgm_data = converter.convert_mfm(mfm)

        reader = VGMReader()
        parsed = reader.read(vgm_data)

        assert len(parsed.commands) > 0
        # Should have OPL4 writes
        assert len(parsed.opl4_writes) > 0

    @pytest.mark.parametrize("mfm_path", MFM_FILES[:10])
    def test_batch_export(self, mfm_path):
        """Test batch VGM export."""
        mfm = MFMParser.from_file(str(mfm_path))
        converter = VGMConverter()
        vgm_data = converter.convert_mfm(mfm)

        assert len(vgm_data) > 0
        assert vgm_data[:4] == b"Vgm "


class TestVGMReader:
    """Test VGM parsing."""

    def test_parse_exported_vgm(self):
        """Test parsing VGM we exported."""
        if not MFM_FILES:
            pytest.skip("No test MFM files found")

        mfm = MFMParser.from_file(str(MFM_FILES[0]))
        converter = VGMConverter()
        vgm_data = converter.convert_mfm(mfm)

        reader = VGMReader()
        parsed = reader.read(vgm_data)

        # Should have wait commands
        waits = [c for c in parsed.commands if c.wait > 0]
        assert len(waits) > 0

        # Should contain end marker (0x66) somewhere
        end_cmds = [c for c in parsed.commands if c.cmd == 0x66]
        assert len(end_cmds) > 0


class TestVGMToMFM:
    """Test VGM import to MFM."""

    def test_roundtrip_basic(self):
        """Test basic MFM → VGM → MFM roundtrip."""
        if not MFM_FILES:
            pytest.skip("No test MFM files found")

        from src.mfm_assembler import MFMAssembler
        from src.converters.vgm import VGMToMFM

        # Original MFM
        mfm = MFMParser.from_file(str(MFM_FILES[0]))

        # Export to VGM
        converter = VGMConverter()
        vgm_data = converter.convert_mfm(mfm)

        # Import back
        reader = VGMReader()
        parsed = reader.read(vgm_data)

        vgm_to_mfm = VGMToMFM()
        mfm_data = vgm_to_mfm.convert(parsed)

        # Assemble
        assembler = MFMAssembler()
        mfm_bytes = assembler.assemble(mfm_data)

        # Should produce valid MFM
        assert mfm_bytes[:4] == b"MBMS"
        assert len(mfm_bytes) > 100
