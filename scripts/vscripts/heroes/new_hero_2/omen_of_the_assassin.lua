function OnCreated(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    target.pointsHited = 1
    target.westFlag = false
    target.eastFlag = false
    target.northFlag = false
    target.southFlag = false
    target.top_particle = {}
    target.top_particle2 = {}
    target.top_particle3 = {}
    target.bot_particle = {}
    target.bot_particle2 = {}
    target.bot_particle3 = {}
    target.left_particle = {}
    target.left_particle2 = {}
    target.left_particle3 = {}
    target.right_particle = {}
    target.right_particle2 = {}
    target.right_particle3 = {}
    local particle = "particles/world_tower/tower_upgrade/ti7_dire_tower_orb_sphere.vpcf"
    local particle_offset = 100
    local height = 50
    for i=0, 2 do
        target.top_particle[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target) 
        ParticleManager:SetParticleControl(target.top_particle[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.top_particle[i], 1, target:GetAbsOrigin() + Vector(0,particle_offset,height+ i*10))

        target.top_particle2[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target) 
        ParticleManager:SetParticleControl(target.top_particle2[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.top_particle2[i], 1, target:GetAbsOrigin() + Vector(30,particle_offset-10,height+ i*10))

        target.top_particle3[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target) 
        ParticleManager:SetParticleControl(target.top_particle3[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.top_particle3[i], 1, target:GetAbsOrigin() + Vector(-30,particle_offset-10,height+ i*10))

        target.bot_particle[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.bot_particle[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.bot_particle[i], 1, target:GetAbsOrigin() + Vector(0,-particle_offset,height+ i*10))

        target.bot_particle2[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.bot_particle2[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.bot_particle2[i], 1, target:GetAbsOrigin() + Vector(30,-particle_offset+10,height+ i*10))

        target.bot_particle3[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.bot_particle3[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.bot_particle3[i], 1, target:GetAbsOrigin() + Vector(-30,-particle_offset+10,height+ i*10))

        target.right_particle[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.right_particle[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.right_particle[i], 1, target:GetAbsOrigin() + Vector(particle_offset,0,height+ i*10))

        target.right_particle2[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.right_particle2[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.right_particle2[i], 1, target:GetAbsOrigin() + Vector(particle_offset-10,-30,height+ i*10))

        target.right_particle3[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.right_particle3[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.right_particle3[i], 1, target:GetAbsOrigin() + Vector(particle_offset-10,30,height+ i*10))

        target.left_particle[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.left_particle[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.left_particle[i], 1, target:GetAbsOrigin() + Vector(-particle_offset,0,height+ i*10))

        target.left_particle2[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.left_particle2[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.left_particle2[i], 1, target:GetAbsOrigin() + Vector(-particle_offset+10,-30,height+ i*10))

        target.left_particle3[i] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(target.left_particle3[i], 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.left_particle3[i], 1, target:GetAbsOrigin() + Vector(-particle_offset+10,30,height+ i*10))
    end
end

function OnHit(keys)
	local caster = keys.attacker
    local ability = keys.ability
    local target = keys.target
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    local damage_bonus = ability:GetLevelSpecialValueFor("damage_bonus", (ability:GetLevel() - 1))
    local victim_angle = target:GetAnglesAsVector().y
    local origin_difference = target:GetAbsOrigin() - keys.attacker:GetAbsOrigin()
    local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
    local origin_difference_radian = origin_difference_radian * 180
    local attacker_angle = origin_difference_radian / math.pi
    local attacker_angle = attacker_angle + 180.0
    local result_angle = math.abs(attacker_angle)
    if target:HasModifier("modifier_omen_angles") then
        if result_angle >= (180 - (90 / 2)) and result_angle <= (180 + (90 / 2)) and target.westFlag == false then 
            print("HITED <")
            for i=0, 2 do
                ParticleManager:DestroyParticle(target.left_particle[i], false)
                ParticleManager:DestroyParticle(target.left_particle2[i], false)
                ParticleManager:DestroyParticle(target.left_particle3[i], false)
            end
            target.westFlag = true
            ReduceDashCooldown(caster)
            PlaySound(target)
        elseif result_angle >= (360 - (90 / 2)) or result_angle <= (0 + (90 / 2)) and target.eastFlag == false then 
            print("HITED >")
            for i=0, 2 do
                ParticleManager:DestroyParticle(target.right_particle[i], false)
                ParticleManager:DestroyParticle(target.right_particle2[i], false)
                ParticleManager:DestroyParticle(target.right_particle3[i], false)
            end
            target.eastFlag = true
            ReduceDashCooldown(caster)
            PlaySound(target)
        elseif result_angle >= (280 - (90 / 2)) and result_angle <= (280 + (90 / 2)) and target.southFlag == false then 
            print("HITED DOWN")
            for i=0, 2 do
                ParticleManager:DestroyParticle(target.bot_particle[i], false)
                ParticleManager:DestroyParticle(target.bot_particle2[i], false)
                ParticleManager:DestroyParticle(target.bot_particle3[i], false)
            end
            target.southFlag = true
            ReduceDashCooldown(caster)
            PlaySound(target)
        elseif result_angle >= (90 - (90 / 2)) and result_angle <= (90 + (90 / 2)) and target.northFlag == false then 
            print("HITED ^")
            for i=0, 2 do
                ParticleManager:DestroyParticle(target.top_particle[i], false)
                ParticleManager:DestroyParticle(target.top_particle2[i], false)
                ParticleManager:DestroyParticle(target.top_particle3[i], false)
            end
            ReduceDashCooldown(caster)
            target.northFlag = true
            PlaySound(target)
        end
    end
    if(target.westFlag and target.eastFlag and target.southFlag and target.northFlag) then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_omen_debuffs", {Duration=duration})
        ApplyDamage({victim = target, attacker = keys.attacker, damage = damage_bonus, damage_type = ability:GetAbilityDamageType()})
        EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Omen.FinalHit", caster)
        ability:ApplyDataDrivenThinker(caster, target:GetAbsOrigin(), "modifier_omen_thinker", {})
        target:RemoveModifierByName("modifier_omen_angles")
        target.northFlag = false
    end
end

function OnEarlyDeath(keys)
    local caster = keys.attacker
    local ability = keys.ability
    local target = keys.unit
    local agi_bonus = ability:GetSpecialValueFor("agi_bonus_scepter") / 2
    if (target.westFlag == false or target.eastFlag == false or target.southFlag == false or target.northFlag == false) then
        if caster:HasScepter() then
            if not caster:HasModifier("modifier_omen_agility_scepter") then
                ability:ApplyDataDrivenModifier(caster, caster, "modifier_omen_agility_scepter", {})
            end
            if ability.agi_bonus == nil then
                ability.agi_bonus = 0
            end
            ability.agi_bonus = ability.agi_bonus + agi_bonus
            caster:SetModifierStackCount("modifier_omen_agility_scepter", ability, ability.agi_bonus)
        end
        EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Omen.FinalHit", caster)
        ability:ApplyDataDrivenThinker(caster, target:GetAbsOrigin(), "modifier_omen_thinker_halved", {})
        target:RemoveModifierByName("modifier_omen_angles")
        target.northFlag = false
    end
end

function ReduceDashCooldown(caster)
    local dash_ability = caster:FindAbilityByName("art_dash")
    if dash_ability:GetCooldownTimeRemaining() > 1 then
        dash_ability:EndCooldown()
        dash_ability:StartCooldown(1)
    end
end

function PlaySound(target)
    if target.pointsHited == 1 then
        EmitSoundOn("Omen.FirstHit", target)
    elseif target.pointsHited == 2 then
        EmitSoundOn("Omen.SecondHit", target)
    elseif target.pointsHited == 3 then
        EmitSoundOn("Omen.ThirdHit", target)
    end
    target.pointsHited = target.pointsHited + 1
end

function OnDeath(keys)
    local caster = keys.caster
    local ability = keys.ability
    local agi_bonus = ability:GetSpecialValueFor("agi_bonus_scepter")
    if caster:HasScepter() then
        if not caster:HasModifier("modifier_omen_agility_scepter") then
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_omen_agility_scepter", {})
        end
        if ability.agi_bonus == nil then
            ability.agi_bonus = 0
        end
        ability.agi_bonus = ability.agi_bonus + agi_bonus
        caster:SetModifierStackCount("modifier_omen_agility_scepter", ability, ability.agi_bonus)
    end
end

function OnDestroyed(keys)
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    for i=0, 2 do
        ParticleManager:DestroyParticle(target.bot_particle[i], false)
        ParticleManager:DestroyParticle(target.bot_particle2[i], false)
        ParticleManager:DestroyParticle(target.bot_particle3[i], false)
        ParticleManager:DestroyParticle(target.left_particle[i], false)
        ParticleManager:DestroyParticle(target.left_particle2[i], false)
        ParticleManager:DestroyParticle(target.left_particle3[i], false)
        ParticleManager:DestroyParticle(target.top_particle[i], false)
        ParticleManager:DestroyParticle(target.top_particle2[i], false)
        ParticleManager:DestroyParticle(target.top_particle3[i], false)
        ParticleManager:DestroyParticle(target.right_particle[i], false)
        ParticleManager:DestroyParticle(target.right_particle2[i], false)
        ParticleManager:DestroyParticle(target.right_particle3[i], false)
    end
end