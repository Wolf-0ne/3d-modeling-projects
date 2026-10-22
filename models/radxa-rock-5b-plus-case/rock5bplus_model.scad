// Written by WolfOne <https://github.com/Wolf-0ne/3d-modeling-projects>
// License - CC BY 4.0 Attribution

/* Features toggle as needed (0/1) */

	body = 1;				// show body
	lid = 1;				// show lid
	pcb = 0;				// show pcb
	sma = 0;				// [0,2,4] top antenna mounts
	modemMount = 0;			// upper modem mount
	less_fans = 0;			// reduce fan mounts
	shrink = 0;				// remove fan space on top
	fan_25mm = 0;			// reduce z for 25mm fans instead of default 30mm
	badge = 1;

/* Parameters */

	$fn = 50;

	// rock pi dimensions ( not exact, but it works )

	boardx = 74;
	boardy = 100;
	boardholex = 49;
	boardholey = 93.7;

	// board hole radius

	boardholer = 1.15;
	boardholeouterr = 2.3; // support radius

	// offsets from center of model
	// all port positions relative to board
	// all post positions relative to board

	boardoffsetx = -0.2 + 1.5;
	boardoffsety = shrink == 1 ? 5 : 0;
	boardoffsetz = fan_25mm == 0 ? 2.75 : 2.25; // 3.5
	boardholeoffsetx = 8.75;
	boardholeoffsety = 0;

	// distance between side wall and board

	xOffset = 15;
	yOffset = shrink == 1 ? 9 : 14;

	// box walls

	wallThickness = 3.6;
	bottomThickness = 3.5; // bottom
	lidThickness = 4;

	// box solid border

	border = 8.4;
	borderFill = 7;

	// box inner height

	height = (fan_25mm == 0 ? 30 : 25) - 2.5; // 1.25mm inset on top and bottom

	// box inner x/y

	x = boardx + xOffset * 2;
	y = boardy + yOffset * 2;

	// top bolt pattern

	boltInset = 2.5;
	boltRadius = 3.5;

	boltX = x / 2 - boltInset; //-8
	boltY = y / 2 - boltInset;

	boltAvoid = boltRadius + boltInset;

	/* port x or y offsets from center of board */

	micY = 44.3 + boardoffsety;
	usbcWY = 35.6 + boardoffsety;
	usb2Y = -11.5 + boardoffsety;
	usb3Y = -30.5 + boardoffsety;
	ethY = -48.6 + boardoffsety;

	usbcEY = -22.5 + boardoffsety;

	hdmiSX = -4.5 + boardoffsetx;

	/* port Z offsets from bottom of board */

	micZ = 4 + boardoffsetz;
	usbcWZ = 3 + boardoffsetz;
	usb2Z = -0.0 + boardoffsetz;
	usb3Z = -0.0 + boardoffsetz;

	usbcEZ = 4.4 + boardoffsetz;

	hdmiSZ = -3.5 + boardoffsetz;

/* Objects */

if (body == 1) body();
if (pcb == 1) pcb();
if (lid == 1) color([ 0.3, 0.7, 0.5 ]) lid();

/* Body */

module body()
{

	h = height;

	hot = height / 2;
	
	bt = bottomThickness;
	wt = wallThickness;
	
	bottomGridWall = 2.2;
	bottomGridHex = 7;
	
	sideGridWall = 2.4;
	sideGridHex = 6.28;
	sideGridOffsetZ = height / 2 - .875;
	sideGridHeight = height + 1.75;
	sideGridHexOffsetZ = fan_25mm == 0 ? 6.85 : 4.4;
	
	module sideGrid(sx, sy, x_offset = 0)
	{
			width = abs(sx) > x / 2 ? 
				(sx < 0 ? y / 2 + 2 + boardoffsety : y)
				: x;
			translate([ sx, sy, sideGridOffsetZ ]) 
			rotate([ 0, 0, abs(sx) > x / 2 ? 90 : 0 ])
			rotate([ 90, 0, 0 ])
			create_grid([ width, sideGridHeight, wt ], 
				sideGridHex, 
				sideGridWall, 
				0.05, 
				1, 
				sideGridHexOffsetZ, 
				-sideGridWall,
				x_offset = x_offset);
	}
	
	corner = 5.2; // blocked out corners
	module sideFill(sx, sy)
	{
			xw = abs(sx) > x / 2 ? wt : corner;
			yw = abs(sx) > x / 2 ? corner : wt;
			translate([ sx, sy, hot ]) 
			cube([ xw, yw, height ], center = true);
	}

