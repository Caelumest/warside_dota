octarine_core = class({})
LinkLuaModifier("modifier_octarine_core", LUA_MODIFIER_MOTION_NONE)

--[[
    Author: Bude
    Date: 30.09.2015
    Simply applies the lua modifier
--]]
function SpellSteal(keys)
    local caster = keys.caster
    local ability = keys.ability
    caster:RemoveModifierByName("modifier_octarine_core")
    caster:RemoveModifierByName("modifier_item_octarine_core")
    caster:RemoveModifierByName("modifier_item_aether_lens")
end