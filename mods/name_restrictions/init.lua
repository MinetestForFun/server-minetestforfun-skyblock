-- name_restrictions mod by ShadowNinja
-- License: WTFPL

----------------------------
-- Restriction exemptions --
----------------------------
-- For legitimate player names that are caught by the filters.

local exemptions = {}
local temp = minetest.setting_get("name_restrictions.exemptions")
temp = temp and temp:split() or {}
for _, allowed_name in pairs(temp) do
	exemptions[allowed_name] = true
end
temp = nil
-- Exempt server owner
exemptions[minetest.setting_get("name")] = true
exemptions["singleplayer"] = true

local disallowed_names

local function load_forbidden_names()
	disallowed_names = {}
	local path = minetest.setting_get("name_restrictions.forbidden_names_list_path") or
		minetest.get_worldpath("name_restrictions") .. "/forbidden_names.txt"
	local file = io.open(path, 'r')
	if file then
		local count = 0
		for line in file:lines() do
			local low_line = line:lower()
			disallowed_names[low_line] = true
			count = count + 1
		end
		file:close()
		return true, count .. " forbidden names loaded", 'verbose'
	else
		disallowed_names = {}
		return true, path .. " doesn't exist, no forbidden names have been loaded", 'warning'
	end
end

do
	local ret, msg, lvl = load_forbidden_names()
	if msg and lvl then
		minetest.log(lvl, msg)
	end
end

---------------------
-- Simple matching --
---------------------

local disallowed

local function load_disallowed()
	local path = minetest.setting_get("name_restrictions.forbidden_name_patterns_list_path") or
		minetest.get_worldpath("name_restrictions") .. "/forbidden_names_patterns.txt"
	local file = io.open(path, 'r')
	if file then
		local content = file:read('*all')
		local imported = minetest.deserialize(content)
		local ret, msg, lvl = true, nil, nil
		if imported == nil then
			disallowed = disallowed or {}
			ret, msg, lvl = false, "Failed to parse " .. path .. "; patterns not imported", 'error'
		elseif type(imported) ~= 'table' then
			disallowed = disallowed or {}
			ret, msg, lvl = false, "Parsing " .. path .. " returned a " .. type(imported) ..
				" where a table was expected; patterns not imported", 'error'
		else
			disallowed = imported
			local count = 0
			for _ in pairs(disallowed) do
				count = count + 1
			end
			msg, lvl = count .. " forbidden name patterns loaded", 'verbose'
		end
		file:close()
		return ret, msg, lvl
	else
		disallowed = {}
		return true, path .. " doesn't exist, no forbidden name patterns have been loaded", 'warning'
	end
end

do
	local ret, msg, lvl = load_disallowed()
	if msg and lvl then
		minetest.log(lvl, msg)
	end
end

minetest.register_on_prejoinplayer(function(name, ip)
	if string.find(name, "Sadie") then
		return "Your client/nickname is disallowed. Please use the official Minetest client (or change your nickname)"
	end
	local lname = name:lower()
	for re, reason in pairs(disallowed) do
		if lname:find(re) then
			return reason
		end
	end
	if disallowed_names[lname] then
		return "Sorry. This name is forbidden."
	end
end)

--------------------------------------
-- Simple matching config reloading --
--------------------------------------

minetest.register_chatcommand("forbidden_names_reload", {
	params = "",
	description = "Reloads forbidden_names match lists",
	privs = {ban= true},
	func = function(name)
		local ret1, msg, lvl = load_forbidden_names()
		if msg and lvl then
			minetest.log(lvl, msg)
			minetest.chat_send_player(name, msg)
		end
		local ret2
		ret2, msg, lvl = load_disallowed()
		if msg and lvl then
			minetest.log(lvl, msg)
			minetest.chat_send_player(name, msg)
		end
		return ret1 and ret2
	end
})

------------------------
-- Case-insensitivity --
------------------------

minetest.register_on_prejoinplayer(function(name, ip)
	local lname = name:lower()
	for iname, data in pairs(minetest.auth_table) do
		if iname:lower() == lname and iname ~= name then
			return "Sorry, someone else is already using this"
				.." name.  Please pick another name."
				.."  Another posibility is that you used the"
				.." wrong case for your name."
		end
	end
end)

