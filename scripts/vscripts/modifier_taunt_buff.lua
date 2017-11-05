modifier_taunt_buff = class({})

function modifier_taunt_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
             MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_taunt_buff:OnCreated()
	local target = self:GetParent()
    local caster = self:GetCaster();
    local origin = caster:GetOrigin()
    local ability = caster:GetAbility()
    local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	direUnits = FindAllInSphere(origin, radius)
end

function modifier_taunt_buff:IsHidden()
    return false
end

function modifier_taunt_buff:IsPurgable()
    return false
end

function modifier_taunt_buff:GetTexture()
    return "legion_demon_form"
end

function modifier_taunt_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor") * direUnits
end

function modifier_taunt_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("regen") * direUnits
end
