// CNC electronics panel set.
//
// Six printed panels and a separate joystick box. The panels are laid out for
// printing in `part = "panels"`; select a single part to export it on its own.
//
// The original archive source had the panel section commented out, so only the
// joystick was exported. The panel geometry below is recovered from that file.

$fn = 90;

/* [Part] */
part = "panels"; // [panels, front, back, top, bottom, left, right, joystick]

/* [Box] */
X = 130;          // front/back panel width
Y = 120;          // front/back panel height
Z = 4;            // panel thickness
chamfer = 4;
boreInset = 15;
sideTrim = 6;
sideX = 54;       // box depth / top and bottom panel depth

/* [Front panel] */
screenX = 79;
screenY = 52;
screenXOffset = -9.5;
screenYOffset = 4.5;

boltX = 88;
boltY = 65;

/* [Rear panel] */
controllerX = 96;
controllerY = 61.2;

/* [Top panel] */
fanBore = 19;          // 38 mm opening for a 40 mm fan
fanHoleSpacing = 32;
fanScrewRadius = 1.4;

module hexagon(size, height) {
  boxWidth = size/1.75;
  for (r = [-60, 0, 60])
    rotate([0, 0, r])
      cube([boxWidth, size, height], true);
}

module bore(x, y, r, z = 500) {
  translate([x, y, -z/2])
    cylinder(h = z, r = r);
}

module bore4(x, y, r, z = 500) {
  translate([-x/2, -y/2, 0])
    union() {
      bore(0, 0, r, z);
      bore(x, 0, r, z);
      bore(0, y, r, z);
      bore(x, y, r, z);
    }
}

module box(x, y, x2, y2, z) {
  translate([x2, y2, z/2])
    cube([x, y, z], center = true);
}

module chamferedBox(x, y, z, c) {
  hull() {
    box(x, y - c, 0, 0, z);
    box(x - c, y, 0, 0, z);
  }
}

module cylinder4(x, y, h, r) {
  x = x/2;
  y = y/2;
  union() {
    translate([x, y, 0])
      cylinder(r = r, h = h);
    translate([x, -y, 0])
      cylinder(r = r, h = h);
    translate([-x, y, 0])
      cylinder(r = r, h = h);
    translate([-x, -y, 0])
      cylinder(r = r, h = h);
  }
}

module hexagon4(x, y, h, r) {
  x = x/2;
  y = y/2;
  union() {
    translate([x, y, 0])
      hexagon(r, h);
    translate([x, -y, 0])
      hexagon(r, h);
    translate([-x, y, 0])
      hexagon(r, h);
    translate([-x, -y, 0])
      hexagon(r, h);
  }
}

module front_panel() {
  difference() {
    union() {
      hull() {
        chamferedBox(X, Y, Z/2, chamfer);
        chamferedBox(X - chamfer, Y - chamfer, Z, chamfer);
      }
      translate([screenXOffset, screenYOffset, -5])
        cylinder4(boltX, boltY, 6, 3);
    }
    union() {
      bore(X/2 - boreInset - 3, 0, 7.93);
      bore4(X - boreInset, Y - boreInset, 2.1);
      translate([0, 0, 2.5])
        cylinder4(X - boreInset, Y - boreInset, 6, 4);
      translate([0, 0, -18.5])
        difference() {
          box(X - 12, Y - 12, 0, 0, 20);
          translate([0, 0, -5])
            box(X - 17, Y - 17, 0, 0, 30);
        }
      translate([screenXOffset, screenYOffset, 0])
        union() {
          translate([0, 0, -10])
            box(screenX, screenY, 0, 0, 20);
          translate([0, 0, 3])
            hull() {
              box(screenX, screenY, 0, 0, 4);
              translate([0, 0, 4])
                box(screenX + chamfer, screenY + chamfer, 0, 0, 1);
            }
          translate([0, 0, -6])
            cylinder4(boltX, boltY, 6, 1.5);
          bore(36, -44, 4);
          bore(3, -43, 5);
          translate([0, 0, -1])
            box(screenX + 10, screenY, 0, 0, 3);
        }
    }
  }
}

