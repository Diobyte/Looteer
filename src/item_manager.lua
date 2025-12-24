local Settings = require("src.settings")
local Utils = require("utils.utils")
local CustomItems = require("data.custom_items")
local ItemTypes = require("data.item_types")

local ItemManager = {}

local function to_lower(str)
    return str and string.lower(str) or ""
end

local BLACKLIST_DURATION = 4.0
local loot_blacklist = {}

local function resolve_item_id(item)
    if type(item) == "number" then
        return item
    end
    if not item then
        return nil
    end
    local ok, id = pcall(function() return item:get_id() end)
    if ok then
        return id
    end
    return nil
end

function ItemManager.blacklist_item(item, duration)
    local id = resolve_item_id(item)
    if not id then return end
    loot_blacklist[id] = get_time_since_inject() + (duration or BLACKLIST_DURATION)
end

function ItemManager.is_blacklisted(item)
    local id = resolve_item_id(item)
    if not id then return false end
    local expiry = loot_blacklist[id]
    if not expiry then return false end
    if get_time_since_inject() > expiry then
        loot_blacklist[id] = nil
        return false
    end
    return true
end

local RARITY_MAPPING = {
    [0] = 0,
    [1] = 1,
    [2] = 3,
    [3] = 5,
    [4] = 6
}

local function check_equipment(item, id, item_info, settings)
    if Utils.is_inventory_full() then return false, "Inventory Full" end

    local ok_rarity, rarity = pcall(function() return item_info:get_rarity() end)
    if not ok_rarity or not rarity then return false, "Rarity Error" end

    local min_rarity_id = RARITY_MAPPING[settings.rarity] or 0
    if rarity < min_rarity_id then return false, "Rarity Low" end

    if rarity >= 5 then
        local ok_display, display_name = pcall(function() return item_info:get_display_name() end)
        if not ok_display or not display_name then return false, "Display Name Error" end

        local greater_affix_count = Utils.get_greater_affix_count(display_name)
        local required_ga_count = 0

        if rarity == 6 then
            required_ga_count = CustomItems.ubers[id] and settings.uber_unique_ga_count or settings.unique_ga_count
        end

        if greater_affix_count < required_ga_count then
            return false, "GA Count Low"
        end
    end
    return true, "Wanted"
end

-- Rule Definitions
local RULES = {
    -- Categories
    cinders = { setting = "cinders", walkover = true },
    infernal_warp = { setting = "infernal_warp", walkover = true },
    quest = { setting = "quest_items", walkover = false },
    crafting = { setting = "crafting_items", walkover = false },
    recipe = { setting = "crafting_items", walkover = false, check = "consumable" },
    sigil = { setting = "sigils", walkover = false, check = "sigil" },
    tribute = { setting = "tribute", walkover = false, check = "sigil" },
    compass = { setting = "compass", walkover = false, check = "sigil" },
    item_cache = { setting = true, walkover = false, check = "inventory" },
    scroll = { setting = "scroll", walkover = false, check = "stackable_consumable", stack = 20 },
    rune = { setting = "rune", walkover = false, check = "stackable_socketable", stack = 100 },
    prism = { setting = "prism", walkover = true, check = "stackable_socketable", stack = 100 },
    gem = { setting = "gem", walkover = false, check = "stackable_socketable", stack = 100 },
    equipment = { setting = true, walkover = false, check = check_equipment },

    -- Custom Item Types (Mapped from CustomItems)
    obducite = { setting = "obducite", walkover = true },
    veiled_crystal = { setting = "veiled_crystal", walkover = true },
    s11_corrupted_essence = { setting = "s11_items", walkover = true },
    event_items = { setting = "event_items", walkover = false, check = "consumable" },
    boss_items = { setting = "boss_items", walkover = false, check = "consumable", stack = 99 },
    rare_elixirs = { setting = "rare_elixirs", walkover = false, check = "consumable", stack = 99 },
    basic_elixirs = { setting = "basic_elixirs", walkover = false, check = "consumable", stack = 99 },
    advanced_elixirs = { setting = "advanced_elixirs", walkover = false, check = "consumable", stack = 99 },
    tributes = { setting = "tribute", walkover = false, check = "sigil" },
    compasses = { setting = "compass", walkover = false, check = "sigil" },
    s11_special = { setting = "s11_items", walkover = false, check = "inventory" },
}

