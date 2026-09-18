"""Base converter interface."""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Union

from src.mfm_parser import MFMParser
from src.mwm_parser import MWMParser


@dataclass
class ConversionResult:
    """Result of a conversion operation."""
    success: bool
    output_path: Optional[Path] = None
    output_data: Optional[bytes] = None
    message: str = ""
    warnings: list = None

    def __post_init__(self):
        if self.warnings is None:
            self.warnings = []


class Converter(ABC):
    """Abstract base class for format converters."""

    @property
    @abstractmethod
    def name(self) -> str:
        """Converter name for logging."""
        pass

    @property
    @abstractmethod
    def output_extension(self) -> str:
        """Output file extension (e.g., '.fur')."""
        pass

    @abstractmethod
    def convert_mfm(self, mfm: MFMParser) -> bytes:
        """Convert MFM data to target format."""
        pass

    @abstractmethod
    def convert_mwm(self, mwm: MWMParser) -> bytes:
        """Convert MWM data to target format."""
        pass

    def convert_file(
        self,
        input_path: Union[str, Path],
        output_path: Optional[Union[str, Path]] = None
    ) -> ConversionResult:
        """Convert a file and optionally write output."""
        input_path = Path(input_path)
        suffix = input_path.suffix.upper()

        try:
            if suffix == '.MFM':
                parsed = MFMParser.from_file(str(input_path))
                output_data = self.convert_mfm(parsed)
            elif suffix == '.MWM':
                parsed = MWMParser.from_file(str(input_path))
                output_data = self.convert_mwm(parsed)
            else:
                return ConversionResult(
                    success=False,
                    message=f"Unknown file type: {suffix}"
                )

            result = ConversionResult(
                success=True,
                output_data=output_data,
                message=f"Converted {input_path.name}"
            )

            if output_path:
                output_path = Path(output_path)
                output_path.parent.mkdir(parents=True, exist_ok=True)
                output_path.write_bytes(output_data)
                result.output_path = output_path

            return result

        except Exception as e:
            return ConversionResult(
                success=False,
                message=f"Conversion failed: {e}"
            )

    def convert_directory(
        self,
        input_dir: Union[str, Path],
        output_dir: Union[str, Path],
        pattern: str = "*.MFM"
    ) -> list:
        """Convert all matching files in a directory."""
        input_dir = Path(input_dir)
        output_dir = Path(output_dir)
        results = []

        for input_file in sorted(input_dir.rglob(pattern)):
            rel_path = input_file.relative_to(input_dir)
            output_file = output_dir / rel_path.with_suffix(self.output_extension)

            result = self.convert_file(input_file, output_file)
            results.append(result)

        return results
