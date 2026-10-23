
$fn=100;

difference(){
  hull(){
    cylinder(r=7.5,h=6);
    cylinder(r=10,h=3);
    }
  union(){
    hull(){
      translate([0,0,4])
        cylinder(r=5,h=8);
      translate([0,0,2])
      cylinder(r=3,h=12);
      }
    translate([0,0,-1])
      cylinder(r=3,h=12);
    }
  }
