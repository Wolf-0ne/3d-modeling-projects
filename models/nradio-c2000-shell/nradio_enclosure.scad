// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects

// Native hex-grid helpers.

module cell(SW_hole, height, wall) {
  tol = 0.001; // used to clean up difference artifacts
  difference() {
    cylinder(d=(SW_hole+2*wall)*1.1547005384, h=height, $fn=6, center=true);
    cylinder(d=SW_hole*1.1547005384, h=height+tol, $fn=6, center=true);
  }
}

module grid(size, cell_hole, cell_wall) {
  dx = cell_hole*sqrt(3) + cell_wall*sqrt(3);
  dy = cell_hole + cell_wall;
  nx = floor(size[0]/dx + 1.000001);
  ny = floor(size[1]/dy + 1.000001);

  for (j = [0:1:ny-1])
    translate([0, (j-(ny-1)/2)*dy, 0])
      for (i = [0:1:nx-1]) {
        translate([(i-(nx-1)/2)*dx, 0, 0])
          cell(SW_hole=cell_hole, height=size[2], wall=cell_wall);
        translate([(i-(nx-1)/2)*dx + dx/2, -dy/2, 0])
          cell(SW_hole=cell_hole, height=size[2], wall=cell_wall);
      }
}

module mask(size) {
  difference() {
    cube(3*size, center=true);
    cube(size, center=true);
  }
}

module create_grid(size, SW, wall) {
  b = 2*wall;
  difference() {
    cube(size, center=true);
    cube([size[0]-b, size[1]-b, size[2]+b], center=true);
  }

  difference() {
    grid(size=size, cell_hole=SW, cell_wall=wall);
    mask(size);
  }
}

//my functions
	
module bore(x,y,r,h=500,r2=0,z){
	zh = (z == undef ? -h/2 : z);
  translate([x,y,zh])
	union(){
	
		if ( r2 == 0 )
			cylinder(h=h, r=r);
		
		if ( r2 != 0 )
		hull(){
			cylinder(h=0.1, r=r);
			cylinder(h=h, r=r2);
			}
			
		}
  }

module bore4(x,y,r,h=500,r2=0,z){
  translate([-x/2, -y/2, 0])
  union(){
    bore(0, 0, r, h, r2, z);
    bore(x, 0, r, h, r2, z);
    bore(0, y, r, h, r2, z);
    bore(x, y, r, h, r2, z);
    }
  }
	
module post(h,r=3){
	union(){
		difference(){
			cylinder(h=h,r=r);
			bore(0,0,1.44);
			}
		pin(h/2,r);
		}
	}
	
module pin(h,r){
	hull(){
		cylinder(h=outerThickness+h,r=r);
		cylinder(h=outerThickness,r=r+1);
		}
	}

module mPin(){
	hull(){
		translate([0,8,0])
			cylinder(h=10,r=2.2);
		cylinder(h=10,r=2.2);
		}
	}
	
module plate(x,y,t,border,sw,wall,position=0){
	
	create_grid(size=[x-border/2,y-border/2,t],SW=sw,wall=wall);

	ot = t/4 * ( position == 0 ? 1 : -1 );
	wt = wallThickness;
	b = border;
	
	difference(){
		hull(){
			//inner x
			translate([0,0,ot])
				cube([x+wt*2,y,t/2],center=true);
			//inner y
			translate([0,0,ot])
				cube([x,y+wt*2,t/2],center=true);
			//outer x
			translate([0,0,0])
				cube([x,y+wt,t],center=true);
			//outer y
			translate([0,0,0])
				cube([x+wt,y,t],center=true);
			}
		//cutout
		cube([x-b,y-b,1000],center=true);
		}
		
	}
	
module fillhex(n, x, y, h, size){
	for ( i = [0 : n] ){
		xn = size;
		yn = i % 2 == 0 ? 0 : size/2 + .4;
		translate([x + xn * i, y + ( y > 0 ? -yn : yn ),-h/2])
			cylinder(h=h,r=size*.60);	
		}
	}

module post(h,r=3){
	union(){
		difference(){
			cylinder(h=h,r=r);
			bore(0,0,1.44);
			}
		pin(h/2,r);
		}
	}
	
