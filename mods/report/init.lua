report = {}

function report.send(name, param)
	-- Send to online moderators / admins
	-- Get comma separated list of online moderators and admins
	local mods = {}
	for _, player in pairs(minetest.get_connected_players()) do
		local toname = player:get_player_name()
		if minetest.check_player_privs(toname, {kick = true, ban = true}) then
			table.insert(mods, toname)
			minetest.chat_send_player(toname, "-!- " .. name .. " reported: " .. param)
		end
	end

	if #mods > 0 then
		mod_list = table.concat(mods, ", ")
		local admin = minetest.setting_get("name")
		email.send_mail(name, admin, "Report: " .. param .. " (mods online: " .. mod_list .. ")")
		for _, moderator in pairs(mods) do
			if name ~= moderator then
				email.send_mail(name, moderator, "Report: " .. param .. " (mods online: " .. mod_list .. ")")
			end
		end
		return true, "Reported. Moderators currently online: " .. mod_list
	else
		email.send_mail(name, minetest.setting_get("name"),
			"Report: " .. param .. " (no mods online)")
		return true, "Reported. We'll get back to you."
	end
end

minetest.register_chatcommand("report", {
	func = function(name, param)
		param = param:trim()
		if param == "" then
			return false, "Please add a message to your report. " ..
				"If it's about (a) particular player(s), please also include their name(s)."
		end
		local _, count = string.gsub(param, " ", "")
		if count == 0 then
			minetest.chat_send_player(name, "If you're reporting a player, " ..
				"you should also include a reason why. (Eg: swearing, sabotage)")
		end

		local success, message = action_timers.wrapper(name, "report", "report_" .. name, 300, report.send, {name, param})
		if message then
			core.chat_send_player(name, message)
		end
		return success
	end
})

if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_button("report", {
		type = "image",
		-- From http://www.clker.com/cliparts/v/K/Y/P/2/M/warning-sign-bl-bg-hi.png
		image = "report_button.png",
		tooltip = "Report to the moderators/administrator",
	})

	unified_inventory.register_page("report", {
		get_formspec = function(player)
			local form = "field[2,4;5,1;text;Text about what to report:;]" ..
				"button[2,5;2,0.5;report;Send]"
			return {formspec = form, draw_inventory = false}
		end
	})

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname ~= "" or not fields.report then
			return
		end

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

			if success then
				-- Little hack, since we cannot control a field's value
				local base_form = unified_inventory.get_formspec(player, "report")
				minetest.show_formspec(player:get_player_name(), "report:_thank", "label[4.7,3;Thank you for your input]")
			end
		else
			core.chat_send_player(name, "You don't have permission"
					.. " to run this command (missing privileges: "
					.. table.concat(missing_privs, ", ") .. ")")
		end
		return true -- Handled fields reception
	end)
end
