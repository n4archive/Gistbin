local function get(user, id, file)
	local handle, message
	write("Connecting to GitHub... ")
	if file then
		handle, message = http.get("https://gist.githubusercontent.com/" .. user .. "/" .. id .. "/raw/" .. file)
	else
		handle, message = http.get("https://gist.githubusercontent.com/" .. user .. "/" .. id .. "/raw/")
	end

	if not handle then error(message or "Unknown error", 0) end

	local contents = handle.readAll()
	handle.close()
        print("Success.")

	return contents
end

local command = ...
if command == "get" then
	local _, user, id, dest = ...
	if not id then error("No id specified", 0) end

	local mainId, file = id:match("^([^/]+)/(.+)$")
	dest = dest or file
	if not dest then error("No destination specified", 0) end

	local contents = get(user, mainId or id, file)
	local path = shell.resolve(dest)

	local handle = fs.open(path, "w")
	if not handle then error("Cannot open " .. dest) end
	handle.write(contents)
	handle.close()
elseif command == "run" then
	local _, user, id = ...
	if not id then error("No id specified", 0) end

	local mainId, file = id:match("^([^/]+)/(.+)$")
	local contents = get(user, mainId or id, file)

	local func, msg = load(contents, file or id, nil, _ENV)
	if not func then error(msg, 0) end

	func(select(3, ...))
elseif not command then
	error("Must specify command", 0)
else
	error("No such command: " .. command, 0)
end
