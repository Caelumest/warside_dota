LinkLuaModifier("modifier_release_anger", "heroes/new_hero/modifier_release_anger.lua", LUA_MODIFIER_MOTION_NONE)

modifier_release_anger = class({})

function modifier_release_anger:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_release_anger:IsHidden()
    return true
end

function modifier_release_anger:IsPurgable()
    return true
end

function modifier_release_anger:GetModifierPreAttack_CriticalStrike()
    local stack_modifier = "modifier_release_angerss"
    local ability = self:GetAbility()
    local total = self:GetParent():GetModifierStackCount(stack_modifier, ability)
    return total
end
