# Soldering Kit for the TS80P Iron

A storage kit for a TS80/TS80P soldering iron, tips, solder, cable, and power
supply. The dual layout is the primary, actively used version.

Published on [Printables](https://www.printables.com/model/314754-ts80p-soldering-kit).

![Isometric preview](img/primary/iso.png)

## Status

- Last verified: 2026-10-21 (build)
- OpenSCAD version: see the [root README](../../README.md)
- Physically tested on: Original Prusa MK3.5S

## Files

| File | Purpose |
|---|---|
| `soldering_kit.scad` | current kit; `type = "dual"` or `"single"` |
| `soldering_kit_legacy.scad` | older layout, kept as an optional variation |
| `render.json` | primary variant and declared variants |

## Variants

| Variant | Image | Dimensions | Difference |
|---|---|---|---|
| primary | `img/primary/` | 65 x 117 x 43 mm | 2 irons + 6 tips (default) |
| `single` | `img/single/` | 65 x 102 x 43 mm | 1 iron + 4 tips |
| `legacy` | `img/legacy/` | 65 x 118 x 43 mm | older opening layout |

The legacy file is kept separate because its body and opening layout differ
from the current parametric `type` paths.

## Dimensions

- Overall: 65 x 117 x 43 mm (dual), 65 x 102 x 43 mm (single),
  65 x 118 x 43 mm (legacy).
- Iron openings: 14.5 mm diameter (15 mm in the legacy layout).
- Tip openings: 9 mm diameter.
- Walls 2.5 mm. Zones: solder 22 mm, power 31 mm, storage 34 mm
  (dual) or 39 mm (single), cable 17.5 mm (dual only).

## Hardware

None.

## Material

PETG. Avoid PLA if the iron or tips may be stored still warm.

## Printing

Print flat on the base. The current source does not model supports.

## Build

```bash
python scripts/check_models.py --model ts80p-soldering-kit
python scripts/render_previews.py models/ts80p-soldering-kit --all
```

## Known issues

None recorded.

## License

CC BY 4.0 — WolfOne (@wolfone_17684). See the repository [LICENSE](../../LICENSE).
