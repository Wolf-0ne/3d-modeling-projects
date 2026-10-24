
$fn = 90;

module hexagon(size, height) {
  boxWidth = size/1.75;
  for (r = [-60, 0, 60])
    rotate([0,0,r])
      cube([boxWidth, size, height], true);
  }
  
module hex3(spacing, size, height) {
  for (r = [-120, 0, 120])
    rotate([0,0,r])
      translate([0,spacing/2,0])
        hexagon(size,height);
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
  translate([x,y,0])
    cylinder(h=500, r=r,center=true);
  }
  
module bore3(spacing, radius) {
  for (r = [-120, 0, 120])
    rotate([0,0,r])
      bore(0,spacing/2,radius);
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

plywood = 21;
height = 30;
width = 75;
offset = 13.33;
nema = 50;
depth = plywood+offset+nema/2;
thickness = 15;
sideThickness = 5;
leadscrew = 8; // T8 lead screw diameter
bearing = 22.15;
m3 = 1.55;
screwHole = 2.1;
mountZ = 20;
    
/*/

union(){
  difference(){
    union(){
      hull(){
        cube([width,plywood+sideThickness,thickness]);
        translate([(width-nema)/2,0,0])
        cube([nema,depth,thickness]);
        }
      hull(){
        translate([0,plywood,0])
        cube([width,sideThickness,thickness]);
        translate([(width-nema)/2,plywood,0])
        cube([nema,depth-plywood,thickness]);
        translate([0,plywood,-height])
          cube([width,sideThickness,height]);
        }
      }
    union(){
      translate([width/2,plywood+offset,thickness/2-2])
      union(){
        bore(0,0,4.25);
        translate([0,0,-2])
        cylinder(h=thickness, r=leadscrew/2);
        cylinder(h=thickness, r=bearing/2);
        bore3(bearing, m3);
        translate([0,0,-250-thickness/2])
          bore3(bearing, m3*2);
        translate([0,0,thickness/4])
          hex3(bearing, 5.75, thickness);
        
        translate([-27.5,5,0])
          bore(0,0,screwHole);
        translate([+27.5,5,0])
          bore(0,0,screwHole);
        translate([0,-27.5,0])
          bore(0,0,screwHole);
        
        translate([-27.5,5,-thickness/2])
          hexagon(7.1,thickness);
        translate([+27.5,5,-thickness/2])
          hexagon(7.1,thickness);
        translate([-27.5,5,-thickness-6])
          hexagon(7.1,thickness);
        translate([+27.5,5,-thickness-6])
          hexagon(7.1,thickness);
        translate([0,-27.5,-thickness/2])
          hexagon(7.1,thickness);
        
        }
      rotate([270,0,0])
      union(){
        bore(thickness,mountZ,screwHole);
        bore(width-thickness,mountZ,screwHole);
        bore(width/2,mountZ,screwHole);
        }
      rotate([270,0,0])
      translate([0,0,250+plywood+sideThickness])
      union(){
        bore(thickness,mountZ,screwHole*2.65);
        bore(width-thickness,mountZ,screwHole*2.65);
        bore(width/2,mountZ,screwHole*2.65);
        }
        
      bore(width/3,thickness/2,screwHole);
      bore(width/3*2,thickness/2,screwHole);
      translate([width/3*2,thickness/2,thickness-screwHole])
        cone(screwHole, screwHole*2, screwHole);
      translate([width/3,thickness/2,thickness-screwHole])
        cone(screwHole, screwHole*2, screwHole);
      
      
      }
    }
  }
  
/**/

topThickness = 10;
couplerHeight = 25;

translate([0,0,thickness+2+couplerHeight])
union(){
  difference(){
    union(){
      translate([0,0,-couplerHeight])
      hull(){
        cube([width,plywood+sideThickness,topThickness+couplerHeight]);
        translate([(width-nema)/2,0,0])
        cube([nema,depth,topThickness+couplerHeight]);
        }
      }
    union(){
      translate([0,0,-couplerHeight-thickness*2])
      box(42,42,width/2,plywood+offset,couplerHeight+thickness*2);
      translate([0,0,-couplerHeight-thickness*2])
      box(42,42,width/2,plywood+offset*2,couplerHeight+thickness*2);
      translate([width/2,plywood+offset,0])
      union(){
        bore(0,0,leadscrew/2);
        translate([0,0,-12.5])
          nema17(1.6);
        translate([0,0,8])
          cylinder(h=4, r=bearing/2);
        translate([0,0,-4.5])
          cylinder(h=9, r=bearing/2);
        
        translate([-27.5,5,0])
          bore(0,0,screwHole);
        translate([+27.5,5,0])
          bore(0,0,screwHole);
        translate([0,-27.5,0])
          bore(0,0,screwHole);
        
        }
      }
    }
  }
  
/**/
  
    