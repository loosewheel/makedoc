

local TEXT			= 0
local TEXT_BREAK	= 1
local HEADING_1	= 2
local HEADING_2	= 3
local HEADING_3	= 4
local HEADING_4	= 5
local CODE_BLOCK	= 6
local PARAGRAPH	= 7
local LIST_ITEM	= 8
local TABLE_ROW	= 9
local DOCFORMAT	= 10
local TEXT_CODE	= 11



-- linkup so accessible to inline parsing functions
local g_docs = nil



local function trim_left (s)
   return s:gsub ("^%s+", "")
end



local function trim_right (s)
   return s:gsub ("%s+$", "")
end



local function trim (s)
   return s:gsub("^%s+", ""):gsub("%s+$", "")
end



local function clean_name (text)
	return text:gsub ("`", ""):gsub ("##", ""):gsub ("'", ""):gsub ("\"", "")
end


local function line_type (l)
	local tag = l:sub (1, 3)

	if tag == "===" then
		return HEADING_1
	elseif tag == "---" then
		return HEADING_2
	elseif l:sub (1, 4) == "####" then
		return HEADING_4
	elseif tag == "###" then
		return HEADING_3
	elseif tag == "```" then
		return CODE_BLOCK
	elseif trim (l) == "" then
		return PARAGRAPH
	end

	if trim_left (l):sub (1, 2) == "* " then
		return LIST_ITEM
	end

	if l:sub (1, 1) == "|" then
		return TABLE_ROW
	end

	return TEXT
end



local function parse_line (l)
	local lt = line_type (l)
	local level = nil
	local text = nil

	if lt == LIST_ITEM then
		local pre = l:match ("^%s*")

		if pre then
			level = math.floor (pre:len () / 4) + 1
			text = trim_left (l:sub (pre:len () + 2))
		else
			level = 1
			text = trim_left (l:sub (2))
		end

	elseif lt == TEXT or lt == TEXT_BREAK then
		text = l

	elseif lt == TABLE_ROW then
		text = l

	elseif lt == HEADING_3 then
		text = trim_left (l:sub (4))

	elseif lt == HEADING_4 then
		text = trim_left (l:sub (5))
	end

	return lt, level, text
end



local function parse_symbols (text)
	text = text:gsub ("<", "&lt;")
	text = text:gsub (">", "&gt;")

	return text
end



local function eval_inline_code (str)
	str = str:gsub ("`", "")

	return "<code>"..str.."</code>"
end



local function eval_inline_bold (str)
	str = str:gsub ("%*%*", "")

	return "<em>"..str.."</em>"
end



local function eval_inline_link (str, address)
	return "<a href=\""..address.."\">"..str.."</a>"
end



local function eval_inline_reference (str)
	local copy = str

	for d = 1, #g_docs do
		local doc = g_docs[d].doc

		for l = 1, #doc do
			if doc[l].anchor and doc[l].anchor == clean_name (copy) then
				return "<a href=\""..g_docs[d].name..".html#"..doc[l].anchor.."\">"..copy.."</a>"
			end
		end
	end

	return "["..str.."]"
end



local function parse_inline (text)

	text = parse_symbols (text)

	text = text:gsub ("%[([^%]]*)%]%(([^%)]*)%)", eval_inline_link)
	text = text:gsub ("%[([^%]]*)%]", eval_inline_reference)

	text = text:gsub ("`([^`]*)`", eval_inline_code)
	text = text:gsub ("%*%*([^%*]*)%*%*", eval_inline_bold)

	return text
end



local app = { }



-- constructor
function app:new ( ... )
	local args = { ... }
	local obj = { }

   setmetatable(obj, self)
   self.__index = self

   obj.help = #args < 2 or args[1] == "-h" or args[1] == "--help"
   obj.infile = args[1]
   obj.outdir = args[2]

   if obj.outdir and obj.outdir:sub (-1) ~= "/" then
		obj.outdir = obj.outdir.."/"
	end

	obj.raw = { }
	obj.docs = { { title = "Preamble", doc = { } } }
	obj.output = nil

	obj.list_item = { }
	obj.code_open = false
	obj.paragraph_open = false
	obj.list_indent = false

	return obj
end



