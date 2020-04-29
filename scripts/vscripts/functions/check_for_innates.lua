LinkLuaModifier("modifier_krigler_effects", "heroes/new_hero/modifier_krigler_effects.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sage_ronin_translate_attack", "heroes/sage_ronin/modifier_sage_ronin_translate_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sage_ronin_responses", "heroes/sage_ronin/modifier_sage_ronin_responses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_tamer", "heroes/soul_tamer/modifier_soul_tamer.lua", LUA_MODIFIER_MOTION_NONE)
function CheckForInnates(spawnedUnit)
    if(spawnedUnit:GetUnitName() == "npc_dota_hero_sage_ronin") then
      spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_sage_ronin_translate_attack", {})
      spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_sage_ronin_responses", {})
      spawnedUnit:FindAbilityByName("ronin_precaches"):SetLevel(1) 
      if not spawnedUnit.alreadySpawned then
  	    AddAnimationTranslate(spawnedUnit, "walk")
  	    AddAnimationTranslate(spawnedUnit, "odachi")
  	    spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/fire_of_the_exiled_ronin/fire_of_the_exiled_ronin.vmdl"})
        spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
        spawnedUnit.weapon:SetRenderColor(200, 200, 200)
        spawnedUnit.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/oblivion_blazer_head/oblivion_blazer_head.vmdl"})
        spawnedUnit.head:FollowEntity(spawnedUnit, true)
        spawnedUnit.head:SetRenderColor(100, 100, 100)
        spawnedUnit.pants = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/dc_legsupdate5/dc_legsupdate5.vmdl"})
        spawnedUnit.pants:FollowEntity(spawnedUnit, true)
        spawnedUnit.pants:SetRenderColor(100, 100, 100)
        spawnedUnit.shoulders = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/thousand_faces_vest/thousand_faces_vest.vmdl"})
        spawnedUnit.shoulders:FollowEntity(spawnedUnit, true)
        spawnedUnit.shoulders:SetRenderColor(100, 100, 100)
  	    spawnedUnit:SetRenderColor(50, 50, 50)
  	    spawnedUnit.alreadySpawned = true
        if not spawnedUnit:IsIllusion() then
    	    Timers:CreateTimer(6, function ()  
    	      SageRoninResponses:Start(spawnedUnit)
    	      SageRoninResponses:RegisterUnit(spawnedUnit:GetUnitName(), "scripts/responses/"..spawnedUnit:GetUnitName().."_responses.txt")
    	    end)
        end
      end

    elseif(spawnedUnit:GetUnitName() == "npc_dota_hero_gravitum") then
      if not spawnedUnit.alreadySpawned then
        spawnedUnit.attraction_stacks = 0
        AddAnimationTranslate(spawnedUnit, "jog")

        --spawnedUnit:SetRenderColor(100, 0, 220)
        spawnedUnit.alreadySpawned = true
        spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/mars/mars_spear.vmdl"})
        spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
        spawnedUnit.weapon:SetRenderColor(100, 0, 220)
        spawnedUnit.armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/void_spirit/void_spirit_armor.vmdl"})
        spawnedUnit.armor:FollowEntity(spawnedUnit, true)
        --spawnedUnit.armor:SetRenderColor(100, 0, 220)
      end
    elseif spawnedUnit:GetUnitName() == "npc_dota_hero_krigler" and not spawnedUnit.alreadySpawned then
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
  	    spawnedUnit.alreadySpawned = true
        if not spawnedUnit:IsIllusion() then
    	    Timers:CreateTimer(0.8, function () 
    	      EmitAnnouncerSoundForPlayer("krigler_first_spawn", spawnedUnit:GetPlayerOwnerID())
    	    end)
    	    Timers:CreateTimer(6, function ()  
    	      KriglerResponses:Start(spawnedUnit)
    	      KriglerResponses:RegisterUnit(spawnedUnit:GetUnitName(), "scripts/responses/"..spawnedUnit:GetUnitName().."_responses.txt")
    	    end)
        end
  	elseif spawnedUnit:GetUnitName() == "npc_dota_hero_andrax" and not spawnedUnit.alreadySpawned then
	    spawnedUnit.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_weapon.vmdl"})
	    spawnedUnit.weapon:FollowEntity(spawnedUnit, true)
	    spawnedUnit.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_head.vmdl"})
	    spawnedUnit.head:FollowEntity(spawnedUnit, true)
	    spawnedUnit.armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_armor.vmdl"})
	    spawnedUnit.armor:FollowEntity(spawnedUnit, true)
	    AddAnimationTranslate(spawnedUnit, "walk")
	    spawnedUnit.alreadySpawned = true
      if not spawnedUnit:IsIllusion() then
  	    Timers:CreateTimer(0.8, function () 
  	      EmitAnnouncerSoundForPlayer("andrax_spawn", spawnedUnit:GetPlayerOwnerID())
  	    end)
  	    Timers:CreateTimer(6, function ()  
  	      AndraxResponses:Start(spawnedUnit)
  	      AndraxResponses:RegisterUnit(spawnedUnit:GetUnitName(), "scripts/responses/"..spawnedUnit:GetUnitName().."_responses.txt")
  	    end)
      end
  	elseif spawnedUnit:GetUnitName() == "npc_dota_hero_casalmar" and not spawnedUnit.alreadySpawned then
      spawnedUnit:SetRenderColor(155, 146, 80)
      if not spawnedUnit:IsIllusion() then
  	    Timers:CreateTimer(0.8, function ()
  	      EmitAnnouncerSoundForPlayer("undying_undying_big_spawn_02", spawnedUnit:GetPlayerOwnerID())
  	    end)
  	    Timers:CreateTimer(6, function ()  
  	      CasalmarResponses:Start(spawnedUnit)
  	      CasalmarResponses:RegisterUnit(spawnedUnit:GetUnitName(), "scripts/responses/"..spawnedUnit:GetUnitName().."_responses.txt")
  	    end)
      end
  	end
end
