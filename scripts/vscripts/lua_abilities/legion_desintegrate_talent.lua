function CheckTalent(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ability2 = caster:FindAbilityByName("legion_desintegrate_talent")
    local talent = caster:FindAbilityByName("special_bonus_unique_legion_1")
    if talent:GetLevel() > 0 then
	    if ability:IsHidden() == false then
		    caster:SwapAbilities("legion_desintegrate", "legion_desintegrate_talent", false, true)
		    local cooldown = ability:GetCooldownTimeRemaining()
		    ability2:StartCooldown(cooldown)
		    local level = ability:GetLevel()
		    ability2:SetLevel(level)
		    caster:RemoveModifierByName("modifier_desintegrate_talent")
		else
			local level = ability:GetLevel()
		    ability2:SetLevel(level)
		    caster:RemoveModifierByName("modifier_desintegrate_talent")
		end
	end
end