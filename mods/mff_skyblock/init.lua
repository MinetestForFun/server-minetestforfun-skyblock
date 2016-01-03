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

-- unified_inventory:
-- * Override home buttons to support (set)home API
--   Could've been a dirty workaround by tapping in the core minetest
--   command callback array if Mg was't there to clean coredevs' idiocy
-- * Remove bags, clear_inv, misc_set_day and misc_set_night button

for i=#unified_inventory.buttons,1,-1 do
	local def = unified_inventory.buttons[i]
	if def.name == "home_gui_set" then
		def.action = function(player)
			sethome.set_home(player:get_player_name())
		end
	elseif def.name == "home_gui_go" then
		def.action = function(player)
			sethome.go_home(player:get_player_name())
		end
	elseif def.name == "bags" or def.name == "clear_inv" or def.name == "misc_set_day" or
		def.name == "misc_set_night" then
		table.remove(unified_inventory.buttons, i)
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
		minetest.chat_send_player(playername, "You have lost FLY and FAST. You will earn these privileges when you reach level 4.")
		minetest.chat_send_player(playername, "Complete the quests in your inventory to level up. Each level has a new set of quests.")
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

-- Allow everybody to add to a travelnet network

local ret_true = function(...) return true end

travelnet.allow_attach = ret_true
travelnet.allow_dig    = ret_true

-- Play a generic sound when someone eats
minetest.register_on_item_eat(function(_, _, _, user)
	if user then
		minetest.sound_play({name = "mff_skyblock_eat_generic", gain = 1}, {pos = user:getpos(), max_hear_distance = 16})
	end
end)		
