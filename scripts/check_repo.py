#!/usr/bin/env python3
"""Validate repository consistency before committing.

Checks:
- required scaffold files exist
- relative links in Markdown resolve
- no local-state paths in tracked text files

Exit code 1 on any failure.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "README.md",
    "LICENSE",
    ".gitignore",
    ".gitattributes",
    "libraries/std.scad",
    "libraries/README.md",
    "models/README.md",
    "models/_template/README.md",
    "models/_template/render.json",
    "scripts/check_models.py",
    "scripts/render_previews.py",
    "scripts/check_repo.py",
]

TEXT_SUFFIXES = {".md", ".scad", ".py", ".json"}
TEXT_NAMES = {".gitignore", ".gitattributes", "LICENSE"}
SKIP_DIRS = {".git", "build", "__pycache__"}

# Built from fragments so this file does not match its own scan.
LOCAL_PATTERNS = [
    "C:" + "\\",
    "F:" + "\\",
    "/" + "Users/",
    "Users" + "\\",
    "Wolf" + "-001",
    "Public" + "-Candidate",
    "plans" + "/",
    "Private" + "/",
    "local" + "host",
    "192" + ".168.",
]
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")


def iter_files():
    for path in ROOT.rglob("*"):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.is_file():
            yield path


def main():
    errors = []

    for relative in REQUIRED:
        if not (ROOT / relative).is_file():
            errors.append(f"missing required file: {relative}")

    for path in iter_files():
        relative = path.relative_to(ROOT)
        if path.suffix.lower() in TEXT_SUFFIXES or path.name in TEXT_NAMES:
            text = path.read_text(encoding="utf-8", errors="replace")
            for pattern in LOCAL_PATTERNS:
                if pattern in text:
                    errors.append(f"local-state pattern {pattern!r} in {relative}")

            if path.suffix.lower() == ".md":
                for target in LINK_RE.findall(text):
                    if target.startswith(("http://", "https://", "mailto:", "#")):
                        continue
                    clean = target.split("#", 1)[0]
                    if not clean:
                        continue
                    if not (path.parent / clean).resolve().exists():
                        errors.append(f"broken link in {relative}: {target}")

    if errors:
        print("repository check failed:")
        for error in errors:
            print(f"  - {error}")
        return 1

    print("repository check passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
