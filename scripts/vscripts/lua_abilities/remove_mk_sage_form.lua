
remove_mk_sage_form = class({})
LinkLuaModifier("modifier_mk_sage_form", LUA_MODIFIER_MOTION_NONE)


function remove_mk_sage_form(keys)
	local caster = keys.caster
	local ability3 = caster:FindAbilityByName("mk_sage_form")
	if ability3:IsHidden() then
		caster:RemoveModifierByName("modifier_effects")
		caster:RemoveModifierByName("modifier_mk_sage_form")
		caster:SwapAbilities("remove_mk_sage_form", "mk_sage_form", false, true)
		local ability1 = caster:FindAbilityByName("mk_sage_form")
	    	ability1:SetLevel(1)

	    caster:SwapAbilities("mk_knockup", "mk_staff", true, false)

		caster:RemoveModifierByName("modifier_mk_staff_orb")

		caster:SwapAbilities("mana_break_datadriven", "mk_distraction", true, false)

		caster:SwapAbilities("mk_mkb", "mk_doppleganger", true, false)
	end
end
