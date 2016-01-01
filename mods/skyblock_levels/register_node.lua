--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--


-- quest node
minetest.override_item('skyblock:quest', {
	groups = {crumbly=2,cracky=2},
	on_construct = function(pos)
		local player_name = skyblock.get_spawn_player(pos)
		if player_name then
			skyblock.feats.update(player_name)
		end
	end,
    on_punch = function(pos, node, puncher)
		local player_name = skyblock.get_spawn_player(pos)
		if player_name then
			skyblock.feats.update(player_name)
		end
	end,
	can_dig = function(pos, player)
		return true
	end,
    on_dig = function(pos, node, digger)
		skyblock.show_restart_formspec(digger:get_player_name())
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.restart then
			skyblock.show_restart_formspec(sender:get_player_name())
			return
		end
		for k,v in pairs(fields) do
			if string.match(k, 'skyblock_craft_guide_') then
				minetest.show_formspec(sender:get_player_name(),'skyblock_craft_guide',skyblock.craft_guide.get_formspec(k, fields))
				return
			end
		end
	end,
})

-- Monsarno Round-Down
local round_down_radius = 5
minetest.register_node(':skyblock:round_down', {
	description = "Monsarno Round-Down",
	inventory_image = 'skyblock_round_down_sprayer.png^[transformFY',
	tiles = {'skyblock_round_down.png'},
	is_ground_content = true,
	drawtype = "airlike",
	groups = {oddly_breakable_by_hand=3, not_in_creative_inventory=1},
	paramtype = "light",
	sunlight_propagates = "true",
	drop = "",
	walkable = false,
	buildable_to = true,
	selection_box = { type = 'fixed', fixed = {-0.5, -0.5, -0.5, 0.5, -0.475, 0.5} },
	on_construct = function(pos)
		minetest.after(1, function(pos)
			-- Remove nearby flora
			local owner = minetest.get_meta(pos):get_string("owner") or ""
			local player_name = skyblock.get_spawn_player(pos)
			for x=-round_down_radius,round_down_radius do
				for y=-round_down_radius,round_down_radius do
					for z=-round_down_radius,round_down_radius do
						if not minetest.is_protected(pos, owner) then
							local pos = { x=pos.x+x, y=pos.y+y, z=pos.z+z }
							local node = minetest.get_node_or_nil(pos)
							if node and (minetest.get_item_group(node.name, 'flora') > 0
							   or minetest.get_item_group(node.name, 'plant') > 0) then
								minetest.remove_node(pos)
							end
						end
					end
				end
			end
		end, pos)
	end
})

local round_down_uses = 40
minetest.register_tool(':skyblock:round_down_sprayer', {
	description = "Monsarno Round-Down sprayer",
	inventory_image = 'skyblock_round_down_sprayer.png',
	wield_scale = {x = 1, y = 1, z = 6},
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type == 'node' then
			if not minetest.is_protected(pointed_thing.above, user:get_player_name()) then
				minetest.item_place_node(ItemStack("skyblock:round_down"), user, pointed_thing, 0)
				minetest.get_meta(pointed_thing.above):set_string("owner", user:get_player_name())
				itemstack:add_wear(65535/round_down_uses+1)
			end
		end
		return itemstack
	end
})

-- trees
local trees = {'default:tree','default:jungletree','default:pinetree'}
for k,node in ipairs(trees) do
	local groups = minetest.registered_nodes[node].groups
	groups.oddly_breakable_by_hand = 0
	minetest.override_item(node, {groups = groups})
end

-- leaves
local leaves = {'default:leaves','default:jungleleaves','default:pine_needles'}
for k,node in ipairs(leaves) do
	minetest.override_item(node, {climbable = true,	walkable = false})
end

-- instant grow sapling if there is room
minetest.override_item('default:sapling', {
	after_place_node = function(pos)
		-- check if node under belongs to the soil group
		pos.y = pos.y - 1
		local node_under = minetest.get_node(pos)
		pos.y = pos.y + 1
		if minetest.get_item_group(node_under.name, "soil") == 0 then
			return
		end

		-- check if we have space to make a tree
		for dy=1,4 do
			pos.y = pos.y+dy
			if minetest.get_node(pos).name ~= 'air' and minetest.get_item_group(minetest.env:get_node(pos).name, 'leaves') == 0 then
				return
			end
			pos.y = pos.y-dy
		end
		-- add the tree
		default.grow_tree(pos, math.random(1, 4) == 1)
	end
})

minetest.override_item('default:junglesapling', {
	after_place_node = function(pos)
		-- check if node under belongs to the soil group
		pos.y = pos.y - 1
		local node_under = minetest.get_node(pos)
		pos.y = pos.y + 1
		if minetest.get_item_group(node_under.name, "soil") == 0 then
			return
		end

		-- check if we have space to make a tree
		for dy=1,8 do
			pos.y = pos.y+dy
			if minetest.get_node(pos).name ~= 'air' and minetest.get_item_group(minetest.env:get_node(pos).name, 'leaves') == 0 then
				return
			end
			pos.y = pos.y-dy
		end
		-- add the tree
		default.grow_jungle_tree(pos)
	end
})

minetest.override_item('default:pine_sapling', {
	after_place_node = function(pos)
		-- check if node under belongs to the soil group
		pos.y = pos.y - 1
		local node_under = minetest.get_node(pos)
		pos.y = pos.y + 1
		if minetest.get_item_group(node_under.name, "soil") == 0 then
			return
		end

		-- check if we have space to make a tree
		for dy=1,9 do
			pos.y = pos.y+dy
			if minetest.get_node(pos).name ~= 'air' and minetest.get_item_group(minetest.env:get_node(pos).name, 'leaves') == 0 then
				return
			end
			pos.y = pos.y-dy
		end
		-- add the tree
		default.grow_pine_tree(pos)
	end
})
