local Settings = require("src.settings")
local Utils = require("utils.utils")
local CustomItems = require("data.custom_items")
local ItemLogic = require("src.item_logic")

local ItemManager = {}

local function to_lower(str)
   return str and string.lower(str) or ""
end

-- Table to store item type patterns
local item_type_patterns = {
   sigil = { "nightmare_sigil", "s07_witchersigil", "s07_drlg_sigil" },
   compass = { "bsk_sigil" },
   tribute = { "undercity_tribute" },
   equipment = { 
      "base", "amulet", "ring", "axe", "sword", "mace", "dagger", "wand", "staff", "bow", "crossbow", 
      "shield", "focus", "totem", "helm", "chest", "gloves", "pants", "boots", "glaive", "quarterstaff", "scythe"
   },
   item_cache = { "item_cache" },
   quest = { "global", "glyph", "qst", "dgn", "pvp_currency", "s07_witch_bonus", "gamblingcurrency_key", "experience_powerup_actor", "s09_arcana" },
   crafting = { "craftingmaterial", "crafting_legendary" },
   recipe = { "tempering_recipe", "item_book_generic", "item_book_horadrim", "test_mount", "mnt_amor", "mountreins" },
   cinders = { "test_bloodmoon_currency" },
   infernal_warp = { "s10_chaos_currency" },
   scroll = { "scroll_of" },
   rune = {
      "generic_rune",
      "socketable",
      function(_, _, name_lower)
         return name_lower:find("rune", 1, true) ~= nil
      end,
   },
   prism = {
      "prism",
      function(_, item_info)
         local ok_display, display = pcall(function() return item_info:get_display_name() end)
         if ok_display and type(display) == "string" then
            return display:lower():find("prism", 1, true) ~= nil
         end
         return false
      end,
   }
}

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

-- Generic function to check item type
function ItemManager.check_item_type(item, type_name)
   local item_info = item and item:get_item_info()
   if not item_info then return false end
   local ok, name = pcall(function() return item_info:get_skin_name() end)
   if not ok or not name then return false end
   local name_lower = to_lower(name)

   -- Special case for equipment
   -- if type_name == "equipment" and item_info:get_rarity() ~= 0 then
   --    return false
   -- end

   for _, pattern in ipairs(item_type_patterns[type_name] or {}) do
      local pattern_type = type(pattern)
      if pattern_type == "string" then
         if name_lower:find(pattern, 1, true) then
            return true
         end
      elseif pattern_type == "function" then
         if pattern(item, item_info, name_lower) then
            return true
         end
      end
   end
   return false
end

function ItemManager.check_item_stack(item, id)
   local stack = 1
   if (CustomItems.rare_elixirs[id] or
         CustomItems.basic_elixirs[id] or
         CustomItems.advanced_elixirs[id]) then
      stack = 99
   elseif ItemManager.check_is_scroll(item) then
      stack = 20
   elseif CustomItems.boss_items[id] then
      stack = 99
   elseif ItemManager.check_is_rune(item) or ItemManager.check_is_prism(item) then
      stack = 100
   end

   return stack
end

function ItemManager.check_is_infernal_warp(item)
   return ItemManager.check_item_type(item, "infernal_warp")
end

function ItemManager.check_is_cinders(item)
   return ItemManager.check_item_type(item, "cinders")
end

function ItemManager.check_is_tribute(item)
   return ItemManager.check_item_type(item, "tribute")
end

function ItemManager.check_is_sigil(item)
   return ItemManager.check_item_type(item, "sigil")
end

function ItemManager.check_is_compass(item)
   return ItemManager.check_item_type(item, "compass")
end

function ItemManager.check_is_equipment(item)
   return ItemManager.check_item_type(item, "equipment")
end

function ItemManager.check_is_quest_item(item)
   return ItemManager.check_item_type(item, "quest")
end

function ItemManager.check_is_crafting(item)
   return ItemManager.check_item_type(item, "crafting")
end

function ItemManager.check_is_recipe(item)
   return ItemManager.check_item_type(item, "recipe")
end

function ItemManager.check_is_item_cache(item)
   return ItemManager.check_item_type(item, "item_cache")
end

function ItemManager.check_is_scroll(item)
   return ItemManager.check_item_type(item, "scroll")
end

function ItemManager.check_is_cache(item)
   return ItemManager.check_item_type(item, "cache")
end

