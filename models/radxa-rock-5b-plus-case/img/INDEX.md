# Rock 5B+ feature previews

One preview per feature, not a full option matrix.

| Variant | Config | Preview |
|---|---|---|
| primary | 30 mm, 2 SMA, modem | [iso](primary/iso.png) |
| sma0 | 30 mm, 0 SMA, modem | [iso](sma0/iso.png) |
| sma4 | 30 mm, 4 SMA, modem | [iso](sma4/iso.png) |
| modem_off | 30 mm, 2 SMA, no modem | [iso](modem_off/iso.png) |
| fan25 | 25 mm, 2 SMA, modem | [iso](fan25/iso.png) |
| lessfans | 30 mm, 2 SMA, modem | [iso](lessfans/iso.png) |
| shrink | 30 mm, 2 SMA, modem | [iso](shrink/iso.png) |

Canonical source is the standalone public source with the corrected
`plate`/`grid` helpers. The legacy `rock5bplus_model.scad` and separate
`_output` file were moved to `tmp/rock-removed/`.

The old model candidate's top/bottom hex grid rendered open/broken; that was
the original `resources.scad` path, not a staged edit.