	// body
	difference()
	{
		// positive
		union()
		{
			/* main body */

			translate([ 0, 0, bottomThickness / 2 ]) 
			union()
			{
				plate(x, y, bottomThickness, border, bottomGridHex, bottomGridWall, 0);


				// sim / nvme area support
				if (shrink == 0)
				{
					translate([ 32.25, -40, 0 ]) 
					cube([ 7.5, 32, bottomThickness ], center = true);

					translate([ 16.0, -40, 0 ]) 
					cube([ 7, 32, bottomThickness ], center = true);
				}
				else
				{
					translate([ 21.2, -47, 0 ]) 
					cube([ 30, 10, bottomThickness ], center = true);

					translate([ 33.5, -31, 0 ]) 
					cube([ 5, 10, bottomThickness ], center = true);
				}

				// eth slot (w) support
				translate([ -boardx / 2 - 25, -boardy / 2 + boardoffsety + 2 - wt, -bottomThickness / 2 ])
				intersection()
				{
					translate([ 0, 8 + wt, 0 ]) 
					cylinder(h = bottomThickness, r = 20 + wt);

					translate([ 10, 0, 0 ]) 
					cube([ 14, 16 + wt * 2, 32 ]);
				}

				// m.2 nvme slot outer wrappers
				translate([ 0, 0, 0 ]) 
				pcb_m2(wt * .8, bottomThickness, -bottomThickness / 2);

				// board mount posts
				translate([ 0, 0, 0 - bottomThickness / 2 ])
				translate([ boardholeoffsetx + boardoffsetx, boardholeoffsety + boardoffsety, 0 ]) 
				union()
				{
					bore4(boardholex, boardholey, 4.5, bottomThickness, z = 0);

					bore4(boardholex, boardholey, 4.5, boardoffsetz, boardholeouterr, bottomThickness);

					// posts only on one side
					translate([ boardholex / 2, boardholey / 2, bottomThickness ])
						cylinder(h = boardoffsetz + 3, r = boardholer);

					translate([ -boardholex / 2, -boardholey / 2, bottomThickness ])
						cylinder(h = boardoffsetz + 3, r = boardholer);

					bore(boardholex / 2, -boardholey / 2 + 35, 4.5, bottomThickness, z = 0);

					bore(boardholex / 2, -boardholey / 2 + 35, 4.5, boardoffsetz, boardholeouterr, bottomThickness);

					translate([ boardholex / 2, -boardholey / 2 + 35, bottomThickness ])
						cylinder(h = boardoffsetz + 3, r = boardholer);
				}

				// eth support
				translate([ boardoffsetx, boardoffsety, -bottomThickness / 2 ])
					bore(-boardx / 2, -boardy / 2 + 23, 2.5, boardoffsetz - .2, 1.5, bottomThickness);
			}

			/* walls */

			translate([ 0, 0, bottomThickness ]) 
			union()
			{
				/* north */

				nsX = x / 2 - corner / 2;
				nsY = y / 2 + wt / 2;

				sideGrid(0, nsY);
				
				sideFill(-nsX, nsY);
				sideFill(nsX, nsY);
				
				/* south */
				
				sideGrid(0, -nsY);
				
				sideFill(-nsX, -nsY);
				sideFill(nsX, -nsY);

				// hdmi fill in above
				if (fan_25mm == 0)
				{
					translate([ -17, -y / 2 - wt, 0 ]) 
					cube([ 25, wt, 18 ]);
				}
				else
				{
					translate([ -15.2, -y / 2 - wt, 0 ]) 
					cube([ 25, wt, h ]);
				}

				/* east */

				ewX = x / 2 + wt / 2;
				ewY = y / 2 - corner / 2;
				ewOffset = (sideGridHex + sideGridWall) / 2 - .2;

				sideGrid(ewX, 0, ewOffset);

				sideFill(ewX, -ewY);
				sideFill(ewX, ewY);

				// usb-c port (e)
				translate([ x / 2 - wt, -boardy / 2 + 27.5 + boardoffsety, usbcEZ ]) 
				hull()
				{
					usbc_center = 6.5;
					usbc_or = 3.55;
					translate([ -wt/2, 0, 0 ]) 
					rotate([ 0, 90, 0 ]) 
					hull()
					{
						cylinder(h = 1, r = usbc_or + 1);

						translate([ 0, usbc_center, 0 ]) 
						cylinder(h = 1, r = usbc_or + 1);
					}

					translate([ wt, 0, 0 ]) 
					rotate([ 0, 90, 0 ]) 
					hull()
					{
						cylinder(h = wt, r = usbc_or + wt);

						translate([ 0, usbc_center, 0 ]) 
						cylinder(h = wt, r = usbc_or + wt);
					}

					translate([ wt, -usbc_or - wt, -usbcEZ - .1 ]) 
					cube([ wt, (usbc_or + wt) * 2 + usbc_center, 1 ]);
					
					translate([ -wt/2, -wt/2, -usbcEZ - .1 ]) 
					cube([ wt, usbc_center + wt, 1 ]);
				}

				/* west */

				sideGrid(-ewX, y / 4 - 2 - boardoffsety / 2, 
					ewOffset);

				sideFill(-ewX, ewY);

				/*extra size around ports*/

				// mic port (w)
				translate([ -x / 2 - wt, micY, micZ ]) 
				union()
				{
					rotate([ 0, 90, 0 ]) 
					cylinder(h = wt, r = 4.5 + wt / 2 + .5 + 
						(shrink == 0 && fan_25mm == 1 ? 1 : 0));

					if (fan_25mm == 0)
					{
						translate([ 0, -6, -micZ - .1 ]) 
						cube([ wt, 5, 18 ]);
					}
					else
					{
						translate([ 0, -16, -micZ - .1 ]) 
						cube([ wt, 16, 5 ]);
					}

					translate([ 0, 0, -micZ - .1 ]) 
					cube([ wt, 6, 3 ]);
				}

				// beefier usb-c
				translate([ -x / 2, usbcWY, usbcWZ ]) 
				usbcWest();

				// usb/eth (w)
				translate([ -x / 2 - wt, -y / 2, 0 ])
					cube([ wt * 2.25, (shrink == 0 ? 76 : 75.5), height ]); 
					// reduced for more room to route cables internally

				/* special features */

				// pins to interlock top/bottom
				pins(0);

				// bolt hole pillars
				boltHoles(h = height, r = boltRadius);

				// corners
				translate([ 0, 0, height / 2 ]) 
				difference()
				{
					hull()
					{
						cube([ x + wt * 2, y, height ], center = true);
						cube([ x, y + wt * 2, height ], center = true);
					}
					union()
					{
						cube([ x * 2, y, height * 2 ], center = true);
						cube([ x, y * 2, height * 2 ], center = true);
					}
				}

				// wings to lock in hdmi
				translate([ hdmiSX, -y / 2 + wt, 6 ]) 
				union()
				{
					r = 10.25;
					baseWidth = 1.8;
					interference = 0.6;
					h = 16;
					verticalOffset = 2.2;
					wingLength = 8;
					translate([ r + baseWidth / 2, 0, 0 ]) 
					hull()
					{
						cube([ baseWidth, .01, h ], center = true);

						translate([ -baseWidth / 2, wingLength, verticalOffset ])
							cube([ interference * 2, 1, h / 2 ], center = true);
					}
					translate([ -r - baseWidth / 2, 0, 0 ]) 
					hull()
					{
						cube([ baseWidth, .01, h ], center = true);

						translate([ baseWidth / 2, wingLength, verticalOffset ])
							cube([ interference * 2, 1, h / 2 ], center = true);
					}
				}
			}
			
			// sma mounts
			smaMounts(0);
							
			// fill extra hexes
			hexfill = bottomGridHex + bottomGridWall;
			if (shrink == 1)
			{
				translate([x/2-border-12,y/2-border-1,0])
				cylinder(h = bt, d = 9);
				
				translate([x/2-border-12,-4.5,0])
				cylinder(h = bt, d = 9);
				
				translate([-16,y/2-border-1,0])
				cylinder(h = bt, d = 9);
				
				translate([-16,-y/2+border+10,0])
				cylinder(h = bt, d = 9);
				
				translate([0,-y/2+border+10,0])
				cylinder(h = bt, d = 9);
			}
			
			fillhex(10, -40, 28, bottomThickness, hexfill);
			fillhex(10, -40, -28, bottomThickness, hexfill);

		}

		// negative
		union()
		{
		
			diffX = -x / 2 - wt * 2;

			// ports
			translate([ 0, 0, bottomThickness ]) 
			union()
			{
				// usb-c port (e)
				translate([ x / 2 - 10, usbcEY, usbcEZ ]) 
				hull()
				{
					rotate([ 0, 90, 0 ]) 
					cylinder(h = 20, r = 3.57);

					translate([ 0, 6.5, 0 ]) 
					rotate([ 0, 90, 0 ]) 
					cylinder(h = 20, r = 3.57);
				}

				// mic port (w) (oblong because print droops a bit)
				micr = 4.12;
				translate([ diffX - .1, micY, micZ ]) 
				rotate([ 0, 90, 0 ]) 
				hull()
				{
					translate([ -.3, 0, 0 ]) 
					cylinder(h = wt * 4, r = micr);

					translate([ .3, 0, 0 ]) 
					cylinder(h = wt * 4, r = micr);
				}

				// usb-c port (w)
				translate([ diffX - .1, usbcWY, usbcWZ ]) 
				rotate([ 0, 90, 0 ]) 
				hull()
				{
					cylinder(h = wt * 2 + .2, r = 3.44);

					translate([ -6.5, 0, 0 ]) 
					cylinder(h = wt * 2 + .2, r = 3.44);
				}

				// usb 2.0 (w)
				translate([ diffX, usb2Y, usb2Z ]) 
				union()
				{
					cube([ wt * 3, 17.5, 18.5 ]);

					translate([ wt * 2, 0, 0 ]) 
					hull()
					{
						cube([ wt * 2, 17.5, 18.5 ]);

						translate([ wt, 0, wt ]) 
						cube([ wt * 2, 17.5, 18.5 ]);
					}
				}

				// usb 3.0 (w)
				translate([ diffX, usb3Y, usb3Z ]) 
				union()
				{
					cube([ wt * 3, 17.5, 18.5 ]);
					translate([ wt * 2, 0, 0 ]) 
					hull()
					{
						cube([ wt * 2, 17.5, 18.5 ]);

						translate([ wt, 0, wt ]) 
						cube([ wt * 2, 17.5, 18.5 ]);
					}
				}

				// eth (w)
				translate([ -boardx / 2 - 24, ethY, -bottomThickness - 4 ]) 
				union()
				{
					intersection()
					{
						translate([ 0, 7.5, 0 ]) 
						cylinder(h = 24, r = 20);

						cube([ 80, 16, 32 ]);
					}
					translate([ wt * 2 - (-boardx / 2 - 25) + diffX, 0, 8 ]) 
					hull()
					{
						cube([ wt * 2, 16, 16 ]);

						translate([ wt, 0, wt ]) 
						cube([ wt * 2, 16, 16 ]);
					}
				}
			}

			/* fans */
			fans(2);
			
			// sma mounts
			smaMounts(1);

			// top mounts
			boltHoles(h = height, r = 1.44, z = height - 3);

			// pcb cutout
			pcb_m2(wall = .5, h = 20, z = -1);

			// m.2 nvme post clearance
			translate([
				boardholex / 2 + boardoffsetx + boardholeoffsetx, 
				boardholey / 2 + boardholeoffsety + boardoffsety,
				0
			]) translate([ 0, +1, bottomThickness / 2 ]) 
			union()
			{
				translate([ -13, 0, 0 ]) 
				cylinder(h = 4, r = 3.5);

				translate([ -36, 0, 0 ]) 
				cylinder(h = 4, r = 3.5);
			}

			// screw holes on one side
			translate([
				boardholex / 2 + boardoffsetx + boardholeoffsetx, 
				-boardholey / 2 + boardholeoffsety + boardoffsety,
				-2
			]) cylinder(h = 50, r = boardholer);

			translate([
				-boardholex / 2 + boardoffsetx + boardholeoffsetx, 
				boardholey / 2 + boardholeoffsety + boardoffsety,
				-2
			]) cylinder(h = 50, r = boardholer);

			// capacitor? clearance
			translate([ 0, 0, bottomThickness ]) 
			cube([ 36, 34.6, bottomThickness ], center = true);

		}
	}
}

