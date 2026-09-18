"""Round-trip verification for MFM files.

Verifies that parse + reassemble produces identical bytes.
"""

from pathlib import Path
from typing import List, Optional
from dataclasses import dataclass

from src.mfm_parser import MFMParser, MFMPattern, MFMRow, MFMEvent
from src.mfm_assembler import (
    MFMAssembler, MFMAssemblerData, AssemblerPattern, AssemblerRow, AssemblerEvent,
    MFM_TRACK_INFO_SIZE, MFM_TRAILER_SIZE
)


@dataclass
class VerifyResult:
    """Result of round-trip verification."""
    file_path: str
    success: bool
    original_size: int
    reassembled_size: int = 0
    first_diff_offset: Optional[int] = None
    first_diff_section: Optional[str] = None
    message: str = ""


def event_to_assembler(event: MFMEvent) -> AssemblerEvent:
    """Convert parser event to assembler event using raw value."""
    return AssemblerEvent(
        event_type='raw',
        channel=event.channel,
        raw_value=event.raw_value,
    )


def row_to_assembler(row: MFMRow) -> AssemblerRow:
    """Convert parser row to assembler row."""
    asm_row = AssemblerRow(
        row_index=row.row_index,
        is_empty=row.is_empty,
        mask1=row.mask1,
        mask2=row.mask2,
        mask3=row.mask3,
        use_original_masks=True,  # Use original masks for exact round-trip
    )
    for event in row.events:
        asm_row.events.append(event_to_assembler(event))
    return asm_row


def pattern_to_assembler(pattern: MFMPattern) -> AssemblerPattern:
    """Convert parser pattern to assembler pattern."""
    asm_pattern = AssemblerPattern(
        index=pattern.index,
        trailing_bytes=pattern.trailing_bytes,
    )
    for row in pattern.rows:
        asm_pattern.rows.append(row_to_assembler(row))
    return asm_pattern


def get_section_name(offset: int, positions_end: int) -> str:
    """Determine which section an offset falls in."""
    if offset < 6:
        return "header"
    elif offset < 6 + MFM_TRACK_INFO_SIZE:
        return f"track-info (byte {offset - 6})"
    elif offset < 6 + MFM_TRACK_INFO_SIZE + MFM_TRAILER_SIZE:
        return f"trailer (byte {offset - 6 - MFM_TRACK_INFO_SIZE})"
    elif offset < positions_end:
        return f"positions (byte {offset - 6 - MFM_TRACK_INFO_SIZE - MFM_TRAILER_SIZE})"
    else:
        return f"pattern-section (byte {offset - positions_end})"


def verify_file(file_path: str) -> VerifyResult:
    """Verify a single MFM file with round-trip parsing."""
    path = Path(file_path)
    original = path.read_bytes()

    result = VerifyResult(
        file_path=str(path),
        success=False,
        original_size=len(original),
    )

    try:
        # Parse with parser
        parsed = MFMParser.from_file(file_path)

        # Build assembler data
        asm_data = MFMAssemblerData()
        asm_data.version_high = parsed.version_high
        asm_data.version_low = parsed.version_low

        # Use raw blocks from original file for sections we don't fully parse
        asm_data.raw_track_info = original[6:6 + MFM_TRACK_INFO_SIZE]
        asm_data.raw_trailer = original[6 + MFM_TRACK_INFO_SIZE:6 + MFM_TRACK_INFO_SIZE + MFM_TRAILER_SIZE]

        # Positions
        asm_data.positions = list(parsed.positions)

        # Convert patterns with full structure
        for pattern in parsed.patterns:
            asm_data.patterns.append(pattern_to_assembler(pattern))

        # Reassemble
        assembler = MFMAssembler()
        reassembled = assembler.assemble(asm_data)
        result.reassembled_size = len(reassembled)

        # Calculate positions_end for section naming
        positions_end = 6 + MFM_TRACK_INFO_SIZE + MFM_TRAILER_SIZE + len(parsed.positions)

        # Compare byte-by-byte
        if original == reassembled:
            result.success = True
            result.message = "Perfect match"
        else:
            # Find first difference
            min_len = min(len(original), len(reassembled))
            for i in range(min_len):
                if original[i] != reassembled[i]:
                    result.first_diff_offset = i
                    result.first_diff_section = get_section_name(i, positions_end)
                    result.message = (
                        f"First diff at 0x{i:04X} ({result.first_diff_section}): "
                        f"0x{original[i]:02X} vs 0x{reassembled[i]:02X}"
                    )
                    break
            else:
                result.first_diff_offset = min_len
                result.message = f"Size mismatch: {len(original)} vs {len(reassembled)}"

    except Exception as e:
        result.message = f"Error: {e}"

    return result


def verify_directory(dir_path: str, pattern: str = "*.MFM") -> List[VerifyResult]:
    """Verify all MFM files in a directory."""
    path = Path(dir_path)
    return [verify_file(str(f)) for f in sorted(path.rglob(pattern))]


def print_results(results: List[VerifyResult]) -> None:
    """Print verification results summary."""
    passed = [r for r in results if r.success]
    failed = [r for r in results if not r.success]

    print(f"\n{'='*60}")
    print(f"Round-trip verification: {len(passed)}/{len(results)} passed")
    print(f"{'='*60}\n")

    if failed:
        print("FAILURES:")
        for r in failed:
            print(f"  {Path(r.file_path).name}: {r.message}")
        print()

    if passed:
        print(f"PASSED: {len(passed)} files")


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python -m src.mfm_verify <file_or_directory>")
        sys.exit(1)

    target = Path(sys.argv[1])

    if target.is_file():
        result = verify_file(str(target))
        if result.success:
            print(f"PASS: {target.name}")
        else:
            print(f"FAIL: {target.name} - {result.message}")
    else:
        results = verify_directory(str(target))
        print_results(results)
