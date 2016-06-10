--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--

--[[
Level 4 mostly revolving around farming and dying
level 4 feats and rewards:

* Craft the wooden hoe -> Wheat seed
* Plant wheat seed -> Cactus 1
* Craft the bread and eat it -> Cotton Seed
* Use hoe 50 times -> Steel hoe
* Place 5 white wool blocks -> 2 orange wool blocks + 2 red dye
* Dig cactus 20 -> 2 white dyes
* Dig Geranium 10 -> Brown Mushroom 2
* Dig Tulip 15 -> Red Mushroom 2
* Dig Brown Mushroom 10 -> Stick 50
* Craft the Diamond Hoe -> Diamondblock

]]--

local level = 4

--
-- PUBLIC FUNCTIONS
--

skyblock.levels[level] = {}

-- feats
skyblock.levels[level].feats = {
   {
      
   }
}

-- init level
skyblock.levels[level].init = function(player_name)
end

-- get level information
skyblock.levels[level].get_info = function(player_name)
	local info = { 
		level=level, 
		total=1, 
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

-- no feat tracking
skyblock.levels[level].reward_feat = function(player_name, feat) end
skyblock.levels[level].on_placenode = function(pos, newnode, placer, oldnode) end
skyblock.levels[level].on_dignode = function(pos, oldnode, digger) end
skyblock.levels[level].on_item_eat = function(player_name, itemstack) end
skyblock.levels[level].on_craft = function(player_name, itemstack) end
skyblock.levels[level].bucket_on_use = function(player_name, pointed_thing) end
skyblock.levels[level].bucket_water_on_use = function(player_name, pointed_thing) end
skyblock.levels[level].bucket_lava_on_use = function(player_name, pointed_thing) end