// usb-c surround structure
module usbcWest()
{
	wt = wallThickness;
	union()
	{
	
		// surround
		translate([ -wt * 1.5, 0, 0 ]) 
		rotate([ 0, 90, 0 ]) 
		difference(){
			hull()
			{
				cylinder(h = wt * 2, r = 5);

				translate([ -6.5, 0, 0 ]) 
				cylinder(h = wt, r = 5);

				translate([ 0.5, 0, wt / 2 ]) 
				union()
				{
					cylinder(h = wt, r = 6.5);

					translate([ -6.5 - .55, 0, 0 ]) //elongated for easier print angle on bottom
					cylinder(h = wt, r = 6.5);
				}
				
				// support bottom
				translate([3,0,5])
				cube([5,9,6], center = true);
			}
			translate([ 0, 0, -1 ]) 
			hull()
			{
				cylinder(h = wt * 10, r = 3.44);

				translate([ -6.5, 0, 0 ]) 
				cylinder(h = wt * 10, r = 3.44);
			}
		}

		// wings to lock in
		translate([ 0, 0, 1 ]) 
		union()
		{
			r = 3.44;
			baseWidth = 2;
			interference = 0.5;
			h = 16;
			verticalOffset = 2.2;
			wingLength = 6;
			translate([ 0, r + baseWidth / 2, 0 ]) 
			hull()
			{
				cube([ 2, baseWidth, h ], center = true);
				translate([ wingLength, -baseWidth / 2, verticalOffset ])
				cube([ 1, interference * 2, h / 2 ], center = true);
			}
			translate([ 0, -r - baseWidth / 2, 0 ]) 
			hull()
			{
				cube([ 2, baseWidth, h ], center = true);
				translate([ wingLength, baseWidth / 2, verticalOffset ])
				cube([ 1, interference * 2, h / 2 ], center = true);
			}
		}
	}
}

