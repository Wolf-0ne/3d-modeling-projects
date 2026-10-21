
// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects

// Stackable box. display: box, lid, interlock, full; divisions 0-4.

$fn = 85;

//General

divisions = 0; // 0,1,2,3,4
display = "box"; // lid, box, interlock, full

/* Small Box */
x = 45; // outer width
y = 90; // outer length
z = 35; // outer height
wallThickness = 2;
/**/
	
/* Standard Box *
x = 75; // outer width
y = 125; // outer length
z = 50; // outer height
wallThickness = 3;
/**/
	
/* Alternate Box *
x = 65; // outer width
y = 120; // outer length
z = 40; // outer height
wallThickness = 3;
/**/

//Clearance, Adjust this based on the accuracy of your 3d printer and desired tolerances.
clearance = 0.15; // 0.12

//Minimum Wall Thickness ( at sliding area )
slideWallThickness = wallThickness * 0.6; // wallThickness * 0.7

//Corner Radius
roundover = .8; // 0.75

//Slot
slotDepth = wallThickness*0.75; // wallThickness * 0.85
slotWidth = y/8; // y/10 

//Lid
lidThickness = wallThickness; // wallThickness
lidInterfaceLoc = slotWidth; // position of locking tabs
lidRoundOver = lidThickness/3.5; // 0.75

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
lo = (sx/2)+slideWallThickness-c2;
lya = -y/2+lidInterfaceLoc;
lyb = -lya;
lz = lidThickness - slotDepth;
lza = z - slotDepth - lidThickness;

baseOffset = (wallThickness+c*3)*2;

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
          roundedCube(sx, sy, lidThickness+c2, lidRoundOver);
          translate([0,-sy/2,0])
            roundedCube(sx, sy, lidThickness+c2, lidRoundOver);
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
        roundedQuadrilateral(ix-c*2, iy+10+c2*2, ix, iy+10-c2*2, wallThickness*2, clearance);
				
      //base slot cutouts
      translate([0,tabYa-(wallThickness-sz),0])
        roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, lidRoundOver);
      translate([0,tabYb-(wallThickness-sz),0])
        roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, lidRoundOver);
      }
    }
  }

module division(o) {
  difference(){
    translate([0,0,c])
      quadrilateral(slideWallThickness, y-o-baseOffset, slideWallThickness, y-o, lza-c2-c);  
    //base slot cutouts
    translate([0,tabYa-(wallThickness-sz),0])
      roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, lidRoundOver);
    translate([0,tabYb-(wallThickness-sz),0])
      roundedCube(x, tabWidth+clearance*4, slotDepth*2+c, lidRoundOver);
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
          roundedCube(sx-c2, sy-c2*2, lidThickness, lidRoundOver);
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
        roundedCube(x-(wallThickness*2)-roundover-c, tabWidth, slotDepth*2, roundover/2);
      translate([0,tabYb,lz+slotDepth])
        roundedCube(x-(wallThickness*2)-roundover-c, tabWidth, slotDepth*2, roundover/2);
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
	box();
	translate([0,0,lza+lidThickness+clearance])
  union(){
    box();
    dividers(divisions); 
    }
  }
  
  