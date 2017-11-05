modifier_legion_demon_form = class({})



function modifier_legion_demon_form:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			 MODIFIER_PROPERTY_STATS_AGILITY_BONUS, 
             MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
             MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
             MODIFIER_EVENT_ON_ATTACK_START,}
end

function modifier_legion_demon_form:OnCreated()
    if IsServer() then
        local target = self:GetParent()
        local caster = self:GetCaster();
        local particle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_ambient_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        self:AddParticle(particle, false, false, 1, false, false)
        local particleFeet = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_feet_effects.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        self:AddParticle(particleFeet, false, false, 1, false, false)
    end
end

function modifier_legion_demon_form:GetEffectName()
    return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_legion_demon_form:GetEffectName()
    return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_ambient.vpcf"
end

function modifier_legion_demon_form:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_legion_demon_form:OnAttackStart()
    return "Hero_Terrorblade.Metamorphosis"
end

function modifier_legion_demon_form:IsHidden()
    return false
end

function modifier_legion_demon_form:IsPurgable()
    return false
end

function modifier_legion_demon_form:GetTexture()
    return "legion_demon_form"
end

function modifier_legion_demon_form:AllowIllusionDuplicate()
    return true
end

function modifier_legion_demon_form:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_legion_demon_form:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_legion_demon_form:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("attack_rate")
end

function modifier_legion_demon_form:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end
