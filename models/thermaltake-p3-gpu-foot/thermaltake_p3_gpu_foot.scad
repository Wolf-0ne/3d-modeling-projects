


difference(){
	union(){
		hull(){
			cube([14,21,25], center=true);
			cube([15,20,25], center=true);
			cube([14,20,26], center=true);
		}
		translate([8,0,1])
		hull(){
			cube([5,21,4], center=true);
			cube([6,20,3], center=true);
			translate([-3.5,0,10])
			hull(){
				cube([6,20,3], center=true);
				translate([-0.5,0,0])
					cube([6,21,3], center=true);
			}
		}
		translate([10,0,-0.5])
		hull(){
			cube([2,20,3], center=true);
			cube([1,21,4], center=true);
		}
	}
	union(){
	}
}