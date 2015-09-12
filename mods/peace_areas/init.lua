--
-- Peaceful areas
-- Where hitting is impossible
--

peace_areas = {areas = {}}

minetest.register_on_punchplayer(function(player, hitter)
	local pos = player:getpos() 
	if pos == nil then return end
	for name, positions in pairs(peace_areas.areas) do
		local pos1 = positions["pos1"]
		local pos2 = positions["pos2"]
		local minp = {
			x = math.min(pos1.x, pos2.x),
			y = math.min(pos1.y, pos2.y),
			z = math.min(pos1.z, pos2.z)
		}
		local maxp = {
			x = math.max(pos1.x, pos2.x),
			y = math.max(pos1.y, pos2.y),
			z = math.max(pos1.z, pos2.z)
		}
		if minp.x < pos.x and pos.x < maxp.x and
			minp.y < pos.y and pos.y < maxp.y and
			minp.z < pos.z and pos.z < maxp.z then
			return true
			--[[
			Note:
				This use of the callback register_on_punchplayer may prevent other
				instance of it to work correctly. Please take note of it.
			]]--
		end
	end
end)

function peace_areas.register_area(area_name, def)
	peace_areas.areas[area_name] = def
end

peace_areas.register_area("server", {
	["pos1"] = {x = -31029, y = -31029, z = -31029},
	["pos2"] = {x =  31029, y =  31029, z =  31029},
})
