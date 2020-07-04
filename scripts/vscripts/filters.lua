Filters = class({})

function Filters:TrackingProjectileFilter(event)
	-- PrintTable(event)
	local dodgeable = event.dodgeable
	local ability = event.entindex_ability_const and EntIndexToHScript(event.entindex_ability_const)
	local attackerUnit = event.entindex_source_const and EntIndexToHScript(event.entindex_source_const)
	local targetUnit = event.entindex_target_const and EntIndexToHScript(event.entindex_target_const)
	local expireTime = event.expire_time
	local isAttack = (1==event.is_attack)
	local maxImpactTime = event.max_impact_time
	local moveSpeed = event.move_speed -- can not get modified with local
	-- --  example
		-- event.move_speed = moveSpeed*RandomFloat(0,2)
	local attacker = EntIndexToHScript(event["entindex_source_const"])
	local target_unit = EntIndexToHScript(event["entindex_target_const"])
	
	if _G.WIND_WALL_TEAM ~= nil and attacker:GetTeamNumber() ~= target_unit:GetTeamNumber() and target_unit:GetUnitName() ~= "npc_dota_creature_spirit_vessel" then
		local units = FindUnitsInLine(attacker:GetTeamNumber(), attacker:GetAbsOrigin(), target_unit:GetAbsOrigin(), nil, 10, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

		for _,target in pairs( units ) do
			if target:GetUnitName() == "npc_dota_creature_spirit_vessel" and target:HasModifier("modifier_wind_wall_dummy") and _G.TestHit <= 0 and attacker:GetTeamNumber() ~= target:GetTeamNumber() then
				if isAttack then
					attacker:PerformAttack(target, true, true, true, false, true, false, false)
					local distance = (attacker:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
					Timers:CreateTimer(distance/moveSpeed -0.1, function() 
						local wall_particle = ParticleManager:CreateParticle("particles/ronin_wind_wall_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
						ParticleManager:SetParticleControl(wall_particle, 0, target:GetAbsOrigin())
						EmitSoundOn("Hero_Ronin.Wind_Wall_Hitted", target)
					end)
				--elseif ability then
				--	ability:EndCooldown()
				--	attacker:CastAbilityOnTarget(target, ability, attacker:GetPlayerID())
					return false
				end
			end
		end
	end
	return true
end