


local g_stylesheet = [[
body {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
}

code {
	font-family: "Lucida Console", "Courier New", monospace;
}

pre {
	font-family: "Lucida Console", "Courier New", monospace;
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

.line1 {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 14px;
	line-height: 2.0;
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
	border-style: none;
	width: 98.5%;
}

.search {
	margin-top: 10px;
	margin-bottom: 10px;
	margin-left: 10px;
	margin-right: 10px;
	padding-top: 10px;
	padding-bottom: 10px;
	padding-left: 10px;
	padding-right: 10px;
	border-style: solid;
	border-color: #83B0BF;
	border-width: 1px;
	background-color: #FFFFFF;
}

.searchbg {
	background-color: #9CD1E3;
	margin-top: 0px;
	margin-bottom: 0px;
	margin-left: 0px;
	margin-right: 0px;
	padding-top: 0px;
	padding-bottom: 0px;
	padding-left: 0px;
	padding-right: 0px;
}
]]



local g_jsfile = [[


var files = [
%s
];



function get_search_term ()
{
	var st = document.getElementById ("search_term");

	if (st)
	{
		return st.value;
	}

	return undefined;
}



function show_search_results ()
{
	var sr = document.getElementById ("search_results");

	if (sr)
	{
		sr.style.display = "block";
	}
}



function hide_search_results ()
{
	var sr = document.getElementById ("search_results");

	if (sr)
	{
		sr.style.display = "none";
	}
}



function start_search (term)
{
	var src = document.getElementById ("search_results_contents");

	if (src)
	{
		src.innerHTML = "<p>Search results for \"" + term + "\"</p>";
	}
}



function end_search (found)
{
	var src = document.getElementById ("search_results_contents");

	if (src)
	{
		src.innerHTML += "<p>" + found.toString () + " results found.</p>";
	}
}



function add_search_result (file)
{
	var src = document.getElementById ("search_results_contents");

	if (src)
	{
		src.innerHTML += "<p><a href=\"" + file[0] + "\">" + file[1] + "</a></p>";
	}
}



function search ()
{
	var term = get_search_term ();

	if (term && term.length > 0)
	{
		var found = 0;

		term = term.toLowerCase();

		start_search (term);

		show_search_results ();

		var file;

		for (file of files)
		{
			let content = file[2].toLowerCase();

			if (content.search (term) > -1)
			{
				add_search_result (file);
				found += 1;
			}
		}

		end_search (found);
	}
}



function term_key ()
{
	if (event.key == "Enter")
	{
		search ();
	}
}
]]



local g_contents_prefix = [[
<!DOCTYPE html>
<html>
	<head>
		<title>%s</title>
		<link rel="stylesheet" href="minetest.css">
		<script type="text/javascript" src="search.js"></script>
	</head>

	<body>
		<div>
			<table class="nav" style="width: 100%%">
				<tr class="nav">
					<td style="text-align: left;" class="nav">
						<a href="index.html#contents">Contents</a>, <a href="full_index.html">Index</a>
					</td>
					<td style="text-align: right;" class="nav">
						<input type="text" id="search_term" name="search_term" onkeydown="term_key ();">
					</td>
					<td style="text-align: right;" class="nav">
						<button type="button" onclick="search ();" id="searchbtn" name="searchbtn">Search</button>
					</td>
				</tr>
			</table>
		</div>

		<div id="search_results" style="display: none;" class="searchbg">
			<button type="button" onclick="hide_search_results ();" id="hide_results" name="hide_results">Hide</button>
			<div id="search_results_contents" class="search">
			</div>
		</div>

]]



local g_contents_postfix = [[
		<p class="nav"><a href="index.html#contents">Contents</a>, <a href="full_index.html">Index</a></p>
	</body>
</html>
]]



local g_topic_prefix = [[
<!DOCTYPE html>
<html>
	<head>
		<title>%s</title>
		<link rel="stylesheet" href="minetest.css">
		<script type="text/javascript" src="search.js"></script>
	</head>

	<body>
		<div>
			<table class="nav" style="width: 100%%">
				<tr class="nav">
					<td style="text-align: left;" class="nav">
						<a href="index.html#contents">Contents</a>, <a href="full_index.html#%s">Index</a>
					</td>
					<td style="text-align: right;" class="nav">
						<input type="text" id="search_term" name="search_term" onkeydown="term_key ();">
					</td>
					<td style="text-align: right;" class="nav">
						<button type="button" onclick="search ();" id="searchbtn" name="searchbtn">Search</button>
					</td>
				</tr>
			</table>
		</div>

		<div id="search_results" style="display: none;" class="searchbg">
			<button type="button" onclick="hide_search_results ();" id="hide_results" name="hide_results">Hide</button>
			<div id="search_results_contents" class="search">
			</div>
		</div>

]]



local g_topic_postfix = [[
		<p class="nav"><a href="index.html#contents">Contents</a>, <a href="full_index.html#%s">Index</a></p>
	</body>
</html>
]]



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
	text = text:gsub ("&", "&amp;")
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



local function parse_text_break (text)
	text = parse_inline (text)

	local spaces = text:match ("^%s*")

	if spaces:len () > 0 then
		local pre = string.rep ("&nbsp;", spaces:len ())

		text = pre..trim_left (text)
	end

	return text
end



local function clean_markdown (text)
	return text:gsub ("`", ""):gsub ("##", "")
end



local function indent (level)
	return string.rep ("\t", level)
end



local function cat ( ... )
	return table.concat ( { ... } )
end



local function icat (level, ... )
	return indent (level)..table.concat ( { ... } )
end



local app = { }



-- constructor
function app:new ( ... )
	local args = { ... }
	local obj = { }

   setmetatable(obj, self)
   self.__index = self

   obj.help = false
	obj.max_lines = 500
   obj.infile = nil
   obj.outdir = nil

   local mode = ""
   for i = 1, #args do
		if mode == "-m" then
			obj.max_lines = tonumber (args[i] or 0) or 0
			mode = ""
		else
			if i == 1 and (args[i] == "-h" or args[i] == "--help") then
				obj.help = true
			elseif i == 1 and (args[i] == "-m" or args[i] == "--max_lines") then
				mode = "-m"
			elseif obj.infile then
				obj.outdir = args[i]
			elseif obj.outdir then
				obj.help = true
			else
				obj.infile = args[i]
			end
		end
	end

	if not obj.help then
		if obj.max_lines < 1 or not obj.infile or not obj.outdir then
			obj.help = true
		end
	end

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



function app:close_paragraph (level)
	if self.paragraph_open then
		if self.output[#self.output].type == PARAGRAPH then
			table.remove (self.output, #self.output)
		else
			self.output[#self.output + 1] =
			{
				type = DOCFORMAT,
				text = icat ((level or 0) + 2, "</p>\n")
			}
		end
	end

	self.paragraph_open = false
end



function app:close_lists_to_level (level)
	while level < #self.list_item do
		self.output[#self.output + 1] =
		{
			type = DOCFORMAT,
			text = icat (#self.list_item + 3, "</li>\n")
		}
		self.output[#self.output + 1] =
		{
			type = DOCFORMAT,
			text = icat (#self.list_item + 2, "</ul>\n")
		}

		table.remove (self.list_item, #self.list_item)
	end

	if level < 1 then
		self.list_indent = false
	end
end



function app:close_open_tags (level)
	self:close_lists_to_level (level)
	self:close_paragraph (level)
end



function app:parse_lines ()
	self.output = self.docs[#self.docs].doc

	for l = 1, #self.raw do
		local lt, level, text = parse_line (self.raw[l])

		if self.code_open then
			if lt == CODE_BLOCK then
				self.output[#self.output + 1] =
				{
					type = DOCFORMAT,
					text = "</pre>"
				}

				self.code_open = false

			else
				self.output[#self.output + 1] =
				{
					type = TEXT_CODE,
					text = text
				}
			end

		elseif lt == TEXT then

			if self.list_indent then
				if self.paragraph_open and self.output[#self.output].type == PARAGRAPH then
					table.remove (self.output, #self.output)
					self.paragraph_open = false
				end

				self.output[#self.output + 1] =
				{
					type = TEXT_BREAK,
					text = text
				}

			elseif #self.list_item == 0 and text:sub (1, 1) == " " then
				if self.paragraph_open and self.output[#self.output].type == PARAGRAPH then
					table.remove (self.output, #self.output)
					self.paragraph_open = false
				end

				self.output[#self.output + 1] =
				{
					type = TEXT_BREAK,
					text = text
				}

			else
				if #self.output > 0 and self.output[#self.output].type == TEXT then
					self.output[#self.output].text =
						self.output[#self.output].text.." "..text

				else
					self.output[#self.output + 1] =
					{
						type = TEXT,
						text = text
					}

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
			self.output[#self.output + 1] =
			{
				type = CODE_BLOCK,
				text = icat ((level or 0) + 2, "<pre>\n")
			}
			self.code_open = true

		elseif lt == PARAGRAPH then
			self:close_paragraph (0)

			if #self.list_item > 0 then
				self.list_indent = true
			else
				self.output[#self.output + 1] =
				{
					type = PARAGRAPH,
					text = icat ((level or 0) + 2, "<p>\n")
				}
				self.paragraph_open = true
			end

		elseif lt == LIST_ITEM then
			self:close_open_tags (level)

			self.list_indent = false

			if level > #self.list_item then
				self.output[#self.output + 1] =
				{
					type = DOCFORMAT,
					text = icat (level + 2, "<ul>\n")
				}

				if level == 1 then
					self.output[#self.output + 1] =
					{
						type = DOCFORMAT,
						text = icat (level + 3, "<li class=\"line1\">\n")
					}

				else
					self.output[#self.output + 1] =
					{
						type = DOCFORMAT,
						text = icat (level + 3, "<li>\n")
					}

				end

				self.output[#self.output + 1] =
				{
					type = TEXT,
					text = text
				}

				self.list_item[level] = 1

			else
				self.output[#self.output + 1] =
				{
					type = DOCFORMAT,
					text = icat (level + 3, "</li>\n")
				}

				if level == 1 then
					self.output[#self.output + 1] =
					{
						type = DOCFORMAT,
						text = icat (level + 3, "<li class=\"line1\">\n")
					}
				else
					self.output[#self.output + 1] =
					{
						type = DOCFORMAT,
						text = icat (level + 3, "<li>\n")
					}
				end

				self.output[#self.output + 1] =
				{
					type = TEXT,
					text = text
				}

				self.list_item[level] = self.list_item[level] + 1
			end

		elseif lt == TABLE_ROW then
			self.output[#self.output + 1] =
			{
				type = TABLE_ROW,
				text = text
			}

		end
	end

	self:close_open_tags (0)

	return true
end



function app:expand_output ()
	local docs = { }
	local curdoc = { }

	docs[1] = self.docs[2]
	docs[1].file_name = "index.html"
	docs[1].contents = ""

	for d = 3, #self.docs do
		if #self.docs[d].doc <= self.max_lines then
			docs[#docs + 1] = self.docs[d]
			docs[#docs].file_name = docs[#docs].name..".html"
			docs[#docs].contents = ""

		else
			local title = self.docs[d].title
			local name = self.docs[d].name
			local doc = self.docs[d].doc

			for l = 1, #doc do
				if doc[l].type == HEADING_1 then
					-- ignore it, promoting following

				elseif doc[l].type == HEADING_2 then
					docs[#docs + 1] =
					{
						title = title..", "..clean_name (doc[l].text),
						name = name.."_"..clean_name (doc[l].text):gsub (" ", "_"),
						file_name = name.."_"..clean_name (doc[l].text):gsub (" ", "_")..".html",
						contents = "",
						doc = { }
					}

					curdoc = docs[#docs].doc

					curdoc[#curdoc + 1] =
					{
						type = HEADING_1,
						text = doc[l].text,
						anchor = doc[l].anchor
					}

				elseif doc[l].type == HEADING_3 then
					curdoc[#curdoc + 1] =
					{
						type = HEADING_2,
						text = doc[l].text,
						anchor = doc[l].anchor
					}

				elseif doc[l].type == HEADING_4 then
					curdoc[#curdoc + 1] =
					{
						type = HEADING_3,
						text = doc[l].text,
						anchor = doc[l].anchor
					}

				else
					curdoc[#curdoc + 1] =
					{
						type = doc[l].type,
						text = doc[l].text
					}

				end
			end
		end
	end

	self.docs = docs

	return true
end



function app:parse_input ()
	if not self:parse_lines () then
		return false
	end

	if not self:expand_output () then
		return false
	end

	return true
end



local function fix_to_level (file, level, cur_level)
	while cur_level > level do
		cur_level = cur_level - 1
		file:write (icat (cur_level + 2, "</ul>\n"))
	end

	while cur_level < level do
		file:write (icat (cur_level + 2, "<ul>\n"))
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
	local contents = ""

	if table_row == 0 then
		out = "<table>\n <tr>\n"

		if doc[idx + 1] and doc[idx + 1].type == TABLE_ROW then
			local aligns = get_table_alignments (doc[idx + 1].text)

			if aligns then
				for c = 1, #cells do
					local cell = parse_inline (cells[c] or "")

					contents = contents..(cells[c] or "").." "

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

				return out, -1, #cells, aligns, contents
			end
		end

		table_cells = #cells

	elseif table_row == -1 then
		-- is alignment row
		return nil, 1, table_cells, align, ""

	end

	for c = 1, table_cells do
		local cell = parse_inline (cells[c] or "")

		contents = contents..(cells[c] or "").." "

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

	return out, table_row + 1, table_cells, align, contents
end



function app:write_out_contents ()
	local file = io.open (self.outdir..self.docs[1].file_name, "w")
	local contents = ""

	if not file then
		print ("Could not write output file \""..self.outdir..name..".html\"")

		return false
	end

	file:write (string.format (g_contents_prefix, self.docs[1].title))

	local table_row = 0
	local table_cells = 0
	local table_align = nil

	local doc = self.docs[1].doc

	for l = 1, #doc do
		local text = doc[l].text

		if doc[l].type == HEADING_1 then
			contents = contents..clean_markdown (text).." "

			text = icat (2, "<h1 id=\"", doc[l].anchor, "\">", parse_inline (text), "</h1>\n")

		elseif doc[l].type == HEADING_2 then
			contents = contents..clean_markdown (text).." "

			text = icat (2, "<h2 id=\"", doc[l].anchor, "\">", parse_inline (text), "</h2>\n")

		elseif doc[l].type == HEADING_3 then
			contents = contents..clean_markdown (text).." "

			text = icat (2, "<h3 id=\"", doc[l].anchor, "\">", parse_inline (text), "</h3>\n")

		elseif doc[l].type == HEADING_4 then
			contents = contents..clean_markdown (text).." "

			text = icat (2, "<h4 id=\"", doc[l].anchor, "\">", parse_inline (text), "</h4>\n")

		elseif doc[l].type == TEXT_CODE then
			contents = contents..text.." "

			text = parse_symbols (text)

		elseif doc[l].type == TEXT then
			contents = contents..clean_markdown (text).." "

			text = parse_inline (text).."\n"

		elseif doc[l].type == TEXT_BREAK then
			contents = contents..clean_markdown (text).." "

			if doc[l - 1] and (doc[l - 1].type == TEXT_BREAK or doc[l - 1].type == TEXT) then
				text = "<br>\n"..parse_text_break (text).."\n"
			else
				text = parse_text_break (text).."\n"
			end

		elseif doc[l].type == TABLE_ROW then
			local str = nil

			text, table_row, table_cells, table_align, str =
				self:get_table_row (doc, l, table_row, table_cells, table_align)

			if not table_row then
				return false
			end

			if text then
				text = text.."\n"
			end

			contents = contents..str
		end

		if text then
			file:write (text)
		end
	end

	self.docs[1].contents = contents

	file:write (icat (2, "<hr>\n"))
	file:write (icat (2, "<h2 id=\"contents\">Contents</h2>\n"))
	file:write (icat (2, "<ul>\n"))

	for d = 3, #self.docs do
		local doc = self.docs[d].doc

		if #doc > 1 then
			for l = 1, #doc do
				text = nil

				if doc[l].type == HEADING_1 then

					local text = icat (3,
						"<li>", "<a href=\"", self.docs[d].file_name, "\">", self.docs[d].title, "</a>, ",
						"[<a href=\"full_index.html#", self.docs[d].name, "\">index</a>]", "</li>\n")

					file:write (text)
				end
			end
		end
	end

	file:write (icat (2, "</ul>\n"))

	file:write (g_contents_postfix)

	file:close ()

	return true
end



function app:write_out_index ()
	local file = io.open (self.outdir.."full_index.html", "w")

	if not file then
		print ("Could not write output file \"full_index.html\"")

		return false
	end

	file:write (string.format (g_contents_prefix, "Index"))

	file:write (icat (2, "<h1>Index</h1>\n"))

	local level = 1

	file:write (icat (2, "<ul>\n"))

	for d = 3, #self.docs do
		local doc = self.docs[d].doc

		if #doc > 1 then
			for l = 1, #doc do
				local text = nil

				if doc[l].type == HEADING_1 then
					level = fix_to_level (file, 1, level)

					text = icat (1 + 2,
						"<li>", "<a href=\"", self.docs[d].file_name, "\" id=\"",
						self.docs[d].name, "\">", self.docs[d].title, "</a>", "</li>\n")

				elseif doc[l].type == HEADING_2 then
					level = fix_to_level (file, 2, level)

					text = icat (2 + 2,
						"<li>", "<a href=\"", self.docs[d].file_name, "#", doc[l].anchor, "\">",
						parse_inline (doc[l].text), "</a>", "</li>\n")

				elseif doc[l].type == HEADING_3 then
					level = fix_to_level (file, 3, level)

					text = icat (3 + 2,
						"<li>", "<a href=\"", self.docs[d].file_name, "#", doc[l].anchor, "\">",
						parse_inline (doc[l].text), "</a>", "</li>\n")

				elseif doc[l].type == HEADING_4 then
					level = fix_to_level (file, 4, level)

					text = icat (4 + 2,
						"<li>", "<a href=\"", self.docs[d].file_name, "#", doc[l].anchor, "\">",
						parse_inline (doc[l].text), "</a>", "</li>\n")

				end

				if text then
					file:write (text)
				end

			end

		end
	end

	fix_to_level (file, 1, level)
	file:write (icat (2, "</ul>\n"))

	file:write (g_contents_postfix)

	file:close ()

	return true
end



function app:write_out_topic (idx)
	local doc = self.docs[idx].doc
	local contents = ""

	if #doc > 1 then
		local file = io.open (self.outdir..self.docs[idx].file_name, "w")

		if not file then
			print ("Could not write output file \""..self.docs[idx].file_name.."\"")

			return false
		end

		file:write (string.format (g_topic_prefix, self.docs[idx].title, self.docs[idx].name))

		local table_row = 0
		local table_cells = 0
		local table_align = nil

		for l = 1, #doc do
			local text = doc[l].text

			if table_row ~= 0 and doc[l].type ~= TABLE_ROW then
				file:write (icat (2, "</table>\n"))
				table_row = 0
			end

			if doc[l].type == HEADING_1 then
				contents = contents..clean_markdown (text).." "

				text = icat (2, "<h1 id=\"", doc[l].anchor, "\">", self.docs[idx].title, "</h1>\n")

			elseif doc[l].type == HEADING_2 then
				contents = contents..clean_markdown (text).." "

				text = icat (2, "<h2 id=\"", doc[l].anchor, "\">", parse_inline (text), "</h2>\n")

			elseif doc[l].type == HEADING_3 then
				contents = contents..clean_markdown (text).." "

				text = icat (2, "<h3 id=\"", doc[l].anchor, "\">", parse_inline (text), "</h3>\n")

			elseif doc[l].type == HEADING_4 then
				contents = contents..clean_markdown (text).." "
				text = icat (2, "<h4 id=\"", doc[l].anchor, "\">", parse_inline (text), "</h4>\n")

			elseif doc[l].type == TEXT_CODE then
				contents = contents..text.." "

				text = parse_symbols (text).."\n"

			elseif doc[l].type == TEXT then
				contents = contents..clean_markdown (text).." "

				text = parse_inline (text).."\n"

			elseif doc[l].type == TEXT_BREAK then
				contents = contents..clean_markdown (text).." "

				if doc[l - 1] and (doc[l - 1].type == TEXT_BREAK or doc[l - 1].type == TEXT) then
					text = "<br>\n"..parse_text_break (text).."\n"
				else
					text = parse_text_break (text).."\n"
				end

			elseif doc[l].type == TABLE_ROW then
				local str = nil

				text, table_row, table_cells, table_align, str =
					self:get_table_row (doc, l, table_row, table_cells, table_align)

				if not table_row then
					return false
				end

				if text then
					text = text.."\n"
				end

				contents = contents..str
			end

			if text then
				file:write (text)
			end
		end

		self.docs[idx].contents = contents

		file:write (string.format (g_topic_postfix, self.docs[idx].name))

		file:close ()
	end

	return true
end



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



function app:write_out_js ()
	local strs = ""

	for d = 1, #self.docs do
		if d < #self.docs then
			strs = strs..string.format ("	[ %q, %q, %q ],\n",
												 self.docs[d].file_name,
												 self.docs[d].title,
												 self.docs[d].contents)
		else
			strs = strs..string.format ("	[ %q, %q, %q ]",
												 self.docs[d].file_name,
												 self.docs[d].title,
												 self.docs[d].contents)
		end
	end

	local file = io.open (self.outdir.."search.js", "w")

	if not file then
			print ("Could not write output file \"search.js\"")

		return false
	end

	file:write (string.format (g_jsfile, strs))

	file:close ()

	return true
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

	if not self:write_out_js () then
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
				 "   -h, --help        show help.\n"..
				 "   -m, --max_lines   followed by the max lines on a page\n"..
				 "                     before it's split into more than one\n"..
				 "                     page.\n"..
				 "\n"..
				 "infile   input file to read.\n"..
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
