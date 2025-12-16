local gui = require("gui")

local Settings = {}

local settings = {
   enabled = false,
   looting = false,
   custom_toggle = false,
   isArmor = false ,
   behavior = 0,
   rarity = 0,
   distance = 2,
   loot_priority = 0,
   ga_count = 0,
   unique_ga_count = 0,
   uber_unique_ga_count = 0,
   quest_items = false,
   crafting_items = false,
   obducite = false,
   veiled_crystal = false,
   cinders = false,
   infernal_warp = false,
   boss_items = false,
   rare_elixirs = false,
   advanced_elixirs = false,
   basic_elixirs = false,
   sigils = false,
   compass = false,
   rune = false,
   prism = false,
   gem = false,
   tribute = false,
   scroll = false,
   event_items = true,
   s11_items = true,

   draw_wanted_items = false
}

function Settings.update()
   settings = {
      enabled = gui.elements.main_toggle:get(),
      
      -- General Settings
      behavior = gui.elements.general.behavior_combo:get(),
      rarity = gui.elements.general.rarity_combo:get(),
      distance = gui.elements.general.distance_slider:get(),
      loot_priority = gui.elements.general.loot_priority_combo:get(),
      
      -- Affix Settings
      ga_count = gui.elements.affix_settings.greater_affix_slider:get(),
      unique_ga_count = gui.elements.affix_settings.unique_greater_affix_slider:get(),
      uber_unique_ga_count = gui.elements.affix_settings.uber_unique_greater_affix_slider:get(),
      
      -- Item Types
      quest_items = gui.elements.item_types.quest_items_toggle:get(),
      s11_items = gui.elements.item_types.s11_items_toggle:get(),
      crafting_items = gui.elements.item_types.crafting_items_toggle:get(),
      obducite = gui.elements.item_types.obducite_toggle:get(),
      veiled_crystal = gui.elements.item_types.veiled_crystal_toggle:get(),
      boss_items = gui.elements.item_types.boss_items_toggle:get(),
      rare_elixirs = gui.elements.item_types.rare_elixir_items_toggle:get(),
      basic_elixirs = gui.elements.item_types.basic_elixir_items_toggle:get(),
      advanced_elixirs = gui.elements.item_types.advanced_elixir_items_toggle:get(),
      sigils = gui.elements.item_types.sigil_items_toggle:get(),
      compass = gui.elements.item_types.compass_items_toggle:get(),
      rune = gui.elements.item_types.rune_items_toggle:get(),
      prism = gui.elements.item_types.prism_items_toggle:get(),
      gem = gui.elements.item_types.gem_items_toggle:get(),
      cinders = gui.elements.item_types.cinders_toggle:get(),
      tribute = gui.elements.item_types.tribute_items_toggle:get(),
      scroll = gui.elements.item_types.scroll_items_toggle:get(),
      event_items = gui.elements.item_types.event_items_toggle:get(),
      infernal_warp = gui.elements.item_types.infernal_warp_toggle:get(),

      -- Debug
      draw_wanted_items = gui.elements.debug.draw_wanted_toggle:get()
   }
end

function Settings.get()
   return settings
end

function Settings.should_execute()
   return settings.behavior == 0 or
       (settings.behavior == 1 and orbwalker.get_orb_mode() == orb_mode.clear)
end

return Settings
