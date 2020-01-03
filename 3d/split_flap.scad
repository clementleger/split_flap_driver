include 
include <parametric_pulley.scad>
include <28byj-48.scad>

TOLERANCY = 0.2;

FLAP_WIDTH = 54;
FLAP_HEIGHT = 85.6;
FLAP_THICKNESS = 0.380;
FLAP_DRUM_WIDTH = FLAP_WIDTH;
FLAP_CORNER_RADIUS = 3;

FLAP_SIDE_CUT_HEIGHT = 8;
FLAP_SIDE_CUT_WIDTH = 4;
FLAP_CUT_OFFSET = 1;

FRONT_BOTTOM_HEIGHT = 40;
FRONT_BOTTOM_OPEN_HEIGHT = 30;
FRONT_TOP_HEIGHT = 20;

DRUM_FLAPS_COUNT = 40;
DRUM_FLAPS_HOLE_DIAMETER = 2;
assert(DRUM_FLAPS_HOLE_DIAMETER > FLAP_CUT_OFFSET);
DRUM_FLAPS_HOLE_OFFSET = 0.5;
DRUM_INNER_DIAMETER = 30;
DRUM_OUTER_DIAMETER = 45;
DRUM_SIDE_THICKNESS = 2;
DRUM_FLAP_RADIUS = DRUM_OUTER_DIAMETER/2 - DRUM_FLAPS_HOLE_DIAMETER/2 - DRUM_FLAPS_HOLE_OFFSET;

DRUM_AXIS_OVERLAP = 1;
assert(DRUM_AXIS_OVERLAP < DRUM_SIDE_THICKNESS);
/* Add some slack around cards */
DRUM_AXIS_EXTRA_WIDTH = 1;
DRUM_AXIS_HEIGHT = FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH - DRUM_SIDE_THICKNESS + DRUM_AXIS_OVERLAP;
DRUM_AXIS_THICKNESS = 0.8;

/* Center which rolls around the axis */
DRUM_CENTER_DIAMETER = 8;
DRUM_CENTER_HEIGHT = 10;
DRUM_CENTER_THICKNESS = 3;

DRUM_PLUG_WIDTH = 3;
DRUM_PLUG_HEIGHT = 6;
DRUM_PLUG_THICKNESS = 2;
DRUM_PLUG_COUNT = 4;

DRUM_PULLEY_TEETH = 40;
DRUM_PULLEY_HEIGHT = 3.5;

DRUM_WIDTH = FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH + DRUM_PLUG_WIDTH;

$fn = 50;

module hole(width, height, thickness)
{
    cylinder(d = width, h = thickness, $fn = 30);
    translate([-width / 2, 0, 0]) cube([width, height, thickness]);
    
    translate([0, height, 0]) cylinder(d = width, h = thickness, $fn = 30);
}

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
            rotate([0, 0, hole * (360/DRUM_FLAPS_COUNT)  ]) translate([DRUM_FLAP_RADIUS, 0, 0]) cylinder(d = DRUM_FLAPS_HOLE_DIAMETER, h = DRUM_SIDE_THICKNESS);
        /* Axis */
        cylinder(d = DRUM_CENTER_DIAMETER, h = DRUM_SIDE_THICKNESS);
    }
}

module clipsable_male_part(width, height, thickness, clip_count = 5, clip_height = 5, clip_bottom_width = 8, clip_top_width = 10)
{
    difference() {
        linear_extrude(thickness) {
            square([width, height]);
            for (clips=[0:clip_count+1]) {
                translate([clips * (width / (clip_count + 1)), height]) polygon(points = [[clip_bottom_width/2, 0],[clip_top_width/2, clip_height],[-clip_top_width/2, clip_height],[-clip_bottom_width/2, 0]]);
            }
        }
        /* Remove sides */
        translate([-clip_top_width /2, 0, 0]) cube([clip_top_width/2, height + clip_height, thickness]);
        translate([width, 0, 0]) cube([clip_top_width/2, height + clip_height, thickness]);
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
        translate([0, 0, FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH - DRUM_SIDE_THICKNESS]) {
            drum_end_with_holes();
            translate([0, 0, DRUM_SIDE_THICKNESS]) pulley(teeth = DRUM_PULLEY_TEETH, profile = 12, motor_shaft = DRUM_CENTER_DIAMETER, pulley_t_ht = DRUM_PULLEY_HEIGHT);
        }
       
    drum_side();
    }
}

