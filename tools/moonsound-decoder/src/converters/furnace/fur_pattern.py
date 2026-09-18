"""Furnace pattern data structures."""

from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import struct


# Furnace note values (Furnace 0.6.8.3 internal scale: 0 = C-0, 48 = C-4,
# verified by rendering; MoonBlaster note byte N maps to Furnace note N-1).
FUR_NOTE_EMPTY = -1
FUR_NOTE_OFF = 180


@dataclass
class FurEffect:
    """Single effect in a pattern row."""
    code: int = -1     # -1 = empty, 0x00-0xFF = effect code
    value: int = -1    # -1 = empty, 0x00-0xFF = effect value

    def is_empty(self) -> bool:
        return self.code < 0


@dataclass
class FurPatternRow:
    """Single row in a pattern channel."""
    note: int = FUR_NOTE_EMPTY       # -1 empty, 0-179 note, 180 off
    instrument: int = -1             # -1=empty, 0-255=instrument
    volume: int = -1                 # -1=empty, 0-127=volume
    effects: List[FurEffect] = field(default_factory=list)

    def __post_init__(self):
        if not self.effects:
            self.effects = [FurEffect()]

    def is_empty(self) -> bool:
        return (self.note == FUR_NOTE_EMPTY and
                self.instrument < 0 and
                self.volume < 0 and
                all(e.is_empty() for e in self.effects))


@dataclass
class FurPattern:
    """Pattern data for a single channel."""
    channel: int = 0
    index: int = 0
    rows: List[FurPatternRow] = field(default_factory=list)

    def to_furnace_bytes(self, row_count: int, effect_cols: int = 1) -> bytes:
        """Encode pattern body for a Furnace "PATR" (old/legacy) block.

        This is the pre-v157 row format used by fur.cpp's old-format
        pattern reader: chan(S) index(S) subs(S) reserved(S), then for
        each row: note(S) octave(S) ins(S) vol(S) [fx(S) fxval(S)]*effect_cols,
        followed by an optional pattern name string (version>=51).

        Every field is a *signed* 16-bit little-endian integer; -1 means
        "empty" for ins/vol/fx/fxval. NOTE ON NOTE/OCTAVE ENCODING: current
        GitHub master's fur.cpp reconstructs DIV_PAT_NOTE via
        `splitNoteToNote` as note+octave*12+60, but the actually-installed
        Furnace release (0.6.8.3/format 232) used during development here
        was empirically verified (round-tripping test files through the
        real binary with -view commands/-cmdout) to instead use plain
        note+octave*12 with NO +60 term - i.e. write note=target,octave=0
        directly. Sentinels: note=100 (any octave) -> NOTE_OFF and
        note=0&&octave==0 -> empty, so real notes 100 and 0 are written as
        88/+1 and 12/-1 (note + octave*12 still equals the target).
        """
        result = bytearray()

        result.extend(struct.pack('<H', self.channel))
        result.extend(struct.pack('<H', self.index))
        result.extend(struct.pack('<H', 0))   # subsong
        result.extend(struct.pack('<H', 0))   # reserved

        for i in range(row_count):
            row = self.rows[i] if i < len(self.rows) else FurPatternRow()

            if row.note == FUR_NOTE_EMPTY:
                note, octave = 0, 0
            elif row.note == FUR_NOTE_OFF:
                note, octave = 100, 0
            elif row.note == 100:
                note, octave = 88, 1          # 100 alone would read as NOTE_OFF
            elif row.note == 0:
                note, octave = 12, -1         # 0/0 would read as empty
            else:
                note, octave = row.note, 0

            result.extend(struct.pack('<h', note))
            result.extend(struct.pack('<h', octave))
            result.extend(struct.pack('<h', row.instrument if row.instrument >= 0 else -1))
            result.extend(struct.pack('<h', row.volume if row.volume >= 0 else -1))

            for k in range(effect_cols):
                if k < len(row.effects) and not row.effects[k].is_empty():
                    eff = row.effects[k]
                    result.extend(struct.pack('<h', eff.code))
                    result.extend(struct.pack('<h', eff.value))
                else:
                    result.extend(struct.pack('<h', -1))
                    result.extend(struct.pack('<h', -1))

        result.append(0)  # pattern name (empty string, version>=51)

        return bytes(result)