function app:read_input ()
	local file = io.open (self.infile, "r")

	self.raw = { }

	if file then
		for line in file:lines () do
			self.raw[#self.raw + 1] = line
		end

		file:close ()

		return true
	end

	return fale
end



function app:close_paragraph ()
	if self.paragraph_open then
		if self.output[#self.output].type == PARAGRAPH then
			table.remove (self.output, #self.output)
		else
			self.output[#self.output + 1] = { type = DOCFORMAT, text = "</p>" }
		end
	end

	self.paragraph_open = false
end



function app:close_lists_to_level (level)
	while level < #self.list_item do
		self.output[#self.output + 1] = { type = DOCFORMAT, text = "</li>" }
		self.output[#self.output + 1] = { type = DOCFORMAT, text = "</ul>" }

		table.remove (self.list_item, #self.list_item)
	end

	if level < 1 then
		self.list_indent = false
	end
end



function app:close_open_tags (level)
	self:close_paragraph ()
	self:close_lists_to_level (level)
end



function app:parse_input ()
	self.output = self.docs[#self.docs].doc

	for l = 1, #self.raw do
		local lt, level, text = parse_line (self.raw[l])

		if self.code_open then
			if lt == CODE_BLOCK then
				self.output[#self.output + 1] = { type = DOCFORMAT, text = "</pre>" }
				self.code_open = false
			else
				self.output[#self.output + 1] = { type = TEXT_CODE, text = text }
			end

		elseif lt == TEXT then

			if self.list_indent then
				if self.paragraph_open and self.output[#self.output].type == PARAGRAPH then
					table.remove (self.output, #self.output)
					self.paragraph_open = false
				end

				local spaces = text:match ("^%s*")
				local pre = string.rep ("&nbsp;", spaces:len ())
				self.output[#self.output + 1] =
				{
					type = TEXT_BREAK,
					text = pre..trim_left (text)
				}

			elseif #self.list_item == 0 and text:sub (1, 1) == " " then
				if self.paragraph_open and self.output[#self.output].type == PARAGRAPH then
					table.remove (self.output, #self.output)
					self.paragraph_open = false
				end

				local spaces = text:match ("^%s*")
				local pre = string.rep ("&nbsp;", spaces:len ())
				self.output[#self.output + 1] =
				{
					type = TEXT_BREAK,
					text = pre..trim_left (text)
				}

			else
				if #self.output > 0 and self.output[#self.output].type == TEXT then
					self.output[#self.output].text =
						self.output[#self.output].text.." "..text

				else
					self.output[#self.output + 1] = { type = TEXT, text = text }

				end

			end

		elseif lt == HEADING_1 then
			if #self.output > 0 then
				local entry = table.remove (self.output, #self.output)
				local name = clean_name (entry.text)

				self:close_open_tags (0)

				self.docs[#self.docs + 1] =
				{
					title = name,
					name = name:gsub (" ", "_"),
					doc = { }
				}

				self.output = self.docs[#self.docs].doc

				self.output[#self.output + 1] =
				{
					type = HEADING_1,
					text = entry.text,
					anchor = clean_name (entry.text)
				}
			end

		elseif lt == HEADING_2 then
			if #self.output > 0 then
				text = table.remove (self.output, #self.output).text

				self:close_open_tags (0)

				self.output[#self.output + 1] =
				{
					type = HEADING_2,
					text = text,
					anchor = clean_name (text)
				}
			end

		elseif lt == HEADING_3 then
			self:close_open_tags (0)

			self.output[#self.output + 1] =
			{
				type = HEADING_3,
				text = text,
				anchor = clean_name (text)
			}

		elseif lt == HEADING_4 then
			self:close_open_tags (0)

			self.output[#self.output + 1] =
			{
				type = HEADING_4,
				text = text,
				anchor = clean_name (text)
			}

		elseif lt == CODE_BLOCK then
			self:close_open_tags (0)
			self.output[#self.output + 1] = { type = CODE_BLOCK, text = "<pre>" }
			self.code_open = true

		elseif lt == PARAGRAPH then
			self:close_paragraph ()

			if #self.list_item > 0 then
				self.list_indent = true
			else
				self.output[#self.output + 1] = { type = PARAGRAPH, text = "<p>" }
				self.paragraph_open = true
			end

		elseif lt == LIST_ITEM then
			self:close_open_tags (level)

			self.list_indent = false

			if level > #self.list_item then
				if level == 1 then
					self.output[#self.output + 1] = { type = DOCFORMAT, text = "<ul>" }
				else
					self.output[#self.output + 1] = { type = DOCFORMAT, text = "<ul>" }
				end
				self.output[#self.output + 1] = { type = DOCFORMAT, text = "<li>" }
				self.output[#self.output + 1] = { type = TEXT, text = text }

				self.list_item[level] = 1

			else
				self.output[#self.output + 1] = { type = DOCFORMAT, text = "</li>" }
				self.output[#self.output + 1] = { type = DOCFORMAT, text = "<li>" }
				self.output[#self.output + 1] = { type = TEXT, text = text }

				self.list_item[level] = self.list_item[level] + 1
			end

		elseif lt == TABLE_ROW then
			self.output[#self.output + 1] = { type = TABLE_ROW, text = text }

		end
	end

	self:close_open_tags (0)

	return true
end



local function fix_to_level (file, level, cur_level)
	while cur_level > level do
		file:write ("</ul>\n")
		cur_level = cur_level - 1
	end

	while cur_level < level do
		file:write ("<ul>\n")
		cur_level = cur_level + 1
	end

	return cur_level
end



local function get_table_cells (row)
	if row:sub (1, 1) ~= "|" then
		return nil
	end

	local copy = row:sub (2)
	local cells = { }

	for cell in string.gmatch (copy, "[^|]+") do
		cells[#cells + 1] = cell
	end

	return cells
end



local function get_table_alignments (row)
	local cells = get_table_cells (row)

	if not cells then
		return nil
	end

	for c = 1, #cells do
		cells[c] = trim (cells[c])

		while cells[c]:find ("--", 1, true) do
			cells[c] = cells[c]:gsub ("%-%-", "-")
		end

		if cells[c] == "-" or cells[c] == ":-" then
			cells[c] = "left"
		elseif cells[c] == "-:" then
			cells[c] = "right"
		elseif cells[c] == ":-:" then
			cells[c] = "center"
		else
			return nil
		end
	end

	return cells
end




function app:get_table_row (doc, idx, table_row, table_cells, align)
	local cells = get_table_cells (doc[idx].text)

	if not cells then
		return nil
	end

	local out = "<tr>\n"

	if table_row == 0 then
		out = "<table>\n <tr>\n"

		if doc[idx + 1] and doc[idx + 1].type == TABLE_ROW then
			local aligns = get_table_alignments (doc[idx + 1].text)

			if aligns then
				for c = 1, #cells do
					local cell = parse_inline (cells[c] or "")

					if cell == "" then
						cell = "&nbsp;"
					end

					if aligns[c] then
						out = out..
						"  <th style=\"text-align:"..aligns[c]..";\">"..cell.."</th>\n"
					else
						out = out..
						"  <th>"..cell.."</th>\n"
					end
				end

				out = out.." </tr>"

				return out, -1, #cells, aligns
			end
		end

		table_cells = #cells

	elseif table_row == -1 then
		-- is alignment row
		return nil, 1, table_cells, align

	end

	for c = 1, table_cells do
		local cell = parse_inline (cells[c] or "")

		if cell == "" then
			cell = "&nbsp;"
		end

		if align and align[c] then
			out = out..
			"  <td style=\"text-align:"..align[c]..";\">"..cell.."</td>\n"
		else
			out = out..
			"  <td>"..cell.."</td>\n"
		end
	end

	out = out.." </tr>"

	return out, table_row + 1, table_cells, align
end



function app:write_out_contents ()
	local file = io.open (self.outdir.."index.html", "w")

	if not file then
		print ("Could not write output file \""..self.outdir..name..".html\"")

		return false
	end

	file:write ("<!DOCTYPE html>\n")
	file:write ("<html>\n")
	file:write ("<head>\n")
	file:write (" <link rel=\"stylesheet\" href=\"minetest.css\">\n")
	file:write ("<head>\n")
	file:write ("<body>\n")
	file:write ("<p class=\"nav\"><a href=\"index.html#contents\">Contents</a>, "..
				   "<a href=\"full_index.html\">Index</a></p>\n")

	local table_row = 0
	local table_cells = 0
	local table_align = nil

	local doc = self.docs[2].doc

	for l = 1, #doc do
		local text = doc[l].text

		if doc[l].type == HEADING_1 then
			text = "<h1 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h1>"

		elseif doc[l].type == HEADING_2 then
			text = "<h2 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h2>"

		elseif doc[l].type == HEADING_3 then
			text = "<h3 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h3>"

		elseif doc[l].type == HEADING_4 then
			text = "<h4 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h4>"

		elseif doc[l].type == TEXT_CODE then
			text = parse_symbols (text)

		elseif doc[l].type == TEXT then
			text = parse_inline (text)

		elseif doc[l].type == TEXT_BREAK then
			if doc[l - 1] and (doc[l - 1].type == TEXT_BREAK or doc[l - 1].type == TEXT) then
				text = "<br>\n"..parse_inline (text)
			else
				text = parse_inline (text)
			end

		elseif doc[l].type == TABLE_ROW then
			text, table_row, table_cells, table_align =
				self:get_table_row (doc, l, table_row, table_cells, table_align)

			if not table_row then
				return false
			end

		end

		if text then
			file:write (text.."\n")
		end
	end

	file:write ("<hr>\n")
	file:write ("<h2 id=\"contents\">Contents</h2>\n")
	file:write ("<ul>\n")

	for d = 3, #self.docs do
		local doc = self.docs[d].doc

		if #doc > 1 then
			local name = self.docs[d].title:gsub (" ", "_")
			local file_name = self.docs[d].title:gsub (" ", "_")..".html"

			for l = 1, #doc do
				text = nil

				if doc[l].type == HEADING_1 then

					local text = "<li>\n"..
									 "<a href=\""..file_name.."\">"..parse_inline (doc[l].text).."</a>, "..
									 "[<a href=\"full_index.html#"..name.."\">index</a>]\n"..
									 "</li>\n"


					file:write (text)
				end
			end
		end
	end

	file:write ("</ul>\n")

	file:write ("<p class=\"nav\"><a href=\"index.html#contents\">Contents</a>, "..
				   "<a href=\"full_index.html\">Index</a></p>\n")
	file:write ("</body>\n")
	file:write ("</html>\n")

	file:close ()

	return true
end



function app:write_out_index ()
	local file = io.open (self.outdir.."full_index.html", "w")

	if not file then
		print ("Could not write output file \""..self.outdir..name..".html\"")

		return false
	end

	file:write ("<!DOCTYPE html>\n")
	file:write ("<html>\n")
	file:write ("<head>\n")
	file:write (" <link rel=\"stylesheet\" href=\"minetest.css\">\n")
	file:write ("<head>\n")
	file:write ("<body>\n")
	file:write ("<p class=\"nav\"><a href=\"index.html#contents\">Contents</a>, "..
				   "<a href=\"full_index.html\">Index</a></p>\n")
	file:write ("<h2>Index</h2>\n")

	local level = 1

	file:write ("<ul>\n")

	for d = 3, #self.docs do
		local name = self.docs[d].title:gsub (" ", "_")
		local doc = self.docs[d].doc

		if #doc > 1 then
			local file_name = self.docs[d].title:gsub (" ", "_")..".html"

			for l = 1, #doc do
				local text = nil

				if doc[l].type == HEADING_1 then
					level = fix_to_level (file, 1, level)

					text = "<li>\n"..
							 "<a href=\""..file_name.."\" id=\""..self.docs[d].name.."\">"..
							 parse_inline (doc[l].text).."</a>\n"..
							 "</li>\n"

				elseif doc[l].type == HEADING_2 then
					level = fix_to_level (file, 2, level)

					text = "<li>\n"..
							 "<a href=\""..file_name.."#"..doc[l].anchor.."\">"..
							 parse_inline (doc[l].text).."</a>\n"..
							 "</li>\n"

				elseif doc[l].type == HEADING_3 then
					level = fix_to_level (file, 3, level)

					text = "<li>\n"..
							 "<a href=\""..file_name.."#"..doc[l].anchor.."\">"..
							 parse_inline (doc[l].text).."</a>\n"..
							 "</li>\n"

				elseif doc[l].type == HEADING_4 then
					level = fix_to_level (file, 4, level)

					text = "<li>\n"..
							 "<a href=\""..file_name.."#"..doc[l].anchor.."\">"..
							 parse_inline (doc[l].text).."</a>\n"..
							 "</li>\n"

				end

				if text then
					file:write (text)
				end

			end

		end
	end

	fix_to_level (file, 1, level)
	file:write ("</ul>\n")

	file:write ("<p class=\"nav\"><a href=\"index.html#contents\">Contents</a>, "..
				   "<a href=\"full_index.html\">Index</a></p>\n")
	file:write ("</body>\n")
	file:write ("</html>\n")

	file:close ()

	return true
end



function app:write_out_topic (idx)
	local doc = self.docs[idx].doc

	if #doc > 1 then
		local name = self.docs[idx].name
		local file = io.open (self.outdir..name..".html", "w")

		if not file then
			print ("Could not write output file \""..self.outdir..name..".html\"")

			return false
		end

		file:write ("<!DOCTYPE html>\n")
		file:write ("<html>\n")
		file:write ("<head>\n")
		file:write (" <link rel=\"stylesheet\" href=\"minetest.css\">\n")
		file:write ("<head>\n")
		file:write ("<body>\n")
		file:write ("<p class=\"nav\"><a href=\"index.html#contents\">Contents</a>, <a href=\"full_index.html#"..
						name.."\">Index</a></p>\n")

		local table_row = 0
		local table_cells = 0
		local table_align = nil

		for l = 1, #doc do
			local text = doc[l].text

			if table_row ~= 0 and doc[l].type ~= TABLE_ROW then
				file:write ("</table>\n")
				table_row = 0
			end

			if doc[l].type == HEADING_1 then
				text = "<h1 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h1>"

			elseif doc[l].type == HEADING_2 then
				text = "<h2 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h2>"

			elseif doc[l].type == HEADING_3 then
				text = "<h3 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h3>"

			elseif doc[l].type == HEADING_4 then
				text = "<h4 id=\""..doc[l].anchor.."\">"..parse_inline (text).."</h4>"

			elseif doc[l].type == TEXT_CODE then
				text = parse_symbols (text)

			elseif doc[l].type == TEXT then
				text = parse_inline (text)

			elseif doc[l].type == TEXT_BREAK then
				if doc[l - 1] and (doc[l - 1].type == TEXT_BREAK or doc[l - 1].type == TEXT) then
					text = "<br>\n"..parse_inline (text)
				else
					text = parse_inline (text)
				end

			elseif doc[l].type == TABLE_ROW then
				text, table_row, table_cells, table_align =
					self:get_table_row (doc, l, table_row, table_cells, table_align)

				if not table_row then
					return false
				end
			end

			if text then
				file:write (text.."\n")
			end
		end

		file:write ("<p class=\"nav\"><a href=\"index.html#contents\">Contents</a>, <a href=\"full_index.html#"..
						name.."\">Index</a></p>\n")
		file:write ("<br>\n")
		file:write ("</body>\n")
		file:write ("</html>\n")

		file:close ()
	end

	return true
end



local g_stylesheet = [[
body {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
}

code {
	font-family: "Lucida Console", "Courier New", monospace;
	font-size: 16px;
}

pre {
	font-family: "Lucida Console", "Courier New", monospace;
	font-size: 16px;
}

h1 {
	color: black;
	background-color: #A5DDF0;
	margin-top: 0px;
	padding-top: 20px;
	padding-left: 10px;
	padding-bottom: 20px;
	padding-right: 10px;
}

ul {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
	line-height: 1;
}

li {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
	line-height: 1.5;
}

a {
	text-decoration: none;
}

hr {
	border: 1px solid #83B0BF;
}

table {
	border-collapse: collapse;
	border: 1px solid #83B0BF;
}

th {
	color: black;
	background-color: #A5DDF0;
	padding-top: 5px;
	padding-left: 5px;
	padding-bottom: 5px;
	padding-right: 5px;
	border: 1px solid #83B0BF;
}

td {
	color: black;
	background-color: white;
	padding-top: 5px;
	padding-left: 5px;
	padding-bottom: 5px;
	padding-right: 5px;
	border: 1px solid #83B0BF;
}

.nav {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
	color: black;
	background-color: #9CD1E3;
	padding-top: 20px;
	padding-left: 10px;
	padding-bottom: 20px;
	padding-right: 10px;
	margin-top: 0px;
	margin-bottom: 0px;
}
]]



function app:check_stylesheet ()
	local file = io.open (self.outdir.."minetest.css", "r")

	if not file then
		file = io.open (self.outdir.."minetest.css", "w")

		if file then
			file:write (g_stylesheet)
			file:close ()
		end
	end
end



function app:write_out ()
	g_docs = self.docs

	self:check_stylesheet ()

	for idx = 3, #self.docs do
		if not self:write_out_topic (idx) then
			return false
		end
	end

	if not self:write_out_index () then
		return false
	end

	if not self:write_out_contents () then
		return false
	end

	return true
end



function app:run ()
	if self.help then
		print ("   lua makedoc.lua [OPTIONS] infile outdir\n"..
				 "\n"..
				 "Creates HTML output from tagged input file.\n"..
				 "\n"..
				 "Options\n"..
				 "   -h, --help   show help\n"..
				 "\n"..
				 "infile   input file to read\n"..
				 "\n"..
				 "outdir   dir to put output files - must exist.\n"..
				 "\n")

		return 0
	end


	if not self:read_input () then
		print ("Could not read input file \""..self.infile.."\"")

		return 1
	end

	if not self:parse_input () then
		print ("Error parsing input")

		return 2
	end

	if not self:write_out () then
		return 3
	end

	return 0
end



return app:new ( ... ):run ()



--
