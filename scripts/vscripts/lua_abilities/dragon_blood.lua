dragon_blood = class({})
LinkLuaModifier("modifier_dragon_blood_talent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_blood", LUA_MODIFIER_MOTION_NONE)

--[[
    Author: Bude
    Date: 30.09.2015
    Simply applies the lua modifier
--]]
function ApplyLuaModifier(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifiername = keys.ModifierName
    local talent = caster:FindAbilityByName("special_bonus_unique_dk_2")
    if talent:GetLevel() == 0 and ability:IsHidden() == false then
		caster:AddNewModifier(caster, ability, "modifier_dragon_blood", {})
	elseif ability:IsHidden() == false then
		caster:RemoveModifierByName("modifier_dragon_blood")
		caster:AddNewModifier(caster, ability, "modifier_dragon_blood_talent", {})
        caster:RemoveModifierByName("modifier_check_talent")
	end
end