LinkLuaModifier("modifier_gravitum_orb", "heroes/gravitum/gravity_rift.lua", LUA_MODIFIER_MOTION_NONE)
gravitum_gravity_rift = gravitum_gravity_rift or class({})

function gravitum_gravity_rift:OnUpgrade()
	local caster = self:GetCaster()
	local ability = self
end

function gravitum_gravity_rift:GetBehavior()
	local caster = self:GetCaster()
	return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT
end

function gravitum_gravity_rift:GetCooldown()
	return 0
end

function gravitum_gravity_rift:GetCastPoint()
	return 1.5
end

function gravitum_gravity_rift:GetAOERadius()
	return self:GetSpecialValueFor("aoe")
end

function gravitum_gravity_rift:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local mousePos = self:GetCursorPosition()
	local direction = (Vector(mousePos.x, mousePos.y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized()
	StartAnimation(caster, {duration=1.5, activity=ACT_DOTA_CHANNEL_STATUE, rate=1.5})
	self:GetCaster():EmitSoundParams("Hero_Invoker.EMP.Charge",1,0.2,0)
	self.startParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_singularity.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(self.startParticle, 0, caster:GetAbsOrigin() + direction * 150)
    ParticleManager:SetParticleControl(self.startParticle, 1, caster:GetAbsOrigin() + direction * 150)
    Timers:CreateTimer(1.2, function ()
    	if self.stopped == nil or self.stopped == false then
    		EndAnimation(caster)
    		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.0})
    	end
    	self.stopped = false
    	end)
    return true
end

function gravitum_gravity_rift:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle(self.startParticle, false)
	StopSoundOn("Hero_Invoker.EMP.Charge", self:GetCaster())
	self:GetCaster():EmitSoundParams("Hero_VoidSpirit.Dissimilate.TeleportIn",1,0.3,0)
	EndAnimation(self:GetCaster())
	AddAnimationTranslate(self:GetCaster(), "jog")
	self.stopped = true
end

