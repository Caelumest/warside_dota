
spirit_form = class({})

function SwapAbilities(event)
	local caster = event.caster
	caster:SwapAbilities("spirit_form", "remove_spirit_form", false, true)
    local ability1 = caster:FindAbilityByName("remove_spirit_form")
    	ability1:SetLevel(1)
    	
    caster:SwapAbilities("keeper_guardian_blessing", "illuminate_datadriven", false, true)

	caster:SwapAbilities("keeper_light_armor", "keeper_blinding", false, true)

	caster:SwapAbilities("keeper_amplify_magic", "keeper_roar", false, true)
end
