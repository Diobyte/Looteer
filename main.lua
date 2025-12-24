local Settings = require("src.settings")
local ItemManager = require("src.item_manager")
local Renderer = require("src.renderer")
local GUI = require("gui")
local Utils = require("utils.utils")
local explorerlite = require "core.explorerlite"
local CustomItems = require("data.custom_items")
local TargetManager = require("src.target_manager")

local function handle_loot(wanted_item)
   if not wanted_item then return end

   local ok_id, current_id = pcall(function() return wanted_item:get_id() end)
   local ok_pos, item_position = pcall(function() return wanted_item:get_position() end)
   if not ok_id or not ok_pos or not current_id or not item_position then
      return
   end

   local walkover = ItemManager.is_walkover_item(wanted_item)
   local player_position = get_player_position()
   if not player_position then return end

   local distance = player_position:dist_to_ignore_z(item_position)
   local stop_dist = walkover and 0.5 or 2.0

   if TargetManager.check_timeout(current_id) then
      ItemManager.blacklist_item(wanted_item, 10.0)
      TargetManager.attempt_unstuck()
      TargetManager.clear()
      return
   end

   if distance > stop_dist then
      local prev_id = TargetManager.get_current_id()
      if prev_id ~= current_id then
         explorerlite:set_custom_target(item_position)
      end
      explorerlite:move_to_target()
      TargetManager.set_target(current_id, walkover)
      return
   end

   if walkover then
      local prev_id = TargetManager.get_current_id()
      if prev_id ~= current_id then
         explorerlite:set_custom_target(item_position)
      end
      explorerlite:move_to_target()
      TargetManager.set_target(current_id, true)
      return
   end

   TargetManager.reset()
   local ok_interact = pcall(function() interact_object(wanted_item) end)
   if not ok_interact then
      ItemManager.blacklist_item(wanted_item, 5.0)
      TargetManager.clear()
      return
   end

   -- Check if item was successfully picked up
   if Utils.item_exists(current_id) then
      -- Item still exists, pickup failed (e.g., inventory full)
      if TargetManager.register_failure(current_id) then
         TargetManager.clear()
         return
      end
   else
      -- Pickup successful, reset failure count
      TargetManager.reset_failure(current_id)
   end
end

local function main_pulse()
   local player = get_local_player()
   if not player then return end

   TargetManager.prune_failures()

   Settings.update()
   local settings = Settings.get()
   if not settings.enabled or not Settings.should_execute() then
      settings.looting = false
      return
   end

   orbwalker.set_auto_loot_toggle(false)

   -- If the active target vanished (e.g., pet pickup), stop pathing
   local current_id = TargetManager.get_current_id()
   if current_id and not Utils.item_exists(current_id) then
      TargetManager.clear()
   end

   local wanted_item = ItemManager.get_item_based_on_priority()
   settings.looting = wanted_item ~= nil
   if not wanted_item then
      if TargetManager.get_current_id() then
         TargetManager.clear()
      end
      return
   end

   handle_loot(wanted_item)
end

-- Set Global access for other plugins
LooteerPlugin = {
   getSettings = function(setting)
      if Settings.get()[setting] then
         return Settings.get()[setting]
      else
         return nil
      end
   end,
   setSettings = function(setting, value)
      if Settings.get()[setting] then
         Settings.get()[setting] = value
         return true
      else
         return false
      end
   end,
}

on_update(main_pulse)
on_render_menu(GUI.render)
on_render(Renderer.draw_stuff)
