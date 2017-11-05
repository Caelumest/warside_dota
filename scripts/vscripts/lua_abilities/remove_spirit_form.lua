
spirit_form = class({})

function SwapAbilities(event)
	local caster = event.caster
	local ability3 = caster:FindAbilityByName("spirit_form")
	if ability3:IsHidden() then
		ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", 0, self)
		EmitSoundOn( "Hero_Terrorblade.Metamorphosis", caster )
		caster:RemoveModifierByName("modifier_spirit_form")
		caster:SwapAbilities("spirit_form", "remove_spirit_form", true, false)
	    local ability1 = caster:FindAbilityByName("spirit_form")
	    	ability1:SetLevel(1)
	    	
	    caster:SwapAbilities("keeper_guardian_blessing", "illuminate_datadriven", true, false)


		caster:SwapAbilities("keeper_light_armor", "keeper_blinding", true, false)


		caster:SwapAbilities("keeper_amplify_magic", "keeper_roar", true, false)
		caster:RemoveModifierByName("mana_aura")
	end

end
