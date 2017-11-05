modifier_lone_heritage = class({})

function modifier_lone_heritage:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
             MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_lone_heritage:OnCreated()
    local target = self:GetParent()
    local caster = self:GetCaster()
    armor_buff_lone = nil
    regen_buff_lone = nil
    armor_buff_lone = caster:GetPhysicalArmorValue()
    regen_buff_lone = caster:GetHealthRegen()
end

function modifier_lone_heritage:IsHidden()
    return false
end

function modifier_lone_heritage:IsPurgable()
    return false
end

function modifier_lone_heritage:GetTexture()
    return "lone_druid_rabid"
end

function modifier_lone_heritage:GetModifierPhysicalArmorBonus()
    return armor_buff_lone
end

function modifier_lone_heritage:GetModifierConstantHealthRegen()
    return regen_buff_lone
end
