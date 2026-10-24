
$fn = 90;

module hexagon(size, height) {
  boxWidth = size/1.75;
  for (r = [-60, 0, 60])
    rotate([0,0,r])
      cube([boxWidth, size, height], true);
  }

module nema17(r){
  translate([-15.5, -15.5, 0])
  union(){
    translate([31,31,0])
      cylinder(h=25, r=r);
    translate([31,0,0])
      cylinder(h=25, r=r);
    translate([0,31,0])
      cylinder(h=25, r=r);
    translate([0,0,0])
      cylinder(h=25, r=r);
    }
  }
  
module box(x,y,x2,y2,z){
  translate([x2,y2,z/2])
    cube([x,y,z], center=true);
  }
  
module bore(x,y,r){
  translate([x,y,-10])
    cylinder(h=100, r=r);
  }
  
module cone(r, r2, h){
  hull(){      
    translate([0,0,0])
      cylinder(h=0.01,r=r);   
    translate([0,0,h])
      cylinder(h=0.01,r=r2);   
    }
  }

module tooth(spacing, height, radius){
  hull(){
    cylinder(h=height, r=radius);
    translate([-spacing/3, -radius, 0])
      cube([spacing/3*2, 0.01, height]);
    }
  }
  
module teeth(count, spacing, height, radius, plane){
  for ( i = [0 : count-1]){
    rotate(plane)
    translate([spacing * i, radius, 0])
      tooth(spacing, height, radius);
    }
  }
  
/**/

height = 9;
width = 30;
depth = 24;
beltWidth = 15;
beltClearance = 1;
slot = beltWidth + beltClearance; // 16 mm slot for a 15 mm belt
teeth = depth/2-1;
spacing = 2;
chamfer = 4;
bore = 2.6;
lidHeight = 5;
    
/**/

union(){
  translate([(width-slot)/2, depth-spacing*teeth, height-spacing/2])
    teeth(teeth, spacing, slot, 0.5, [270,180,270]);
  difference(){
    union(){
      hull(){
          translate([chamfer, 0, 0])
            cube([width-chamfer*2,depth,height]);  
          translate([0, chamfer, 0])
            cube([width,depth-chamfer*2,height]);  
        }
      }
    union(){
      translate([(width-slot)/2,-depth/2,height-spacing/2])
        cube([slot,depth*2,spacing*2]);
      bore((width)/2-slot+spacing,depth/2,bore);
      bore((width)/2+slot-spacing,depth/2,bore);
      translate([(width)/2-slot+spacing,depth/2,0])
        hexagon(7.8, 4);
      translate([(width)/2+slot-spacing,depth/2,0])
        hexagon(7.8, 4);
      }
    }
  }
    