#!/usr/bin/env python3
"""Convert every demo-disk song to Furnace and write the collection indexes.

    demo-disks/<disk>/<SONG>.MFM|MWM  ->  converted/furnace/<disk>/<SONG>.fur

and regenerates converted/README.md (formats, disk mapping, A-Z song index)
and converted/furnace/README.md (per-disk tables mapping each .fur to its
source file, TR-DOS image and demo melody number from
demo-disks/<disk>/melody-mapping.md).

Usage (from tools/moonsound-decoder):  python3 scripts/export_furnace_collection.py
"""

import hashlib
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
DECODER = HERE.parent
REPO = DECODER.parent.parent
sys.path.insert(0, str(DECODER))

from src.mfm_parser import MFMParser                       # noqa: E402
from src.mwm_parser import MWMParser                       # noqa: E402
from src.converters.furnace import FurnaceConverter       # noqa: E402
from src.converters.furnace.converter import ZX_TICK_RATE  # noqa: E402

DEMO = REPO / "demo-disks"
OUT = REPO / "converted" / "furnace"
SONG_RE = re.compile(r"\.(mfm|mwm)$", re.I)


def info_string(raw: bytes, is_mwm: bool) -> str:
    off = 0xE2 if is_mwm else 0x2D4
    text = raw[off:off + 50].decode("ascii", "replace")
    return " ".join(text.replace("_", " ").split())


def kit_name(raw: bytes, is_mwm: bool) -> str:
    off = 0xE2 + 50 if is_mwm else 0x2D4 + 0x56
    return raw[off:off + 8].decode("ascii", "replace").strip()


def song_seconds(song, is_mwm: bool) -> float:
    """One pass through the song in player timing (rows last `speed`
    interrupts; command step: 1-23 speed = 25-cmd, 24 ends the pattern)."""
    patterns = {p.index: p for p in song.patterns}
    speed, ticks = max(1, song.tempo), 0
    for idx in song.positions:
        for row in patterns[idx].rows if idx in patterns else []:
            if is_mwm:
                cmd = next((e.raw_value for e in row.events if e.channel == 24), 0)
            else:
                cmd = row.command
            if 1 <= cmd <= 23:
                speed = max(1, 25 - cmd)
            ticks += speed
            if cmd == 24:
                break
    return ticks / ZX_TICK_RATE


def melody_numbers(disk: Path) -> dict:
    """File name -> list of demo melody numbers from melody-mapping.md."""
    result = defaultdict(list)
    mapping = disk / "melody-mapping.md"
    if not mapping.exists():
        return result
    for line in mapping.read_text(encoding="utf-8", errors="replace").splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 2 or not cells[0].isdigit():
            continue
        for cell in cells[1:]:
            m = re.search(r"\b([A-Za-z0-9_\-]+\.(?:MFM|MWM))\b", cell, re.I)
            if m:
                nums = result[m.group(1).upper()]
                if int(cells[0]) not in nums:     # files may appear in several tables
                    nums.append(int(cells[0]))
                break
    return result


def disk_images(disk: Path) -> list:
    return sorted(p.name for p in disk.iterdir() if p.suffix.lower() in (".trd", ".scl"))


def md(text: str) -> str:
    return text.replace("|", "\\|")


def main():
    commit = subprocess.run(["git", "-C", str(REPO), "rev-parse", "--short", "HEAD"],
                            capture_output=True, text=True).stdout.strip() or "unknown"
    rows, by_hash, warnings = [], defaultdict(list), []
    total_bytes = 0

    for disk in sorted(p for p in DEMO.iterdir() if p.is_dir()):
        songs = sorted(p for p in disk.iterdir() if SONG_RE.search(p.name))
        if not songs:
            continue
        melodies = melody_numbers(disk)
        images = disk_images(disk)
        for src in songs:
            is_mwm = src.suffix.lower() == ".mwm"
            data = src.read_bytes()
            song = (MWMParser if is_mwm else MFMParser)().parse(data)
            conv = FurnaceConverter(compress=True, source_path=str(src))
            fur = conv.convert_mwm(song) if is_mwm else conv.convert_mfm(song)
            dst = OUT / disk.name / (src.stem + ".fur")
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes(fur)
            total_bytes += len(fur)
            digest = hashlib.sha1(data).hexdigest()
            by_hash[digest].append(f"{disk.name}/{src.name}")
            for w in conv.warnings:
                warnings.append((f"{disk.name}/{src.name}", w))
            secs = song_seconds(song, is_mwm)
            rows.append(dict(
                disk=disk.name, images=images, src=src.name, fur=dst.name,
                fmt="MWM" if is_mwm else "MFM",
                melody=",".join(map(str, melodies.get(src.name.upper(), []))) or "—",
                info=info_string(data, is_mwm), kit=kit_name(data, is_mwm),
                chains=None if is_mwm else data[0x24B],
                length=f"{int(secs // 60)}:{int(secs % 60):02d}",
                hz={0: 60, 1: 50}.get(song.hz_equalizer, f"timer {song.hz_equalizer}"),
                positions=len(song.positions), sha=digest[:8], size=len(fur),
                warn=bool(conv.warnings)))
        print(f"{disk.name}: {len(songs)} songs")

    dupes = {h: v for h, v in by_hash.items() if len(v) > 1}
    write_readme(rows, dupes, warnings, commit, total_bytes)
    write_top_readme(rows, total_bytes)
    print(f"{len(rows)} songs -> {OUT.relative_to(REPO)} ({total_bytes / 1048576:.1f} MB)")


