#!/usr/bin/python3

import svgwrite
import sys, getopt
import subprocess
import tempfile
import os

characters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
"M", "N","O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
",", ".", ":", "#", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

output_dir = "output/"

try:
	opts, args = getopt.getopt(sys.argv[1:],"ho:",["ofile="])
except getopt.GetoptError:
	print(sys.argv[0] + ' -o <outputfolder>')
	sys.exit(2)
for opt, arg in opts:
	if opt == '-h':
		print(sys.argv[0] + ' -o <outputfolder>')
		sys.exit()
	elif opt in ("-o", "--ofile"):
		output_dir = arg


os.makedirs(name = output_dir, exist_ok = True)
print('Output file is ', output_dir)


for char in characters:
	output_file = os.path.join(output_dir, char + ".svg")
	svg_document = svgwrite.Drawing(filename = output_file,
					size = ("200px", "350px"))

	svg_document.add(svg_document.text(char,
					   insert = (0, 250),
					   style="font-size:340;font-family:Bebas;stroke:black;stroke-width:1;fill:none"))
	svg_document.save()

	subprocess.call("inkscape " + output_file + " --export-text-to-path --export-plain-svg " + output_file, shell = True)

