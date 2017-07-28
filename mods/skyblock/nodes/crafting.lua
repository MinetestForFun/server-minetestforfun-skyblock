-- Disabled until level 5 quests are ready.
--[[
minetest.register_craft({
	output = 'skyblock:aerbratus_sapling',
	recipe = {
		{'skyblock:aerbratus_leaves', 'skyblock:aerbratus_leaves', 'skyblock:aerbratus_leaves'},
		{'skyblock:aerbratus_leaves', 'skyblock:aerbratus_leaves', 'skyblock:aerbratus_leaves'},
		{'', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'skyblock:aerbratus_wood 4',
	recipe = {
		{'skyblock:aerbratus_trunk'},
	}
})

minetest.register_craft({
	output = "skyblock:cloud_light 2",
	recipe = {
		{"skyblock:cloud"},
	}
})

minetest.register_craft({
	output = "skyblock:cloud 2",
	recipe = {
		{"skyblock:cloud_rainy"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "skyblock:cloud_light",
	recipe = {
		{"skyblock:aerbratus_leaves", "skyblock:aerbratus_leaves"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "skyblock:cloud",
	recipe = {
		{"skyblock:cloud_light","skyblock:cloud_light"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "skyblock:cloud_rainy",
	recipe = {
		{"skyblock:cloud","skyblock:cloud"},
	}
})

minetest.register_craft({
	output = 'skyblock:pick_aerbratus',
	recipe = {
		{'skyblock:cloud_rainy', 'skyblock:cloud_rainy', 'skyblock:cloud_rainy'},
		{'', 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})

minetest.register_craft({
	output = 'skyblock:shovel_aerbratus',
	recipe = {
		{'skyblock:cloud_rainy'},
		{'group:stick'},
		{'group:stick'},
	}
})

minetest.register_craft({
	output = 'skyblock:axe_aerbratus',
	recipe = {
		{'skyblock:cloud_rainy', 'skyblock:cloud_rainy'},
		{'skyblock:cloud_rainy', 'group:stick'},
		{'', 'group:stick'},
	}
})
--]]