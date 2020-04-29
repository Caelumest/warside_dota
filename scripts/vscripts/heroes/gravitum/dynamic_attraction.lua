LinkLuaModifier("modifier_dynamic_attraction_attracted", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dynamic_attraction_knockback", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dynamic_attraction_target", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dynamic_attraction_stacks", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dynamic_attraction_ground_check", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)

gravitum_dynamic_attraction = gravitum_dynamic_attraction or class({})

function gravitum_dynamic_attraction:OnUpgrade()
	local caster = self:GetCaster()
	local ability = self

	if not caster:HasModifier("modifier_dynamic_attraction_stacks") then
		caster:AddNewModifier(caster, ability, "modifier_dynamic_attraction_stacks", {})
	end
end

function gravitum_dynamic_attraction:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT
end

function gravitum_dynamic_attraction:GetCooldown()
	return 1
end

function gravitum_dynamic_attraction:CastFilterResultLocation(location)
	local caster = self:GetCaster()
	local stacks = caster:GetModifierStackCount("modifier_dynamic_attraction_stacks", caster)
	local max_distance = self:GetSpecialValueFor("max_distance")

	if stacks < 3 then
		return UF_FAIL_CUSTOM
	end
	if (self.target1 ~= nil and self.pointLocation ~= nil) or (self.target1 ~= nil and self.target2 ~= nil) then
		return UF_FAIL_CUSTOM
	end
	if self.target1 ~= nil and (location - self.target1:GetAbsOrigin()):Length2D() > max_distance then
		return UF_FAIL_CUSTOM
	end
	if self.pointLocation ~= nil and self.target1 == nil then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function gravitum_dynamic_attraction:CastFilterResultTarget( hTarget )
	local caster = self:GetCaster()
	local stacks = caster:GetModifierStackCount("modifier_dynamic_attraction_stacks", caster)
	local max_distance = self:GetSpecialValueFor("max_distance")
	if caster == hTarget and stacks <= 1 then
		return UF_FAIL_CUSTOM
	end
	if (self.target1 ~= nil and self.pointLocation ~= nil) or (self.target1 ~= nil and self.target2 ~= nil) then
		return UF_FAIL_CUSTOM
	end
	if self.target1 ~= nil and (hTarget:GetAbsOrigin() - self.target1:GetAbsOrigin()):Length2D() > max_distance then
		return UF_FAIL_CUSTOM
	end
	if self.pointLocation ~= nil and (hTarget:GetAbsOrigin() - self.pointLocation):Length2D() > max_distance then
		return UF_FAIL_CUSTOM
	end
	if self.target1 ~= nil and hTarget == self.target1 then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

function gravitum_dynamic_attraction:GetCustomCastErrorLocation(location)
	local ability = self
	local caster = ability:GetCaster()
	local stacks = caster:GetModifierStackCount("modifier_dynamic_attraction_stacks", caster)
	local max_distance = ability:GetSpecialValueFor("max_distance")

	if self.target1 ~= nil and (location - self.target1:GetAbsOrigin()):Length2D() > max_distance then
		return "Above maximum distance"
	end
	if (self.target1 ~= nil and self.pointLocation ~= nil) or (self.target1 ~= nil and self.target2 ~= nil) then
		return "Can't use this ability yet"
	end
	if stacks < 3 then
		return "You need more stacks to cast on ground"
	end
	if self.pointLocation ~= nil and self.target1 == nil then
		return "Need a target"
	end
	return "Error"
end

function gravitum_dynamic_attraction:GetCustomCastErrorTarget( hTarget )
	local ability = self
	local caster = ability:GetCaster()
	local stacks = caster:GetModifierStackCount("modifier_dynamic_attraction_stacks", caster)
	local max_distance = ability:GetSpecialValueFor("max_distance")
	if self.target1 ~= nil and hTarget == self.target1 then
		return "Cant select the same target"
	end
	if (self.target1 ~= nil and self.pointLocation ~= nil) or (self.target1 ~= nil and self.target2 ~= nil) then
		return "Can't use this ability yet"
	end
	if self.target1 ~= nil and (hTarget:GetAbsOrigin() - self.target1:GetAbsOrigin()):Length2D() > max_distance then
		return "Above maximum distance"
	end
	if self.pointLocation ~= nil and (hTarget:GetAbsOrigin() - self.pointLocation):Length2D() > max_distance then
		return "Above maximum distance"
	end
	if caster == hTarget and stacks <= 1 then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "Error"
