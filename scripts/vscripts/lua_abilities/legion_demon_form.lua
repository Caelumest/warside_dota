
legion_demon_form = class({})
LinkLuaModifier("modifier_legion_demon_form", LUA_MODIFIER_MOTION_NONE)

function legion_demon_form(event)
	local caster = event.caster
	local ability = event.ability
	local ability2 = caster:FindAbilityByName("demon_blood")
	local ability3 = caster:FindAbilityByName("legion_crit")
	local talent = caster:FindAbilityByName("special_bonus_unique_legion_1")
	caster:AddNewModifier(caster, ability, "modifier_legion_demon_form", {})
	caster:SwapAbilities("legion_demon_form", "remove_legion_demon_form", false, true)
    local ability1 = caster:FindAbilityByName("remove_legion_demon_form")
    	ability1:SetLevel(1)

    if talent:GetLevel() > 0 then
    	caster:SwapAbilities("legion_desintegrate_talent", "legion_imprecise_smash", false, true)
    else
    	caster:SwapAbilities("legion_desintegrate", "legion_imprecise_smash", false, true)
    end

	caster:SwapAbilities("legion_courage", "demon_blood", false, true)

	caster:SwapAbilities("legion_expose_weakness", "legion_crit", false, true)
	if ability2:GetLevel() > 0 then
		ability2:ApplyDataDrivenModifier(caster, caster, "modifier_demon_blood", {})
	end

	if ability3:GetLevel() > 0 then
    	ability3:ApplyDataDrivenModifier(caster, caster, "legion_crit", {})
	end
end
