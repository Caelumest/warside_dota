modifier_flux_bonus_stacks = class({})

function modifier_flux_bonus_stacks:IsHidden()
	return false
end

function modifier_flux_bonus_stacks:IsPassive()
	return true
end

function modifier_flux_bonus_stacks:IsPermanent()
	return true
end

function modifier_flux_bonus_stacks:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
	
end

function modifier_flux_bonus_stacks:GetModifierDamageOutgoing_Percentage()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local bonus = ability:GetSpecialValueFor("bonus_per_kill")
	return bonus * caster:GetModifierStackCount("modifier_flux_bonus_stacks", ability)
end