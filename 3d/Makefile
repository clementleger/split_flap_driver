3d_parts = bottom right_side left_side front drum_with_magnet drum_with_belt
stl_output_dir = stl/
stl_parts = $(addprefix $(stl_output_dir),$(addsuffix .stl,$(3d_parts)))

2d_parts = flap
svg_output_dir = svg/
svg_parts = $(addprefix $(svg_output_dir),$(addsuffix .svg,$(2d_parts)))

scad_input = $(wildcard *.scad)

all: $(stl_parts) $(svg_parts)

%.stl: $(scad_input)
	mkdir -p $(stl_output_dir)
	openscad --autocenter -o $@ -DGENERATE=\"$(notdir $*)\" split_flap.scad

%.svg: $(scad_input)
	mkdir -p $(svg_output_dir)
	openscad --autocenter -o $@ -DGENERATE=\"$(notdir $*)\" split_flap.scad

.PHONY: clean
clean:
	rm -rf $(stl_output_dir) $(svg_output_dir)
	
