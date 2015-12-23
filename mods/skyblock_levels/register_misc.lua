--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--


-- new player
minetest.register_on_newplayer(function(player)
	local player_name = player:get_player_name()
	-- add rewards to player inventory
	player:get_inventory():set_size('rewards', 4)
	-- update feats
	skyblock.feats.update(player_name)
	-- init level1
	skyblock.levels[1].init(player_name)
end)

-- join player
minetest.register_on_joinplayer(function(player)
	-- set inventory formspec
	player:set_inventory_formspec(skyblock.levels.get_formspec(player:get_player_name()))
end)

-- die player
minetest.register_on_dieplayer(function(player)
	local player_name = player:get_player_name()
	-- empty inventory
	skyblock.levels.empty_inventory(player)

	-- back to beginning
	if skyblock.levels.restart_on_die then
		skyblock.feats.reset(player_name)
	else
		skyblock.feats.reset_level(player_name)
	end
	
	-- back to start of this level
	
end)

-- player receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- restart
	if formname=='skyblock_restart' and fields.restart then
		skyblock.feats.reset(player:get_player_name())
		minetest.chat_send_player(player:get_player_name(), "Your feats have been reset")
		player:set_hp(0)
	elseif formname == '' then -- That's the main inventory
		if fields.gohome then
			sethome.go_home(player:get_player_name())
		elseif fields.sethome then
			sethome.set_home(player:get_player_name())
		elseif fields.report then
			minetest.show_formspec(player:get_player_name(), "report:form", "field[text;Text about what to report:;")
		end
	elseif formname == "report:form" and fields.text and fields.text ~= "" then
		-- Copied from src/builtin/game/chatcommands.lua (with little tweaks)
		if not fields.text or fields.text == "" then
			return
		end
		local name = player:get_player_name()
		local cmd_def = core.chatcommands["report"]
		if not cmd_def then
			return
		end
		local has_privs, missing_privs = core.check_player_privs(name, cmd_def.privs)
		if has_privs then
			core.set_last_run_mod(cmd_def.mod_origin)
			local success, message = cmd_def.func(name, fields.text)
			if message then
				core.chat_send_player(name, message)
			end
		else
			core.chat_send_player(name, "You don't have permission"
					.. " to run this command (missing privileges: "
					.. table.concat(missing_privs, ", ") .. ")")
		end
		return true -- Handled fields reception
	end
end)

-- unified inventory skyblock button
if minetest.get_modpath('unified_inventory') then
	unified_inventory.register_button('skyblock', {
		type = 'image',
		image = 'ui_skyblock_icon.png',
		tooltip = 'Skyblock Quests',
		action = function(player)
			skyblock.feats.update(player:get_player_name())
		end,	
	})
end
