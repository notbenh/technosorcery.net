local to_ext = {
	['text/xml'] = '.xml',
	['application/xml'] = '.xml',
	['text/html'] = '.html',
	['application/xhtml+xml'] = '.xhtml',
}
local fallback = { 'text/html' }

function file_exists(path)
	-- checks whether a file exists; stolen from darix... thanks :)
	local attr = lighty.stat(path)
	if (attr) then
		return true
	else
		return false
	end
end

function in_list(table, element)
	for i, e in ipairs(table) do
		if e == element then
			return true
		end
	end
	return false
end

function iterate(t1, t2)
	-- iterates over two tables
	local tn = 1
	local i = 0
	local function it(t1, t2)
		i = i + 1
		if tn == 1 and t1[i] then
			t = t1
		else
			t = t2
			tn = 2
		end
		return t[i]
	end
	return it, t1, t2
end

function split(str, delimiter)
	-- generic split function
	local t = {}
	local function helper(line)
		table.insert(t, line)
		return ""
	end
	helper((str:gsub('(.-)('..delimiter..')', helper)))
	return t
end

http = {accept = {}}

function http.accept.parse(headers)
	-- return a list of seperate mime types (including parameters)
	headers = headers:gsub('%s+', '') -- remove whitespace
	return split(headers, ',')
end

function http.accept.parse_element(elementstr)
	-- split "text/plain;q=0.3" appropriately
	local pos = elementstr:find(';q=')
	local q, element
	if pos then
		element = elementstr:sub(0, pos -1)
		q = elementstr:sub(pos + 3)
		q = q:gsub('[^%d\.]', '') + 0 -- ignore everything after q=0.8
	else
		element = elementstr
		q = 1.0
	end
	return element, q
end

function http.accept.best_match(to_ext, header)
	if not header then
		header = '*/*'
	else
		header = header..''
	end
	local t = {}
	for index, element in ipairs(http.accept.parse(header)) do
		local element, q = http.accept.parse_element(element)
		table.insert(t, {element, q, index})
	end
	table.sort(t, function (a, b)
		-- ensure that the initial order is kept in case of two
		-- identical q values
		if a[2] == b[2] then
			return a[3] < b[3]
		end
		return a[2] > b[2]
	end)
	selected = {}
	for tindex, telement in ipairs(t) do
		for aelement, aext in pairs(to_ext) do
			if http.accept.compare(aelement, telement[1]) and not in_list(selected, aelement) then
				table.insert(selected, aelement)
			end
		end
	end
	return selected
end

function http.accept.compare(element1, element2)
	local el1_type, el1_sub, el1_ext = http.accept.parse_mime(element1)
	local el2_type, el2_sub, el2_ext = http.accept.parse_mime(element2)
	if not (el1_type == el2_type or el2_type == '*') then
		return false
	end
	if not (el1_sub == el2_sub or el2_sub == '*') then
		return false
	end
	if not (el2_ext == '' or el1_ext == el2_ext) then
		return false
	end
	return true
end

function http.accept.parse_mime(element)
	splitted = split(element, '/')
	type = splitted[1]
	splitted = split(splitted[2], ';')
	subtype = splitted[1]
	ext = splitted[2]
	return type, subtype, ext
end

for e in iterate(http.accept.best_match(to_ext, lighty.request['Accept']), fallback) do
	local ext = to_ext[e]
	if file_exists(lighty.env['physical.path']..ext) then
		lighty.env['request.orig-uri'] = lighty.env['request.uri']
		lighty.env['uri.path'] = lighty.env['uri.path']..ext
		lighty.env['physical.rel-path'] = lighty.env['physical.rel-path']..ext
		lighty.env['physical.path'] = lighty.env['physical.path']..ext
		break
	end
end
