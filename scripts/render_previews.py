#!/usr/bin/env python3
"""Render preview PNGs for a model directory.

Usage:
    python scripts/render_previews.py models/<name>
    python scripts/render_previews.py models/<name> --all
    python scripts/render_previews.py models/<name> --views iso,front,top
    python scripts/render_previews.py models/<name> --variant v2 --size 2000x1500

Reads models/<name>/render.json:

    {
      "primary": "model.scad",
      "defines": {"part": -1},
      "variants": {
        "v2": {"file": "model_v2.scad", "defines": {"part": -1}}
      }
    }

Primary variant only by default. Writes img/<variant>/iso.png for every selected
variant. Pass --views to render additional front/top views.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VIEWS = {
    "iso": (65, 0, 35),
    "front": (90, 0, 0),
    "top": (0, 0, 0),
}
DEFAULT_VIEWS = "iso"


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
        sys.exit(f"error: missing {spec_path}")
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
    if not variants:
        sys.exit(f"error: no primary/variants in {spec_path}")
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


def run(cmd):
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
    if proc.returncode != 0 or bad:
        print("\n".join(bad) or output.strip())
        sys.exit(f"error: OpenSCAD failed (exit {proc.returncode})")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "model",
        help="model directory, e.g. models/drawer-cabinet-organizer",
    )
    parser.add_argument(
        "--variant",
        action="append",
        default=None,
        help="variant to render (repeatable); default: primary",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="render every declared variant",
    )
    parser.add_argument("--size", default="1600x1200")
    parser.add_argument(
        "--views",
        default=DEFAULT_VIEWS,
        help="comma-separated views: iso, front, top (default: iso)",
    )
    args = parser.parse_args()

    model_dir = (ROOT / args.model).resolve()
    if model_dir.parent.name != "models":
        sys.exit("error: model must live directly under models/")
    if not model_dir.is_dir():
        sys.exit(f"error: {model_dir} is not a directory")

    try:
        width, height = (int(part) for part in args.size.lower().split("x"))
    except ValueError:
        sys.exit("error: --size must look like 1600x1200")

    variants = load_variants(model_dir)
    if args.all:
        selected = list(variants)
    elif args.variant:
        selected = args.variant
    else:
        selected = ["primary"]

    missing = [name for name in selected if name not in variants]
    if missing:
        sys.exit(
            f"error: unknown variant(s): {', '.join(missing)}; "
            f"have: {', '.join(variants)}"
        )

    selected_views = [view.strip() for view in args.views.split(",") if view.strip()]
    missing_views = [view for view in selected_views if view not in VIEWS]
    if missing_views:
        sys.exit(
            f"error: unknown view(s): {', '.join(missing_views)}; "
            f"have: {', '.join(VIEWS)}"
        )

    openscad = find_openscad()
    for name in selected:
        entry = variants[name]
        source = model_dir / entry["file"]
        if not source.is_file():
            sys.exit(f"error: missing source {source}")

        out_dir = model_dir / "img" / name
        out_dir.mkdir(parents=True, exist_ok=True)
        defines = define_args(entry.get("defines"))

        for view in selected_views:
            rot_x, _rot_y, rot_z = VIEWS[view]
            out = out_dir / f"{view}.png"
            cmd = [
                openscad,
                "--hardwarnings",
                "--render",
                f"--imgsize={width},{height}",
                "--projection=o",
                "--colorscheme=Cornfield",
                "--autocenter",
                "--viewall",
                f"--camera=0,0,0,{rot_x},0,{rot_z},0",
                *defines,
                "-o",
                str(out),
                str(source),
            ]
            run(cmd)
            print(f"wrote {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
