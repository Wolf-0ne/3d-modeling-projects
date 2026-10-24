padding=30;//
thickness=10;//

yAxisXspacing=100;//
yAxisYspacing=132.5;//141.3,123.2->132.25

zAxisXspacing=40;//
zAxisYspacing=90;//
zAxisYoffset=-10;//

width=yAxisXspacing+padding;//
height=yAxisYspacing+padding;//

leadScrewDiameter=8.45;//
leadScrewZ=7;//
leadScrewNeckDiameter=10.8;//
leadScrewNeckHeight=10.6;//
leadScrewNutDiameter=23;//
leadScrewNutHeight=5;//
leadScrewNutY=3;//

leadScrewRadius=leadScrewDiameter/2;//
leadScrewNeckRadius=leadScrewNeckDiameter/2;//
leadScrewNutRadius=leadScrewNutDiameter/2;//

$fn = 90;

module hexagon(size, height) {
  boxWidth = size/1.75;
  for (r = [-60, 0, 60])
    rotate([0,0,r])
      cube([boxWidth, size, height], true);
  }

module bore(x,y,r,z=500){
  translate([x,y,-z/2])
    cylinder(h=z, r=r);
  }
  
module bore4(x, y, r, z=500){
  translate([-x/2, -y/2, 0])
  union(){
    bore(0, 0, r, z);
    bore(x, 0, r, z);
    bore(0, y, r, z);
    bore(x, y, r, z);
    }
  }
  
module nema17(r){
  bore4(31, 31, r);
  }
  
module box(x,y,x2,y2,z){
  translate([x2,y2,z/2])
    cube([x,y,z], center=true);
  }
  
module cone(r, r2, h){
  hull(){      
    translate([0,0,0])
      cylinder(h=0.01,r=r);   
    translate([0,0,h])
      cylinder(h=0.01,r=r2);   
    }
  }
  
module MGN_Pattern(x,y,x2,y2,z=500,b=1.55){
    xa = (width-x)/2;
    ya = (height-y)/2;
    xb = width-xa;
    yb = height-ya;
    translate([xa,ya,0])
      bore4(x2, y2, b, z);
    translate([xa,yb,0])
      bore4(x2, y2, b, z);
    translate([xb,ya,0])
      bore4(x2, y2, b, z);
    translate([xb,yb,0])
      bore4(x2, y2, b, z);
  }
  
difference(){
  union(){
    
    //core
    hull(){
      translate([width/2-(zAxisXspacing+padding)/2,height/2-zAxisYspacing/2+zAxisYoffset-padding/2-1,0])
        cube([zAxisXspacing+padding, padding, thickness]);
      translate([width/2-(zAxisXspacing+padding)/2,height-padding-leadScrewNutY-leadScrewNutHeight,0])
        cube([zAxisXspacing+padding, padding, thickness]);
      }
      
    //bottom legs
    hull(){
      translate([0,0,0])
        cube([padding,padding,thickness]);
      box(padding,padding,width/2-zAxisXspacing/2,height/2-zAxisYspacing/2,thickness);
      }
    hull(){
      translate([width-padding,0,0])
        cube([padding,padding,thickness]);
      box(padding,padding,width/2+zAxisXspacing/2,height/2-zAxisYspacing/2,thickness);
      }
      
    //top legs
    hull(){
      translate([0,height-padding,0])
        cube([padding,padding,thickness]);
      box(padding,padding,width/2-zAxisXspacing/2,height/2+zAxisYspacing/2,thickness);
      }
    hull(){
      translate([width-padding,height-padding,0])
        cube([padding,padding,thickness]);
      box(padding,padding,width/2+zAxisXspacing/2,height/2+zAxisYspacing/2,thickness);
      }
      
    //lead screw wrapper
    translate([width/2,height/2-zAxisYspacing/2+zAxisYoffset-padding/2-1,leadScrewZ])
    rotate([270,0,0])
      cylinder(h=height,r=leadScrewRadius+2.5);
    
    //lead screw nut cone
    difference(){
      translate([width/2,height-leadScrewNutY,leadScrewZ])
      rotate([90,0,0])
        hull(){
          cylinder(r=leadScrewNutRadius+2,h=5);
          cylinder(r=thickness/2,h=25);
          }
      union(){
        translate([0,0,-thickness+0.01])      
          cube([width,height,thickness]);
        }
      }
    }
  union(){
    
    //Y Axis MGN Mounts
    MGN_Pattern(yAxisXspacing,yAxisYspacing,16,15);
    translate([0,0,thickness])
      MGN_Pattern(yAxisXspacing,yAxisYspacing,16,15,z=thickness,b=3);
    
    //Z Axis offset
    translate([0,zAxisYoffset,0])
    union(){
      spacing=padding-thickness/2;
      
      //Belt/Re-enforcement slots
      hull(){
        bore(width/2-zAxisXspacing/2,height/2+zAxisYspacing/2-spacing,2.55);
        bore(width/2-zAxisXspacing/2,height/2-zAxisYspacing/2+spacing,2.55);
        }
      hull(){
        bore(width/2+zAxisXspacing/2,height/2+zAxisYspacing/2-spacing,2.55);
        bore(width/2+zAxisXspacing/2,height/2-zAxisYspacing/2+spacing,2.55);
        }
      translate([0,0,thickness])
      union(){
        hull(){
          bore(width/2-zAxisXspacing/2,height/2+zAxisYspacing/2-spacing,5,thickness);
          bore(width/2-zAxisXspacing/2,height/2-zAxisYspacing/2+spacing,5,thickness);
          }
        hull(){
          bore(width/2+zAxisXspacing/2,height/2+zAxisYspacing/2-spacing,5,thickness);
          bore(width/2+zAxisXspacing/2,height/2-zAxisYspacing/2+spacing,5,thickness);
          }
        }
      
      //Z Axis MGN Mounts
      MGN_Pattern(zAxisXspacing,zAxisYspacing,15,16);
      translate([0,0,0])
        MGN_Pattern(zAxisXspacing,zAxisYspacing,15,16,z=thickness,b=3);
      }
    
    //Lead Screw Bore
    rotate([90,0,0])
      bore(width/2,leadScrewZ,leadScrewRadius);
    
    //Lead Screw Nut Recess  
    translate([width/2,height-leadScrewNutY-leadScrewNutHeight,leadScrewZ])
    rotate([270,0,0])
      cylinder(r=leadScrewNutRadius,h=40);
    
    //Lead Screw Nut Neck Recess  
    translate([width/2,height+leadScrewNeckHeight-leadScrewNeckHeight,leadScrewZ])
    rotate([90,0,0])
      cylinder(r=leadScrewNeckRadius,h=40);
      
    //Lead Screw Nut Bolt Pattern
    translate([width/2,height,leadScrewZ])
    rotate([90,45,0])
      bore4(11.5,11.5,1.3,30);
    }
  }
  
/*/
  
//Visualization of brass nut
color("yellow",0.4)
translate([width/2,height-leadScrewNutY,leadScrewZ])
rotate([90,0,0])
difference(){
  union(){
    cylinder(r=leadScrewNutRadius-0.25,h=5);
    translate([0,0,-3])
      cylinder(r=leadScrewNeckRadius-0.25,h=16);
    }
  union(){
    translate([0,0,-20])  
      cylinder(r=4,h=40);
    translate([width/2,height,leadScrewZ])
      rotate([90,45,0])
        bore4(11.5,1.3,90);
    }
  }
  
/**/