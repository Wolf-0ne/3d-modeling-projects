
// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects

// TS80P soldering kit. type: dual (default), single.

$fn = 90;

/* Parameters */

type = "dual"; // dual (default), single

width = 65;
height = 43;
wallthickness = 2.5;
chamfer = 2/sqrt(2);

solderZoneLength = 22;
powerZoneLength = 31;
storageZoneLength = (type == "dual") ? 34 : 39;
cableZoneLength = (type == "dual") ? 17.5 : 0;

tipOffset = 10.5;
tipSpacing = (storageZoneLength+wallthickness)/4+wallthickness;
ironSpacing = (storageZoneLength+wallthickness)/3+wallthickness;

length = wallthickness*5+solderZoneLength+powerZoneLength+storageZoneLength+cableZoneLength;
    
/* Cube */

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
	
/* Iron Tips */

module ironTips(offset){
	translate([0,offset,wallthickness])
	union(){
		translate([0,0,0])
			cylinder(d=9, height);
		translate([0,tipSpacing,0])
			cylinder(d=9, height);
		if (type == "dual"){
			translate([0,tipSpacing*2,0])
				cylinder(d=9, height);
			}
		}
	}

difference(){

	//Main Body
  union(){
		translate([0,0,0])
      chamferedCube([width,length-((cableZoneLength != 0) ? 0 : wallthickness),height], chamfer);
    }
		
  union(){
	
		translate([wallthickness,((cableZoneLength != 0) ? 0 : -wallthickness),wallthickness])
		union(){
			
			//Power Zone
			translate([0,length-wallthickness*2-solderZoneLength-powerZoneLength,0])
				chamferedCube([width-wallthickness*2,powerZoneLength,height],chamfer);
				
			//Solder Zone
			translate([0,length-wallthickness-solderZoneLength,0])
				chamferedCube([width-wallthickness*2,solderZoneLength,height],chamfer);
			
			//Storage Zone
			storageZoneWidth = (type == "dual") ? 16 : width-tipOffset*3+wallthickness*1.5;
			translate([0,wallthickness*2+cableZoneLength,7])
				chamferedCube([storageZoneWidth-wallthickness*2,storageZoneLength,height],chamfer);
			
			//Cable Zone
			if (cableZoneLength != 0){
				translate([0,wallthickness,0])
					chamferedCube([width-wallthickness*2,cableZoneLength,height],chamfer);
				}
			}
			
		if (type == "dual"){
			translate([6,cableZoneLength-wallthickness/2,0])
			union(){
			
				//Tips Storage
				translate([width-(wallthickness*2+tipOffset),0,0])
					ironTips(tipSpacing);
				translate([wallthickness*2+tipOffset,0,0])
					ironTips(tipSpacing);
					
				//Soldering Irons
				translate([width/2,ironSpacing,wallthickness])
					cylinder(d=14.5, height);
				translate([width/2,ironSpacing*2+wallthickness,wallthickness])
					cylinder(d=14.5, height);
					
				}
			}
		else {
			a = cableZoneLength+tipOffset;
			b = length-wallthickness-solderZoneLength-powerZoneLength-tipOffset;
			c = width-(wallthickness*2+tipOffset);
			d = a + (b - a) / 2;
			translate([6,-wallthickness,0])
			union(){
				
				//Tips Storage
				translate([c,a,0])
				rotate([0,0,90])
					ironTips(0);
				translate([c,b,0])
				rotate([0,0,90])
					ironTips(0);
					
				//Soldering Irons
				translate([width-tipOffset*2,d,wallthickness])
					cylinder(d=14.5, height);
					
				}
			}
    }
  }
  
/**/