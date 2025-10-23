
local ItemLogic = {}

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
   return safe_check_item(item, 5, "Amulet")
end
function ItemLogic.is_unique_amulet(item)
   if not item then return false end
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return false end
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity or item_rarity ~= 6 then return false end
   local ok_name, skin_name = pcall(function() return item_info:get_skin_name() end)
   if not ok_name or not skin_name then return false end
   return skin_name:find("Amulet") or skin_name:find("Necklace")
end
function ItemLogic.is_unique_ring(item)
   return safe_check_item(item, 6, "Ring")
end
function ItemLogic.is_legendary_ring(item)
   return safe_check_item(item, 5, "Ring")
end
--Armors
function ItemLogic.is_legendary_helm(item)
   return safe_check_item(item, 5, "HLM")
end
function ItemLogic.is_unique_helm(item)
   return safe_check_item(item, 6, "HLM")
end
function ItemLogic.is_legendary_chest(item)
   return safe_check_item(item, 5, "TRS")
end
function ItemLogic.is_unique_chest(item)
   return safe_check_item(item, 6, "TRS")
end
function ItemLogic.is_legendary_gloves(item)
   return safe_check_item(item, 5, "GLV")
end
function ItemLogic.is_unique_gloves(item)
   if not item then return false end
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return false end
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity or item_rarity ~= 6 then return false end
   local ok_name, skin_name = pcall(function() return item_info:get_skin_name() end)
   if not ok_name or not skin_name then return false end
   return skin_name:find("GLV") or skin_name:find("Gloves")
end
function ItemLogic.is_legendary_pants(item)
   return safe_check_item(item, 5, "LEG")
end
function ItemLogic.is_unique_pants(item)
   if not item then return false end
   local ok_info, item_info = pcall(function() return item:get_item_info() end)
   if not ok_info or not item_info then return false end
   local ok_rarity, item_rarity = pcall(function() return item_info:get_rarity() end)
   if not ok_rarity or item_rarity ~= 6 then return false end
   local ok_name, skin_name = pcall(function() return item_info:get_skin_name() end)
   if not ok_name or not skin_name then return false end
   return skin_name:find("LEG") or skin_name:find("Pants")
end
function ItemLogic.is_legendary_boots(item)
   return safe_check_item(item, 5, "BTS")
end
function ItemLogic.is_unique_boots(item)
   return safe_check_item(item, 6, "BTS")
end

--offhand
function ItemLogic.is_legendary_focus(item)
   return safe_check_item(item, 5, "offHandsSorc")
end
function ItemLogic.is_legendary_totem(item)
   return safe_check_item(item, 5, "offHandsDruid")
end

--1Handed Weapons
function ItemLogic.is_legendary_1h_mace(item)
   return safe_check_item(item, 5, "mace")
end
function ItemLogic.is_legendary_1h_axe(item)
   return safe_check_item(item, 5, "axe")
end
function ItemLogic.is_legendary_1h_sword(item)
   return safe_check_item(item, 5, "sword")
end
function ItemLogic.is_legendary_dagger(item)
   return safe_check_item(item, 5, "dagger")
end
function ItemLogic.is_legendary_wand(item)
   return safe_check_item(item, 5, "wand")
end
function ItemLogic.is_unique_1h_mace(item)
   return safe_check_item(item, 6, "mace")
end
function ItemLogic.is_unique_1h_axe(item)
   return safe_check_item(item, 6, "axe")
end
function ItemLogic.is_unique_1h_sword(item)
   return safe_check_item(item, 6, "sword")
end
function ItemLogic.is_unique_dagger(item)
   return safe_check_item(item, 6, "dagger")
end
function ItemLogic.is_unique_wand(item)
   return safe_check_item(item, 6, "wand")
end

--2H Weapons
function ItemLogic.is_legendary_2h_mace(item)
   return safe_check_item(item, 5, "Mace")
end
function ItemLogic.is_legendary_2h_axe(item)
   return safe_check_item(item, 5, "Axe")
end
function ItemLogic.is_legendary_2h_sword(item)
   return safe_check_item(item, 5, "Sword")
end
function ItemLogic.is_legendary_2h_polearm(item)
   return safe_check_item(item, 5, "Polearm")
end
function ItemLogic.is_legendary_staff(item)
   return safe_check_item(item, 5, "Staff")
end
function ItemLogic.is_legendary_bow(item)
   return safe_check_item(item, 5, "Bow")
end
function ItemLogic.is_legendary_crossbow(item)
   return safe_check_item(item, 5, "Crossbow")
end
function ItemLogic.is_legendary_glaive(item)
   return safe_check_item(item, 5, "Glaive")
end
function ItemLogic.is_legendary_quarterstaff(item)
   return safe_check_item(item, 5, "Quarterstaff")
end
function ItemLogic.is_unique_2h_mace(item)
   return safe_check_item(item, 6, "Mace")
end
function ItemLogic.is_unique_2h_axe(item)
   return safe_check_item(item, 6, "Axe")
end
function ItemLogic.is_unique_2h_sword(item)
   return safe_check_item(item, 6, "Sword")
end
function ItemLogic.is_unique_2h_polearm(item)
   return safe_check_item(item, 6, "Polearm")
end
function ItemLogic.is_unique_staff(item)
   return safe_check_item(item, 6, "Staff")
end
function ItemLogic.is_unique_bow(item)
   return safe_check_item(item, 6, "Bow")
end
function ItemLogic.is_unique_crossbow(item)
   return safe_check_item(item, 6, "Crossbow")
end
function ItemLogic.is_unique_glaive(item)
   return safe_check_item(item, 6, "Glaive")
end
function ItemLogic.is_unique_quarterstaff(item)
   return safe_check_item(item, 6, "Quarterstaff")
end


 return ItemLogic