local Settings = require("src.settings")
local ItemManager = require("src.item_manager")
local Utils = require("utils.utils")

local Renderer = {}

local wanted_items_cache = {}
local last_cache_update = 0
local CACHE_INTERVAL = 0.2

function Renderer.draw_stuff()
    local player = get_local_player()
    if not player then return end
    local settings = Settings.get()
    if not settings.enabled then return end

    local base_pos = get_player_position()
    if Utils.is_inventory_full() then
        graphics.text_3d("Inventory Full", base_pos, 20, color.new(255, 0, 0, 255))
    end
    if Utils.is_consumable_inventory_full() then
        graphics.text_3d("Consumable Inventory Full", vec3:new(base_pos:x(), base_pos:y(), base_pos:z() + 1), 20,
            color.new(255, 0, 0, 255))
    end
    if Utils.is_socketable_inventory_full() then
        graphics.text_3d("Socketable Inventory Full", vec3:new(base_pos:x(), base_pos:y(), base_pos:z() + 2), 20,
            color.new(255, 0, 0, 255))
    end
    if Utils.is_sigil_inventory_full() then
        graphics.text_3d("Sigil Inventory Full", vec3:new(base_pos:x(), base_pos:y(), base_pos:z() + 3), 20,
            color.new(255, 0, 0, 255))
    end

    if not settings.draw_wanted_items then return end

    local current_time = get_time_since_inject()
    if current_time - last_cache_update > CACHE_INTERVAL then
        wanted_items_cache = {}
        local items = actors_manager.get_all_items()
        if items then
            for _, item in pairs(items) do
                if item then
                    -- Get full debug info
                    local ok_debug, debug_info = pcall(function() return ItemManager.get_debug_info(item) end)
                    if not ok_debug then debug_info = "Error getting debug info" end

                    -- Check wanted status for coloring (don't ignore distance for renderer)
                    local wanted = ItemManager.check_want_item(item, true, true)
                    table.insert(wanted_items_cache, { item = item, wanted = wanted, debug_info = debug_info })
                end
            end
        end
        last_cache_update = current_time
    end

    for _, entry in ipairs(wanted_items_cache) do
        local item = entry.item
        local wanted = entry.wanted
        local debug_info = entry.debug_info

        local ok, pos = pcall(function() return item:get_position() end)
        if ok and pos then
            local color_val = wanted and color.new(0, 255, 0, 255) or color.new(255, 0, 0, 255)
            if wanted then
                graphics.circle_3d(pos, 0.5, color_val, 2)
            end

            -- Convert 3D position to 2D screen coordinates
            local screen_pos = graphics.w2s(pos)
            if screen_pos and not screen_pos:is_zero() then
                -- Parse the debug_info string and split into lines
                local parts = {}
                for part in string.gmatch(debug_info, "[^|]+") do
                    table.insert(parts, part:match("^%s*(.-)%s*$")) -- Trim whitespace
                end

                -- Draw each part on a separate line with vertical offset
                local base_y = screen_pos.y
                for i, text in ipairs(parts) do
                    local line_pos = vec2.new(screen_pos.x, base_y + (i - 1) * 15)
                    graphics.text_2d(text, line_pos, 12, color_val)
                end
            end
        end
    end
end

return Renderer
