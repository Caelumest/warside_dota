modifier_legion_demon_form = class({})

function modifier_legion_demon_form:DeclareFunctions()
    local funcs_array = {MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS}
    return funcs_array
end



function modifier_legion_demon_form:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end