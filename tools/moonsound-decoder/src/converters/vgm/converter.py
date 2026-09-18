"""Bidirectional VGM converter."""

from pathlib import Path
from typing import Union, Optional

from src.mfm_parser import MFMParser
from src.mfm_assembler import MFMAssembler
from src.mwm_parser import MWMParser
from src.converters.base import Converter, ConversionResult

from .vgm_writer import VGMWriter
from .vgm_reader import VGMReader
from .vgm_to_mfm import VGMToMFM


class VGMConverter(Converter):
    """Bidirectional VGM converter (MFM↔VGM)."""

    @property
    def name(self) -> str:
        return "VGM"

    @property
    def output_extension(self) -> str:
        return ".vgm"

    def __init__(self, clock: int = 33868800, rate: int = 60):
        self.clock = clock
        self.rate = rate
        self.warnings = []

    def convert_mfm(self, mfm: MFMParser) -> bytes:
        """Convert MFM to VGM format."""
        self.warnings = []
        writer = VGMWriter(clock=self.clock, rate=self.rate)
        return writer.write(mfm)

    def convert_mwm(self, mwm: MWMParser) -> bytes:
        """Convert MWM to VGM format (PCM samples)."""
        self.warnings = []
        self.warnings.append("MWM PCM to VGM not yet implemented")
        # Would need to generate OPL4 PCM register writes
        return b""

    def import_vgm(self, vgm_path: Union[str, Path]) -> bytes:
        """Import VGM file and convert to MFM format."""
        vgm_path = Path(vgm_path)
        vgm_data = vgm_path.read_bytes()

        # Parse VGM
        reader = VGMReader()
        vgm = reader.read(vgm_data)

        # Check for OPL4 content
        if vgm.opl4_clock == 0 and vgm.opl3_clock == 0:
            raise ValueError("VGM file does not contain OPL3/OPL4 data")

        # Convert to MFM assembler data
        converter = VGMToMFM()
        mfm_data = converter.convert(vgm)

        # Assemble to MFM binary
        assembler = MFMAssembler()
        return assembler.assemble(mfm_data)

    def import_vgm_to_file(
        self,
        vgm_path: Union[str, Path],
        mfm_path: Optional[Union[str, Path]] = None
    ) -> ConversionResult:
        """Import VGM and write MFM file."""
        vgm_path = Path(vgm_path)

        if mfm_path is None:
            mfm_path = vgm_path.with_suffix('.MFM')
        else:
            mfm_path = Path(mfm_path)

        try:
            mfm_bytes = self.import_vgm(vgm_path)

            mfm_path.parent.mkdir(parents=True, exist_ok=True)
            mfm_path.write_bytes(mfm_bytes)

            return ConversionResult(
                success=True,
                output_path=mfm_path,
                output_data=mfm_bytes,
                message=f"Imported {vgm_path.name} to {mfm_path.name}"
            )

        except Exception as e:
            return ConversionResult(
                success=False,
                message=f"Import failed: {e}"
            )


class VGMImporter:
    """Dedicated class for VGM→MFM import."""

    def __init__(self):
        self.converter = VGMConverter()

    def import_file(
        self,
        vgm_path: Union[str, Path],
        mfm_path: Optional[Union[str, Path]] = None
    ) -> ConversionResult:
        """Import VGM file to MFM."""
        return self.converter.import_vgm_to_file(vgm_path, mfm_path)

    def import_directory(
        self,
        vgm_dir: Union[str, Path],
        mfm_dir: Union[str, Path],
        pattern: str = "*.vgm"
    ) -> list:
        """Import all VGM files from directory."""
        vgm_dir = Path(vgm_dir)
        mfm_dir = Path(mfm_dir)
        results = []

        for vgm_file in sorted(vgm_dir.rglob(pattern)):
            rel_path = vgm_file.relative_to(vgm_dir)
            mfm_file = mfm_dir / rel_path.with_suffix('.MFM')

            result = self.import_file(vgm_file, mfm_file)
            results.append(result)

        return results
