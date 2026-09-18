"""OPL4 wavetable resolution for MoonBlaster Wave songs.

Reproduces how the reference player (mwm_player.asm: MBPlayer_calc_wave,
MBPlayer_calc_drm and the RAM-kit path) turns a wave preset + note into an
OPL4 PCM tone and pitch, and extracts the tone's waveform as 16-bit PCM:

  preset -> patch p = xwavnrs[preset]
    p 0..174  ROM patch: key splits [bound, tone, tnote, fnum table];
              first split with a < bound; n = tnote + a - lo
    p 175     GM drum kit: a < 36 -> DRUM_MIDI patch, else GM_DRUMS[a-36]
              (per-note tone + register freq word)
    p >= 176  MWK kit wave w = p-176: eight [bound, x, tnote] splits,
              tone 384+x, freq word = RAM table[n] (Amiga / 44.1k / Turbo-R)

  ROM pitch: oct = n//12 - 5, F = fnums[n%12] (>=2048: oct+1, F-2048)
  rate = 44100 * 2^oct * (1024 + F) / 1024   (33.8688 MHz / 768 base)

Tone headers (12 bytes; ROM at 0, RAM kit tones 384+ at 0x200000):
  b0 bits7-6 format (0=8, 1=12, 2=16 bit), b0-b2 22-bit start address,
  b3-b4 loop (BE), b5-b6 end (length = 0x10000 - raw), b7 LFO/VIB,
  b8 AR/D1R, b9 DL/D2R, b10 RC/RR, b11 AM.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
import os
import struct

from . import moonblaster_tables as T

REPO_ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
DEFAULT_ROM_PATH = os.path.join(REPO_ROOT, 'hardware', 'firmware', 'YRW801-M - Yamaha - 1993.rom')

PATCH_DRUMS = 175
PATCH_KIT_BASE = 176
RAM_TONE_BASE = 384


def fw_to_rate(freq_word: int) -> float:
    """Rate of an OPL4 PCM register word (oct<<12 | F<<1)."""
    octave = (((freq_word >> 12) & 0xF) ^ 8) - 8
    fnum = (freq_word >> 1) & 0x3FF
    return 44100.0 * (2.0 ** octave) * (1024 + fnum) / 1024.0


def rom_note_rate(n: int, fnums: List[int]) -> float:
    octave = n // 12 - 5
    fnum = fnums[n % 12]
    if fnum >= 2048:
        octave += 1
        fnum -= 2048
    return 44100.0 * (2.0 ** octave) * (1024 + fnum) / 1024.0


@dataclass
class ToneHeader:
    tone: int
    bits: int           # 8, 12 or 16
    start: int
    loop: int
    length: int
    lfo: int
    vib: int
    ar: int
    d1r: int
    dl: int
    d2r: int
    rc: int
    rr: int
    am: int

    @classmethod
    def parse(cls, tone: int, h: bytes) -> 'ToneHeader':
        fmt = h[0] >> 6
        return cls(
            tone=tone,
            bits={0: 8, 1: 12, 2: 16}.get(fmt, 12),   # fmt 3: ymfm treats as 12-bit
            start=((h[0] & 0x3F) << 16) | (h[1] << 8) | h[2],
            loop=(h[3] << 8) | h[4],
            length=0x10000 - ((h[5] << 8) | h[6]),
            lfo=(h[7] >> 3) & 7, vib=h[7] & 7,
            ar=h[8] >> 4, d1r=h[8] & 15,
            dl=h[9] >> 4, d2r=h[9] & 15,
            rc=h[10] >> 4, rr=h[10] & 15,
            am=h[11] & 7,
        )


def decode_pcm(mem: bytes, start: int, bits: int, count: int) -> bytes:
    """Decode OPL4 wave memory to 16-bit signed little-endian PCM."""
    out = bytearray()
    if bits == 8:
        for i in range(count):
            b = mem[start + i] if start + i < len(mem) else 0
            out += struct.pack('<h', (b - 256 if b & 0x80 else b) << 8)
    elif bits == 16:
        for i in range(count):
            a = start + 2 * i
            v = (mem[a] << 8) | mem[a + 1] if a + 1 < len(mem) else 0
            out += struct.pack('<h', v - 0x10000 if v & 0x8000 else v)
    else:
        # 12-bit: 3 bytes hold 2 samples (ymfm order):
        #   s0 = b0<<8 | (b1 & 0x0F)<<4,  s1 = b2<<8 | (b1 & 0xF0)
        for i in range(count):
            a = start + (i // 2) * 3
            if a + 2 >= len(mem):
                out += b'\x00\x00'
                continue
            b0, b1, b2 = mem[a], mem[a + 1], mem[a + 2]
            v = (b0 << 8) | ((b1 & 0x0F) << 4) if i % 2 == 0 else (b2 << 8) | (b1 & 0xF0)
            out += struct.pack('<h', v - 0x10000 if v & 0x8000 else v)
    return bytes(out)


class WaveMemory:
    """OPL4 wave address space: YRW-801 ROM (tones 0-383) plus an optional
    MWK sample kit loaded as RAM tones 384+ (headers at 0x200000)."""

    def __init__(self, rom: bytes, kit: Optional['MwkKit'] = None):
        self.rom = rom
        self.kit = kit

    def header(self, tone: int) -> ToneHeader:
        if tone >= RAM_TONE_BASE:
            if not self.kit:
                raise KeyError(f'tone {tone} needs a sample kit (.MWK), none loaded')
            return self.kit.header(tone)
        return ToneHeader.parse(tone, self.rom[12 * tone:12 * tone + 12])

    def pcm(self, h: ToneHeader) -> bytes:
        if h.tone >= RAM_TONE_BASE:
            return self.kit.pcm(h)
        return decode_pcm(self.rom, h.start, h.bits, h.length)


class MwkKit:
    """MoonBlaster Wave Kit (.MWK): 'MBMS' 0x10 0x0D, 24-bit total size,
    count, tones_data[64] (bit0 present, bits2-1 freq table, bit7 16-bit),
    `count` 25-byte wave records, then per tone: 2 pad bytes, 9 header
    bytes (b3-b11), LE16 length, raw data. The player packs the data into
    RAM from 0x200300 in tone order and writes 12-byte headers at
    0x200000 + 12*i."""

    def __init__(self, data: bytes):
        if data[:4] != b'MBMS':
            raise ValueError('not an MWK file')
        self.count = data[9]
        self.tones_data = list(data[0x0A:0x4A])
        self.wave_records = [data[0x4A + 25 * i:0x4A + 25 * i + 25] for i in range(self.count)]
        self._headers: Dict[int, ToneHeader] = {}
        self._data: Dict[int, bytes] = {}
        p = 0x4A + 25 * self.count
        addr = 0x200300
        for i in range(self.count):
            h9 = data[p + 2:p + 11]
            ln = data[p + 11] | (data[p + 12] << 8)
            raw = data[p + 13:p + 13 + ln]
            # tones_data bit 7 selects 16-bit; otherwise the kit data is 8-bit
            fmt = 0x80 if self.tones_data[i] & 0x80 else 0x00
            hdr = bytes([fmt | ((addr >> 16) & 0x3F), (addr >> 8) & 0xFF, addr & 0xFF]) + h9
            tone = RAM_TONE_BASE + i
            self._headers[tone] = ToneHeader.parse(tone, hdr)
            self._data[tone] = raw
            p += 13 + ln
            addr += ln

    def header(self, tone: int) -> ToneHeader:
        return self._headers[tone]

    def pcm(self, h: ToneHeader) -> bytes:
        raw = self._data[h.tone]
        return decode_pcm(raw, 0, h.bits, h.length)

    def freq_table(self, x: int) -> List[int]:
        sel = self.tones_data[x] & 6
        return T.FRQTAB_AMIGA if sel == 0 else T.FRQTAB_44K if sel == 2 else T.FRQTAB_TURBO


@dataclass(frozen=True)
class VoiceKey:
    """Identifies one (patch, split) voice: a fixed tone + fixed tuning."""
    patch: int
    split: int


@dataclass
class Voice:
    key: VoiceKey
    tone: int
    header: ToneHeader
    # rate(a) = ref_rate * 2^((a - ref_a)/12) for notes a in this split;
    # fixed_pitch voices (GM drums) always play at ref_rate.
    ref_a: int
    ref_rate: float
    obeys_transpose: bool
    fixed_pitch: bool
    # envelope after the patch's register overrides
    ar: int
    d1r: int
    dl: int
    d2r: int
    rc: int
    rr: int
    lfo: int
    vib: int
    am: int


def _apply_overrides(h: ToneHeader, lfo_vib: Optional[int], regs) -> dict:
    env = dict(ar=h.ar, d1r=h.d1r, dl=h.dl, d2r=h.d2r, rc=h.rc, rr=h.rr, lfo=h.lfo, vib=h.vib, am=h.am)
    if lfo_vib is not None and lfo_vib:
        env['lfo'], env['vib'] = (lfo_vib >> 3) & 7, lfo_vib & 7
    for reg, val in regs or []:
        if reg == 0x98:
            env['ar'], env['d1r'] = val >> 4, val & 15
        elif reg == 0xB0:
            env['dl'], env['d2r'] = val >> 4, val & 15
        elif reg == 0xC8:
            env['rc'], env['rr'] = val >> 4, val & 15
        elif reg == 0xE0:
            env['am'] = val & 7
    return env


class WaveResolver:
    """Resolves (patch, note a = N-1 [+transpose]) -> (Voice, a)."""

    def __init__(self, mem: WaveMemory):
        self.mem = mem
        self._voices: Dict[VoiceKey, Voice] = {}

    def _voice(self, key: VoiceKey, tone: int, ref_a: int, ref_rate: float,
               obeys_transpose: bool, lfo_vib, regs, fixed_pitch: bool = False) -> Voice:
        if key not in self._voices:
            h = self.mem.header(tone)
            env = _apply_overrides(h, lfo_vib, regs)
            self._voices[key] = Voice(key=key, tone=tone, header=h, ref_a=ref_a,
                                      ref_rate=ref_rate, obeys_transpose=obeys_transpose,
                                      fixed_pitch=fixed_pitch, **env)
        return self._voices[key]

    @staticmethod
    def _find_split(splits, a):
        lo = 0
        for i, s in enumerate(splits):
            if a < s[0]:
                return i, lo, s
            lo = s[0]
        return len(splits) - 1, lo, splits[-1]

    def patch_obeys_transpose(self, patch: int) -> bool:
        if patch < PATCH_DRUMS:
            return bool(T.PATCHES[patch]['flag'] & 1)
        if patch == PATCH_DRUMS:
            return False
        rec = self.mem.kit.wave_records[patch - PATCH_KIT_BASE] if self.mem.kit else b'\x00'
        return bool(rec[0] & 1)

    def resolve(self, patch: int, a: int) -> Optional[Tuple[Voice, int]]:
        """Returns (voice, a) where a is the (already transposed) note index
        used to pick the split; the Furnace note is chosen by the caller."""
        a &= 0xFF
        if patch < PATCH_DRUMS or (patch == PATCH_DRUMS and a < 36):
            rec = T.PATCHES[patch] if patch < PATCH_DRUMS else T.DRUM_MIDI
            idx, lo, (bound, tone, tnote, fnums) = self._find_split(rec['splits'], a)
            n = (tnote + a - lo) & 0xFF
            return self._voice(VoiceKey(patch, idx), tone, a, rom_note_rate(n, fnums),
                               bool(rec['flag'] & 1), rec['lfo_vib'], rec['regs']), a
        if patch == PATCH_DRUMS:
            aa = min(a, 0x56)
            tone, fw, lfo_vib, regs = T.GM_DRUMS[aa - 36]
            # every drum note is its own voice with a fixed pitch
            return self._voice(VoiceKey(patch, 1000 + aa), tone, aa, fw_to_rate(fw),
                               False, lfo_vib, regs, fixed_pitch=True), a
        kit = self.mem.kit
        if not kit:
            return None
        rec = kit.wave_records[patch - PATCH_KIT_BASE]
        splits = [(rec[1 + 3 * i], rec[2 + 3 * i], rec[3 + 3 * i]) for i in range(8)]
        lo = 0
        for idx, (bound, x, tnote) in enumerate(splits):
            if a < bound or bound == 255 or idx == 7:
                break
            lo = bound
        n = (tnote + a - lo) & 0xFF
        table = kit.freq_table(x)
        fw = table[min(n, len(table) - 1)]
        return self._voice(VoiceKey(patch, idx), RAM_TONE_BASE + x, a, fw_to_rate(fw),
                           bool(rec[0] & 1), None, None), a

    def voices(self) -> List[Voice]:
        return list(self._voices.values())


def load_rom(path: Optional[str] = None) -> bytes:
    path = path or DEFAULT_ROM_PATH
    with open(path, 'rb') as f:
        return f.read()