/* PCB */

// pcb ( for visualization )
module pcb()
{
	radius = 3;
	color([ 0.2, 0.5, 0.2, 0.5 ]) 
	translate([ 0, boardoffsety, bottomThickness + .1 ]) 
	union()
	{
		difference()
		{
			translate([ boardoffsetx, 0, boardoffsetz ]) 
			hull()
			{
				bore4(boardx - radius * 2, boardy - radius * 2, radius, radius, z = 0);
			}
			translate([ boardholeoffsetx + boardoffsetx, boardholeoffsety, 0 ])
			bore4(boardholex, boardholey, 1.5, boardoffsetz + 3, z = bottomThickness);
		}
		pcb_m2();
	}
}

// nvme m.2 slot + sim + sdcard ( visualization or cutout )
module pcb_m2(wall = 0, h, z)
{
	// 7 from bottom
	// 11 from right
	pcbx = 45 + wall * 2;
	pcby = 7.5 + wall * 2;
	pcbz = (h != undef ? h : 0.5);

	simx = 19 + wall * 2;
	simy = 15 + wall * 2;

	sdx = 14 + wall * 3;
	sdy = 60;
	sdr = 22 + wall * 1.5;
	sdz = (h != undef ? (h > bottomThickness ? bottomThickness + 5 : h) : 0);

	translate([ boardoffsetx, boardoffsety, 0 ])
	translate([ -boardx / 2, -boardy / 2, (z != undef ? z : boardoffsetz - pcbz / 2) ]) 
	union()
	{
		// pcb
		translate([ 23 - wall, 14.5 - wall, 0 ]) 
		difference()
		{
			cube([ pcbx, pcby, pcbz + 1 ]);
			translate([ 0, 0, pcbz ]) 
			cylinder(h=2, r=4);
		}

