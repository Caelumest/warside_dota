function CheckHealth(event)
	caster = event.caster
	ability = event.ability
	local radius = ability:GetSpecialValueFor("radius")
	mistCircle = {}
	totalDamage = 0
	particle_numbers = 3
    for i=0, particle_numbers do
    	mistCircle[i] = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_riki/riki_tricks_ring_glow_move.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeam())
    	ParticleManager:SetParticleControl(mistCircle[i],0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z))
   	 	ParticleManager:SetParticleControl(mistCircle[i],1,Vector(radius + 50,1,0))
	end
end

function OnTakeDamage(event)
	target = event.attacker
	local dmg = event.Damage
	local health = caster:GetHealth()
	if dmg > health then
		dmg = health
	end
	print("STARG", startingHealth)
	ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	totalDamage = totalDamage + dmg
	print("totalDamage", totalDamage, "CT", caster:GetTeam(), "ET", target:GetTeam())
end

function CheckArea(event)
	local radius = ability:GetSpecialValueFor("radius")
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false )
	for _,enemy in pairs( units ) do
		if caster:GetRangeToUnit(enemy) <= radius  and enemy ~= caster and enemy:IsMagicImmune() == false then
    		ability:ApplyDataDrivenModifier(caster, enemy, "modifier_damage_mark", {})
    	else
    		enemy:RemoveModifierByName("modifier_damage_mark")
    	end
	end
end

function OnEnd(event)
	local radius = ability:GetSpecialValueFor("radius")
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false )
	for _,enemy in pairs( units ) do
		if caster:GetRangeToUnit(enemy) <= radius  and enemy ~= caster and enemy:HasModifier("modifier_damage_mark") and enemy:IsMagicImmune() == false then
			if totalDamage > 0 then
				local damage_returned = ability:GetSpecialValueFor("damage_returned")

				totalDamage = totalDamage * damage_returned

				print("TOTAL", totalDamage)

				if enemy:IsCreep() then
					totalDamage = totalDamage * 2
				end
				ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
				EmitSoundOn("Hero_Oracle.FalsePromise.Damaged", enemy)
				local finaldamage = {
					                        victim = enemy,
					                        attacker = caster,
					                        damage = totalDamage,
					                        damage_type = DAMAGE_TYPE_MAGICAL,
					                        ability = ability
					                    }
	        	ApplyDamage(finaldamage)
        	end
        	enemy:RemoveModifierByName("modifier_damage_mark")
		end
	end
	for i=0, particle_numbers do
		ParticleManager:DestroyParticle(mistCircle[i], false)
	end
end
