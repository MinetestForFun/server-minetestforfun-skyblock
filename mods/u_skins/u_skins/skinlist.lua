u_skins.list = {}
u_skins.add = function(skin)
	table.insert(u_skins.list,skin)
end

local id

id = 1
while true do
	local f = io.open(minetest.get_modpath("u_skins").."/textures/player_"..id..".png")
	if (not f) then break end
	f:close()
	u_skins.add("player_"..id)
	id = id +1
end

id = 1
while true do
	local f = io.open(minetest.get_modpath("u_skins").."/textures/character_"..id..".png")
	if (not f) then break end
	f:close()
	u_skins.add("character_"..id)
	id = id +1
end

minetest.log("action", "[u_skins] Loaded " .. id .. " normal skins")

id = 1
while true do
	local f = io.open(minetest.get_modpath("u_skins") .. "/textures/mff_character_" .. id .. ".png")
	if (not f) then break end
	f:close()
	u_skins.add("mff_character_" .. id)
	id = id + 1
end


minetest.log("action", "[u_skins] Loaded " .. id .. " mff custom skins")
