
$fn = 100;

//Designed for 3/4 inch hole

diameter = 19;
clearance = 0.1;
slot = 3;
slot_height = 15;
rounding = 0.7;
notchCorner = 2;     // round the notch's vertical corners
slotCorner = 1.1;    // round the screw-slot corners
baseFillet = 1.1;    // collar radius at the bottom of each stem

//Spaghetti

radius = diameter / 2;
r = radius;
c = clearance;

//Base fillet: add a collar, then relieve it with a torus
module stem_base_fillet(stem_radius, fillet)
{
	if (fillet > 0)
	{
		eps = 0.02;
		outer = stem_radius + fillet + eps;
		difference()
		{
			translate([0,0,fillet])
				cylinder(h=fillet+eps, r=outer);
			translate([0,0,fillet+eps*2])
				rotate_extrude($fn=64)
					translate([outer+eps,0,0])
						circle(r=fillet+eps, $fn=32);
		}
	}
}

//Body
module bench_body(height, pin, fillet = 1){
	union(){
		cylinder(h=height, r=radius);
		minkowski(){
			cylinder(h=pin, r=radius);
			sphere(c*4);
			}
    cylinder(rounding);
		
		if (fillet == 1)
		translate([0,0,height-3 + .8])
			stem_base_fillet(radius, baseFillet);
		}
	}

// Rounded cutter / transition helper
module rounded_cube(size, corner)
{
	hull()
	{
		for (x = [ -size[0] / 2 + corner, size[0] / 2 - corner ])
			for (y = [ -size[1] / 2 + corner, size[1] / 2 - corner ])
				for (z = [ -size[2] / 2 + corner, size[2] / 2 - corner ])
					translate([ x, y, z ])
						sphere(r = corner, $fn = 24);
	}
}

//Bench A
module bench_A (height, notch_height, notch_size, pin, fillet = 1){
    difference(){
      minkowski(){
        difference(){
				
					//Body
					bench_body(height, pin, fillet);
						
          //Notch — rounded vertical corners instead of a sharp cube
          translate([notch_size + diameter, 0, height])
            rounded_cube([diameter*2, diameter*2, notch_height*2], notchCorner);
						
          }
        }
      union(){
			
        //Pin
        translate([0,0,slot_height+slot])
          cylinder(h=height+radius, r=pin+c/2);
					
        //Slot — rounded cutter
        translate([0,0,-1+slot_height/2])
          rounded_cube([radius*3, slot, slot_height+2], slotCorner);
					
        }
      }
  }

//Bench B
module bench_B (z, xy, top_z, offset, pin, notch){
  xy = xy;
  o = offset;
  n = notch;
  difference(){
    union(){
		
			//Body
			bench_body(z, pin);
				
      //Head
      translate([-xy/2-(xy/2-radius),-xy/2,z])
        minkowski(){
          hull(){
            translate([offset,offset/2,top_z-0.01])
              cube([xy-offset,xy-offset,.01]);
            cube([xy,xy,.01]);
            }
          cylinder(rounding);
          }
					
      }
    union(){
		
      //Puller
      translate([0,0,slot_height+slot])
        cylinder(h=z+radius, r=pin+c/2);
				
			//Slot — rounded cutter
      translate([0,0,-1+slot_height/2])
        rounded_cube([radius*3, slot, slot_height+2], slotCorner);
				
      }
    }
  }

/* A */
translate([0,diameter*2,0])
bench_A(45, 15, 5, 3, 0);
/**/
  
/* B - Small 1/4 inch */
translate([0,-diameter*2,0])
bench_B(30, 23, 6, 4, 2, 2);
/**/

/* B - Medium 1/2 inch */
translate([-diameter*2,0,0])
bench_B(30, 26, 10, 5.5, 2, 2);
/**/

/* B - Large 3/4 inch */
translate([diameter*2,0,0])
bench_B(35, 30, 15, 7, 3, 2);
/**/
