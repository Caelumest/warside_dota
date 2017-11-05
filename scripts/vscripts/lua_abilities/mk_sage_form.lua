
mk_sage_form = class({})
LinkLuaModifier("modifier_mk_sage_form", LUA_MODIFIER_MOTION_NONE)

function mk_sage_form(event)
	local caster = event.caster
	local ability = event.ability
	local ability2 = caster:FindAbilityByName("mk_staff")

    caster:SwapAbilities("mk_knockup", "mk_staff", false, true)

    if ability2:GetCooldownTimeRemaining() == 0 and ability2:GetLevel() > 0 then
		ability2:ApplyDataDrivenModifier(caster, caster, "modifier_mk_staff_orb", {})
	end

	caster:SwapAbilities("mana_break_datadriven", "mk_distraction", false, true)

	caster:SwapAbilities("mk_mkb", "mk_doppleganger", false, true)

	caster:SwapAbilities("mk_sage_form", "remove_mk_sage_form", false, true)
    local ability1 = caster:FindAbilityByName("remove_mk_sage_form")
    	ability1:SetLevel(1)

end
