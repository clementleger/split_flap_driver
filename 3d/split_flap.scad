include <prism.scad>
include <parametric_pulley.scad>
include <28byj-48.scad>

/* General tolenracy (should be upadate according to 3D printer) */
TOLERANCY = 0.2;
/* Tolerancy for drum axis */
AXIS_TOLERANCY = 0.3;

/* Width of flaps */
FLAP_WIDTH = 54;
/* Height of flaps */
FLAP_HEIGHT = 85.6;
/* THickness of flaps */
FLAP_THICKNESS = 0.380;
/* Flap drum width */
FLAP_DRUM_WIDTH = FLAP_WIDTH;
/* Corner around flaps */
FLAP_CORNER_RADIUS = 3;

FLAP_SIDE_CUT_HEIGHT = 8;
FLAP_SIDE_CUT_WIDTH = 1.5;
FLAP_CUT_OFFSET = 1;

FRONT_BOTTOM_HEIGHT = 40;
FRONT_BOTTOM_OPEN_HEIGHT = 30;
FRONT_TOP_HEIGHT = 20;

/* Number of flaps on drum */
DRUM_FLAPS_COUNT = 40;
/* Holes for flaps */
DRUM_FLAPS_HOLE_DIAMETER = 2;
assert(DRUM_FLAPS_HOLE_DIAMETER > FLAP_CUT_OFFSET);
/* Offset of flaps hole  from drum side */
DRUM_FLAPS_HOLE_OFFSET = 1;
/* Inner diameter of drum (ie tube connecting both ends) */
DRUM_INNER_DIAMETER = 30;
/* Outer diameter of drum (ie where the flaps insert) */
DRUM_OUTER_DIAMETER = 42;
/* Thickness of side of drum (ie where the flaps insert) */
DRUM_SIDE_THICKNESS = 2.5;

/* Radius of flaps where the flaps are inserted */
DRUM_FLAP_RADIUS = DRUM_OUTER_DIAMETER/2 - DRUM_FLAPS_HOLE_DIAMETER/2 - DRUM_FLAPS_HOLE_OFFSET;

/* Depth */
DRUM_AXIS_OVERLAP = 1.6;
assert(DRUM_AXIS_OVERLAP < DRUM_SIDE_THICKNESS);
/* Slack around cards (normally unnecessary) */
DRUM_AXIS_EXTRA_WIDTH = 0;

DRUM_AXIS_HEIGHT = FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH - DRUM_SIDE_THICKNESS + DRUM_AXIS_OVERLAP;
/* Thickness if tube connecting both ends both ends of drum */
DRUM_AXIS_THICKNESS = 0.8;


/* Diameter of rotation axis */
DRUM_CENTER_DIAMETER = 8;
/* Additionnal height of axis*/
DRUM_CENTER_HEIGHT = 10;
DRUM_CENTER_THICKNESS = 3;

/* Plug width */
DRUM_PLUG_WIDTH = 3;
/* Plug height */
DRUM_PLUG_HEIGHT = 6;
/* Plug thickness */
DRUM_PLUG_THICKNESS = 2;
/* Plug inside drum to connect with other end of drum */
/* This will be minus 1 to allow an exact fitting with other side */
DRUM_PLUG_COUNT = 4;

/* Number of tooth of pulley */
DRUM_PULLEY_TEETH = 20;
/* Thickness of pulley */
DRUM_PULLEY_HEIGHT = 3.5;

/* Total width of drum */
DRUM_WIDTH = FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH + DRUM_PLUG_WIDTH;

/* Magnet (for hall effect sensor) diameter */
DRUM_MAGNET_DIAMETER = 3;
/* Magnet height */
DRUM_MAGNET_HEIGHT = 3;

$fn = 50;

module hole(width, height, thickness)
{
    cylinder(d = width, h = thickness, $fn = 30);
    translate([-width / 2, 0, 0]) cube([width, height, thickness]);
    
    translate([0, height, 0]) cylinder(d = width, h = thickness, $fn = 30);
}

