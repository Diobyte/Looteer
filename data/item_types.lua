local item_types = {
    sigil = { "nightmare_sigil", "s07_witchersigil", "s07_drlg_sigil", "s09_sigil", "s09_drlg_sigil", "s11_sigil", "s11_drlg_sigil", "s11_heavenly_sigil", "heavenly_sigil" },
    compass = { "bsk_sigil" },
    tribute = { "undercity_tribute" },
    equipment = { 
       "base", "amulet", "ring", "axe", "sword", "mace", "dagger", "wand", "staff", "bow", "crossbow", 
       "shield", "focus", "totem", "helm", "chest", "gloves", "pants", "boots", "glaive", "quarterstaff", "scythe"
    },
    item_cache = { "item_cache", "divine_gift" },
    quest = { "global", "glyph", "qst", "dgn", "pvp_currency", "s07_witch_bonus", "gamblingcurrency_key", "experience_powerup_actor", "s09_arcana", "s11_currency", "s11_quest", "corrupted_essence", "divine_gift" },
    crafting = { 
       "craftingmaterial", "crafting_legendary", "s11_crafting",
       "herb", "ore", "leather", "part", "fragment", "shard", "powder", "crystal", "soul", "rose", "obducite", "ingolith", "neathiron",
       "rawhide", "chunk", "bone", "dust", "tongue", "ward", "spark"
    },
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
       function(_, item_info)
          local ok_display, display = pcall(function() return item_info:get_display_name() end)
          if ok_display and type(display) == "string" then
             return display:lower():find("rune", 1, true) ~= nil
          end
          return false
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
    },
    gem = { "amethyst", "emerald", "ruby", "sapphire", "topaz", "skull", "diamond" },
    s11_special = { "memory", "deceitful", "ancient_memory" }
 }
 
 return item_types