-- Build ID Lookup
local ID_TO_RULE_KEY = {}
for key, items in pairs(CustomItems) do
    if RULES[key] then
        for id, _ in pairs(items) do
            ID_TO_RULE_KEY[id] = key
        end
    end
end

-- Category Order for Pattern Matching
local CATEGORY_ORDER = {
    "cinders", "infernal_warp", "quest",
    "recipe", "s11_special", "sigil", "tribute", "compass",
    "crafting", "item_cache",
    "scroll", "rune", "prism", "gem",
    "equipment"
}

-- Cache
local item_cache = {}
local last_cache_clear = 0

local function get_cached_rule(id)
    if not id then return nil end
    local now = get_time_since_inject()
    if now - last_cache_clear > 60.0 then
        item_cache = {}
        last_cache_clear = now
    end
    return item_cache[id]
end

local function resolve_rule(item, id, item_info)
    if not id then return nil end

    -- Check cache
    local cached = get_cached_rule(id)
    if cached then return RULES[cached], cached end

    -- Check ID
    local rule_key = ID_TO_RULE_KEY[id]
    if rule_key then
        item_cache[id] = rule_key
        return RULES[rule_key], rule_key
    end

    -- Check Patterns
    local ok, name = pcall(function() return item:get_skin_name() end)
    if ok and name then
        local name_lower = to_lower(name)

        -- Ensure item_info is available for function patterns
        if not item_info or not item_info:is_valid() then
            local ok_info, info = pcall(function() return item:get_item_info() end)
            if ok_info and info and info:is_valid() then
                item_info = info
            end
        end

        for _, type_name in ipairs(CATEGORY_ORDER) do
            local patterns = ItemTypes[type_name]
            if patterns then
                for _, pattern in ipairs(patterns) do
                    local pattern_type = type(pattern)
                    if pattern_type == "string" then
                        if name_lower:find(pattern, 1, true) then
                            item_cache[id] = type_name
                            return RULES[type_name], type_name
                        end
                    elseif pattern_type == "function" then
                        if pattern(item, item_info, name_lower) then
                            item_cache[id] = type_name
                            return RULES[type_name], type_name
                        end
                    end
                end
            end
        end
    end

    return nil, nil
end

function ItemManager.get_debug_info(item)
    local ok_id, id = pcall(function() return item:get_id() end)
    if not ok_id or not id then return "Invalid Item" end

    local info_parts = {}
    table.insert(info_parts, "ID: " .. tostring(id))

    local ok_name, name = pcall(function() return item:get_skin_name() end)
    if ok_name then
        table.insert(info_parts, "Skin: " .. tostring(name))
    end

    local ok_info, item_info = pcall(function() return item:get_item_info() end)
    if ok_info and item_info and item_info:is_valid() then
        local ok_sno, sno = pcall(function() return item_info:get_sno_id() end)
        if ok_sno then
            table.insert(info_parts, "SNO: " .. tostring(sno))
        end
        local ok_display, display = pcall(function() return item_info:get_display_name() end)
        if ok_display then
            table.insert(info_parts, "Name: " .. tostring(display))
        end
    end

    local rule, rule_key = resolve_rule(item, id, item_info)
    if rule_key then
        table.insert(info_parts, "Cat: " .. tostring(rule_key))
    else
        table.insert(info_parts, "Cat: None")
    end

    local wanted, reason = ItemManager.get_pick_reason_with_flags(item, true, true, item_info)
    table.insert(info_parts, "Status: " .. (wanted and "WANTED" or "IGNORED"))
    table.insert(info_parts, "Reason: " .. tostring(reason))

    return table.concat(info_parts, " | ")