		// sim
		translate([ 48 - wall, -wall, 0 ]) 
		cube([ simx, simy, pcbz + 2 ]);

		// sd card
		translate([ 32.5, -sdr + 2, 0 ]) 
		difference()
		{
			// finger hole
			translate([ 0, wall * 1.5, 0 ]) 
			intersection()
			{
				cylinder(h = sdz + 1, r = sdr);
				translate([ -sdx / 2, -sdy / 2, 0 ]) 
				cube([ sdx, sdy, sdz * 2 ]);
			}

			// trim any beyond edge of the model
			trim = (wall > 1 ? -((boardy / 2 + border / 2 - 2) - y / 2) + boardoffsety : 0);
			translate([ -50, trim - 50, -pcbz / 2 ]) 
			cube([ 100, 50, sdz * 2 ]);
		}

		// hdmi
		if (!(wall == 0))
		{
			w = wallThickness;
			translate([
				32.5 - 9.4 - wall * 1.2, 
				-(y / 2 - boardy / 2) - boardoffsety - w - (wall > 1 ? 0 : wall * 1),
				bottomThickness + 5.2 - wall * 2
			]) cube([ 18.8 + wall * 2.4, (wall > 1 ? w * 2 : 8), 9.3 + wall * 2.6 ]);
		}
	}
}

/* Lid */

module lid()
{

	modemAX = 24;
	modemAY = -51;
	
	simX = -2.5;

	translate([ 0, 0, lidThickness / 2 + height + bottomThickness + .2 ]) 
	difference()
	{
		union()
		{
			// sma mounts
			smaMounts(2);

			// main body
			plate(x, y, lidThickness, border, 7, 2.2, 1);

			// re-enforcing filled hexes
			translate([0, 0, -lidThickness/2])
			union()
			{
				fillhex(10, -40, 28, lidThickness, 7 + 2.2);
				fillhex(10, -40, -28, lidThickness, 7 + 2.2);
			}
			
			// modem mounting
			if (modemMount == 1)
			{
				// modem mounting
				translate([ modemAX, modemAY + boardoffsety, 0 ]) 
				modem(1);
								
				// fill extra hexes (shrink)
				if (shrink == 1)
				{
					translate([x/2-border-4,-18,-lidThickness/2])
					cylinder(h = lidThickness, d = 9);
					
					translate([x/2-border-12,32,-lidThickness/2])
					cylinder(h = lidThickness, d = 9);
					
					translate([x/2-border-28,32,-lidThickness/2])
					cylinder(h = lidThickness, d = 9);
				}

				// block out top
				cube([ 25, 55, lidThickness ], center = true);

				// sim slot
				simy = 14.25;
				translate([ simX + 2, 5 + boardoffsety, 0 ]) 
				union()
				{
					r = 45;

					wallHeight = 20;
					sphereZ = 6.3;

					// sides
					translate([ -1.125, 0, 0 ]) 
					intersection()
					{
						translate([ 0, 0, -wallHeight / 2 ]) 
						difference()
						{
							cube([ 21.75, 30.5, wallHeight ], center = true);

							translate([ 2, 0, 0 ]) 
							cube([ 21.75, 26.5, wallHeight * 2 ], center = true);
						}

						translate([ 0, 0, -lidThickness - sphereZ ]) 
						translate([ 0, 0, r - 1.5 ]) 
						sphere(r = r - 1);
					}

					// top arched hex grid
					translate([ -1.125, 0, -lidThickness - sphereZ ]) 
					intersection()
					{
						create_grid([ 21.75, 30.5, 10 ], 5.5, 1.35, 3, 1, 0);
						translate([ 0, 0, r - 1.5 ]) 
						difference()
						{
							sphere(r = r);
							sphere(r = r - 1.6);
						}
					}
				}
			}
			
			// block out top for badge
			if (badge == 1){
				translate([ simX + 2, 5, 0 ]) 
				translate([ -36.2, -5, 0 ])
					cube([ 18, 55, lidThickness ], center = true);
				translate([-x/2+border+20,18,-lidThickness/2])
					cylinder(h = lidThickness, d = 9);
				}
		}
		union()
		{
			// fans
			fans(-30.3 - lidThickness / 2 + 1.4);

			// overcomplicated hatred for default font kerning
			if (badge == 1)
			{
				#translate([ -27, 28, lidThickness / 4 ]) 
				rotate([ 0, 0, -90 ])
				byWolfOne(2);
			}

			if (modemMount == 1)
			{
				// modem cutouts
				translate([ modemAX, modemAY + boardoffsety, 0 ]) 
				modem(0);

				// sim slot
				translate([ simX + 2, 5 + boardoffsety, 0 ]) 
				cube([ 20, 26.5, lidThickness * 2 ], center = true);
			}

			// screw holes
			boltHoles(h = 50, r = 1.61, z = -5);

			rotate([ 0, 0, 180 ]) 
			rotate([ 0, 180, 0 ]) 
			boltHoles(h = 2.35, r = 3.2, r2 = 1.61, z = -2.3);

			/* port markers */

			// west
			translate([ -x / 2 + boltInset, 0, 1 ])
			{
				translate([ 0, micY, 0 ]) 
				cylinder(h = lidThickness, r = 1);

				translate([ 0, usbcWY, 0 ]) 
				cylinder(h = lidThickness, r = 1);

				translate([ 0, usb2Y + 18 / 2, 0 ]) 
				cylinder(h = lidThickness, r = 1);

				translate([ 0, usb3Y + 18 / 2, 0 ]) 
				cylinder(h = lidThickness, r = 1);

				translate([ 0, ethY + 17 / 2, 0 ]) 
				cylinder(h = lidThickness, r = 1);
			}

			// east
			translate([ x / 2 - boltInset, 0, 1 ])
			{
				translate([ 0, usbcEY, 0 ]) 
				cylinder(h = lidThickness, r = 1);
			}

			// south
			translate([ 0, -y / 2 + boltInset, 1 ])
			{
				translate([ hdmiSX, 0, 0 ]) 
				cylinder(h = lidThickness, r = 1);
			}

			// pins
			translate([ 0, 0, -lidThickness ]) 
			pins(1);
		}
	}
}

