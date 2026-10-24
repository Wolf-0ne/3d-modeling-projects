
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

/**/

height = 16;
width = 60;
depth = 25;
beltWidth = 15;
beltClearance = 1;
slot = beltWidth + beltClearance; // 16 mm slot for a 15 mm belt
teeth = depth/2-1;
spacing = 2;
chamfer = 4;
bore = 4.1;
lidHeight = 5;
coreX = 22;
coreY = 14;
offset = 0.3;
    
/**/

union(){
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
      translate([width/2,depth/2,height/2])
        cube([coreX,coreY,height*2], center = true);
      translate([width/2,depth/2,height+height/2])
        cube([coreX,depth*2,height*2], center = true);
      bore((width-coreX)/4,depth/2,bore/2);
      bore(width-(width-coreX)/4,depth/2,bore/2);
      translate([width-(width-coreX)/4,depth/2,3])
        cone(bore, bore+bore/2, height-3);
      translate([(width-coreX)/4,depth/2,3])
        cone(bore, bore+bore/2, height-3);
      }
    }
  }
  
/**/
  
translate([0, 0, height+2])
union(){
  difference(){
    union(){
      hull(){
          translate([chamfer, 0, 0])
            cube([width-chamfer*2,depth,height*1/2]);  
          translate([0, chamfer, 0])
            cube([width,depth-chamfer*2,height*3/4]);  
        }
      translate([width/2,depth/2,0])
      hull(){
          cube([coreX-2,depth,height-chamfer*2], center = true);
          cube([coreX-2-chamfer*2,depth,height], center = true);
        }
      }
    union(){
      translate([width/2,depth/2,height/2])
        cube([coreX,coreY,height*4], center = true);
      bore((width-coreX)/4,depth/2,bore);
      bore(width-(width-coreX)/4,depth/2,bore);
      translate([(width-coreX)/4,depth/2,0])
        hexagon(12.85,9);
      translate([width-(width-coreX)/4,depth/2,0])
        hexagon(12.85,9);
      translate([width/2,20,2])
        rotate([90,270,0])
          bore(0,0,2.55);
      }
    }
  }
    
/**/
    