"""VGM file writer for MFM export."""

import struct
from dataclasses import dataclass, field
from typing import List, Tuple

from src.mfm_parser import MFMParser, MFMEvent


# VGM format constants
VGM_MAGIC = b"Vgm "
VGM_VERSION = 0x00000171  # 1.71
VGM_SAMPLE_RATE = 44100

# OPL4 clock (33.8688 MHz)
OPL4_CLOCK = 33868800

# Samples per frame at 60Hz
SAMPLES_PER_FRAME_60HZ = 735
SAMPLES_PER_FRAME_50HZ = 882


@dataclass
class VGMCommand:
    """Single VGM command."""
    cmd: int
    data: bytes = b""

    def to_bytes(self) -> bytes:
        return bytes([self.cmd]) + self.data


class VGMWriter:
    """Exports MFM to VGM format."""

    def __init__(self, clock: int = OPL4_CLOCK, rate: int = 60):
        self.clock = clock
        self.rate = rate
        self.commands: List[VGMCommand] = []
        self.total_samples = 0

    def write(self, mfm: MFMParser) -> bytes:
        """Convert MFM to VGM format."""
        self.commands = []
        self.total_samples = 0

        # Initialize OPL4
        self._init_opl4(mfm)

        # Convert instruments to register writes (store in wave RAM)
        self._write_instruments(mfm)

        # Play through all positions
        for pos_idx, pattern_idx in enumerate(mfm.positions):
            if pattern_idx < len(mfm.patterns):
                self._write_pattern(mfm, mfm.patterns[pattern_idx])

        # End command
        self.commands.append(VGMCommand(0x66))

        return self._build_file()

    def _init_opl4(self, mfm: MFMParser):
        """Initialize OPL4 chip."""
        # Enable OPL3 mode
        self._write_opl4_fm(0x01, 0x05, 0x01)  # Test register
        self._write_opl4_fm(0x01, 0x04, 0x00)  # 4-op disable

        # Set 4-op mode if needed
        if mfm.four_op_chain_count > 0:
            four_op_mask = 0
            if mfm.four_op_chain_count >= 2:
                four_op_mask |= 0x03
            if mfm.four_op_chain_count >= 4:
                four_op_mask |= 0x0C
            if mfm.four_op_chain_count >= 6:
                four_op_mask |= 0x30
            self._write_opl4_fm(0x01, 0x04, four_op_mask)

    def _write_instruments(self, mfm: MFMParser):
        """Write instrument definitions to OPL4."""
        # For FM, instruments are written per-channel when notes play
        pass

    def _write_pattern(self, mfm: MFMParser, pattern):
        """Write pattern data as register commands."""
        samples_per_row = self._calc_samples_per_row(mfm.tempo)

        for row in pattern.rows:
            if not row.is_empty:
                self._write_row_events(mfm, row)

            # Wait for next row
            self._write_wait(samples_per_row)

    def _write_row_events(self, mfm: MFMParser, row):
        """Write events for a single row."""
        for event in row.events:
            self._write_event(mfm, event)

    def _write_event(self, mfm: MFMParser, event: MFMEvent):
        """Convert MFM event to OPL4 register writes."""
        ch = event.channel
        event_type = event.event_type.name

        if event_type == 'NOTE_ON':
            # Calculate F-number and block from note
            # MFM note: raw_value - 1 = note index (0-95)
            note_index = event.raw_value - 1
            fnum, block = self._note_to_fnum(note_index)

            # Get channel register offsets
            port, base = self._channel_to_reg(ch)

            # Write F-num low byte
            self._write_opl4_fm(port, 0xA0 + base, fnum & 0xFF)

            # Write block, F-num high, key-on
            self._write_opl4_fm(port, 0xB0 + base, 0x20 | ((block & 0x07) << 2) | ((fnum >> 8) & 0x03))

        elif event_type == 'NOTE_OFF':
            port, base = self._channel_to_reg(ch)
            # Key-off (clear bit 5)
            self._write_opl4_fm(port, 0xB0 + base, 0x00)

        elif event_type == 'INSTRUMENT':
            inst_idx = event.instrument if event.instrument is not None else 0
            self._write_instrument_to_channel(mfm, inst_idx, ch)

        elif event_type == 'VOLUME':
            # Write to TL register (carrier)
            port, base = self._channel_to_reg(ch)
            # Carrier offset for 2-op
            car_offset = [3, 4, 5, 3, 4, 5, 3, 4, 5][base % 9]
            vol = event.volume if event.volume is not None else 0
            tl = 63 - vol  # Invert (0=loud, 63=silent)
            self._write_opl4_fm(port, 0x40 + base + car_offset, tl)

    def _write_instrument_to_channel(self, mfm: MFMParser, inst_idx: int, channel: int):
        """Write instrument operator data to channel."""
        if inst_idx >= len(mfm.instruments):
            return

        inst = mfm.instruments[inst_idx]
        port, base = self._channel_to_reg(channel)

        # Modulator offset
        mod_offset = base
        # Carrier offset (varies by channel in 2-op)
        car_offset = base + 3
        if base >= 6:
            car_offset = base + 3

        # Write modulator
        self._write_opl4_fm(port, 0x20 + mod_offset, inst.primary.mod_am_vib_eg_ksr_mult)
        self._write_opl4_fm(port, 0x40 + mod_offset, inst.primary.mod_ksl_tl)
        self._write_opl4_fm(port, 0x60 + mod_offset, inst.primary.mod_ar_dr)
        self._write_opl4_fm(port, 0x80 + mod_offset, inst.primary.mod_sl_rr)
        self._write_opl4_fm(port, 0xE0 + mod_offset, inst.primary.mod_waveform)

        # Write carrier
        self._write_opl4_fm(port, 0x20 + car_offset, inst.primary.car_am_vib_eg_ksr_mult)
        self._write_opl4_fm(port, 0x40 + car_offset, inst.primary.car_ksl_tl)
        self._write_opl4_fm(port, 0x60 + car_offset, inst.primary.car_ar_dr)
        self._write_opl4_fm(port, 0x80 + car_offset, inst.primary.car_sl_rr)
        self._write_opl4_fm(port, 0xE0 + car_offset, inst.primary.car_waveform)

        # Feedback/connection
        self._write_opl4_fm(port, 0xC0 + (base % 9), inst.primary.feedback_connection)

    def _write_opl4_fm(self, port: int, reg: int, val: int):
        """Write to OPL4 FM register."""
        # VGM command 0xD0 = YMF278B write
        # Format: D0 pp aa dd (port, address, data)
        cmd = VGMCommand(0xD0, bytes([port, reg, val]))
        self.commands.append(cmd)

    def _write_wait(self, samples: int):
        """Add wait command."""
        self.total_samples += samples

        while samples > 0:
            if samples >= SAMPLES_PER_FRAME_60HZ and samples < SAMPLES_PER_FRAME_50HZ:
                self.commands.append(VGMCommand(0x62))  # Wait 735
                samples -= SAMPLES_PER_FRAME_60HZ
            elif samples >= SAMPLES_PER_FRAME_50HZ:
                self.commands.append(VGMCommand(0x63))  # Wait 882
                samples -= SAMPLES_PER_FRAME_50HZ
            elif samples > 0:
                # 0x61 nn nn - wait n samples
                wait = min(samples, 65535)
                self.commands.append(VGMCommand(0x61, struct.pack('<H', wait)))
                samples -= wait

    def _note_to_fnum(self, note_index: int) -> Tuple[int, int]:
        """Convert note index to F-number and block."""
        # MFM note 0 = C-1, each octave = 12 semitones
        octave = note_index // 12
        semitone = note_index % 12

        # Base frequencies for C in each octave (Hz)
        # OPL4 F-num formula: F-num = (freq * 2^20) / (clock / 288)
        # Simplified: F-num = freq * 288 * 2^20 / clock

        # Reference: A4 = 440 Hz, A4 is note 57 in MFM (0-indexed from C-1)
        # C-1 = note 0, freq ≈ 8.18 Hz
        base_freq = 8.175798915643707  # C-1
        freq = base_freq * (2 ** (note_index / 12))

        # Calculate F-number
        # clock/288 = 117600, but we need to fit in 10 bits
        # Use block to shift: actual_freq = fnum * (clock/288) / 2^(20-block)

        block = min(7, max(0, octave + 1))
        fnum = int((freq * (1 << (20 - block))) / (self.clock / 288))
        fnum = min(1023, max(0, fnum))

        return fnum, block

    def _channel_to_reg(self, channel: int) -> Tuple[int, int]:
        """Map MFM channel to OPL4 port and register base."""
        # Channels 0-8: port 0, base 0-8
        # Channels 9-17: port 1, base 0-8
        if channel < 9:
            return 0, channel
        else:
            return 1, channel - 9

    def _calc_samples_per_row(self, tempo: int) -> int:
        """Calculate samples per row from MFM tempo."""
        # MFM tempo is basically speed (ticks per row)
        # At 60 Hz, 1 tick = 735 samples
        ticks = max(1, tempo)
        return ticks * SAMPLES_PER_FRAME_60HZ

    def _build_file(self) -> bytes:
        """Build complete VGM file."""
        # Build data section
        data = bytearray()
        for cmd in self.commands:
            data.extend(cmd.to_bytes())

        # Calculate offsets
        header_size = 0x100  # Extended header
        data_offset = header_size - 0x34
        eof_offset = header_size + len(data) - 4

        # Build header
        header = bytearray(header_size)

        # Magic
        header[0x00:0x04] = VGM_MAGIC

        # EOF offset
        struct.pack_into('<I', header, 0x04, eof_offset)

        # Version
        struct.pack_into('<I', header, 0x08, VGM_VERSION)

        # Total samples
        struct.pack_into('<I', header, 0x18, self.total_samples)

        # Loop offset (0 = no loop)
        struct.pack_into('<I', header, 0x1C, 0)

        # Loop samples
        struct.pack_into('<I', header, 0x20, 0)

        # Rate (playback rate in Hz)
        struct.pack_into('<I', header, 0x24, self.rate)

        # VGM data offset
        struct.pack_into('<I', header, 0x34, data_offset)

        # YMF278B (OPL4) clock at offset 0x5C
        struct.pack_into('<I', header, 0x5C, self.clock)

        return bytes(header) + bytes(data)
