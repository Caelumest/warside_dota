function DealDamage(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local breakpoints = caster:FindAbilityByName("andrax_breakpoints")
    local agi_damage = ability:GetLevelSpecialValueFor("agi_damage", (ability:GetLevel() - 1)) + caster:GetTalentValue("special_bonus_unique_andrax_agi_mult")
    local damage = ability:GetAbilityDamage() + caster:GetAgility() * agi_damage
    caster:PerformAttack(target, true, true, true, true, false, true, true)
    if breakpoints:GetLevel() > 0 then
        local stack_count = target:GetModifierStackCount("modifier_breakpoints_stacks", breakpoints)
        local stack_count_caster = caster:GetModifierStackCount("modifier_breakpoints_stacks_regen_caster", breakpoints)
        if target:IsHero() then
            target:SetModifierStackCount("modifier_breakpoints_stacks", breakpoints, stack_count + 3)
            caster:SetModifierStackCount("modifier_breakpoints_stacks_regen_caster", breakpoints, stack_count_caster + 3)
            target.breakpoints_stacks = stack_count + 3
        else
            target:SetModifierStackCount("modifier_breakpoints_stacks", breakpoints, stack_count + 1)
            caster:SetModifierStackCount("modifier_breakpoints_stacks_regen_caster", breakpoints, stack_count_caster + 1)
            target.breakpoints_stacks = stack_count + 1
        end
    end
    ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
    if not target:IsAlive() and breakpoints:GetLevel() > 0 then
        local stack_count = caster:GetModifierStackCount("modifier_breakpoints_stacks_regen_caster", breakpoints) - target.breakpoints_stacks
        caster:SetModifierStackCount("modifier_breakpoints_stacks_regen_caster", breakpoints, stack_count)
        target.breakpoints_stacks = 0
        if stack_count <= 0 then
            caster:RemoveModifierByName("modifier_breakpoints_stacks_regen_caster")
        end
    end
end

function Effects(keys)
    local caster = keys.caster
    local ability = keys.ability
    local point = ability:GetCursorPosition()
    caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1_END, 3.0)
    local particle_name = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler.vpcf"

    ability.maxDist = ability:GetLevelSpecialValueFor("hit_range", (ability:GetLevel() - 1))
    if caster:FindAbilityByName("special_bonus_cast_range_250"):GetLevel() > 0 then
        ability.maxDist = ability.maxDist + 250
    end
    if caster:HasModifier("modifier_item_aether_lens") then
        ability.maxDist = ability.maxDist + 250
    end
    caster:SetForwardVector((Vector(point.x, point.y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
    ability.projID = ProjectileManager:CreateLinearProjectile( {
        Ability             = ability,
        EffectName          = nil,
        vSpawnOrigin        = caster:GetAbsOrigin(),
        fDistance           = ability.maxDist,
        fStartRadius        = 120,
        fEndRadius          = 120,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType     = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        fExpireTime         = GameRules:GetGameTime() + 1.0,
        bDeleteOnHit        = false,
        vVelocity           = caster:GetForwardVector() * 50000,
        bProvidesVision     = true,
        iVisionRadius       = 0,
        iVisionTeamNumber   = caster:GetTeamNumber(),
    } )
    ability.particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, caster) 
    ParticleManager:SetParticleControl(ability.particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(ability.particle, 1, caster:GetForwardVector() * 1500)
end

function RemoveEffect(keys)
    local ability = keys.ability
    local caster = keys.caster
    ParticleManager:DestroyParticle(ability.particle, false)
    caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1_END)
end