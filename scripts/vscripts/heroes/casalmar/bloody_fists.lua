function OnHit(event)
	local target = event.target
	local caster = event.caster
	local ability = event.ability
	local health_mult = ability:GetSpecialValueFor("health_mult") + (caster:GetTalentValue("special_bonus_casalmar_bloody_fists") / 100)
	local totalDamage = caster:GetMaxHealth() * health_mult
	local finaldamage = {
                        victim = target,
                        attacker = caster,
                        damage = totalDamage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = ability
                    }
    if target:IsTower() == false and target:IsBuilding() == false and target:IsBarracks() == false then
    	ApplyDamage(finaldamage)
    end
    print("TOTAL DAMAGE", totalDamage)
end

function SwapAbilities(event)
	local caster = event.caster
	local ability = caster:FindAbilityByName("bloody_fists")
	local sub_ability = caster:FindAbilityByName("deactivate_bloody_fists")
	if ability:IsHidden() then
		caster:RemoveModifierByName("modifier_bloody_fists")
		caster:SwapAbilities("bloody_fists", "deactivate_bloody_fists", true, false)
	else
		sub_ability:SetLevel(1)
		caster:SwapAbilities("bloody_fists", "deactivate_bloody_fists", false, true)
	end
end

function DrainHealth(event)
	local caster = event.caster
	local ability = event.ability
	local health_mult = ability:GetSpecialValueFor("health_mult") + (caster:GetTalentValue("special_bonus_unique_casalmar_bloody_fists") / 100)
	local totalDamage = (caster:GetMaxHealth() / 10) * health_mult
	local drainedHealth = {
                        victim = caster,
                        attacker = caster,
                        damage = totalDamage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
                        ability = ability
                    }
    ApplyDamage(drainedHealth)
end

function OnDied(event)
	local caster = event.caster
	local ability = caster:FindAbilityByName("bloody_fists")
	if ability:IsHidden() then
		caster:SwapAbilities("bloody_fists", "deactivate_bloody_fists", true, false)
	end
end