module drum_plug(tolerancy = 0) 
{
    translate([-DRUM_PLUG_WIDTH/2 - tolerancy/2, 0, -DRUM_PLUG_HEIGHT]) {
        cube([DRUM_PLUG_WIDTH + tolerancy, DRUM_PLUG_THICKNESS + tolerancy, DRUM_PLUG_HEIGHT]);
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

module drum_side(tolerancy = 0)
{
    /* Base with holes for flaps */
    drum_end_with_holes();

    difference() {
        cylinder(d = DRUM_CENTER_DIAMETER + DRUM_CENTER_THICKNESS, h = DRUM_CENTER_HEIGHT, $fn = 50);
        cylinder(d = DRUM_CENTER_DIAMETER, h = DRUM_CENTER_HEIGHT);
    }
    /* Axis */
    difference() {
        cylinder(d = DRUM_INNER_DIAMETER + tolerancy/2, h = DRUM_AXIS_HEIGHT);
        cylinder(d = DRUM_INNER_DIAMETER - DRUM_AXIS_THICKNESS*2 - tolerancy/2, h = DRUM_AXIS_HEIGHT);
    }
    /* Little plugs on top of axis */
    for (hole=[1:DRUM_PLUG_COUNT - 1])
            rotate([0, 0, hole * (360/DRUM_PLUG_COUNT)]) translate([0, -DRUM_INNER_DIAMETER/2 + DRUM_AXIS_THICKNESS, DRUM_AXIS_HEIGHT]) drum_plug(tolerancy);
}

module drum_with_magnet()
{
    difference() {
        drum_side();
        
        /* Magnet hole */
        translate([DRUM_INNER_DIAMETER/2 - DRUM_MAGNET_DIAMETER/2 - DRUM_AXIS_THICKNESS, 0, 0]) cylinder(d = DRUM_MAGNET_DIAMETER, h = DRUM_MAGNET_HEIGHT);
    }
}

module drum_with_belt()
{
    difference() {
        translate([0, 0, FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH - DRUM_SIDE_THICKNESS]) {
            drum_end_with_holes();
            translate([0, 0, DRUM_SIDE_THICKNESS]) pulley(teeth = DRUM_PULLEY_TEETH, profile = 12, motor_shaft = DRUM_CENTER_DIAMETER, pulley_t_ht = DRUM_PULLEY_HEIGHT);
        }
       
    drum_side(TOLERANCY);
    }
}

module cube_rounded(width, height, thickness)
{
    cube([width, height, thickness]);
    translate([0, height, 0]) cylinder(r = width, h = thickness ); 
}

module flap()
{
    difference() {
        hull() {
            cube([FLAP_WIDTH, FLAP_HEIGHT/2 - FLAP_CORNER_RADIUS, FLAP_THICKNESS]);
            translate([FLAP_CORNER_RADIUS, FLAP_HEIGHT/2 - FLAP_CORNER_RADIUS, 0]) cylinder(r = FLAP_CORNER_RADIUS, h = FLAP_THICKNESS);
            translate([FLAP_WIDTH - FLAP_CORNER_RADIUS, FLAP_HEIGHT/2 - FLAP_CORNER_RADIUS, 0]) cylinder(r = FLAP_CORNER_RADIUS, h = FLAP_THICKNESS);
        }
        translate([FLAP_WIDTH, FLAP_CUT_OFFSET, 0]) mirror([1, 0, 0]) cube_rounded(FLAP_SIDE_CUT_WIDTH,FLAP_SIDE_CUT_HEIGHT,FLAP_THICKNESS);
        translate([0, FLAP_CUT_OFFSET, 0]) cube_rounded(FLAP_SIDE_CUT_WIDTH,FLAP_SIDE_CUT_HEIGHT,FLAP_THICKNESS);
    }
}

HANGING_FLAPS_COUNT = DRUM_FLAPS_COUNT/2;

module flaps()
{
    /* Flaps hanging in the bottom of the drum */
    for (flap=[0:HANGING_FLAPS_COUNT-1]) {
        translate([DRUM_FLAP_RADIUS * sin(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_FLAP_RADIUS * cos(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_AXIS_EXTRA_WIDTH/2]) rotate([0, 0, -90]) 
    rotate([0, -90, 0])  flap();
    }
    for (flap=[HANGING_FLAPS_COUNT:DRUM_FLAPS_COUNT - 1]) {
        translate([DRUM_FLAP_RADIUS * sin(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_FLAP_RADIUS * cos(flap * (360 / DRUM_FLAPS_COUNT)), DRUM_AXIS_EXTRA_WIDTH/2]) rotate([0, 0, - (360 - 90) - flap * (360 / (DRUM_FLAPS_COUNT - 1))]) 
    rotate([0, -90, 0])  flap();
    }
    
}

module drum()
{
    color("grey") drum_side();
    color("grey") drum_with_belt();
    color("white") flaps();
}

/* Size of bottom border */
DISP_BOTTOM_SIZE = 12;
/* Size of top border */
DISP_TOP_SIZE = 12;
/* Add some slack to sides */
DISP_BORDER_ADJUST = 0.8;
DISP_BORDER_SIZE = DRUM_PULLEY_HEIGHT + DISP_BORDER_ADJUST;
assert(DISP_BORDER_SIZE >= DRUM_PULLEY_HEIGHT);

/* Thickness of front part */
FRONT_THICKNESS = 3;

/* Window height inside front display */
DISP_WINDOW_HEIGHT = FLAP_HEIGHT + DRUM_OUTER_DIAMETER / 3;
/* Add some slack around flaps */
DISP_WINDOW_EXTRA_WIDTH = 1.6;
/* Window width inside front display */
DISP_WINDOW_WIDTH = FLAP_WIDTH + DRUM_AXIS_EXTRA_WIDTH;

SIDE_THICKNESS = 3;

DISP_TOTAL_HEIGHT = DISP_WINDOW_HEIGHT + DISP_BOTTOM_SIZE + DISP_TOP_SIZE;
DISP_FULL_WIDTH = DISP_WINDOW_WIDTH + 2 * DISP_BORDER_SIZE + 2 * SIDE_THICKNESS;
DISP_FULL_HEIGHT = DISP_WINDOW_HEIGHT + DISP_BOTTOM_SIZE + DISP_TOP_SIZE;

/* Front clip parameters */
FRONT_CLIP_HEIGHT = 3;
FRONT_CLIP_TOP_WIDTH = 9;
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
        /* Window */
        translate([DISP_BORDER_SIZE + SIDE_THICKNESS - DISP_WINDOW_EXTRA_WIDTH/2, DISP_BOTTOM_SIZE, 0]) cube([DISP_WINDOW_WIDTH + DISP_WINDOW_EXTRA_WIDTH, DISP_WINDOW_HEIGHT, FRONT_THICKNESS]); 
    }
    /* Side clip parts */
    rotate([90, 0, 90]) front_clips();
    translate([DISP_FULL_WIDTH - FRONT_THICKNESS, 0, 0]) rotate([90, 0, 90]) front_clips();
}

DRUM_X_OFFSET = -DRUM_AXIS_EXTRA_WIDTH / 2 - FLAP_WIDTH/2;
DRUM_Y_OFFSET = - DRUM_FLAP_RADIUS;
FLAP_Z_ADJUST = 1;
DRUM_Z_OFFSET = DISP_TOTAL_HEIGHT - DISP_TOP_SIZE - FLAP_HEIGHT/2 - FLAP_Z_ADJUST;

SIDE_END_ROUND = 15;
SIDE_BOTTOM_CLIP_COUNT = 3;
SIDE_BOTTOM_CLIP_HEIGHT = 2;
SIDE_BOTTOM_CLIP_TOP_WIDTH = 9;
SIDE_BOTTOM_CLIP_BOTTOM_WIDTH = 8;
SIDE_DRUM_AXIS_LENGTH = 15;

SIDE_BORDER_THICKNESS = 7;

SIDE_LENGTH = 80;

BOTTOM_THICKNESS = 3;

SIDE_ANGLE = -45;

module side_format_2d()
{
    hull() {
        translate([FRONT_THICKNESS + SIDE_BORDER_THICKNESS, DISP_FULL_HEIGHT - SIDE_END_ROUND/2]) circle(d = SIDE_END_ROUND);
        square([FRONT_THICKNESS + SIDE_BORDER_THICKNESS, DISP_FULL_HEIGHT]);
        translate([SIDE_LENGTH - SIDE_END_ROUND/2, SIDE_BORDER_THICKNESS + BOTTOM_THICKNESS]) circle(d = SIDE_END_ROUND);
        square([SIDE_LENGTH, SIDE_BORDER_THICKNESS + BOTTOM_THICKNESS]);
    }
}


module side_format_2d_empty_part()
{
    translate([- SIDE_BORDER_THICKNESS - FRONT_THICKNESS, - SIDE_BORDER_THICKNESS - BOTTOM_THICKNESS])
    difference() {
        side_format_2d();
        square([FRONT_THICKNESS + SIDE_BORDER_THICKNESS, DISP_FULL_HEIGHT]);
        square([SIDE_LENGTH, SIDE_BORDER_THICKNESS + BOTTOM_THICKNESS]);
    }
}

module side_base()
{
    REDUCE_RATIO = (SIDE_LENGTH - SIDE_BORDER_THICKNESS) / SIDE_LENGTH;
    linear_extrude(SIDE_THICKNESS) {
        difference() {
            side_format_2d();
            translate([SIDE_BORDER_THICKNESS + FRONT_THICKNESS, SIDE_BORDER_THICKNESS + BOTTOM_THICKNESS]) resize([REDUCE_RATIO * (SIDE_LENGTH - FRONT_THICKNESS - SIDE_BORDER_THICKNESS), REDUCE_RATIO * (DISP_FULL_HEIGHT - SIDE_BORDER_THICKNESS - BOTTOM_THICKNESS)]) side_format_2d_empty_part();
        }
        /* Middle part to support axis */
        intersection() {
            side_format_2d();
            translate([0, DRUM_Z_OFFSET - DRUM_INNER_DIAMETER/2]) square([SIDE_LENGTH, DRUM_INNER_DIAMETER]);
        }
        /* Transverse support */
        intersection() {
            side_format_2d();
            translate([0, SIDE_BORDER_THICKNESS/2]) rotate([0, 0, SIDE_ANGLE]) square([SIDE_BORDER_THICKNESS, DISP_FULL_HEIGHT]);
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
            translate([-DRUM_Y_OFFSET, DRUM_Z_OFFSET]) cylinder(d = DRUM_CENTER_DIAMETER - AXIS_TOLERANCY, h = SIDE_DRUM_AXIS_LENGTH);
        }
    }
}

module side_bottom_clips(tolerancy = 0)
{
    clipsable_male_part(SIDE_LENGTH - FRONT_CLIP_HEIGHT + tolerancy, SIDE_THICKNESS, BOTTOM_THICKNESS, SIDE_BOTTOM_CLIP_COUNT, SIDE_BOTTOM_CLIP_HEIGHT, SIDE_BOTTOM_CLIP_BOTTOM_WIDTH, SIDE_BOTTOM_CLIP_TOP_WIDTH);
}

module side()
{
    side_full();
    translate([FRONT_CLIP_HEIGHT, BOTTOM_THICKNESS, 0]) rotate([90, 0, 0]) side_bottom_clips();
}

/* Width of hall effect sensor */
HALL_EFFECT_SENSOR_WIDTH = 5;
/* Diameter of hall effect sensor pcb screw */
HALL_EFFECT_SENSOR_HOLE_DIAM = 3;
HALL_EFFECT_SENSOR_HOLE_HEIGHT = 15;
HALL_EFFECT_SENSOR_SUPPORT_WIDTH = 10;

module right_side()
{
    side();

    difference() {
        /* Axis for drum */
        translate([-DRUM_Y_OFFSET, DRUM_Z_OFFSET, SIDE_THICKNESS]) cylinder(d = DRUM_INNER_DIAMETER, h = DRUM_PULLEY_HEIGHT + DRUM_AXIS_EXTRA_WIDTH / 2 );
        
        /* Hole for hall effect sensor */
        translate([-DRUM_Y_OFFSET - HALL_EFFECT_SENSOR_WIDTH/2, DRUM_Z_OFFSET - (DRUM_INNER_DIAMETER/2 - DRUM_CENTER_DIAMETER/2) - DRUM_CENTER_DIAMETER/2, SIDE_THICKNESS]) #cube([HALL_EFFECT_SENSOR_WIDTH, DRUM_INNER_DIAMETER/2 - DRUM_CENTER_DIAMETER/2, DRUM_PULLEY_HEIGHT + DRUM_AXIS_EXTRA_WIDTH / 2]);
    }
    /* Support for hall effect sensor PCB */
    
    translate([-DRUM_Y_OFFSET, -HALL_EFFECT_SENSOR_HOLE_HEIGHT + DRUM_Z_OFFSET - DRUM_INNER_DIAMETER/2, 0]) difference() {
        hole(HALL_EFFECT_SENSOR_SUPPORT_WIDTH, HALL_EFFECT_SENSOR_HOLE_HEIGHT, SIDE_THICKNESS);
        hole(HALL_EFFECT_SENSOR_HOLE_DIAM, HALL_EFFECT_SENSOR_HOLE_HEIGHT, SIDE_THICKNESS);
    }
}

BOTTOM_WIDTH = DISP_FULL_WIDTH - 2 * SIDE_THICKNESS;
BOTTOM_BORDER_THICKNESS = 8;
BOTTOM_CARVE_LENGTH = SIDE_LENGTH - 33;
BOTTOM_MOTOR_Y_OFFSET = SIDE_LENGTH - 28byj48_chassis_radius * 2;
MOTOR_HOLDER_THICKNESS = 3;
MOTOR_HOLDER_WIDTH = 15;
MOTOR_HOLDER_MIDDLE_WIDTH = 30;

MOTOR_HOLDER_ROUNDING = 4;
MOTOR_HOLDER_HOLE_TOP_THICKNESS = 2;
MOTOR_HOLDER_HOLE_SIDE_THICKNESS = 4;
MOTOR_HOLDER_HEIGHT = 43;
MOTOR_MOUNT_SPACING = 35;
MOTOR_MOUNT_SCREW_DIAM = 3.5;
MOTOR_SHAFT_COLLAR_DIAMETER = 28byj48_shaft_collar_radius * 2;
MOTOR_HOLDER_MOUNT_WIDTH = 10;
MOTOR_HOLDER_MOUNT_HEIGHT = MOTOR_MOUNT_SCREW_DIAM;

/* FIXME ! */
module motor_holder()
{
    difference() {
        hull () {
            cube([MOTOR_HOLDER_THICKNESS, MOTOR_HOLDER_WIDTH, MOTOR_HOLDER_HEIGHT- MOTOR_HOLDER_ROUNDING/2 ]); 
            translate([0, MOTOR_HOLDER_ROUNDING/2, MOTOR_HOLDER_HEIGHT - MOTOR_HOLDER_ROUNDING/2]) rotate ([0, 90, 0]) cylinder(d = MOTOR_HOLDER_ROUNDING , h = MOTOR_HOLDER_THICKNESS);
            translate([0, MOTOR_HOLDER_WIDTH - MOTOR_HOLDER_ROUNDING/2, MOTOR_HOLDER_HEIGHT - MOTOR_HOLDER_ROUNDING/2]) rotate ([0, 90, 0]) cylinder(d = MOTOR_HOLDER_ROUNDING , h = MOTOR_HOLDER_THICKNESS);
               /* Crappy things... */
    translate([0, MOTOR_HOLDER_MOUNT_HEIGHT/2 + MOTOR_HOLDER_HOLE_SIDE_THICKNESS - 28byj48_shaft_offset, MOTOR_HOLDER_HEIGHT - MOTOR_HOLDER_MOUNT_HEIGHT/2 - MOTOR_HOLDER_HOLE_TOP_THICKNESS - MOTOR_MOUNT_SPACING/2])rotate([0, 90, 0])  cylinder(d = MOTOR_HOLDER_MOUNT_WIDTH +  MOTOR_HOLDER_HOLE_SIDE_THICKNESS, h = MOTOR_HOLDER_THICKNESS);
    
    translate([MOTOR_HOLDER_THICKNESS/2, MOTOR_HOLDER_MOUNT_HEIGHT/2 + MOTOR_HOLDER_HOLE_SIDE_THICKNESS - 28byj48_shaft_offset, (MOTOR_HOLDER_MOUNT_WIDTH +  MOTOR_HOLDER_HOLE_SIDE_THICKNESS)/2]) cube([MOTOR_HOLDER_THICKNESS, MOTOR_HOLDER_MOUNT_WIDTH +  MOTOR_HOLDER_HOLE_SIDE_THICKNESS, MOTOR_HOLDER_MOUNT_WIDTH +  MOTOR_HOLDER_HOLE_SIDE_THICKNESS], center = true);
        }
        
        /* Top hole for motor */
        translate([0, MOTOR_HOLDER_MOUNT_HEIGHT/2 + MOTOR_HOLDER_HOLE_SIDE_THICKNESS, MOTOR_HOLDER_HEIGHT - MOTOR_HOLDER_MOUNT_HEIGHT/2 - MOTOR_HOLDER_HOLE_TOP_THICKNESS]) #rotate([0, 90, 0]) hole(MOTOR_HOLDER_MOUNT_HEIGHT, MOTOR_HOLDER_WIDTH - MOTOR_HOLDER_MOUNT_HEIGHT - 2 * MOTOR_HOLDER_HOLE_SIDE_THICKNESS, MOTOR_HOLDER_THICKNESS);
        /* Bottom hole for motor */
        translate([0, MOTOR_HOLDER_MOUNT_HEIGHT/2 + MOTOR_HOLDER_HOLE_SIDE_THICKNESS, MOTOR_HOLDER_HEIGHT - MOTOR_HOLDER_MOUNT_HEIGHT/2 - MOTOR_HOLDER_HOLE_TOP_THICKNESS - MOTOR_MOUNT_SPACING]) #rotate([0, 90, 0]) hole(MOTOR_HOLDER_MOUNT_HEIGHT, MOTOR_HOLDER_WIDTH - MOTOR_HOLDER_MOUNT_HEIGHT - 2 * MOTOR_HOLDER_HOLE_SIDE_THICKNESS, MOTOR_HOLDER_THICKNESS);
        /* Hole for motor shaft */
        translate([0, MOTOR_HOLDER_MOUNT_HEIGHT/2 + MOTOR_HOLDER_HOLE_SIDE_THICKNESS - 28byj48_shaft_offset, MOTOR_HOLDER_HEIGHT - MOTOR_HOLDER_MOUNT_HEIGHT/2 - MOTOR_HOLDER_HOLE_TOP_THICKNESS - MOTOR_MOUNT_SPACING/2]) rotate([0, 90, 0]) hole(MOTOR_HOLDER_MOUNT_WIDTH, MOTOR_HOLDER_WIDTH - MOTOR_HOLDER_MOUNT_HEIGHT - 2 * MOTOR_HOLDER_HOLE_SIDE_THICKNESS, MOTOR_HOLDER_THICKNESS);
    }
    
}

module motor_holder_with_motor(with_stepper)
{
    motor_holder();
    if (with_stepper == 1) {
        translate([MOTOR_HOLDER_THICKNESS, 0, MOTOR_HOLDER_HEIGHT - MOTOR_HOLDER_MOUNT_HEIGHT/2 - MOTOR_HOLDER_HOLE_TOP_THICKNESS - MOTOR_MOUNT_SPACING/2]) rotate([180, 90, 0]) Stepper28BYJ48();
    }
}


module bottom(with_stepper = 1)
{
    difference() {
        cube([BOTTOM_WIDTH, SIDE_LENGTH, BOTTOM_THICKNESS]);
        /* Remove useless center part */
        
        translate([BOTTOM_BORDER_THICKNESS, BOTTOM_BORDER_THICKNESS, 0]) cube([BOTTOM_WIDTH - 2 * BOTTOM_BORDER_THICKNESS, BOTTOM_CARVE_LENGTH, BOTTOM_THICKNESS]);
        /* Clips */
        translate([BOTTOM_WIDTH + SIDE_THICKNESS, FRONT_CLIP_HEIGHT, 0]) rotate([0, 0, 90]) side_bottom_clips(TOLERANCY);
        translate([-SIDE_THICKNESS, FRONT_CLIP_HEIGHT, 0]) rotate([0, 0, 90]) mirror([0, 1, 0]) side_bottom_clips(TOLERANCY);
    }
    /* Motor_holder */
    translate([28byj48_shaft_height - MOTOR_HOLDER_THICKNESS + TOLERANCY, SIDE_LENGTH - MOTOR_HOLDER_WIDTH, BOTTOM_THICKNESS]) motor_holder_with_motor(with_stepper);
}

module split_flap()
{
    /* Drum */
    translate([DRUM_X_OFFSET, DRUM_Y_OFFSET, DRUM_Z_OFFSET]) rotate([0, 90, 0]) drum();
    /* Front */
    translate([-DISP_FULL_WIDTH/2, FRONT_THICKNESS, 0]) rotate([90, 0, 0]) front();
    /* Left Side */
    translate([DISP_FULL_WIDTH/2, 0, 0]) rotate([90, 0, -90]) side();
    /* Right Side */
    mirror([1, 0, 0]) translate([DISP_FULL_WIDTH/2, 0, 0]) rotate([90, 0, -90]) right_side();
    
    /* Bottom */
    translate([BOTTOM_WIDTH/2, 0, 0]) rotate([0, 0, 180]) bottom();
}

if (GENERATE == undef) {
    split_flap();
} else  {
    if (GENERATE == "bottom") {
        bottom(0);
    }
    if (GENERATE == "right_side") {
        mirror([1, 0, 0]) right_side();
    }
    if (GENERATE == "left_side") {
        side();
    }
    if (GENERATE == "front") {
        front();
    }
    if (GENERATE == "drum_with_belt") {
        drum_with_belt();
    }
    if (GENERATE == "drum_with_magnet") {
        drum_with_magnet();
    }

    if (GENERATE == "flap") {
       projection(cut = false)  flap();
    }
}
