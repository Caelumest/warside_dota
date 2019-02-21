function MoveSoul(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    if caster.soul.particle_soul == nil then
        caster.soul.hasParticle = true
    end
    ability.point = Vector(ability:GetCursorPosition().x, ability:GetCursorPosition().y, caster.soul:GetAbsOrigin().z)
    if ab_target_soul and ab_target_soul.target then
        ab_target_soul.target:RemoveModifierByName("modifier_soul_current_target")
    end
    ab_target_soul.target = nil
    caster:RemoveModifierByName("modifier_soul_moving_to_target")
    caster.soul:SetForwardVector((Vector(ability.point.x, ability.point.y, caster.soul:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
    caster.soul:MoveToPosition(ability.point)
end

function MoveToTarget(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_soul_moving_to_target", {})
    caster:RemoveModifierByName("modifier_soul_moving")
    caster:RemoveModifierByName("modifier_soul_follow_caster")
    ab_move_soul.isMoving = nil
    if ability.target and ability.target == keys.target then
        return nil
    end
    if ability.target then
        ability.target:RemoveModifierByName("modifier_soul_current_target")
    end
    ability.target = keys.target
    print("CASTERTARGET", caster.soul.particle_soul)
    if caster.soul.particle_soul == nil then
        caster.soul.hasParticle = true
    end
    local target_loc = ability.target:GetOrigin()
    caster.soul:SetForwardVector((Vector(target_loc.x, target_loc.y, caster.soul:GetAbsOrigin().z) - caster.soul:GetAbsOrigin()):Normalized())
    caster.soul:Stop()
    caster.soul:MoveToPosition(ability.target:GetOrigin())
end

function PrePull(keys)
    local caster = keys.caster
    local ability = keys.ability
    local casterpos = caster:GetAbsOrigin()
    ability.startParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul)
    ParticleManager:SetParticleControlEnt(ability.startParticle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "world_origin", casterpos, true)
    ParticleManager:SetParticleControlEnt(ability.startParticle, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "world_origin", casterpos, true)
    ParticleManager:SetParticleControlEnt(ability.startParticle, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "world_origin", casterpos, true)
    ParticleManager:SetParticleControl(ability.startParticle, 60, Vector(30, 120, 255))
    ParticleManager:SetParticleControl(ability.startParticle, 61, Vector(500, 500, 500))
    ability.startParticle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul)
    ParticleManager:SetParticleControlEnt(ability.startParticle2, 0, caster, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", casterpos, true)
    ParticleManager:SetParticleControlEnt(ability.startParticle2, 1, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster.soul:GetAbsOrigin(), true)
end

function CastPull(keys)
    local caster = keys.caster
    local ability = keys.ability
    local area = ability:GetCastRange()
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    if caster:HasScepter() then
        ability.duration = ability:GetLevelSpecialValueFor("duration_scepter", (ability:GetLevel() - 1))
    else
        ability.duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    end
    if ability.particle then 
        ParticleManager:DestroyParticle(ability.particle, false)
        ParticleManager:DestroyParticle(ability.particle2, false)
        ParticleManager:DestroyParticle(ability.particleArea, false)
        ParticleManager:DestroyParticle(ability.particleArea2, false)
        ParticleManager:DestroyParticle(ability.particleArea3, false)
    end
    caster:RemoveNoDraw()
    caster:Stop()
    ability.ticks = 0
    caster:AddNewModifier(caster, nil, "modifier_soul_tamer", {})
    caster:SetAbsOrigin(caster.soul:GetAbsOrigin())
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_pull_chase_soul", {Duration = ability.duration})
    PlayerResource:SetCameraTarget(caster:GetPlayerID(), caster.soul)
    Timers:CreateTimer(0.1, function () PlayerResource:SetCameraTarget(caster:GetPlayerID(), nil) end)
    --PlayerResource:SetCameraTarget(caster:GetPlayerID(), nil)
    if caster.soul.particle_soul == nil then
        if caster:HasModifier("modifier_soul_follow_caster") then
            caster.soul.hasParticle = true
        elseif ab_target_soul.target:HasModifier("modifier_soul_current_target") then
            caster.soul.hasParticle = false
        end
    end
    if ability.particle then
        ParticleManager:DestroyParticle(ability.particle, false)
        ParticleManager:DestroyParticle(ability.particle2, false)
    end
    ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_age_aoe_soft.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul)
    ParticleManager:SetParticleControlEnt(ability.particle, 0, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particle, 1, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(ability.particle, 2, Vector(area, 0, 0))

    ability.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_age_aoe_soft.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul)
    ParticleManager:SetParticleControlEnt(ability.particle2, 0, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particle2, 1, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(ability.particle2, 2, Vector(area, 0, 0))

    ability.particleArea = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_age_aoe_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul)
    ParticleManager:SetParticleControlEnt(ability.particleArea, 0, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particleArea, 1, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(ability.particleArea, 2, Vector(area, 0, 0))

    ability.particleArea2 = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_tag_team_base_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul)
    ParticleManager:SetParticleControlEnt(ability.particleArea2, 0, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(ability.particleArea2, 1, Vector(area-100, 0, 0))

    ability.particleArea3 = ParticleManager:CreateParticleForTeam("particles/ui_mouseactions/range_finder_tower_aoe_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul, caster:GetTeam())
    ParticleManager:SetParticleControlEnt(ability.particleArea3, 0, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particleArea3, 2, caster.soul, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(ability.particleArea3, 3, Vector(area, 0, 0))
    ParticleManager:SetParticleControl(ability.particleArea3, 4, Vector(100, 100, 100))

    ability:ApplyDataDrivenModifier(caster, caster.soul, "modifier_soul_casting_pull", {Duration = ability.duration})
    caster:AddNoDraw()
    if caster.head then
        caster.head:Destroy()
        caster.body:Destroy()
        caster.arms:Destroy()
        caster.arms2:Destroy()
        caster.legs:Destroy()
    end
end

function RemovePull(keys)
    local ability = keys.ability
    local caster = keys.caster
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    if ab_target_soul.target then
        ab_target_soul.target:RemoveModifierByName("modifier_soul_current_target")
    end
    if caster:HasModifier("modifier_soul_moving_to_target") then
        caster:RemoveModifierByName("modifier_soul_moving_to_target")
        caster.soul:Stop()
    end
    ab_target_soul.target = nil
    ab_move_soul:SetActivated(true)
    caster:RemoveModifierByName("modifier_soul_tamer")
    caster:RemoveNoDraw()
    caster.body = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/dragon_knight/dragon_knight.vmdl"})
    caster.arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/the_havoc_of_dragon_palacesix_ear_armor/the_havoc_of_dragon_palacesix_ear_shoulders.vmdl"})
    caster.arms2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/arc_warden/arc_warden_bracers.vmdl"})
    caster.legs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"})
    caster.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/ti8_dk_third_awakening_head/ti8_dk_third_awakening_head.vmdl"})
    caster.head:FollowEntity(caster, true)
    caster.body:FollowEntity(caster, true)
    caster.arms:FollowEntity(caster, true)
    caster.arms2:FollowEntity(caster, true)
    caster.legs:FollowEntity(caster, true)
    caster.soul.hasParticle = false
    ab_move_soul:ApplyDataDrivenModifier(caster, caster, "modifier_soul_follow_caster", {})
end

function AddPullEffects(keys)
    local ability = keys.ability
    local caster = keys.caster
    local enemy = keys.target
    enemy.tamer_pull_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_POINT, enemy)
    ParticleManager:SetParticleControlEnt(enemy.tamer_pull_particle, 0, caster.soul, PATTACH_POINT_FOLLOW, "attach_hitloc", caster.soul:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(enemy.tamer_pull_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
    -- body
end

function RemovePullEffects(keys)
    local ability = keys.ability
    local caster = keys.caster
    local unit = keys.target
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    if unit then
        unit:StopSound("Hero_Slark.Pounce.Leash")
    end
    if unit.tamer_pull_particle then
        ParticleManager:DestroyParticle(unit.tamer_pull_particle, false)
        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), false)
    end
    if not caster.soul:HasModifier("modifier_soul_casting_pull") then 
        ParticleManager:DestroyParticle(ability.particle, false)
        ParticleManager:DestroyParticle(ability.particle2, false)
        ParticleManager:DestroyParticle(ability.particleArea, false)
        ParticleManager:DestroyParticle(ability.particleArea2, false)
        ParticleManager:DestroyParticle(ability.particleArea3, false)
    end
    --local units = FindUnitsInRadius( caster:GetTeam(), caster.soul:GetOrigin(), nil, 10000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
    --for _,enemy in pairs( units ) do
      --  if enemy.tamer_pull_particle then
            --ParticleManager:DestroyParticle(enemy.tamer_pull_particle, false)
        --end
    --end
end

function ShieldTarget(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    local talent = caster:FindAbilityByName("special_bonus_unique_tamer_2")
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    if ability.target then
        ability.target:RemoveModifierByName("modifier_tamer_shield_life")
        ability.target:RemoveModifierByName("modifier_tamer_shield_bonus")
        print('entrou gostoso')
    end
    if caster:HasModifier("modifier_soul_follow_caster") then
        ability.target = caster
    else
        ability.target = ab_target_soul.target
    end
    ability.target:RemoveModifierByName("modifier_tamer_shield_life")
    ability.target:RemoveModifierByName("modifier_tamer_shield_bonus")
    if ability.particle then
        ParticleManager:DestroyParticle(ability.particle, false)
        ParticleManager:DestroyParticle(ability.particle2, false)
    end
    EmitSoundOn("Hero_TemplarAssassin.Refraction", ability.target)

    ability.particleStart = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_start_sphere", PATTACH_ABSORIGIN, ability.target)
    ParticleManager:SetParticleControl(ability.particleStart, 1, ability.target:GetAbsOrigin())

    ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_sphere_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, ability.target)
    ParticleManager:SetParticleControlEnt(ability.particle, 1, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)


    ability.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_sphere_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, ability.target)
    ParticleManager:SetParticleControlEnt(ability.particle2, 1, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)

    ability.total_damage = 0
    ability.shield = ability:GetSpecialValueFor("shield_life") + talent:GetSpecialValueFor("value")

    ability:ApplyDataDrivenModifier(caster, ability.target, "modifier_tamer_shield_life", {Duration = (duration )})
    ability:ApplyDataDrivenModifier(caster, ability.target, "modifier_tamer_shield_bonus", {Duration = (duration)})
    ability.target:SetModifierStackCount("modifier_tamer_shield_life", ability, ability.shield)
    ability.target:CalculateStatBonus()
end

function GatherDamage(keys)
    local caster = keys.caster
    local ability = keys.ability
    local dmg = keys.damage
    local attacker = keys.attacker
    EmitSoundOn("Hero_TemplarAssassin.Refraction.Absorb", ability.target)
    ability.particleHit = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, ability.target)
    ParticleManager:SetParticleControlEnt(ability.particleHit, 0, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particleHit, 1, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particleHit, 2, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particleHit, 3, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)
    local stackcount = ability.target:GetModifierStackCount("modifier_tamer_shield_life", caster)
    ability.total_damage = ability.total_damage + dmg
    local intdmg = math.floor(dmg)
    local floatvalue = dmg - intdmg
    print("FLOAT", floatvalue)
    print('dmg', dmg)
    print("SHIELD", ability.shield)
    print("total damage",ability.total_damage)
    if ability.shield > ability.total_damage then
        local current_health = ability.target:GetHealth() + dmg
        if ability.target:GetHealth() < dmg then
            ability.target:SetHealth(ability.targethp)
            ability.target:Heal(floatvalue, caster)
        else
            ability.target:SetHealth(current_health)
            ability.target:Heal(floatvalue, caster)
        end
    else
        local current_health = ability.target:GetHealth() + stackcount
        print(ability.target:GetHealth(),"+", stackcount, "=", current_health)
        print("IF", ability.targethp + stackcount, "<", dmg)
        if (ability.targethp + stackcount) < dmg then
            ability.target:Kill(nil, attacker)
        else
            ability.target:SetHealth(current_health)
            ability.target:Heal(floatvalue, caster)
        end
    end
    ability.target:SetModifierStackCount("modifier_tamer_shield_life", ability, ability.shield - ability.total_damage)
    
    if ability.target:GetModifierStackCount("modifier_tamer_shield_life", caster) < 1 then
        ability.target:RemoveModifierByName("modifier_tamer_shield_bonus")
        ability.target:RemoveModifierByName("modifier_tamer_shield_life")
        ParticleManager:DestroyParticle(ability.particle, false)
        ParticleManager:DestroyParticle(ability.particle2, false)
        ability.particleEnd = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, ability.target)
        ParticleManager:SetParticleControlEnt(ability.particleEnd, 1, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)
        ability.total_damage = 0
    end

end

function BreakShield(keys)
    local caster = keys.caster
    local ability = keys.ability
    ParticleManager:DestroyParticle(ability.particle, false)
    ParticleManager:DestroyParticle(ability.particle2, false)
    ability.particleEnd = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, ability.target)
    ParticleManager:SetParticleControlEnt(ability.particleEnd, 1, ability.target, PATTACH_POINT_FOLLOW, "attach_origin", ability.target:GetAbsOrigin(), true)
    ability.target:RemoveModifierByName("modifier_tamer_shield_bonus")
    ability.target:RemoveModifierByName("modifier_tamer_shield_life")
end