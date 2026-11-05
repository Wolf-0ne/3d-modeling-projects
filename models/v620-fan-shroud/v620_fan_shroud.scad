// v620 Multi-Fan Shroud
// By WolfOne_
//
// Print: 80mm rotates 180° (slot down). 40mm no rotation (fan face down).
// Card: use_v340l selects V340L slot sizing (V620 by default).

use_dual_40  		 = 0;   // 0=single 80mm, 1=dual 40mm (locks 90°, ignores others)
use_45deg    		 = 0;   // 0=off, 1=45° fan angle (80mm only)
use_60deg    		 = 0;   // 0=off, 1=60° fan angle (80mm only)
use_75deg    		 = 0;   // 0=off, 1=75° fan angle (80mm only)
use_90deg    		 = 1;   // 0=off, 1=90° fan angle (80mm only)
use_flip     		 = 0;   // 0=normal, 1=mirrored (80mm only)
use_cable_shroud = 1;   // 0=off, 1=shroud over cable opening
use_v340l        = 0;   // 0=V620 (tested), 1=V340L slot sizing

wallThickness = 1.8;

// Card slot (GPU fit)
// V620: as built, card-tested. V340L: the cavity grips the cooler shroud
// while the wider PCB edge passes through a relief band in the cavity wall
// (see Card opening).
v340l_cavityWidth  = 97;  // cavity width (cooler shroud grip)
v340l_cavityHeight = 39.3;  // cavity height (backplate face to slot top)
v340l_pcbWidth     = 98.8;  // PCB relief band width
v340l_pcbStart     = 2.6;   // PCB underside above backplate face
v340l_pcbThk       = 1.7;   // PCB thickness
v340l_pcbRelief    = 1.2;   // extra relief height around the PCB band (total)
v340l_ductTop      = 0.4;   // duct mouth: capture at the top edge
v340l_ductBottom   = 2.5;   // duct mouth: cut at the bottom edge

innerWidth  = use_v340l ? v340l_cavityWidth : 99.3;   // V620: measured 99.5, modeled 99.3
innerDepth  = 18;
innerHeight = use_v340l ? v340l_cavityHeight : 38.4;  // V620 cavity height

// Airflow duct (flow path only)
innerDuctWidth  = innerWidth - (use_v340l ? 1 : 5);   // V620: 94.3 (-5mm total / -2.5mm per side), V340L much thinner shroud
innerDuctHeight = innerHeight - 0.4   // V620: 38
    - (use_v340l ? v340l_ductBottom - v340l_ductTop : 0);  // V340L: mouth shortened at the bottom
ductLiftZ       = use_v340l ? (v340l_ductBottom + v340l_ductTop) / 2 : 0;  // duct mouth center lift

// Derived from flags
fan_size  = use_dual_40 ? 40 : 80;
fan_angle = use_dual_40 ? 90 : (use_90deg ? 90 : (use_75deg ? 75 : (use_60deg ? 60 : 45)));
use_steep = use_75deg || use_90deg;  // ramp adjustments for steep angles
flip      = use_dual_40 ? 0  : use_flip;

fanWidth = 79.7;

// Fan depth: 80mm=8, 40mm=20
fanHeight = use_dual_40 ? 14 : 8;

// Fan offset per angle.
fanOffSet = use_dual_40
    ? [0, -64, 0]
    : (use_90deg
        ? [0, -65,   8 * (flip == 0 ? 1 : -1)]   // 90°
        : (use_75deg
            ? [0, -65,   8 * (flip == 0 ? 1 : -1)]   // 75°
            : (use_60deg
                ? [0, -63,  12 * (flip == 0 ? 1 : -1)]   // 60°
                : [0,  -63,  10 * (flip == 0 ? 1 : -1)]))); // 45°

// Fan opening Y: 80mm=square, 40mm=half
fan_opening_y = use_dual_40 ? fanWidth / 2 : fanWidth;


wt_outer = wallThickness * 2.5;    // shell margin (width, height)
wt_depth = wallThickness * 2;      // shell margin (depth)
wt_gap   = wallThickness * 1.5;    // clearance gap (fan inner, ramp)

outerWidth  = innerWidth  + wt_outer;
outerDepth  = innerDepth  + wt_depth;
outerHeight = innerHeight + wt_outer;

fanOuterWidth = fanWidth + wt_depth;
fanInnerWidth = fanWidth - wt_gap;
fanInnerOffset = -2;

pcie_8pin_x  = 20.5;                  // X offset from centerline
pcie_8pin_d  = [38.66, 11.5, 14];     // [width, depth, height]
pcie_8pin_db = [38.66, 1, 1];         // far-end stub

lowerRedirect  = [innerWidth, wallThickness, 14];
lowerRedirectB = use_dual_40
    ? [innerWidth - 3, 1, 1]
    : (use_steep
        ? [innerWidth - 3, 1, 1]   // 75°/90°: narrower
        : [innerWidth, 1, 1]);

