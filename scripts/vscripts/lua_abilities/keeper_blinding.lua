keeper_blinding = class({})
LinkLuaModifier("modifier_keeper_blinding", LUA_MODIFIER_MOTION_NONE)

function keeper_blinding(event)
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local debuff_duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    target:AddNewModifier(caster, ability, "modifier_keeper_blinding", {duration = debuff_duration})
end