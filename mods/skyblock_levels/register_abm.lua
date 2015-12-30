--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--

skyblock.flora = {
	'default:junglegrass',
	'default:grass_1',
	'flowers:dandelion_white',
	'flowers:dandelion_yellow',
	'flowers:geranium',
	'flowers:rose',
	'flowers:tulip',
	'flowers:viola'
}

function skyblock.register_flora(node)
	table.insert(skyblock.flora, node)
end

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

		-- Check for nearby Monsarno Round-Down
		if minetest.find_node_near(pos, 5, 'skyblock:round_down') ~= nil then
			return
		end

		-- check for nearby flora
		if minetest.find_node_near(pos, 2, {'group:flora'}) ~= nil then
			return
		end

		if minetest.get_node(pos).name == 'air' then
			local node = skyblock.flora[math.random(1,#skyblock.flora)]
			minetest.set_node(pos, {name=node})
		end
	end
})

-- remove bones

if not minetest.setting_getbool("disable_skyblock_remove_bones_abm") then
	minetest.register_abm({
		nodenames = {'bones:bones'},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			minetest.remove_node(pos)
		end
	})
end
