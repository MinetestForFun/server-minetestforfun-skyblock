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

			-- Step 1 : Retrieve data and make declarations
			local inv = player:get_inventory()
			local outstack = inv:get_stack("craftpreview", 1):to_table()

			local craftgrid = {
				[1] = {},
				[2] = {},
				[3] = {},
			}
			local stacks = {}

			-- Step 2 : Compute the craft grid
			for id, stack in pairs(inv:get_list("craft")) do
				craftgrid[math.ceil(id/3)][((id-1)%3)+1] = stack:to_table()
			end

			-- Step 3 : Determine how much will be crafted
			local multiplier = 65535
			for x, tab in pairs(craftgrid) do
				for y, stack in pairs(tab) do
					multiplier = math.min(multiplier, stack.count)
				end
			end
			local cnt = outstack.count * multiplier
			table.insert(stacks, 1, {name = outstack.name, count = cnt, metadata = outstack.metadata, wear = outstack.wear})

			minetest.log("Promising " .. outstack.name .. " " .. stacks[1].count)

			-- Step 4 : Determine replacements
			-- Step 4.1 : Determine the recipe
			-- Step 4.1.1 : Retrieve all possible recipes
			local all_possible_recipes = minetest.get_all_craft_recipes(outstack.name)
			local our_recipe

			if not all_possible_recipes then return end -- This is a toolrepair, and for some reason it has nothing registered
			if #all_possible_recipes == 1 then
				our_recipe = all_possible_recipes[1]
			end
			-- Didn't want to put an "else" here, the code's already idented enough at some points
			while #all_possible_recipes > 1 do
				minetest.log(#all_possible_recipes)
				-- Step 4.1.2 : If multiple recipes, try to match ours..
				-- Step 4.1.2.1 : .. using output amount
				local recpamntfound = 0
				for _, recipe in pairs(all_possible_recipes) do
					local recpcount = tonumber(recipe.output:split(" ")[2] or "1")
					if recpcount == outstack.count then
						recpamntfound = recpamntfound + 1
						our_recipe = recipe
					end
				end
				if recpamntfound == 1 then
					break
				else
					-- Better luck next time
					our_recipe = nil
				end

				-- Step 4.1.2.2 : .. using width analysis
				for _, recipe in pairs(all_possible_recipes) do
					-- CODE THE MATCHING
					-- Step 4.1.2.2.1 : Recognize a shapeless recipe
					if recipe.width == 0 then
						-- Step 4.1.2.2.1.1 : Declare the validation table
						local validated = {}
						for x = 1,(#recipe.items) do
							validated[x] = false
						end

						-- Step 4.1.2.2.1.2 : Validate stacks one per one
						for x, tab in pairs(craftgrid) do
							for y, stack in pairs(craftgrid) do
								local s = craftgrid[x][y]
								if s then
									for id, item in pairs(recipe.items) do
										if (not validated[id]) and (item == s.name or (
										item:split(":")[1] == "group" and minetest.get_item_group(s.name, item:split(":")[2]) > 0
										)) then
											validated[id] = true
										end
									end
								end
							end
						end

						-- Step 4.1.2.2.1.3 : Sum up all validation
						local valid = true
						for _, i in pairs(validated) do
							valid = valid and i
							if not valid then break end
						end

						-- Step 4.1.2.2.1.4 : If validated, we found it
						if valid then
							our_recipe = recipe
							break
						end

					-- Step 4.1.2.2.2 : Recipe with one of width
					elseif recipe.width == 1 then
						minetest.log(dump(recipe))
						-- Step 4.1.2.2.2.1 : Vertical analysis of the items
						local recheight = #recipe.items
						local reclock = (recheight == 3)
						local recx = 0
						local valid = true

						-- Step 4.1.2.2.2.1.1 : Check the presence of only one column
						for x, tab in pairs(craftgrid) do
							for y, stack in pairs(tab) do
								if stack then
									if recx == 0 then
										recx = x
									elseif recx ~= x then
										valid = false
										break
									end
								end
							end
						end

						if valid then
							-- Step 4.1.2.2.2.1.2 : Verify column content
							local iterlock = false
							local iterdelay = 0
							for y = 1, 3 do
								local stack = craftgrid[recx][y]
								if stack then
									iterlock = true
								elseif not (stack or iterlock) then
									iterdelay = iterdelay + 1
								end
								if iterlock then -- We start to check from here
									valid = valid and ((stack or {name=nil}).name == recipe.items[y - iterdelay])
								end
							end
							if valid then
								our_recipe = recipe
								break
							end
						end

					-- Step 4.1.2.2.3
					elseif recipe.width == 2 then
						local valid = true
						-- Step 4.1.2.2.3.1 : Determining the odd column out
						local emptycol = 0
						-- Technically speaking, tables are only worth being used anonymously (memory-wise) above 11 elements
						-- But, meh. We'll spare the CPU instead
						for _, y in pairs({1,3}) do
							if not (craftgrid[1][y] or craftgrid[2][y] or craftgrid[3][y]) then
								emptycol = y
								break
							end
						end

						-- Step 4.1.2.2.3.2 : Check column 2 and the other non empty
						-- This loop is a correct implementation of a per-column verification
						-- It might be modified to fit any width later in the future
						for _, y in pairs({2, ({[1]=3,[3]=1})[emptycol]}) do
							local iterlock = false
							local iterdelay = 0
							for x = 1,3 do
								local stack = craftgrid[x][y]
								if stack then
									iterlock = true
								elseif not (stack or iterlock) then
									iterdelay = iterdelay + 1
								end
								if iterlock then -- We've gotta check from here
									valid = valid and
									(stack or {name = nil}).name == recipe.items[(x-iterdelay-1)*2+({[3]=y,[1]=y-1})[emptycol]]
								end
							end
							if not valid then break end
						end

						if valid then
							our_recipe = recipe
							break
						end

					-- Step 4.1.2.2.4
					elseif recipe.width == 3 then
						-- Easier since we can just check one by one
						minetest.log(dump(recipe))
						local valid = true
						for y=1,3 do
							for x = 1,3 do
								local stack = craftgrid[x][y]
								valid = valid and (stack or {name = nil}).name == recipe.items[(y-1)*3+x]
							end
							if not valid then minetest.log(y) break end
						end

						if valid then
							our_recipe = recipe
							break
						end
					end
				end
				break
			end

			-- JOKER
			if not our_recipe then minetest.log("JOKER 1") return end

			-- Step 4.1.3 : Call minetest.get_craft_result with the recipe found
			local our_result = minetest.get_craft_result(our_recipe)

			-- Step 4.2 : Add replacements in the given stacks' table
			for x, rep in pairs(our_result.replacements) do
				table.insert(stacks, 1, {name = rep:get_name(), count = rep:get_count() * multipler, metadata = rep:get_metadata(), wear = rep:get_wear()})
			end

			-- Step 5 : Clean the inventory
			-- Step 5.1 : Craft preview inventory
			inv:set_stack("craftpreview", 1, nil)

			-- Step 5.2 : Craft inventory
			for x = 1,9 do
				local s = craftgrid[math.ceil(x/3)][((x-1)%3)+1]
				if s then
					inv:set_stack("craft", x, ItemStack({
						name = s.name,
						count = s.count - multiplier,
						wear = s.wear,
						metadata = s.metadata,
					}))
				end
			end

			-- Step 6 : Dump all the necessary stacks in the inventory or near the player
			local pos = player:getpos()
			pos.y = pos.y + 1
			for _, stack in pairs(stacks) do
				-- Step 6.1 : If object is a tool, then we can't stack them
				if minetest.registered_tools[stack.name] then
					minetest.log("Giving away " .. stack.count .. " tools")
					for x=1,stack.count do
						local overflow = inv:add_item("main", {name = stack.name, count=1, wear=stack.wear, metadata=stack.metadata})
						if overflow then
							minetest.add_item(pos, overflow)
						end
					end
				else
					local overflow = inv:add_item("main", stack)
					if overflow then
						minetest.add_item(pos, overflow)
					end
				end
			end

			-- Step 7 : Profit
		end
	end
end)

-- Custom recipe for testing
minetest.register_craft({
	output = "default:cobble 2",
	recipe = {
		{"default:dirt", "default:dirt"},
	}
})

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