def write_readme(rows, dupes, warnings, commit, total_bytes):
    n_mfm = sum(1 for r in rows if r["fmt"] == "MFM")
    n_mwm = len(rows) - n_mfm
    dup_of = {}
    for paths in dupes.values():
        for p in paths:
            dup_of[p] = [q for q in paths if q != p]

    out = []
    w = out.append
    w("# MoonSound Demo Collection — Furnace Conversions\n")
    w("Every MoonBlaster song from [`demo-disks/`](../../demo-disks/) converted to "
      "[Furnace](https://github.com/tildearrow/furnace) tracker modules (`.fur`) for the "
      "Yamaha YMF278B (OPL4), so the music can be played, studied and edited on a modern "
      "machine without MoonSound hardware or an MSX / ZX Spectrum emulator.\n")
    w(f"- **{len(rows)} modules:** {n_mfm} from `.MFM` (MoonBlaster FM) and {n_mwm} from "
      f"`.MWM` (MoonBlaster Wave), {total_bytes / 1048576:.1f} MB in total.")
    w(f"- **Converter:** [`tools/moonsound-decoder`](../../tools/moonsound-decoder/), "
      f"repository commit `{commit}`. How it works and how it was verified: "
      "[furnace-converter.md](../../tools/moonsound-decoder/doc/furnace-converter.md).")
    w("- **Opens in:** Furnace **0.6.8.3** or newer (desktop app: *File → Open*). The files "
      "use Furnace's module format version 100, which newer releases load too.\n")

    w("## Folder layout\n")
    w("The folders mirror `demo-disks/`, so every module has the same relative path as its "
      "source song with `.fur` instead of `.MFM`/`.MWM`:\n")
    w("```")
    w("demo-disks/moonsound_11/GALIOUS.MWM   ->  converted/furnace/moonsound_11/GALIOUS.fur")
    w("demo-disks/mfm_sample_02/CRYOGENT.MFM ->  converted/furnace/mfm_sample_02/CRYOGENT.fur")
    w("```\n")
    w("`moonsound_01` holds no songs (driver only), so it has no folder here.\n")

    w("## What is inside a module\n")
    w("| Part | MFM songs | MWM songs |")
    w("|------|-----------|-----------|")
    w("| Chip | OPL4 (`0xAE`), 42 channels | OPL4 (`0xAE`), 42 channels |")
    w("| FM (channels 0-17) | 2-op and 4-op voices, allocated like the original player | "
      "Unused; hidden in the editor |")
    w("| PCM (channels 18-41) | The 6 wave tracks on 18-23 | The 24 wave tracks on 18-41 |")
    w("| Instruments | 24 two-op + 12 four-op FM patches, plus one MultiPCM instrument per "
      "wave voice | One MultiPCM instrument per wave voice |")
    w("| Samples | Waveforms extracted from the YRW-801 ROM (or `.MWK` kit) actually used | "
      "Same |")
    w("| Patterns | One 16-row pattern per song position (positions unrolled) | Same |")
    w("| Timing | Speed = song tempo; 50 Hz ticks, as on the ZX Spectrum (see *Timing* below) | Same |\n")
    w("Samples are embedded in each module, so a module plays on its own without the ROM.\n")
    w("**Timing.** Every module ticks at 50 Hz, because that's how the demo disks play on the "
      "ZX Spectrum. The players run once per 50 Hz frame interrupt. Where a player waits for the "
      "OPL4 timer (59.5 Hz for songs whose Hz flag is 60), the card never routes that timer's "
      "IRQ to the Z80, so the flag is only polled on 50 Hz frames. The *Hz flag* column shows "
      "what each song stores (MSX meaning: 60 = NTSC); on the ZX it doesn't change the "
      "speed.\n")

    by_disk = defaultdict(list)
    for r in rows:
        by_disk[r["disk"]].append(r)

    w("## Disk summary\n")
    w("| Disk | Format | Songs | Played by the demo | Disk image | Source folder | Modules |")
    w("|------|--------|------:|-------------------:|------------|---------------|---------|")
    for disk, items in by_disk.items():
        played = sum(1 for r in items if r["melody"] != "—")
        imgs = ", ".join(f"`{i}`" for i in items[0]["images"]) or "—"
        w(f"| [{disk}](#{disk}) | {items[0]['fmt']} | {len(items)} | {played} | {imgs} "
          f"| [`demo-disks/{disk}/`](../../demo-disks/{disk}/) | [`{disk}/`]({disk}/) |")
    w("")

    w("## Index\n")
    w("Columns:\n")
    w("- **Melody:** the song's number in the disk's own demo program, from the disk's "
      "`melody-mapping.md` (— if the demo doesn't play it).")
    w("- **Info:** the song's own 50-character info string (title / game / author).")
    w("- **Kit:** `NONE` = YRW-801 ROM sounds only; otherwise the `.MWK` sample kit.")
    w("- **4-op:** number of 4-operator FM chains (MFM only).")
    w("- **Hz flag:** the song's stored base frequency (see *Timing* above).")
    w("- **Length:** one pass through the song at the ZX's 50 Hz tick (loops not repeated).")
    w("- **Source SHA1:** first 8 hex digits of the source file's SHA-1, to match copies.\n")

    for disk, items in by_disk.items():
        imgs = ", ".join(f"[`{i}`](../../demo-disks/{disk}/{i})" for i in items[0]["images"]) or "—"
        mapping = f"[melody-mapping.md](../../demo-disks/{disk}/melody-mapping.md)"
        w(f"### {disk}\n")
        w(f"Source: [`demo-disks/{disk}/`](../../demo-disks/{disk}/) · disk image {imgs} · "
          f"track order {mapping} · {len(items)} songs\n")
        fm = items[0]["fmt"] == "MFM"
        head = "| Furnace module | Source | Melody | Info | Kit | " + ("4-op | " if fm else "") + \
               "Hz flag | Positions | Length | Source SHA1 |"
        w(head)
        w("|" + "---|" * (head.count("|") - 1))
        for r in items:
            note = " ⚠" if r["warn"] else ""
            dup = f" (= {', '.join(dup_of[f'{disk}/{r['src']}'])})" if f"{disk}/{r['src']}" in dup_of else ""
            w(f"| [`{r['fur']}`]({disk}/{r['fur']}){note} "
              f"| [`{r['src']}`](../../demo-disks/{disk}/{r['src']}){md(dup)} "
              f"| {r['melody']} | {md(r['info'])} | {r['kit']} | "
              + (f"{r['chains']} | " if fm else "")
              + f"{r['hz']} | {r['positions']} | {r['length']} | `{r['sha']}` |")
        w("")

    w("## Notes\n")
    if dupes:
        w("**Identical sources.** These files are byte-identical copies on more than one disk; "
          "each copy has its own module:\n")
        for paths in sorted(dupes.values()):
            w("- " + " = ".join(f"`{p}`" for p in paths))
        w("")
    if warnings:
        w("**Conversion warnings** (⚠ in the index):\n")
        for path, msg in warnings:
            w(f"- `{path}`: {msg}")
        w("")
    w("**Not yet translated.** Wave tracks (PCM) are complete apart from *damp*: their note "
      "links, pitch bends, detune and modulation are reproduced tick by tick as per-note pitch "
      "macros. On the FM side, MFM pitch bends, modulation and portamento are not converted "
      "yet, so FM passages that rely on them sound plainer than on real hardware. See "
      "[furnace-converter.md](../../tools/moonsound-decoder/doc/furnace-converter.md#not-yet-translated).\n")

    w("## Accuracy\n")
    w("The converter reproduces the original Z80 players' behaviour and was checked against "
      "them, not only against the file-format docs:\n")
    w("- **FM:** 421 of 428 key-ons in five songs match the original player running in an "
      "emulator exactly (same tick, channel, block and F-number); the rest are within 4 cents.")
    w("- **PCM:** every tick of every sounding wave note is compared with a tick-exact simulation "
      "of the player (pitch bends, links, detune and vibrato included), using Furnace's own "
      "register output. Over all 240 songs, 98.8% of 16.2 million sounding ticks are within 2 "
      "cents, and 217 songs never exceed 3 cents. The rest are songs that needed a coarser "
      "instrument-sharing tolerance (up to 12.5 cents, `ALLPART2`), note links inside notes longer "
      "than 255 ticks that land one tick late, and one bend in `TWINPEAK` that runs off the top "
      "of the chip's pitch range.\n")

    w("## Regenerating\n")
    w("From `tools/moonsound-decoder`:\n")
    w("```bash")
    w("python3 scripts/export_furnace_collection.py")
    w("```\n")
    w("This rewrites every module, this README and [`../README.md`](../README.md). It needs the YRW-801 ROM image at "
      "`hardware/firmware/YRW801-M - Yamaha - 1993.rom` and reads `.MWK` kits from each "
      "song's disk folder.\n")

    w("## Rights\n")
    w("The music belongs to its original composers (named in each song's info string); the "
      "embedded samples come from the Yamaha YRW-801 ROM or the MoonBlaster sample kits on "
      "the disks. Like the rest of this archive, the conversions are provided for historical "
      "and educational purposes.")

    (OUT / "README.md").write_text("\n".join(out) + "\n", encoding="utf-8")


