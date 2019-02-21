modifier_dk_dragon_form = class({})



function modifier_dk_dragon_form:DeclareFunctions()
    return { MODIFIER_PROPERTY_MODEL_CHANGE, 
			 MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			 MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, 
             MODIFIER_PROPERTY_HEALTH_BONUS,
             MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
             MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
             MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
             MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_dk_dragon_form:OnCreated()
    if IsServer() then
        local caster = self:GetCaster();
        local target = self:GetParent();
        EmitSoundOn( "Hero_DragonKnight.ElderDragonForm", caster )
    end
end

function modifier_dk_dragon_form:GetEffectName()
    return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_dk_dragon_form:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_dk_dragon_form:GetAttackSound()
    return "Hero_DragonKnight.ElderDragonShoot1.Attack"
end

function modifier_dk_dragon_form:OnAttackLanded()
    return "Hero_DragonKnight.ProjectileImpact"
end

function modifier_dk_dragon_form:GetModifierModelChange()
    return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function modifier_dk_dragon_form:IsHidden()
    return false
end

function modifier_dk_dragon_form:IsPurgable()
    return false
end

function modifier_dk_dragon_form:GetTexture()
    return "dragon_knight_elder_dragon_form"
end

function modifier_dk_dragon_form:AllowIllusionDuplicate()
    return true
end

function modifier_dk_dragon_form:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_dk_dragon_form:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_dk_dragon_form:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_dk_dragon_form:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("range_bonus")
end

function modifier_dk_dragon_form:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end
