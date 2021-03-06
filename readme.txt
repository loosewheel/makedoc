makedoc.lua


Licence
=======
Code licence:
LGPL 2.1


Version
=======
0.1.2


Description
===========
A lua script to read a tagged input file (typically lua_api.txt) and output
a series of html files from it.

The output is pretty rudimentary, but may make navigating the documentation
a little easier.

A search bar is incorporated on the page to search the document set. The
searches are case insensitive.

You can play with the minetest.css file if you like, to change the
appearance.

Four element classes are defined:

nav : The navigation bar, top and bottom of the pages.
search : The panel which displays the search results.
searchbg : The background panel around the search panel.
line1 : The list entries of the outer most lists.

If the minetest.css file exists it is not overwritten.



Usage
=====
   lua makedoc.lua [OPTIONS] infile outdir

Creates HTML output from tagged input file.

Options
   -h, --help        show help.
   -m, --max_lines   max lines on a page before it's
                     split into more than one page.

infile   input file to read.

outdir   dir to put output files - must exist.



The easiest way is to copy the makedoc.lua script and lua_api.txt to a
folder. In that folder create a folder for the output files, and run the
script from the containing folder. For example, assuming the output folder
is called 'output':

lua makedoc.lua --max_lines 500 lua_api.txt output

The script separates the major headings into single pages. Some of the
sections are quite large, resulting in some very long pages. The max_line
option can be used to control the approximate page size of the output.
When a document would exceed this line count (approximately) the script
splits that section by its second heading groups, promoting the headings
up one size. The default is 500.

Note: The accompanying output was produced from a lua_api.txt for version
5.3.0, but the mod folder structure section was made into a code block so
the output lined up better.