function ItemManager.check_is_rune(item)
   return ItemManager.check_item_type(item, "rune")
end

function ItemManager.check_is_prism(item)
   return ItemManager.check_item_type(item, "prism")
end

function ItemManager.check_is_opal(item)
   return ItemManager.check_item_type(item, "opal")
end

local ga_settings_map = {
   { check = ItemLogic.is_legendary_amulet, setting = "legendary_amulet_ga_count" },
   { check = ItemLogic.is_legendary_ring, setting = "legendary_ring_ga_count" },
   { check = ItemLogic.is_unique_amulet, setting = "unique_amulet_ga_count" },
   { check = ItemLogic.is_unique_ring, setting = "unique_ring_ga_count" },
   { check = ItemLogic.is_legendary_helm, setting = "legendary_helm_ga_count" },
   { check = ItemLogic.is_unique_helm, setting = "unique_helm_ga_count" },
   { check = ItemLogic.is_legendary_chest, setting = "legendary_chest_ga_count" },
   { check = ItemLogic.is_unique_chest, setting = "unique_chest_ga_count" },
   { check = ItemLogic.is_legendary_gloves, setting = "legendary_gloves_ga_count" },
   { check = ItemLogic.is_unique_gloves, setting = "unique_gloves_ga_count" },
   { check = ItemLogic.is_legendary_pants, setting = "legendary_pants_ga_count" },
   { check = ItemLogic.is_unique_pants, setting = "unique_pants_ga_count" },
   { check = ItemLogic.is_legendary_boots, setting = "legendary_boots_ga_count" },
   { check = ItemLogic.is_unique_boots, setting = "unique_boots_ga_count" },
   { check = ItemLogic.is_legendary_shield, setting = "legendary_shield_ga_count" },
   { check = ItemLogic.is_unique_shield, setting = "unique_shield_ga_count" },
   { check = ItemLogic.is_legendary_focus, setting = "legendary_focus_ga_count" },
   { check = ItemLogic.is_unique_focus, setting = "unique_focus_ga_count" },
   { check = ItemLogic.is_legendary_totem, setting = "legendary_totem_ga_count" },
   { check = ItemLogic.is_unique_totem, setting = "unique_totem_ga_count" },
   { check = ItemLogic.is_legendary_1h_mace, setting = "legendary_1h_mace_ga_count" },
   { check = ItemLogic.is_legendary_1h_axe, setting = "legendary_1h_axe_ga_count" },
   { check = ItemLogic.is_legendary_1h_sword, setting = "legendary_1h_sword_ga_count" },
   { check = ItemLogic.is_legendary_dagger, setting = "legendary_dagger_ga_count" },
   { check = ItemLogic.is_legendary_wand, setting = "legendary_wand_ga_count" },
   { check = ItemLogic.is_legendary_1h_scythe, setting = "legendary_1h_scythe_ga_count" },
   { check = ItemLogic.is_unique_1h_mace, setting = "unique_1h_mace_ga_count" },
   { check = ItemLogic.is_unique_1h_axe, setting = "unique_1h_axe_ga_count" },
   { check = ItemLogic.is_unique_1h_sword, setting = "unique_1h_sword_ga_count" },
   { check = ItemLogic.is_unique_dagger, setting = "unique_dagger_ga_count" },
   { check = ItemLogic.is_unique_wand, setting = "unique_wand_ga_count" },
   { check = ItemLogic.is_unique_1h_scythe, setting = "unique_1h_scythe_ga_count" },
   { check = ItemLogic.is_legendary_2h_axe, setting = "legendary_2h_axe_ga_count" },
   { check = ItemLogic.is_legendary_2h_mace, setting = "legendary_2h_mace_ga_count" },
   { check = ItemLogic.is_legendary_2h_sword, setting = "legendary_2h_sword_ga_count" },
   { check = ItemLogic.is_legendary_2h_polearm, setting = "legendary_2h_polearm_ga_count" },
   { check = ItemLogic.is_legendary_staff, setting = "legendary_staff_ga_count" },
   { check = ItemLogic.is_legendary_bow, setting = "legendary_bow_ga_count" },
   { check = ItemLogic.is_legendary_crossbow, setting = "legendary_crossbow_ga_count" },
   { check = ItemLogic.is_legendary_glaive, setting = "legendary_glaive_ga_count" },
   { check = ItemLogic.is_legendary_quarterstaff, setting = "legendary_quarterstaff_ga_count" },
   { check = ItemLogic.is_legendary_2h_scythe, setting = "legendary_2h_scythe_ga_count" },
   { check = ItemLogic.is_unique_2h_axe, setting = "unique_2h_axe_ga_count" },
   { check = ItemLogic.is_unique_2h_mace, setting = "unique_2h_mace_ga_count" },
   { check = ItemLogic.is_unique_2h_sword, setting = "unique_2h_sword_ga_count" },
   { check = ItemLogic.is_unique_2h_polearm, setting = "unique_2h_polearm_ga_count" },
   { check = ItemLogic.is_unique_staff, setting = "unique_staff_ga_count" },
   { check = ItemLogic.is_unique_bow, setting = "unique_bow_ga_count" },
   { check = ItemLogic.is_unique_crossbow, setting = "unique_crossbow_ga_count" },
   { check = ItemLogic.is_unique_glaive, setting = "unique_glaive_ga_count" },
   { check = ItemLogic.is_unique_quarterstaff, setting = "unique_quarterstaff_ga_count" },
   { check = ItemLogic.is_unique_2h_scythe, setting = "unique_2h_scythe_ga_count" },
}

