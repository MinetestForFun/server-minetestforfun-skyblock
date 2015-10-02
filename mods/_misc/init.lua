--------------------
-- _Miscellaneous
--


-- Give set privileges
minetest.register_on_joinplayer(function(player)
	local p = minetest.setting_get("default_privs")
	minetest.set_player_privs(player:get_player_name(), minetest.string_to_privs(p))
end)
