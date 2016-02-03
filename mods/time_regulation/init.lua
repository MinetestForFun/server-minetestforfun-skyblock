--------------------
-- Time Regulation
-- By Mg/LeMagnesium
-- License: CC0
-- Last modification :
--

-- Namespace first, with basic informations
time_reg = {}
time_reg.version = "00.01.00"
time_reg.author = "Mg/LeMagnesium"

-- Definitions
time_reg.time_speed = 72

time_reg.loop_interval = 0
time_reg.loop_active = false

time_reg.threshold = {}
time_reg.threshold.day = 5000 -- time units
time_reg.threshold.night = 19000 -- time units

time_reg.moment = ""
time_reg.duration = 1440 / time_reg.time_speed
time_reg.day_time_speed = 0
time_reg.night_time_speed = 0

--[[ Status :
    0: Dead
    1: Idle
    2: Active
]]
time_reg.status = 2

time_reg.ratio = { -- Expressed in percent
    day = tonumber(minetest.setting_get("day_time_ratio")) or 50,
    night = tonumber(minetest.setting_get("night_time_ratio")) or 50,
}
if (time_reg.ratio.day + time_reg.ratio.night ~= 100) or time_reg.ratio.day < 0 or time_reg.ratio.night < 0 then
    minetest.log("error", ("[TimeRegulation] Invalid ratio : %d/100 day & %d/100 night. Setting to 50/50"):format(time_reg.ratio.day, time_reg.ratio.night))
    time_reg.ratio.day, time_reg.ratio.night = 50, 50
end

-- Crappy overrides
local old_settime_func = core.chatcommands["time"].func
core.chatcommands["time"].func = function(...)
    local res, msg = old_settime_func(...)
    if res and time_reg.status == 2 then
        time_reg.do_calculation()
        time_reg.loop(0, false)
        minetest.log("action", "[TimeRegulation] Settime override : updating regulation")
    end
    return res, msg
end

local old_set_func = core.chatcommands["set"].func
core.chatcommands["set"].func = function(...)
    local res, msg = old_set_func(...)
    if res and time_reg.status ~= 0 then
        time_reg.update_constants()
        time_reg.loop(false)
        minetest.log("action", "[TimeRegulation] Set override : updating constants and regulation")
    end
    return res, msg
end


-- Then methods
function time_reg.do_calculation()
    time_reg.time_speed = tonumber(minetest.setting_get("time_speed")) -- Absolute Time Speed
    time_reg.duration = 1440 / time_reg.time_speed -- Absolute Human Speed
    local day_htime, night_htime = time_reg.duration * (time_reg.ratio.day/100), time_reg.duration * (time_reg.ratio.night/100)
    time_reg.loop_interval = (math.min(night_htime, day_htime) / 12) * 60
    time_reg.day_time_speed = 1440 / (day_htime * 2)
    time_reg.night_time_speed = 1440 / (night_htime * 2)
end

function time_reg.update_constants()
    time_reg.time_speed = minetest.setting_get("time_speed")
    time_reg.do_calculation()
    if time_reg.status == 1 and time_reg.time_speed > 0 then
        time_reg.set_status(2, "ACTIVE")
    end
end

function time_reg.start_loop()
    if time_reg.loop_active then
        minetest.log("action", "[TimeRegulation] Will not start the loop : one is already running")
        return false
    end
    time_reg.loop_active = true
    minetest.log("action", "[TimeRegulation] Loop started")
    minetest.after(0, time_reg.loop, true)
    return true
end

function time_reg.stop_loop()
    if not time_reg.loop_active then
        minetest.log("action", "[TimeRegulation] Will not break the loop : no loop running")
        return false
    end
    time_reg.loop_active = false
    minetest.log("action", "[TimeRegulation] Loop asked to stop")
    return true
end

function time_reg.set_status(x, title)
    minetest.log("action", "[TimeRegulation] Entered status " .. x .. " (" .. title .. ")")
    time_reg.status = x
end

-- And the loop
function time_reg.loop(loop)
    -- Determine TOD and current moment
    local tod = minetest.get_timeofday() * 24000

    local moment = "day"
    if tod < time_reg.threshold.day or tod > time_reg.threshold.night then
        moment = "night"
    end

    if time_reg.time_speed == 0 then
        time_reg.set_status(1, "IDLE")
        return
    end

    -- Update if threshold reached
    if moment ~= time_reg.moment then
        -- We've reached a treshold
        time_reg.moment = moment

        if moment == "day" then
            if time_reg.ratio.day == 0 then
                minetest.set_timeofday(time_reg.threshold.night / 2400)
                minetest.log("action", "[TimeRegulation] Entering day period : period skipped")
            else
                minetest.setting_set("time_speed", time_reg.day_time_speed)
                minetest.log("action", "[TimeRegulation] Entering day period : time_speed " .. time_reg.day_time_speed)
            end
        else
            if time_reg.ratio.night == 0 then
                minetest.set_timeofday(time_reg.threshold.day / 24000)
                minetest.log("action", "[TimeRegulation] Entering night period : period skipped")
            else
                minetest.setting_set("tims_speed", time_reg.night_time_speed)
                minetest.log("action", "[TimeRegulation] Entering night period : time_speed " .. time_reg.night_time_speed)
            end
        end
    end

    -- Loop if we weren't broken
    if loop then
        minetest.after(time_reg.loop_interval, time_reg.loop, time_reg.loop_active)
    else
        minetest.log("action", "[TimeRegulation] Loop stopped")
    end
end

time_reg.update_constants()
time_reg.start_loop()

-- chatcommand
minetest.register_chatcommand("time_reg", {
    description = "Control time_regulation",
    privs = {server = true},
    func = function(name, param)
        if param == "" then
            return true, "see /time_reg help"

        elseif param == "help" then
            return true, "Supported commands: start, stop"
        elseif param == "stop" then
            local res = time_reg.stop_loop()
            if res then
                time_reg.set_status(0, "DEAD")
                return true, "Loop was told to stop\nTime regulation disabled"
            else
                return false, "Loop couldn't be stopped, it isn't running"
            end
        elseif param == "start" then
            local res = time_reg.start_loop()
            if res then
                time_reg.set_status(2, "ACTIVE")
                time_reg.update_constants()
                return true, "Loop started. Time regulation enabled"
            else
                return false, "Loop couldn't be started, it already is"
            end
        else
            return false, "Unknown subcommand: " .. param
        end
    end
})

-- Startup informations
local function log(x) minetest.log("action", "[TimeRegulation] " .. (x or "")) end

log("Thank you for using TimeRegulation v" .. time_reg.version .. " by " .. time_reg.author)
log("Status: " .. time_reg.status)
log("Absolute Time Speed: " .. time_reg.time_speed)
log("Duration: " .. time_reg.duration)
log("Loop interval: " .. time_reg.loop_interval .. "s")
log("Ratio:")
log("\tDay: " .. time_reg.ratio.day .. "%")
log("\tNight: " .. time_reg.ratio.night .. "%")
log("Applied time speeds:")
log("\tDay: " .. time_reg.day_time_speed)
log("\tNight: " .. time_reg.night_time_speed)
