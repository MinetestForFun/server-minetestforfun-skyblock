--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--


-- new player
minetest.register_on_newplayer(function(player)
	local player_name = player:get_player_name()
	-- add rewards to player inventory
	player:get_inventory():set_size('rewards', 4)
	-- update feats
	skyblock.feats.update(player_name)
	-- init level1
	skyblock.levels[1].init(player_name)
end)

-- join player
minetest.register_on_joinplayer(function(player)
	-- set inventory formspec
	player:set_inventory_formspec(skyblock.levels.get_formspec(player:get_player_name()))
end)

-- die player
minetest.register_on_dieplayer(function(player)
	local player_name = player:get_player_name()
	-- empty inventory
	skyblock.levels.empty_inventory(player)

	-- back to beginning
	if skyblock.levels.restart_on_die then
		skyblock.feats.reset(player_name)
	else
		skyblock.feats.reset_level(player_name)
	end
	
	-- back to start of this level
	
end)

-- player receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- restart
	if formname == 'skyblock_restart' and fields.restart then
		skyblock.feats.reset(player:get_player_name())
		minetest.chat_send_player(player:get_player_name(), "Your feats have been reset")
		player:set_hp(0)
	elseif formname == '' then -- That's the main inventory
		if fields.craft_max then
			local inv = player:get_inventory()
			if inv:is_empty("craftpreview") then
				return
			end
			local stack = inv:get_stack("craftpreview", 1)
			local cgrid = inv:get_list("craft")
			local count = 65535
			for _, st in pairs(cgrid) do
				if st:get_count() > 0 then
					count = math.min(count, st:get_count())
				end
			end

			for _, st in pairs(cgrid) do
				if st:get_count() > 0 then
					st:set_count(st:get_count() - count)
					if st:get_count() > 0 then
						if inv:room_for_item("main", st) then
							inv:add_item("main", st)
						else
							minetest.add_item(player:getpos(), st)
						end
					end
				end
			end
			stack:set_count(stack:get_count() * count)
			inv:set_list("craft", {[1] = "", [9] = ""})
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			else
				minetest.add_item(player:getpos(), stack)
			end
		end
	end
end)

-- unified inventory skyblock button
if minetest.get_modpath('unified_inventory') then
	unified_inventory.register_button('skyblock', {
		type = 'image',
		image = 'ui_skyblock_icon.png',
		tooltip = 'Skyblock Quests',
		action = function(player)
			skyblock.feats.update(player:get_player_name())
		end,	
	})
end
