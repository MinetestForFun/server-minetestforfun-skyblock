-- Needed variables
local pvptable = {}
local huds = {}
local toggle_interval = 5 * 60

-- Inventory mod determination
local inv_mod = ""
if minetest.get_modpath("unified_inventory") ~= nil then
	inv_mod = "unified_inventory"
	minetest.log("action", "[pvpbutton] Using UnifiedInventory (u_inv) as inventory management mod")
elseif minetest.get_modpath("inventory_plus") ~= nil then
	inv_mod = "inventory_plus"
	minetest.log("action", "[pvpbutton] Using Inventory+ (inv+) as inventory management mod")
end

if inv_mod == "" then
	error("No inventory mod could be found! Please install either unified_inventory (recommended) or inventory_plus")
end

-- The toggle callback
function toggle_pvp(localname)
	local player = minetest.get_player_by_name(localname)
	if pvptable[localname] == 0 then
		pvptable[localname] = 1
		minetest.chat_send_player(localname,
			"PvP was enabled for "..localname)
		player:hud_remove(huds[localname])
		huds[localname] = player:hud_add({
			hud_elem_type = "text",
			position = {x = 1, y = 0},
			offset = {x=-100, y = 20},
			scale = {x = 100, y = 100},
			text = "PvP is enabled for you!",
			number = 0xFF0000 -- Red
		})
		return
	else
		pvptable[localname] = 0
		minetest.chat_send_player(localname,
			"PvP was disabled for "..localname)
		player:hud_remove(huds[localname])
		return
	end
end

-- Link the toggle callback to the proper hook
if inv_mod == "unified_inventory" then
	unified_inventory.register_button("pvp", {
		type = "image",
		image = "pvpbutton_pvp.png",
		tooltip = "Toggle pvp",
		action = function(player)
			local pname = player:get_player_name()
			action_timers.wrapper(pname,
				"pvp toggle",
				"pvp_" .. pname,
				toggle_interval,
				toggle_pvp, {pname}
			)
		end
	})
else
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if fields.pvp then
			local pname = player:get_player_name()
			action_timers.wrapper(pname,
				"pvp toggle",
				"pvp_" .. pname,
				toggle_interval,
				toggle_pvp, {pname}
			)
		end
	end)
end

-- Initialize values for players
minetest.register_on_joinplayer(function(player)
	pvptable[player:get_player_name()] = 0
	huds[player:get_player_name()] = nil
	if inv_mod == "inventory_plus" then
		inventory_plus.register_button(player, "pvpbutton_pvp", "PvP")
		minetest.after(1, function()
			inventory_plus.set_inventory_formspec(player, inventory_plus.get_formspec(player, inventory_plus.default))
		end)		
	end
end)

-- Support on on_punchplayer hook
if minetest.setting_getbool("enable_pvp") then
	if minetest.register_on_punchplayer then
		minetest.register_on_punchplayer(
			function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, pvp)
			
			if not hitter:is_player() then
				return false
			end
			
			local localname = player:get_player_name()
			local hittername = hitter:get_player_name()
			
			if pvptable[hittername] == 1 then
				if pvptable[localname] == 1 then
					return false
				else
					minetest.chat_send_player(hittername, "Player " .. localname .. " does not have PvP activated")
				end
			else
				minetest.chat_send_player(hittername, "PvP is disabled for you")
			end
			minetest.chat_send_player(localname, "Player " .. hittername .. " tried hurting you. It failed")
			return true
		end)
	end
end
