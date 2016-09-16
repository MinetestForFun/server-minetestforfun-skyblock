--[[
--	That Dam Chat
--	Wait, it's a Chat Dam
--	Anyway, the pun failed
--
--	License : WTFPL
--	ßÿ Lymkwi/LeMagnesium/Mg
--
--]]

chatdam = {}

chatdam.data = {}

-- Retrieve some config stuff
chatdam.conf = {}
chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE = tonumber(minetest.setting_get("maximum_characters_per_message") or "255")
chatdam.conf.MAXIMUM_MESSAGES_PER_INTERVAL = tonumber(minetest.setting_get("maximum_messages_per_interval") or "3")
chatdam.conf.FLOOD_INTERVAL = tonumber(minetest.setting_get("flood_interval") or "2")

-- Main control function. A real nightmare for flooders.
function chatdam.floodcontrol(name, message)
	local violation

	-- Kick for message length
	if message:len() > chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE then
		violation = ("Your sent a message with more characters than allowed (%s)"):format(chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE)
	end

	-- Kick for message frequency
	local rightnow = tonumber(os.date("%s"))
	-- By the power of maths I check the last <interval> seconds
	if rightnow > chatdam.data[name].lastmsg+chatdam.conf.FLOOD_INTERVAL then
		chatdam.data[name].msgs = 1
		chatdam.data[name].lastmsg = rightnow
	else
		chatdam.data[name].msgs = chatdam.data[name].msgs + 1
		if chatdam.data[name].msgs > chatdam.conf.MAXIMUM_MESSAGES_PER_INTERVAL then
			violation = ("You sent too many messages in a short amount of time (maximum allowed is %s for %s seconds)"):format(chatdam.conf.MAXIMUM_MESSAGES_PER_INTERVAL, chatdam.conf.FLOOD_INTERVAL)
		end
	end

	if violation then
		minetest.kick_player(name, violation)
		return true -- Cancel anything that might happen after, and the engine's response, which is to send the message
	end
end
minetest.register_on_chat_message(chatdam.floodcontrol)

-- We create tracking data for the players' messages here...
minetest.register_on_joinplayer(function(pref)
	chatdam.data[pref:get_player_name()] = {lastmsg=0, msgs=0}
end)

-- ... and we discard it here
minetest.register_on_leaveplayer(function(pref)
	chatdam.data[pref:get_player_name()] = nil
end)

minetest.log("[ChatDam] Loaded")
