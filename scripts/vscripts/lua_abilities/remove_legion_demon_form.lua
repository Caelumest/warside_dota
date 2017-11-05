
remove_legion_demon_form = class({})
LinkLuaModifier("modifier_legion_demon_form", LUA_MODIFIER_MOTION_NONE)


function remove_legion_demon_form(event)
	local caster = event.caster
	local ability3 = caster:FindAbilityByName("legion_demon_form")
	local talent = caster:FindAbilityByName("special_bonus_unique_legion_1")
	if ability3:IsHidden() then
		caster:RemoveModifierByName("modifier_legion_demon_form")
		caster:SwapAbilities("remove_legion_demon_form", "legion_demon_form", false, true)
		local ability1 = caster:FindAbilityByName("legion_demon_form")
	    	ability1:SetLevel(1)

	    if talent:GetLevel() > 0 then
    		caster:SwapAbilities("legion_desintegrate_talent", "legion_imprecise_smash", true, false)
	    else
	    	caster:SwapAbilities("legion_desintegrate", "legion_imprecise_smash", true, false)
	    end

		caster:SwapAbilities("legion_courage", "demon_blood", true, false)

		caster:SwapAbilities("legion_expose_weakness", "legion_crit", true, false)
		
		caster:RemoveModifierByName("modifier_demon_blood")
		caster:RemoveModifierByName("legion_crit")
	end
end
