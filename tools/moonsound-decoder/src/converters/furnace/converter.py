"""MoonBlaster (.MFM / .MWM) to Furnace (.fur) converter.

Semantics follow the reference Z80 players (demo-disks/*/mfm_player.asm,
mwm_player.asm), not secondary docs. Target is always Furnace OPL4
(YMF278B, 42 channels: logical 0-17 FM, 18-41 PCM). Output was verified
against the installed Furnace 0.6.8.3 by rendering and tracing commands.

Song layout (both formats):
  * A pattern row is the player's 25-entry step buffer; step 24 is the
    command channel: 1-23 tempo (speed = 25 - cmd), 24 end of pattern,
    25-75 transpose (tspval = cmd - 52, from the next row on).
  * Rows advance every `speed` ticks (initial speed = xtempo); ticks run at
    50 Hz when xhzequal is set, else 60 Hz.
  * Positions are unrolled: Furnace pattern index == position index, so
    transposition state and pattern breaks are baked in exactly.

MFM (FM + 6 PCM wave tracks):
  * Steps 0..(17-chvol_1) are FM voices, allocated in order: the first
    chvol_1 go to 4-op chains on hw channels 0,1,2,9,10,11
    (MBPlayer_play_table_wav_1), the rest to 2-op hw channels in
    MBPlayer_play_table_wav_2 order. hw channels are then mapped to Furnace
    logical channels (inverse of Furnace's outChanMapOPL3).
  * Instruments: 24 x 11-byte 2-op patches at 0x008, 12 x 22-byte 4-op
    patches at 0x110 (register order 20,23,40,43,60,63,80,83,E0,E3 per
    pair, then C0 master / C3 slave).
  * FM volume event = carrier TL (attenuation, 0 loudest); ignored on
    4-op tracks. FM pan: 0xBA left, 0xBB right, 0xBC both.
  * Steps 18-23 are PCM wave tracks (Furnace 18-23), using the wave
    taxonomy below with xwavnrs/xwavvols at 0x294/0x2B4.

MWM (24 PCM wave tracks, Furnace 18-41; FM section unused and hidden).

Wave taxonomy (both): 1-96 note, 97 off, 98-145 preset, 146-177 volume
(TL = 4*(31-v)), 178-192 pan (nibble (N-185)&15), 193-211 link, 212-230
pitch bend, 231-237 detune, 238-240 modulation, 241-242 damp.
"""

from dataclasses import dataclass, field
from types import SimpleNamespace
from typing import Dict, List, Optional, Tuple
import math
import os

from src.mfm_parser import MFMOperatorPatch
from src.converters.base import Converter
from src.opl4_wave import (WaveMemory, WaveResolver, MwkKit, Voice, load_rom,
                           PATCH_DRUMS)

from .fur_song import FurSong, FurChip, FUR_CHIP_OPL4
from .fur_instrument import FurFMInstrument
from .fur_pattern import FurPattern, FurPatternRow, FurEffect, FUR_NOTE_OFF
from .fur_sample import FurSample, FurSampleInstrument
from .fur_writer import FurWriter


# --- FM channel allocation (mfm_player.asm) --------------------------------

# Inverse of Furnace opl.cpp outChanMapOPL3 (logical -> hw): hw -> logical.
HW_TO_FURNACE_LOGICAL = [0, 2, 4, 1, 3, 5, 15, 16, 17, 6, 8, 10, 7, 9, 11, 12, 13, 14]
# MBPlayer_play_table_wav_1: 4-op chain masters (slave = master + 3).
FOUR_OP_MASTER_HW = [0, 1, 2, 9, 10, 11]
# MBPlayer_play_table_wav_2: 2-op voice order; any prefix skips the
# channels taken by the active 4-op chains.
TWO_OP_HW_ORDER = [17, 16, 15, 8, 7, 6, 14, 11, 13, 10, 12, 9, 5, 2, 4, 1, 3, 0]

# --- MFM file layout (player RAM copy at 0x50F2 = file offset 6) ----------
MFM_2OP_PATCHES = 0x008       # 24 x 11 bytes
MFM_4OP_PATCHES = 0x110       # 12 x 22 bytes
MFM_INIT_PAN = 0x218          # 24 bytes: FM steps 0-17, wave tracks 0-5
MFM_INIT_INSTRUMENT = 0x27C   # 24 bytes (1-based): FM steps, wave tracks
MFM_XWAVNRS = 0x294           # 32 wave presets -> patch number
MFM_XWAVVOLS = 0x2B4          # 32 default attenuations
MFM_CHVOL1 = 0x24B
MFM_KIT_NAME = 0x2D4 + 0x56

