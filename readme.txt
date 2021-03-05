makedoc.lua


Licence
=======
Code licence:
LGPL 2.1


Version
=======
0.1.0


Description
===========
A lua script to read a tagged input file (typically lua_api.txt) and output
a series of html files from it.

The output is pretty rudimentary, but may make navigating the documentation
a little easier.

You can play with the minetest.css file if you like. The only class element
is the navigation bar, top and bottom of the pages, with class name 'nav'.
If the minetest.css file exists it is not overwritten.


Usage
=====
   lua makedoc.lua [OPTIONS] infile outdir

Creates HTML output from tagged input file.

Options
   -h, --help   show help

infile   input file to read

outdir   dir to put output files - must exist.


The easiest way is to copy the makedoc.lua script and  lua_api.txt to a
folder. In that folder create a folder for the output files, and run the
script from the containing folder. For example, assuming the output folder
is called 'output':

lua makedoc.lua lua_api.txt output


Note: The accompanying output was produced from a lua_api.txt for version
5.3.0, but the mod folder structure section was made into a code block so
the output lined up better.
