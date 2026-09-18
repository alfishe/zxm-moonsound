#!/usr/bin/env python3
"""
MoonSound File Analysis CLI

Command-line tool for analyzing MoonSound audio files:
  - MFM (MoonBlaster FM Music)
  - MWM (MoonBlaster Wave Music)
  - Raw OPL4 register dumps

Usage:
  moonsound info <file>
  moonsound parse <file> [--output json|text]
  moonsound instruments <file>
  moonsound scan <directory> [--recursive]
"""

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any

from .mfm_parser import MFMParser, MFMFile
from .mwm_parser import MWMParser, MWMFile


def get_scratch_dir() -> Path:
    """Get scratch output directory with timestamp in project root."""
    # Find project root (zxm-moonsound/)
    # cli.py path: tools/moonsound-decoder/src/moonsound/cli.py
    cli_path = Path(__file__).resolve()
    # Go up: moonsound -> src -> moonsound-decoder -> tools -> zxm-moonsound
    project_root = cli_path.parent.parent.parent.parent
    scratch_base = project_root / "scratch"

    # Create timestamped subdirectory
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    scratch_dir = scratch_base / timestamp
    scratch_dir.mkdir(parents=True, exist_ok=True)

    return scratch_dir


def detect_format(path: str) -> str:
    """Detect file format from header."""
    try:
        with open(path, 'rb') as f:
            header = f.read(64)
    except Exception:
        return "unknown"

    # MBMS signature (MoonBlaster MoonSound)
    if header[:4] == b"MBMS":
        ext = Path(path).suffix.lower()
        if ext == '.mwm':
            return "mwm"
        return "mfm"  # Default to MFM for MBMS
    elif b"MoonBlaster 1.4" in header:
        return "mfm"
    elif b"MoonBlaster" in header and b"Wave" in header:
        return "mwm"
    elif b"MoonBlaster" in header:
        return "mfm"
    else:
        ext = Path(path).suffix.lower()
        if ext == '.mfm':
            return "mfm"
        elif ext == '.mwm':
            return "mwm"
    return "unknown"


def cmd_info(args: argparse.Namespace) -> int:
    """Show detailed file info."""
    path = args.file

    if not Path(path).exists():
        print(f"Error: File not found: {path}", file=sys.stderr)
        return 1

    fmt = detect_format(path)

    print(f"File: {Path(path).name}")
    print(f"Path: {path}")
    print(f"Size: {Path(path).stat().st_size} bytes")
    print(f"Detected format: {fmt.upper()}")
    print()

    if fmt == "mfm":
        info = MFMParser.info(path)
        if info.get('valid'):
            print("=== MFM File Details ===")
            print(f"Signature: {info.get('signature', 'N/A')}")
            print(f"Version: {info.get('version', 'N/A')}")
            print(f"Format: {info.get('format_name', info.get('format', 'N/A'))}")
            if info.get('metadata'):
                print(f"Metadata: {info.get('metadata')}")
            if info.get('song_length'):
                print(f"Song length: {info.get('song_length')} positions")
            if info.get('loop_position') is not None:
                print(f"Loop position: {info.get('loop_position')}")
            else:
                print("Loop: no loop (play once)")
            if info.get('tempo'):
                print(f"Tempo: {info.get('tempo')}")
            if info.get('four_op_chains') is not None:
                chains = info.get('four_op_chains')
                print(f"4-op chains: {chains} ({18 - 2*chains} 2-op channels)")
        elif info.get('error'):
            print(f"Error: {info.get('error')}")

    elif fmt == "mwm":
        info = MWMParser.info(path)
        if info.get('valid'):
            print("=== MWM File Details ===")
            print(f"Signature: {info.get('signature', 'N/A')}")
            print(f"Format: {info.get('format', 'MoonBlaster Wave')}")
        elif info.get('error'):
            print(f"Error: {info.get('error')}")
    else:
        print("Unknown or unsupported file format")

    return 0


