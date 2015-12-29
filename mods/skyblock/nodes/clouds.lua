minetest.register_node('skyblock:cloud_light', {
	description ='Light cloud',
	drawtype = 'glasslike',
	paramtype = 'light',
	tiles = {'skyblock_cloud_light.png'},
	use_texture_alpha = true,
	post_effect_color = {r = 255, g = 255, b = 255, a = 127},
	light_propagates = true,
	sunlight_propagates = true,
	climbable = true,
	walkable = false,
	groups = {oddly_breakable_by_hand = 3}
})

minetest.register_node('skyblock:cloud', {
	description ='Cloud',
	tiles = {'skyblock_cloud.png'},
	light_propagates = true,
	sunlight_propagates = true,
	groups = {oddly_breakable_by_hand = 2}
})

minetest.register_node('skyblock:cloud_dense', {
	description ='Dense cloud',
	tiles = {'skyblock_cloud_dense.png'},
	light_propagates = true,
	sunlight_propagates = false,
	groups = {oddly_breakable_by_hand = 1}
})

minetest.register_node('skyblock:cloud_rainy', {
	description ='Rainy cloud',
	tiles = {'skyblock_cloud_rainy.png'},
	light_propagates = true,
	sunlight_propagates = false,
	groups = {snappy = 3}
})
