
// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects

// Small interlock box for thread-tapping tools.
// Optional variation of the stackable box.

$fn = 85;

x = 40; // outer width
y = 80; // outer length
z = 15; // outer height
wallThickness = 1.8;

divisions = 2; // 0,1,2,3,4
display = "interlock"; // lid, box, interlock, full

//Minimum Wall Thickness ( at sliding area )
slideWallThickness = wallThickness * 0.6; // wallThickness * 0.7

//Corner Radius
roundover = 0.6; // 0.75

//Slot
slotDepth = 1.25; // wallThickness * 0.85
slotWidth = 10; // y/10 

//Lid
lidThickness = 1.5; // wallThickness
lidInterfaceLoc = 8.5; // slotWidth*2

//Clearance, Adjust this based on the accuracy of your 3d printer and desired tolerances.
clearance = 0.12; // 0.12

//Spagetti Code, Edit at your own Pasta

c = clearance;
c2 = clearance*2;

ix = x-(wallThickness*2)-c2;
iy = y-(wallThickness*2)-c2;

sx = x-(slideWallThickness*2);
sy = y-(slideWallThickness);
sz = slideWallThickness;

tabWidth = slotWidth;
tabYa = -y/2+tabWidth*2;
tabYb = -tabYa;

lr = slideWallThickness + c2;
lo = (sx/2)+slideWallThickness-c*3;
lya = -y/2+lidInterfaceLoc;
lyb = -lya;
lz = lidThickness - slotDepth;
lza = z - slotDepth - lidThickness;

baseOffset = (wallThickness+c2)*2;

module quadrilateral(xa, ya, xb, yb, z, r=.1, o=0){
  hull(){
    translate([0,0,o])
      cube([xa,ya,r],center=true);
    translate([0,0,z])
      cube([xb,yb,r],center=true);
    }
  }
module roundedCube(x, y, z, r) {
  minkowski(){
    cube([x-r*2,y-r*2,z-r*2],center=true);
    sphere(r);
    }
  }
module roundedQuadrilateral(xa, ya, xb, yb, z, r) {
  minkowski(){
    quadrilateral(xa-r*2, ya-r*2, xb-r*2, yb-r*2, z-r-r/2, r, r+r/2);
    sphere(r);
    }
  }
  
module box() {
  difference(){
      //main
    union(){
      roundedQuadrilateral(x-baseOffset, y-baseOffset, x, y, z, roundover);
      }
    union(){
      //main cutout
      difference(){
        translate([0,0,wallThickness])
          roundedQuadrilateral(ix-baseOffset+c, iy-baseOffset+c, ix, iy, z-wallThickness*2, roundover);
        //ensure base thickness is at least 1mm in all points
        translate([0,0,wallThickness+.5])
          cube([ix-baseOffset, iy-baseOffset,1],center=true);
        }
      //slide cutout
      translate([0,-sz/2,lza])
      difference(){
        translate([0,0,lidThickness/2])
        union(){
          roundedCube(sx, sy, lidThickness+c2, roundover*0.75);
          translate([0,-sy/2,0])
            roundedCube(sx, sy, lidThickness+c2, roundover*0.75);
          }
        //locking nubs
        translate([0,0,0])
        union(){
          translate([lo,lya,0])
            cylinder(h=baseOffset, r=lr, center=true);
          translate([lo,lyb,0])
            cylinder(h=baseOffset, r=lr, center=true);
          translate([-lo,lya,0])
            cylinder(h=baseOffset, r=lr, center=true);
          translate([-lo,lyb,0])
            cylinder(h=baseOffset, r=lr, center=true);
          }
        }
      //top cutout/clearance
      translate([0,-5,z-wallThickness])
        roundedQuadrilateral(ix+c2, iy+10+c2*2, ix-c2*2, iy+10-c2*2, wallThickness*2, clearance);
      //base slot cutouts
      translate([0,tabYa-(wallThickness-sz),0])
        roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, roundover*0.75);
      translate([0,tabYb-(wallThickness-sz),0])
        roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, roundover*0.75);
      }
    }
  }

module division(o) {
  difference(){
    translate([0,0,c])
      quadrilateral(slideWallThickness, y-o-baseOffset, slideWallThickness, y-o, lza-c2-c);  
    //base slot cutouts
    translate([0,tabYa-(wallThickness-sz),0])
      roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, roundover*0.75);
    translate([0,tabYb-(wallThickness-sz),0])
      roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, roundover*0.75);
    }
  }

module dividers(d) {
  o = slideWallThickness;
  if (d == 1){
    division(o);
    }
  else if (d == 2){
    translate([x/6-o/2,0,0])
      division(o);
    translate([-x/6+o/2,0,0])
      division(o);
    }
  else if (d == 3){
    division(o);
    translate([x/4-o,0,0])
      division(o);
    translate([-x/4+o,0,0])
      division(o);
    }
  else if (d == 4){
    translate([x/10-o/2,0,0])
    division(o);
    translate([-x/10+o/2,0,0])
    division(o);
    translate([x/10*3-o,0,0])
    division(o);
    translate([-x/10*3+o,0,0])
    division(o);
    } 
  }

module lid() {
  translate([0,-(wallThickness-sz),lza]){
    union(){
      //main
      difference(){
        translate([0,0,lidThickness/2])
          roundedCube(sx-c2, sy-c2*2, lidThickness, roundover*0.75);
        //locking cutouts
        union(){
          translate([lo-c,lya,0])
            cylinder(h=baseOffset, r=lr, center=true);
          translate([lo-c,lyb,0])
            cylinder(h=baseOffset, r=lr, center=true);
          translate([-lo+c,lya,0])
            cylinder(h=baseOffset, r=lr, center=true);
          translate([-lo+c,lyb,0])
            cylinder(h=baseOffset, r=lr, center=true);
          }
        }
      //slots
      translate([0,tabYa,lz+slotDepth])
        roundedCube(x-(wallThickness*2)-roundover, tabWidth, slotDepth*2, roundover/2);
      translate([0,tabYb,lz+slotDepth])
        roundedCube(x-(wallThickness*2)-roundover, tabWidth, slotDepth*2, roundover/2);
      }
    }
  }
  

/* Output */

if (display == "box" || display == "full"){
  union(){
    box();
    dividers(divisions); 
    }
  }
if (display == "lid" || display == "interlock" || display == "full"){
  lid();
  }
if (display == "interlock"){
    translate([0,0,lza+lidThickness+clearance])
  union(){
    box();
    dividers(divisions); 
    }
  }
  
  