module flap()
{
    rotate([0, -90, 0]) 
    difference() {
        hull() {
            cube([FLAP_WIDTH, FLAP_HEIGHT/2 - FLAP_CORNER_RADIUS, FLAP_THICKNESS]);
            translate([FLAP_CORNER_RADIUS, FLAP_HEIGHT/2 - FLAP_CORNER_RADIUS, 0]) cylinder(r = FLAP_CORNER_RADIUS, h = FLAP_THICKNESS);
            translate([FLAP_WIDTH - FLAP_CORNER_RADIUS, FLAP_HEIGHT/2 - FLAP_CORNER_RADIUS, 0]) cylinder(r = FLAP_CORNER_RADIUS, h = FLAP_THICKNESS);
        }
        translate([FLAP_WIDTH, FLAP_SIDE_CUT_WIDTH/2 + FLAP_CUT_OFFSET, 0]) hole(FLAP_SIDE_CUT_WIDTH,FLAP_SIDE_CUT_HEIGHT,FLAP_THICKNESS);
        translate([0, FLAP_SIDE_CUT_WIDTH/2 + FLAP_CUT_OFFSET, 0]) hole(FLAP_SIDE_CUT_WIDTH,FLAP_SIDE_CUT_HEIGHT,FLAP_THICKNESS);
    }
}

HANGING_FLAPS_COUNT = DRUM_FLAPS_COUNT/2;

