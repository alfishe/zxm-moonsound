"""VGM file reader for import to MFM."""

import struct
from dataclasses import dataclass, field
from typing import List, Tuple, Optional


VGM_MAGIC = b"Vgm "


@dataclass
class VGMCommand:
    """Parsed VGM command."""
    offset: int          # File offset
    time: int            # Cumulative sample time
    cmd: int             # Command byte
    port: int = 0        # Chip port (for multi-port chips)
    register: int = 0    # Register address
    value: int = 0       # Register value
    wait: int = 0        # Wait samples (for wait commands)


@dataclass
class VGMData:
    """Parsed VGM file data."""
    version: int = 0
    total_samples: int = 0
    loop_offset: int = 0
    loop_samples: int = 0
    rate: int = 60

    # Chip clocks
    opl4_clock: int = 0
    opl3_clock: int = 0
    opl2_clock: int = 0

    # Parsed commands
    commands: List[VGMCommand] = field(default_factory=list)

    # Register writes grouped by chip
    opl4_writes: List[Tuple[int, int, int, int]] = field(default_factory=list)  # (time, port, reg, val)


class VGMReader:
    """Reads and parses VGM files."""

    def __init__(self):
        self.data: Optional[VGMData] = None
        self._raw: bytes = b""
        self._offset: int = 0
        self._time: int = 0

    def read(self, data: bytes) -> VGMData:
        """Parse VGM file."""
        self._raw = data
        self._offset = 0
        self._time = 0
        self.data = VGMData()

        self._parse_header()
        self._parse_commands()

        return self.data

    def _parse_header(self):
        """Parse VGM header."""
        if self._raw[:4] != VGM_MAGIC:
            raise ValueError("Invalid VGM file magic")

        self.data.version = struct.unpack_from('<I', self._raw, 0x08)[0]
        self.data.total_samples = struct.unpack_from('<I', self._raw, 0x18)[0]
        self.data.loop_offset = struct.unpack_from('<I', self._raw, 0x1C)[0]
        self.data.loop_samples = struct.unpack_from('<I', self._raw, 0x20)[0]
        self.data.rate = struct.unpack_from('<I', self._raw, 0x24)[0]

        # Data offset (relative to 0x34)
        data_offset = struct.unpack_from('<I', self._raw, 0x34)[0]
        if data_offset == 0:
            self._offset = 0x40  # Default for older versions
        else:
            self._offset = 0x34 + data_offset

        # Chip clocks (if present based on version)
        if len(self._raw) > 0x5C + 4:
            self.data.opl4_clock = struct.unpack_from('<I', self._raw, 0x5C)[0]

        if len(self._raw) > 0x50 + 4:
            self.data.opl3_clock = struct.unpack_from('<I', self._raw, 0x50)[0]

        # OPL2 at 0x0C
        self.data.opl2_clock = struct.unpack_from('<I', self._raw, 0x0C)[0]

    def _parse_commands(self):
        """Parse VGM data commands."""
        while self._offset < len(self._raw):
            cmd_offset = self._offset
            cmd = self._raw[self._offset]
            self._offset += 1

            if cmd == 0x66:  # End of data
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd
                ))
                break

            elif cmd == 0x61:  # Wait n samples
                wait = struct.unpack_from('<H', self._raw, self._offset)[0]
                self._offset += 2
                self._time += wait
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd, wait=wait
                ))

            elif cmd == 0x62:  # Wait 735 samples (1/60s)
                self._time += 735
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd, wait=735
                ))

            elif cmd == 0x63:  # Wait 882 samples (1/50s)
                self._time += 882
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd, wait=882
                ))

            elif cmd in (0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
                        0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F):
                # Wait 1-16 samples
                wait = (cmd & 0x0F) + 1
                self._time += wait
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd, wait=wait
                ))

            elif cmd == 0x5A:  # YM3812 (OPL2)
                reg = self._raw[self._offset]
                val = self._raw[self._offset + 1]
                self._offset += 2
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd,
                    port=0, register=reg, value=val
                ))

            elif cmd == 0x5E:  # YMF262 port 0 (OPL3)
                reg = self._raw[self._offset]
                val = self._raw[self._offset + 1]
                self._offset += 2
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd,
                    port=0, register=reg, value=val
                ))

            elif cmd == 0x5F:  # YMF262 port 1 (OPL3)
                reg = self._raw[self._offset]
                val = self._raw[self._offset + 1]
                self._offset += 2
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd,
                    port=1, register=reg, value=val
                ))

            elif cmd == 0xD0:  # YMF278B (OPL4)
                port = self._raw[self._offset]
                reg = self._raw[self._offset + 1]
                val = self._raw[self._offset + 2]
                self._offset += 3
                self.data.commands.append(VGMCommand(
                    offset=cmd_offset, time=self._time, cmd=cmd,
                    port=port, register=reg, value=val
                ))
                self.data.opl4_writes.append((self._time, port, reg, val))

            elif cmd == 0x67:  # Data block
                # Skip data blocks for now
                self._offset += 2  # 0x66 type
                size = struct.unpack_from('<I', self._raw, self._offset)[0]
                self._offset += 4 + size

            else:
                # Unknown command - try to skip based on known patterns
                # Most 2-byte data commands are 0x3x-0x5x
                if 0x30 <= cmd <= 0x5F:
                    self._offset += 2
                else:
                    # Single byte or unknown - advance cautiously
                    pass

    def get_opl4_fm_writes(self) -> List[Tuple[int, int, int, int]]:
        """Get OPL4 FM register writes (port 0 and 1)."""
        return [(t, p, r, v) for t, p, r, v in self.data.opl4_writes if p < 2]

    def get_opl4_pcm_writes(self) -> List[Tuple[int, int, int, int]]:
        """Get OPL4 PCM register writes (port 2+)."""
        return [(t, p, r, v) for t, p, r, v in self.data.opl4_writes if p >= 2]
