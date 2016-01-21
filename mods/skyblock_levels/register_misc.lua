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
			local stack   = inv:get_stack("craftpreview", 1)
			local cgrid   = inv:get_list("craft")
			local recipes = minetest.get_all_craft_recipes(stack:get_name())
			local tabrcp  = {}
			local count   = 65535

			-- Get a simplified table for the craft grid's recipe
			local widths = 0
			local widthe = 0
			for i = 1,3 do
				if cgrid[i]:get_count() > 0 or cgrid[i+3]:get_count() > 0 or cgrid[i+6]:get_count() > 0 then
					widthe = i
					if widths == 0 then
						widths = i
					end
				end
			end
			local width = widthe - widths + 1

			for u, st in pairs(cgrid) do
				if st:get_count() > 0 then
					count = math.min(count, st:get_count())
				end
				if widths <= ((u-1)%3)+1 and ((u-1)%3)+1 <= widthe then
					table.insert(tabrcp, st:get_name())
				end
			end

			if count * stack:get_count() > stack:get_stack_max() then
				count = math.floor(stack:get_stack_max() / stack:get_count())
			end

			-- Crop out the useless blanks
			local tmprcp = {}
			for i = 0, 2 do
				if (tabrcp[(i*3)+1] or "") ~= "" or (tabrcp[(i*3)+2] or "") ~= "" or (tabrcp[(i*3)+3] or "") ~= "" then
					for u = 1, 3 do
						if (tabrcp[u] or "") ~= "" or (tabrcp[3+u] or "") ~= "" or (tabrcp[6+u] or "") ~= "" then
							table.insert(tmprcp, tabrcp[(i*3)+u])
						end
					end
				end
			end
			tabrcp = table.copy(tmprcp)

			-- Now check which recipe is the right one
			local recipe = {}
			for _, rcp in pairs(recipes) do
				if rcp.type == "normal" and (rcp.width == width or rcp.width == 0) then
					local status = true
					for u, elem in pairs(rcp.items) do
						if elem:split(":")[1] == "group" then
							local groups = elem:split(":")[2]:split(",")
							for _, group in pairs(groups) do
								if minetest.get_item_group(tabrcp[u], group) == 0 then
									status = false
									break
								end
							end

						elseif elem ~= tabrcp[u] then
							status = false
							break
						end
					end
					if status then
						recipe = rcp
						break
					end
				end
			end

			-- And get its replacements (even though there are usually not any...)
			if not recipe.items then
				minetest.log("error", "ERROR in Max button for output " .. stack:get_name() .. ". Debug details :\nTabrcp: " .. dump(tabrcp) .. "\nCgrid: " .. dump(cgrid))
				minetest.chat_send_player(player:get_player_name(), "Something went wrong. Ask the administrators for further informations.")
				return
			end

			local _, output_decrement = minetest.get_craft_result(recipe)
			local leftovers = table.copy((output_decrement.items or {}))

			-- Back to normal crafting
			stack:set_count(stack:get_count() * count)
			for i = 1,inv:get_size("craft") do
				local s = inv:get_stack("craft", i)
				s:set_count(s:get_count() - count)
				inv:set_stack("craft", i, s)
			end

			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			else
				minetest.add_item(player:getpos(), stack)
			end

			for _, ls in pairs(leftovers) do
				ls:set_count(count)
				if inv:room_for_item("main", ls) then
					inv:add_item("main", ls)
				else
					minetest.add_item(player:getpos(), ls)
				end
			end
			-- WE'RE DONE
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
