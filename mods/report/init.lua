report = {}

function report.send(sender, message)
	-- Send to online moderators / admins
	-- Get comma separated list of online moderators and admins
	local mods = {}
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if minetest.check_player_privs(name, {kick = true, ban = true}) then
			table.insert(mods, name)
			minetest.chat_send_player(name, "-!- " .. sender .. " reported: " .. message)
		end
	end
	
	if #mods > 0 then
		local mod_list = table.concat(mods, ", ")
		email.send_mail(sender, minetest.setting_get("name"),
			"Report: " .. message .. " (mods online: " .. mod_list .. ")")
		return true, "Reported. Moderators currently online: " .. mod_list
	else
		email.send_mail(sender, minetest.setting_get("name"),
			"Report: " .. message .. " (no mods online)")
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

		local success, message = action_timers.wrapper(name, "report", "report_" .. name, 600, report.send, {name, param})
		if message then
			core.chat_send_player(name, message)
		end
	end
})
