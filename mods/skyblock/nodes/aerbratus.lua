minetest.register_node('skyblock:aerbratus_trunk', {
	description = 'Aerbratus trunk',
	tiles = {'skyblock_aerbratus_tree_top.png', 'skyblock_aerbratus_tree_top.png',
		'skyblock_aerbratus_tree.png'},
	paramtype2 = 'facedir',
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

minetest.register_node('skyblock:aerbratus_wood', {
	description = 'Aerbratus planks',
	tiles = {'skyblock_aerbratus_wood.png'},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node('skyblock:aerbratus_leaves',{
	description = 'Aerbratus leaves',
	drawtype = 'allfaces_optional',
	visual_scale = 1.3,
	tiles = {'skyblock_aerbratus_leaves.png'},
	waving = 1,
	paramtype = 'light',
	is_ground_content = false,
	groups = {snappy = 3, leafdecay = 3, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			{items = {'skyblock:aerbratus_sapling'}, rarity = 100},
			{items = {'skyblock:aerbratus_leaves'}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node('skyblock:aerbratus_sapling', {
	description = 'Aerbratus sapling',
	drawtype = 'plantlike',
	visual_scale = 1.0,
	tiles = {'skyblock_aerbratus_sapling.png'},
	inventory_image = 'skyblock_aerbratus_sapling.png',
	wield_image = 'skyblock_aerbratus_sapling.png',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy = 2, dig_immediate = 3,
		attached_node = 1, sapling = 1},
	sounds = default.node_sound_leaves_defaults(),
  after_place_node = function(pos)
		skyblock.grow_aerbratus(pos)
	end
})