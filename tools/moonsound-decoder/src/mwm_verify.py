"""MWM file verification - checks parsing doesn't crash and extracts data."""

from pathlib import Path
from typing import List
from dataclasses import dataclass

from src.mwm_parser import MWMParser


@dataclass
class VerifyResult:
    file_path: str
    success: bool
    original_size: int
    message: str = ""


def verify_file(file_path: str) -> VerifyResult:
    """Verify a single MWM file parses correctly."""
    path = Path(file_path)
    original = path.read_bytes()

    result = VerifyResult(
        file_path=str(path),
        success=False,
        original_size=len(original),
    )

    try:
        parsed = MWMParser.from_file(file_path)
        total_events = sum(parsed.get_event_statistics().values())

        result.success = True
        result.message = f"{len(parsed.patterns)} patterns, {total_events} events"

    except Exception as e:
        result.message = f"Error: {e}"

    return result


def verify_directory(dir_path: str, pattern: str = "*.MWM") -> List[VerifyResult]:
    path = Path(dir_path)
    return [verify_file(str(f)) for f in sorted(path.rglob(pattern))]


def print_results(results: List[VerifyResult]) -> None:
    passed = [r for r in results if r.success]
    failed = [r for r in results if not r.success]

    print(f"\n{'='*60}")
    print(f"MWM Parsing verification: {len(passed)}/{len(results)} passed")
    print(f"{'='*60}\n")

    if failed:
        print("FAILURES:")
        for r in failed:
            print(f"  {Path(r.file_path).name}: {r.message}")
        print()

    print(f"PASSED: {len(passed)} files")


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python -m src.mwm_verify <file_or_directory>")
        sys.exit(1)

    target = Path(sys.argv[1])

    if target.is_file():
        result = verify_file(str(target))
        print(f"{'PASS' if result.success else 'FAIL'}: {target.name} - {result.message}")
    else:
        results = verify_directory(str(target))
        print_results(results)
