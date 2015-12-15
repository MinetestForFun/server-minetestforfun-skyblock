--[[

Craft Guide for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-craft_guide
License: BSD-3-Clause https://raw.github.com/cornernote/minetest-craft_guide/master/LICENSE

MAIN LOADER

]]--

-- load api
--dofile(minetest.get_modpath("craft_guide").."/api_craft_guide.lua")

--[[ override minetest.register_craft
local minetest_register_craft = minetest.register_craft
minetest.register_craft = function (options) 
	minetest_register_craft(options) 
	craft_guide.register_craft(options)
end

-- override minetest.register_alias
local minetest_register_alias = minetest.register_alias
minetest.register_alias = function (name, convert_to) 
	minetest_register_alias(name,convert_to) 
	craft_guide.register_alias(name, convert_to)
end

local function retrograde_table(recipe, w)
	local tab = {}
	for i = 1, 3 do
		tab[i] = {}
	end
	for i, v in pairs(recipe) do
		i = i - 1
		local j = i%w
		local k = (i-j) / w
		tab[k+1][j+1] = v
	end
	return tab
end

minetest.after(1, function()
	for item, def in pairs(minetest.registered_items) do
		if minetest.get_item_group(item, "not_in_creative_inventory") == 0 and def.description ~= "" then
			local crafts = minetest.get_all_craft_recipes(item)
			if crafts then
				for _, tab in pairs(crafts) do
					if tab.width == 0 then
						tab.type = "shapeless"
					elseif tab.type == "normal" then
						tab.type = nil
						tab.items = retrograde_table(tab.items, tab.width)
					end
					craft_guide.register_craft({
						type = tab.type,
						output = tab.output,
						recipe = tab.items,
						replacements = tab["replacements"]
					})
				end
			end
		end
	end
end)]]

-- register entities
dofile(minetest.get_modpath("craft_guide").."/register_node.lua")
--dofile(minetest.get_modpath("craft_guide").."/register_craft.lua")

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
