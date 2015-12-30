-- farming_plus integration

local flora = {
	'farming:tomato_7',
	'farming:rhubarb_3',
	'farming:raspberry_4',
	'farming:pumpkin_8',
	'farming:potato_3',
	'farming:melon_8',
	'farming:grapebush',
	'farming:cucumber_4',
	'farming:corn_7',
	'farming:coffee_5',
	'farming:carrot_7',
	'farming:blueberry_4',
	'farming:beanbush' 
}

for _, node in ipairs(flora) do
	skyblock.register_flora(node)
end

-- unified_inventory: override home buttons to support (set)home API

-- Could've been a dirty workaround by tapping in the core minetest
-- command callback array if Mg was't there to clean coredevs' idiocy

for _, def in ipairs(unified_inventory.buttons) do
	if def.name == "home_gui_set" then
		def.action = function(player)
			sethome.set_home(player:get_player_name())
		end
	elseif def.name == "home_gui_go" then
		def.action = function(player)
			sethome.go_home(player:get_player_name())
		end
	end
end

-- Set privileges

minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	local p = minetest.setting_get("default_privs")
	local u = minetest.get_player_privs(playername)
	local n = minetest.string_to_privs(p)

	for priv, _ in pairs(n) do
		u[priv] = true
	end

	if skyblock.feats.get_level(playername) < 4 and (u.fly or u.fast) then
		u.fly = nil
		u.fast = nil
		minetest.chat_send_player(playername, "You have lost FLY and FAST")
	end

	minetest.set_player_privs(playername, u)
end)

-- Override travelnet box texture

minetest.override_item("travelnet:travelnet", {
	tiles = {
		"travelnet_travelnet_front.png",  -- backward view
		"travelnet_travelnet_back.png", -- front view
		"travelnet_travelnet_side.png", -- sides :)
		"travelnet_travelnet_top.png",  -- view from top
		"travelnet_travelnet_top.png",  -- view from bottom
	}
})
