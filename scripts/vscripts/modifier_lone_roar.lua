modifier_lone_roar = class({})

function modifier_lone_roar:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_lone_roar:IsHidden()
    return false
end

function modifier_lone_roar:IsPurgable()
    return false
end

function modifier_lone_roar:GetTexture()
    return "lone_druid_true_form_battle_cry"
end

function modifier_lone_roar:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end