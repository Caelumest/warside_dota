LinkLuaModifier("modifier_lone_heritage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lone_heritage_debuff", LUA_MODIFIER_MOTION_NONE)
function ApplyBuff(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local talent = caster:FindAbilityByName("special_bonus_unique_lone_1")
    if talent:GetLevel() > 0 then
        talent_duration = talent:GetSpecialValueFor("value")
    else
        talent_duration = 0
    end
    local duration_buff = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1)) + talent_duration
    local modifier = keys.modifier
    if target == caster then
    	target:RemoveModifierByName("modifier_lone_heritage_debuff")
    	target:RemoveModifierByName("modifier_lone_heritage")
    	target:AddNewModifier(caster, ability, "modifier_lone_heritage", {duration = duration_buff})
    else
    	caster:RemoveModifierByName("modifier_lone_heritage")
    	caster:RemoveModifierByName("modifier_lone_heritage_debuff")
    	target:AddNewModifier(caster, ability, "modifier_lone_heritage", {duration = duration_buff})
    	caster:AddNewModifier(caster, ability, "modifier_lone_heritage_debuff", {duration = duration_buff})
    end
end