# --- MWM file layout (track-info block at 6) --------------------------------
MWM_XWVSTPR = 6 + 0x02        # 24 initial pan nibbles
MWM_XBEGWAV = 6 + 0x64        # 24 initial presets (1-based)
MWM_XWAVNRS = 6 + 0x7C        # 48 presets -> patch number
MWM_XWAVVOLS = 6 + 0xAC       # 48 default attenuations
MWM_TITLE = 0xE2              # 50-byte info string
MWM_KIT_NAME = 0xE2 + 50

ROWS = 16
PCM_BASE = 18
# MoonBlaster's FM F-number table (C..B = 345,365,...,651 per block) is
# tuned to A4 = 580 * (33.8688 MHz / 684) / 2^16 = 438.23 Hz on OPL4. Using
# it as the song tuning makes Furnace compute the player's exact F-numbers
# (verified against the original player's register stream in the emulator).
# Furnace applies song tuning to PCM samples too, so PCM C-4 rates are
# pre-scaled by 440 / MB_TUNING to keep the player's exact sample rates.
MB_TUNING = 580 * (33868800 / 684) / 2 ** 16
# Furnace floors its computed F-number while the player's table is
# round-to-nearest. Measured against Furnace 0.6.8.3's VGM output, a bias in
# [1.00079, 1.00095] reproduces all 12 table entries (345,365,...,651)
# exactly for blocks >= 3; in blocks 1-2 Furnace's own float math still puts
# E and G# one unit high (<= 4 cents).
TUNING_BIAS = 1.00087
SONG_TUNING = MB_TUNING * TUNING_BIAS
# Furnace also rounds OPL4 PCM F-numbers ~1.4 cents sharp on average
# (measured over all 2809 GALIOUS.MWM notes vs the player's rates);
# centre that out.
PCM_TUNING_COMP = 440.0 / SONG_TUNING * 2 ** (-1.44 / 1200)
FUR_CHANNELS = 42
GLOBAL_FX_COLS = 3            # [speed1, speed2, flow control]


