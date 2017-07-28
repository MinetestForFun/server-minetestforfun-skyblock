minetest.register_tool("skyblock:pick_aerbratus", {
	description = "Aerbratus Pickaxe",
	inventory_image = "skyblock_pick_aerbratus.png",
	tool_capabilities = {
		full_punch_interval = .8,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=1.5, [2]=.8, [3]=.4}, uses=60, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.register_tool("skyblock:shovel_aerbratus", {
	description = "Aerbratus Shovel",
	inventory_image = "skyblock_shovel_aerbratus.png",
	tool_capabilities = {
		full_punch_interval = .8,
		max_drop_level=3,
		groupcaps={
			crumbly = {times={[1]=.9, [2]=.4, [3]=.2}, uses=60, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
})

minetest.register_tool("skyblock:axe_aerbratus", {
	description = "Aerbratus Axe",
	inventory_image = "skyblock_axe_aerbratus.png",
	tool_capabilities = {
		full_punch_interval = .8,
		max_drop_level=3,
		groupcaps={
			choppy={times={[1]=1.5, [2]=.7, [3]=0.4}, uses=60, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	},
})
