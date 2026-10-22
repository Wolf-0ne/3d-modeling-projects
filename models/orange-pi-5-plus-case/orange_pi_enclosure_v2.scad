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

module grid(size, cell_hole, cell_wall, rotateHex=0) {
  dx = cell_hole*sqrt(3) + cell_wall*sqrt(3);
  dy = cell_hole + cell_wall;
  x = rotateHex == 0 ? 0 : 1;
  y = rotateHex == 0 ? 1 : 0;
  r = rotateHex == 0 ? 0 : 90;
  nx = floor(size[x]/dx + 1.000001);
  ny = floor(size[y]/dy + 1.000001);

  rotate([0,0,r])
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

module create_grid(size, SW, wall, outerWallModifier=2, rotateHex=0) {
  b = outerWallModifier*wall;
  difference() {
    cube(size, center=true);
    cube([size[0]-b, size[1]-b, size[2]+b], center=true);
  }

  difference() {
    grid(size=size, cell_hole=SW, cell_wall=wall, rotateHex=rotateHex);
    mask(size);
  }
}


//my functions (aka junk)
	
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
	
module pin(h,r){
	hull(){
		cylinder(h=outerThickness+h,r=r);
		cylinder(h=outerThickness,r=r+1);
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
	
/* Params */

	$fn=90;

	//orange pi dimensions ( not exact, but it works )

	boardh = 18;
	boardx = 75;
	boardy = 100;
	boardholex = 49;
	boardholey = 87;

	//board hole radius

	boardholer = 1.4; 
	boardholeouterr = 2.7; //support radius

	//offsets from center of model

	boardoffsetx = -.2;
	boardoffsetz = 3.5;
	boardholeoffsetx = 8.75; 
	boardholeoffsety = -3.25; 

	//box inner x/y

	x = boardx + 5;
	y = boardy + 8;

	//box inner height

	height = boardh + boardoffsetz;

	//box walls

	wallThickness = 3.2;
	outerThickness = 2.5; //bottom
	topThickness = 3.5;

	//box solid border

	border = 9;

	//top bolt pattern

	boltInset = 2;

	boltX = x/2 - boltInset;
	boltY = y/2 - boltInset;

	offset = 0; //holdover from old model

	part = "body"; // body, top, full
	fanMount = 1; // top fan mount (0/1)
	usbcSupport = 0; // USB-C support

/* Objects */

if (part == "full") {
	body(usbcSupport);
	top(fanMount);
} else if (part == "top") {
	top(fanMount);
} else {
	body(usbcSupport);
}
	

//body
module body(usbcSupport=0){
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
					create_grid([x,height,wt],sw,wall,3);
					
					//s
				translate([0,-y/2-wt/2,hot])
				rotate([90,0,0])
					create_grid([x,height,wt],sw,wall,3);
					
					//e
				translate([x/2+wallThickness/2,-26,wall/2+outerThickness/2])
					cube([wallThickness, 50, wall*2], center=true);
				rotate([0,0,90])
				translate([y/2-16/2,-x/2-wt/2,hot])
				rotate([90,0,0])
					create_grid([16,height,wt],sw,wall,3);
				rotate([0,0,90])
				translate([9,-x/2-wt/2,hot])
				rotate([90,0,0])
					create_grid([22,height,wt],sw,wall,3);
				rotate([0,0,90])
				translate([-y/2+10/2,-x/2-wt/2,hot])
				rotate([90,0,0])
					cube([10,height,wt], center=true);
					
					//w
				translate([-x/2-wallThickness/2,0,wall/2+outerThickness/2])
					cube([wallThickness, y, wall*2], center=true);
				rotate([0,0,90])
				translate([y/2-s/2,x/2+wt/2,hot])
				rotate([90,0,0])
					cube([s,height,wt], center=true);
				rotate([0,0,90])
				translate([4.5,x/2+wt/2,hot])
				rotate([90,0,0])
					create_grid([27,height,wt],sw,wall,3);
				rotate([0,0,90])
				translate([-y/2+15/2,x/2+wt/2,hot])
				rotate([90,0,0])
					cube([15,height,wt], center=true);
				//	create_grid(size=[s,height,wt],SW=sw,wall=wall);
					
				//pins
				pinr = wallThickness/3;
				pinh = outerThickness;
				pinz = height;
				pinrc = pinr;
				translate([0,-y/2-pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([0,y/2+pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2+pinr,18,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2+pinr,0,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([-x/2-pinr,16,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([-x/2-pinr,-7,pinz])
					cylinder(h=pinh,r=pinrc);
					
				//corner pillars
				translate([0,0,outerThickness/2+height/2])
				bore4(boltX*2,boltY*2,3.1,height);
			
				//re-enforcing filled hexes
				fillhex(10, -32.4, 25.7, outerThickness, 5.8+1.7/2-.15);
				fillhex(10, -32.4, -25.7, outerThickness, 5.8+1.7/2-.15);
						
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
					
				//beefier usb-c
				if (usbcSupport != 0){
					translate([-x/2-6.5,-y/2+8.5,8.2])
					hull(){
						rotate([0,90,0])
							cylinder(h=1,r=5);
							
						translate([0,0,6.5])
						rotate([0,90,0])
							cylinder(h=1,r=5);
							
						translate([3.3,0,-1.7])
						union(){
							rotate([0,90,0])
								cylinder(h=2,r=6.5);
								
							translate([0,0,8.5])
							rotate([0,90,0])
								cylinder(h=2,r=6.5);
							}
						}
					}
				
				//pcb wall
				translate([0,0,0-1-outerThickness/2])
				pcb_m2(wall, outerThickness);
				
				}
			translate([0,0,0])
			union(){
			
				//usb-c port
				translate([-x,-y/2+8.5,8.2])
				hull(){
					rotate([0,90,0])
						cylinder(h=x,r=3.5);
						
					translate([0,0,6.5])
					rotate([0,90,0])
						cylinder(h=x,r=3.5);
					}
					
				//sd card
				translate([x/2-4,20,outerThickness/2])
				cube([10,18,4]);
				
				//top mounts
				translate([0,0,height])
				bore4(boltX*2,boltY*2,1.44,height);
					
				//pcb cutout
				pcb_m2(z=outerThickness/2);
				
				//pcb clearance
				translate([1,0,outerThickness/2+.01])
				hull(){
					bore4(boardx-4, boardy-2, 3, .1, z=0);
					translate([0,0,boardoffsetz+height])
						bore4(boardx-4, boardy-10, 2, 1, z=0);
					}
				
				}
			
			}

		//posts
		bhx = boardholex;
		bhy = boardholey;
		translate([boardholeoffsetx+boardoffsetx,boardholeoffsety,0])
		union(){
			bore4(bhx, bhy, 4, outerThickness, z=0);
			bore4(bhx, bhy, 4, boardoffsetz, boardholeouterr, outerThickness);
			bore4(bhx, bhy, boardholer, boardoffsetz+2, z=outerThickness);
			}
			
		}
	}

//pcb ( for visualization )
module pcb(){
	color([0.2,0.5,0.2,0.5])
	translate([0,0,outerThickness+.1])
	union(){
		difference(){
			translate([boardoffsetx,0,boardoffsetz])
			hull(){
				bore4(boardx-2, boardy-2, 1, 1, z=0);
				}
			translate([boardholeoffsetx+boardoffsetx,boardholeoffsety,0])
			bore4(boardholex, boardholey, boardholer, boardoffsetz+3, z=outerThickness);
			}
		pcb_m2();
		}
	}
module pcb_m2(wall=0,h,z){
	//7 from bottom
	//11 from right
	pcbx = 24;
	pcby = 8;
	pcbz = (h != undef ? h : 5.8);
	translate([2,0,0])
	translate([boardx/2,-boardy/2,0])
	translate([-12-11,7+4,(z != undef ? z : boardoffsetz-pcbz/2)])
	cube([pcbx+wall*2, pcby+wall*2, pcbz], center=true);
	}

//lid
module top(fanMount=0){
	
	fanx = 4.7;
	fany = -23.8;
	fanr = 11;
	
	hdmix = -3.5;
	hdmiy1 = 28;
	hdmiy2 = 39.5;
	hdmiy3 = 52.5;
	hdmiw = 16;
	hdmih = 6;
	
	wall = 1.7;

	translate([0,offset,topThickness/2+height+outerThickness+.2])
	difference(){

		union(){
		
			//main body
			plate(x,y,topThickness,border,5.8,wall,1);
				
			//re-enforcing filled hexes
			fillhex(10, -32.4, 25.7, topThickness, 5.8+1.7/2-.15);
			fillhex(10, -32.4, -25.7, topThickness, 5.8+1.7/2-.15);
			
			//fan mounting
			//L 22, R 18
			if (fanMount != 0){
				translate([fanx,fany,-topThickness/2])
				union(){
					cylinder(h=topThickness,r=fanr+wall*1.5);
				
					translate([13.25,10,0])
					union(){
						cylinder(h=topThickness,r=1+wall);
						hull(){
							translate([0,0,-4])
							cylinder(h=topThickness,r=.8);
							cylinder(h=topThickness,r=.93);
							}
						}
					
					translate([-1,-13,0])
					union(){
						translate([-12.5,0,0])
						union(){
							cylinder(h=topThickness,r=1+wall);
							hull(){
								translate([0,0,-4])
								cylinder(h=topThickness,r=.8);
								cylinder(h=topThickness,r=.93);
								}
							}
						translate([+12.5,0,0])
						union(){
							cylinder(h=topThickness,r=1+wall);
							hull(){
								translate([0,0,-4])
								cylinder(h=topThickness,r=.8);
								cylinder(h=topThickness,r=.93);
								}
							}
						}
					}
				}
				
			//eth mount pressure
			translate([-x/2+7.6,-26.3,-topThickness/2-1.3])
			cylinder(h=topThickness, r=4);
			
			//eth strenghthening
			translate([-x/2+.3,-y/2+12,-topThickness/2-1])
			cube([2,35,2]);
				
			//sd card
			translate([x/2,20+.2,-topThickness])
			cube([wallThickness,18-.4,topThickness]);
			
			}
		union(){
		
			//fan mounting
			//L 22, R 18
			if (fanMount != 0){
			translate([fanx,fany,-topThickness])
				union(){
					cylinder(h=topThickness*3,r=fanr);
					
					//translate([-12.5,.5+12.5,0])
					//cylinder(h=topThickness*3,r=1);
					
					//translate([+12.5,.5+12.5,0])
					//cylinder(h=topThickness*3,r=1);
					}
				}
		
			//screw holes
			bore4(boltX*2,boltY*2,1.6);
			
			//HDMI Clearance
			translate([-x/2,0,-topThickness])
			union(){
				translate([-wallThickness*2,20,0])
				hull(){
					cube([+wallThickness*2, hdmih+4, topThickness*2]);
					translate([0,-2,0])
					cube([+wallThickness, hdmih+8, topThickness*2]);
					}
					
				//translate([hdmix,-hdmiy2,0])
				//	cube([hdmiw, hdmih, topThickness]);
				
				//translate([hdmix,-hdmiy3,0])
				//	cube([hdmiw, hdmih, topThickness]);
				}
				
			//pins
			translate([0,0,-topThickness/4*3])
			union(){
				pinr = wallThickness/3;
				pinh = topThickness;
				pinz = 0;
				pinrc = pinr + .1;
				translate([0,-y/2-pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([0,y/2+pinr,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2+pinr,18,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([x/2+pinr,0,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([-x/2-pinr,16,pinz])
					cylinder(h=pinh,r=pinrc);
				translate([-x/2-pinr,-7,pinz])
					cylinder(h=pinh,r=pinrc);
				}
			}
		}
	}
