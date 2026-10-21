// Hardware and cutout helpers
// Written by WolfOne
// License - CC BY 4.0

// Rounded bar / pin between two points. direction is "x" or "y".
module bar(h, r, direction, gap) {
    g = gap / 2;
    x = direction == "x" ? 1 : 0;
    y = direction == "y" ? 1 : 0;
    hull() {
        translate([-g * x, -g * y, 0])
            cylinder(h = h, r = r);
        translate([g * x, g * y, 0])
            cylinder(h = h, r = r);
    }
}

// Single bore. r2 != 0 makes a tapered bore. z defaults to -h/2.
module bore(x, y, r, h = 500, r2 = 0, z) {
    zh = (z == undef ? -h / 2 : z);
    translate([x, y, zh])
        union() {
            if (r2 == 0)
                cylinder(h = h, r = r);
            if (r2 != 0)
                hull() {
                    cylinder(h = 0.1, r = r);
                    cylinder(h = h, r = r2);
                }
        }
}

// Four bores on a rectangle. x and y are the full spacings.
module bore4(x, y, r, h = 500, r2 = 0, z) {
    translate([-x / 2, -y / 2, 0])
        union() {
            bore(0, 0, r, h, r2, z);
            bore(x, 0, r, h, r2, z);
            bore(0, y, r, h, r2, z);
            bore(x, y, r, h, r2, z);
        }
}

// Four bolt holes. Falls back to the model's boltX / boltY globals.
// Explicit x / y are the full spacings (same units as bore4).
module boltHoles(h = 50, r = 3.1, r2 = 0, z = 0, x = undef, y = undef) {
    _x = is_undef(x) ? boltX * 2 : x;
    _y = is_undef(y) ? boltY * 2 : y;
    bore4(_x, _y, r, h, r2, z);
}

// Tapered post used for board standoffs. Falls back to outerThickness.
module pin(h, r, ot = outerThickness) {
    hull() {
        cylinder(h = ot + h, r = r);
        cylinder(h = ot, r = r + 1);
    }
}
