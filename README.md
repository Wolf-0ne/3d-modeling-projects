# 3d-modeling-projects

Collection of **WolfOne**'s 3D-printable models.

Printable STLs for published models are on
[Printables](https://www.printables.com/@wolfone_17684).

## What this is

This repository holds `.scad` sources, shared libraries, preview images, and the
scripts used to build and verify them. The only requirements are OpenSCAD and Python.

It deliberately does **not** contain STLs, 3MFs, gcode, slicer profiles, or
machine-specific print settings. Those are build artifacts; printable files are
published on Printables.

## Status

- **Last verified**: 2026-10-22 (Batch 7, workbench/tooling)
- **Models**: 14
- **Build check**: `python scripts/check_models.py` checks 40 variants with zero warnings

## Quick start

```bash
git clone https://github.com/Wolf-0ne/3d-modeling-projects.git
cd 3d-modeling-projects
python scripts/check_models.py
```

Requirements:

- **OpenSCAD 2022.06.26** — the version this repository is tested with. Newer
  versions may work but are not verified here.
- **Python 3.8+** — used for tooling and automation.

If `openscad` is not on `PATH`, set `OPENSCAD_BIN` (the Windows default is
under `Program Files\OpenSCAD`):

```powershell
$env:OPENSCAD_BIN = "<install-dir>\openscad.exe"
```

## Repository layout

```
libraries/   shared OpenSCAD modules (grid, hardware, plate, branding)
models/      one directory per model: source, render.json, README, img/
scripts/     headless build and preview helpers
build/       local STL output, gitignored
```

## Models

Each model directory contains its source, a `render.json`, a model README, and
preview images. The index lives in [`models/README.md`](models/README.md) and
lists only models that are actually present and verified.

## Build and preview

```bash
# Check all variants, reusing clean build results when sources are unchanged
python scripts/check_models.py

# Scope to models changed in git (and models using changed libraries)
python scripts/check_models.py --changed

# Force a complete rebuild and bypass the cache
python scripts/check_models.py --all

# Parallel OpenSCAD exports (default: up to 4)
python scripts/check_models.py --jobs 4

# One model
python scripts/check_models.py --model drawer-cabinet-organizer

# Preview the primary variant (isometric PNG by default)
python scripts/render_previews.py models/drawer-cabinet-organizer

# Preview every declared variant
python scripts/render_previews.py models/drawer-cabinet-organizer --all

# Add front and top views when they are useful
python scripts/render_previews.py models/drawer-cabinet-organizer --views iso,front,top
```

`check_models.py` writes STLs to `build/<model>/<variant>.stl`. Clean results are
keyed by source, include files, defines, and OpenSCAD version in
`build/.check-cache.json`; `--all` bypasses that cache. `--changed` requires a
git worktree; use `--all` from a downloaded ZIP. Local STLs may also sit beside
the `.scad` files while testing; every `*.stl`, `*.3mf`, and `*.gcode` is ignored
by git either way.

A model is ready to publish only when the build check emits **zero warnings**:
OpenSCAD exits 0 on a missing include or unknown module, so exit status alone
is not proof.

## Repository checks

Before committing changes:

```bash
python scripts/check_repo.py
```

This verifies required files, relative links, and local-path leaks. It does not
require OpenSCAD. Local STLs are ignored by git and are not treated as errors.

## Fonts

`libraries/branding.scad` renders the `byWolfOne` mark with
`brandFont = "Consolas:style=Bold"`. Consolas ships with Windows; it is not
bundled here and its glyphs are not redistributed. OpenSCAD has no font-stack
fallback: a missing font is silently substituted, changing the mark's geometry.

On systems without Consolas, override it:

```bash
openscad -D brandFont='"DejaVu Sans Mono:style=Bold"' ...
```

Suggested substitutes: `DejaVu Sans Mono` or `Liberation Mono` (both OFL).
Fonts are **not** covered by this repository's CC BY 4.0 license. The build
cache does not hash installed fonts; run `python scripts/check_models.py --all`
after changing font availability.

## What this repository does not publish

- STLs, 3MFs, gcode, or slicer project files
- printer profiles or personal machine settings
- third-party fonts
- compatibility claims that have not been physically tested

## Support

> [!TIP]
> If you like my work, check out my [Buy Me a Coffee](https://buymeacoffee.com/wolfone_) link.
>
> <a href="https://buymeacoffee.com/wolfone_"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" width="180"></a>

## Issues

Open an issue for build problems or source errors. Do not attach generated
artifacts; include the failing command and the warning text.

## License

Models and source are licensed under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
Attribution: **WolfOne** (@wolfone_17684).
