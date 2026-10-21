// Shared OpenSCAD library for 3d-modeling-projects
// Written by WolfOne
// License - CC BY 4.0

// Include once from a model:
//   include <../../libraries/std.scad>
//
// Consumer contract: a model may define these globals before the include:
//   wallThickness, boltX, boltY, outerThickness
// The modules below fall back to them so existing model files keep working.
// New code should pass explicit parameters instead.

include <grid.scad>
include <hardware.scad>
include <plate.scad>
include <branding.scad>
