
// Tested; fit to my saw. Casting tolerances vary.
/**/
 minkowski(){
  difference(){
    union(){
      cube([25,55,5]);
      }
    union(){
      translate([3.5,-1,-1])
        cube([5,35,7]);
      }
    }
  sphere(.5);
  }
/**/