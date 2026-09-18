"""Furnace OPL4 PCM (MultiPCM) instrument and sample definitions.

Layouts follow Furnace's real readers (src/engine/instrument.cpp
readFeatureSM/readFeatureMP, src/engine/sample.cpp readSampleData) and are
verified by round-tripping through the installed Furnace binary. Furnace's
OPL4 plays PCM exclusively from samples embedded in the song (there is no
built-in YRW-801 ROM): a PCM note-on resolves `ins->amiga.getSample(note)`
on a DIV_INS_MULTIPCM instrument, and an index outside [0, sampleLen)
silently leaves the channel mute.
"""

from dataclasses import dataclass
from typing import List, Optional
import struct


DIV_INS_MULTIPCM = 28

DIV_SAMPLE_DEPTH_8BIT = 8
DIV_SAMPLE_DEPTH_12BIT = 14   # OPL4 packed: 3 bytes per 2 samples, copied to chip memory as-is
DIV_SAMPLE_DEPTH_16BIT = 16

# Number of per-sample "render on chip" bitmask words (sample.h
# DIV_MAX_SAMPLE_TYPE).
DIV_MAX_SAMPLE_TYPE = 4


def _feature(code: bytes, payload: bytes) -> bytes:
    return code + struct.pack('<H', len(payload)) + payload


@dataclass
class FurSampleInstrument:
    """OPL4 PCM instrument (DIV_INS_MULTIPCM) bound to one embedded sample.

    Envelope fields are raw OPL4 PCM values (0-15; LFO/VIB/AM 0-7), the
    same values a tone header / MoonBlaster wave preset programs into PCM
    registers 0x98-0xE0.
    """
    name: str = ""
    sample_index: int = -1   # index into song.samples; -1 = no sample (mute)

    attack_rate: int = 15
    decay1_rate: int = 15
    decay_level: int = 0
    decay2_rate: int = 0
    rate_correction: int = 15
    release_rate: int = 15

    lfo_speed: int = 0
    vibrato_depth: int = 0
    tremolo_depth: int = 0

    # Optional pitch macro (Furnace macro code 4): per-tick values,
    # `pitch_mode` 0 = absolute, 1 = relative; `pitch_loop` = loop start
    # index or 255 for none.
    pitch_macro: Optional[List[int]] = None
    pitch_mode: int = 0
    pitch_loop: int = 255
    pitch_speed: int = 1        # ticks per macro step

    def _macro_feature(self) -> bytes:
        vals = self.pitch_macro or []
        body = bytearray(struct.pack('<H', 8))          # macro header length
        body += bytes([4, len(vals), self.pitch_loop & 0xFF, 255,
                       self.pitch_mode, 0x80,            # word size 2 (int16)
                       0, max(1, self.pitch_speed)])     # delay 0, speed
        for v in vals:
            body += struct.pack('<h', max(-32768, min(32767, v)))
        body.append(255)                                 # end of macro list
        return _feature(b"MA", bytes(body))

    def to_furnace_bytes(self) -> bytes:
        """Encode as an "INS2" body (everything after the 4-byte magic)."""
        na_feat = _feature(b"NA", self.name.encode('utf-8', errors='replace') + b"\x00")

        # SM: initSample(S), flags(C: bit1 useSample, bit0 useNoteMap,
        # bit2 useWave), waveLen(C). No note map: every note plays
        # initSample, pitched by the sample's own C-4 rate.
        sm_payload = struct.pack('<hBB', self.sample_index, 0x02, 0)
        sm_feat = _feature(b"SM", sm_payload)

        # MP: ar, d1r, dl, d2r, rr, rc, lfo, vib, am. (A trailing flags
        # byte only exists for format version >= 221; we write v100.)
        mp_payload = bytes([
            self.attack_rate & 15, self.decay1_rate & 15,
            self.decay_level & 15, self.decay2_rate & 15,
            self.release_rate & 15, self.rate_correction & 15,
            self.lfo_speed & 7, self.vibrato_depth & 7,
            self.tremolo_depth & 7,
        ])
        mp_feat = _feature(b"MP", mp_payload)

        body = bytearray()
        body.extend(struct.pack('<H', 0))                # format version (ignored)
        body.extend(struct.pack('<H', DIV_INS_MULTIPCM))
        body.extend(na_feat)
        body.extend(sm_feat)
        body.extend(mp_feat)
        if self.pitch_macro:
            body.extend(self._macro_feature())
        body.extend(b"EN" + struct.pack('<H', 0))

        return struct.pack('<I', len(body)) + bytes(body)


@dataclass
class FurSample:
    """Embedded sample, written as an "SMP2" block.

    `data` holds signed PCM at `depth`: 8-bit, 16-bit little-endian, or
    OPL4-packed 12-bit (then `count` gives the number of samples).
    `c4_rate` is the playback rate Furnace uses for note C-4; the note ->
    rate mapping is c4_rate * 2^((note - C4_NOTE)/12).
    """
    name: str = ""
    c4_rate: int = 44100
    depth: int = DIV_SAMPLE_DEPTH_16BIT
    loop_start: int = -1
    loop_end: int = -1
    data: bytes = b""
    count: Optional[int] = None

    @property
    def num_samples(self) -> int:
        if self.count is not None:
            return self.count
        return len(self.data) // (2 if self.depth == DIV_SAMPLE_DEPTH_16BIT else 1)

    def to_furnace_bytes(self) -> bytes:
        """Encode the SMP2 body (everything after the 4-byte magic,
        starting with the 4-byte block size)."""
        body = bytearray()
        body.extend(self.name.encode('utf-8', errors='replace') + b"\x00")
        body.extend(struct.pack('<I', self.num_samples))
        body.extend(struct.pack('<I', self.c4_rate))      # legacy/compat rate
        body.extend(struct.pack('<I', self.c4_rate))      # center (C-4) rate
        body.append(self.depth)
        body.append(0)   # loop mode (read, ignored before v123: forward)
        body.append(0)   # BRR emphasis (ignored before v129)
        body.append(0)   # dither (ignored before v159)
        body.extend(struct.pack('<i', self.loop_start))
        body.extend(struct.pack('<i', self.loop_end))
        for _ in range(DIV_MAX_SAMPLE_TYPE):
            body.extend(struct.pack('<I', 0xFFFFFFFF))    # render on all chips
        body.extend(self.data)

        return struct.pack('<I', len(body)) + bytes(body)
