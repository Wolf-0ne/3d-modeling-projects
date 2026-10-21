// Written by WolfOne
// License - CC BY 4.0
// https://github.com/Wolf-0ne/3d-modeling-projects

// Parametric box. variant: "elongated" (default) or "square".

include <../../libraries/std.scad>

/* Features toggle as needed (0/1) */

	body = 1;				// show body
	badge = 1;

/* Parameters */

	$fn = 50;

	variant = "elongated";	// elongated (default), square

	// external box dimensions (overall size)

	boxX = 96.6;
	boxY = variant == "square" ? 96.6 : 143.5;
	boxHeight = variant == "square" ? 56 : 55;

	// box walls

	wallThickness = 1.9;
	bottomThickness = 2.2; // base
	lidThickness = 4;		// lid

	// inner dimensions (derived from external)

	x = boxX - wallThickness * 2;
	y = boxY - wallThickness * 2;
	height = boxHeight - bottomThickness - lidThickness;

	/* Objects */

if (body == 1) {
	if (variant == "square") body_square();
	else body_elongated();
}

/* Elongated body */

module body_elongated()
{
	wt = wallThickness;
	
	sideGridWall = 2.0;
	sideGridHex = 6.45;
	sideRim = 3;					// solid band at top of walls for a clean print edge
	sideGridOffsetZ = height / 2 - .875 - sideRim / 2;
	sideGridHeight = height + 1.75 - sideRim;
	sideGridHexOffsetZ = 1.25;
	
	module sideGrid()
	{
		// one grid, rotated around so the hexes line up on each face
		for (i = [0:3])
		{
			out = [ y, x ][i % 2] / 2 + wt / 2;	// outward distance to this face
			w = [ x, y ][i % 2];				// arc length of this face
			rotate([ 0, 0, i * 90 ])
			translate([ 0, out, sideGridOffsetZ ])
			rotate([ 90, 0, 0 ])
			create_grid([ w, sideGridHeight, wt ], 
				sideGridHex, 
				sideGridWall, 
				0.05, 
				1, 
				sideGridHexOffsetZ, 
				-sideGridWall);
		}
	}
	
	// body
	difference()
	{
		// positive
		union()
		{
			/* main body */

			translate([ 0, 0, bottomThickness / 2 ]) 
				plate(x, y, bottomThickness, 0, 0, 0, 0);


			/* walls */

			translate([ 0, 0, bottomThickness ]) 
			difference(){
				union()
				{
					sideGrid();

					// solid rim ring above the hexes: clean print edge + lid seat
					translate([ 0, 0, height - sideRim / 2 ])
					difference()
					{
						hull()
						{
							cube([ x + wt * 2, y, sideRim ], center = true);
							cube([ x, y + wt * 2, sideRim ], center = true);
						}
						cube([ x, y, sideRim * 2 ], center = true);
					}
					
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
				}
				translate([ 0, 0, -bottomThickness/2 ]) 
				cube([ x*2, y*2, bottomThickness ], center = true);
			}

		}

		// negative
		union()
		{
			
			// overcomplicated hatred for default font kerning
			if (badge == 1)
			{
				#translate([ -27, 28, lidThickness / 4 ]) 
				rotate([ 0, 0, -90 ])
				byWolfOne(2);
			}
		}
	}
}

/* Square body */

module body_square()
{

	h = height;

	hot = height / 2;
	
	bt = bottomThickness;
	wt = wallThickness;
	
	bottomGridWall = 2.2;
	bottomGridHex = 7;
	
	sideGridWall = 2.0;
	sideGridHex = 6.4;
	sideGridOffsetZ = height / 2 - .875;
	sideGridHeight = height + 1.75;
	sideGridHexOffsetZ = 3.5;
	
	module sideGrid(sx, sy, x_offset = 0)
	{
		width = abs(sx) > x / 2 ? 
			y : x;
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
				plate(x, y, bottomThickness, 0, 0, 0, 0);


			/* walls */

			translate([ 0, 0, bottomThickness ]) 
			difference(){
				union()
				{
					/* north */

					nsX = x / 2 - corner / 2;
					nsY = y / 2 + wt / 2;

					sideGrid(0, nsY);
					
					/* south */
					
					sideGrid(0, -nsY);

					/* east */

					ewX = x / 2 + wt / 2;
					ewY = y / 2 - corner / 2;
					ewOffset = (sideGridHex + sideGridWall) / 2 - .2;

					sideGrid(ewX, 0, ewOffset);

					/* west */

					sideGrid(-ewX, 0, ewOffset);

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
				}
				translate([ 0, 0, -bottomThickness/2 ]) 
				cube([ x*2, y*2, bottomThickness ], center = true);
			}

		}

		// negative
		union()
		{
			
			// overcomplicated hatred for default font kerning
			if (badge == 1)
			{
				#translate([ -27, 28, lidThickness / 4 ]) 
				rotate([ 0, 0, -90 ])
				byWolfOne(2);
			}
		}
	}
}
