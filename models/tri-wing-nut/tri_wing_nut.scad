
$fn = 100;

height = 8;
diameter = 10.5;
wingsize = 16.5;

// 1/4 inch hardware, press fit
hexHeight = 5;
hexWidth = 11.1125;
// Bore radius; 3.5 gives a 7.0 mm hole for a 1/4 in bolt.
throughHoleRadius = 3.5;


radius = diameter / 2;

module hexagon(size, height){
  boxWidth = size/1.75;
  for (r = [-60, 0, 60]){
		rotate([0,0,r]) 
			cube([boxWidth, size, height*2], true);
		}
	}

difference(){
  hull(){
		//Wings
    for(i=[0:2]){
      rotate([0,0,120*i])
      hull(){
        cylinder(r=radius*2, h=height);
        translate([0,wingsize,0])
          cylinder(r=radius, h=height);
        }
      }
		//Core
    translate([0,0,-height/2-2])
      cylinder(r=radius*1.5, h=height);
    }
  union(){
    //Bore
		translate([0,0,-height/2])
      cylinder(r=throughHoleRadius, h=height*3);
    
		//Nut
		translate([0,0,-4])
      hexagon(hexWidth, hexHeight);
    
		//Cutouts
		union(){
      for(i=[0:2]){
				rotate([0,0,120*i])
				translate([0,-wingsize*2.09,-height/2])
					cylinder(r=wingsize*1.505, h=height*2);
        }
      }
    }
  }
  
  