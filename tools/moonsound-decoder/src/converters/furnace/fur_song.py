"""Furnace song-level data structures."""

from dataclasses import dataclass, field
from typing import List
import struct


# Furnace chip IDs (as used in the .fur file format's system ID byte,
# per src/engine/sysDef.cpp sysDefs[...]->id -- NOT the same as DivSystem enum)
FUR_CHIP_OPL4 = 0xAE       # 42 channels (18 FM + 24 PCM)
FUR_CHIP_OPL4_DRUMS = 0xAF
FUR_CHIP_OPL3 = 0x91       # 18 channels (FM only)
FUR_CHIP_OPL2 = 0x90       # 9 channels


@dataclass
class FurChip:
    """Sound chip configuration."""
    chip_id: int = FUR_CHIP_OPL4
    volume: int = 64           # 0-127, 64=1.0
    panning: int = 0           # -128 to 127
    flags: bytes = b'\x00\x00\x00\x00'  # Chip-specific flags (4 bytes)


@dataclass
class FurSong:
    """Complete Furnace song data."""
    name: str = ""
    author: str = ""
    album: str = ""
    system_name: str = "OPL4"

    # Timing
    tempo: float = 150.0       # BPM (ticks per second)
    speed: int = 6             # Speed 1
    speed2: int = 6            # Speed 2
    pattern_length: int = 64   # Rows per pattern

    # Arrangement
    orders: List[List[int]] = field(default_factory=list)
    order_length: int = 0

    # Content
    chips: List[FurChip] = field(default_factory=list)
    instruments: List = field(default_factory=list)
    patterns: List = field(default_factory=list)
    samples: List = field(default_factory=list)

    # Settings
    tick_rate: float = 60.0
    tuning: float = 440.0       # A-4 reference in Hz
    # Furnace logical channel indices to hide/collapse in the editor
    # (e.g. the unused FM section 0-17 of a pure-MWM OPL4 export).
    hidden_channels: set = field(default_factory=set)
    # Per-channel effect column count overrides (default 1, max 8).
    effect_cols: dict = field(default_factory=dict)

    def effect_cols_for(self, channel: int) -> int:
        return self.effect_cols.get(channel, 1)

    def channel_count(self) -> int:
        """Total channels across all chips.

        Must match Furnace's own getChannelCount(DIV_SYSTEM_*) exactly -
        the reader derives tchans purely from the system ID byte(s) it
        reads, independent of anything else in the file, so every
        fixed-per-channel section we write (orders, effectCols, chanShow,
        chanCollapse, chanName, chanShortName) must be sized to match or
        the whole rest of the file desyncs (observed as garbage/zero
        effectCols values downstream).
        """
        count = 0
        for chip in self.chips:
            if chip.chip_id == FUR_CHIP_OPL4:
                count += 42  # 18 FM + 24 PCM
            elif chip.chip_id == FUR_CHIP_OPL4_DRUMS:
                count += 44
            elif chip.chip_id == FUR_CHIP_OPL3:
                count += 18
            elif chip.chip_id == FUR_CHIP_OPL2:
                count += 9
        return max(count, 1)