end

function gravitum_dynamic_attraction:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local location = self:GetCursorPosition()
	local velocity = 5000
	local pull_duration = self:GetSpecialValueFor("pull_duration")
	local pull_delay = self:GetSpecialValueFor("pull_delay")
	local width = self:GetSpecialValueFor("max_width")
	local stacks = caster:GetModifierStackCount("modifier_dynamic_attraction_stacks", caster)

	if ability.pointLocation == nil and target == nil and stacks >= 3 then
		ability.pointLocation = location
		ability:EndCooldown()
		caster:AddNewModifier(caster, ability, "modifier_dynamic_attraction_ground_check", {duration = 3})
		ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_POINT, caster)
    	ParticleManager:SetParticleControl(ability.particle, 0, ability.pointLocation)
    	ParticleManager:SetParticleControl(ability.particle, 1, ability.pointLocation)
	end

	if target ~= nil and ability.target1 == nil then
		ability.target1 = target
		ability.enemyTeam = ability.target1:GetTeam()
		local modif = target:AddNewModifier(caster, ability, "modifier_dynamic_attraction_target", {duration = 3, testtarget = target})
		modif:StartIntervalThink(0.01)
		ability:EndCooldown()
	end

	if target ~= nil and ability.target2 == nil and ability.target1 ~= nil and target ~= ability.target1 and ability.pointLocation == nil then
		ability.target2 = target
		target:AddNewModifier(caster, ability, "modifier_dynamic_attraction_target", {duration = 3})
		if ability.particle == nil and ability.target1 and target ~= ability.target1 then
			local target1 = ability.target1
			local target2 = ability.target2

	    	ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_POINT, target2)
	    	ParticleManager:SetParticleControlEnt(ability.particle, 0, target2, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
	    	ParticleManager:SetParticleControlEnt(ability.particle, 1, target1, PATTACH_POINT_FOLLOW, "attach_hitloc", target1:GetAbsOrigin(), true)

    		target1:RemoveModifierByName("modifier_dynamic_attraction_target")
    		target2:RemoveModifierByName("modifier_dynamic_attraction_target")

	    	target1:AddNewModifier(caster, ability, "modifier_dynamic_attraction_knockback", {duration = pull_delay + 0.1})

	    	modifier = target2:AddNewModifier(caster, ability, "modifier_dynamic_attraction_knockback", {duration = pull_delay + 0.1})
	    	modifier:StartIntervalThink(0.01)
	    	target1:EmitSoundParams("Hero_Rubick.Telekinesis.Target",1,0.5,0)
	    	target2:EmitSoundParams("Hero_Rubick.Telekinesis.Target",1,0.5,0)
	    	Timers:CreateTimer(pull_delay, function () 
		    	if target1 ~= target then
		    		if target1 and target2 and target1:HasModifier("modifier_dynamic_attraction_knockback") and target2:HasModifier("modifier_dynamic_attraction_knockback") then
			    		if(target2:IsAlive())then
			    			if(caster:GetTeamNumber() ~= target2:GetTeamNumber()) then
								local unit_location = target2:GetAbsOrigin()
						        local vector_distance = target1:GetAbsOrigin() - unit_location
						        local distance = (vector_distance):Length2D()/GetRangeDivisor(target1:GetTeamNumber(), caster:GetTeamNumber())
						        local direction = (vector_distance):Normalized()
								local knockbackTable = {
										center_x = (unit_location.x + -direction.x) ,
										center_y = (unit_location.y + -direction.y) ,
										center_z = target2:GetAbsOrigin().z,
										knockback_duration = pull_duration,
										knockback_distance = distance,
										knockback_height = 100,
										should_stun = 1,
										duration = pull_duration,
									}
								target2:RemoveModifierByName("modifier_knockback")
								target2:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
							end
							local modif = target2:AddNewModifier(caster, ability, "modifier_dynamic_attraction_attracted", {duration = pull_duration, testtarget = target1:GetUnitName()})
							modif:StartIntervalThink(0.01)
						end
						if(target1:IsAlive())then
							if(caster:GetTeamNumber() ~= target1:GetTeamNumber()) then
								local unit_location = target1:GetAbsOrigin()
						        local vector_distance = target2:GetAbsOrigin() - unit_location
						        local distance = (vector_distance):Length2D()/GetRangeDivisor(target2:GetTeamNumber(), caster:GetTeamNumber())
						        local direction = (vector_distance):Normalized()
								local knockbackTable = {
										center_x = (unit_location.x + -direction.x) ,
										center_y = (unit_location.y + -direction.y) ,
										center_z = target1:GetAbsOrigin().z,
										knockback_duration = pull_duration,
										knockback_distance = distance,
										knockback_height = 100,
										should_stun = 1,
										duration = pull_duration,
									}
								target1:RemoveModifierByName("modifier_knockback")
								target1:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
							end
							local modif = target1:AddNewModifier(caster, ability, "modifier_dynamic_attraction_attracted", {duration = pull_duration, testtarget = target1:GetUnitName()})
							modif:StartIntervalThink(0.01)
						end
						ParticleManager:DestroyParticle(ability.particle, false)
						target1:RemoveModifierByName("modifier_dynamic_attraction_target")
						target2:RemoveModifierByName("modifier_dynamic_attraction_target")
			    	end
			    end
		    end)
		end
	elseif ability.target1 ~= nil and ability.target2 == nil and ability.pointLocation ~= nil then
		local target1 = ability.target1
		target1:EmitSoundParams("Hero_Rubick.Telekinesis.Target",1,0.5,0)
		caster:RemoveModifierByName("modifier_dynamic_attraction_ground_check")
		if ability.particle == nil then
			ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_POINT, target1)
	    	ParticleManager:SetParticleControl(ability.particle, 0, ability.pointLocation)
	    	ParticleManager:SetParticleControlEnt(ability.particle, 1, target1, PATTACH_POINT_FOLLOW, "attach_hitloc", target1:GetAbsOrigin(), true)
	    else
	    	ParticleManager:SetParticleControlEnt(ability.particle, 1, target1, PATTACH_POINT_FOLLOW, "attach_hitloc", target1:GetAbsOrigin(), true)
	    end
    	target1:RemoveModifierByName("modifier_dynamic_attraction_target")
    	local modifier = target1:AddNewModifier(caster, ability, "modifier_dynamic_attraction_knockback", {duration = pull_delay+ 0.1})
    	modifier:StartIntervalThink(0.01)
    	Timers:CreateTimer(pull_delay, function () 
			if target1 ~= nil and ability.pointLocation ~= nil and target1:HasModifier("modifier_dynamic_attraction_knockback") then
		        local vector_distance = target1:GetAbsOrigin() - ability.pointLocation
		        local distance = (vector_distance):Length2D()
		        local direction = (vector_distance):Normalized()
		        local unit_location = target1:GetAbsOrigin()
				local knockbackTable = {
						center_x = (unit_location.x + direction.x) ,
						center_y = (unit_location.y + direction.y) ,
						center_z = ability.pointLocation.z,
						knockback_duration = pull_duration,
						knockback_distance = distance,
						knockback_height = 100,
						should_stun = 1,
						duration = pull_duration,
					}
				target1:RemoveModifierByName("modifier_knockback")
				target1:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
				
				local modif = target1:AddNewModifier(caster, ability, "modifier_dynamic_attraction_attracted", {duration = pull_duration})
				modif:StartIntervalThink(0.01)
			end
			ParticleManager:DestroyParticle(ability.particle, false)
			target1:RemoveModifierByName("modifier_dynamic_attraction_target")
		end)
	end
