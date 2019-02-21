lm_free_spells = class({})

function lm_free_spells:IsHidden()
	return true
end

function lm_free_spells:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}

	return funcs
end

function lm_free_spells:OnAbilityFullyCast( event )
	if not IsServer() then return end
	if self:GetParent() == event.unit then
		local ability = event.ability
		if ability then
			ability:RefundManaCost()
			ability:EndCooldown()
			ability:RefreshCharges()
		end
	end
end
