
// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects

// Older TS80 soldering kit layout, kept as an optional legacy variation.

$fn = 90;

/**/

width = 65;
height = 43;
wallthickness = 2.5;
chamfer = 2/sqrt(2);
    
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

/*/

difference(){
  union(){
    chamferedCube([width,width,height], chamfer);
    }
  union(){
    translate([wallthickness,wallthickness,wallthickness])
      chamferedCube([width/2-wallthickness*1.5,width/2-wallthickness*1.5,height], chamfer);
    translate([width/2+wallthickness/2,wallthickness,wallthickness])
      chamferedCube([width/2-wallthickness*1.5,width/2-wallthickness*1.5,height], chamfer);
    translate([wallthickness,width/2+wallthickness/2,wallthickness])
      chamferedCube([width/2-wallthickness*1.5,width/2-wallthickness*1.5,height], chamfer);
    translate([width/2+wallthickness/2,width/2+wallthickness/2,wallthickness])
      chamferedCube([width/2-wallthickness*1.5,width/2-wallthickness*1.5,height], chamfer);
    }
  }
  
/**/

difference(){
  union(){
    translate([0,-55,0])
      chamferedCube([width,width+53,height], chamfer);
    }
  union(){
    translate([wallthickness,-55+wallthickness,wallthickness])
      chamferedCube([width-wallthickness*2,20-wallthickness,height], chamfer);
    translate([wallthickness,wallthickness,wallthickness])
      chamferedCube([width-wallthickness*2,31,height], chamfer);
    translate([wallthickness,width/2+wallthickness/2+2,wallthickness])
      chamferedCube([width-wallthickness*2,25,height], chamfer);
    translate([wallthickness*2+7.5,-7.5,wallthickness])
      cylinder(d=9, height);
    translate([wallthickness*2+7.5,-7.5-wallthickness-15,wallthickness])
      cylinder(d=9, height);
    translate([65-(wallthickness*2+7.5),-7.5,wallthickness])
      cylinder(d=9, height);
    translate([65-(wallthickness*2+7.5),-7.5-wallthickness-15,wallthickness])
      cylinder(d=9, height);
    translate([65/2,-7.5-wallthickness-15,wallthickness])
      cylinder(d=15, height);
    translate([65/2,-7.5,wallthickness])
      cylinder(d=15, height);
    }
  }
  
/**/