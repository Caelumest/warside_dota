LinkLuaModifier("modifier_release_anger", "heroes/new_hero/modifier_release_anger.lua", LUA_MODIFIER_MOTION_NONE)

release_anger = class({})

function release_anger(event)
	local caster = event.caster
	local ability = event.ability
    local ability2 = caster:FindAbilityByName("insatiable_hunger")
    local talent = caster:FindAbilityByName("special_bonus_unique_dk_2")
    local buff_duration = ability:GetSpecialValueFor("duration")
    local crit_base = ability:GetSpecialValueFor("base_crit")
    local total_stacks = caster:GetModifierStackCount("modifier_anger_stacks", ability2)
    local crit_damage = ability:GetSpecialValueFor("crit_damage")
    local atkspeed = ability:GetSpecialValueFor("atkspeed")
    local talent = caster:FindAbilityByName("special_bonus_unique_jugg_3")
    AddAnimationTranslate(caster, "arcana")
    AddAnimationTranslate(caster, "run_fast")
    AddAnimationTranslate(caster, "odachi")
    if talent:GetLevel() > 0 then
        atkspeed = atkspeed + talent:GetSpecialValueFor("value")
        crit_damage = crit_damage + talent:GetSpecialValueFor("value")
    end
    if caster:HasScepter() then
        crit_base = ability:GetSpecialValueFor("base_crit_scepter")
        buff_duration = ability:GetSpecialValueFor("duration_scepter")
    end
    if total_stacks > 0 then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_release_angers", {duration = buff_duration})
        caster:SetModifierStackCount("modifier_release_angers", ability, total_stacks * atkspeed)
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_release_angerss", {duration = buff_duration})
        caster:SetModifierStackCount("modifier_release_angerss", ability, crit_base + (total_stacks * crit_damage))
        ability:ApplyDataDrivenModifier(caster, caster, "anger_crit", {duration = buff_duration})
    end
end

function anger_crit(args)
    local caster = args.caster
    local ability = args.ability
    local buff_duration = ability:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, ability, "modifier_release_anger", {Duration = buff_duration})
end