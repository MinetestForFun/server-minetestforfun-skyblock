--------------------
-- _Miscellaneous
--


-- Give set privileges
minetest.register_on_joinplayer(function(player)
	local p = minetest.setting_get("default_privs")
	local u = minetest.get_player_privs(player:get_player_name())
	local n = minetest.string_to_privs(p)

	for priv, _ in pairs(u) do
		n[priv] = true
	end
	minetest.set_player_privs(player:get_player_name(), n)
end)
