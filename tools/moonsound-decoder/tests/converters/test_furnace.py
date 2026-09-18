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

    def test_tick_rate_is_zx_frame_rate_unless_msx_timing(self):
        conv = FurnaceConverter(compress=False, tick_rate=None)
        assert conv._new_song("t", "", 6, 0, 1).tick_rate == 60.0
        assert conv._new_song("t", "", 6, 1, 1).tick_rate == 50.0
        assert FurnaceConverter(compress=False)._new_song("t", "", 6, 0, 1).tick_rate == 50.0

    def test_compressed_output_round_trips(self):
        raw, _ = _convert_mfm(MFM_FILES[0], compress=False)
        packed, _ = _convert_mfm(MFM_FILES[0], compress=True)
        assert len(packed) < len(raw)
        assert 'INFO' in FurReader().read(packed)['blocks']


@needs_rom
@pytest.mark.skipif(not GALIOUS.exists(), reason="GALIOUS.MWM not available")
class TestWaveResolution:
    """Reference values independently derived from mwm_player.asm; rates use
    the chip's 22050 * 2^oct * (1024+F)/1024 (ymfm / openMSX)."""

    @pytest.fixture(scope="class")
    def resolver(self):
        return WaveResolver(WaveMemory(load_rom()))

    @pytest.mark.parametrize("patch,note_byte,tone,rate", [
        (175, 47, 122, 36391),    # GM drum kit
        (175, 83, 191, 13910.5),
        (175, 84, 197, 20801),
        (173, 37, 49, 22567),     # drum_7
    ])
    def test_rom_voices(self, resolver, patch, note_byte, tone, rate):
        voice, _ = resolver.resolve(patch, note_byte - 1)
        assert voice.tone == tone
        assert abs(voice.ref_rate - rate) < 0.5

    def test_piano_key_split(self, resolver):
        voice, _ = resolver.resolve(0, 30)     # a=30 -> split 28..33
        assert voice.tone == 303
        assert (voice.header.loop, voice.header.length) == (28377, 33650)

    def test_galious_converts_with_all_pcm_on_pcm_channels(self):
        conv = FurnaceConverter(compress=False, source_path=str(GALIOUS))
        data = conv.convert_mwm(MWMParser.from_file(str(GALIOUS)))
        parsed = FurReader().read(data)
        # one sample per voice; extra instruments carry per-note pitch paths
        assert len(parsed['blocks']['SMP2']) == 20
        assert len(parsed['blocks']['INS2']) >= 20
        assert not conv.warnings


class TestWavePitch:
    """Player pitch arithmetic (mwm_player.asm) and macro building."""

    def test_chip_rate_is_half_speed_at_octave_zero(self):
        from src.opl4_wave import chip_rate, word_rate
        assert chip_rate(0, 0) == 22050.0              # ymfm/openMSX: step 0.5 per 44.1k sample
        assert word_rate((1 << 12) | (0 << 1)) == 44100.0

    def test_carry_add_moves_fnum_overflow_into_octave(self):
        from src.opl4_wave import carry_add, word_rate
        w = (2 << 12) | (1020 << 1)                    # octave 2, F 1020
        up = carry_add(w, 20)                          # +10 F -> wraps
        assert (up >> 12) == 3 and ((up >> 1) & 0x3FF) == 6
        assert word_rate(up) > word_rate(w)
        down = carry_add((2 << 12) | (4 << 1), -20)    # F 4 - 10 -> borrow
        assert (down >> 12) == 1 and ((down >> 1) & 0x3FF) == 1018

    def test_bend_and_link_in_simulation(self):
        from src.opl4_wave import WaveMemory, WaveResolver, load_rom, word_rate
        from src.wave_pitch import simulate
        res = WaveResolver(WaveMemory(load_rom()))
        rows = [(0, 0, 'r0', 0, 0, 4), (0, 1, 'r1', 0, 0, 4), (0, 2, 'r2', 0, 0, 4)]
        events = {'r0': {0: 50}, 'r1': {0: 230}, 'r2': {0: 203}}   # note, bend +9, link +1
        notes = simulate(res, rows, lambda r: events[r], 1, [0], [0], [0], b"")
        voice, a, rates = notes[(0, 0, 0)]
        _, w0, _ = res.note_word(0, 49)
        assert rates[:5] == [word_rate(w0)] * 5          # bend starts the tick after the event
        assert rates[5] > rates[4]                        # 18 F-units per tick up
        _, w1, _ = res.note_word(0, 50)
        assert rates[8] == pytest.approx(word_rate(w1))  # link lands on the next semitone

    def test_macro_builder(self):
        from src.converters.furnace.converter import build_pitch_macro
        assert build_pitch_macro([1000.0] * 10, 1000.0) == (None, 255, 1)
        vals, loop, speed = build_pitch_macro([1000.0, 1000.0 * 2 ** (1 / 12)], 1000.0)
        assert vals == [0, 128] and loop == 255 and speed == 1
        wobble = [1000.0 * 2 ** ((i % 4) / 1200) for i in range(600)]
        vals, loop, speed = build_pitch_macro(wobble, 1000.0)   # periodic -> looped
        assert loop != 255 and len(vals) <= 255
        glide = [1000.0 * 2 ** (i / 1200) for i in range(600)]
        vals, loop, speed = build_pitch_macro(glide, 1000.0)    # long non-periodic -> slower macro
        assert speed == 3 and len(vals) <= 255
        stairs = [1000.0 * 2 ** ((i // 6) / 12) for i in range(600)]   # a link every 6-tick row
        vals, loop, speed = build_pitch_macro(stairs, 1000.0)   # row-aligned -> exact, no averaging
        assert speed == 3 and vals[::2] == [128 * i for i in range(100)]
