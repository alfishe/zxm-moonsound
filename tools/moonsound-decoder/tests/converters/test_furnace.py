"""Tests for the MoonBlaster -> Furnace converter.

Expected values come from the reference Z80 players and were cross-checked
against captures of the original player running in the unreal-ng emulator
(FM key-on streams) and against Furnace 0.6.8.3 renders.
"""

import struct
from pathlib import Path

import pytest

from src.mfm_parser import MFMParser
from src.mwm_parser import MWMParser
from src.converters.furnace import FurnaceConverter
from src.converters.furnace.converter import (
    HW_TO_FURNACE_LOGICAL, FOUR_OP_MASTER_HW, TWO_OP_HW_ORDER,
    PAN_NIBBLE_TO_80XX, _mb_fm_word,
)
from src.converters.furnace.fur_pattern import FurPattern, FurPatternRow, FUR_NOTE_OFF
from src.converters.furnace.fur_writer import FurReader
from src.opl4_wave import WaveMemory, WaveResolver, load_rom, DEFAULT_ROM_PATH

REPO = Path(__file__).resolve().parents[4]
DEMO_DIR = REPO / "demo-disks"
MFM_FILES = sorted(DEMO_DIR.rglob("*.MFM")) if DEMO_DIR.exists() else []
GALIOUS = DEMO_DIR / "moonsound_11" / "GALIOUS.MWM"
HAVE_ROM = Path(DEFAULT_ROM_PATH).exists()

needs_mfm = pytest.mark.skipif(not MFM_FILES, reason="no demo MFM files")
needs_rom = pytest.mark.skipif(not HAVE_ROM, reason="YRW-801 ROM image not available")


def _convert_mfm(path, compress=False):
    conv = FurnaceConverter(compress=compress, source_path=str(path))
    return conv.convert_mfm(MFMParser.from_file(str(path))), conv


class TestChannelAllocation:
    def test_hw_to_logical_is_inverse_of_furnace_outchanmap(self):
        out_chan_map_opl3 = [0, 3, 1, 4, 2, 5, 9, 12, 10, 13, 11, 14, 15, 16, 17, 6, 7, 8]
        for logical, hw in enumerate(out_chan_map_opl3):
            assert HW_TO_FURNACE_LOGICAL[hw] == logical

    @pytest.mark.parametrize("chains", range(7))
    def test_two_op_prefix_avoids_active_four_op_channels(self, chains):
        busy = set()
        for m in FOUR_OP_MASTER_HW[:chains]:
            busy |= {m, m + 3}
        two_op = TWO_OP_HW_ORDER[:18 - 2 * chains]
        assert not busy & set(two_op)
        assert len(set(two_op)) == len(two_op)


class TestFmPitch:
    def test_detune_quirk_matches_player(self):
        # C (a=48 -> block 4, fnum 345) with detune -4 -> 341 in block 4
        word = _mb_fm_word(48, -4)
        assert (word >> 10) & 7 == 4 and word & 0x3FF == 341
        assert _mb_fm_word(57, 0) & 0x3FF == 580     # A


class TestPatternEncoding:
    def _row_fields(self, note):
        pat = FurPattern(channel=0, index=0, rows=[FurPatternRow(note=note)])
        data = pat.to_furnace_bytes(1, 1)
        return struct.unpack_from('<hh', data, 8)

    def test_sentinels_are_avoided(self):
        assert self._row_fields(-1) == (0, 0)          # empty
        assert self._row_fields(FUR_NOTE_OFF) == (100, 0)
        assert self._row_fields(100) == (88, 1)        # 100 alone = note off
        assert self._row_fields(0) == (12, -1)         # 0/0 alone = empty
        assert self._row_fields(57) == (57, 0)


def test_pan_table_covers_player_nibbles():
    # player writes (N-185) & 15 for N in 178..192
    for n in range(178, 193):
        assert ((n - 185) & 15) in PAN_NIBBLE_TO_80XX


@needs_mfm
class TestMfmConversion:
    def test_structure(self):
        data, conv = _convert_mfm(MFM_FILES[0])
        assert data[:16] == b"-Furnace module-"
        parsed = FurReader().read(data)
        assert parsed['version'] == 100
        assert 'INFO' in parsed['blocks'] and 'END-' in parsed['blocks']
        mfm = MFMParser.from_file(str(MFM_FILES[0]))
        assert len(parsed['blocks']['PATR']) == len(mfm.positions) * 42
        # 24 two-op + 12 four-op FM instruments, then PCM wave voices
        assert len(parsed['blocks']['INS2']) >= 36

    @pytest.mark.parametrize("mfm_path", MFM_FILES[:12], ids=lambda p: p.name)
    def test_patterns_decode_to_exact_sizes(self, mfm_path):
        mfm = MFMParser.from_file(str(mfm_path))
        # every pattern but the last (EOF slack) consumes exactly its span
        for p in mfm.patterns[:-1]:
            assert len(p.rows) == 16 and not p.trailing_bytes
        for p in mfm.patterns:
            for r in p.rows:
                assert r.command == 0 or 1 <= r.command <= 75

    def test_compressed_output_round_trips(self):
        raw, _ = _convert_mfm(MFM_FILES[0], compress=False)
        packed, _ = _convert_mfm(MFM_FILES[0], compress=True)
        assert len(packed) < len(raw)
        assert 'INFO' in FurReader().read(packed)['blocks']


@needs_rom
@pytest.mark.skipif(not GALIOUS.exists(), reason="GALIOUS.MWM not available")
class TestWaveResolution:
    """Reference values independently derived from mwm_player.asm."""

    @pytest.fixture(scope="class")
    def resolver(self):
        return WaveResolver(WaveMemory(load_rom()))

    @pytest.mark.parametrize("patch,note_byte,tone,rate", [
        (175, 47, 122, 72782),    # GM drum kit
        (175, 83, 191, 27821),
        (175, 84, 197, 41602),
        (173, 37, 49, 45134),     # drum_7
    ])
    def test_rom_voices(self, resolver, patch, note_byte, tone, rate):
        voice, _ = resolver.resolve(patch, note_byte - 1)
        assert voice.tone == tone
        assert abs(voice.ref_rate - rate) < 1.0

    def test_piano_key_split(self, resolver):
        voice, _ = resolver.resolve(0, 30)     # a=30 -> split 28..33
        assert voice.tone == 303
        assert (voice.header.loop, voice.header.length) == (28377, 33650)

    def test_galious_converts_with_all_pcm_on_pcm_channels(self):
        conv = FurnaceConverter(compress=False, source_path=str(GALIOUS))
        data = conv.convert_mwm(MWMParser.from_file(str(GALIOUS)))
        parsed = FurReader().read(data)
        assert len(parsed['blocks']['SMP2']) == len(parsed['blocks']['INS2']) == 20
        assert not conv.warnings
