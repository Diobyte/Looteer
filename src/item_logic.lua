local ItemLogic = {}

local ItemRarity = {
    Normal = 0,
    Magic = 1,
    Rare = 2,
    Legendary = 5,
    Unique = 6,
    Set = 7
}

-- Helper function to safely get item info
local function safe_check_item(item, rarity, pattern)
   if not item then return false end
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return false end
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity or item_rarity ~= rarity then return false end
   local ok_name, skin_name = pcall(function() return item_info:get_skin_name() end)
   if not ok_name or not skin_name then return false end
   return skin_name:find(pattern) ~= nil
end

--Jewelry
function ItemLogic.is_legendary_amulet(item)
   return safe_check_item(item, ItemRarity.Legendary, "Amulet")
end
function ItemLogic.is_unique_amulet(item)
   if not item then return false end
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return false end
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity or item_rarity ~= ItemRarity.Unique then return false end
   local ok_name, skin_name = pcall(function() return item_info:get_skin_name() end)
   if not ok_name or not skin_name then return false end
   return skin_name:find("Amulet") or skin_name:find("Necklace")
end
function ItemLogic.is_unique_ring(item)
   return safe_check_item(item, ItemRarity.Unique, "Ring")
end
function ItemLogic.is_legendary_ring(item)
   return safe_check_item(item, ItemRarity.Legendary, "Ring")
end
--Armors
function ItemLogic.is_legendary_helm(item)
   return safe_check_item(item, ItemRarity.Legendary, "HLM")
end
function ItemLogic.is_unique_helm(item)
   return safe_check_item(item, ItemRarity.Unique, "HLM")
end
function ItemLogic.is_legendary_chest(item)
   return safe_check_item(item, ItemRarity.Legendary, "TRS")
end
function ItemLogic.is_unique_chest(item)
   return safe_check_item(item, ItemRarity.Unique, "TRS")
end
function ItemLogic.is_legendary_gloves(item)
   return safe_check_item(item, ItemRarity.Legendary, "GLV")
end
function ItemLogic.is_unique_gloves(item)
   if not item then return false end
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return false end
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity or item_rarity ~= ItemRarity.Unique then return false end
   local ok_name, skin_name = pcall(function() return item_info:get_skin_name() end)
   if not ok_name or not skin_name then return false end
   return skin_name:find("GLV") or skin_name:find("Gloves")
end
function ItemLogic.is_legendary_pants(item)
   return safe_check_item(item, ItemRarity.Legendary, "LEG")
end
function ItemLogic.is_unique_pants(item)
   if not item then return false end
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return false end
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity or item_rarity ~= ItemRarity.Unique then return false end
   local ok_name, skin_name = pcall(function() return item_info:get_skin_name() end)
   if not ok_name or not skin_name then return false end
   return skin_name:find("LEG") or skin_name:find("Pants")
end
function ItemLogic.is_legendary_boots(item)
   return safe_check_item(item, ItemRarity.Legendary, "BTS")
end
function ItemLogic.is_unique_boots(item)
   return safe_check_item(item, ItemRarity.Unique, "BTS")
end

--offhand
function ItemLogic.is_legendary_shield(item)
   return safe_check_item(item, ItemRarity.Legendary, "Shield")
end
function ItemLogic.is_unique_shield(item)
   return safe_check_item(item, ItemRarity.Unique, "Shield")
end
function ItemLogic.is_legendary_focus(item)
   return safe_check_item(item, ItemRarity.Legendary, "offHandsSorc")
end
function ItemLogic.is_unique_focus(item)
   return safe_check_item(item, ItemRarity.Unique, "offHandsSorc")
end
function ItemLogic.is_legendary_totem(item)
   return safe_check_item(item, ItemRarity.Legendary, "offHandsDruid")
end
function ItemLogic.is_unique_totem(item)
   return safe_check_item(item, ItemRarity.Unique, "offHandsDruid")
end

--1Handed Weapons
function ItemLogic.is_legendary_1h_mace(item)
   return safe_check_item(item, ItemRarity.Legendary, "mace")
