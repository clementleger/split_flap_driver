parts = bottom right_side side front drum_with_magnet drum_with_belt
output_dir = stl/
stl_parts = $(addprefix $(output_dir),$(addsuffix .stl,$(parts)))
scad_input = $(wildcard *.scad)

all: $(stl_parts)

%.stl: $(scad_input)
	mkdir -p $(output_dir)
	openscad --autocenter -o $@ -DGENERATE=\"$(notdir $*)\" split_flap.scad

.PHONY: clean
clean:
	rm -rf $(output_dir)
	
