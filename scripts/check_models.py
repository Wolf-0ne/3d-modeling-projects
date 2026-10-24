#!/usr/bin/env python3
"""Build declared model variants and validate the output.

Usage:
    python scripts/check_models.py
    python scripts/check_models.py --model drawer-cabinet-organizer
    python scripts/check_models.py --changed
    python scripts/check_models.py --paths models/foo models/bar
    python scripts/check_models.py --all
    python scripts/check_models.py --changed --jobs 4

For each model directory with a render.json, every variant (primary included)
is exported to build/<model>/<variant>.stl with --hardwarnings. A missing
include or unknown module is only a warning in OpenSCAD and still exits 0, so
warnings are treated as failures here.

Normal runs use a content-addressed cache in build/.check-cache.json. --all
forces a complete rebuild without reading or writing the cache. --changed uses
git status to scope the run to changed models and models that consume changed
libraries. --paths accepts explicit model directories, source files, or library
files and resolves them to the affected models.

STL parsing handles both ASCII and binary output. The bed check is a report by
default; --strict-bed turns an oversized part into a failure.
"""

import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE_PATH = ROOT / "build" / ".check-cache.json"
INCLUDE_RE = re.compile(r"^\s*(?:include|use)\s*<([^>]+)>", re.M)


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


def openscad_version(openscad):
    proc = subprocess.run(
        [openscad, "--version"],
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return (proc.stdout or "unknown").strip() or "unknown"


def include_closure(source):
    """Return [(relative path, sha256)] for source and its include graph."""
    seen = set()
    result = []

    def walk(path):
        try:
            resolved = path.resolve()
        except OSError:
            return
        try:
            relative = resolved.relative_to(ROOT).as_posix()
        except ValueError:
            relative = resolved.as_posix()
        if relative in seen or not resolved.is_file():
            return
        seen.add(relative)
        data = resolved.read_bytes()
        result.append((relative, hashlib.sha256(data).hexdigest()))
        text = data.decode("utf-8", errors="replace")
        for include in INCLUDE_RE.findall(text):
            walk(resolved.parent / include)

    walk(source)
    return sorted(result)


def variant_key(source, defines, version):
    payload = {
        "openscad": version,
        "source": source.resolve().as_posix(),
        "defines": defines or {},
        "includes": include_closure(source),
    }
    blob = json.dumps(payload, sort_keys=True, separators=(",", ":"), default=str)
    return hashlib.sha256(blob.encode("utf-8")).hexdigest()


def load_cache():
    try:
        data = json.loads(CACHE_PATH.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}
    return data if isinstance(data, dict) else {}


def save_cache(cache):
    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    CACHE_PATH.write_text(
        json.dumps(cache, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def git_changed_paths():
    try:
        proc = subprocess.run(
            ["git", "status", "--porcelain", "--untracked-files=all"],
            cwd=ROOT,
            text=True,
            encoding="utf-8",
            errors="replace",
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
    except OSError:
        sys.exit("error: --changed needs git; use --all")
    if proc.returncode != 0:
        sys.exit("error: --changed needs a git worktree; use --all")

    paths = set()
    for line in (proc.stdout or "").splitlines():
        if len(line) < 4:
            continue
        raw = line[3:].strip()
        if " -> " in raw:
            raw = raw.split(" -> ", 1)[1]
        raw = raw.strip().strip('"').replace("\\", "/")
        if raw:
            paths.add(raw)
    return paths


def all_model_dirs():
    return sorted(
        path
        for path in (ROOT / "models").iterdir()
        if path.is_dir() and not path.name.startswith("_")
    )


def _relative_to_root(path):
    try:
        return path.resolve().relative_to(ROOT)
    except (OSError, ValueError):
        return None


def models_for_paths(paths):
    """Resolve explicit model dirs, source files, or libraries to model dirs."""
    selected = set()
    library_paths = set()
    dirs = all_model_dirs()

    for raw in paths:
        path = Path(raw)
        if not path.is_absolute():
            path = ROOT / path
        path = path.resolve()
        if not path.exists():
            sys.exit(f"error: path does not exist: {raw}")

        relative = _relative_to_root(path)
        if relative is None:
            sys.exit(f"error: path is outside the repository: {raw}")

        parts = relative.parts
        if len(parts) == 0:
            continue
        if parts[0] == "models" and len(parts) > 1:
            model_dir = ROOT / "models" / parts[1]
            if model_dir.is_dir():
                selected.add(parts[1])
        elif parts[0] == "libraries":
            library_paths.add(relative.as_posix())

    if library_paths:
        for model_dir in dirs:
            variants = load_variants(model_dir) or {}
            for entry in variants.values():
                source = model_dir / entry["file"]
                closure = include_closure(source)
                if any(
                    relative == library
                    or relative.startswith(library + "/")
                    for relative, _digest in closure
                    for library in library_paths
                ):
                    selected.add(model_dir.name)
                    break

    return [model_dir for model_dir in dirs if model_dir.name in selected]


def changed_model_dirs():
    paths = git_changed_paths()
    names = set()
    library_changed = False

    for path in paths:
        parts = path.split("/")
        if parts[0] == "models" and len(parts) > 1:
            if not parts[1].startswith("_"):
                names.add(parts[1])
        if parts[0] == "libraries":
            library_changed = True

    dirs = all_model_dirs()
    if library_changed:
        for model_dir in dirs:
            variants = load_variants(model_dir) or {}
            for entry in variants.values():
                source = model_dir / entry["file"]
                if any(
                    relative.startswith("libraries/")
                    for relative, _digest in include_closure(source)
                ):
                    names.add(model_dir.name)
                    break

    return [model_dir for model_dir in dirs if model_dir.name in names]


def build_one(task):
    label, source, out, defines, openscad = task
    code, bad, output = run_export(openscad, source, out, defines)
    if code != 0 or bad:
        detail = "; ".join(bad[:3]) or (
            output.strip().splitlines()[-1] if output.strip() else "no output"
        )
        return {
            "label": label,
            "ok": False,
            "error": f"build failed ({code}): {detail}",
        }

    vertices, box = parse_stl(out)
    if not box or vertices == 0:
        return {
            "label": label,
            "ok": False,
            "error": "empty or unreadable STL",
        }

    return {
        "label": label,
        "ok": True,
        "vertices": vertices,
        "box": list(box),
        "stl_size": out.stat().st_size,
    }


def size_text(box):
    width = box[1] - box[0]
    depth = box[3] - box[2]
    height = box[5] - box[4]
    return f"{width:.1f}x{depth:.1f}x{height:.1f}"


def main():
    parser = argparse.ArgumentParser()
    scope = parser.add_mutually_exclusive_group()
    scope.add_argument("--model", default=None, help="model name or directory")
    scope.add_argument(
        "--changed",
        action="store_true",
        help="only models changed in git (and library consumers)",
    )
    scope.add_argument(
        "--paths",
        nargs="+",
        metavar="PATH",
        help="model dirs, source files, or library files to check",
    )
    scope.add_argument(
        "--all",
        action="store_true",
        help="build every variant and bypass the cache",
    )
    parser.add_argument(
        "--jobs",
        type=int,
        default=max(1, min(4, (os.cpu_count() or 2) - 2)),
        help="parallel OpenSCAD exports (default: up to 4)",
    )
    parser.add_argument("--bed", default="210x250", help="bed size WxH")
    parser.add_argument(
        "--strict-bed",
        action="store_true",
        help="fail when a part does not fit the configured bed",
    )
    args = parser.parse_args()

    if args.jobs < 1:
        sys.exit("error: --jobs must be at least 1")

    if args.model:
        candidate = Path(args.model)
        model_dir = candidate if candidate.is_absolute() else ROOT / candidate
        if not model_dir.is_dir():
            model_dir = ROOT / "models" / args.model
        model_dirs = [model_dir]
    elif args.changed:
        model_dirs = changed_model_dirs()
        if not model_dirs:
            print("no changed models; nothing to check")
            return 0
    elif args.paths:
        model_dirs = models_for_paths(args.paths)
        if not model_dirs:
            print("no model paths matched; nothing to check")
            return 0
    else:
        model_dirs = all_model_dirs()

    bed = parse_bed(args.bed)
    openscad = find_openscad()
    version = openscad_version(openscad)
    cache_enabled = not args.all
    cache = load_cache() if cache_enabled else {}

    records = []
    pending = []
    failures = []

    for model_dir in model_dirs:
        variants = load_variants(model_dir)
        if not variants:
            continue

        for name, entry in variants.items():
            source = model_dir / entry["file"]
            label = f"{model_dir.name}/{name}"
            out = ROOT / "build" / model_dir.name / f"{name}.stl"

            if not source.is_file():
                failures.append(f"{label}: missing source {source}")
                records.append((label, "FAIL", None, None, None, None))
                continue

            key = variant_key(source, entry.get("defines"), version)
            cached = cache.get(label) if cache_enabled else None
            if (
                isinstance(cached, dict)
                and cached.get("key") == key
                and out.is_file()
                and cached.get("stl_size") == out.stat().st_size
                and cached.get("vertices")
                and cached.get("box")
            ):
                records.append((label, "cached", cached["vertices"], cached["box"], None, key))
                continue

            records.append((label, "pending", None, None, entry.get("defines"), key))
            pending.append((label, source, out, entry.get("defines"), openscad))

    results = {}
    if pending:
        if args.jobs > 1 and len(pending) > 1:
            with ProcessPoolExecutor(max_workers=args.jobs) as executor:
                for result in executor.map(build_one, pending):
                    results[result["label"]] = result
        else:
            for task in pending:
                result = build_one(task)
                results[result["label"]] = result

    rows = []
    cached_count = 0
    for label, state, vertices, box, _defines, key in records:
        if state == "cached":
            cached_count += 1
            rows.append((label, "cached", str(vertices), size_text(box), box))
            continue

        if state == "FAIL":
            rows.append((label, "FAIL", "-", "-", "-"))
            continue

        result = results.get(label)
        if not result or not result.get("ok"):
            error = result.get("error", "unknown build failure") if result else "no result"
            failures.append(f"{label}: {error}")
            cache.pop(label, None)
            rows.append((label, "FAIL", "-", "-", "-"))
            continue

        box = result["box"]
        rows.append((label, "OK", str(result["vertices"]), size_text(box), box))
        if cache_enabled:
            cache[label] = {
                "key": key,
                "vertices": result["vertices"],
                "box": box,
                "stl_size": result["stl_size"],
            }

    if cache_enabled:
        save_cache(cache)

    if not rows:
        print("no models with render.json found")
        return 0

    report_rows = []
    for label, status, vertices, size, box in rows:
        if status in ("OK", "cached"):
            bed_ok = fits_bed(
                (box[1] - box[0], box[3] - box[2]),
                bed,
            )
            bed_text = "ok" if bed_ok else "EXCEEDS"
            if args.strict_bed and not bed_ok:
                failures.append(f"{label}: {size} exceeds bed {args.bed}")
        else:
            bed_text = "-"
        report_rows.append((label, status, vertices, size, bed_text))

    widths = [max(len(str(row[i])) for row in report_rows) for i in range(5)]
    header = ("model/variant", "status", "verts", "bbox mm", "bed")
    print(
        f"{header[0]:<{widths[0]}}  {header[1]:<{widths[1]}}  "
        f"{header[2]:>{widths[2]}}  {header[3]:>{widths[3]}}  {header[4]}"
    )
    for row in report_rows:
        print(
            f"{row[0]:<{widths[0]}}  {row[1]:<{widths[1]}}  "
            f"{row[2]:>{widths[2]}}  {row[3]:>{widths[3]}}  {row[4]}"
        )

    if failures:
        print("\nfailures:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    summary = f"{len(report_rows)} variant(s) checked clean"
    if cached_count:
        summary += f" ({cached_count} cached)"
    print(f"\n{summary}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
