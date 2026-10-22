
$fn = 100;

/* Magnetic QR Vise Inspired by a Quick Release vise design by Pask Makes */

/* Designed for a small vise using 5/8 rod, 1 inch diameter magnet, 8mm pin ( 6mm should work too ) */
/* Pin between latch and body should be loosly fitted ( a framing nail is used in the original ) */
/* Half nuts can be made by cutting a nut in half and rouding over the upper initial engagement area of the threads */

display = "full"; // [full, latch, body, accessory]

/* Parameters */

sides = 12; //width of threaded rod interface area
threadedRod = 8.08; // 5/8 threaded rod radius
  
hexNutWidth = 26.7;
hexNutLength = 32;
hexNutSupport = 5;
halfNutRadius = 34;
halfNutSetScrew = 1.5;
halfNutAngle = 30;
  
latchThickness = 2.25;
latchClearance = 0;
latchTopBore = 1.75;
latchHeight = 25;
latchRadius = threadedRod + latchThickness + latchClearance;
latchBore = latchRadius - latchThickness;
latchTopRadius = 1.5 + latchThickness;

clearance = 1;
center = hexNutLength + clearance * 2 + hexNutSupport;
depth = center + sides * 2;

halfNutHeight = hexNutLength + sides * 2 + clearance *2 + hexNutSupport;

/* Modules */

module hexagon(size, height) {
  boxWidth = size/1.75;
  hull(){
    for (r = [-60, 0, 60])
      rotate([0,0,r])
        cube([boxWidth, size, height], true);
    }
  }
  
module box(x,y,x2,y2,z){
  translate([x2,y2,z/2])
    cube([x,y,z], center=true);
  }
  
module bore(x,y,r){
  translate([x,y,0])
    cylinder(h=500, r=r,center=true);
  }

module cone(r, r2, h){
  hull(){      
    translate([0,0,0])
      cylinder(h=0.01,r=r);   
    translate([0,0,h])
      cylinder(h=0.01,r=r2);   
    }
  }

module halfNut(){
  color("orange")
  rotate([180,270+halfNutAngle,0])
  difference(){
    rotate([90,0,0])
      hexagon(hexNutWidth,hexNutLength/2);
    union(){
      rotate([90,0,0])
        bore(0,0,threadedRod-0.01);
      translate([0,0,depth/2+0.01])
        cube([depth, depth, depth], true);
      }
    }
  }

module halfCylinder(h,r){
  difference(){
    cylinder(h,r,r);
    translate ([-r,0,-h/2]) 
      cube([2*r,2*r,h*2]);
    }
  }
	
/* Accessories */

if (display == "full" || display == "accessory"){

	//Pin - (Engages lockup of mech)
	color("silver")
	translate([-33,-halfNutHeight/2,14])
	rotate([270,0,0])
	cylinder(h=halfNutHeight,r=4);
	
	translate([0,11,0])
	halfNut();
	
	translate([0,-6,0])
	halfNut();

	} 
 
/* Latch */

module latch(){
  translate([0,-depth/2,0])
  rotate([270,270+halfNutAngle,0])
  difference(){
    union(){
		
			//Inner Latch Body
      hull(){
        cylinder(h=depth, r=latchRadius);
        translate([latchHeight,0,0])
          cylinder(h=depth, r=latchTopRadius);
        }
				
			//Outer Latch Body
      hull(){
        translate([-latchThickness/2,clearance/2,0])
        rotate([0,0,180])
          halfCylinder(h=depth, r=latchRadius+latchThickness/2);
        translate([latchHeight,0,0])
        rotate([0,0,180])
          halfCylinder(h=depth, r=latchTopRadius);
        }
				
      }
    union(){
      //main bore
      bore(0,0,threadedRod);
      
			//bushing area
      cylinder(h=sides*2+0.01, r=latchBore, center=true);
      translate([0,0,depth])
        cylinder(h=sides*2+0.01, r=latchBore, center=true);
      
			//latching bore
      bore(latchHeight,0,latchTopBore);
      
			//latching clearance area for interface
      translate([latchHeight,0,sides])
        cylinder(h=center, r=latchTopRadius + clearance/2);
      
			//main clearance for halfnut assembly
      translate([0,-center/2+latchClearance+clearance/2,depth/2])
        cube([center*2,center,center],center=true);
      
			//magnet area ( Designed for a 1 inch magnet )
      rotate([0,0,-15])
      union(){
        //translate([0,latchRadius*2,depth/2])
        //rotate([90,0,0])
        //  cylinder(h=20, r=5);
        translate([0,latchRadius+clearance*1.5+5.5,depth/2])
        rotate([90,0,0])
          cylinder(h=9, r=13);
        }
      }
    }
  }

if (display == "full" || display == "latch"){
	latch();
	}
              
/* Body / Half Nut Assembly */
// I wish I had commented this when I did it...

module halfNutAssembly(){
  translate([0,-(hexNutLength+hexNutSupport)/2-sides -clearance,0])
  rotate([270,270+halfNutAngle,0])
  difference(){
    union(){
      union(){
        difference(){
					// Body
          rotate([0,0,-halfNutAngle])
          hull(){
            difference(){
              resize([latchHeight*2+latchTopRadius, halfNutRadius*2])
                cylinder(h=halfNutHeight, r=halfNutRadius);
              translate([-center*2,-center,-center/2])
                cube([center*2,center*3,center*3]);
              }
            difference(){
              cylinder(h=halfNutHeight, r=halfNutRadius);
              translate([0,-center,-center/2])
                cube([center*2,center*3,center*3]);
              }
            }
          union(){
            translate([0,0,center/2+sides+hexNutSupport/2])
              hexagon(hexNutWidth,hexNutLength+clearance);
            translate([0,center/2,0])
              cube([center*3,center,center*4],center=true);
            rotate([90,0,-60])
              bore(0,hexNutLength/4+sides+hexNutSupport,halfNutSetScrew);
            rotate([90,0,-60])
              bore(0,hexNutLength/4*3+sides+hexNutSupport,halfNutSetScrew);
            rotate([90,0,-60])
            translate([0,hexNutLength/4+sides+hexNutSupport,22])
              cylinder(h=15,r=halfNutSetScrew*2);
            rotate([90,0,-60])
            translate([0,hexNutLength/4*3+sides+hexNutSupport,22])
              cylinder(h=15,r=halfNutSetScrew*2);
            }
          }
        hull(){
          translate([latchHeight+latchTopRadius*2.5,0,sides+clearance])
            cylinder(h=hexNutLength+hexNutSupport, r=latchTopRadius);
          translate([latchHeight,0,sides+clearance])
            cylinder(h=hexNutLength+hexNutSupport, r=latchTopRadius);
          }
        }
      translate([latchHeight,0,sides+clearance])
        cylinder(h=hexNutLength+hexNutSupport, r=latchTopRadius);
      }
    translate([0,0,-0.01])
    hull(){
      cylinder(h=sides+clearance, r=latchRadius+clearance/2);
      translate([latchHeight,0,0])
        cylinder(h=sides+clearance, r=latchTopRadius+clearance/2);
      }
    translate([0,0,sides+center+0.01-clearance])
    hull(){
      cylinder(h=sides+clearance, r=latchRadius+clearance/2);
      translate([latchHeight,0,0])
        cylinder(h=sides+clearance, r=latchTopRadius+clearance/2);
      }
    bore(0,0,latchBore);
    //latching bore
    bore(latchHeight,0,latchTopBore);
    }
  }
if (display == "full" || display == "body"){
	halfNutAssembly();
	}
	