modifier_lone_heritage_debuff = class({})

function modifier_lone_heritage_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
             MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_lone_heritage_debuff:OnCreated()
    local target = self:GetParent()
    local caster = self:GetCaster()
    armor_buff_lone2 = nil
    regen_buff_lone2 = nil
    armor_buff_lone2 = 0 - caster:GetPhysicalArmorValue()
    regen_buff_lone2 = 0 - caster:GetHealthRegen()
end

function modifier_lone_heritage_debuff:IsHidden()
    return false
end

function modifier_lone_heritage_debuff:IsDebuff()
    return true
end

function modifier_lone_heritage_debuff:IsPurgable()
    return false
end

function modifier_lone_heritage_debuff:GetTexture()
    return "lone_druid_rabid"
end

function modifier_lone_heritage_debuff:GetModifierPhysicalArmorBonus()
    return armor_buff_lone2
end

function modifier_lone_heritage_debuff:GetModifierConstantHealthRegen()
    return regen_buff_lone2
end
