LinkLuaModifier("modifier_krigler_effects", "heroes/new_hero/modifier_krigler_effects.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_tamer", "heroes/soul_tamer/modifier_soul_tamer.lua", LUA_MODIFIER_MOTION_NONE)
function CheckForInnates(spawnedUnit)
  if(spawnedUnit:GetName() == "npc_dota_hero_legion_commander") then
    local innate = spawnedUnit:FindAbilityByName("legion_demon_form")
    if innate then innate:SetLevel(1) end
  elseif(spawnedUnit:GetName() == "npc_dota_hero_dragon_knight") then
    local innate = spawnedUnit:FindAbilityByName("dk_dragon_form")
    if innate then innate:SetLevel(1) end
  elseif(spawnedUnit:GetName() == "npc_dota_hero_monkey_king") then
    local innate = spawnedUnit:FindAbilityByName("mk_sage_form")
    if innate then innate:SetLevel(1) end
  end
end

function CheckForIllusionsInnate(spawnedUnit) --Check the spawned custom hero and their illusions for visual effects
  if(spawnedUnit:GetUnitName() == "npc_dota_hero_krigler") and spawnedUnit.innateIluFlag == nil then
      AddAnimationTranslate(spawnedUnit, "walk")
      AddAnimationTranslate(spawnedUnit, "arcana")
      spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/krigler/jugg_sword.vmdl"})
      spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
      spawnedUnit.weapon:SetRenderColor(200, 200, 200)
      spawnedUnit.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/krigler/jugg_mask.vmdl"})
      spawnedUnit.head:FollowEntity(spawnedUnit, true)
      spawnedUnit.head:SetRenderColor(200, 200, 200)
      spawnedUnit.pants = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"})
      spawnedUnit.pants:FollowEntity(spawnedUnit, true)
      spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_krigler_effects", {})
      spawnedUnit.innateIluFlag = true
  elseif(spawnedUnit:GetUnitName() == "npc_dota_hero_andrax") then
      spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_weapon.vmdl"})
      spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
      spawnedUnit.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_head.vmdl"})
      spawnedUnit.head:FollowEntity(spawnedUnit, true)
      spawnedUnit.armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_armor.vmdl"})
      spawnedUnit.armor:FollowEntity(spawnedUnit, true)
      AddAnimationTranslate(spawnedUnit, "walk")
  elseif(spawnedUnit:GetUnitName() == "npc_dota_hero_soul_tamer") then
      AddAnimationTranslate(spawnedUnit, "walk")
      spawnedUnit.body = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/dragon_knight/dragon_knight.vmdl"})
      spawnedUnit.body:FollowEntity(spawnedUnit, true)
      spawnedUnit.arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/the_havoc_of_dragon_palacesix_ear_armor/the_havoc_of_dragon_palacesix_ear_shoulders.vmdl"})
      spawnedUnit.arms:FollowEntity(spawnedUnit, true)
      spawnedUnit.arms2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/arc_warden/arc_warden_bracers.vmdl"})
      spawnedUnit.arms2:FollowEntity(spawnedUnit, true)
      spawnedUnit.legs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"})
      spawnedUnit.legs:FollowEntity(spawnedUnit, true)
      spawnedUnit.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/ti8_dk_third_awakening_head/ti8_dk_third_awakening_head.vmdl"})
      spawnedUnit.head:FollowEntity(spawnedUnit, true)
  end
end