---@param item game.object Item to check
---@param ignore_distance boolean If we want to ignore the distance check
---@param ignore_inventory boolean If we want to ignore the inventory check (e.g. for drawing)
function ItemManager.check_want_item(item, ignore_distance, ignore_inventory)
   ---@diagnostic disable-next-line
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info then return false end
   if not item_info then return false end
   if ItemManager.is_blacklisted(item) then return false end

   local settings = Settings.get()
   local id = item_info:get_sno_id()
   local rarity = item_info:get_rarity()
   local affixes = item_info:get_affixes()

   -- Early return checks
   if not ignore_distance and Utils.distance_to(item) >= settings.distance then return false end
   if settings.skip_dropped and #affixes > 0 then
      local ok_row, row = pcall(function() return item_info:get_inventory_row() end)
      local ok_col, col = pcall(function() return item_info:get_inventory_column() end)
      if ok_row and ok_col and row and col and row >= 0 and col >= 0 then
         return false
      end
   end
   if loot_manager.is_gold(item) or loot_manager.is_potion(item) then return false end
   
   -- Check for Obducite BEFORE general crafting check to prevent interference
   local is_obducite = CustomItems.obducite[id]
   if is_obducite then
      -- Only pick up if obducite toggle is enabled
      return settings.obducite
   end
   
   -- Check for Veiled Crystal BEFORE general crafting check to prevent interference
   local is_veiled_crystal = CustomItems.veiled_crystal[id]
   if is_veiled_crystal then
      -- Only pick up if veiled_crystal toggle is enabled
      return settings.veiled_crystal
   end
   
   local is_consumable_item =
      (settings.boss_items and CustomItems.boss_items[id]) or
      (settings.rare_elixirs and CustomItems.rare_elixirs[id]) or
      (settings.basic_elixirs and CustomItems.basic_elixirs[id]) or
      (settings.advanced_elixirs and CustomItems.advanced_elixirs[id]) or
      (settings.scroll and ItemManager.check_is_scroll(item))

   local is_sigils = 
      (settings.sigils and ItemManager.check_is_sigil(item)) or
      (settings.tribute and ItemManager.check_is_tribute(item)) or
      (settings.compass and ItemManager.check_is_compass(item))

   local is_quest_item = settings.quest_items and ItemManager.check_is_quest_item(item)
   local is_event_item = settings.event_items and CustomItems.event_items[id]
   local is_cinders = settings.cinders and ItemManager.check_is_cinders(item)
   local is_infernal_warp = settings.infernal_warp and ItemManager.check_is_infernal_warp(item)
   local is_crafting_item = settings.crafting_items and ItemManager.check_is_crafting(item)
   local is_rune = settings.rune and ItemManager.check_is_rune(item)
   local is_prism = settings.prism and ItemManager.check_is_prism(item)
   local is_recipe = settings.crafting_items and ItemManager.check_is_recipe(item)
   local is_item_cache = ItemManager.check_is_item_cache(item)

   if is_event_item then
      -- Event items go to consumable inventory; only pick up if consumable inventory is not full
      if Utils.is_consumable_inventory_full() then
         return false 
      else
         return true 
      end
   elseif is_crafting_item or is_cinders or is_infernal_warp then
      -- If the item is crafting material or cinders, skip inventory and consumable checks
      return true
   elseif is_sigils then
      -- Sigil has its own inventory now, only pick it if sigil inventory is not full
      if not Utils.is_sigil_inventory_full() then
         return true
      end
   elseif is_consumable_item then
      -- Consumable inventory check and if have existing stack to loot
      if not Utils.is_consumable_inventory_full() or
            Utils.is_lowest_stack_below(
               get_local_player():get_consumable_items(),
               id,
               ItemManager.check_item_stack(item, id),
               item_info:get_stack_count()
            ) then
         return true
      end
   elseif is_rune or is_prism then
      -- Socketable inventory check and if have existing stack to loot
      if not Utils.is_socketable_inventory_full() or
            Utils.is_lowest_stack_below(
               get_local_player():get_socketable_items(),
               id,
               ItemManager.check_item_stack(item, id),
               item_info:get_stack_count()
            ) then
         return true
      else
         return false
      end
   elseif is_recipe then
      if not Utils.is_inventory_full() then
         return true
      end
   elseif is_item_cache then
      if not Utils.is_inventory_full() then
         return true
      end
   elseif is_quest_item then
      -- Loot them all quest items
      return true
   end

   -- Handle Equipments
   local inventory_full = Utils.is_inventory_full()
   if not ignore_inventory and inventory_full then return false end

   -- Check rarity
   if rarity < settings.rarity then return false end

   -- Check greater affixes for high rarity items
   if rarity >= 5 then
      local greater_affix_count = Utils.get_greater_affix_count(item_info:get_display_name())
      local required_ga_count

      if Settings.get().custom_toggle then
         for _, map in ipairs(ga_settings_map) do
            if map.check(item) then
               required_ga_count = settings[map.setting]
               break
            end
         end
      end

      if not required_ga_count then
         -- Fallback to general settings for rarity == 5 or unique/uber items
         if rarity == 5 then
            required_ga_count = settings.ga_count
         elseif rarity == 6 then
            required_ga_count = settings.unique_ga_count
         elseif rarity == 8 then
            required_ga_count = CustomItems.ubers[id] and settings.uber_unique_ga_count or settings.unique_ga_count
         else
            -- For any other rarity, use the general legendary setting as fallback
            required_ga_count = settings.ga_count
         end
      end
      
      if greater_affix_count < required_ga_count then
         return false
      end
   end
   return true
