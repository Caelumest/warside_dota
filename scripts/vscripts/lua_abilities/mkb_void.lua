function MkbVoid( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local talent = caster:FindAbilityByName("special_bonus_unique_mk_2")
	if talent:GetLevel() > 0 then
        mana_talent = talent:GetSpecialValueFor("value")
    else
        mana_talent = 0
    end
	local damagePerMana = ability:GetLevelSpecialValueFor("mana_void_damage_per_mana", (ability:GetLevel() - 1)) + mana_talent
	local finaldamage = {
                        victim = target,
                        attacker = caster,
                        damage = (target:GetMaxMana() - target:GetMana())*damagePerMana,
                        damage_type = ability:GetAbilityDamageType(),
                        ability = ability
                    }
	-- Damage calculation depending on the missing mana
	ApplyDamage(finaldamage)
end