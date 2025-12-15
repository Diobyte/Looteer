local plugin_label = "Looter (Pirated Edition) "
local gui = {}
local options = require("data.gui_options")
local version = "v1.4.0"


gui.elements = {
   main_tree = tree_node:new(0),
   main_toggle = checkbox:new(false, get_hash(plugin_label .. "_main_toggle")),
   
   general = {
      tree = tree_node:new(1),
      behavior_combo = combo_box:new(0, get_hash(plugin_label .. "_behavior_combo")),
      loot_priority_combo = combo_box:new(0, get_hash(plugin_label .. "_loot_priority_combo")), 
      rarity_combo = combo_box:new(0, get_hash(plugin_label .. "_rarity_combo")),
      distance_slider = slider_int:new(1, 30, 2, get_hash(plugin_label .. "_distance_slider")),
      skip_dropped_toggle = checkbox:new(false, get_hash(plugin_label .. "_skipped_dropped_toggle")),
   },

   affix_settings = {
      tree = tree_node:new(1),
      greater_affix_slider = slider_int:new(0, 3, 0, get_hash(plugin_label .. "_greater_affix_slider")),
      unique_greater_affix_slider = slider_int:new(0, 4, 0, get_hash(plugin_label .. "_unique_greater_affix_slider")),
      --ubers
      uber_unique_greater_affix_slider = slider_int:new(0, 4, 0,get_hash(plugin_label .. "_uber_unique_greater_affix_slider")),
   },

   item_types = {
      tree = tree_node:new(1),
      event_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_event_items_toggle")),
      quest_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_quest_items_toggle")),
      crafting_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_crafting_items_toggle")),
      obducite_toggle = checkbox:new(false, get_hash(plugin_label .. "_obducite_toggle")),
      veiled_crystal_toggle = checkbox:new(false, get_hash(plugin_label .. "_veiled_crystal_toggle")),
      boss_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_boss_items_toggle")),
      rare_elixir_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_rare_elixir_items_toggle")),
      basic_elixir_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_basic_elixir_items_toggle")),
      advanced_elixir_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_advanced_elixir_items_toggle")),
      sigil_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_sigil_items_toggle")),
      compass_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_compass_items_toggle")),
      rune_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_rune_items_toggle")),
      prism_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_prism_items_toggle")),
      gem_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_gem_items_toggle")),
      tribute_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_tribute_items_toggle")),
      scroll_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_scroll_items_toggle")),
      s11_items_toggle = checkbox:new(false, get_hash(plugin_label .. "_s11_items_toggle")),
      cinders_toggle = checkbox:new(false, get_hash(plugin_label .. "_cinders_toggle")),
      infernal_warp_toggle = checkbox:new(false, get_hash(plugin_label .. "_infernal_warp_toggle")),
   },

   debug = {
      tree = tree_node:new(1),
      draw_wanted_toggle = checkbox:new(false, get_hash(plugin_label .. "_draw_wanted_toggle")),
   },
}
function gui.render()
   if not gui.elements.main_tree:push("Looter | Letrico | " .. version) then
      return
   end

   gui.elements.main_toggle:render("Enable", "Toggles the main module on/off")
    
   if not gui.elements.main_toggle:get() then
      gui.elements.main_tree:pop()
      return
   end
    
   if gui.elements.general.tree:push("General Settings") then
      gui.elements.general.behavior_combo:render("Behavior", options.behaviors,
         "When do you want the autolooter to execute?")
      gui.elements.general.rarity_combo:render("Rarity", options.rarities,
         "Minimum Rarity for bot to consider picking up.")
      gui.elements.general.distance_slider:render("Distance", "Distance from the loot to execute pickup")
      gui.elements.general.skip_dropped_toggle:render("Skip Self Dropped (Equipment only)",
         "Do you want the bot to not loot items that you dropped yourself?")
      gui.elements.general.loot_priority_combo:render("Loot Priority", {"Closest First", "Best First"},
         "Select the priority for looting items")
      gui.elements.general.tree:pop()
   end
       
   if gui.elements.affix_settings.tree:push("Affix Settings") then
      gui.elements.affix_settings.greater_affix_slider:render("Legendary GA Count",
      "Minimum GA's to consider picking up legendary")
      gui.elements.affix_settings.unique_greater_affix_slider:render("Unique GA Count",
      "Minimum GA's to consider picking up unique")
      gui.elements.affix_settings.uber_unique_greater_affix_slider:render("Uber GA Count",
      "Minimum GA's to consider picking up Uber unique")
      gui.elements.affix_settings.tree:pop()
   end
 
   if gui.elements.item_types.tree:push("Item Types") then
      gui.elements.item_types.quest_items_toggle:render("Quest Items",
         "Do you want to pickup Quest items, this includes Objectives in dungeons.")
      gui.elements.item_types.crafting_items_toggle:render("Crafting Items", "Do you want to pickup Crafting Items?")
      gui.elements.item_types.obducite_toggle:render("Obducite", "Do you want to pickup Obducite?")
      gui.elements.item_types.veiled_crystal_toggle:render("Veiled Crystal", "Do you want to pickup Veiled Crystal?")
      gui.elements.item_types.boss_items_toggle:render("Boss Items", "Do you want to pickup Boss summon items?")
      gui.elements.item_types.rare_elixir_items_toggle:render("Rare Elixirs",
         "Do you wanna pickup Rare Elixirs? (Momentum, Holy Bolts)")
      gui.elements.item_types.basic_elixir_items_toggle:render("Basic Elixirs",
         "Do you wanna pickup Basic Elixirs?")
      gui.elements.item_types.advanced_elixir_items_toggle:render("Advanced Elixirs",
         "Do you wanna pickup Advanced Elixirs II?")
      gui.elements.item_types.scroll_items_toggle:render("Scrolls", "Do you want to loot scrolls?")
      gui.elements.item_types.sigil_items_toggle:render("Nightmare Dungeon Sigils", "Do you want to loot dungeon sigils?")
      gui.elements.item_types.compass_items_toggle:render("Horde Compasses", "Do you want to loot horde compasses?")
      gui.elements.item_types.tribute_items_toggle:render("Tributes", "Do you want to loot tributes?")
      gui.elements.item_types.rune_items_toggle:render("Runes", "Do you want to loot runes?")
      gui.elements.item_types.prism_items_toggle:render("Prisms", "Do you want to loot prisms?")
      gui.elements.item_types.gem_items_toggle:render("Gems", "Do you want to loot gems?")
      gui.elements.item_types.event_items_toggle:render("Event", "Do you want to pickup Event items?")
      gui.elements.item_types.s11_items_toggle:render("Season 11 Items", "Do you want to pickup Season 11 items (Corrupted Essences)?")
      gui.elements.item_types.cinders_toggle:render("Cinders", "Do you want to pickup Cinders?")
      gui.elements.item_types.infernal_warp_toggle:render("Infernal Warp", "Do you want to pickup Infernal Warp?")
      gui.elements.item_types.tree:pop()
   end
 
   if gui.elements.debug.tree:push("Debug") then
      gui.elements.debug.draw_wanted_toggle:render("Draw Wanted",
         "Do you want to draw the items that the bot considers picking up? (Debug)")
      gui.elements.debug.tree:pop()
   end
 
   gui.elements.main_tree:pop()
end

return gui
