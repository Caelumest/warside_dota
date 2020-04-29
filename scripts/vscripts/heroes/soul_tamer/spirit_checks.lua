function CheckDistance(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_stun_soul = caster:FindAbilityByName("tamer_soul_stun")
    local ab_push_soul = caster:FindAbilityByName("tamer_push_area")
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    local ab_shield = caster:FindAbilityByName("tamer_shield_target")
    ability.distance = 1100
    if caster:HasModifier("modifier_item_aether_lens") then
        ability.distance = 1350
    end

    if not ability.helperParticle and not caster:HasModifier("modifier_soul_follow_caster") and caster:IsAlive() then
        ability.helperParticle = ParticleManager:CreateParticleForTeam("particles/ui_mouseactions/range_finder_tower_aoe_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeam())
        ParticleManager:SetParticleControlEnt(ability.helperParticle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(ability.helperParticle, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(ability.helperParticle, 3, Vector(ability.distance, 0, 0))
        ParticleManager:SetParticleControl(ability.helperParticle, 4, Vector(150, 150, 220))
    elseif caster:HasModifier("modifier_soul_follow_caster") or not caster:IsAlive() then
        if ability.helperParticle then
            ParticleManager:DestroyParticle(ability.helperParticle, true)
        end
        ability.helperParticle = nil
    end

    if caster.soul.hasParticle == false then
        if caster.soul.particle_soul then
            ParticleManager:DestroyParticle(caster.soul.particle_soul, false)
        end
        caster.soul.hasParticle = nil
        caster.soul.particle_soul = nil
    elseif caster.soul.hasParticle == true then
        caster.soul.particle_soul = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.soul)
        ParticleManager:SetParticleControlEnt(caster.soul.particle_soul, 0, caster.soul, PATTACH_POINT_FOLLOW, "attach_hitloc", caster.soul:GetAbsOrigin(), true)
        caster.soul.hasParticle = nil
    end
    if caster:GetRangeToUnit(caster.soul) > ability.distance and not ab_stun_soul.stunInQueue and not ab_push_soul.pushInQueue then
        local casterpos = caster:GetAbsOrigin()
        caster.soul:Stop()
        caster.soul:SetAbsOrigin(casterpos)
        caster:RemoveModifierByName("modifier_soul_moving")
        caster.soul.hasParticle = false
        if ab_target_soul and ab_target_soul.target then
            caster:RemoveModifierByName("modifier_soul_moving_to_target")
            ab_target_soul.target:RemoveModifierByName("modifier_soul_current_target")
            ab_target_soul.target = nil
        end
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_soul_follow_caster", {})
        --caster.soul:MoveToPosition(caster:GetAbsOrigin())
    end
end

function CheckIfMoving(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability.isMoving = true
    if (Vector(ability.point.x, ability.point.y, caster.soul:GetAbsOrigin().z) - Vector(caster.soul:GetAbsOrigin().x, caster.soul:GetAbsOrigin().y, caster.soul:GetAbsOrigin().z)):Length2D() < 3 then
        caster:RemoveModifierByName("modifier_soul_moving")
        ability.isMoving = nil
    end
end

function PullArea(keys)
    local caster = keys.caster
    local ability = keys.ability
    local talent = caster:FindAbilityByName("special_bonus_unique_tamer_3")
    local damage = (ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1)) + talent:GetSpecialValueFor("value")) /2
    local modifier = caster.soul:FindModifierByName("modifier_soul_casting_pull")
    local area = ability:GetCastRange()
    if caster:HasScepter() then
        ability.dmgType = DAMAGE_TYPE_PURE
    else
        ability.dmgType = DAMAGE_TYPE_MAGICAL
    end
    ability.ticks = ability.ticks + 1
    local pull_speed = ability:GetLevelSpecialValueFor("pull_speed", (ability:GetLevel() - 1)) / 100
    local units = FindUnitsInRadius( caster:GetTeam(), caster.soul:GetOrigin(), nil, area + 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    for _,enemy in pairs( units ) do
        if caster.soul:GetRangeToUnit(enemy) <= area and enemy:IsAlive() then
            if not enemy:HasModifier("modifier_tamer_pull_effects") then
                local duration = modifier:GetRemainingTime()
                EmitSoundOn("Hero_Slark.Pounce.Leash", enemy)
                ability:ApplyDataDrivenModifier(caster, enemy, "modifier_tamer_pull_effects", {Duration = duration})
            end
            if ability.ticks == 50 then
                ApplyDamage({victim = enemy, attacker = caster, damage = (damage + (caster.soul:GetRangeToUnit(enemy)*damage/area)), damage_type = ability.dmgType})
            end
            local unit_location = enemy:GetAbsOrigin()
            local vector_distance = caster.soul:GetAbsOrigin() - unit_location
            local distance = (vector_distance):Length2D()
            local direction = (vector_distance):Normalized()
            local speed = caster.soul:GetRangeToUnit(enemy)
            if distance >= 50 and not enemy:HasModifier("modifier_soul_root") and not enemy:HasModifier("modifier_rod_of_atos_debuff") then
                enemy:SetAbsOrigin(unit_location + direction * (pull_speed + (speed / area)))
            end
        else
            enemy:RemoveModifierByName("modifier_tamer_pull_effects")
        end
    end
    if ability.ticks == 50 then
        ability.ticks = 0
    end
end

function DeathRemove(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier_name = keys.modifier
    local target = keys.unit
    if target.tamer_pull_particle then
        ParticleManager:DestroyParticle(target.tamer_pull_particle, false)
        target:RemoveModifierByName("modifier_tamer_pull_effects")
    end
end

function SoulFollow(keys)
    local caster = keys.caster
    local ability = keys.ability
    local casterpos = caster:GetAbsOrigin()
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    if caster:HasModifier("modifier_pull_chase_soul") and ab_move_soul.isMoving or caster:HasModifier("modifier_soul_moving_to_target") then
        caster:SetAbsOrigin(caster.soul:GetAbsOrigin())
    else
        caster.soul:SetAbsOrigin(casterpos)
    end
    if caster:HasModifier("modifier_pull_chase_soul") then
        ab_move_soul:SetActivated(false)
    else
        ab_move_soul:SetActivated(true)
    end
end

function StopSoul(keys)
    local caster = keys.caster
    local ability = keys.ability
    local casterpos = caster.soul:GetAbsOrigin()
    local order = keys.order_type
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    if caster.soul then
        local position = caster:GetForwardVector()
        caster.soul:SetForwardVector(position)
    end
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    if ab_target_soul and ab_target_soul.target and ab_target_soul.target:HasModifier("modifier_soul_current_target") then
        ab_target_soul.target:RemoveModifierByName("modifier_soul_current_target")
        caster.soul.hasParticle = true
        ab_target_soul.target = nil
    end
    if not caster:HasModifier("modifier_soul_follow_caster") then
        ab_move_soul:ApplyDataDrivenModifier(caster, caster, "modifier_soul_follow_caster", {})
    end
    if ab_move_soul and ab_move_soul.isMoving or caster:HasModifier("modifier_soul_moving_to_target") then
        ab_move_soul.isMoving = nil
        caster.soul:Stop()
        if caster:HasModifier("modifier_soul_moving_to_target") then
            caster:RemoveModifierByName("modifier_soul_moving_to_target")
        end
    end
end

function RemoveFromTarget(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    ab_target_soul.target = nil
    caster.soul.hasParticle = true
end

function MoveToTargetThinker(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    if caster.soul:GetRangeToUnit(ability.target) > 50 and not ability.target:HasModifier("modifier_soul_current_target") and ability.target:IsAlive() then
        --caster.soul:Stop()
        print("think2")
        caster.soul:MoveToPosition(ability.target:GetOrigin())
    elseif ability.target == caster then
        ab_move_soul:ApplyDataDrivenModifier(caster, caster, "modifier_soul_follow_caster", {})
        caster.soul.hasParticle = false
        caster:RemoveModifierByName("modifier_soul_moving_to_target")
    elseif not ability.target:IsAlive() then
        caster:RemoveModifierByName("modifier_soul_moving_to_target")
        ability.target = nil
        caster.soul:Stop()
        ab_move_soul.isMoving = nil
    else
        ability:ApplyDataDrivenModifier(caster, ability.target, "modifier_soul_current_target", {})
        caster.soul.hasParticle = false
        caster:RemoveModifierByName("modifier_soul_moving_to_target")
    end
end

function StickToTargetThinker(keys)
    local caster = keys.caster
    local ability = keys.ability
    caster.soul:Stop()
    if ability.target then
        caster.soul:SetOrigin(ability.target:GetOrigin())
    end
    if caster:HasModifier("modifier_pull_chase_soul") then
        caster:SetOrigin(caster.soul:GetOrigin())
    end
end

function CheckTarget(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    if (ab_target_soul.target and ab_target_soul.target:HasModifier("modifier_soul_current_target")) or caster:HasModifier("modifier_soul_follow_caster") then
        ability:SetActivated(true)
        if caster:HasModifier("modifier_soul_follow_caster") then
            ability.targethelper = caster
        else
            ability.targethelper = ab_target_soul.target
        end
        ability.targethp = ability.targethelper:GetHealth()
    else
        ability:SetActivated(false)
    end
end

function SoulStun(caster, ability)
    local dmg = ability:GetAbilityDamage()
    local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
    local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() - 1))
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    local talent = caster:FindAbilityByName("special_bonus_unique_tamer_4")
    local units = FindUnitsInRadius( caster:GetTeam(), caster.soul:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
    EmitSoundOnLocationWithCaster(caster.soul:GetAbsOrigin(), "Hero_EarthSpirit.BoulderSmash.Target", caster)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_CUSTOMORIGIN, caster.soul)
    ParticleManager:SetParticleControl(particle, 0, caster.soul:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
    for _,enemy in pairs( units ) do
        ApplyDamage({victim = enemy, attacker = caster, damage = dmg, damage_type = ability:GetAbilityDamageType()})
        if talent:GetLevel() > 0 then
            enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = talent:GetSpecialValueFor("value")})
        end
        ability:ApplyDataDrivenModifier(caster, enemy, "modifier_soul_slow", {duration = duration + talent:GetSpecialValueFor("value")})
    end
end

function CheckIfMoved(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability.stunInQueue = true
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    print("point", ab_move_soul.point)
    if caster:HasModifier("modifier_pull_chase_soul") then
        caster:RemoveModifierByName("modifier_tamer_stun_limit")
        ability.stunInQueue = nil
        SoulStun(caster, ability)
        ability:StartCooldown(ability.cooldown)
        ability.cooldown = nil
        ability:SetActivated(true)
    end
    if not ab_move_soul.isMoving and not caster:HasModifier("modifier_soul_moving_to_target") and not caster:HasModifier("modifier_pull_chase_soul") then
        caster:RemoveModifierByName("modifier_tamer_stun_limit")
        ability.stunInQueue = nil
        SoulStun(caster, ability)
        ability:StartCooldown(ability.cooldown)
        ability.cooldown = nil
        ability:SetActivated(true)
    end
end

function CheckDeath(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    local ab_target_soul = caster:FindAbilityByName("tamer_target_soul")
    local ab_stun_soul = caster:FindAbilityByName("tamer_soul_stun")
    local ab_push_soul = caster:FindAbilityByName("tamer_push_area")
    if ab_target_soul.target then
        ab_target_soul.target:RemoveModifierByName("modifier_soul_current_target")
        ab_target_soul.target = nil
    end
    ab_move_soul.isMoving = nil
    ab_stun_soul:SetActivated(true)
    ab_push_soul:SetActivated(true)
    caster.soul.hasParticle = false
    caster:RemoveModifierByName("modifier_soul_follow_caster")
    --caster.soul:Kill(caster.soul, caster.soul)
end

function CheckRespawn(keys)
    local caster = keys.caster
    local ability = keys.ability
    caster.soul:Kill(caster.soul, caster.soul)
    caster.soul = CreateUnitByName("npc_dota_creature_spirit_vessel", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
    caster.soul:AddNewModifier(caster, nil, "modifier_soul_tamer", {})
    caster.soul:SetAbsOrigin(Vector(0,0,0)) --Just to trigger the follow caster modifier
end

function CastPush(caster, ability)
    local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
    local distance = ability:GetLevelSpecialValueFor("distance", (ability:GetLevel() - 1))
    local talent = caster:FindAbilityByName("special_bonus_unique_tamer_1")
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1)) + talent:GetSpecialValueFor("value")
    local knockduration = ability:GetLevelSpecialValueFor("knockduration", (ability:GetLevel() - 1))
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_death.vpcf", PATTACH_CUSTOMORIGIN, caster.soul)
    ParticleManager:SetParticleControl(particle, 0, Vector(caster.soul:GetAbsOrigin().x, caster.soul:GetAbsOrigin().y, caster.soul:GetAbsOrigin().z + 100))
    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_death.vpcf", PATTACH_CUSTOMORIGIN, caster.soul)
    ParticleManager:SetParticleControl(particle2, 0, Vector(caster.soul:GetAbsOrigin().x, caster.soul:GetAbsOrigin().y, caster.soul:GetAbsOrigin().z + 100))
    EmitSoundOnLocationWithCaster(caster.soul:GetAbsOrigin(), "Hero_Abaddon.AphoticShield.Destroy", caster)
    local units = FindUnitsInRadius( caster:GetTeam(), caster.soul:GetOrigin(), nil, distance, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
    for _,target in pairs( units ) do
        local knockbackTable = {
            center_x = caster.soul:GetAbsOrigin().x,
            center_y = caster.soul:GetAbsOrigin().y,
            center_z = caster.soul:GetAbsOrigin().z,
            knockback_duration = knockduration,
            knockback_distance = distance - caster.soul:GetRangeToUnit(target) + 50,
            knockback_height = 100 - (caster.soul:GetRangeToUnit(target)/4),
            should_stun = 0,
            duration = knockduration,
        }
        target:RemoveModifierByName("modifier_knockback")
        target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
        Timers:CreateTimer(knockduration, function () ability:ApplyDataDrivenModifier(caster, target, "modifier_soul_root", {duration = duration}) end)
        local distance = caster.soul:GetRangeToUnit(target)
        local dmg = damage / distance * 130
        if dmg > damage then
            ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
        elseif dmg <= (damage / 2) then
            ApplyDamage({victim = target, attacker = caster, damage = (damage / 2), damage_type = ability:GetAbilityDamageType()})
        else
            ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type = ability:GetAbilityDamageType()})
        end
    end
end

function AddStunModifier(keys)
    local ability = keys.ability
    local caster = keys.caster
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_tamer_stun_limit", {})
    if not ability.cooldown then
        ability.cooldown = ability:GetCooldownTimeRemaining()
        ability:SetActivated(false)
        ability:EndCooldown() 
    end
end

function AddPushModifier(keys)
    local ability = keys.ability
    local caster = keys.caster
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_tamer_push_limit", {})
    if not ability.cooldown then
        ability.cooldown = ability:GetCooldownTimeRemaining()
        ability:SetActivated(false)
        ability:EndCooldown() 
    end
end

function CheckIfMovedPush(keys)
    local caster = keys.caster
    local ability = keys.ability
    local cooldown = ability:GetCooldown(ability:GetLevel())
    ability.pushInQueue = true
    local ab_move_soul = caster:FindAbilityByName("tamer_move_soul")
    if caster:HasModifier("modifier_pull_chase_soul") then
        ability.pushInQueue = nil
        CastPush(caster, ability)
        caster:RemoveModifierByName("modifier_tamer_push_limit")
        ability:StartCooldown(ability.cooldown)
        ability.cooldown = nil
        ability:SetActivated(true)
    end
    if not ab_move_soul.isMoving and not caster:HasModifier("modifier_soul_moving_to_target") and not caster:HasModifier("modifier_pull_chase_soul") then
        caster:RemoveModifierByName("modifier_tamer_push_limit")
        ability.pushInQueue = nil
        CastPush(caster, ability)
        ability:StartCooldown(ability.cooldown)
        ability.cooldown = nil
        ability:SetActivated(true)
    end
end