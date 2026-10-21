// Hex-cut panel
// Written by WolfOne
// License - CC BY 4.0

// A panel of thickness t with a rounded border and a hex-grid cutout.
// position: 0 for a top-side taper, 1 for a bottom-side taper.
// wt: wall thickness; falls back to the model's wallThickness global.
module plate(x, y, t, border, sw, wall, position = 0, funkytown = 0, wt = undef) {
    ot = t / 4 * (position == 0 ? 1 : -1);
    _wt = is_undef(wt) ? wallThickness : wt;
    b = border;

    difference() {
        hull() {
            // inner x
            translate([0, 0, ot])
                cube([x + _wt * 2, y, t / 2], center = true);
            // inner y
            translate([0, 0, ot])
                cube([x, y + _wt * 2, t / 2], center = true);
            // outer x
            translate([0, 0, 0])
                cube([x, y + _wt, t], center = true);
            // outer y
            translate([0, 0, 0])
                cube([x + _wt, y, t], center = true);
        }

        // cutout
        intersection() {
            if (border > 0) {
                cube(size = [x - b * 2, y - b * 2, t * 1.1], center = true);
                grid(
                    size = [x - border, y - border, t],
                    cell_hole = sw,
                    cell_wall = wall,
                    y_offset = funkytown
                );
            }
        }
    }
}
