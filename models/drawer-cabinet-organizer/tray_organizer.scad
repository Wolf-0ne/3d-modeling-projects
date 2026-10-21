// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects

$fn = 90;

/* Dimensions */

width = 70;
height = 35;
wallthickness = 2.5;
divisions = 2;

/* Dimensions */

chamfer = wallthickness/5*3; // 2/sqrt(2);
dividerMultiplier = chamfer; // wallthickness/5*3 or 1.5
    
/**/

module chamferedCube(xyz, chamfer){
  c2 = chamfer * 2;
  a = [xyz[0] - c2, xyz[1] - c2, xyz[2]];
  b = [xyz[0] - c2, xyz[1], xyz[2] - c2];
  c = [xyz[0], xyz[1] - c2, xyz[2] - c2];
  hull(){
    translate([chamfer,chamfer,0])
      cube(a);
    translate([chamfer,0,chamfer])
      cube(b);
    translate([0,chamfer,chamfer])
      cube(c);
    }
  }
	
module dividers(d) {

  t = wallthickness;
	t1 = t*1.5;
	t2 = t/2;
	w = width;
	w2 = width/2;
	w3 = width/3;
	c = chamfer;
	m = dividerMultiplier;
	
  if (d == 1){
		translate([t,t,t])
      chamferedCube([w-t*2,w-t*2,height], c);
    }
  else if (d == 2){
		translate([t,t,t])
      chamferedCube([w-t*2,w2-t*m,height], c);
		translate([t,w/2+t/2,t])
      chamferedCube([w-t*2,w2-t*m,height], c);
    }
  else if (d == 3){
		translate([t,t,t])
      chamferedCube([w-t*2,w3-t*m,height], c);
		translate([t,w3+t/3*2,t])
      chamferedCube([w-t*2,w3-t*m,height], c);
		translate([t,w3*2+t/3,t])
      chamferedCube([w-t*2,w3-t*m,height], c);
    }
  else if (d == 4){
		translate([t,t,t])
      chamferedCube([w2-t*m,w2-t*m,height], c);
		translate([t,w/2+t/2,t])
      chamferedCube([w2-t*m,w2-t*m,height], c);
		translate([w/2+t/2,t,t])
      chamferedCube([w2-t*m,w2-t*m,height], c);
		translate([w/2+t/2,w/2+t/2,t])
      chamferedCube([w2-t*m,w2-t*m,height], c);
    } 
		
  }

/**/

difference(){
  union(){
    chamferedCube([width,width,height], chamfer);
    }
  union(){
		dividers(divisions);
    }
  }
  
/**/
