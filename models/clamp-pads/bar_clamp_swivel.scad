
$fn = 100;

// Bar clamp defaults. Resize these six values for other bars or brands.
// The swivel shape also works for C-clamps; adjust the same dimensions.
//
// Reference sizes:
//   4 in C-clamp:  wallThickness=2, diameter=16, footHeight=2.5,
//                  footThickness=2, slotWidth=2, bootAngle=45
//   10 in C-clamp: wallThickness=2.5, diameter=30.5, footHeight=4,
//                  footThickness=2.5, slotWidth=5.5, bootAngle=45
wallThickness = 2;
diameter = 22.5;
footHeight = 3.5;
footThickness = 2.5;
slotWidth = 4.5;
bootAngle = 55;

//Math
totalHeight = footThickness + footHeight * 2;
radius = (diameter + (wallThickness*2))/2;
innerRadius = radius-wallThickness;

difference(){
  union(){
    cylinder(r=radius, h=footHeight+footThickness);
    translate([0,0,footHeight+footThickness])
      cylinder(h=tan(bootAngle)*radius,r1=radius,r2=0);
    }
  union(){
    translate([0,0,footThickness+.1])
      cylinder(r=innerRadius, h=footHeight);
    translate([0,0,footThickness + footHeight])
      cylinder(h=tan(bootAngle)*innerRadius,r1=innerRadius,r2=0);
    translate([-(radius),-(radius),totalHeight])
      cube([radius*2,radius*2,radius]);
    translate([-(radius),-(slotWidth/2),footHeight+footThickness])
      cube([radius*2,slotWidth,radius*2]);
    }
  }