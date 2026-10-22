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
	
//params

$fn=90;

boardh = 14.5;
boardx = 105;
boardy = 105;
boardholex = 70;
boardholey = 70;
boardoffsetx = 0;
boardoffsety = -1.5;
boardoffsetz = 2.4;
boardholeoffsetx = 0;
boardholeoffsety = 0;
boardholer = 2.8;
boardholeouterr = 4;

wallThickness = 3.5;
outerThickness = 2.5; //bottom
topThickness = 3.2;

oversize = 16;

x = boardx + 3;
y = boardy;

cornerWidth = 2;
height = boardh + boardoffsetz;

//offset = 4;
offset = 0;

boltX = x/2 - cornerWidth;
boltY = y/2 - cornerWidth;

border = 10.7;

part = "body"; // body, lid, full

//objects 

module body(){
	union(){

		hot = height/2+outerThickness/2;
		wt = wallThickness;
		wall = 1.7;
		sw = 5.8;
		s = 6;

		//body
		translate([0,0,outerThickness/2])
		difference(){

			union(){
				
				//main body
				plate(x,y,outerThickness,border,5.8,1.7,0);
					
				//walls
				
					//n
				translate([0,y/2+wt/2,hot])
				rotate([90,0,0])
					create_grid(size=[x,height,wt],SW=sw,wall=wall);
					
					//s
				translate([0,-y/2-wallThickness/2,wall/2+outerThickness/2])
					cube([x, wallThickness, wall], center=true);
					
				translate([-x/2+13/2,-y/2-wt/2,hot])
				rotate([90,0,0])
					create_grid(size=[13,height,wt],SW=sw,wall=wall);
				translate([x/2-13/2,-y/2-wt/2,hot])
				rotate([90,0,0])
					create_grid(size=[13,height,wt],SW=sw,wall=wall);
					
					//e
				rotate([0,0,90])
				translate([0,-x/2-wt/2,hot])
				rotate([90,0,0])
					create_grid(size=[y,height,wt],SW=sw,wall=wall);
					
					//w
				rotate([0,0,90])
				translate([0,x/2+wt/2,hot])
				rotate([90,0,0])
					create_grid(size=[y,height,wt],SW=sw,wall=wall);
					
				//pins
				pinr = wallThickness/3;
				pinh = outerThickness;
				pinz = height;
				pinrc = pinr;
				translate([-x/2+10,-y/2-pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2-10,-y/2-pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([0,y/2+pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2+pinr,0,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([-x/2-pinr,0,pinz])
					cylinder(h=pinh,r=pinrc);
					
				//corner pillars
				translate([0,0,outerThickness/2+height/2])
				bore4(boltX*2,boltY*2,3.1,height);
			
				//re-enforcing filled hexes
				fillhex(14, -45.4, 26.7, outerThickness, 5.8+1.7/2-.15);
				fillhex(14, -45.4, -26.7, outerThickness, 5.8+1.7/2-.15);
						
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
					
				}
			translate([0,0,0])
			union(){
				
				//top mounts
				translate([0,0,height])
				bore4(boltX*2,boltY*2,1.44,height);
				
				//pcb clearance
				translate([-23,0,outerThickness/2])
					cube([36,39,2.5],center=true);
				translate([14,-12,outerThickness/2])
					cube([27,18,2.5],center=true);
				
				
				}
			
			}
			
			pcb_posts();
			
		}
	}

//pcb 
module pcb(){
	color([0.2,0.5,0.2,0.5])
	translate([0,0,outerThickness+.1])
	union(){
		difference(){
			translate([boardoffsetx,boardoffsety,boardoffsetz+0.5])
			hull(){
				cube([boardx,76,1], center=true);
				cube([76,boardy,1], center=true);
				}
			}
		}
	}
module pcb_posts(){
	translate([boardoffsetx,boardoffsety,0])
	union(){
		translate([-boardx/2+17.5,boardy/2-16.5,0])
		pcb_post();
		translate([boardx/2-17.5,boardy/2-16.5,0])
		pcb_post();
		translate([-boardx/2+19,-boardy/2+22,0])
		pcb_post();
		translate([boardx/2-22,-boardy/2+22,0])
		pcb_post();
		}
	}
module pcb_post(){
	hull(){
		cylinder(h=outerThickness, r=(boardholeouterr > 4 ? boardholeouterr : 4));
		cylinder(h=outerThickness+boardoffsetz, r=boardholeouterr);
		}
	cylinder(h=boardoffsetz+outerThickness+2, r=boardholer);
	}
	

module top(){
	
	fanx = 2 + boardoffsetx;
	fany = -16;
	fanr = 11;
	
	wall = 1.7;
	
	topCenter = 14;

	translate([0,offset,topThickness/2+height+outerThickness+.2])
	difference(){

		union(){
		
			//main body
			plate(x,y,topThickness,border,5.8,wall,1);
				
			//re-enforcing filled hexes
			fillhex(14, -45.4, 19, topThickness, 5.8+1.7/2-.15);
			fillhex(14, -45.4, -19, topThickness, 5.8+1.7/2-.15);
			
			//fan mounting
			translate([0,-15,-topThickness/2])
			union(){
				cylinder(h=topThickness,r=14+wall*2+.7);
				translate([0,0,topThickness/2])
					bore4(24.5,24.5,3.2,topThickness);
				}
				
			//modem interfaces
			translate([0,26,-topThickness/2])
			union(){
				translate([-topCenter,0,0])
				mPin();
				translate([topCenter,0,0])
				mPin();
				}
				
			}
		union(){
		
			//fan mounting
			translate([0,-15,-4])
			union(){
				cylinder(h=50,r=14);
				bore4(24.5,24.5,1.44,50);
				}
		
			//screw holes
			bore4(boltX*2,boltY*2,1.6);
				
			//pins
			translate([0,0,-topThickness/4*3])
			union(){
				pinr = wallThickness/3;
				pinh = topThickness;
				pinz = 0;
				pinrc = pinr + .1;
				translate([-x/2+10,-y/2-pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2-10,-y/2-pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([0,y/2+pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2+pinr,0,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([-x/2-pinr,0,pinz])
					cylinder(h=pinh,r=pinrc);
				}
				
			}
		}
	}
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
	
	
if (part == "body") body();
else if (part == "lid") top();
else if (part == "full") { body(); top(); }
