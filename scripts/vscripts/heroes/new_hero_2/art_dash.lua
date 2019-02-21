function CheckInitialPos(keys)
    local caster = keys.caster
    local ability = keys.ability
    local point = Vector(ability:GetCursorPosition().x, ability:GetCursorPosition().y, caster:GetAbsOrigin().z)
    local vector_distance = point - caster:GetAbsOrigin()
    local mod_count = caster:GetModifierStackCount("modifier_andrax_extra_dash", ability)
    if caster:HasModifier("modifier_item_octarine_core") then
        caster.octarineReduce = 0.75
    else
        caster.octarineReduce = 1
    end
    starting_distance = (vector_distance):Length2D()
    starting_caster_loc = (caster:GetAbsOrigin()):Length2D()
    traveled_distance = 0
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_dash_stop_caster", {Duration = 1})
    caster:SetForwardVector((Vector(point.x, point.y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
    caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.7)
    
    ability.particle_dash = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(ability.particle_dash, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(ability.particle_dash, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(ability.particle_dash, 2, caster:GetAbsOrigin())
    if mod_count > 1 then
        ability:EndCooldown()
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_andrax_extra_dash_cooldown", {Duration = ability:GetCooldown(ability:GetLevel() -1) * caster.octarineReduce})
        caster:SetModifierStackCount("modifier_andrax_extra_dash", ability, mod_count - 1)
    elseif caster:HasModifier("modifier_andrax_extra_dash_cooldown") then
        local cooldown = caster:FindModifierByName("modifier_andrax_extra_dash_cooldown"):GetRemainingTime()
        caster:RemoveModifierByName("modifier_andrax_extra_dash")
        ability:EndCooldown()
        ability:StartCooldown(cooldown)
    end
end

function CheckTalent(keys)
    local caster = keys.caster
    local ability = keys.ability
    local talent = caster:FindAbilityByName("special_bonus_unique_andrax_extra_dash")
    if talent:GetLevel() > 0 then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_andrax_extra_dash", {})
        caster:SetModifierStackCount("modifier_andrax_extra_dash", ability, 2)
        caster:RemoveModifierByName("modifier_check_extra_dash")
    end
end

function GiveExtraDash(keys)
    local caster = keys.caster
    local ability = keys.ability
    if caster:HasModifier("modifier_item_octarine_core") then
        caster.octarineReduce = 0.75
    else
        caster.octarineReduce = 1
    end
    local mod_count = caster:GetModifierStackCount("modifier_andrax_extra_dash", ability)
    if mod_count < 1 then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_andrax_extra_dash_cooldown", {Duration = ability:GetCooldown(ability:GetLevel() -1) * caster.octarineReduce})
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_andrax_extra_dash", {})
        caster:SetModifierStackCount("modifier_andrax_extra_dash", ability, 1)
    else
        caster:SetModifierStackCount("modifier_andrax_extra_dash", ability, 2)
    end
end

function MoveTo(event)
    local caster = event.caster
    local ability = event.ability
    local speed = ability:GetSpecialValueFor("speed") / 30
    local atkGatherAOE = ability:GetSpecialValueFor("atkGatherAOE")
    local point = Vector(ability:GetCursorPosition().x, ability:GetCursorPosition().y, caster:GetAbsOrigin().z)
    local caster_loc = (point - caster:GetAbsOrigin()):Length2D()
    --local distance = caster_loc:Length2D() - ability:GetCastRange()
    local vector_distance = point - caster:GetAbsOrigin()
    -- Moving the caster closer to the target until it reaches the enemy
    if traveled_distance < starting_distance then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + caster:GetForwardVector() * speed)
        traveled_distance = traveled_distance + speed
        if caster:IsHexed() then
            caster:InterruptMotionControllers(true)
            caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
            caster:RemoveModifierByName("modifier_dash_stop_caster")
            ParticleManager:DestroyParticle(ability.particle_dash, false)
        end
    else
        caster:InterruptMotionControllers(true)
        caster:RemoveModifierByName("modifier_dash_stop_caster")
        if not caster:IsStunned() then
            AttackNearby(caster, ability, atkGatherAOE)
        end
        caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
        ParticleManager:DestroyParticle(ability.particle_dash, false)
    end
end

function AttackNearby(caster, ability, atkGatherAOE)
    local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, atkGatherAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
    for _,enemy in pairs( units ) do
        if caster:GetRangeToUnit(enemy) <= atkGatherAOE  and enemy ~= caster then
            if enemy:HasModifier("modifier_omen_angles") then
                AttackTarget(caster, enemy)
                return
            else
                ability.target = enemy
            end
        end
    end
    AttackTarget(caster, ability.target)
    ability.target = nil
end

function OnDestroyed(keys)
    local ability = keys.ability
    local caster = keys.caster
    ParticleManager:DestroyParticle(ability.particle_dash, false)
end

function AttackTarget(caster, target)
    if target and not target:IsInvisible() then
        caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
        caster:PerformAttack(target, true, true, true, false, false, false, true)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_heartpiercer_cast_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
    end
end