end

function ItemManager.get_nearby_item()
   local items = actors_manager:get_all_items()
   local nearest_item = nil
   local nearest_dist = math.huge
   for _, item in pairs(items) do
      if ItemManager.check_want_item(item, false) then
         local d = Utils.distance_to(item)
         if d < nearest_dist then
            nearest_dist = d
            nearest_item = item
         end
      end
   end
   return nearest_item
end

function ItemManager.calculate_item_score(item)
   local score = 0
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return 0 end
   
   local ok_id, item_id = pcall(function() return item_info:get_sno_id() end)
   if not ok_id then return 0 end
   
   local ok_display, display_name = pcall(function() return item_info:get_display_name() end)
   if not ok_display then return 0 end
   
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity then return 0 end

   if CustomItems.ubers[item_id] then
      score = score + 1000
   elseif item_rarity >= 5 then
      score = score + 500
   elseif item_rarity >= 3 then
      score = score + 300
   elseif item_rarity >= 1 then
      score = score + 100
   else
      score = score + 10
   end

   local greater_affix_count = Utils.get_greater_affix_count(display_name)

   if greater_affix_count == 3 then
      score = score + 100
   elseif greater_affix_count == 2 then
      score = score + 75
   elseif greater_affix_count == 1 then
      score = score + 50
   end

   return score
end

function ItemManager.get_best_item()
   local items = actors_manager:get_all_items()
   local best_item = nil
   local best_score = -math.huge
   for _, item in ipairs(items) do
      if ItemManager.check_want_item(item, false) then
         local score = ItemManager.calculate_item_score(item)
         if score > best_score then
            best_score = score
            best_item = item
         end
      end
   end
   if best_item then
      return { Item = best_item, Score = best_score }
   end
   return nil
end

function ItemManager.get_item_based_on_priority()
   local settings = Settings.get()
   if settings.loot_priority == 0 then
      return ItemManager.get_nearby_item()
   else
      return ItemManager.get_best_item()
   end
end

return ItemManager
