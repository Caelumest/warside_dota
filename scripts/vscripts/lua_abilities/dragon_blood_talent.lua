dragon_blood_talent = class({})
LinkLuaModifier("modifier_dragon_blood_talent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_blood", LUA_MODIFIER_MOTION_NONE)

--[[
    Author: Bude
    Date: 30.09.2015
    Simply applies the lua modifier
--]]
function ApplyLuaModifier(keys)
    local caster = keys.caster
    local ability = caster:FindAbilityByName("dk_dragon_blood")
    local modifiername = keys.ModifierName
    caster:RemoveModifierByName("modifier_dragon_blood")
    caster:RemoveModifierByName("modifier_dragon_blood_talent")
end