module back_panel() {
  difference() {
    union() {
      hull() {
        translate([0, 0, Z/2])
          chamferedBox(X, Y, Z/2, chamfer);
        chamferedBox(X - chamfer, Y - chamfer, Z, chamfer);
      }
      translate([0, -5, 1])
        cylinder4(controllerX, controllerY, 7, 3);
    }
    union() {
      bore4(X - boreInset, Y - boreInset, 2.1);
      translate([0, 0, 0])
        hexagon4(X - boreInset, Y - boreInset, 3.5, 7.5);
      translate([0, 0, 2.5])
        difference() {
          box(X - 12, Y - 12, 0, 0, 20);
          translate([0, 0, -5])
            box(X - 17, Y - 17, 0, 0, 30);
        }
      translate([0, -5, 1])
        cylinder4(controllerX, controllerY, 22, 1.5);
    }
  }
}

module top_panel() {
  difference() {
    union() {
      box(X - boreInset - sideTrim, sideX + 3, 0, 0, 2);
      box(X - boreInset - sideTrim, sideX, 0, 0, 3);
    }
    union() {
      bore(0, 0, fanBore);
      bore4(fanHoleSpacing, fanHoleSpacing, fanScrewRadius);
    }
  }
}

module bottom_panel() {
  difference() {
    union() {
      box(X - boreInset - sideTrim, sideX + 3, 0, 0, 2);
      box(X - boreInset - sideTrim, sideX, 0, 0, 3);
    }
    union() {
      translate([0, 3, -2])
        box(X - boreInset*2, 3, 0, 0, 10);
      translate([0, 9, -2])
        box(X - boreInset*2.5, 3, 0, 0, 10);
      translate([0, 15, -2])
        box(X - boreInset*3, 3, 0, 0, 10);
      translate([0, 21, -2])
        box(X - boreInset*3, 3, 0, 0, 10);
      translate([0, -3, -2])
        box(X - boreInset*2, 3, 0, 0, 10);
      translate([0, -9, -2])
        box(X - boreInset*2.5, 3, 0, 0, 10);
      translate([0, -15, -2])
        box(X - boreInset*3, 3, 0, 0, 10);
      translate([0, -21, -2])
        box(X - boreInset*3, 3, 0, 0, 10);
    }
  }
}

module left_panel() {
  difference() {
    union() {
      box(sideX + 3, Y - boreInset - sideTrim, 0, 0, 2);
      box(sideX, Y - boreInset - sideTrim, 0, 0, 3);
    }
    union() {
      translate([(sideX/2) - 13, 15 - 23, -4])
        cube([4, 28, 10]);
      bore(-16, -2, 8);
    }
  }
}

module right_panel() {
  difference() {
    union() {
      box(sideX + 3, Y - boreInset - sideTrim, 0, 0, 2);
      box(sideX, Y - boreInset - sideTrim, 0, 0, 3);
    }
    union() {
      bore(13, 12, 7);
      bore(13, -12, 7);
    }
  }
}

module joystick() {
  difference() {
    union() {
      hull() {
        chamferedBox(84, 84, 40 - chamfer, chamfer);
        chamferedBox(84 - chamfer, 84 - chamfer, 40, chamfer);
      }
    }
    union() {
      bore(0, 0, 38.5/2);
      translate([0, 0, -chamfer])
        chamferedBox(84 - chamfer*4, 84 - chamfer*2, 40 + 1, chamfer);
      bore4(32.5, 32.5, 1.75);
      bore(29, 29, 3.25);
      translate([0, 0, -chamfer])
        cylinder4(76, 65, 15, 1.5);
      translate([0, 60, 10])
        rotate([90, 0, 0])
          cylinder(r = 5, h = 80);
    }
  }
}

// Print layout: front at the origin, remaining panels spaced around it.
module panels_layout() {
  front_panel();
  translate([0, 0, -sideX - chamfer])
    back_panel();
  translate([0, 70, -sideX/2])
    rotate([-90, 0, 0])
      top_panel();
  translate([0, -70, -sideX/2])
    rotate([90, 0, 0])
      bottom_panel();
  translate([-80, 0, -sideX/2])
    rotate([0, -90, 0])
      left_panel();
  translate([80, 0, -sideX/2])
    rotate([0, 90, 0])
      right_panel();
}

if (part == "panels") {
  panels_layout();
} else if (part == "front") {
  front_panel();
} else if (part == "back") {
  back_panel();
} else if (part == "top") {
  top_panel();
} else if (part == "bottom") {
  bottom_panel();
} else if (part == "left") {
  left_panel();
} else if (part == "right") {
  right_panel();
} else if (part == "joystick") {
  joystick();
} else {
  assert(false, str("unknown part: ", part));
}