def write_top_readme(rows, total_bytes):
    """converted/README.md: formats, disk -> folder mapping, A-Z song index."""
    out = []
    w = out.append
    by_disk = defaultdict(list)
    for r in rows:
        by_disk[r["disk"]].append(r)

    w("# Converted Music\n")
    w("The MoonBlaster songs from [`demo-disks/`](../demo-disks/) converted to formats that "
      "modern tools can open. Every conversion keeps the folder structure of `demo-disks/`, "
      "so `demo-disks/<disk>/<SONG>.MFM|MWM` becomes `converted/<format>/<disk>/<SONG>.<ext>`.\n")

    w("## Formats\n")
    w("| Format | Folder | Files | Size | Opens in | Index |")
    w("|--------|--------|------:|-----:|----------|-------|")
    w(f"| Furnace module (`.fur`), YMF278B / OPL4 | [`furnace/`](furnace/) | {len(rows)} "
      f"| {total_bytes / 1048576:.1f} MB | Furnace 0.6.8.3+ | [furnace/README.md](furnace/README.md) |")
    w("")
    w("Generated by [`tools/moonsound-decoder`](../tools/moonsound-decoder/) "
      "(`scripts/export_furnace_collection.py` rewrites the Furnace folder and both READMEs).\n")

    w("## Disk mapping\n")
    w("| Disk | Format | Songs | Disk image | Source | Track order | Furnace |")
    w("|------|--------|------:|------------|--------|-------------|---------|")
    for disk, items in by_disk.items():
        imgs = ", ".join(f"[`{i}`](../demo-disks/{disk}/{i})" for i in items[0]["images"]) or "—"
        w(f"| {disk} | {items[0]['fmt']} | {len(items)} | {imgs} "
          f"| [`demo-disks/{disk}/`](../demo-disks/{disk}/) "
          f"| [melody-mapping.md](../demo-disks/{disk}/melody-mapping.md) "
          f"| [`furnace/{disk}/`](furnace/{disk}/) · [table](furnace/README.md#{disk}) |")
    w("")
    w("`moonsound_01` contains only the player driver, no songs.\n")

    w("## Song index (A-Z)\n")
    w("All songs by file name. **Melody** is the song's number in its disk's demo program "
      "(— if the demo doesn't play it); **Info** is the song's own info string.\n")
    w("| Song | Info | Disk | Melody | Source | Furnace |")
    w("|------|------|------|-------:|--------|---------|")
    for r in sorted(rows, key=lambda r: (r["src"].upper(), r["disk"])):
        stem = r["src"].rsplit(".", 1)[0]
        w(f"| {stem} | {md(r['info'])} | {r['disk']} | {r['melody']} "
          f"| [`{r['src']}`](../demo-disks/{r['disk']}/{r['src']}) "
          f"| [`{r['fur']}`](furnace/{r['disk']}/{r['fur']}) |")
    w("")

    (OUT.parent / "README.md").write_text("\n".join(out) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