end

function ItemManager.is_walkover_item(item)
    if not item then return false end
    local id = resolve_item_id(item)
    local rule = resolve_rule(item, id)

    if rule then
        return rule.walkover
    end

    -- Fallbacks
    local ok_name, name_raw = pcall(function() return item:get_skin_name() end)
    if ok_name and name_raw and name_raw:lower():find("aether") then
        return true
    end

    local ok_interact, interactable = pcall(function() return item:is_interactable() end)
    if ok_interact and interactable == false then
        return true
    end

    return false
end

local function check_stackable_logic(enabled, full_check_func, get_items_func, item_id, max_stack, current_stack)
    if not enabled then return false end
    if not full_check_func() then return true end
    local ok, items = pcall(get_items_func)
    if not ok or not items then return false end
    return Utils.is_lowest_stack_below(items, item_id, max_stack, current_stack)
end

local function check_rule_logic(rule, item, id, item_info, settings)
    if not rule then return false, "No Rule" end

    -- Check setting
    local enabled = true
    if type(rule.setting) == "string" then
        enabled = settings[rule.setting]
    elseif type(rule.setting) == "boolean" then
        enabled = rule.setting
    end

    if not enabled then return false, "Setting Disabled" end

    -- Check logic
    if type(rule.check) == "function" then
        return rule.check(item, id, item_info, settings)
    elseif rule.check == "consumable" then
        if rule.stack then
            local ok_stack, stack_count = pcall(function() return item_info:get_stack_count() end)
            if not ok_stack then return false, "Stack Count Error" end
            if check_stackable_logic(
                    true,
                    Utils.is_consumable_inventory_full,
                    function() return get_local_player():get_consumable_items() end,
                    id,
                    rule.stack,
                    stack_count
                ) then
                return true, "Wanted Stackable"
            else
                return false, "Stack Full"
            end
        else
            if not Utils.is_consumable_inventory_full() then
                return true, "Wanted Consumable"
            else
                return false, "Consumables Full"
            end
        end
    elseif rule.check == "sigil" then
        if not Utils.is_sigil_inventory_full() then
            return true, "Wanted Sigil"
        else
            return false, "Sigils Full"
        end
    elseif rule.check == "inventory" then
        if not Utils.is_inventory_full() then
            return true, "Wanted Item"
        else
            return false, "Inventory Full"
        end
    elseif rule.check == "stackable_consumable" then
        local ok_stack, stack_count = pcall(function() return item_info:get_stack_count() end)
        if not ok_stack then return false, "Stack Count Error" end
        if check_stackable_logic(
                true,
                Utils.is_consumable_inventory_full,
                function() return get_local_player():get_consumable_items() end,
                id,
                rule.stack,
                stack_count
            ) then
            return true, "Wanted Stackable"
        else
            return false, "Stack Full"
        end
    elseif rule.check == "stackable_socketable" then
        local ok_stack, stack_count = pcall(function() return item_info:get_stack_count() end)
        if not ok_stack then return false, "Stack Count Error" end
        if check_stackable_logic(
                true,
                Utils.is_socketable_inventory_full,
                function() return get_local_player():get_socketable_items() end,
                id,
                rule.stack,
                stack_count
            ) then
            return true, "Wanted Socketable"
        else
            return false, "Socketables Full"
        end
    end

    return true, "Wanted"
end

