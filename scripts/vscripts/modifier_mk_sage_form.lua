modifier_mk_sage_form = class({})

function modifier_mk_sage_form:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			 MODIFIER_PROPERTY_STATS_AGILITY_BONUS, 
             MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
             MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_mk_sage_form:GetEffectName()
    return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_mk_sage_form:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_mk_sage_form:IsHidden()
    return false
end

function modifier_mk_sage_form:IsPurgable()
    return false
end

function modifier_mk_sage_form:GetTexture()
    return "sage_form"
end

function modifier_mk_sage_form:AllowIllusionDuplicate()
    return true
end

function modifier_mk_sage_form:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_mk_sage_form:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_mk_sage_form:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("attack_rate")
end

function modifier_mk_sage_form:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end
