modifier_lone_true_form = class({})



function modifier_lone_true_form:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
             MODIFIER_PROPERTY_MODEL_CHANGE,
			 MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
             MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
             MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
             MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
             MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_lone_true_form:GetEffectName()
    return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_lone_true_form:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_lone_true_form:IsHidden()
    return false
end

function modifier_lone_true_form:GetAttackSound()
    return "Hero_LoneDruid.TrueForm.Attack"
end

function modifier_lone_true_form:IsPurgable()
    return false
end

function modifier_lone_true_form:GetModifierModelChange()
    return "models/heroes/lone_druid/true_form.vmdl"
end

function modifier_lone_true_form:GetTexture()
    return "lone_druid_true_form"
end

function modifier_lone_true_form:AllowIllusionDuplicate()
    return true
end

function modifier_lone_true_form:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("range_loss")
end

function modifier_lone_true_form:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_lone_true_form:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_lone_true_form:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("attack_rate")
end

function modifier_lone_true_form:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("speed_loss")
end