end

function GetRangeDivisor(unitTeam, casterTeam)
	print(unitTeam, casterTeam)
	if unitTeam == casterTeam then
		return 1
	else
		return 2
	end
end

modifier_dynamic_attraction_attracted = class({})

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function modifier_dynamic_attraction_attracted:OnCreated()

end

function modifier_dynamic_attraction_attracted:IsHidden()
	return false
end

function modifier_dynamic_attraction_attracted:IsPassive()
	return false
end

function modifier_dynamic_attraction_attracted:IsPermanent()
	return false
end

function modifier_dynamic_attraction_attracted:OnDestroy()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	if target == ability.target1 then
		ability.target1 = nil
	elseif target == ability.target2 then
		ability.target2 = nil
	end
	if ability.particle and ability.destroyParticle == nil then
		ParticleManager:DestroyParticle(ability.particle, false)
	end
	ability.particle = nil
	ability.pointLocation = nil

end

function modifier_dynamic_attraction_attracted:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local sub_duration = ability:GetSpecialValueFor("sub_knockback_dur")
	local sub_damage = ability:GetSpecialValueFor("sub_damage")
	if parent then
		local origin = parent:GetOrigin()
    	local units = FindUnitsInRadius( ability.enemyTeam, origin, nil, 150, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
	    for _,target in pairs( units ) do
	    	if target and target ~= parent and not target:HasModifier("modifier_dynamic_attraction_knockback") and target ~= ability.target1 and target ~= ability.target2 and target:GetTeamNumber() ~= caster:GetTeamNumber() then

	    		local vector_distance = parent:GetAbsOrigin() - target:GetAbsOrigin()
		        local direction = (vector_distance):Normalized()

		 		local knockbackTable = {
					center_x = (parent:GetAbsOrigin().x + direction.x) ,
					center_y = (parent:GetAbsOrigin().y + direction.y) ,
					center_z = target:GetAbsOrigin().z,
					knockback_duration = sub_duration,
					knockback_distance = 250,
					knockback_height = 100,
					should_stun = 0,
					duration = sub_duration,
				}
				target:AddNewModifier(caster, ability, "modifier_dynamic_attraction_knockback", {duration = sub_duration})
				target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())

				EmitSoundOn("Hero_Spirit_Breaker.GreaterBash.Creep", target)

				ApplyDamage({victim = target, attacker = caster, damage = sub_damage, damage_type = DAMAGE_TYPE_MAGICAL})
		 	end
	    end

	    if ability.pointLocation ~= nil then
	    	Timers:CreateTimer(0.5, function () 
	    	StopSoundOn("Hero_Rubick.Telekinesis.Target", ability.target1)
	    	ability.pointLocation = nil
	    	end)
	    end

	    if ability.target1 and ability.target1:HasModifier("modifier_dynamic_attraction_attracted") and ability.target1 ~= parent and
	    	parent:HasModifier("modifier_dynamic_attraction_attracted") and ability.target1:GetRangeToUnit(parent) <= 100 then

	    	if ability.target1:IsAlive() and ability.target2:IsAlive() then
				local stacks = caster:GetModifierStackCount("modifier_dynamic_attraction_stacks", caster)
				caster:SetModifierStackCount("modifier_dynamic_attraction_stacks", caster, stacks+1)
				caster.attraction_stacks = caster:GetModifierStackCount("modifier_dynamic_attraction_stacks", caster)
			end
			StopSoundOn("Hero_Rubick.Telekinesis.Target", ability.target1)
			StopSoundOn("Hero_Rubick.Telekinesis.Target", ability.target2)
	    	ShockTarget(ability.target1, caster, ability)
	    	ShockTarget(ability.target2, caster, ability)

			ability.target1:EmitSoundParams("Hero_Spirit_Breaker.GreaterBash",1,0.8,0)
			ability.target2:EmitSoundParams("Hero_Spirit_Breaker.GreaterBash",1,0.8,0)

	    	ability.target1:RemoveModifierByName("modifier_dynamic_attraction_attracted")
	    	ability.target2:RemoveModifierByName("modifier_dynamic_attraction_attracted")
	    	

			if ability.particle and ability.destroyParticle == nil then
				ParticleManager:DestroyParticle(ability.particle, false)
			end

			ability.target1 = nil
			ability.target2 = nil
		end
	end
