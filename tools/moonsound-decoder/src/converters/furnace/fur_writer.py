"""Furnace .fur file writer.

The exact byte layout implemented here was reverse-engineered from
Furnace's actual C++ loader (src/engine/fileOps/fur.cpp, src/engine/sysDef.cpp)
at tag matching format version 100, and cross-checked by loading the
files this writer produces in the real Furnace binary. Do not "simplify"
field ordering without re-checking against fur.cpp: the reader is a
straight-line sequence of fixed reads gated by `ds.version>=N` checks,
and any field written out of order or with the wrong byte width breaks
loading in a way that produces misleading downstream errors (e.g. a
wrong-offset effect-columns read reports a bogus "too many effect
columns" instead of an alignment error).
"""

import struct
import zlib
from typing import Optional

from .fur_song import FurSong


FUR_MAGIC = b"-Furnace module-"
FUR_VERSION = 100

DIV_MAX_CHIPS = 32


def write_string(s: str) -> bytes:
    """Write null-terminated string."""
    return s.encode('utf-8', errors='replace') + b'\x00'


class FurWriter:
    """Writes Furnace .fur binary files (format version 100)."""

    def __init__(self, version: int = FUR_VERSION, compress: bool = True):
        self.version = version
        self.compress = compress

    def write(self, song: FurSong) -> bytes:
        """Generate complete .fur file from song data."""
        num_channels = song.channel_count()

        content = bytearray()

        # Header (32 bytes total: 16 magic + 2 version + 2 reserved + 4 infoSeek + 8 pad)
        content.extend(FUR_MAGIC)
        content.extend(struct.pack('<H', self.version))
        content.extend(struct.pack('<H', 0))
        content.extend(struct.pack('<I', 32))
        while len(content) < 32:
            content.append(0)

        # Build INFO block with placeholder instrument/pattern pointer tables,
        # then patch in real file offsets once we know where each block lands.
        info, ins_ptr_offsets, smp_ptr_offsets, pat_ptr_offsets = \
            self._build_info_block(song, num_channels)

        content.extend(b"INFO")
        content.extend(struct.pack('<I', len(info)))
        info_start_in_content = len(content)
        content.extend(info)

        instrument_file_offsets = []
        for inst in song.instruments:
            instrument_file_offsets.append(len(content))
            content.extend(b"INS2")
            content.extend(inst.to_furnace_bytes())

        sample_file_offsets = []
        for sample in song.samples:
            sample_file_offsets.append(len(content))
            content.extend(b"SMP2")
            content.extend(sample.to_furnace_bytes())

        pattern_file_offsets = []
        for pattern in song.patterns:
            pattern_file_offsets.append(len(content))
            patr_body = pattern.to_furnace_bytes(song.pattern_length,
                                                 song.effect_cols_for(pattern.channel))
            content.extend(b"PATR")
            content.extend(struct.pack('<I', len(patr_body)))
            content.extend(patr_body)

        # Patch pointers back into the INFO block bytes already written.
        for i, offset_in_info in enumerate(ins_ptr_offsets):
            abs_offset = info_start_in_content + offset_in_info
            struct.pack_into('<I', content, abs_offset, instrument_file_offsets[i])
        for i, offset_in_info in enumerate(smp_ptr_offsets):
            abs_offset = info_start_in_content + offset_in_info
            struct.pack_into('<I', content, abs_offset, sample_file_offsets[i])
        for i, offset_in_info in enumerate(pat_ptr_offsets):
            abs_offset = info_start_in_content + offset_in_info
            struct.pack_into('<I', content, abs_offset, pattern_file_offsets[i])

        content.extend(b"END-")
        content.extend(struct.pack('<I', 0))

        if self.compress:
            return zlib.compress(bytes(content), level=9)
        return bytes(content)

    def _build_info_block(self, song: FurSong, num_channels: int):
        """Build INFO block content for format version 100.

        Returns (info_bytes, ins_pointer_offsets, pattern_pointer_offsets)
        where the latter two are lists of byte offsets *within
        info_bytes* of each 4-byte pointer slot, in song.instruments /
        song.patterns order, so the caller can patch in real file
        offsets after the INS2/PATR blocks are written.
        """
        result = bytearray()

        # --- timing (8 bytes) ---
        result.append(0)                                   # oldTimeBase
        result.append(song.speed & 0xFF)                    # speed1
        result.append(song.speed2 & 0xFF)                   # speed2
        result.append(0)                                    # arpLen
        result.extend(struct.pack('<f', song.tick_rate))    # hz

        # --- pattern/order lengths + highlight (6 bytes) ---
        result.extend(struct.pack('<H', song.pattern_length))
        result.extend(struct.pack('<H', song.order_length))
        result.append(4)    # hilightA
        result.append(16)   # hilightB

        # --- counts (10 bytes) ---
        result.extend(struct.pack('<H', len(song.instruments)))
        result.extend(struct.pack('<H', 0))                  # waveLen
        result.extend(struct.pack('<H', len(song.samples)))  # sampleLen
        result.extend(struct.pack('<I', len(song.patterns)))

        # --- systems: ids / volumes / panning / old-flags (32+32+32+128 bytes) ---
        sys_ids = bytearray(DIV_MAX_CHIPS)
        for i, chip in enumerate(song.chips[:DIV_MAX_CHIPS]):
            sys_ids[i] = chip.chip_id
        result.extend(sys_ids)

        sys_vol = bytearray(DIV_MAX_CHIPS)
        for i, chip in enumerate(song.chips[:DIV_MAX_CHIPS]):
            sys_vol[i] = chip.volume & 0xFF
        result.extend(sys_vol)

        sys_pan = bytearray(DIV_MAX_CHIPS)
        for i, chip in enumerate(song.chips[:DIV_MAX_CHIPS]):
            sys_pan[i] = chip.panning & 0xFF
        result.extend(sys_pan)

        # For version<119 these 32 x 4-byte slots are raw "old flags" values
        # (fed through convertOldFlags), not pointers. Zero = chip defaults.
        result.extend(bytes(DIV_MAX_CHIPS * 4))

        # --- strings ---
        result.extend(write_string(song.name or "Untitled"))
        result.extend(write_string(song.author or ""))

        # --- tuning (version>=33) ---
        result.extend(struct.pack('<f', song.tuning))

        # --- compat flags (version>=37): exactly 20 bytes for v100 ---
        result.extend(bytes([
            0,    # limitSlides
            2,    # linearPitch (0=off,1=pitch only,2=full)
            0,    # loopModality
            0,    # properNoiseLayout (>=43)
            0,    # waveDutyIsVol (>=43)
            1,    # resetMacroOnPorta (>=45)
            1,    # legacyVolumeSlides (>=45)
            1,    # compatibleArpeggio (>=45)
            0,    # noteOffResetsSlides (>=45)
            1,    # targetResetsSlides (>=45)
            0,    # arpNonPorta (>=47)
            0,    # algMacroBehavior (>=47)
            0,    # brokenShortcutSlides (>=49)
            0,    # ignoreDuplicateSlides (>=50)
            0,    # stopPortaOnNoteOff (>=62)
            0,    # continuousVibrato (>=62)
            0,    # brokenDACMode (>=64)
            0,    # oneTickCut (>=65)
            0,    # newInsTriggersInPorta (>=66)
            0,    # arp0Reset (>=69)
        ]))

        # --- pointers: instruments / wavetables / samples / patterns ---
        ins_ptr_offsets = []
        for _ in range(len(song.instruments)):
            ins_ptr_offsets.append(len(result))
            result.extend(struct.pack('<I', 0))   # placeholder, patched by caller
        # wavetables: none
        smp_ptr_offsets = []
        for _ in range(len(song.samples)):
            smp_ptr_offsets.append(len(result))
            result.extend(struct.pack('<I', 0))   # placeholder, patched by caller
        pat_ptr_offsets = []
        for _ in range(len(song.patterns)):
            pat_ptr_offsets.append(len(result))
            result.extend(struct.pack('<I', 0))   # placeholder, patched by caller

        # --- orders: outer loop = channel, inner loop = order position ---
        for ch in range(num_channels):
            for pos in range(song.order_length):
                if pos < len(song.orders) and ch < len(song.orders[pos]):
                    result.append(song.orders[pos][ch] & 0xFF)
                else:
                    result.append(0)

        # --- effect columns per channel ---
        for ch in range(num_channels):
            result.append(song.effect_cols_for(ch))

        # --- version>=39 channel metadata ---
        hidden = getattr(song, 'hidden_channels', None) or set()
        for ch in range(num_channels):
            result.append(0 if ch in hidden else 1)   # chanShow
        for ch in range(num_channels):
            result.append(1 if ch in hidden else 0)   # chanCollapse
        for _ in range(num_channels):
            result.append(0)   # chanName (empty string)
        for _ in range(num_channels):
            result.append(0)   # chanShortName (empty string)
        result.append(0)       # song notes (empty string)

        # --- master volume (version>=59) ---
        result.extend(struct.pack('<f', 1.0))

        # --- extended compat flags (version>=70 block): 28 bytes for v100 ---
        result.extend(bytes(28))

        # --- virtual tempo (version>=96) ---
        result.extend(struct.pack('<H', 150))
        result.extend(struct.pack('<H', 150))

        # --- subsongs (version>=95): name, notes, count of *additional*
        # subsongs (0 = single-subsong file), 3 reserved bytes ---
        result.append(0)   # subsong name
        result.append(0)   # subsong notes
        result.append(0)   # numberOfSubSongs (additional beyond this one)
        result.extend(bytes(3))

        return bytes(result), ins_ptr_offsets, smp_ptr_offsets, pat_ptr_offsets

    def _write_block(self, block_id: bytes, data: bytes) -> bytes:
        """Write a single block with ID and size."""
        result = bytearray()
        result.extend(block_id[:4].ljust(4, b'\x00'))
        result.extend(struct.pack('<I', len(data)))
        result.extend(data)
        return bytes(result)


class FurReader:
    """Reads Furnace .fur files (for verification)."""

    def __init__(self):
        self.version = 0
        self.blocks = {}

    def read(self, data: bytes) -> dict:
        """Parse .fur file and return block data."""
        if len(data) >= 2 and data[0] == 0x78:
            data = zlib.decompress(data)

        if data[:16] != FUR_MAGIC:
            raise ValueError("Invalid Furnace file magic")

        self.version = struct.unpack('<H', data[16:18])[0]
        offset = struct.unpack('<I', data[20:24])[0]   # infoSeek (INFO block)

        self.blocks = {}
        while offset <= len(data) - 8:
            block_id = data[offset:offset + 4].decode('ascii', errors='replace')
            block_size = struct.unpack('<I', data[offset + 4:offset + 8])[0]
            block_data = data[offset + 8:offset + 8 + block_size]

            if block_id not in self.blocks:
                self.blocks[block_id] = []
            self.blocks[block_id].append(block_data)

            offset += 8 + block_size

            if block_id == "END-":
                break

        return {
            'version': self.version,
            'blocks': self.blocks,
        }
