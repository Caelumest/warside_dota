sobek_absorption = class({})

local CAST_RANGE = 700
local AOE = 700

local DURATION = 5

local UNIT_PARTICLE_DURATION = 1

function sobek_absorption:GetCastRange()
    return CAST_RANGE
end

function sobek_absorption:GetAOERadius()
    return AOE
end

function sobek_absorption:OnSpellStart()
    local caster = self:GetCaster()

    -- If full HP then actually do nothing
    if caster:GetMaxHealth() == caster:GetHealth() and not caster:HasScepter() then
        -- Play particle and stop ability execution
        local endParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_absorption_fullhealth.vpcf", PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl(endParticle, 1, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(endParticle, 4, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(endParticle)
        return
    end

    -- Create particle
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_absorption_ring.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, Vector(AOE, 0, 0))

    -- Emit sound
    EmitGlobalSound("Hero_Koh.Absorption")

    local startTime = GameRules:GetGameTime()

    -- Get factor for dps calculations
    local factor = self:GetSpecialValueFor("max_hp") / 100
    local damageType = DAMAGE_TYPE_MAGICAL
    local damageFlags = DOTA_UNIT_TARGET_FLAG_NONE
    -- -- If we have lvl25 talent, make it deal pure damage
    -- local talent = caster:FindAbilityByName("special_bonus_unique_windranger")
    -- if talent:GetLevel() > 0 then
    --     damageType = DAMAGE_TYPE_PURE
    --     damageFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    -- end

    -- Calculate dps from missing HP
    local dps = 0
    if caster:HasScepter() then
        dps = caster:GetMaxHealth() * factor / DURATION
    else
        dps = (caster:GetMaxHealth() - caster:GetHealth()) * factor / DURATION
    end

    -- Store particle timings
    local particleTimes = {}

    Timers:CreateTimer(0, function()
        -- Get current time
        local time = GameRules:GetGameTime()
        -- Check if timer should expire
        if time - startTime >= DURATION then
            -- End ability
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)

            return nil
        end

        -- Timer tick
        -- Move particle
        ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())

        -- Calculate damage to do
        local damage = dps * FrameTime()

        -- Search target unit in radius
        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, AOE, DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, damageFlags, FIND_ANY_ORDER, false)

        local numTargets = #units

        -- Loop over all targets
        if numTargets > 0 then
            for _, target in pairs(units) do
                -- Apply damage
                ApplyDamage({
                    victim = target,
                    attacker = caster,
                    damage = damage / numTargets,
                    damage_type = damageType,
                    ability = self
                })

                -- Create particle if cooled down
                if particleTimes[target] == nil or time - particleTimes[target] > UNIT_PARTICLE_DURATION then
                    particleTimes[target] = time

                    if target:IsHero() then
                        -- Create particle
                        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_absorption_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                        ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(), true)
                        ParticleManager:ReleaseParticleIndex(particle)
                    else
                        -- Create particle
                        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_absorption_creep.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                        ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(), true)
                        ParticleManager:ReleaseParticleIndex(particle)
                    end

                    target:EmitSound("Hero_Koh.Absorption.Tick")
                end
            end

            -- Heal sobek for the damage dealt, accounting for magic resistance
            caster:Heal(damage, caster)
        end

        return 0
    end)
end