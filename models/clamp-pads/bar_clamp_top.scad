
$fn = 100;

cylinderOffset = 7;
totalWidth = 27;

totalHeight = 10;
baseThickness = 4;

wallThickness = 3;
footHeight = 3.6;
topWallThickness = 5;
y = totalWidth;

difference(){
  intersection(){
    intersection(){
      translate([cylinderOffset,0,0])
        cylinder(r=totalWidth, h=totalHeight);
      translate([-y,-(totalWidth/2),0])
        cube([y*2,totalWidth,totalHeight]);
      }
    intersection(){
      translate([-cylinderOffset,0,0])
        cylinder(r=y, h=totalHeight);
      translate([-y,-(totalWidth/2),0])
        cube([y*2,totalWidth,totalHeight]);
      }
    }
  union(){
    intersection(){
      translate([cylinderOffset,0,baseThickness])
        cylinder(r=totalWidth-wallThickness+1, h=footHeight);
      translate([-y,-((totalWidth-(wallThickness*2))/2),baseThickness])
        cube([y*2,totalWidth-(wallThickness*2),footHeight]);
      }
    intersection(){
      translate([cylinderOffset,0,baseThickness+(footHeight/2)])
        cylinder(r=totalWidth-topWallThickness+1, h=totalHeight);
      translate([-y,-((totalWidth-(topWallThickness*2))/2),baseThickness+(footHeight/2)])
        cube([y*2,totalWidth-(topWallThickness*2),totalHeight]);
      }
    }
  }