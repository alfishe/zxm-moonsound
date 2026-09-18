#!/usr/bin/env python3
"""CLI for MoonSound file format conversion."""

import argparse
import sys
from pathlib import Path
from typing import Optional

from src.converters.furnace import FurnaceConverter
from src.converters.vgm import VGMConverter, VGMImporter


def convert_to_furnace(args):
    """Convert MFM/MWM to Furnace .fur format."""
    converter = FurnaceConverter(compress=not args.no_compress,
                                 tick_rate=None if args.msx_timing else 50.0)

    input_path = Path(args.input)
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_path.with_suffix('.fur')

    if input_path.is_dir():
        results = converter.convert_directory(
            input_path,
            output_path,
            pattern="*.[Mm][Ff][Mm]" if args.mfm_only else "*.[Mm][FfWw][Mm]"
        )
        passed = sum(1 for r in results if r.success)
        print(f"Converted {passed}/{len(results)} files")
        for r in results:
            if not r.success:
                print(f"  FAIL: {r.message}")
    else:
        result = converter.convert_file(input_path, output_path)
        if result.success:
            print(f"Created: {result.output_path}")
        else:
            print(f"Error: {result.message}", file=sys.stderr)
            sys.exit(1)


def convert_to_vgm(args):
    """Convert MFM/MWM to VGM format."""
    converter = VGMConverter()

    input_path = Path(args.input)
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_path.with_suffix('.vgm')

    if input_path.is_dir():
        results = converter.convert_directory(input_path, output_path, pattern="*.MFM")
        passed = sum(1 for r in results if r.success)
        print(f"Converted {passed}/{len(results)} files")
    else:
        result = converter.convert_file(input_path, output_path)
        if result.success:
            print(f"Created: {result.output_path}")
        else:
            print(f"Error: {result.message}", file=sys.stderr)
            sys.exit(1)


def import_vgm(args):
    """Import VGM to MFM format."""
    importer = VGMImporter()

    input_path = Path(args.input)
    output_path = Path(args.output) if args.output else None

    if input_path.is_dir():
        if not output_path:
            output_path = input_path / "mfm_output"
        results = importer.import_directory(input_path, output_path)
        passed = sum(1 for r in results if r.success)
        print(f"Imported {passed}/{len(results)} files")
    else:
        result = importer.import_file(input_path, output_path)
        if result.success:
            print(f"Created: {result.output_path}")
        else:
            print(f"Error: {result.message}", file=sys.stderr)
            sys.exit(1)


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="MoonSound file format converter",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Convert MFM to Furnace
  python -m src.cli.convert furnace song.MFM

  # Convert directory to VGM
  python -m src.cli.convert vgm ./demo-disks/ -o ./vgm-output/

  # Import VGM to MFM
  python -m src.cli.convert import-vgm game.vgm
"""
    )

    subparsers = parser.add_subparsers(dest='command', help='Conversion command')

    # Furnace converter
    fur_parser = subparsers.add_parser('furnace', help='Convert to Furnace .fur format')
    fur_parser.add_argument('input', help='Input MFM/MWM file or directory')
    fur_parser.add_argument('-o', '--output', help='Output file or directory')
    fur_parser.add_argument('--no-compress', action='store_true', help='Disable zlib compression')
    fur_parser.add_argument('--mfm-only', action='store_true', help='Only convert MFM files')
    fur_parser.add_argument('--msx-timing', action='store_true',
                            help='Tick at 60 Hz unless the song sets its 50 Hz flag, as on MSX '
                                 '(default: 50 Hz, as the ZX Spectrum players run)')
    fur_parser.set_defaults(func=convert_to_furnace)

    # VGM converter
    vgm_parser = subparsers.add_parser('vgm', help='Convert to VGM format')
    vgm_parser.add_argument('input', help='Input MFM/MWM file or directory')
    vgm_parser.add_argument('-o', '--output', help='Output file or directory')
    vgm_parser.set_defaults(func=convert_to_vgm)

    # VGM importer
    import_parser = subparsers.add_parser('import-vgm', help='Import VGM to MFM format')
    import_parser.add_argument('input', help='Input VGM file or directory')
    import_parser.add_argument('-o', '--output', help='Output MFM file or directory')
    import_parser.set_defaults(func=import_vgm)

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    args.func(args)


if __name__ == '__main__':
    main()