-- Compatability, for old servers with conflicting players
minetest.register_chatcommand("choosecase", {
	description = "Choose the casing that a player name should have",
	params = "<name>",
	privs = {server = true},
	func = function(name, params)
		local lname = params:lower()
		local worldpath = minetest.get_worldpath()
		for iname, data in pairs(minetest.auth_table) do
			if iname:lower() == lname and iname ~= params then
				minetest.auth_table[iname] = nil
				assert(not iname:find("[/\\]"))
				os.remove(worldpath .. "/players/" .. iname)
			end
		end
		return true, "Done."
	end,
})


------------------------
-- Anti-impersonation --
------------------------
-- Prevents names that are too similar to another player's name.

local similar_chars = {
	-- Only A-Z, a-z, 1-9, dash, and underscore are allowed in playernames
	"A4",
	"B8",
	"COco0",
	"Ee3",
	"Gg69",
	"ILil1",
	"S5",
	"Tt7",
	"Zz2",
}

-- Map of characters to a regex of similar characters
local char_map = {}
for _, str in pairs(similar_chars) do
	for c in str:gmatch(".") do
		if not char_map[c] then
			char_map[c] = str
		else
			char_map[c] = char_map[c] .. str
		end
	end
end

for c, str in pairs(char_map) do
	char_map[c] = "[" .. char_map[c] .."]"
end

-- Characters to match for, containing all characters
local all_chars = "["
for _, str in pairs(similar_chars) do
	all_chars = all_chars .. str
end
all_chars = all_chars .. "]"


minetest.register_on_prejoinplayer(function(name, ip)
	if exemptions[name] then return end

	-- Generate a regular expression to match all similar names
	local re = name:gsub(all_chars, char_map)
	re = "^[_-]*" .. re .. "[_-]*$"

	for authName, _ in pairs(minetest.auth_table) do
		if authName ~= name and authName:match(re) then
			return "Your name is too similar to another player's name."
		end
	end
end)



-----------------
-- Name length --
-----------------

local min_name_len = tonumber(minetest.setting_get("name_restrictions.minimum_name_length")) or 2
local max_name_len = tonumber(minetest.setting_get("name_restrictions.maximum_name_length")) or 17

minetest.register_on_prejoinplayer(function(name, ip)
	if exemptions[name] then return end

	if #name < min_name_len then
		return "Your player name is too short"
		.. " (" .. #name .. " characters, must be " .. min_name_len .. " characters at least)."
		.. " Please try a longer name."
	end

	if #name > max_name_len then
		return "Your player name is too long"
		.. " (" .. #name .. " characters, must be " .. max_name_len .. " characters at most)."
		.. " Please try a shorter name."
	end
end)


----------------------
-- Pronounceability --
----------------------

-- Original implementation (in Python) by sfan5
local function pronounceable(pronounceability, text)
	local pronounceable = 0
	local nonpronounceable = 0
	local cn = 0
	local lastc = ""
	for c in text:lower():gmatch(".") do
		if c:find("[aeiou0-9_-]") then
			if not c:find("[0-9]") then
				if cn > 2 then
					nonpronounceable = nonpronounceable + 1
				else
					pronounceable = pronounceable + 1
				end
			end
			cn = 0
		else
			if cn == 1 and lastc == c and lastc ~= 's' then
				nonpronounceable = nonpronounceable + 1
				cn = 0
			end
			if cn > 2 then
				nonpronounceable = nonpronounceable + 1
				cn = 0
			end
			if lastc:find("[aeiou]") then
				pronounceable = pronounceable + 1
				cn = 0
			end
			if not (c == "r" and lastc:find("[aipfom]")) and
					not (lastc == "c" and c == "h") then
				cn = cn + 1
			end
		end
		lastc = c
	end
	if cn > 0 then
		nonpronounceable = nonpronounceable + 1
	end
	return pronounceable * pronounceability >= nonpronounceable
end

-- Pronounceability factor:
--   nil = Checking disabled.
--   0   = Everything's unpronounceable.
--   0.5 = Strict checking.
--   1   = Normal checking.
--   2   = Relaxed checking.
local pronounceability = tonumber(minetest.setting_get("name_restrictions.pronounceability"))
if pronounceability then
	minetest.register_on_prejoinplayer(function(name, ip)
		if exemptions[name] then return end

		if not pronounceable(pronounceability, name) then
			return "Your player name does not seem to be pronounceable."
				.."  Please choose a more pronounceable name."
		end
	end)
end

