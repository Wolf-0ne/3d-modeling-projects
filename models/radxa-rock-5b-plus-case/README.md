# Radxa Rock 5B+ Case

Vented enclosure for the Radxa Rock 5B+ with optional top antenna mounts,
modem mounting, and 25 mm or 30 mm fan layouts.

Published on [Printables](https://www.printables.com/model/1218830-radxa-rock-5b-case).

![Isometric preview](img/primary/iso.png)

## Status

- Last verified: 2026-10-22 (build)
- OpenSCAD version: see the [root README](../../README.md)
- Physically tested on: not recorded

## Files

| File | Purpose |
|---|---|
| `rock5bplus_model.scad` | standalone body, lid, and feature options |
| `render.json` | primary and declared feature variants |

## Variants

| Variant | Image | Feature |
|---|---|---|
| primary | `img/primary/` | 30 mm fans, 2 SMA, modem |
| `sma0` | `img/sma0/` | 30 mm fans, 0 SMA, modem |
| `sma4` | `img/sma4/` | 30 mm fans, 4 SMA, modem |
| `modem_off` | `img/modem_off/` | 30 mm fans, 2 SMA, no modem |
| `fan25` | `img/fan25/` | 25 mm fans, 2 SMA, modem |
| `lessfans` | `img/lessfans/` | reduced fan cutouts |
| `shrink` | `img/shrink/` | no top fan space |

`render.json` selects `sma=2 modemMount=1 fan_25mm=0` for the primary preview.
The source defaults remain `sma=0 modemMount=0`, matching the public source.

## Options

```bash
-D sma=0|2|4          # top antenna mounts
-D modemMount=0|1     # upper modem mount
-D fan_25mm=0|1       # 30 mm or 25 mm fan space
-D less_fans=0|1      # reduce fan cutouts
-D shrink=0|1         # remove top fan space
-D body=0|1           # show body
-D lid=0|1            # show lid
-D pcb=0|1            # show PCB reference
```

## Hardware

| Item | Qty | Notes |
|---|---|---|
| Flat M3x6 screw | 4 | Lid |
| Self-tapping screw | 2 | Approx. M2.5 x 6 mm; board alignment pegs |
| 30 x 10 mm or 25 x 10 mm fan | 1 | Fan position depends on variant |
| SMA antenna | Optional | Side-grid or lid mounts on some variants |
| Modem carrier board | Optional | May need auxiliary power |

The board is aligned by body pegs. Some variants support an internal modem;
check the carrier-board dimensions and power requirement.

## Material

PETG.

## Printing

Print the body and lid as oriented. Tree supports are recommended for the body;
the model does not include supports. The model is designed for a 210 x 250 mm
bed. Some cleanup may be needed.

## Build

```bash
python scripts/check_models.py --model radxa-rock-5b-plus-case
python scripts/render_previews.py models/radxa-rock-5b-plus-case --all
```

Or directly:

```bash
openscad --hardwarnings -D sma=2 -D modemMount=1 -o build/rock5b.stl rock5bplus_model.scad
```

## Known issues

- Physical-test status is not recorded.
- The branding text uses `Consolas:Bold`; override the font in OpenSCAD if it
  is unavailable on the host.

## License

CC BY 4.0 — WolfOne (@wolfone_17684). See the repository [LICENSE](../../LICENSE).
