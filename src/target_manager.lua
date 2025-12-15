local TargetManager = {}
local ItemManager = require("src.item_manager")
local explorerlite = require("core.explorerlite")

-- Active loot target tracking
local current_target = { id = nil, is_walkover = false, started_at = 0 }
local TIMEOUT_WALKOVER = 3.0
local TIMEOUT_INTERACT = 15.0

-- Failed attempt tracking
local failed_loot_attempts = {}
local FAILED_ATTEMPT_WINDOW = 2.5
local FAILED_ATTEMPT_LIMIT = 4
local last_prune_time = 0
local PRUNE_INTERVAL = 5.0

function TargetManager.reset()
    current_target.id = nil
    current_target.is_walkover = false
    current_target.started_at = 0
end

function TargetManager.clear()
    explorerlite:clear_path_and_target()
    TargetManager.reset()
end

function TargetManager.set_target(id, is_walkover)
    if current_target.id ~= id then
        current_target.id = id
        current_target.is_walkover = is_walkover
        current_target.started_at = get_time_since_inject()
    end
end

function TargetManager.check_timeout(id)
    if current_target.id ~= id then return false end
    
    local timeout = current_target.is_walkover and TIMEOUT_WALKOVER or TIMEOUT_INTERACT
    return (get_time_since_inject() - current_target.started_at > timeout)
end

function TargetManager.get_current_id()
    return current_target.id
end

function TargetManager.attempt_unstuck()
    local player_pos = get_player_position()
    if not player_pos then return end
    
    -- Try to move to a random point nearby to clear stuck state
    local angle = math.random() * 6.28318 -- 2*PI
    local dist = 3.0
    -- Assuming vec3 is available in the environment, otherwise use player_pos methods if available
    -- If vec3 is not global, we might need to rely on explorerlite's internal logic or just skip this.
    -- However, most environments provide vec3.
    if vec3 then
        local offset_x = math.cos(angle) * dist
        local offset_y = math.sin(angle) * dist
        local new_pos = vec3:new(player_pos:x() + offset_x, player_pos:y() + offset_y, player_pos:z())
        
        explorerlite:set_custom_target(new_pos)
        explorerlite:move_to_target()
    end
end

function TargetManager.register_failure(id)
    if not id then return false end
    
    local now = get_time_since_inject()
    local entry = failed_loot_attempts[id]
    
    if entry and now - entry.last_time <= FAILED_ATTEMPT_WINDOW then
        entry.count = entry.count + 1
        entry.last_time = now
        if entry.count >= FAILED_ATTEMPT_LIMIT then
            ItemManager.blacklist_item(id, 10.0)
            failed_loot_attempts[id] = nil
            return true -- Should stop trying
        end
    else
        failed_loot_attempts[id] = { count = 1, last_time = now }
    end
    return false
end

function TargetManager.prune_failures()
    local now = get_time_since_inject()
    if now - last_prune_time < PRUNE_INTERVAL then return end
    last_prune_time = now

    if not next(failed_loot_attempts) then return end
    
    local active_ids = {}
    local items = actors_manager.get_all_items()
    for _, it in pairs(items) do
        active_ids[it:get_id()] = true
    end
    
    for id in pairs(failed_loot_attempts) do
        if not active_ids[id] then
            failed_loot_attempts[id] = nil
        end
    end
end

return TargetManager