end
function ItemLogic.is_legendary_1h_axe(item)
   return safe_check_item(item, ItemRarity.Legendary, "axe")
end
function ItemLogic.is_legendary_1h_sword(item)
   return safe_check_item(item, ItemRarity.Legendary, "sword")
end
function ItemLogic.is_legendary_dagger(item)
   return safe_check_item(item, ItemRarity.Legendary, "dagger")
end
function ItemLogic.is_legendary_wand(item)
   return safe_check_item(item, ItemRarity.Legendary, "wand")
end
function ItemLogic.is_legendary_1h_scythe(item)
   return safe_check_item(item, ItemRarity.Legendary, "scythe")
end
function ItemLogic.is_unique_1h_mace(item)
   return safe_check_item(item, ItemRarity.Unique, "mace")
end
function ItemLogic.is_unique_1h_axe(item)
   return safe_check_item(item, ItemRarity.Unique, "axe")
end
function ItemLogic.is_unique_1h_sword(item)
   return safe_check_item(item, ItemRarity.Unique, "sword")
end
function ItemLogic.is_unique_dagger(item)
   return safe_check_item(item, ItemRarity.Unique, "dagger")
end
function ItemLogic.is_unique_wand(item)
   return safe_check_item(item, ItemRarity.Unique, "wand")
end
function ItemLogic.is_unique_1h_scythe(item)
   return safe_check_item(item, ItemRarity.Unique, "scythe")
end

--2H Weapons
function ItemLogic.is_legendary_2h_mace(item)
   return safe_check_item(item, ItemRarity.Legendary, "Mace")
end
function ItemLogic.is_legendary_2h_axe(item)
   return safe_check_item(item, ItemRarity.Legendary, "Axe")
end
function ItemLogic.is_legendary_2h_sword(item)
   return safe_check_item(item, ItemRarity.Legendary, "Sword")
end
function ItemLogic.is_legendary_2h_polearm(item)
   return safe_check_item(item, ItemRarity.Legendary, "Polearm")
end
function ItemLogic.is_legendary_staff(item)
   return safe_check_item(item, ItemRarity.Legendary, "Staff")
end
function ItemLogic.is_legendary_bow(item)
   return safe_check_item(item, ItemRarity.Legendary, "Bow")
end
function ItemLogic.is_legendary_crossbow(item)
   return safe_check_item(item, ItemRarity.Legendary, "Crossbow")
end
function ItemLogic.is_legendary_glaive(item)
   return safe_check_item(item, ItemRarity.Legendary, "Glaive")
end
function ItemLogic.is_legendary_quarterstaff(item)
   return safe_check_item(item, ItemRarity.Legendary, "Quarterstaff")
end
function ItemLogic.is_legendary_2h_scythe(item)
   return safe_check_item(item, ItemRarity.Legendary, "Scythe")
end
function ItemLogic.is_unique_2h_mace(item)
   return safe_check_item(item, ItemRarity.Unique, "Mace")
end
function ItemLogic.is_unique_2h_axe(item)
   return safe_check_item(item, ItemRarity.Unique, "Axe")
end
function ItemLogic.is_unique_2h_sword(item)
   return safe_check_item(item, ItemRarity.Unique, "Sword")
end
function ItemLogic.is_unique_2h_polearm(item)
   return safe_check_item(item, ItemRarity.Unique, "Polearm")
end
function ItemLogic.is_unique_staff(item)
   return safe_check_item(item, ItemRarity.Unique, "Staff")
end
function ItemLogic.is_unique_bow(item)
   return safe_check_item(item, ItemRarity.Unique, "Bow")
end
function ItemLogic.is_unique_crossbow(item)
   return safe_check_item(item, ItemRarity.Unique, "Crossbow")
end
function ItemLogic.is_unique_glaive(item)
   return safe_check_item(item, ItemRarity.Unique, "Glaive")
end
function ItemLogic.is_unique_quarterstaff(item)
   return safe_check_item(item, ItemRarity.Unique, "Quarterstaff")
end
function ItemLogic.is_unique_2h_scythe(item)
   return safe_check_item(item, ItemRarity.Unique, "Scythe")
end


 return ItemLogic