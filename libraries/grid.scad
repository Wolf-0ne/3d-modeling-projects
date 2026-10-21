// Hex-grid helpers
// Written by WolfOne
// License - CC BY 4.0
//
// Native OpenSCAD: no BOSL2 dependency.
// Defaults follow the gen-1 resources.scad for compatibility; verify each
// migrated model against its published STL before relying on them.

// Two offset hex cells. Private helper for grid().
module cells(d, h, dx, dy, ix, iy) {
    translate([dx * ix, dy * iy, 0])
        cylinder(h = h, d = d, $fn = 6);
    translate([dx * ix + abs(dx) / 2, abs(dy) / 2 + dy * iy, 0])
        cylinder(h = h, d = d, $fn = 6);
}

// Hex cells laid out over a size box. Rotate with rotate_hex = 1.
module grid(size, cell_hole, cell_wall, rotate_hex = 0, x_offset = 0, y_offset = 0) {
    // NB: this spacing was fudged in the original to match the legacy grid.
    across_flats = cell_hole * (2 / sqrt(3));
    dy = across_flats + cell_wall / 2;
    dx = dy * sqrt(3);

    x = rotate_hex == 0 ? 0 : 1;
    y = rotate_hex == 0 ? 1 : 0;
    z = size[2] * 1.1;
    r = rotate_hex == 0 ? 0 : 90;

    xcount = (size[x] / dx) / 2 * 1.2;
    ycount = (size[y] / dy) / 2 * 1.2;

    translate([x_offset, y_offset + dy / 2, -z / 2])
        rotate([0, 0, r])
            for (ix = [0 : xcount]) {
                for (iy = [0 : ycount]) {
                    cells(across_flats, z, dx, dy, ix, iy);
                    cells(across_flats, z, -dx, dy, ix + 1, iy);
                    cells(across_flats, z, dx, -dy, ix, iy + 1);
                    cells(across_flats, z, -dx, -dy, ix + 1, iy + 1);
                }
            }
}

// Solid box with a hex grid cut through the interior, leaving a border.
module create_grid(
    size,
    cell_hole,
    cell_wall,
    outer_wall_modifier = 2,
    rotate_hex = 0,
    y_offset = 0,
    y_offset_border = 0,
    x_offset = 0
) {
    outer_wall = outer_wall_modifier * cell_wall;
    difference() {
        cube(size = size, center = true);
        translate([0, y_offset_border, 0])
            intersection() {
                cube(
                    size = [size[0] - outer_wall, size[1] - outer_wall, size[2] * 1.1],
                    center = true
                );
                grid(size, cell_hole, cell_wall, rotate_hex, x_offset, y_offset);
            }
    }
}

// Fill the cells of a hex plate with solid hexagons.
// gen-1 defaults: flip = 0, centered = false. The newer Rock Pi code used
// equivalent stagger with the fill shifted to -h/2; pass centered = true
// only when that is intended.
module fillhex(n, x, y, h, diameter, flip = 0, centered = false) {
    modifier = flip < 1 ? 1 : -1;
    xn = diameter * sqrt(3) / 2;
    zoff = centered ? -h / 2 : 0;
    for (i = [0 : n]) {
        yn = i % 2 == 0 ? 0 : diameter / 2 * modifier;
        translate([x + xn * i, y + (y > 0 ? -yn : yn), zoff])
            cylinder(h = h, r = diameter / 2, $fn = 6);
    }
}