module pin(h,r){
	hull(){
		cylinder(h=h,r=r);
		cylinder(h=outerThickness,r=r+1);
		}
	}

$fn=90;


//x = 112;
x = 108;
//y = 116;
y = 108;

wallThickness = 3;
outerThickness = 2.5;
topThickness = 3;
antennaHeight = 6 + outerThickness;
lteHeight = 7 + outerThickness - 0.3;
lteInterfaceHeight = lteHeight + 2.5;

cornerWidth = 1;
height = 14.5;

//offset = 4;
offset = 8;

boltX = x/2 - cornerWidth;
boltY = y/2 - cornerWidth;

border = 11;

part = "full"; // full, body, lid
fan = true;
modem = true;

module body(){
	union(){

		//body
		difference(){

			translate([0,offset,outerThickness/2])
			union(){
				
				//main body
				plate(x,y,outerThickness,border,5.8,1.7,0);
					
				//walls
				translate([0,-y/2-wallThickness/2,height/2+outerThickness/2])
				rotate([90,0,0])
					create_grid(size=[x,height,wallThickness],SW=5,wall=1.7);
					
				rotate([0,0,-90])
				translate([0,-x/2-wallThickness/2,height/2+outerThickness/2])
				rotate([90,0,0])
					create_grid(size=[y,height,wallThickness],SW=5,wall=1.7);
					
				rotate([0,0,90])
				translate([0,-x/2-wallThickness/2,height/2+outerThickness/2])
				rotate([90,0,0])
					create_grid(size=[y,height,wallThickness],SW=5,wall=1.7);
					
				translate([3,+y/2+wallThickness/2,height/2+outerThickness/2])
				rotate([90,0,0])
					create_grid(size=[11,height,wallThickness],SW=5,wall=1.7);
					
				translate([x/2-6.5,+y/2+wallThickness/2,height/2+outerThickness/2])
				rotate([90,0,0])
					create_grid(size=[13,height,wallThickness],SW=5,wall=1.7);
					
				translate([-x/2+6.5,+y/2+wallThickness/2,height/2+outerThickness/2])
				rotate([90,0,0])
					create_grid(size=[13,height,wallThickness],SW=5,wall=1.7);
					
				//pins
				translate([0,-y/2-wallThickness/3,height])
					cylinder(h=outerThickness,r=wallThickness/3);
				translate([-x/2-wallThickness/3,0,height])
					cylinder(h=outerThickness,r=wallThickness/3);
				translate([x/2+wallThickness/3,0,height])
					cylinder(h=outerThickness,r=wallThickness/3);
				translate([0,y/2+wallThickness/3,height])
					cylinder(h=outerThickness,r=wallThickness/3);
				translate([6,y/2+wallThickness/3,height])
					cylinder(h=outerThickness,r=wallThickness/3);
					
				//corner pillars
				translate([0,0,outerThickness/2+height/2])
				bore4(boltX*2,boltY*2,2.8,height);
					
				//corners
				translate([0,0,outerThickness/2+height/2])
				difference(){
					hull(){
						cube([x+wallThickness*2,y,height],center=true);
						cube([x,y+wallThickness*2,height],center=true);
						}
					union(){
						cube([x*2,y,height*2],center=true);
						cube([x,y*2,height*2],center=true);
						}
					}
					
				//re-enforcing filled hexes
				fillhex(14, -45.4, 19, outerThickness, 5.8+1.7/2-.15);
				fillhex(14, -45.4, -19, outerThickness, 5.8+1.7/2-.15);
					
				}
			translate([0,offset,outerThickness/2])
			union(){
				
				//top mounts
				translate([0,0,height])
					bore4(boltX*2,boltY*2,1.44,height);
					
				}
			
			}
			
		/*/re-enforcing bars
		translate([4,offset,2])
		hull(){
			cube([4,y,4],center=true);
			translate([0,0,1])
			cube([3,y-3,4],center=true);
			}
			
		translate([0,28.35,2])
		hull(){
			cube([x,4,4],center=true);
			translate([0,0,1])
			cube([x-3,3,4],center=true);
			}
			
		translate([0,-9,2])
		hull(){
			cube([x,4,4],center=true);
			translate([0,0,1])
			cube([x-3,3,4],center=true);
			}
		//*/

