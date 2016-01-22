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
--[[

minetest.override_item("travelnet:travelnet", {
	tiles = {
		"travelnet_travelnet_front.png",  -- backward view
		"travelnet_travelnet_back.png", -- front view
		"travelnet_travelnet_side.png", -- sides :)
		"travelnet_travelnet_top.png",  -- view from top
		"travelnet_travelnet_top.png",  -- view from bottom
	}
})
--]]

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

-- Protectors

local function register_protector_pair(scalename, range, displaycolor, logocolor)
	local logotex = "protector_mff_logo_underlay.png^[colorize:#" .. logocolor ..
	                "^protector_mff_logo_overlay.png"
	protector.register_protector("mff_block_" .. range, {
		description = scalename .. " Protection Block",
		drawtype = "nodebox",
		tiles = {
			"protector_mff_block.png",
			"protector_mff_block.png",
			"protector_mff_block.png^(" .. logotex .. ")"
		},
		sounds = default.node_sound_stone_defaults(),
		groups = {dig_immediate = 2, unbreakable = 1},
		is_ground_content = false,
		paramtype = "light",
		light_source = 4,

		node_box = {
			type = "fixed",
			fixed = {
				{-0.5 ,-0.5, -0.5, 0.5, 0.5, 0.5},
			}
		}
	}, { radius = range, displaycolor = displaycolor })
	protector.register_protector("mff_logo_15", {
		description = scalename .. " Protection Logo",
		tiles = {logotex},
		wield_image = logotex,
		inventory_image = logotex,
		sounds = default.node_sound_stone_defaults(),
		groups = {dig_immediate = 2, unbreakable = 1},
		paramtype = 'light',
		paramtype2 = "wallmounted",
		legacy_wallmounted = true,
		light_source = 4,
		drawtype = "nodebox",
		sunlight_propagates = true,
		walkable = true,
		node_box = {
			type = "wallmounted",
			wall_top    = {-0.375, 0.4375, -0.5, 0.375, 0.5, 0.5},
			wall_bottom = {-0.375, -0.5, -0.5, 0.375, -0.4375, 0.5},
			wall_side   = {-0.5, -0.5, -0.375, -0.4375, 0.5, 0.375},
		},
		selection_box = {type = "wallmounted"}
	}, { radius = range, displaycolor = displaycolor })
end

register_protector_pair("3x", 15, "10EF10", "0BAC0B")

minetest.register_craft({
	output = "protector:mff_block_15",
	recipe = {
		{"protector:protect"}
	}
})
minetest.register_craft({
	output = "protector:protect",
	recipe = {
		{"protector:mff_block_15"}
	}
})
minetest.register_craft({
	output = "protector:mff_logo_15",
	recipe = {
		{"protector:protect2"}
	}
})
minetest.register_craft({
	output = "protector:protect2",
	recipe = {
		{"protector:mff_logo_15"}
	}
})

-- 3x protector fix ABM (temp fix)

if false then

-- Degrade 3x protector into 1x if it overlaps other player's protectors
minetest.register_abm({
	nodenames = {"protector:mff_block_15", "protector:mff_logo_15"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local protradius = protector.registered_protectors[node.name] or 0
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if not protector.can_dig(protector.max_registered_radius * 2 + 2, pos,
		owner, true, 0, protradius) then
			local oldnode = minetest.get_node(pos)
			if node.name == "protector:mff_block_15" then
				minetest.swap_node(pos, {name = "protector:protect", param1 = oldnode.param1, param2 = oldnode.param2})
			else
				minetest.swap_node(pos, {name = "protector:protect2", param1 = oldnode.param1, param2 = oldnode.param2})
			end
		end
	end
})

end
