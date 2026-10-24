
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

/*/


beltWidth = 15;
beltClearance = 1;
slot = beltWidth + beltClearance; // 16 mm slot for a 15 mm belt

translate([0,0,7.5])
  difference(){
    union(){
      hull(){
        box(52,52,0,30,19);
        box(100,20,0,-5,19);
        }
      }
    translate([0,0,0])
      union(){
        bore(27,-7,2.55);
        bore(-27,-7,2.55);
        
        bore(0,-5,2.4);
        bore(42,-5,2.4);
        bore(-42,-5,2.4);
        
        translate([0,-5,17])
          cone(2.4,5,2.5);
        translate([42,-5,17])
          cone(2.4,5,2.5);
        translate([-42,-5,17])
          cone(2.4,5,2.5);
        
        bore(0,30,2.55);
        
        bore(26,29,1.82);
        bore(-26,29,1.82);
          
        translate([0,0,17.5])  
        union(){
          translate([26,29,0])
            cylinder(h=25, r=3);
          translate([-26,29,0])
            cylinder(h=25, r=3);
          }
          
        translate([0,30,3.7])
          nema17(3.2);
        
        translate([0,0,-0.5])  
        box(50,slot,42,-15,14);
        translate([0,0,-0.5])  
        box(50,slot,-42,-15,14);
          
        translate([0,0,-0.5])
        union(){
          box(42,42,0,30,14);
          hull(){
            translate([27,-7,0])
              cylinder(h=14,r=11);
            translate([0,30,0])
              cylinder(h=14,r=8);              
            }
          hull(){
            translate([-27,-7,0])
              cylinder(h=14,r=11);
            translate([0,30,0])
              cylinder(h=14,r=8);              
            }
          }
        }
    }

/**
      
  difference(){
    union(){
      hull(){
        box(52,52,0,30,7);
        box(100,20,0,-5,7);
        }
      difference(){
        union(){
          hull(){
            translate([0,6,-25])
              cube([52,5,50], center=true);
            box(52,52,0,30,7);
            }
          hull(){
            translate([0,6,-20])
              cube([80,5,40], center=true);
            translate([0,6,-25])
              cube([52,5,50], center=true);
            }
          }
        translate([0,0,-80])
          box(42,42,0,30,90);
        translate([0,0,-80])
          box(42,42,0,30,90);
        }
      }
    translate([0,0,0])
      union(){
        bore(27,-7,2.55);
        bore(-27,-7,2.55);
        
        bore(0,-5,2.4);
        bore(42,-5,2.4);
        bore(-42,-5,2.4);
        
          //stepper
        translate([0,30,-1])
          cylinder(h=25, r=7.1);
          
        translate([0,30,-1])
          cylinder(h=4, r=11.3);
          
        translate([0,30,-5])
          nema17(1.82);
          
        translate([0,30,3.7])
          nema17(3.2);
        
        translate([26,29,0])
          cylinder(h=25, r=1.8);
        translate([-26,29,0])
          cylinder(h=25, r=1.8);
        
        translate([0,0,0])  
        union(){
          translate([26,29,0])
            hexagon(5.7, 8);
          translate([-26,29,0])
            hexagon(5.7, 8);
          }
          
        rotate([90,0,0])
          bore(-33,-11,2);
        rotate([90,0,0])
          bore(33,-11,2);
          
        rotate([90,0,0])
          bore(-33,-33,2);
        rotate([90,0,0])
          bore(33,-33,2);
          
        }
    }
    
/**/

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
  
/**

height = 14;
width = 30;
depth = 30;
slot = beltWidth + beltClearance; // 16 mm slot for a 15 mm belt
teeth = 14;
spacing = 2;
chamfer = 4;
bore = 2;
lidHeight = 5;
    
/**

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
      }
    }
  }
    
/**

translate([0,0,height+spacing/2])
union(){
  difference(){
    union(){
      hull(){
          translate([chamfer, 0, 0])
            cube([width-chamfer*2,depth,lidHeight]);  
          translate([0, chamfer, 0])
            cube([width,depth-chamfer*2,lidHeight]);  
        }
      }
    union(){
      translate([(width)/2-slot+spacing,depth/2,lidHeight-bore])
        cone(bore, bore*2, bore);
      translate([(width)/2+slot-spacing,depth/2,lidHeight-bore])
        cone(bore, bore*2, bore);
      bore((width)/2-slot+spacing,depth/2,bore);
      bore((width)/2+slot-spacing,depth/2,bore);
      }
    }
  }

/**/

height = 17;
width = 30;
depth = 30;
slot = 16; // 16 mm slot for a 15 mm belt
teeth = 14;
spacing = 2;
chamfer = 4;
bore = 1.45;
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
        hexagon(5.7, 6);
      translate([(width)/2+slot-spacing,depth/2,0])
        hexagon(5.7, 6);
          
      
      translate([width/2,depth,8])
      rotate([90,270,0])
      bore(0,0,4.1);
      
      translate([width/2,depth/2,8])
      rotate([90,270,0])
        hull(){
          hexagon(12.85, 9.2);
          translate([-9,0,0])
            cube([1, 12.85, 9.2], center=true);
          }
      }
    }
  }
    
/**/

translate([0,0,height+spacing/2])
union(){
  difference(){
    union(){
      hull(){
          translate([chamfer, 0, 0])
            cube([width-chamfer*2,depth,lidHeight]);  
          translate([0, chamfer, 0])
            cube([width,depth-chamfer*2,lidHeight]);  
        }
      }
    union(){
      bore((width)/2-slot+spacing,depth/2,bore);
      bore((width)/2+slot-spacing,depth/2,bore);
      }
    }
  }

/**/

depthBack = 10;
bore2 = 2;

translate([0,depth+height,0])
union(){
  difference(){
    union(){
      hull(){
          translate([chamfer, 0, 0])
            cube([width-chamfer*2,depthBack,height-1]);  
          translate([0, chamfer, 0])
            cube([width,depthBack-chamfer*2,height-1]);  
        }
      }
    union(){
      bore((width)/2-slot+spacing,depthBack/2,bore2);
      bore((width)/2+slot-spacing,depthBack/2,bore2);
      translate([(width)/2-slot+spacing,depthBack/2,height-bore2])
        cone(bore2, bore2*2, bore2);
      translate([(width)/2+slot-spacing,depthBack/2,height-bore2])
        cone(bore2, bore2*2, bore2);
      translate([width/2,depth,8])
        rotate([90,270,0])
          bore(0,0,4.1);
      }
    }
  }

/**/

translate([0,-depth-height,0])
union(){
  difference(){
    union(){
      hull(){
          translate([chamfer, 0, 0])
            cube([width-chamfer*2,depth,height-1]);  
          translate([0, chamfer, 0])
            cube([width,depth-chamfer*2,height-1]);  
        }
      }
    union(){
      bore((width)/2-slot+spacing,depth/2,bore2);
      bore((width)/2+slot-spacing,depth/2,bore2);
      translate([(width)/2-slot+spacing,depth/2,height-bore2])
        cone(bore2, bore2*2, bore2);
      translate([(width)/2+slot-spacing,depth/2,height-bore2])
        cone(bore2, bore2*2, bore2);
      translate([width/2,depth,8.3])
        rotate([90,270,0])
          bore(0,0,1.5);
      translate([width/2,depth/2+depth,8.3])
        rotate([90,270,0])
          cylinder(h=depth, r=4.1);
      }
    }
  }

/**/