		//posts
			
		translate([80/2,-21,0])
			pin(h=lteHeight,r=2.5);
		translate([-80/2,-21,0])
			pin(h=lteHeight,r=2.5);
			
		translate([80/2,-21,0])
			cylinder(h=lteInterfaceHeight,r=0.83);
		translate([-80/2,-21,0])
			cylinder(h=lteInterfaceHeight,r=0.83);
			
		translate([80/2,30,0])
			pin(h=lteHeight,r=2);
		translate([-80/2,30,0])
			pin(h=lteHeight,r=2);
			
		translate([0,-30,0])
			pin(h=lteHeight,r=4);
		translate([0,-30,0])
			cylinder(h=height+outerThickness,r=1.75);
			
		}
	}
	
	
//lid
module mPin(){
	hull(){
		translate([0,8,0])
			cylinder(h=topThickness,r=2.4);
		cylinder(h=topThickness,r=2.4);
		translate([0,8,0])
			cylinder(h=10,r=1.6);
		cylinder(h=10,r=1.6);
		}
	}

module top(){

	topBar = x/2 - 2;
	topCenter = 14;

	translate([0,offset,height+topThickness*1.5])
	difference(){

		union(){
		
			//main
			plate(x,y,topThickness,border,5.8,1.7,1);
				
			if (modem) {
			//modem interfaces
			translate([0,20,-topThickness/2])
			union(){
				//translate([topBar,0,0])
				//mPin();
				//translate([-topBar,0,0])
				//mPin();
				
				translate([-topCenter,0,0])
				mPin();
				translate([topCenter,0,0])
				mPin();
				
				//slot
				h2 = (10-topThickness)/2+topThickness;
				translate([0,0,0])
				hull(){
					translate([topCenter,0,0])
						cylinder(h=topThickness,r=2.4);
					translate([-topCenter,0,0])
						cylinder(h=topThickness,r=2.4);
					translate([topCenter,0,0])
						cylinder(h=h2,r=2);
					translate([-topCenter,0,0])
						cylinder(h=h2,r=2);
					}
				}
			
			translate([0,-y/2+20,-topThickness/2])
			union(){
				//translate([topBar,0,0])
				//mPin();
				//translate([-topBar,0,0])
				//mPin();
				
				translate([-topCenter,0,0])
				mPin();
				translate([topCenter,0,0])
				mPin();
				}
					
			}
			if (fan) {
			//fan mount
			translate([0,0,-topThickness/2])
			union(){
				cylinder(h=topThickness,r=14+2.4);
				translate([0,0,topThickness/2])
					bore4(24.5,24.5,3.2,topThickness);
				}
				
			}
			//pin interface
			translate([0,-38,-topThickness/2])
				cylinder(h=topThickness,r=4);
				
			//re-enforcing filled hexes
			fillhex(14, -45.4, 19, topThickness, 5.8+1.7/2-.15);
			fillhex(14, -45.4, -19, topThickness, 5.8+1.7/2-.15);
				
			}
		union(){
		
			translate([0,0,-4])
			union(){
				cylinder(h=50,r=14);
				bore4(24.5,24.5,1.44,50);
				}
			bore4(boltX*2,boltY*2,1.6);
				
			//pins
			translate([0,0,-topThickness/4*3])
			union(){
				translate([0,-y/2-wallThickness/3,0])
					cylinder(h=topThickness,r=wallThickness/3+.1);
				translate([-x/2-wallThickness/3,0,0])
					cylinder(h=topThickness,r=wallThickness/3+.1);
				translate([x/2+wallThickness/3,0,0])
					cylinder(h=topThickness,r=wallThickness/3+.1);
				translate([0,y/2+wallThickness/3,0])
					cylinder(h=topThickness,r=wallThickness/3+.1);
				translate([6,y/2+wallThickness/3,0])
					cylinder(h=topThickness,r=wallThickness/3+.1);
				}
			}
		}
	}
	
if (part == "full") { body(); top(); }
else if (part == "body") body();
else if (part == "lid") top();
