$fn = 90;

/* Declarations */

// NOTICE - This is fit to my saw, tolerances might vary

radius = 30.1;
height = 3; // OAH = 3.4mm

cutOutLength = 35;
cutOutWidth = 1.8;

interfaceTabs = 8; // 6 or 8
interfaceOffsetRotation = 22.5; // 6 = 0, 8 = 22.5
interfaceTabRadius = 2;
interfaceTabHeight = 0.6; //file these for a flush fit

/* Body */

difference(){
	union(){
		cylinder(r=radius,h=height);
		for ( i = [1 : interfaceTabs]){
			rotate([0,0,360/interfaceTabs*i+interfaceOffsetRotation])
			translate([radius-interfaceTabRadius,0,-interfaceTabHeight])
			cylinder(r=interfaceTabRadius,h=height);
			}
		}
	translate([0,-height,-height/2])
	union(){
		translate([-cutOutWidth/2,0,0])
			cube([cutOutWidth,35,height*2]);
		cylinder(r=cutOutWidth/2,h=height*2);
		}
	}