"""Tick-exact pitch simulation of MoonBlaster wave (PCM) tracks.

Mirrors the reference players (mwm_player.asm; the MFM player's wave tracks
use the same routines). Every interrupt tick:

  1. MBPlayer_play_pitch runs for every track in bend / modulation mode:
       bend (mode 1):   word += speed            (speed = 4*(N-221))
       modulation (2-4): word += 4*sext6(tbl[p]); p++; tbl[p] == 10 -> p = start
     with the player's octave carry (carry_add).
  2. On row ticks, the row's events are applied after that:
       note      word = note word + detune; mode off
       link      word = same-split word for n + (N-202) + detune; mode off
       bend      mode 1                      detune    det = 4*(N-234)
       modulation mode N-236 (table N-238)   off / preset / pan / damp: mode off

A row lasts `speed` ticks (the speed after the row's own tempo command).
Detune starts at 2 * the song's per-track initial detune byte.

simulate() returns, for every note-on, the note's pitch (Hz) at each tick
from its key-on until the next note on the same track.
"""

from typing import Callable, Dict, Iterable, List, Optional, Tuple

from .opl4_wave import WaveResolver, Voice, carry_add, word_rate

MAX_TICKS_PER_NOTE = 2048


def sext8(v: int) -> int:
    v &= 0xFF
    return v - 256 if v & 0x80 else v


class _Track:
    __slots__ = ("preset", "det", "word", "mode", "speed", "ptr", "ctx", "rates")

    def __init__(self, preset: int, det: int):
        self.preset = preset
        self.det = det
        self.word: Optional[int] = None
        self.mode = 0
        self.speed = 0
        self.ptr = 0
        self.ctx = None
        self.rates: Optional[List[float]] = None


def played_rows(positions, rows_of: Callable, command_of: Callable, tempo: int):
    """Yield (pos, row_index, row, cmd, transpose, ticks) in play order, with
    the player's command semantics: 1-23 speed = 25-cmd (applies to this
    row), 24 ends the pattern after this row, 25-75 transpose = cmd-52 from
    the next row."""
    tsp, speed = 0, max(1, tempo)
    for pos, idx in enumerate(positions):
        rows = rows_of(idx)
        for r in range(16):
            row = rows[r] if r < len(rows) else None
            cmd = command_of(row) if row is not None else 0
            if 1 <= cmd <= 23:
                speed = max(1, 25 - cmd)
            yield pos, r, row, cmd, tsp, speed
            if cmd == 24:
                break
            if 25 <= cmd <= 75:
                tsp = cmd - 52


def simulate(resolver: WaveResolver, rows: Iterable, wave_events_of: Callable,
             n_tracks: int, wavnrs: List[int], init_presets: List[int],
             init_detune: List[int], modtab: bytes
             ) -> Dict[Tuple[int, int, int], Tuple[Voice, int, List[float]]]:
    """rows: output of played_rows(); wave_events_of(row) -> {track: byte}.
    Returns {(pos, row, track): (voice, a, per-tick rates)} for each note."""
    tracks = [_Track(init_presets[k], sext8(2 * init_detune[k])) for k in range(n_tracks)]
    notes: Dict[Tuple[int, int, int], Tuple[Voice, int, List[float]]] = {}

    def tbl(i: int) -> int:
        return modtab[i] if 0 <= i < len(modtab) else 0

    for pos, r, row, cmd, tsp, ticks in rows:
        events = wave_events_of(row) if row is not None else {}
        for tick in range(ticks):
            # 1. per-tick pitch routine
            for t in tracks:
                if t.word is None or not t.mode:
                    continue
                if t.mode == 1:
                    t.word = carry_add(t.word, t.speed)
                else:
                    b = tbl(t.ptr)
                    e = (b << 2) & 0xFF
                    delta = e - 256 if b & 0x40 else e
                    t.ptr += 1
                    if tbl(t.ptr) == 10:
                        t.ptr = (t.mode - 2) * 16
                    t.word = carry_add(t.word, delta)
            # 2. row events on the row tick
            if tick == 0:
                for k, ev in events.items():
                    if k >= n_tracks or not ev:
                        continue
                    t = tracks[k]
                    if 1 <= ev <= 96:
                        patch = wavnrs[t.preset] if t.preset < len(wavnrs) else 0
                        a = ev - 1
                        if resolver.patch_obeys_transpose(patch):
                            a += tsp
                        res = resolver.note_word(patch, a)
                        t.mode = 0
                        if res is None:
                            t.word, t.ctx, t.rates = None, None, None
                            continue
                        voice, word, ctx = res
                        t.word = carry_add(word, 2 * t.det)
                        t.ctx = ctx
                        t.rates = []
                        notes[(pos, r, k)] = (voice, a & 0xFF, t.rates)
                    elif ev in (97,) or 178 <= ev <= 192 or 241 <= ev <= 242:
                        t.mode = 0
                    elif 98 <= ev <= 145:
                        t.preset = ev - 98
                        t.mode = 0
                    elif 193 <= ev <= 211:
                        t.mode = 0
                        if t.ctx is not None and t.word is not None:
                            kind, table, n = t.ctx
                            n2 = (n + ev - 202) & 0xFF
                            # link adds detune without the octave carry
                            t.word = (resolver.link_word(t.ctx, n2) + 2 * t.det) & 0xFFFF
                            t.ctx = (kind, table, n2)
                    elif 212 <= ev <= 230:
                        t.mode = 1
                        t.speed = sext8(4 * (ev - 221))
                    elif 231 <= ev <= 237:
                        t.det = sext8(4 * (ev - 234))
                    elif 238 <= ev <= 240:
                        t.mode = ev - 236
                        t.ptr = (ev - 238) * 16
            # 3. record the sounding pitch of each track's current note
            for t in tracks:
                if t.rates is not None and t.word is not None and len(t.rates) < MAX_TICKS_PER_NOTE:
                    t.rates.append(word_rate(t.word))
    return notes