function ItemManager.get_pick_reason_with_flags(item, ignore_distance, ignore_inventory, item_info)
    -- 1. Fast Checks (No Item Info)
    if ItemManager.is_blacklisted(item) then return false, "Blacklisted", nil end
    local settings = Settings.get()
    if not ignore_distance and Utils.distance_to(item) >= settings.distance then return false, "Out of Range", nil end
    if loot_manager.is_gold(item) then return false, "Gold", nil end
    if loot_manager.is_potion(item) then return false, "Potion", nil end

    -- 2. Get Item Info (Expensive)
    if not item_info or not item_info:is_valid() then
        ---@diagnostic disable-next-line
        local ok_info, info = pcall(function() return item:get_item_info() end)
        if not ok_info or not info or not info:is_valid() then
            return false, "Info Error", nil
        end
        item_info = info
    end

    local ok_sno, id = pcall(function() return item_info:get_sno_id() end)
    if not ok_sno then return false, "SNO Error", nil end

    -- 3. Global Checks

    -- 4. Rule Resolution
    local rule = resolve_rule(item, id, item_info)
    if not rule then
        -- Fallback to equipment rule if no specific rule found
        rule = RULES.equipment
    end

    return check_rule_logic(rule, item, id, item_info, settings)
end

---@param item game.object Item to check
---@param ignore_distance boolean If we want to ignore the distance check
---@param ignore_inventory boolean If we want to ignore the inventory check (e.g. for drawing)
---@param item_info? any Optional item info to avoid re-fetching
function ItemManager.check_want_item(item, ignore_distance, ignore_inventory, item_info)
    local wanted, reason, info = ItemManager.get_pick_reason_with_flags(item, ignore_distance, ignore_inventory,
        item_info)
    return wanted, info
end

function ItemManager.calculate_item_score(item, item_info)
    local score = 0
    if not item_info or not item_info:is_valid() then
        local ok_info, info = pcall(function() return item:get_item_info() end)
        if not ok_info or not info or not info:is_valid() then return 0 end
        item_info = info
    end

    local ok_id, item_id = pcall(function() return item_info:get_sno_id() end)
    if not ok_id or not item_id then return 0 end

    local ok_display, display_name = pcall(function() return item_info:get_display_name() end)
    if not ok_display or not display_name then return 0 end

    local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
    if not ok_rarity or not item_rarity then return 0 end

    -- Ubers are top priority
    if CustomItems.ubers[item_id] then return 1000 end

    -- Boss items next
    if CustomItems.boss_items[item_id] or CustomItems.s11_corrupted_essence[item_id] then return 900 end

    -- GA items
    local greater_affix_count = Utils.get_greater_affix_count(display_name)
    if greater_affix_count > 0 then
        return 500 + (greater_affix_count * 100)
    end

    -- Equipment by rarity
    if item_rarity >= 5 then return 100 end -- Legendary/Unique
    if item_rarity >= 3 then return 50 end  -- Rare

    -- Special enabled items (Runes, Sigils, etc)
    -- If they are enabled, they are "wanted".
    -- We can give them a moderate score so they are picked up before trash but after good gear.
    return 10
end

function ItemManager.get_item_based_on_priority()
    local settings = Settings.get()
    local items = actors_manager.get_all_items()
    if not items then return nil end

    local best_item = nil
    local best_val = -math.huge                  -- Score or -Distance

    local priority_mode = settings.loot_priority -- 0: Closest, 1: Best

    for _, item in pairs(items) do
        if item then
            local wanted, _, item_info = ItemManager.check_want_item(item, false)
            if wanted then
                local val
                if priority_mode == 0 then
                    -- Closest: Use negative distance so higher is better (closer)
                    local ok_dist, dist = pcall(function() return Utils.distance_to(item) end)
                    if ok_dist and dist then
                        val = -dist
                    else
                        val = -math.huge
                    end
                else
                    -- Best: Use score
                    val = ItemManager.calculate_item_score(item, item_info)
                end

                if val > best_val then
                    best_val = val
                    best_item = item
                end
            end
        end
    end

    return best_item
end

function ItemManager.get_item_category(item, item_info)
    local _, key = resolve_rule(item, resolve_item_id(item), item_info)
    return key
end

return ItemManager
