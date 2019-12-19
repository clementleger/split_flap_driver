include <prism.scad>
include <parametric_pulley.scad>

FLAP_WIDTH = 54;
FLAP_HEIGHT = 856;
FLAP_DRUM_WIDTH = FLAP_WIDTH;

FRONT_BOTTOM_HEIGHT = 40;
FRONT_BOTTOM_OPEN_HEIGHT = 30;
FRONT_TOP_HEIGHT = 20;

DRUM_FLAPS_COUNT = 40;
DRUM_FLAPS_HOLE_DIAMETER = 2;
DRUM_FLAPS_HOLE_OFFSET = 0.5;
DRUM_INNER_DIAMETER = 30;
DRUM_OUTER_DIAMETER = 45;
DRUM_SIDE_THICKNESS = 3;

DRUM_AXIS_OVERLAP = 2;
assert(DRUM_AXIS_OVERLAP < DRUM_SIDE_THICKNESS);
DRUM_AXIS_HEIGHT = FLAP_WIDTH - DRUM_SIDE_THICKNESS + DRUM_AXIS_OVERLAP;
DRUM_AXIS_THICKNESS = 0.6;

/* Center which rolls around the axis */
DRUM_CENTER_DIAMETER = 10;
DRUM_CENTER_HEIGHT = 10;
DRUM_CENTER_THICKNESS = 3;

DRUM_PLUG_WIDTH = 3;
DRUM_PLUG_HEIGHT = 6;
DRUM_PLUG_THICKNESS = 2;
DRUM_PLUG_COUNT = 4;

DRUM_PULLEY_TEETH = 40;
DRUM_PULLEY_HEIGHT = 3.5;

module drum_plug() 
{
    translate([-DRUM_PLUG_WIDTH/2, 0, -DRUM_PLUG_HEIGHT]) {
        cube([DRUM_PLUG_WIDTH, DRUM_PLUG_THICKNESS, DRUM_PLUG_HEIGHT]);
        translate([0, DRUM_PLUG_THICKNESS, 0]) rotate([180, 0, 0]) prism(DRUM_PLUG_WIDTH, DRUM_PLUG_THICKNESS, DRUM_PLUG_HEIGHT / 2);
    }
}

module drum_end_with_holes()
{
    difference() {
        cylinder(d = DRUM_OUTER_DIAMETER, h = DRUM_SIDE_THICKNESS);
        /* Flaps holes */
        for (hole=[1:DRUM_FLAPS_COUNT])
            rotate([0, 0, hole * (360/DRUM_FLAPS_COUNT)  ]) translate([DRUM_OUTER_DIAMETER/2 - DRUM_FLAPS_HOLE_DIAMETER/2 - DRUM_FLAPS_HOLE_OFFSET , 0, 0]) cylinder(d = DRUM_FLAPS_HOLE_DIAMETER, h = DRUM_SIDE_THICKNESS);
        /* Axis */
        cylinder(d = DRUM_CENTER_DIAMETER, h = DRUM_SIDE_THICKNESS);
    }
}
 
module drum_side()
{
    /* Base with holes for flaps */
    drum_end_with_holes();
    
    difference() {
        cylinder(d = DRUM_CENTER_DIAMETER + DRUM_CENTER_THICKNESS, h = DRUM_CENTER_HEIGHT, $fn = 50);
        cylinder(d = DRUM_CENTER_DIAMETER, h = DRUM_CENTER_HEIGHT);
    }
    /* Axis */
    difference() {
        cylinder(d = DRUM_INNER_DIAMETER, h = DRUM_AXIS_HEIGHT);
        cylinder(d = DRUM_INNER_DIAMETER - DRUM_AXIS_THICKNESS*2, h = DRUM_AXIS_HEIGHT);
    }
    /* Little plugs on top of axis */
    for (hole=[1:DRUM_PLUG_COUNT])
            rotate([0, 0, hole * (360/DRUM_PLUG_COUNT)]) translate([0, -DRUM_INNER_DIAMETER/2 + DRUM_AXIS_THICKNESS, DRUM_AXIS_HEIGHT]) drum_plug();
}

module drum_with_belt_side()
{
    difference() {
        color("green") translate([0, 0, FLAP_WIDTH - DRUM_SIDE_THICKNESS]) {
            drum_end_with_holes();
            translate([0, 0, DRUM_SIDE_THICKNESS]) pulley(teeth = DRUM_PULLEY_TEETH, profile = 12, motor_shaft = DRUM_CENTER_DIAMETER, pulley_t_ht = DRUM_PULLEY_HEIGHT);
        }
       
    drum_side();
    }
    
}

module drum()
{
    drum_side();
    drum_with_belt_side();
}

drum();

module front()
{
    
}

module left_side()
{
    
}

module right_side()
{
    
}

//drum();