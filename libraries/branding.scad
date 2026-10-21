// byWolfOne branding mark
// Written by WolfOne
// License - CC BY 4.0
//
// Consolas ships with Windows and is not redistributed here.
// OpenSCAD has no font-stack fallback: override with
//   openscad -D brandFont='"DejaVu Sans Mono:style=Bold"' ...
// or edit brandFont below. See libraries/README.md.

brandFont = "Consolas:style=Bold";

module byWolfOne(height = 2) {
    linear_extrude(height = height) {
        text("b", font = brandFont, size = 6);

        translate([4.9, 0, 0])
            text("y", font = brandFont, size = 6);

        translate([6.5, -13, 0])
            text("Wo", font = brandFont, size = 8);

        translate([18.3, -13, 0])
            text("l", font = brandFont, size = 8);

        translate([23.3, -13, 0])
            text("f", font = brandFont, size = 8);

        translate([30.1, -13, 0])
            text("O e", font = brandFont, size = 8);

        translate([36.5, -13, 0])
            text("n", font = brandFont, size = 8);
    }
}
