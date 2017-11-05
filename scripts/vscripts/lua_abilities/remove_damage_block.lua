remove_damage_block = class({})
LinkLuaModifier("modifier_item_stout_shield", LUA_MODIFIER_MOTION_NONE)

--[[
    Author: Bude
    Date: 30.09.2015
    Simply applies the lua modifier
--]]
function Block(keys)
    local caster = keys.caster
    local ability = keys.ability

    caster:RemoveModifierByName("modifier_item_stout_shield")
end