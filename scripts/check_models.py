#!/usr/bin/env python3
"""Build every declared model variant and validate the output.

Usage:
    python scripts/check_models.py
    python scripts/check_models.py --model drawer-cabinet-organizer
    python scripts/check_models.py --bed 210x250 --strict-bed

For each model directory with a render.json, every variant (primary included)
is exported to build/<model>/<variant>.stl with --hardwarnings. A missing
include or unknown module is only a warning in OpenSCAD and still exits 0, so
warnings are treated as failures here.

STL parsing handles both ASCII and binary output. The bed check is a report by
default; --strict-bed turns an oversized part into a failure.
"""

import argparse
import json
import os
import shutil
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def find_openscad():
    env = os.environ.get("OPENSCAD_BIN")
    candidates = []
    if env:
        candidates.append(env)
    for env_name in ("ProgramFiles", "ProgramFiles(x86)", "ProgramW6432"):
        base = os.environ.get(env_name)
        if base:
            candidates.append(str(Path(base) / "OpenSCAD" / "openscad.exe"))
    candidates += [
        "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
        "openscad",
    ]
    for candidate in candidates:
        path = candidate if os.path.isabs(candidate) else shutil.which(candidate)
        if path and Path(path).exists():
            return str(path)
    sys.exit("error: OpenSCAD not found; set OPENSCAD_BIN")


def load_variants(model_dir):
    spec_path = model_dir / "render.json"
    if not spec_path.is_file():
        return None
    spec = json.loads(spec_path.read_text(encoding="utf-8-sig"))
    variants = dict(spec.get("variants") or {})
    primary = spec.get("primary")
    if primary:
        variants = {
            "primary": {
                "file": primary,
                "defines": spec.get("defines") or {},
            },
            **variants,
        }
    return variants


def define_args(defines):
    args = []
    for key, value in (defines or {}).items():
        if isinstance(value, bool):
            value = "true" if value else "false"
        elif isinstance(value, str):
            value = json.dumps(value)
        args += ["-D", f"{key}={value}"]
    return args


def run_export(openscad, source, out, defines):
    out.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        openscad,
        "--hardwarnings",
        *define_args(defines),
        "-o",
        str(out),
        str(source),
    ]
    proc = subprocess.run(
        cmd,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    output = proc.stdout or ""
    bad = [
        line
        for line in output.splitlines()
        if line.startswith(("WARNING:", "ERROR:"))
    ]
    return proc.returncode, bad, output


def bounds(vertices):
    xs = [v[0] for v in vertices]
    ys = [v[1] for v in vertices]
    zs = [v[2] for v in vertices]
    return (
        min(xs), max(xs),
        min(ys), max(ys),
        min(zs), max(zs),
    )


def parse_stl(path):
    """Return (vertex_count, (xmin, xmax, ymin, ymax, zmin, zmax))."""
    data = path.read_bytes()
    if not data:
        return 0, None

    if data[:5].lower() == b"solid":
        vertices = []
        for line in data.splitlines():
            stripped = line.strip()
            if stripped.lower().startswith(b"vertex"):
                parts = stripped.split()
                if len(parts) >= 4:
                    try:
                        vertices.append(tuple(float(v) for v in parts[1:4]))
                    except ValueError:
                        continue
        if vertices:
            return len(vertices), bounds(vertices)

    if len(data) >= 84:
        count = struct.unpack_from("<I", data, 80)[0]
        if count > 0 and 84 + count * 50 <= len(data):
            vertices = []
            offset = 84
            for _ in range(count):
                values = struct.unpack_from("<12fH", data, offset)
                vertices.extend((values[3:6], values[6:9], values[9:12]))
                offset += 50
            return len(vertices), bounds(vertices)

    return 0, None


def parse_bed(value):
    try:
        width, height = (float(part) for part in value.lower().split("x"))
    except ValueError:
        sys.exit("error: --bed must look like 210x250")
    return width, height


def fits_bed(size, bed):
    x, y = size
    bed_x, bed_y = bed
    return (x <= bed_x and y <= bed_y) or (x <= bed_y and y <= bed_x)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default=None, help="model name or directory")
    parser.add_argument("--bed", default="210x250", help="bed size WxH")
    parser.add_argument(
        "--strict-bed",
        action="store_true",
        help="fail when a part does not fit the configured bed",
    )
    args = parser.parse_args()

    if args.model:
        candidate = Path(args.model)
        model_dir = candidate if candidate.is_absolute() else ROOT / candidate
        if not model_dir.is_dir():
            model_dir = ROOT / "models" / args.model
        model_dirs = [model_dir]
    else:
        model_dirs = sorted(
            path
            for path in (ROOT / "models").iterdir()
            if path.is_dir() and not path.name.startswith("_")
        )

    bed = parse_bed(args.bed)
    openscad = find_openscad()
    rows = []
    failures = []

    for model_dir in model_dirs:
        variants = load_variants(model_dir)
        if not variants:
            continue

        for name, entry in variants.items():
            source = model_dir / entry["file"]
            label = f"{model_dir.name}/{name}"

            if not source.is_file():
                failures.append(f"{label}: missing source {source}")
                rows.append((label, "FAIL", "-", "-", "-"))
                continue

            out = ROOT / "build" / model_dir.name / f"{name}.stl"
            code, bad, output = run_export(
                openscad, source, out, entry.get("defines")
            )

            if code != 0 or bad:
                detail = "; ".join(bad[:3]) or (
                    output.strip().splitlines()[-1] if output.strip() else "no output"
                )
                failures.append(f"{label}: build failed ({code}): {detail}")
                rows.append((label, "FAIL", "-", "-", "-"))
                continue

            vertices, box = parse_stl(out)
            if not box or vertices == 0:
                failures.append(f"{label}: empty or unreadable STL")
                rows.append((label, "FAIL", "0", "-", "-"))
                continue

            width = box[1] - box[0]
            depth = box[3] - box[2]
            height = box[5] - box[4]
            size_text = f"{width:.1f}x{depth:.1f}x{height:.1f}"
            bed_ok = fits_bed((width, depth), bed)
            bed_text = "ok" if bed_ok else "EXCEEDS"

            if args.strict_bed and not bed_ok:
                failures.append(f"{label}: {size_text} exceeds bed {args.bed}")

            rows.append((label, "OK", str(vertices), size_text, bed_text))

    if not rows:
        print("no models with render.json found")
        return 0

    widths = [max(len(str(row[i])) for row in rows) for i in range(5)]
    header = ("model/variant", "status", "verts", "bbox mm", "bed")
    print(
        f"{header[0]:<{widths[0]}}  {header[1]:<{widths[1]}}  "
        f"{header[2]:>{widths[2]}}  {header[3]:>{widths[3]}}  {header[4]}"
    )
    for row in rows:
        print(
            f"{row[0]:<{widths[0]}}  {row[1]:<{widths[1]}}  "
            f"{row[2]:>{widths[2]}}  {row[3]:>{widths[3]}}  {row[4]}"
        )

    if failures:
        print("\nfailures:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(f"\n{len(rows)} variant(s) built clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
