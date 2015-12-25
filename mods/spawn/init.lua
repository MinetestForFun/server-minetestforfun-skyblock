--local SPAWN_INTERVAL = 5*60

spawn = {}
--function spawn.spawn_interval() return SPAWN_INTERVAL end
function spawn.spawn(name)
	local player = minetest.get_player_by_name(name)
	if minetest.setting_get_pos("static_spawnpoint") then
		player:setpos(minetest.setting_get_pos("static_spawnpoint"))
		minetest.log("action","Player ".. name .." respawned.")
		--Next allowed respawn in ".. spawn.spawn_interval() .." seconds.") -- If we use action_timers
		return true, "Teleporting to spawn..."
	else
		return false, "ERROR: No spawn point is set on this server!"
	end
end

minetest.register_chatcommand("spawn", {
	description = "Teleport a player to the defined spawnpoint",
	func = spawn.spawn
})
