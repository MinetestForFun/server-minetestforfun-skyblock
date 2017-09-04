--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--

--[[
Level 5 mostly revolving around farming and dying
level 5 feats and rewards:

* place_meselamp x4       xdecor:enderchest

* craft_enchanttable       xdecor:trampoline
* craft_sword              default:acacia_sapling
* enchant_sword            default:aspen_sapling
* craft_shield             skyblock:round_down_sprayer
* use_rounddown            xdecor:mailbox

* dig_geranium x5        flowers:mushroom_brown x2

* place_travelnet x2       flowers:mushroom_red x2
* craft_workbench          farming:corn x50
* dig_aerbratus_leaves x50 default:meselamp x5

]]--

local level = 5

--
-- PUBLIC FUNCTIONS
--

skyblock.levels[level] = {}

-- feats
-- Parts of this are purely hypothetical and not implement yet
skyblock.levels[level].feats = {
   {
      name = "Place 4 meselamps",
      hint = "default:meselamp",
      feat = "place_meselamp",
      count = 4,
      reward = "xdecor:enderchest",
      placenode = {"default:meselamp"}
   },
   {
      name = "Craft an Enchantment Table",
      hint = "xdecor:enchantment_table",
      feat = "craft_enchanttable",
      count = 1,
      reward = "xdecor:trampoline",
      craft = {"xdecor:enchantment_table"}
   },
   {
      name = "Craft a sword",
      hint = "default:sword_bronze",
      feat = "craft_sword",
      count = 1,
      reward = "default:acacia_sapling",
      craft = {"default:sword_mese", "default:sword_diamond", "default:sword_bronze", "default:sword_steel"}
   },
   {
      name = "Enchant the sword",
      hint = "xdecor:enchantment_table",
      feat = "enchant_sword",
      count = 1,
      reward = "default:aspen_sapling",
      --enchant = {"default:sword_mese", "default:sword_diamond", "default:sword_bronze", "default:sword_steel"},
   },
   {
      name = "Craft a shield",
      hint = "shields:shield_bronze",
      feat = "craft_pickaxe",
      count = 1,
      reward = "skyblock:round_down_sprayer",
      craft = {
	 "shields:shield_bronze",
	 "shields:shield_cactus",
	 "shields:shield_diamond",
	 "shields:shield_enhanced_cactus",
	 "shields:shield_enhanced_wood",
	 "shields:shield_gold",
	 "shields:shield_steel",
	 "shields:shield_wood"
      },
   },
   {
      name = "Use Round-Down to clear weeds",
      hint = "skyblock:round_down_sprayer",
      feat = "use_rounddown",
      count = 1,
      reward = "xdecor:mailbox",
      use = {"skyblock:round_down_sprayer"},
   },
   {
      name = "Dig 10 Acacia Trunk pieces",
      hint = "default:acacia_tree",
      feat = "dig_acacia_tree",
      count = 10,
      reward = "travelnet:travelnet 2",
      dignode = {"default:acacia_tree"},
   },
   {
      name = "Place 2 Travelnet Boxes",
      hint = "travelnet:travelnet",
      feat = "place_travelnet",
      count = 2,
      reward = "travelnet:elevator 2",
      placenode = {"travelnet:travelnet"},
   },
   {
      name = "Craft a workbench",
      hint = "xdecor:workbench",
      feat = "craft_workbench",
      count = 1,
      reward = "skyblock:aerbratus_sapling",
      craft = {"xdecor:workbench"},
   },
   {
      name = "Dig 50 aerbratus leaves",
      hint = "skyblock:aerbratus_leaves",
      feat = "dig_aerbratus_leaves",
      count = 50,
      reward = "skyblock:pick_aerbratus",
      dignode = {"skyblock:aerbratus_leaves"},
   }
}

-- init level
skyblock.levels[level].init = function(player_name)
	minetest.chat_send_player(player_name, 'You can now toggle PvP and fight with other players')
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

skyblock.levels[level].on_enchanted = function(player, old_stack, new_item, wear, mese)
   local in_there = false
   local sname = old_stack:get_name()
   for _, i in pairs({"default:sword_mese", "default:sword_diamond", "default:sword_bronze", "default:sword_steel"}) do
      in_there = in_there or (i == sname)
   end

   if not in_there then return end

   skyblock.feats.add(level, player:get_player_name(), "enchant_sword")
end

skyblock.levels[level].on_round_down_use = function(itemstack, user, pointed_thing)
   local pname = user:get_player_name()
   local level = skyblock.feats.get_level(pname)

   skyblock.feats.add(level, pname, "use_rounddown")
end

skyblock.levels[level].on_chat = function(name, message)
end
