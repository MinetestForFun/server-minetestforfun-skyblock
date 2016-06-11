--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--

--[[
Level 4 mostly revolving around farming and dying
level 4 feats and rewards:

* craft_woodenhoe        farming:seed_wheat
* use_hoe                farming:hoe_steel
* plant_wheatseed        default:cactus
* craft_bread            farming:seed_cotton
* place_whitewool x5     dye:red x2
* place_cactus x20       dye:white x2
* dig_geranium x10       flowers:mushroom_brown x2
* dig_tulip x2           flowers:mushroom_red x2
* dig_brownmushroom x15  default:stick x50
* craft_diamondhoe       default:diamondblock

]]--

local level = 4

--
-- PUBLIC FUNCTIONS
--

skyblock.levels[level] = {}

-- feats
-- Parts of this are purely hypothetical and not implement yet
skyblock.levels[level].feats = {
   {
      name = "Craft a wooden hoe",
      hint = "farming:hoe_wood",
      feat = "craft_woodenhoe",
      count = 1,
      reward = "farming:seed_wheat 2",
      craft = {"farming:hoe_wood"}
   },
   {
      name = "Use the hoe 50 times",
      hint = "farming:hoe_wood",
      feat = "use_hoe",
      count = 50,
      reward = "farming:hoe_steel",
      hoeuse = {"wood"}
   },
   {
      name = "Plant 10 wheat seeds",
      hint = "farming:seed_wheat",
      feat = "place_wheatseed",
      count = 1,
      reward = "default:cactus",
      placenode = {"farming:seed_wheat"}
   },
   {
      name = "Eat 4 pieces of bread",
      hint = "farming:bread",
      feat = "eat_bread",
      count = 4,
      reward = "farming:seed_cotton",
      item_eat = {"farming:bread"},
   },
   {
      name = "Place 50 white wool blocks",
      hint = "wool:white",
      feat = "place_whitewool",
      count = 50,
      reward = "dye:red 2",
      placenode = {"wool:white"},
   },
   {
      name = "Place 20 cacti",
      hint = "default:cactus",
      feat = "place_cactus",
      count = 20,
      reward = "dye:white 2",
      dignode = {"default:cactus"},
   },
   {
      name = "Dig 10 Geranium flowers",
      hint = "flowers:geranium",
      feat = "dig_geranium",
      count = 10,
      reward = "flowers:mushroom_brown 2",
      dignode = {"flowers:geranium"},
   },
   {
      name = "Dig 15 orange tulips",
      hint = "flowers:tulip",
      feat = "dig_tulip",
      count = 15,
      reward = "flowers:mushroom_red 2",
      dignode = {"flowers:tulip"},
   },
   {
      name = "Dig 10 brown mushrooms",
      hint = "flowers:mushroom_brown",
      feat = "dig_brownmushroom",
      count = 10,
      reward = "default:stick 50",
      dignode = {"flowers:mushroom_brown"},
   },
   {
      name = "Craft the Diamond Hoe",
      hint = "farming:hoe_diamond",
      feat = "craft_diamondhoe",
      count = 1,
      reward = "default:diamondblock",
      craft = {"farming:hoe_diamond"},
   }
}

-- init level
skyblock.levels[level].init = function(player_name)
end

-- get level information
skyblock.levels[level].get_info = function(player_name)
	local info = { 
		level=level, 
		total=10, 
		count=0, 
		player_name=player_name, 
		infotext='', 
		formspec = '', 
		formspec_quest = '',
	}
	
	local text = 'label[0,2.7; --== Quests ==--]'
		..'label[0,0.5; Time Goes On, '..player_name..'...]'
		..'label[0,1.0; You may wonder, traveller, where some of your]'
		..'label[0,1.5; precious items are. Be patient...]'
		..'label[0,2.0; They will come to you in time...]'

	info.formspec = skyblock.levels.get_inventory_formspec(level,info.player_name,true)..text
	info.formspec_quest = skyblock.levels.get_inventory_formspec(level,info.player_name)..text

	for k,v in ipairs(skyblock.levels[level].feats) do
		info.formspec = info.formspec..skyblock.levels.get_feat_formspec(info,k,v.feat,v.count,v.name,v.hint,true)
		info.formspec_quest = info.formspec_quest..skyblock.levels.get_feat_formspec(info,k,v.feat,v.count,v.name,v.hint)
	end
	if info.count>0 then
		info.count = info.count/2 -- only count once
	end

	info.infotext = 'LEVEL '..info.level..' for '..info.player_name..': '..info.count..' of '..info.total
	
	return info
end

-- Reward feats
skyblock.levels[level].reward_feat = function(player_name, feat)
   return skyblock.levels.reward_feat(level, player_name, feat)
end

-- Track node placement
skyblock.levels[level].on_placenode = function(pos, newnode, placer, oldnode)
   skyblock.levels.on_placenode(level, pos, newnode, placer, oldnode)
end

-- Track node digging
skyblock.levels[level].on_dignode = function(pos, oldnode, digger)
   skyblock.levels.on_dignode(level, pos, oldnode, digger)
end

-- track eating feats
skyblock.levels[level].on_item_eat = function(player_name, itemstack)
   skyblock.levels.on_item_eat(level, player_name, itemstack)
end

-- track crafting feats
skyblock.levels[level].on_craft = function(player_name, itemstack)
   skyblock.levels.on_craft(level, player_name, itemstack)
end

-- track hoe use
skyblock.levels[level].hoe_on_use = function(player_name, pointed_thing, wieldeditem)
   skyblock.levels.hoe_on_use(level, player_name, pointed_thing, wieldeditem)
end

skyblock.levels[level].bucket_on_use = function(player_name, pointed_thing) end
skyblock.levels[level].bucket_water_on_use = function(player_name, pointed_thing) end
skyblock.levels[level].bucket_lava_on_use = function(player_name, pointed_thing) end