module flaps()
{
    /* Flaps hanging in the bottom of the drum */
    for (flap=[0:HANGING_FLAPS_COUNT-1]) {
        translate([DRUM_FLAP_RADIUS * sin(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_FLAP_RADIUS * cos(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_AXIS_EXTRA_WIDTH/2]) rotate([0, 0, -90]) flap();
    }
    for (flap=[HANGING_FLAPS_COUNT:DRUM_FLAPS_COUNT - 1]) {
        translate([DRUM_FLAP_RADIUS * sin(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_FLAP_RADIUS * cos(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_AXIS_EXTRA_WIDTH/2]) rotate([0, 0, - (360 - 90) - flap * (360 / (DRUM_FLAPS_COUNT - 1))]) flap();
    }
    
}

module drum()
{
    color("grey") drum_side();
    color("grey") drum_with_belt_side();
    color("white") flaps();
}

DISP_BOTTOM_SIZE = 15;
DISP_TOP_SIZE = 15;
/* Add some slack to sides */
DISP_BORDER_ADJUST = 0.8;
DISP_BORDER_SIZE = DRUM_PULLEY_HEIGHT + DISP_BORDER_ADJUST;
assert(DISP_BORDER_SIZE >= DRUM_PULLEY_HEIGHT);

FRONT_THICKNESS = 3;

/* Window inside front display */
DISP_WINDOW_HEIGHT = FLAP_HEIGHT + DRUM_OUTER_DIAMETER / 3;
DISP_WINDOW_WIDTH = FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH + TOLERANCY;

SIDE_THICKNESS = 3;

DISP_TOTAL_HEIGHT = DISP_WINDOW_HEIGHT + DISP_BOTTOM_SIZE + DISP_TOP_SIZE;
DISP_FULL_WIDTH = DISP_WINDOW_WIDTH + 2 * DISP_BORDER_SIZE + 2 * SIDE_THICKNESS;
DISP_FULL_HEIGHT = DISP_WINDOW_HEIGHT + DISP_BOTTOM_SIZE + DISP_TOP_SIZE;

FRONT_CLIP_HEIGHT = 5;
FRONT_CLIP_TOP_WIDTH = 10;
FRONT_CLIP_BOTTOM_WIDTH = 8;
FRONT_CLIP_COUNT = 5;

module front_clips(tolerancy = 0)
{
    clipsable_male_part(DISP_FULL_HEIGHT, SIDE_THICKNESS, SIDE_THICKNESS, FRONT_CLIP_COUNT, FRONT_CLIP_HEIGHT + tolerancy, FRONT_CLIP_BOTTOM_WIDTH + tolerancy, FRONT_CLIP_TOP_WIDTH + tolerancy);
}

module front()
{
    color("salmon")
    difference() {
        cube([DISP_FULL_WIDTH, DISP_TOTAL_HEIGHT, FRONT_THICKNESS]);
        translate([DISP_BORDER_SIZE + SIDE_THICKNESS, DISP_BOTTOM_SIZE, 0]) cube([DISP_WINDOW_WIDTH, DISP_WINDOW_HEIGHT, FRONT_THICKNESS]); 
    }
    /* Side clip parts */
    rotate([90, 0, 90]) clipsable_male_part(DISP_FULL_HEIGHT, FRONT_THICKNESS, FRONT_THICKNESS);
    translate([DISP_FULL_WIDTH - FRONT_THICKNESS, 0, 0]) rotate([90, 0, 90]) front_clips();
}

//front();

DRUM_X_OFFSET = -DRUM_AXIS_EXTRA_WIDTH / 2 - FLAP_WIDTH/2;
DRUM_Y_OFFSET = - DRUM_FLAP_RADIUS;
FLAP_Z_ADJUST = 2;
DRUM_Z_OFFSET = DISP_TOTAL_HEIGHT - DISP_TOP_SIZE - FLAP_HEIGHT/2 - FLAP_Z_ADJUST;

SIDE_LENGTH = 80;
SIDE_END_ROUND = 10;
SIDE_BOTTOM_CLIP_COUNT = 3;
SIDE_DRUM_AXIS_LENGTH = 15;

module side_base()
{
        linear_extrude(SIDE_THICKNESS) {
            hull() {
                translate([-DRUM_Y_OFFSET, DRUM_Z_OFFSET]) circle(d = DRUM_INNER_DIAMETER);
                square([-DRUM_Y_OFFSET, DRUM_Z_OFFSET + DRUM_INNER_DIAMETER/2]);
                translate([SIDE_LENGTH, SIDE_END_ROUND/2]) circle(d = SIDE_END_ROUND);
                square([SIDE_LENGTH + SIDE_END_ROUND/2, SIDE_END_ROUND/2]);
            }
        }
}

module side_full()
{
    difference() {
        union() {
            difference () {
                side_base();
                /* Clipping part */
                translate([-FRONT_THICKNESS, 0, SIDE_THICKNESS]) rotate([180, 0, 90]) front_clips(TOLERANCY);
            }
            /* Axis for drum */
            translate([-DRUM_Y_OFFSET, DRUM_Z_OFFSET]) cylinder(d = DRUM_CENTER_DIAMETER - TOLERANCY, h = SIDE_DRUM_AXIS_LENGTH);
        }
        
        translate([FRONT_CLIP_HEIGHT * 3, SIDE_THICKNESS * 3, 0]) scale([0.6, 0.5, 1]) side_base();
    }
}

module side_bottom_clips(tolerancy = 0)
{
    clipsable_male_part(SIDE_LENGTH + SIDE_END_ROUND/2 - FRONT_CLIP_HEIGHT + tolerancy, SIDE_THICKNESS + tolerancy, SIDE_THICKNESS + tolerancy, SIDE_BOTTOM_CLIP_COUNT);
}

module side()
{
    side_full();
    
    translate([FRONT_CLIP_HEIGHT, SIDE_THICKNESS, 0]) rotate([90, 0, 0]) side_bottom_clips();
    
}

module right_side()
{
    side();
    
    /* Axis for drum */
    translate([-DRUM_Y_OFFSET, DRUM_Z_OFFSET, SIDE_THICKNESS]) cylinder(d = DRUM_INNER_DIAMETER, h = DRUM_PULLEY_HEIGHT);
    
}

module split_flap()
{
    /* Drum */
    translate([DRUM_X_OFFSET, DRUM_Y_OFFSET, DRUM_Z_OFFSET]) rotate([0, 90, 0]) drum();
    /* Front */
    translate([-DISP_FULL_WIDTH/2, FRONT_THICKNESS, 0]) rotate([90, 0, 0]) front();
    /* Left Side */
    translate([DISP_FULL_WIDTH/2, 0, 0]) rotate([90, 0, -90]) side();
    /* Left Side */
    mirror([1, 0, 0]) translate([DISP_FULL_WIDTH/2, 0, 0]) rotate([90, 0, -90]) right_side();
}

split_flap();