// modem
module modem(mount = 0)
{
	modemw = 35;

	// modem cutout
	if (mount == 0)
	{
		translate([ -modemw / 2, 23, -lidThickness / 2 - 1.2 ]) 
		union()
		{
			// modem screw slot
			translate([ 0, 2.625, -1 ]) 
			difference()
			{
				cube([ modemw, .75, 4 ]);

				translate([ (modemw - 16) / 2, -1, -1 ]) 
				cube([ 16, 10, 10 ]); // only needed on sides
			}

			translate([ 0, 64, -3.5 ]) 
			union()
			{
				translate([ modemw / 2, -80 / 2 + 9 + 7, 2.75 ]) 
				union()
				{
					// modem
					hull()
					{
						cube([ 31.5, 80, 1.35 ], center = true);

						translate([ 0, 0, -1 ]) 
						cube([ 27.5, 80, 1.8 ], center = true);
					}
					translate([ 0, 0, -2 ]) 
					cube([ 28, 80, 4 ], center = true);

					// usb
					translate([ 0, -57, 0 ]) 
					cube([ 20, 34, 8.1 ], center = true);
				}
			}
		}
	}

	// modem mounting
	if (mount != 0)
	{
		translate([ -modemw / 2, 23, -lidThickness / 2 - 1.2 ]) union()
		{
			// bars
			difference()
			{
				cube([ modemw, 6, lidThickness + 1 ]);

				translate([ (modemw - 16) / 2, -1, -1 ]) 
				cube([ 16, 10, 10 ]); // so soldered usb tabs don't conflict
			}

			// slots
			translate([ 0, 51, -4 ]) // 64mm should not block any sim slots
				union()
			{
				hull()
				{
					translate([ 0, 0, 2 ]) 
					cube([ modemw, 5, lidThickness + 3 ]);

					translate([ 3, 0, 0 ]) 
					cube([ modemw - 6, 5, 5 ]);
				}
			}
		}
	}
}

/* Shared Modules */

// fans
module fans(offset = 0)
{
	union()
	{
		//the math here is to avoid the fans overlapping 
		//changing the external dimensions will break it
		
		//clearance
		c = 0.01;
		
		//fan size 3010 or 2510
		fanX = (fan_25mm == 0 ? 30 : 25) - 0.3;
		fanY = 10.5 - c;
		fanZ = fanX + 0.3;
		
		//spacing/overlap avoidance
		fanGap = 1.5;
		fanCornerGap = fanY - boltAvoid + fanGap;
		
		//north/south positions
		nsX = x / 2 - boltAvoid;
		nsY = y / 2 - c;

		if (shrink == 0 && less_fans == 0)
		{
			// fan n1 (n)
			translate([nsX - fanX, nsY - fanY, offset ]) 
			cube([ fanX, fanY, fanZ ]);

			// fan n2 (n)
			translate([ -fanX/2, nsY - fanY, offset ]) 
			cube([ fanX, fanY, fanZ ]);

			// fan n3 (n)
			translate([ -nsX, nsY - fanY, offset ]) 
			cube([ fanX, fanY, fanZ ]);
		}
		
		// fan s1 (s)
		translate([ nsX - fanX - fanCornerGap, -nsY + c * 2, offset ]) 
		cube([ fanX, fanY, fanZ ]);

		//east/west positions
		ewX = x / 2 - fanY - c;
		ewY = y / 2 - boltAvoid;
		ewUpperY = ewY - fanX - (shrink == 0 ? fanCornerGap: 0);
		
		// fan e1 (e)
		translate([ ewX, ewUpperY, offset ]) 
		cube([ fanY, fanX, fanZ ]);

		// fan e2 (e)
		if (less_fans == 0)
		{
			translate([ ewX, ewUpperY - fanGap - fanX, offset ])
			cube([ fanY, fanX, fanZ ]);
		}

		// fan e3 (e)
		translate([ ewX, -ewY, offset ]) 
		cube([ fanY, fanX, fanZ ]);
	}
}

