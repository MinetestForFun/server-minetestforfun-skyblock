--------------------
-- _Miscellaneous
--


-- Give set privileges
minetest.register_on_joinplayer(function(player)
	local p = minetest.setting_get("default_privs")
	local u = minetest.get_player_privs(player:get_player_name())
	local n = minetest.string_to_privs(p)

	for priv, _ in pairs(n) do
		u[priv] = true
	end

	if skyblock.feats.get_level(player:get_player_name()) < 4 and (u['fly'] or u['fast']) then
		u['fly'] = nil
		u['fast'] = nil
		minetest.chat_send_player(player:get_player_name(), "You have lost FLY and FAST")
	end

	minetest.set_player_privs(player:get_player_name(), u)
end)
