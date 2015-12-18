sethome = {}
sethome.homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local function loadhomes()
    local input = io.open(sethome.homes_file, "r")
    if input then
		repeat
            local x = input:read("*n")
            if x == nil then
            	break
            end
            local y = input:read("*n")
            local z = input:read("*n")
            local name = input:read("*l")
            homepos[name:sub(2)] = {x = x, y = y, z = z}
        until input:read(0) == nil
        io.close(input)
    else
        homepos = {}
    end
end

loadhomes()

minetest.register_privilege("home", "Can use /sethome and /home")

local changed = false

function sethome.go_home(name)
	local player = minetest.get_player_by_name(name)
	if player == nil then
		-- just a check to prevent the server crashing
		return false
	end

	if homepos[player:get_player_name()] then
		player:setpos(homepos[player:get_player_name()])
		minetest.chat_send_player(name, "Teleported to home!")
	else
		minetest.chat_send_player(name, "Set a home using /sethome")
	end
	return true
end

minetest.register_chatcommand("home", {
    description = "Teleport you to your home point",
    privs = {home=true},
    func = sethome.go_home
})

function sethome.set_home(name)
	local player = minetest.get_player_by_name(name)
	local pos = player:getpos()
	homepos[player:get_player_name()] = pos
	minetest.chat_send_player(name, "Home set!")
	changed = true
	if changed then
		local output = io.open(sethome.homes_file, "w")
		for i, v in pairs(homepos) do
			output:write(v.x.." "..v.y.." "..v.z.." "..i.."\n")
		end
		io.close(output)
		changed = false
	end
end

minetest.register_chatcommand("sethome", {
    description = "Set your home point",
    privs = {home=true},
    func = sethome.set_home
})

function sethome.get_home(name)
	return homepos[name]
end