// sma connectors
module smaMounts(top)
{
	if (sma > 0)
	{
		translate([ -x / 2 + 30.87, -y / 2 - wallThickness, 0 ]) 
		smaMount(top);

		translate([ -x / 2 + 13.92, -y / 2 - wallThickness, 0 ]) 
		smaMount(top);
		
		if (sma == 4)
		{
			translate([ -x / 2 - wallThickness, 21.6, 0 ]) 
			rotate([ 0, 0, 270 ]) 
			smaMount(top);

			translate([ -x / 2 - wallThickness, y / 2 - 17.1, 0 ]) 
			rotate([ 0, 0, 270 ]) 
			smaMount(top);
		}
	}
}

// sma connector mount (positive,negative,walls)
module smaMount(top)
{
	smaOR = 5.9;
	smaOD = smaOR * 2;

	if (top == 2)
	{
		translate([ 0, 0, -6.8 ]) 
		union()
		{
			smaHex = 8;
			smaIR = (smaHex + 1.7) / 2; //should just use sqrt(3) to change to across faces
			smaY = wallThickness * 2;

			difference()
			{
				union()
				{
					translate([ -smaOR, 0, 0 ]) 
					cube([ smaOD, smaY, smaOR ]);

					translate([ 0, smaY, 0 ]) 
					rotate([ 90, 0, 0 ]) 
					cylinder(h = smaY, r = smaOR);
				}
				union()
				{
					translate([ 0, smaY * 2, 0 ]) 
					rotate([ 90, 0, 0 ]) 
					cylinder(h = smaY * 3, r = 3.35);

					translate([ 0, smaY + 1, 0 ]) 
					rotate([ 90, 0, 0 ]) 
					rotate([ 0, 0, 90 ])
					cylinder(h = 4.4, r = smaIR, $fn = 6);

					translate([ 0, +.4, 0 ]) 
					rotate([ 90, 0, 0 ]) 
					cylinder(h = 2, r = smaOR - 1.1);
				}
			}
		}
	}
	else if (top == 1)
	{
		clearance = .13;
		c = clearance;

		smaY = wallThickness * 3;

		translate([ 0, -wallThickness / 2, height - 1.18 ]) 
		union()
		{
			translate([ -smaOR - c, 0, 0 ]) 
			cube([ smaOD + c * 2, smaY, smaOR + c ]);

			translate([ 0, smaY, 0 ]) 
			rotate([ 90, 0, 0 ]) 
			cylinder(h = smaY, r = smaOR + c);
		}
	}
	else
	{
		clearance = 2.5;
		c = clearance;

		smaY = wallThickness;

		translate([ 0, 0, height - 1.18 ]) 
		union()
		{
			translate([ -smaOR - c, 0, -c / 2 ]) 
			cube([ smaOD + c * 2, smaY, smaOR - c ]);

			translate([ 0, smaY, 0 ]) 
			rotate([ 90, 0, 0 ]) 
			difference()
			{
				cylinder(h = smaY, r = smaOR + c);

				translate([ -smaOD, 4, -c / 2 ]) 
				cube([ smaOD * 3, smaY * 2, smaOR ]);
			}
		}
	}
}

// pins between top/bottom
module pins(top)
{
	pinr = wallThickness / 3;
	pinh = top != 0 ? lidThickness : bottomThickness / 2;
	pinz = top != 0 ? 0 : height;
	pinrc = top != 0 ? pinr + .13 : pinr; // interference fit .11 -> .13

	module pin(xt, yt, gap = 3)
	{
		side = abs(xt) > x/2 - pinr ? "y" : "x";
		translate([xt, yt, 0])
		bar(pinh, pinrc, side, gap); 
	}

	translate([ 0, 0, pinz ]) 
	union()
	{
		//north/south
		nsY = y / 2 + pinr;
	
		pin(-29.65, -nsY, 2.3);
		pin(-10, -nsY);
		pin( 10 + (fan_25mm == 1 ? 2 : 0), -nsY);

		pin( 15, nsY);
		pin(-15, nsY);
			
		//east/west
		ewX = x / 2 + pinr;

		if (shrink == 0)
		{
			pin(ewX, 22);
			pin(ewX, -9);
		}
		else
		{
			pin(ewX, 27);
			pin(ewX, 0);
		}
		pin(ewX, -27);

		pin(-ewX, y / 4);
		pin(-ewX, 0);
		pin(-ewX, -y / 4);
		
	}
}

/* Resource Functions */

module cells(d, h, dx, dy, ix, iy)
{
	translate([ dx * ix, dy * iy, 0 ]) 
		cylinder(h = h, d = d, $fn = 6);
	translate([ dx * ix + abs(dx) / 2, abs(dy) / 2 + dy * iy, 0 ]) 
		cylinder(h = h, d = d, $fn = 6);
}

