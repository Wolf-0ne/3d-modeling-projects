$fn = 75;

module cutout(){
	hull(){
		r = 3.8;
		translate([0,-5.8,0])
			cylinder(50,r=r);
		cylinder(50,r=r);
		}
	}
	
module screwHoles(){
	offset = 2.3;
	difference(){
		union(){			
			translate([offset,0.4,0])
				cylinder(h=10, r=1.30, center=true);
			hull(){
				translate([0,2,0])
					cylinder(h=10, r=2, center=true);
				translate([0,-2,0])
					cylinder(h=10, r=2, center=true);
				}
			translate([offset+1.05,-3,0])
				cube([0.5,7,10], center=true);
			}
		union(){
			hull(){
				translate([offset+.075-0.15,0.3,0])
					cylinder(h=10, r=.85, center=true);
				translate([offset+.5,-1,0])
					cube([0.585,1,10], center=true);
				}
			}
		}
	}
	
	
difference(){
	union(){
		
		hull(){
			translate([0,-2.5,11])
				cube([55,7,10], center=true);
			translate([0,0,10])
				cube([50,8,8], center=true);
			translate([0,-3,1])
				cube([55,6,2], center=true);
			}
		translate([0,-3,5])
			cube([55,6,10], center=true);
		hull(){
			translate([0,-4,1])
				cube([55,6,2], center=true);
			translate([0,-16,1])
				cube([35,20,2], center=true);
			}
			
		}
	union(){
	
		translate([14,-17,0])
		rotate([180,0,180])
			screwHoles();
			
		translate([-14,-17,0])
			screwHoles();
	
		translate([0,-1,-5])
		union(){
			translate([20,0,0])
				cutout();
			translate([0,0,0])
				cutout();
			translate([-20,0,0])
				cutout();
			}
		
		
		}
	}
	
	
	