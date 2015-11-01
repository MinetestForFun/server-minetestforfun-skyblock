--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--


-- flora spawns on dirt_with_grass
minetest.register_abm({
	nodenames = {'default:dirt_with_grass'},
	interval = 300,
	chance = 100,
	action = function(pos, node)
		pos.y = pos.y+1

		local light = minetest.get_node_light(pos)
		if not light or light < 13 then
			return
		end

		-- check for nearby
		if minetest.env:find_node_near(pos, 2, {'group:flora'}) ~= nil then
			return
		end

		if minetest.env:get_node(pos).name == 'air' then
			-- MFF Edit | gravgun | 2015-Nov-01
			local nodes = {
				'default:junglegrass',
				'default:grass_1',
				'flowers:dandelion_white',
				'flowers:dandelion_yellow',
				'flowers:geranium',
				'flowers:rose',
				'flowers:tulip',
				'flowers:viola',
				-- MFF Add: Support farming redo's plants that don't grow otherwise
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
			local node = nodes[math.random(1,#nodes+1)]
			minetest.env:set_node(pos, {name=node})
		end
	end
})

-- remove bones
minetest.register_abm({
	nodenames = {'bones:bones'},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		minetest.env:remove_node(pos)
	end,
})
