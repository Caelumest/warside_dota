
remove_dk_dragon_form = class({})
LinkLuaModifier("modifier_dk_dragon_form", LUA_MODIFIER_MOTION_NONE)


function remove_dk_dragon_form(keys)
	local caster = keys.caster
	local ability2 = caster:FindAbilityByName("dk_fire_sword")
	local ability3 = caster:FindAbilityByName("dk_dragon_form")
	local talent = caster:FindAbilityByName("special_bonus_unique_dk_2")
	if ability3:IsHidden() then
		caster:SetAttackCapability(caster.caster_attack)

		caster:RemoveModifierByName("modifier_dk_dragon_form")

		caster:SwapAbilities("remove_dk_dragon_form", "dk_dragon_form", false, true)
	    local ability1 = caster:FindAbilityByName("remove_dk_dragon_form")
	    	ability1:SetLevel(1)

	    caster:SwapAbilities("dk_pull", "dk_shield_push", false, true)

		caster:SwapAbilities("dk_intimidate", "dk_breathe_fire", true, false)

		caster:SwapAbilities("dk_fire_sword", "dk_dragon_blood", true, false)
		if ability2:GetCooldownTimeRemaining() == 0 and ability2:GetLevel() > 0 then
			ability2:ApplyDataDrivenModifier(caster, caster, "modifier_dk_fire_sword_orb", {})
		end

		if talent:GetLevel() > 0 then
			caster:RemoveModifierByName("modifier_dragon_blood_talent")
		end
			caster:RemoveModifierByName("modifier_dragon_blood")
	end
end