def cmd_parse(args: argparse.Namespace) -> int:
    """Parse file and output structure."""
    path = args.file
    output_format = args.output or 'json'

    if not Path(path).exists():
        print(f"Error: File not found: {path}", file=sys.stderr)
        return 1

    fmt = detect_format(path)

    try:
        if fmt == "mfm":
            file_obj = MFMParser.from_file(path)
        elif fmt == "mwm":
            file_obj = MWMParser.from_file(path)
        else:
            print(f"Error: Unknown file format", file=sys.stderr)
            return 1

        data = file_obj.to_dict()

        if output_format == 'json':
            print(json.dumps(data, indent=2))
        else:
            _print_text(data)

    except Exception as e:
        print(f"Error parsing file: {e}", file=sys.stderr)
        return 1

    return 0


def cmd_instruments(args: argparse.Namespace) -> int:
    """List instruments in file."""
    path = args.file

    if not Path(path).exists():
        print(f"Error: File not found: {path}", file=sys.stderr)
        return 1

    fmt = detect_format(path)

    try:
        if fmt == "mfm":
            file_obj = MFMParser.from_file(path)
            _print_fm_instruments(file_obj)
        elif fmt == "mwm":
            file_obj = MWMParser.from_file(path)
            _print_pcm_instruments(file_obj)
        else:
            print(f"Error: Unknown file format", file=sys.stderr)
            return 1

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

    return 0


def cmd_scan(args: argparse.Namespace) -> int:
    """Scan directory for MoonSound files and analyze all."""
    directory = Path(args.directory)
    recursive = args.recursive

    if not directory.exists():
        print(f"Error: Directory not found: {directory}", file=sys.stderr)
        return 1

    # Find all potential music files
    patterns = ['*.mfm', '*.MFM', '*.mwm', '*.MWM']
    files: List[Path] = []

    for pattern in patterns:
        if recursive:
            files.extend(directory.rglob(pattern))
        else:
            files.extend(directory.glob(pattern))

    # Also check files without extension in specific folders
    if recursive:
        for f in directory.rglob('*'):
            if f.is_file() and f.suffix == '' and f.stat().st_size > 100:
                fmt = detect_format(str(f))
                if fmt in ('mfm', 'mwm'):
                    files.append(f)

    files = sorted(set(files))

    if not files:
        print(f"No MoonSound files found in {directory}")
        return 0

    # Create output directory
    scratch_dir = get_scratch_dir()
    print(f"Output directory: {scratch_dir}")
    print(f"Found {len(files)} files to analyze\n")

    # Process each file
    results: List[Dict[str, Any]] = []
    success_count = 0
    fail_count = 0

    for filepath in files:
        rel_path = filepath.relative_to(directory) if filepath.is_relative_to(directory) else filepath
        result = {
            'file': str(rel_path),
            'path': str(filepath),
            'size': filepath.stat().st_size,
            'status': 'unknown',
        }

        try:
            fmt = detect_format(str(filepath))
            result['format'] = fmt

            if fmt == "mfm":
                file_obj = MFMParser.from_file(str(filepath))
                result['data'] = file_obj.to_dict()
                result['status'] = 'success'
            elif fmt == "mwm":
                file_obj = MWMParser.from_file(str(filepath))
                result['data'] = file_obj.to_dict()
                result['status'] = 'success'
            else:
                result['status'] = 'skipped'
                result['reason'] = 'unknown format'

            if result['status'] == 'success':
                success_count += 1
                print(f"  OK: {rel_path}")
            else:
                print(f"SKIP: {rel_path} ({result.get('reason', 'unknown')})")

        except Exception as e:
            result['status'] = 'error'
            result['error'] = str(e)
            fail_count += 1
            print(f"FAIL: {rel_path} - {e}")

        results.append(result)

    # Write summary
    summary = {
        'timestamp': datetime.now().isoformat(),
        'directory': str(directory),
        'recursive': recursive,
        'total_files': len(files),
        'success': success_count,
        'failed': fail_count,
        'skipped': len(files) - success_count - fail_count,
        'results': results,
    }

    summary_path = scratch_dir / "scan_results.json"
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)

    # Write individual file outputs; a name found on several disks gets its
    # folder as prefix so different songs sharing a name don't overwrite
    name_counts: Dict[str, int] = {}
    for result in results:
        name = Path(result['file']).name
        name_counts[name] = name_counts.get(name, 0) + 1
    for result in results:
        if result['status'] == 'success' and 'data' in result:
            rel = Path(result['file'])
            safe_name = rel.name.replace(' ', '_')
            if name_counts[rel.name] > 1:
                safe_name = f"{rel.parent.name}__{safe_name}".replace(' ', '_')
            output_path = scratch_dir / f"{safe_name}.json"
            with open(output_path, 'w') as f:
                json.dump(result['data'], f, indent=2)

    print(f"\n{'='*60}")
    print(f"Scan complete: {success_count} OK, {fail_count} FAILED, {len(files) - success_count - fail_count} skipped")
    print(f"Results saved to: {scratch_dir}")

    return 1 if fail_count > 0 else 0