module grid(
	size, 
	cell_hole, 
	cell_wall, 
	rotate_hex = 0, 
	x_offset = 0, 
	y_offset = 0)
{
	// fyi the math here kinda off I think
	// it was fudged to match the legacy version 
	across_flats = cell_hole * (2 / sqrt(3));
	dy = (across_flats + cell_wall / 2);
	dx = dy * sqrt(3);

	x = rotate_hex == 0 ? 0 : 1;
	y = rotate_hex == 0 ? 1 : 0;
	z = size[2] * 1.1;
	r = rotate_hex == 0 ? 0 : 90;

	xcopies = (size[x] / dx) / 2 * 1.2;
	ycopies = (size[y] / dy) / 2 * 1.2;

	translate([ x_offset, y_offset + dy / 2, -z / 2 ]) 
	rotate([ 0, 0, r ]) 
	for (ix = [0:xcopies])
	{
		for (iy = [0:ycopies])
		{
			cells(across_flats, z, dx, dy, ix, iy);
			cells(across_flats, z, -dx, dy, ix + 1, iy);
			cells(across_flats, z, dx, -dy, ix, iy + 1);
			cells(across_flats, z, -dx, -dy, ix + 1, iy + 1);
		}
	}
}

module create_grid(
	size, 
	cell_hole, 
	cell_wall, 
	outer_wall_modifier = 2, 
	rotate_hex = 0, 
	y_offset = 0,
	y_offset_border = 0,
	x_offset = 0)
{
	outer_wall = outer_wall_modifier * cell_wall;
	union()
	{
		difference()
		{
			cube(size = size, center = true);
			translate([ 0, y_offset_border, 0 ]) intersection()
			{
				cube(size = [ size[0] - outer_wall, size[1] - outer_wall, size[2] * 1.1 ], center = true);
				grid(size, cell_hole, cell_wall, rotate_hex, x_offset, y_offset);
			}
		}
	}
}

// my functions (aka junk)

// pins changed to bars to avoid sheering off on some printers
module bar(h, r, direction, gap)
{
	g = gap / 2;
	x = direction == "x" ? 1 : 0;
	y = direction == "y" ? 1 : 0;
	hull()
	{
		translate([ -g * x, -g * y, 0 ]) 
		cylinder(h = h, r = r);
		translate([ g * x, g * y, 0 ]) 
		cylinder(h = h, r = r);
	}
}

// bolt holes
module boltHoles(h = 50, r = 3.1, r2 = 0, z = 0)
{
    bore4(boltX * 2, boltY * 2, r, h, r2, z);
}

module bore(x, y, r, h = 500, r2 = 0, z)
{
	zh = (z == undef ? -h / 2 : z);
	translate([ x, y, zh ]) 
	union()
	{
		if (r2 == 0)
			cylinder(h = h, r = r);

		if (r2 != 0)
			hull()
			{
				cylinder(h = 0.1, r = r);
				cylinder(h = h, r = r2);
			}
	}
}

module bore4(x, y, r, h = 500, r2 = 0, z)
{
	translate([ -x / 2, -y / 2, 0 ]) 
	union()
	{
		bore(0, 0, r, h, r2, z);
		bore(x, 0, r, h, r2, z);
		bore(0, y, r, h, r2, z);
		bore(x, y, r, h, r2, z);
	}
}

module plate(x, y, t, border, sw, wall, position = 0, funkytown = 0)
{
	ot = t / 4 * (position == 0 ? 1 : -1);
	wt = wallThickness;
	b = border;

	difference()
	{
		hull()
		{
			// inner x
			translate([ 0, 0, ot ]) 
			cube([ x + wt * 2, y, t / 2 ], center = true);
			
			// inner y
			translate([ 0, 0, ot ]) 
			cube([ x, y + wt * 2, t / 2 ], center = true);
			
			// outer x
			translate([ 0, 0, 0 ]) 
			cube([ x, y + wt, t ], center = true);
			
			// outer y
			translate([ 0, 0, 0 ]) 
			cube([ x + wt, y, t ], center = true);
		}
		// cutout
		intersection()
		{
			cube(size = [ x - b * 2, y - b * 2, t * 1.1 ], center = true);
			grid(size = [ x - border, y - border, t ], cell_hole = sw, cell_wall = wall, y_offset = funkytown);
		}
	}
}

// fill in the cells of a hex plate
module fillhex(n, x, y, h, diameter, flip = 0)
{
	modifier = flip < 1 ? 1 : -1;
	xn = diameter * sqrt(3) / 2;
	for (i = [0:n])
	{
		yn = i % 2 == 0 ? 0 : diameter / 2 * modifier;
		translate([ x + xn * i, y + (y > 0 ? -yn : yn), 0 ]) 
		cylinder(h = h, r = diameter / 2, $fn = 6);
	}
}

module byWolfOne(height) {
	linear_extrude(height = 2) 
	{
		font = "Consolas:Bold";
		text("b", font = font, size = 6);

		translate([ 4.9, 0, 0 ]) 
		text("y", font = font, size = 6);

		translate([ 6.5, -13, 0 ]) 
		text("Wo", font = font, size = 8);

		translate([ 18.3, -13, 0 ]) 
		text("l", font = font, size = 8);

		translate([ 23.3, -13, 0 ]) 
		text("f", font = font, size = 8);

		translate([ 30.1, -13, 0 ]) 
		text("O e", font = font, size = 8);

		translate([ 36.5, -13, 0 ]) 
		text("n", font = font, size = 8);
	}
}

// 57 6F 6C 66 4F 6E 65