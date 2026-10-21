# Model name

One-line description of what it is and what it fits.

<!-- After rendering, add the preview image: img/iso.png -->

This directory is a template. It has no model source; copy it when adding a
model, then generate `img/iso.png` with `render_previews.py`.

## Status

- Last verified: YYYY-MM-DD
- OpenSCAD version: see the root README (single source of truth)
- Physically tested on: (boards/cards/hardware actually used)

## Files

| File | Purpose |
|---|---|
| `model.scad` | primary variant |
| `render.json` | declared entry points and variants |

## Variants

| Variant | File | Difference |
|---|---|---|
| primary | `model.scad` | default |

## Hardware

| Item | Qty | Notes |
|---|---|---|
| | | |

Assembly notes, fasteners, inserts, and any non-print parts.

## Printing

No printer profiles, machine names, or personal slicer settings are published.
Document only design constraints that matter to others:

- orientation
- supports required or not
- material/heat constraints
- multi-part split points

## Build

```bash
python scripts/check_models.py --model <this-directory>
python scripts/render_previews.py models/<this-directory>
```

Or directly:

```bash
openscad --hardwarnings -o build/model.stl model.scad
```

## Fonts

If this model renders text, name the font and say where to obtain it. Fonts are
not bundled and are not covered by CC BY 4.0. OpenSCAD has no font-stack
fallback; a missing font changes the geometry silently.

## Known issues

- Anything a user should know before printing.

## License

CC BY 4.0 — WolfOne (@wolfone_17684).