function gravitum_gravity_rift:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local distance = self:GetSpecialValueFor("distance")
	local air_duration = self:GetSpecialValueFor("air_duration")
	local mousePos = self:GetCursorPosition()
	EndAnimation(caster)
	StartAnimation(caster, {duration=0.22, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=1})
	caster:SetAbsOrigin(caster:GetAbsOrigin() + caster:GetForwardVector() * 150)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	AddAnimationTranslate(caster, "jog")
	ability.casterTeam = caster:GetTeam() 
	local vector_distance = caster:GetAbsOrigin() - mousePos
    local distance = (vector_distance):Length2D()
    local direction = caster:GetAbsOrigin() + (vector_distance):Normalized()
    local orb_unit = CreateUnitByName("npc_dota_creature_spirit_vessel", caster:GetAbsOrigin() + caster:GetForwardVector() * 150, false, caster, caster, caster:GetTeam())
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_void_bubble_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, orb_unit)
    self.orb_unit = orb_unit
    ParticleManager:SetParticleControlEnt(particle, 0, orb_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", orb_unit:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, orb_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", orb_unit:GetAbsOrigin(), true)
    ParticleManager:DestroyParticle(self.startParticle, false)
    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_warp_travel.vpcf", PATTACH_ABSORIGIN_FOLLOW, orb_unit)
    ParticleManager:SetParticleControlEnt(particle2, 0, orb_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", orb_unit:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle2, 1, orb_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", orb_unit:GetAbsOrigin(), true)
    local knockbackTable = {
			center_x = direction.x ,
			center_y = direction.y,
			center_z = orb_unit:GetAbsOrigin().z,
			knockback_duration = air_duration,
			knockback_distance = distance,
			knockback_height = 400,
			should_stun = 0,
			duration = air_duration,
		}
	orb_unit:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
	orb_unit:AddNewModifier(caster, ability, "modifier_gravitum_orb", {duration = air_duration * 3})
	StopSoundOn("Hero_Invoker.EMP.Charge", self:GetCaster())
	orb_unit:EmitSoundParams("Hero_Invoker.EMP.Discharge",1,0.5,0)
	caster:EmitSoundParams("Hero_VoidSpirit.Dissimilate.TeleportIn",1,0.5,0)
	orb_unit:EmitSoundParams("Hero_Lich.ChainFrostLoop",1,1,0)
	Timers:CreateTimer(air_duration, function ()
		StopSoundOn("Hero_Lich.ChainFrostLoop", orb_unit)
		ParticleManager:DestroyParticle(particle, false)
		--ParticleManager:DestroyParticle(particle2, false)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf", PATTACH_CUSTOMORIGIN, orb_unit)
    	ParticleManager:SetParticleControl(particle, 0, orb_unit:GetAbsOrigin())
    	ParticleManager:SetParticleControl(particle, 1, Vector(ability:GetSpecialValueFor("aoe")-100,0,0))
    	orb_unit:EmitSoundParams("Hero_VoidSpirit.Dissimilate.TeleportIn",1,1.2,0)
    	EmitSoundOn("Hero_VoidSpirit.Dissimilate.Stun", orb_unit)
    	local units = FindUnitsInRadius(ability.casterTeam, orb_unit:GetAbsOrigin(), nil, ability:GetSpecialValueFor("aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
    	for _,target in pairs( units ) do
    		ApplyDamage({victim = target, attacker = caster, damage = 500, damage_type = DAMAGE_TYPE_MAGICAL})
    	end

    	local knockbackTable = {
			center_x = orb_unit:GetAbsOrigin().x,
			center_y = orb_unit:GetAbsOrigin().y,
			center_z = orb_unit:GetAbsOrigin().z,
			knockback_duration = air_duration,
			knockback_distance = 0,
			knockback_height = 400,
			should_stun = 0,
			duration = air_duration,
		}
		orb_unit:InterruptMotionControllers(true)
		orb_unit:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
		EmitSoundOn("Hero_VoidSpirit.Dissimilate.TeleportIn", self:GetCaster())
		orb_unit:EmitSoundParams("Hero_Lich.ChainFrostLoop",1,1,0)
		if 1==1 then
			Timers:CreateTimer(air_duration, function ()	
				StopSoundOn("Hero_Lich.ChainFrostLoop", orb_unit)
				ParticleManager:DestroyParticle(particle2, false)
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf", PATTACH_CUSTOMORIGIN, orb_unit)
		    	ParticleManager:SetParticleControl(particle, 0, orb_unit:GetAbsOrigin())
		    	ParticleManager:SetParticleControl(particle, 1, Vector(ability:GetSpecialValueFor("aoe")-100,0,0))
		    	orb_unit:EmitSoundParams("Hero_VoidSpirit.Dissimilate.TeleportIn",1,1.2,0)
		    	EmitSoundOn("Hero_VoidSpirit.Dissimilate.Stun", orb_unit)
		    	local units = FindUnitsInRadius(ability.casterTeam, orb_unit:GetAbsOrigin(), nil, ability:GetSpecialValueFor("aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
		    	for _,target in pairs( units ) do
		    		ApplyDamage({victim = target, attacker = caster, damage = 500, damage_type = DAMAGE_TYPE_MAGICAL})
		    	end
		    	orb_unit:ForceKill(false)
			end)
		else
			orb_unit:ForceKill(false)
		end
	end)
end

modifier_gravitum_orb = class({})

function modifier_gravitum_orb:IsHidden() return true end
function modifier_gravitum_orb:IsDebuff() return false end
function modifier_gravitum_orb:IsPurgable() return false end
function modifier_gravitum_orb:OnCreated() self:StartIntervalThink(0.01) end
function modifier_gravitum_orb:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if ability.casterTeam then
		local dmg = ability:GetSpecialValueFor("shock_damage")
		local units = FindUnitsInRadius(ability.casterTeam, self:GetParent():GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
		for _,target in pairs( units ) do
			if target then

				if not target.gravitum_orb_interval then
					target.gravitum_orb_interval = GameRules:GetGameTime()
				end

				if target.gravitum_orb_interval and target.gravitum_orb_interval <= GameRules:GetGameTime() then
					local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_singularity_lightning_thick_child.vpcf", PATTACH_CUSTOMORIGIN, caster)
		    		ParticleManager:SetParticleControl(particle, 0, ability.orb_unit:GetAbsOrigin())
		    		ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
		    		local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_singularity_lightning_large_child.vpcf", PATTACH_CUSTOMORIGIN, caster)
		    		ParticleManager:SetParticleControl(particle3, 0, ability.orb_unit:GetAbsOrigin())
		    		ParticleManager:SetParticleControl(particle3, 1, target:GetAbsOrigin())
		    		local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_singularity_electricity.vpcf", PATTACH_CUSTOMORIGIN, caster)
		    		ParticleManager:SetParticleControl(particle2, 0, target:GetAbsOrigin())
					ApplyDamage({victim = target, attacker = caster, damage = dmg	, damage_type = DAMAGE_TYPE_MAGICAL})
					EmitSoundOn("Hero_Razor.UnstableCurrent.Target", target)
					target.gravitum_orb_interval = GameRules:GetGameTime() + 1
				end
			end
		end
	end
end
function modifier_gravitum_orb:CheckState()
	local state = 
	{
		[MODIFIER_STATE_COMMAND_RESTRICTED] = false,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}

	return state
end