print_rotation = use_dual_40 ? [90, 0, 0] : [-90, 0, 0];

function rotate_x(p, a) = [
    p.x,
    p.y * cos(a) - p.z * sin(a),
    p.y * sin(a) + p.z * cos(a)
];

fan_center_world = rotate_x(fanOffSet, fan_angle);

ramp_fraction   = use_dual_40 ? 0.035 : 0.28;
cutout_fraction = 0.35;

ramp_start_z   = -14;
ramp_start_y   = -innerDepth/2 - wt_gap - 0.12;
cutout_start_z = use_dual_40 ? -innerDepth/2 + 2 : -innerDepth/2 - 10;

ramp_end_z   = ramp_start_z   + (fan_center_world.z - ramp_start_z)   * ramp_fraction   - (use_steep ? 2 : 0);
cutout_end_z = cutout_start_z + (fan_center_world.z - cutout_start_z) * cutout_fraction - (use_steep ? 2 : 0);

card_chamfer_y = innerDepth/2 + wallThickness/2 + 0.75;
ramp_cutout_z  = -innerDepth/2 - 5;
flow_throat_z  = -wallThickness / 8 * 3;
fan_chamfer_z  = fanHeight/2 - wallThickness;

ramp_end_y = use_dual_40 ? -innerDepth - 34 : -innerDepth - 35;

duct_z_shift = -0.5;

