# V620 Fan Shroud

Printed fan shroud for the passive AMD Radeon PRO V620. It replaces the
server-chassis airflow path with a standard axial fan, so the card can be used
in a normal desktop case without buying a third-party shroud.

The primary version uses one **80 mm fan**. A **single-slot version** uses two
40 mm fans. The model is shared free so users do not need to buy a printed
shroud.

![V620 shroud preview](img/primary/iso.png)

## Status

- Last verified: 2026-10-25 (build)
- OpenSCAD version: see the [root README](../../README.md)
- Physically tested: yes, including the V620 fit and both 8-pin power plugs

## Compatibility

| Card | Fit |
|---|---|
| Radeon PRO V620 | Tested |
| Radeon PRO V340L | Compatible with the same opening; test-fit before relying on it |
| Instinct MI50 / MI100 | May fit with tweaks; check the heatsink opening and screw bosses |

The shroud grips the stock heatsink opening by friction. It does not screw to
the card. Check the opening, backplate, and power-connector clearance before
printing for another card.

## Fans

| Version | Fan |
|---|---|
| Primary | 1× ARCTIC S8038-7K (80 mm) |
| Single-slot | 2× ARCTIC S4028-15K (40 mm) |

The ARCTIC S4028-6K was tested and is not recommended for the 40 mm version.
Use the S4028-15K.

For the 80 mm version, **45% fan load** is the default setting. Start there and
increase only if the card is still throttling.

## Variants

| Variant | Fan layout | Notes |
|---|---|---|
| primary | 1× 80 mm, 90° | Default version |
| `80mm_75` | 1× 80 mm, 75° | Shallower fan angle |
| `80mm_60` | 1× 80 mm, 60° | Shallower fan angle |
| `80mm_45` | 1× 80 mm, 45° | Lowest-profile 80 mm angle |
| `single_slot_40` | 2× 40 mm | Single-slot alternate, S4028-15K |

## Power connectors

The V620 has two 8-pin power connectors. The shroud has a cable relief around
the connector area; check both plugs and cable bends with the shroud installed.
Do not trap or side-load the power cables.

## Printing

Print in PETG or another filament that tolerates the card's exhaust
temperature. The shroud is a thin duct; use enough walls to keep it rigid.

- 80 mm version: rotate the model 180° so the slot faces down.
- 40 mm version: no rotation; fan face down.
- No supports are modeled.

The shroud is a friction fit over the card opening. Clean the opening and check
the fit before forcing it into place.

## Build

```bash
openscad --hardwarnings -D use_dual_40=0 -D use_90deg=1 -D use_75deg=0 -o build/v620_80mm.stl v620_fan_shroud.scad
openscad --hardwarnings -D use_dual_40=0 -D use_90deg=0 -D use_75deg=1 -o build/v620_80mm_75.stl v620_fan_shroud.scad
openscad --hardwarnings -D use_dual_40=0 -D use_90deg=0 -D use_60deg=1 -o build/v620_80mm_60.stl v620_fan_shroud.scad
openscad --hardwarnings -D use_dual_40=0 -D use_90deg=0 -D use_45deg=1 -o build/v620_80mm_45.stl v620_fan_shroud.scad
openscad --hardwarnings -D use_dual_40=1 -o build/v620_single_slot_40.stl v620_fan_shroud.scad
```

## Known issues

- The V340L, MI50, and MI100 fits have not been physically tested.
- The 40 mm version requires the higher-speed S4028-15K; the S4028-6K is not
  recommended.

## License

CC BY 4.0 — WolfOne (@wolfone_17684). See the repository [LICENSE](../../LICENSE).
