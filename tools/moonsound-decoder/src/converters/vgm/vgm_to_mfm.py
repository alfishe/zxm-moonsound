"""VGM to MFM converter - reconstructs tracker data from register logs."""

from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Optional
from collections import defaultdict

from src.mfm_assembler import (
    MFMAssembler, MFMAssemblerData, AssemblerPattern, AssemblerRow, AssemblerEvent,
    AssemblerInstrument, AssemblerOperatorPatch
)
from .vgm_reader import VGMData


SAMPLES_PER_FRAME = 735  # 60 Hz


@dataclass
class ChannelState:
    """Tracks state of a single FM channel."""
    fnum: int = 0
    block: int = 0
    key_on: bool = False
    instrument_hash: int = 0
    volume: int = 63


@dataclass
class DetectedNote:
    """Note event detected from register analysis."""
    time: int
    channel: int
    note_index: int  # MFM note (0-95)
    is_on: bool
    instrument: int = -1
    volume: int = -1


class VGMToMFM:
    """Converts VGM OPL4 register log back to MFM pattern format."""

    def __init__(self):
        self.channels: Dict[int, ChannelState] = {}
        self.instruments: Dict[int, AssemblerInstrument] = {}  # hash → instrument
        self.instrument_list: List[AssemblerInstrument] = []
        self.notes: List[DetectedNote] = []
        self.tempo: int = 6

        # Pending operator writes (to detect full instrument changes)
        self._pending_ops: Dict[int, Dict[int, int]] = defaultdict(dict)

    def convert(self, vgm: VGMData) -> MFMAssemblerData:
        """Convert VGM to MFM assembler data."""
        # Initialize channel state
        for ch in range(18):
            self.channels[ch] = ChannelState()

        # Detect tempo from wait patterns
        self.tempo = self._detect_tempo(vgm)

        # Process OPL4 FM writes
        fm_writes = [(t, p, r, v) for t, p, r, v in vgm.opl4_writes if p < 2]

        for time, port, reg, val in fm_writes:
            self._process_fm_write(time, port, reg, val)

        # Build MFM data
        return self._build_mfm_data(vgm)

    def _detect_tempo(self, vgm: VGMData) -> int:
        """Detect MFM tempo from VGM timing."""
        # Find most common wait pattern
        wait_counts = defaultdict(int)

        for cmd in vgm.commands:
            if cmd.wait > 0:
                # Quantize to frames
                frames = round(cmd.wait / SAMPLES_PER_FRAME)
                if frames > 0:
                    wait_counts[frames] += 1

        if not wait_counts:
            return 6

        # Most common frame count is likely the tempo
        common_wait = max(wait_counts, key=wait_counts.get)
        return max(1, min(15, common_wait))

    def _process_fm_write(self, time: int, port: int, reg: int, val: int):
        """Process a single FM register write."""
        # Calculate channel from register
        channel_base = self._reg_to_channel(reg)
        if channel_base is None or channel_base < 0:
            return

        channel = channel_base + (9 if port == 1 else 0)

        if channel >= 18:
            return

        state = self.channels[channel]

        # F-num low (0xA0-0xA8)
        if 0xA0 <= reg <= 0xA8:
            state.fnum = (state.fnum & 0x300) | val

        # Key-on, block, F-num high (0xB0-0xB8)
        elif 0xB0 <= reg <= 0xB8:
            old_key = state.key_on
            state.key_on = bool(val & 0x20)
            state.block = (val >> 2) & 0x07
            state.fnum = (state.fnum & 0xFF) | ((val & 0x03) << 8)

            # Detect note on/off
            if state.key_on and not old_key:
                note_index = self._fnum_to_note(state.fnum, state.block)
                self.notes.append(DetectedNote(
                    time=time, channel=channel,
                    note_index=note_index, is_on=True
                ))
            elif not state.key_on and old_key:
                self.notes.append(DetectedNote(
                    time=time, channel=channel,
                    note_index=0, is_on=False
                ))

        # Operator registers - track for instrument detection
        elif 0x20 <= reg <= 0x35:  # AM/VIB/EG/KSR/MULT
            self._pending_ops[channel][reg] = val
        elif 0x40 <= reg <= 0x55:  # KSL/TL
            self._pending_ops[channel][reg] = val
            # Volume from carrier TL
            if self._is_carrier_reg(reg):
                state.volume = 63 - (val & 0x3F)
        elif 0x60 <= reg <= 0x75:  # AR/DR
            self._pending_ops[channel][reg] = val
        elif 0x80 <= reg <= 0x95:  # SL/RR
            self._pending_ops[channel][reg] = val
        elif 0xC0 <= reg <= 0xC8:  # FB/Connection
            self._pending_ops[channel][reg] = val
            # Full instrument written - create/find instrument
            self._finalize_instrument(channel)
        elif 0xE0 <= reg <= 0xF5:  # Waveform
            self._pending_ops[channel][reg] = val

    def _reg_to_channel(self, reg: int) -> int:
        """Get channel base (0-8) from register address."""
        if 0xA0 <= reg <= 0xA8:
            return reg - 0xA0
        elif 0xB0 <= reg <= 0xB8:
            return reg - 0xB0
        elif 0xC0 <= reg <= 0xC8:
            return reg - 0xC0
        elif 0x20 <= reg <= 0x35:
            slot = reg - 0x20
            return [0, 1, 2, 0, 1, 2, None, None, 3, 4, 5, 3, 4, 5, None, None, 6, 7, 8, 6, 7, 8][slot] if slot < 22 else -1
        elif 0x40 <= reg <= 0x55:
            return self._reg_to_channel(reg - 0x20)
        elif 0x60 <= reg <= 0x75:
            return self._reg_to_channel(reg - 0x40)
        elif 0x80 <= reg <= 0x95:
            return self._reg_to_channel(reg - 0x60)
        elif 0xE0 <= reg <= 0xF5:
            return self._reg_to_channel(reg - 0xC0)
        return -1

    def _is_carrier_reg(self, reg: int) -> bool:
        """Check if register is for carrier operator."""
        if 0x40 <= reg <= 0x55:
            slot = reg - 0x40
            # Carrier slots: 3,4,5 and 11,12,13 and 19,20,21
            return slot in (3, 4, 5, 11, 12, 13, 19, 20, 21)
        return False

    def _fnum_to_note(self, fnum: int, block: int) -> int:
        """Convert F-number and block to MFM note index."""
        if fnum == 0:
            return 0

        # OPL4 clock / 288 = 117600
        # freq = fnum * 117600 / 2^(20-block)
        freq = (fnum * 117600) / (1 << (20 - block))

        # Convert frequency to note
        # C-1 = 8.175 Hz = note 0
        if freq <= 0:
            return 0

        import math
        note = 12 * math.log2(freq / 8.175798915643707)
        note_index = max(0, min(95, round(note)))

        return note_index

    def _finalize_instrument(self, channel: int):
        """Create instrument from pending operator writes."""
        ops = self._pending_ops.get(channel, {})
        if not ops:
            return

        # Build instrument from operator data
        inst = self._build_instrument_from_ops(ops)

        # Hash for deduplication
        inst_hash = hash(tuple(sorted(ops.items())))

        if inst_hash not in self.instruments:
            self.instruments[inst_hash] = inst
            self.instrument_list.append(inst)

        self.channels[channel].instrument_hash = inst_hash
        self._pending_ops[channel] = {}

    def _build_instrument_from_ops(self, ops: Dict[int, int]) -> AssemblerInstrument:
        """Build AssemblerInstrument from operator register values."""
        inst = AssemblerInstrument()

        # Extract modulator and carrier values
        # This is simplified - full extraction would need all registers
        for reg, val in ops.items():
            if 0x20 <= reg <= 0x35:
                slot = reg - 0x20
                if slot < 3:  # Modulator
                    inst.primary.mod_am_vib_eg_ksr_mult = val
                else:  # Carrier
                    inst.primary.car_am_vib_eg_ksr_mult = val
            elif 0x40 <= reg <= 0x55:
                slot = reg - 0x40
                if slot < 3:
                    inst.primary.mod_ksl_tl = val
                else:
                    inst.primary.car_ksl_tl = val
            elif 0x60 <= reg <= 0x75:
                slot = reg - 0x60
                if slot < 3:
                    inst.primary.mod_ar_dr = val
                else:
                    inst.primary.car_ar_dr = val
            elif 0x80 <= reg <= 0x95:
                slot = reg - 0x80
                if slot < 3:
                    inst.primary.mod_sl_rr = val
                else:
                    inst.primary.car_sl_rr = val
            elif 0xC0 <= reg <= 0xC8:
                inst.primary.feedback_connection = val
            elif 0xE0 <= reg <= 0xF5:
                slot = reg - 0xE0
                if slot < 3:
                    inst.primary.mod_waveform = val
                else:
                    inst.primary.car_waveform = val

        return inst

    def _build_mfm_data(self, vgm: VGMData) -> MFMAssemblerData:
        """Build MFM assembler data from detected notes."""
        data = MFMAssemblerData()
        data.tempo = self.tempo

        # Add instruments
        for inst in self.instrument_list[:24]:  # MFM max 24 instruments
            data.instruments.append(inst)

        # Convert notes to patterns
        samples_per_row = self.tempo * SAMPLES_PER_FRAME

        # Group notes by row
        rows_by_time: Dict[int, List[DetectedNote]] = defaultdict(list)
        for note in self.notes:
            row_idx = note.time // samples_per_row
            rows_by_time[row_idx].append(note)

        # Build patterns (64 rows each)
        max_row = max(rows_by_time.keys()) if rows_by_time else 0
        num_patterns = (max_row // 64) + 1

        for pat_idx in range(num_patterns):
            pattern = AssemblerPattern(index=pat_idx)

            for row_idx in range(64):
                global_row = pat_idx * 64 + row_idx
                row = AssemblerRow(row_index=row_idx)

                if global_row in rows_by_time:
                    for note in rows_by_time[global_row]:
                        if note.is_on:
                            event = AssemblerEvent(
                                event_type='note_on',
                                channel=note.channel,
                                note_index=note.note_index,
                            )
                        else:
                            event = AssemblerEvent(
                                event_type='note_off',
                                channel=note.channel,
                            )
                        row.events.append(event)

                row.is_empty = len(row.events) == 0
                pattern.rows.append(row)

            data.patterns.append(pattern)

        # Build positions (one per pattern for now)
        data.positions = list(range(num_patterns))
        data.song_length = len(data.positions) - 1

        return data
