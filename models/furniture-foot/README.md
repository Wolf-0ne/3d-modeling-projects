# Furniture Foot

Tapered round foot with a center recess, intended as a replaceable furniture or
equipment foot.

![Furniture foot preview](img/primary/iso.png)

## Status

- Last verified: 2026-10-22 (build)
- OpenSCAD version: see the [root README](../../README.md)
- Physically tested: yes

## Files

| File | Purpose |
|---|---|
| `furniture_foot.scad` | tapered foot |
| `render.json` | primary entry point |

## Dimensions

- Base diameter: 20 mm.
- Top diameter: 15 mm.
- Height: 6 mm.
- Center 6 mm through-hole for a screw shank, with a 10 mm recess
  (2 mm deep) for the screw head.

The model can be scaled for different hardware and furniture sizes.

## Hardware

A screw through the 6 mm center hole; the head seats in the 10 mm
recess.

## Material

TPU or a similar rubbery material.

## Printing

Print as oriented. No supports are modeled.

## Build

```bash
python scripts/check_models.py --model furniture-foot
python scripts/render_previews.py models/furniture-foot --all
```

## Known issues

- Not yet published on Printables.

## License

CC BY 4.0 — WolfOne (@wolfone_17684). See the repository [LICENSE](../../LICENSE).
