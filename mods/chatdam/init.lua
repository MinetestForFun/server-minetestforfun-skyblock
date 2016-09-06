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

chatdam.conf = {}
chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE = tonumber(minetest.setting_get("max_chars_per_msg") or 255)
chatdam.conf.TRUNCATE_LONG_MESSAGES = minetest.setting_get("truncate_long_msg")
chatdam.conf.MESSAGE_DELAY = tonumber(minetest.setting_get("message_delay") or 1.5)

--if(table.getn(core.registered_on_chat_messages) > 1) then
--	error("CHATDAM MUST BE LOADED WHEN NO OTHER CALLBACK OTHER THAN THE ONE TO BE WIPED EXIST. PLEASE FIND THE MOD LOADED BEFORE CHATDAM WHICH REGISTERS A CALLBACK FOR CHAT MESSAGES AND ADD 'chatdam' TO ITS depends.txt FILE")
--end


chatdam.emulate_message = function(name, message)
	-- Normal log handling
	minetest.log(("CHAT: <%s> %s"):format(name, message))
	-- First call other callbacks
	for _, cback in pairs(core.registered_on_chat_messages) do
		if (cback ~= chatdam.floodcontrol) then
			if (cback(name, message)) then
				return true
			end
		end
	end

	-- Then send it
	for _, pref in pairs(minetest.get_connected_players()) do
		if (pref:get_player_name() ~= name) then
			minetest.chat_send_player(pref:get_player_name(), ("<%s> %s"):format(name, message))
		end
	end
	-- Boom. Done
end


chatdam.floodcontrol = function(name, message)
	local strlen = string.len(message)
	local delayadd = 0
	while strlen > chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE do
		local nstr = string.sub(message, 0, chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE)
		minetest.after(delayadd * chatdam.conf.MESSAGE_DELAY, chatdam.emulate_message, name, nstr)
		if chatdam.conf.TRUNCATE_LONG_MESSAGES then
			-- We're done, f*ck the rest of the message
			minetest.chat_send_player(name, "-!- Your message was truncated")
			return true
		end
		message = string.sub(message, chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE+1)
		strlen = strlen-chatdam.conf.MAXIMUM_CHARACTERS_PER_MESSAGE
		delayadd = delayadd + 1
	end

	if (strlen > 0) then
		minetest.after(delayadd * chatdam.conf.MESSAGE_DELAY, chatdam.emulate_message, name, message)
	end

	return true -- Cancel anything that might happen after, and the engine's response
end
minetest.register_on_chat_message(chatdam.floodcontrol)


minetest.log("[ChatDam] Loaded")
