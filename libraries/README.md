# libraries

Shared OpenSCAD modules for every model in this repository. Models include the
aggregator once:

```scad
include <../../libraries/std.scad>
```

## Modules

| File | Provides | Notes |
|---|---|---|
| `grid.scad` | `cells`, `grid`, `create_grid`, `fillhex` | native hex grid; no BOSL2 |
| `hardware.scad` | `bar`, `bore`, `bore4`, `boltHoles`, `pin` | bores and standoffs |
| `plate.scad` | `plate` | hex-cut panel with rounded border |
| `branding.scad` | `byWolfOne`, `brandFont` | font-parameterised mark |

## Global contract

Older models define these before including the library:

- `wallThickness` — used by `plate()` when `wt` is omitted
- `boltX`, `boltY` — used by `boltHoles()` when `x`/`y` are omitted
- `outerThickness` — used by `pin()` when `ot` is omitted

New code should pass explicit parameters instead of relying on globals.

## Geometry compatibility

Defaults follow the original `resources.scad` (gen-1) for compatibility. This is
not a blanket guarantee: each migrated model is geometry-checked against its
published STL before it is added. The library is validated model by model.

- `fillhex(..., flip = 0, centered = false)` — gen-1 stagger and no z offset.
  The newer Rock Pi code used `centered = true` (z `-h/2`) with the same
  visual stagger.
- `plate()` keeps the `border > 0` guard around the cutout.
- `create_grid()` matches the gen-1 spacing formula, including its original
  "fudged to match legacy" comment.

Do not change these defaults without an STL comparison against the published
model (bbox alone does not prove internal hex placement). Until a model's check
passes, treat the library defaults as provisional for that model.

## Fonts

`brandFont` defaults to `Consolas:style=Bold`. Consolas is a Windows system
font and is not bundled. On other platforms override it:

```bash
openscad -D brandFont='"DejaVu Sans Mono:style=Bold"' model.scad
```

Suggested OFL alternatives: `DejaVu Sans Mono`, `Liberation Mono`.
