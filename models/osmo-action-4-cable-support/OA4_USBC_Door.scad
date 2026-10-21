// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects
//action 4 usb-c door

$fn = 80;

innerStepYOffset=0.2;
innerStepX=13;
innerStepY=11.3;
innerStepZ=.8;

outerStepYOffset=-1.5;
outerStepX=15.4;
outerStepY=18.5;
outerStepZ=1.6;

topStepYOffset=-.1;
topStepX=19.3;
topStepY=23;
topStepZ=2.5;

lockYOffset=outerStepY/2+outerStepYOffset;
lockX=10.5;
lockY=.9;
lockZ=innerStepZ+outerStepZ+1;
lockCenter=2.3;
lockTangYA=0.2;
lockTangZA=0.1;
lockTangYB=0.5;
lockTangZB=1.3;
lockLipYOffset=.3;
lockLipZOffset=.4;

c=0.1; //clearance

medium = 0;
large = 0;

difference(){
	union(){
	
		// Main Body
		translate([0,innerStepYOffset,0])
			roundedSquare(innerStepX-c,innerStepY-c,innerStepZ,2);
		translate([0,outerStepYOffset,outerStepZ/2+innerStepZ])
			cube([outerStepX-c,outerStepY-c,outerStepZ], center=true);
		if (large == 0 && medium == 0){
			translate([0,topStepYOffset,outerStepZ+innerStepZ])
				roundedSquare(topStepX,topStepY-c,topStepZ,2.2);
			}
		else if (medium != 0){
			translate([0,topStepYOffset,outerStepZ+innerStepZ])
				hull(){
					roundedSquare(topStepX,topStepY-c,topStepZ,2.2);
					translate([c*2,0,2])
						roundedSquare(topStepX-3,topStepY-c-3,topStepZ,2.2);
					}
			}
		else {
			translate([0,topStepYOffset,outerStepZ+innerStepZ])
				hull(){
					roundedSquare(topStepX,topStepY-c,topStepZ,2.2);
					translate([1,0,4])
						roundedSquare(topStepX-5,topStepY-c-4,topStepZ,2.2);
					}
			} 
			
		//Lock Area
		translate([0,lockYOffset+lockY/2+lockCenter,lockZ/2+lockTangZA])
			cube([lockX,lockY+lockTangYA,lockZ], center=true);	
		translate([0,lockYOffset+lockY/2+lockCenter/2,lockZ/2+lockTangZB])
			cube([lockX,lockY+lockTangYB,1.6], center=true);
		
		translate([0,lockYOffset+lockY/2,lockZ/2])
			cube([lockX,lockY,lockZ], center=true);
		hull(){
			translate([0,lockYOffset+lockY/2+lockLipYOffset,-lockLipZOffset])
				cube([lockX,lockY,lockLipZOffset], center=true);	
			translate([0,lockYOffset+lockY/2,0])
				cube([lockX,lockY,lockLipZOffset], center=true);	
			}
			
		//Latch Area ( kinda brute forced )
		translate([0,-topStepY/2+1,1.1])
			cube([topStepX-4,2,3], center=true);
		translate([0,0,-outerStepZ-.1])
		translate([0,-topStepY/2+1,1.1])
			cube([topStepX-4,2,3], center=true);
			
		translate([0,0,-3.05])
		translate([0,-topStepY/2+2.1,1.4])
			cube([9,1,.9], center=true);
			
		}
	union(){
		//USB-C
		translate([3.5,.3,-1])
			roundedSquare(6.5, 11.5, 10, 2.5);
			
		//Cutouts
		translate([topStepX/2-2,topStepY/2-1.95,2.8])
			cube([4.8,3.7,1], center=true);
		translate([-topStepX/2+2,topStepY/2-1.95,2.8])
			cube([4.8,3.7,1], center=true);
		}
	}
	
	
module roundedSquare(xs, ys, z, r=1){
	
	x = xs - r * 2;
	y = ys - r * 2;
	
  translate([-x/2, -y/2, 0])
	hull(){
		translate([0,0,0])
			cylinder(h=z,r=r);
		translate([0,y,0])
			cylinder(h=z,r=r);
		translate([x,0,0])
			cylinder(h=z,r=r);
		translate([x,y,0])
			cylinder(h=z,r=r);
		}

	}