def _print_fm_instruments(file_obj: MFMFile) -> None:
    """Print FM instrument list."""
    print("FM Instruments:")
    print("-" * 60)
    print(f"{'#':>2} {'Op1':>8} {'Op2':>8} {'FB':>3} {'Conn':>4}")
    print("-" * 60)

    for inst in file_obj.instruments:
        if inst.op1_level > 0 or inst.op2_level > 0:
            op1 = f"A{inst.op1_attack:X}D{inst.op1_decay:X}S{inst.op1_sustain:X}R{inst.op1_release:X}"
            op2 = f"A{inst.op2_attack:X}D{inst.op2_decay:X}S{inst.op2_sustain:X}R{inst.op2_release:X}"
            conn = "Add" if inst.connection else "FM"
            print(f"{inst.index:2d} {op1:>8} {op2:>8} {inst.feedback:>3} {conn:>4}")


def _print_pcm_instruments(file_obj: MWMFile) -> None:
    """Print PCM instrument list."""
    print("PCM Instruments:")
    print("-" * 70)
    print(f"{'#':>2} {'Sample':>6} {'AR':>3} {'D1R':>4} {'DL':>3} {'D2R':>4} {'RR':>3} {'Pan':>8}")
    print("-" * 70)

    for inst in file_obj.instruments:
        if inst.sample > 0:
            print(f"{inst.index:2d} {inst.sample:>6} {inst.attack_rate:>3} "
                  f"{inst.decay1_rate:>4} {inst.decay_level:>3} {inst.decay2_rate:>4} "
                  f"{inst.release_rate:>3} {inst.pan_position:>8}")


def _print_text(data: dict) -> None:
    """Print data in text format."""
    header = data.get('header', {})
    settings = data.get('settings', {})
    stats = data.get('statistics', {})

    print("=== Header ===")
    for k, v in header.items():
        print(f"  {k}: {v}")

    print("\n=== Settings ===")
    for k, v in settings.items():
        print(f"  {k}: {v}")

    print("\n=== Statistics ===")
    for k, v in stats.items():
        print(f"  {k}: {v}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="MoonSound File Analysis Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s info melody.mfm
  %(prog)s parse song.mwm --output json
  %(prog)s instruments track.mfm
  %(prog)s scan ./demo-disks --recursive
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Command')

    # info command
    p_info = subparsers.add_parser('info', help='Show file information')
    p_info.add_argument('file', help='Input file path')

    # parse command
    p_parse = subparsers.add_parser('parse', help='Parse file and show structure')
    p_parse.add_argument('file', help='Input file path')
    p_parse.add_argument('--output', '-o', choices=['json', 'text'],
                         default='json', help='Output format')

    # instruments command
    p_inst = subparsers.add_parser('instruments', help='List instruments')
    p_inst.add_argument('file', help='Input file path')

    # scan command
    p_scan = subparsers.add_parser('scan', help='Scan directory for MoonSound files')
    p_scan.add_argument('directory', help='Directory to scan')
    p_scan.add_argument('--recursive', '-r', action='store_true',
                        help='Scan recursively')

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        return 1

    if args.command == 'info':
        return cmd_info(args)
    elif args.command == 'parse':
        return cmd_parse(args)
    elif args.command == 'instruments':
        return cmd_instruments(args)
    elif args.command == 'scan':
        return cmd_scan(args)

    return 0


if __name__ == '__main__':
    sys.exit(main())