def _furnace_pan_value_for_nibble() -> Dict[int, int]:
    """Choose the linear 80xx value whose Furnace pipeline yields each OPL4
    PCM pan nibble: convertPanLinearToSplit(xx,8,255) -> (L,R) ->
    convertPanSplitToLinear(...,15) -> nibble = 8 ^ min(lin+1, 15)."""
    table = {}
    for xx in range(256):
        val = xx
        pan_l = min(255, ((255 - val) * 255 * 2) // 255)
        pan_r = min(255, (val * 255 * 2) // 255)
        diff = pan_r - pan_l
        pan = 0.5 if diff == 0 else (1.0 + diff / max(pan_l, pan_r)) * 0.5
        lin = int(pan * 15)
        nibble = 8 ^ min(lin + 1, 15)
        # prefer the value closest to the middle of each nibble's range
        table.setdefault(nibble, []).append(xx)
    return {n: vals[len(vals) // 2] for n, vals in table.items()}


PAN_NIBBLE_TO_80XX = _furnace_pan_value_for_nibble()

# MoonBlaster FM F-number table (mfm_player.asm unk_0_4CC8), block = a // 12.
MB_FNUMS = [345, 365, 387, 410, 434, 460, 488, 517, 547, 580, 615, 651]
MFM_DETUNE = 0x233            # 18 signed bytes: per-FM-step detune (fnum units)


def _mb_fm_word(a: int, detune: int) -> int:
    """Player's B0/A0 word for note index a with detune applied exactly as
    sub_0_4530 does it: `inc de; e += detune (8-bit); dec de`."""
    word = ((a // 12) << 10) | MB_FNUMS[a % 12]
    d, e = word >> 8, word & 0xFF
    return ((d << 8) | ((e + 1 + detune) & 0xFF)) - 1


def _detune_pitch_effect(a: int, detune: int) -> Optional[int]:
    """E5xx value (0x80 = centre, 1/128 semitone per step) that moves
    Furnace's own F-number for note a onto the player's detuned one."""
    if detune == 0:
        return None
    target = _mb_fm_word(a, detune)
    t_fnum, t_block = target & 0x3FF, (target >> 10) & 7
    ideal = 580 * 2 ** ((a % 12 - 9) / 12) * TUNING_BIAS    # Furnace's pre-floor fnum
    ratio = ((t_fnum + 0.5) * 2 ** t_block) / (ideal * 2 ** (a // 12))
    steps = round(1536 * math.log2(ratio))
    return max(0, min(255, 0x80 + steps))


@dataclass
class _WaveTrackState:
    preset: int = 0
    volume: Optional[int] = None      # Furnace 0-127, pending until next note
    pan_nibble: Optional[int] = None  # pending pan


@dataclass
class _FmTrackState:
    instrument: int = 0               # patch index (2-op 0-23, 4-op 0-11)
    pan: Optional[int] = None         # pending 80xx value
    detune: int = 0                   # signed F-number offset
    last_pitch_fx: Optional[int] = 0x80


class FurnaceConverter(Converter):
    """Converts MFM/MWM files to Furnace .fur format (OPL4)."""

    @property
    def name(self) -> str:
        return "Furnace"

    @property
    def output_extension(self) -> str:
        return ".fur"

    def __init__(self, compress: bool = True, rom_path: Optional[str] = None,
                 source_path: Optional[str] = None):
        self.compress = compress
        self.rom_path = rom_path
        self.source_path = source_path
        self.warnings: List[str] = []

    def convert_file(self, input_path, output_path=None):
        # The song's directory is where its .MWK sample kit is looked up.
        self.source_path = str(input_path)
        result = super().convert_file(input_path, output_path)
        result.warnings.extend(self.warnings)
        return result

    # ------------------------------------------------------------------ utils

    def _load_kit(self, kit_name: str) -> Optional[MwkKit]:
        name = kit_name.strip()
        if not name or name.upper() == 'NONE':
            return None
        search = [os.path.dirname(self.source_path)] if self.source_path else []
        for d in search:
            for fn in os.listdir(d):
                if fn.upper() == f'{name.upper()}.MWK':
                    return MwkKit(open(os.path.join(d, fn), 'rb').read())
        self.warnings.append(f'sample kit {name}.MWK not found - kit waves will be silent')
        return None

    def _new_song(self, name: str, author: str, tempo: int, hz_equalizer: int, n_positions: int) -> FurSong:
        song = FurSong(name=name or "Untitled", author=author or "")
        song.chips = [FurChip(chip_id=FUR_CHIP_OPL4)]
        song.tuning = SONG_TUNING
        song.speed = song.speed2 = max(1, tempo)
        song.tick_rate = 50.0 if hz_equalizer else 60.0
        song.pattern_length = ROWS
        song.order_length = n_positions
        song.orders = [[pos] * FUR_CHANNELS for pos in range(n_positions)]
        return song

    @staticmethod
    def _grid(n_positions: int) -> List[List[Dict[int, FurPatternRow]]]:
        """grid[pos][row][channel] -> FurPatternRow (created lazily)."""
        return [[{} for _ in range(ROWS)] for _ in range(n_positions)]

    @staticmethod
    def _cell(grid, pos: int, row: int, ch: int) -> FurPatternRow:
        cells = grid[pos][row]
        if ch not in cells:
            cells[ch] = FurPatternRow()
        return cells[ch]

    @staticmethod
    def _set_fx(cell: FurPatternRow, col: int, code: int, value: int):
        while len(cell.effects) <= col:
            cell.effects.append(FurEffect())
        cell.effects[col] = FurEffect(code=code, value=value)

    def _emit_patterns(self, song: FurSong, grid):
        for pos, rows in enumerate(grid):
            for ch in range(FUR_CHANNELS):
                pat = FurPattern(channel=ch, index=pos)
                pat.rows = [rows[r].get(ch, FurPatternRow()) for r in range(ROWS)]
                song.patterns.append(pat)

    def _walk_song(self, positions, get_rows, get_command, grid, global_ch: int, xloop: int,
                   on_row):
        """Walk positions in play order, honouring commands.

        get_rows(pattern_index) -> list of rows; on_row(pos, r, row, tsp) is
        called for each played row with the transpose in effect for it.
        Returns nothing; writes global effects into `grid`."""
        tsp = 0
        last_pos = len(positions) - 1
        for pos, pat_idx in enumerate(positions):
            rows = get_rows(pat_idx)
            last_row = ROWS - 1
            for r in range(ROWS):
                row = rows[r] if r < len(rows) else None
                cmd = get_command(row) if row is not None else 0
                if row is not None:
                    on_row(pos, r, row, tsp)
                if 1 <= cmd <= 23:
                    speed = max(1, 25 - cmd)
                    cell = self._cell(grid, pos, r, global_ch)
                    self._set_fx(cell, 0, 0x09, speed)
                    self._set_fx(cell, 1, 0x0F, speed)
                elif cmd == 24:
                    last_row = r
                    if pos != last_pos:
                        self._set_fx(self._cell(grid, pos, r, global_ch), 2, 0x0D, 0)
                    break
                elif 25 <= cmd <= 75:
                    tsp = cmd - 52
            if pos == last_pos:
                cell = self._cell(grid, pos, last_row, global_ch)
                if xloop == 0xFF:
                    self._set_fx(cell, 2, 0xFF, 0)
                elif 0 < xloop <= last_pos:
                    self._set_fx(cell, 2, 0x0B, xloop)

    # ----------------------------------------------------------- wave tracks

    def _setup_wave(self, song: FurSong, rom_kit_name: str):
        rom = load_rom(self.rom_path)
        self._resolver = WaveResolver(WaveMemory(rom, self._load_kit(rom_kit_name)))
        self._voice_instrument: Dict = {}

    def _voice_to_instrument(self, song: FurSong, voice: Voice) -> int:
        if voice.key in self._voice_instrument:
            return self._voice_instrument[voice.key]
        h = voice.header
        pcm = self._resolver.mem.pcm(h)
        # Furnace plays note f at c4_rate * 2^((f-48)/12) (0.6.8.3: note 48
        # = C-4, verified by rendering). We emit f = a, so the sample's C-4
        # rate is the voice's rate transposed from ref_a to note 48.
        c4 = voice.ref_rate * 2.0 ** ((48 - voice.ref_a) / 12.0) * PCM_TUNING_COMP
        loop_start = h.loop if h.loop < h.length else -1
        sample = FurSample(name=f"t{voice.tone} p{voice.key.patch}.{voice.key.split}",
                           c4_rate=max(1, int(round(c4))),
                           loop_start=loop_start, loop_end=h.length if loop_start >= 0 else -1,
                           data=pcm)
        song.samples.append(sample)
        inst = FurSampleInstrument(
            name=f"PCM tone {voice.tone} (patch {voice.key.patch})",
            sample_index=len(song.samples) - 1,
            attack_rate=voice.ar, decay1_rate=voice.d1r, decay_level=voice.dl,
            decay2_rate=voice.d2r, rate_correction=voice.rc, release_rate=voice.rr,
            lfo_speed=voice.lfo, vibrato_depth=voice.vib, tremolo_depth=voice.am)
        song.instruments.append(inst)
        idx = len(song.instruments) - 1
        self._voice_instrument[voice.key] = idx
        return idx

    def _wave_event(self, song, grid, pos, r, fur_ch, state: _WaveTrackState, ev: int,
                    tsp: int, wavnrs: List[int], wavvols: List[int]):
        cell = self._cell(grid, pos, r, fur_ch)
        if 1 <= ev <= 96:
            patch = wavnrs[state.preset] if state.preset < len(wavnrs) else 0
            a = ev - 1
            if self._resolver.patch_obeys_transpose(patch):
                a += tsp
            res = self._resolver.resolve(patch, a)
            if res is None:
                return
            voice, a = res
            note = voice.ref_a if voice.fixed_pitch else a
            if not 0 <= note < 180:
                return
            cell.note = note
            cell.instrument = self._voice_to_instrument(song, voice)
            if state.volume is not None:
                cell.volume = state.volume
                state.volume = None
            if state.pan_nibble is not None:
                self._set_fx(cell, 0, 0x80, PAN_NIBBLE_TO_80XX.get(state.pan_nibble, 0x80))
                state.pan_nibble = None
        elif ev == 97:
            cell.note = FUR_NOTE_OFF
        elif 98 <= ev <= 145:
            state.preset = ev - 98
            if state.preset < len(wavvols):
                state.volume = max(0, 127 - 2 * wavvols[state.preset])
        elif 146 <= ev <= 177:
            vol = 3 + 4 * (ev - 146)
            cell.volume = vol
            state.volume = None
        elif 178 <= ev <= 192:
            self._set_fx(cell, 0, 0x80, PAN_NIBBLE_TO_80XX.get((ev - 185) & 0x0F, 0x80))
            state.pan_nibble = None
        # link / pitch bend / detune / modulation / damp: not translated yet

    # --------------------------------------------------------------------- MFM

    def convert_mfm(self, mfm) -> bytes:
        self.warnings = []
        raw = mfm.raw
        chvol_1 = raw[MFM_CHVOL1]
        n_fm_tracks = 18 - chvol_1
        positions = list(mfm.positions)

        song = self._new_song(mfm.title, mfm.author, mfm.tempo, mfm.hz_equalizer, len(positions))
        global_ch = FUR_CHANNELS - 1          # unused PCM channel carries global fx
        song.effect_cols[global_ch] = GLOBAL_FX_COLS

        # FM instruments: 0-23 = 2-op patches, 24-35 = 4-op patches.
        patches_2op = [MFMOperatorPatch.from_bytes(raw[MFM_2OP_PATCHES + 11 * i:MFM_2OP_PATCHES + 11 * i + 11])
                       for i in range(24)]
        for i, p in enumerate(patches_2op):
            song.instruments.append(FurFMInstrument.from_mfm_instrument(
                SimpleNamespace(primary=p), f"FM {i:02d}"))
        for k in range(12):
            b = raw[MFM_4OP_PATCHES + 22 * k:MFM_4OP_PATCHES + 22 * k + 22]
            inst = SimpleNamespace(primary=MFMOperatorPatch.from_bytes(b[0:10] + b[20:21]),
                                   secondary=MFMOperatorPatch.from_bytes(b[10:20] + b[21:22]))
            song.instruments.append(FurFMInstrument.from_mfm_instrument_4op(inst, f"FM4 {k:02d}"))

        # Track allocation
        fm_tracks: Dict[int, Tuple[int, bool]] = {}
        for s in range(n_fm_tracks):
            if s < chvol_1:
                fm_tracks[s] = (HW_TO_FURNACE_LOGICAL[FOUR_OP_MASTER_HW[s]], True)
            else:
                fm_tracks[s] = (HW_TO_FURNACE_LOGICAL[TWO_OP_HW_ORDER[s - chvol_1]], False)
        used_channels = {ch for ch, _ in fm_tracks.values()} | set(range(PCM_BASE, PCM_BASE + 6))
        song.hidden_channels = set(range(FUR_CHANNELS)) - used_channels

        fm_state = {}
        for s, (ch, is4) in fm_tracks.items():
            init = raw[MFM_INIT_INSTRUMENT + s]
            det = raw[MFM_DETUNE + s]
            fm_state[s] = _FmTrackState(instrument=max(0, init - 1), detune=det - 256 if det > 127 else det)
            song.effect_cols[ch] = 2          # col 0: pan, col 1: detune pitch
            pan = raw[MFM_INIT_PAN + s]
            fm_state[s].pan = {1: 0x00, 2: 0xFF, 3: 0x80}.get(pan, 0x80)

        self._setup_wave(song, raw[MFM_KIT_NAME:MFM_KIT_NAME + 8].decode('ascii', 'replace'))
        wavnrs = list(raw[MFM_XWAVNRS:MFM_XWAVNRS + 32])
        wavvols = list(raw[MFM_XWAVVOLS:MFM_XWAVVOLS + 32])
        wave_state = []
        for k in range(6):
            st = _WaveTrackState(preset=max(0, raw[MFM_INIT_INSTRUMENT + 18 + k] - 1))
            if st.preset < len(wavvols):
                st.volume = max(0, 127 - 2 * wavvols[st.preset])
            st.pan_nibble = raw[MFM_INIT_PAN + 18 + k] & 0x0F
            wave_state.append(st)

        grid = self._grid(len(positions))
        patterns = {p.index: p for p in mfm.patterns}

        def on_row(pos, r, row, tsp):
            for ev in row.events:
                s = ev.channel
                if s not in fm_tracks:
                    continue
                self._fm_event(grid, pos, r, fm_tracks[s], fm_state[s], ev.raw_value, tsp, patches_2op)
            for k, ev in row.wave_events.items():
                self._wave_event(song, grid, pos, r, PCM_BASE + k, wave_state[k], ev, tsp, wavnrs, wavvols)

        self._walk_song(positions, lambda i: patterns[i].rows if i in patterns else [],
                        lambda row: row.command, grid, global_ch, raw[7], on_row)
        self._emit_patterns(song, grid)
        return FurWriter(compress=self.compress).write(song)

    def _fm_event(self, grid, pos, r, track, state: _FmTrackState, ev: int, tsp: int, patches_2op):
        ch, is4 = track
        cell = self._cell(grid, pos, r, ch)
        if 1 <= ev <= 96:
            note = ev - 1 + tsp
            if not 0 <= note < 180:
                return
            cell.note = note
            cell.instrument = (24 + state.instrument) if is4 else state.instrument
            if state.pan is not None:
                self._set_fx(cell, 0, 0x80, state.pan)
                state.pan = None
            pitch = _detune_pitch_effect(note, state.detune) or 0x80
            if pitch != state.last_pitch_fx:
                self._set_fx(cell, 1, 0xE5, pitch)
                state.last_pitch_fx = pitch
        elif ev == 97:
            cell.note = FUR_NOTE_OFF
        elif 98 <= ev <= 121:
            state.instrument = ev - 98
            if is4 and state.instrument > 11:
                state.instrument = 11
        elif 122 <= ev <= 185:
            if is4:
                return   # the player ignores volume on 4-op tracks
            tl = ev - 0x7A
            car_tl = patches_2op[state.instrument].car_ksl_tl & 0x3F
            cell.volume = max(0, min(63, 63 - tl + car_tl))
        elif 186 <= ev <= 188:
            self._set_fx(cell, 0, 0x80, {186: 0x00, 187: 0xFF, 188: 0x80}[ev])
            state.pan = None
        elif 240 <= ev <= 246:
            state.detune = 2 * (ev - 243)     # takes effect on the next note
        # 189-207 / 208-226 / 227-239 / 247-249: not translated yet

    # --------------------------------------------------------------------- MWM

    def convert_mwm(self, mwm) -> bytes:
        self.warnings = []
        raw = mwm.raw
        positions = list(mwm.positions)
        title = raw[MWM_TITLE:MWM_TITLE + 50].decode('ascii', 'replace').strip()

        song = self._new_song(title or mwm.title, mwm.author, mwm.tempo, mwm.hz_equalizer, len(positions))
        global_ch = 0                          # unused FM channel carries global fx
        song.effect_cols[global_ch] = GLOBAL_FX_COLS
        song.hidden_channels = set(range(PCM_BASE))

        self._setup_wave(song, raw[MWM_KIT_NAME:MWM_KIT_NAME + 8].decode('ascii', 'replace'))
        wavnrs = list(raw[MWM_XWAVNRS:MWM_XWAVNRS + 48])
        wavvols = list(raw[MWM_XWAVVOLS:MWM_XWAVVOLS + 48])
        wave_state = []
        for k in range(24):
            st = _WaveTrackState(preset=max(0, raw[MWM_XBEGWAV + k] - 1))
            if st.preset < len(wavvols):
                st.volume = max(0, 127 - 2 * wavvols[st.preset])
            st.pan_nibble = raw[MWM_XWVSTPR + k] & 0x0F
            wave_state.append(st)

        grid = self._grid(len(positions))
        patterns = {p.index: p for p in mwm.patterns}

        def command(row):
            for ev in row.events:
                if ev.channel == 24:
                    return ev.raw_value
            return 0

        def on_row(pos, r, row, tsp):
            for ev in row.events:
                if ev.channel < 24 and ev.raw_value:
                    self._wave_event(song, grid, pos, r, PCM_BASE + ev.channel, wave_state[ev.channel],
                                     ev.raw_value, tsp, wavnrs, wavvols)

        self._walk_song(positions, lambda i: patterns[i].rows if i in patterns else [],
                        command, grid, global_ch, raw[7], on_row)
        self._emit_patterns(song, grid)
        return FurWriter(compress=self.compress).write(song)
