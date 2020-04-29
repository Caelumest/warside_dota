function SetPosition(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local mana = caster:GetMana() + ability:GetManaCost(-1)
	ability.willDamage = true
	ability.target = target
    if not target:HasModifier("modifier_ronin_dash_target") then
    	caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
    	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ronin_dash", {duration = 0.4})
        EmitSoundOn("Hero_Ronin.Dash_Cast", caster);
        ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_windwalk_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_windwalk_swoop.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        StartAnimation(caster, {duration=1, activity=ACT_DOTA_FLAIL, rate=1, translate="forcestaff_friendly"})
        local abilityPuncture = caster:FindAbilityByName("ronin_puncture")
        abilityPuncture.hittedOne = nil
        abilityPuncture.spinInQueue = nil
        abilityPuncture.spinTornado = nil
    else
        caster:InterruptMotionControllers(true)
        ability:EndCooldown()
        caster:SetMana(ability.currentMana)
    end
end

function CheckCurrentMana(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability.currentMana = caster:GetMana()
end

function MoveThrough(keys)
	local caster = keys.caster
    local ability = keys.ability
    ability.speed = ability:GetSpecialValueFor("speed") / 30
    ability.linger = 0.25
    ability.stacks = caster:GetModifierStackCount("modifier_ronin_dash_count", caster)
    if ability.stacks == nil then
        ability.stacks = 0
    end
    if not ability.target:HasModifier("modifier_ronin_dash_target") then
        ability:ApplyDataDrivenModifier(caster, ability.target, "modifier_ronin_dash_target", {duration = ability:GetSpecialValueFor("target_cooldown") + caster:GetTalentValue("special_bonus_unique_sage_ronin_3")})
    end
    if caster:HasModifier("modifier_item_aether_lens") then
    	ability.speed = (ability:GetSpecialValueFor("speed") + 250) / 30
    	ability.linger = 0.16
    end
    local vector_distance = caster:GetAbsOrigin() + 400
    if caster:HasModifier("modifier_ronin_dash") then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + caster:GetForwardVector() * ability.speed)
        if caster:GetRangeToUnit(ability.target) < 50 and ability.willDamage then
        	ApplyDamage({victim = ability.target, attacker = caster, damage = ability:GetSpecialValueFor("damage") + (ability:GetSpecialValueFor("damage") * (ability.stacks+1) / 2), damage_type = DAMAGE_TYPE_MAGICAL})
            EmitSoundOn("Hero_Ronin.Dash_Hit", ability.target);
            if not caster:HasModifier("modifier_ronin_dash_count") then
                ability:ApplyDataDrivenModifier(caster, caster, "modifier_ronin_dash_count", {duration = ability:GetSpecialValueFor("target_cooldown")})
                caster:SetModifierStackCount("modifier_ronin_dash_count", caster, 1)
            elseif ability.stacks <= 2 then
                ability:ApplyDataDrivenModifier(caster, caster, "modifier_ronin_dash_count", {duration = ability:GetSpecialValueFor("target_cooldown")})
                caster:SetModifierStackCount("modifier_ronin_dash_count", caster, 2)
            end
        	ability.willDamage = nil
            local puncture = caster:FindAbilityByName("ronin_puncture")
            if not puncture.spinInQueue then
                caster:StartGestureWithPlaybackRate(ACT_DOTA_FORCESTAFF_END,1.5)
            end
            ability.animationPlayed = true
        	Timers:CreateTimer(ability.linger, function () 
                caster:RemoveModifierByName("modifier_ronin_dash")
                AddAnimationTranslate(caster, "walk")
                caster:StartGestureWithPlaybackRate(ACT_DOTA_FORCESTAFF_END,1.3)
                end)
        end
        AddAnimationTranslate(caster, "walk")
        if caster:IsHexed() then
            caster:InterruptMotionControllers(true)
            --caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
            caster:RemoveModifierByName("modifier_ronin_dash")
        end
    else
        caster:InterruptMotionControllers(true)
        caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    end
end

function OnDestroy(keys)
    local caster = keys.caster
    local ability = keys.ability
    local puncture = caster:FindAbilityByName("ronin_puncture")
    if not ability.animationPlayed and not puncture.spinInQueue then
        caster:StartGestureWithPlaybackRate(ACT_DOTA_FORCESTAFF_END,1.5)
    end
    ability.animationPlayed = nil
end

function CreateRings(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    ability.ringNumbers = ability:GetSpecialValueFor("target_cooldown") + caster:GetTalentValue("special_bonus_unique_sage_ronin_3")
    target.outRings = {}
    target.roninDashTicks = ringNumbers
    target.ringSize = 50
    ability.color = 0
    for i=1, ability.ringNumbers do
        target.outRings[i] = ParticleManager:CreateParticle("particles/ui_mouseactions/range_finder_tower_aoe_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(target.outRings[i], 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(target.outRings[i], 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(target.outRings[i], 3, Vector(target.ringSize, 0, 0))
        ParticleManager:SetParticleControl(target.outRings[i], 4, Vector(0, 170, 255 - ability.color))
        target.ringSize = target.ringSize + 4
        ability.color = ability.color + 10
    end
end

function RingEffects(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    if not target.roninDashTicks then
        target.roninDashTicks = ability.ringNumbers
    end
    if not target.ringSize then
        target.ringSize = 50
    end
    ParticleManager:DestroyParticle(target.outRings[target.roninDashTicks], false)
    target.roninDashTicks = target.roninDashTicks - 1
end

function RemoveRingEffects(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    if target.RingEffects then
        target.ringSize = nil
    end
    for i=1, ability.ringNumbers do
        if target.outRings[i] then
            ParticleManager:DestroyParticle(target.outRings[i], false)
        end
    end
end