rotate(print_rotation)
translate([0, 0, duct_z_shift])
difference(){
    union(){

        // Flow ramp (flip=0 only)
        if (flip == 0 && use_dual_40 == 0){
						hull(){
								translate([0, ramp_start_y, ramp_start_z])
										cube(lowerRedirect + [-2, 0, 0], center = true);
								translate([0, ramp_end_y, ramp_end_z])
										cube(lowerRedirectB - [8, 0, 0], center = true);
						}
        }
        difference(){

					// Shell
					union(){
							hull(){
									cube([outerWidth, outerDepth, outerHeight], center = true);

									translate(fanOffSet)
									rotate([fan_angle, 0, 0])
									translate([0, 0, -wallThickness])
											cube([fanOuterWidth, use_dual_40 ? fanOuterWidth/2 + wallThickness : fanOuterWidth, fanHeight + wallThickness], center = true);
							}
					}

					// Cutouts
					union(){

						// Card opening
						cube([innerWidth, outerDepth * 1.01, innerHeight], center = true);

						// V340L PCB relief: local slot in the cavity wall across the PCB
						// band, so the wider PCB edge passes while the cooler shroud stays
						// clamped. Backplate side = -Z (same as the 8-pin cutout).
						if (use_v340l){
							translate([0, 0, -innerHeight/2 + v340l_pcbStart + v340l_pcbThk/2])
								cube([v340l_pcbWidth, outerDepth * 1.01, v340l_pcbThk + v340l_pcbRelief], center = true);
						}

						// Fan opening
						translate(fanOffSet)
						rotate([fan_angle, 0, 0])
								cube([fanWidth, fan_opening_y, fanHeight * 1.01], center = true);

						// Flow path
						if (use_dual_40 == 1){
							hull(){
								translate([0, -innerDepth/2 - wallThickness, flow_throat_z+6+ductLiftZ])
									cube([innerDuctWidth - wallThickness/2, wallThickness/4, innerDuctHeight - 12 + wallThickness/4] - [wallThickness, 0, wallThickness], center = true);
								translate(fanOffSet)
								rotate([fan_angle, 0, 0])
								translate([0, 0, -fanHeight/2])
								hull(){
									translate([-20, 0, 0])
										cylinder(h=1, r=19, center=true);
									translate([15, 0, 0])
										cylinder(h=1, r=5, center=true);
								}
							}
							hull(){
								translate([0, -innerDepth/2 - wallThickness, flow_throat_z+6+ductLiftZ])
									cube([innerDuctWidth - wallThickness/2, wallThickness/4, innerDuctHeight - 12 + wallThickness/4] - [wallThickness, 0, wallThickness], center = true);
								translate(fanOffSet)
								rotate([fan_angle, 0, 0])
								translate([0, 0, -fanHeight/2])
								hull(){
									translate([-15, 0, 0])
										cylinder(h=1, r=5, center=true);
									translate([20, 0, 0])
										cylinder(h=1, r=19, center=true);
								}
							}
						}
						else {
							hull(){
								if (flip == 0){
									translate([0, -innerDepth/2 - wallThickness, flow_throat_z+ductLiftZ])
										cube([innerDuctWidth - wallThickness/2, wallThickness/4, innerDuctHeight + wallThickness/4] - [wallThickness, 0, wallThickness], center = true);
								}
								else {
									translate([0, -innerDepth/2 - wallThickness*2, 5.5+ductLiftZ])
									cube([innerDuctWidth - wallThickness/2, wallThickness/4, innerDuctHeight + wallThickness/4] - [wallThickness, 0, 13], center = true);
								}

								translate(fanOffSet)
								rotate([fan_angle, 0, 0])
								translate([0, 0, -fanHeight/2])
									cube([fanInnerWidth, use_dual_40 ? fanInnerWidth/2 - 1 : fanInnerWidth, 1], center = true);
									

							}
							if (flip == 1){
								translate([0, -innerDepth/2 - wallThickness, 5.5+ductLiftZ])
									cube([innerDuctWidth - wallThickness/2, wallThickness*2, innerDuctHeight + wallThickness/4] - [wallThickness, 0, 13], center = true);
							}
						}
					}
				
        }
				
				// Cable Shroud		
				translate([0, (use_v340l == 1 ? -1 : 0), (use_v340l == 1 ? 1.5 : 0)])
				hull(){
						translate([pcie_8pin_x, -innerDepth - 11, -innerDepth/2 - 8.3])
								cube(pcie_8pin_db + [-9+wallThickness*2, 0, 0], center = true);
						translate([pcie_8pin_x, -innerDepth + 2, -innerDepth/2 + 1.05])
								cube(pcie_8pin_db + [wallThickness*2, 8, -1+wallThickness], center = true);
						translate([pcie_8pin_x, -innerDepth -2, -innerDepth/2 - 8])
								cube(pcie_8pin_db + [wallThickness*2, 10, 0], center = true);
				}
    }
    union(){

        // 45° ramp cutout
        cubert = (use_v340l == 1 ? 9.2 : 7.3);
        translate([0, -innerDepth/2 - wallThickness - 0.1, (use_v340l == 1 ? ramp_cutout_z + .8 : ramp_cutout_z)])
        rotate([45,0,0])
            cube([innerWidth, cubert, cubert], center = true);

        // Card chamfer
        translate([0, card_chamfer_y, 0])
        hull(){
                cube([innerWidth, 1, innerHeight], center = true);
                translate([0, wallThickness/2, 0])
                cube([innerWidth, 1, innerHeight] + [wallThickness, 0, wallThickness], center = true);
        }

        // 8-pin slot
        if (flip == 0){
            hull(){
                translate([pcie_8pin_x, -innerDepth + 1, -innerDepth/2 - 12])
                    cube(pcie_8pin_d + [0, -10, 5.01], center = true);
                translate([pcie_8pin_x, -innerDepth - 35, cutout_end_z])
                    cube(pcie_8pin_db + [0, 4, 4], center = true);
            }
            translate([0, 0, 2])
            hull(){
                translate([pcie_8pin_x, -innerDepth + 1.5, -innerDepth/2 - 5])
                    cube(pcie_8pin_d + [0, -11, -10.01], center = true);
                translate([pcie_8pin_x, -innerDepth + 4, -innerDepth/2 - 0.5])
                    cube(pcie_8pin_d + [0, -3, (use_v340l == 1 ? -8.01 : -12.01)], center = true);
								translate([pcie_8pin_x, -innerDepth + 4.5, -innerDepth/2 - 5])
                    cube(pcie_8pin_d + [-9, -2, -4.01], center = true);
								translate([pcie_8pin_x, -innerDepth-3 - (use_v340l == 1 ? 4 : 0), -innerDepth/2 - 10 - (use_v340l == 1 ? 2 : 0)])
                    cube(pcie_8pin_d + [-9, 4, -12.01], center = true);
            }
            translate([0, -6, 0])
            hull(){
                translate([pcie_8pin_x, -innerDepth + 5, -innerDepth/2 - 12])
                    cube(pcie_8pin_d + [0, -6, 0], center = true);
                translate([pcie_8pin_x, 0, -innerDepth])
                    cube([10,12,innerDepth], center = true);
            }
            translate([pcie_8pin_x, 0, -innerDepth])
                cube([10,25,innerDepth], center = true);
        }
        else {
            // flip=1 cutout
            hull(){
                translate([pcie_8pin_x, -innerDepth + 0, -innerDepth/2])
                        cube(pcie_8pin_d + [-4, 8, 0], center = true);
                translate([pcie_8pin_x, 5, -innerDepth])
                    cube([10,20,innerDepth-2], center = true);
            }
        }

        // Fan chamfer
        translate(fanOffSet)
        rotate([fan_angle, 0, 0])
        translate([0, 0, fan_chamfer_z])
            hull(){
                cube([fanWidth, fan_opening_y, 1], center = true);
                translate([0, 0, wallThickness])
                cube([fanWidth + wallThickness, use_dual_40 ? fanWidth/2 + wallThickness : fanWidth + wallThickness, 1], center = true);
            }
    }
}
