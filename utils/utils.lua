local Utils = {}

function Utils.distance_to(object)
   local player_pos = get_player_position()
   if not player_pos then return math.huge end

   local ok_pos, obj_pos = pcall(function() return object:get_position() end)
   if not ok_pos or not obj_pos then return math.huge end

   return player_pos:dist_to_ignore_z(obj_pos)
end

function Utils.get_greater_affix_count(item_info)
   if not item_info or not item_info:is_valid() then
      return 0
   end

   local ok, count = pcall(function() return item_info:get_attribute("Item_Greater_Affix_Count") end)
   if ok and count then
      return math.floor(count)
   end

   return 0
end

function Utils.is_lowest_stack_below(inventory, item_id, max_stack, looted_stack)
   if not inventory then return true end -- Return true if no inventory (safer to try pickup)
   if not item_id or not max_stack or not looted_stack then return false end

   local lowest_stack = max_stack -- Initialize with max_stack

   for _, item in pairs(inventory) do
      if item and item:is_valid() then
         local ok_sno, sno = pcall(function() return item:get_sno_id() end)
         if ok_sno and sno == item_id then
            local ok_stack, stack_count = pcall(function() return item:get_stack_count() end)
            if ok_stack and stack_count and stack_count < lowest_stack then
               lowest_stack = stack_count
            end
         end
      end
   end

   -- Return true only if lowest stack + looted stack is less than equals max_stack
   return (lowest_stack + looted_stack) <= max_stack
end

function Utils.is_inventory_full()
   return get_local_player():get_item_count() == 33
end

function Utils.is_consumable_inventory_full()
   return get_local_player():get_consumable_count() == 33
end

function Utils.is_sigil_inventory_full()
   return #get_local_player():get_dungeon_key_items() == 33
end

local SOCKETABLE_CAPACITY = 96 -- conservative cap to accommodate expanded socketable storage

function Utils.is_socketable_inventory_full()
   local local_player = get_local_player()
   if not local_player then
      return false
   end
   local socketables = local_player:get_socketable_items()
   return #socketables >= SOCKETABLE_CAPACITY
end

function Utils.player_in_zone(zname)
   return world.get_current_zone_name() == zname
end

function Utils.item_exists(id)
   if not id then return false end
   local ok_items, items = pcall(function() return actors_manager.get_all_items() end)
   if not ok_items or not items then return false end

   for _, it in pairs(items) do
      if it then
         local ok_id, item_id = pcall(function() return it:get_id() end)
         if ok_id and item_id == id then
            return true
         end
      end
   end
   return false
end

return Utils