end

function ShockTarget(target, caster, ability)
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		local shock_stun = ability:GetSpecialValueFor("stun_duration")
		local shock_damage = ability:GetSpecialValueFor("shock_damage")
		local vector_distance = ability.target1:GetAbsOrigin() - ability.target2:GetAbsOrigin()
	    local direction = ability.target1:GetAbsOrigin() - (vector_distance):Normalized()

		local knockbackTable = {
			center_x = direction.x ,
			center_y = direction.y,
			center_z = target:GetAbsOrigin().z,
			knockback_duration = 0.5,
			knockback_distance = 50,
			knockback_height = 100,
			should_stun = 1,
			duration = 0.5,
		}

		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = shock_stun})

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())

		target:InterruptMotionControllers(true)

		target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)

		ApplyDamage({victim = target, attacker = caster, damage = shock_damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

modifier_dynamic_attraction_target = class({})

function modifier_dynamic_attraction_target:IsHidden() return false end
function modifier_dynamic_attraction_target:IsDebuff() return false end
function modifier_dynamic_attraction_target:IsPurgable() return false end
function modifier_dynamic_attraction_target:OnDestroy(table)
	local ability = self:GetAbility()
	if ability.target1 ~= nil and ability.target2 == nil then
		ability.target1 = nil
		print("D AO CU ASASA")
	end
end

modifier_dynamic_attraction_knockback = class({})

function modifier_dynamic_attraction_knockback:IsHidden() return false end
function modifier_dynamic_attraction_knockback:IsDebuff() return false end
function modifier_dynamic_attraction_knockback:IsPurgable() return false end

function modifier_dynamic_attraction_knockback:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	local max_distance = ability:GetSpecialValueFor("max_distance")
	if ability.target1 ~= nil and ability.target2 ~= nil then

		local vector_distance = nil

		if ability.target1 ~= nil and ability.target2 ~= nil then
			vector_distance = ability.target2:GetAbsOrigin() - ability.target1:GetAbsOrigin()
		elseif ability.target1 ~= nil and ability.pointLocation ~= nil then
			vector_distance = ability.pointLocation - ability.target1:GetAbsOrigin()
		else
			return false
		end

    	local direction = (vector_distance):Normalized()
    	local distance = (vector_distance):Length2D()

    	if ability.pointLocation and ability.target1 and ability.target2 == nil and (distance > max_distance or not ability.target1:IsAlive()) then
    		local target1 = ability.target1
    		ParticleManager:DestroyParticle(ability.particle, false)
    		target1:RemoveModifierByName("modifier_dynamic_attraction_knockback")
			target1:RemoveModifierByName("modifier_dynamic_attraction_target")
			ability.target1 = nil
			ability.target2 = nil
			ability.particle = nil
    	end

    	if ability.pointLocation == nil and ability.target1 and ability.target2 and (distance > max_distance or not ability.target1:IsAlive() or not ability.target2:IsAlive()) then
    		local target1 = ability.target1
    		local target2 = ability.target2
    		ParticleManager:DestroyParticle(ability.particle, false)
    		target1:RemoveModifierByName("modifier_dynamic_attraction_knockback")
    		target2:RemoveModifierByName("modifier_dynamic_attraction_knockback")
			target1:RemoveModifierByName("modifier_dynamic_attraction_target")
			target2:RemoveModifierByName("modifier_dynamic_attraction_target")
			ability.target1 = nil
			ability.target2 = nil
			ability.particle = nil
    	end
	end
end

modifier_dynamic_attraction_stacks = class({})

function modifier_dynamic_attraction_stacks:IsHidden() return false end
function modifier_dynamic_attraction_stacks:IsDebuff() return false end
function modifier_dynamic_attraction_stacks:IsPurgable() return false end
function modifier_dynamic_attraction_stacks:IsPermanent() return true end

function modifier_dynamic_attraction_stacks:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

modifier_dynamic_attraction_dummy = class({})

function modifier_dynamic_attraction_dummy:IsHidden() return true end
function modifier_dynamic_attraction_dummy:IsDebuff() return false end
function modifier_dynamic_attraction_dummy:IsPurgable() return false end
function modifier_dynamic_attraction_dummy:IsPermanent() return true end
function modifier_dynamic_attraction_dummy:CheckState()
	local state = 
	{
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = false,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}

	return state
end

modifier_dynamic_attraction_ground_check = class({})

function modifier_dynamic_attraction_ground_check:IsHidden() return true end
function modifier_dynamic_attraction_ground_check:IsDebuff() return false end
function modifier_dynamic_attraction_ground_check:IsPurgable() return false end
function modifier_dynamic_attraction_ground_check:IsPermanent() return true end
function modifier_dynamic_attraction_ground_check:OnDestroy()
	local ability = self:GetAbility()
	if ability.pointLocation ~= nil and ability.target1 == nil then
		ability.pointLocation = nil
		ParticleManager:DestroyParticle(ability.particle, false)
		ability.particle = nil
	end
end