LinkLuaModifier("modifier_ronin_puncture_tornado", "heroes/sage_ronin/ronin_puncture_tornado.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ronin_puncture_tornado", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy_projectile_sound", "modifiers/modifier_dummy_projectile_sound.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tornado_on_hit", "heroes/sage_ronin/ronin_puncture_tornado.lua", LUA_MODIFIER_MOTION_NONE)

ronin_puncture_tornado = ronin_puncture_tornado or class({})

function ronin_puncture_tornado:OnUpgrade()
	local caster = self:GetCaster()
	local ability = self
	caster:AddNewModifier(caster, self, "modifier_ronin_puncture", {})
end

function ronin_puncture_tornado:GetBehavior()
	local caster = self:GetCaster()
	local ability = self
	if caster:HasModifier("modifier_ronin_dash") then
		ability.behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	else
		ability.behavior = DOTA_ABILITY_BEHAVIOR_POINT
	end
	return ability.behavior
end

function ronin_puncture_tornado:GetCooldown()
	local caster = self:GetCaster()
	local ability = self
	if not ability.cooldown then
		return ability:GetSpecialValueFor("cooldown")
	elseif ability.cooldown <= 1.5 then
		return 1.5
	else
		return ability.cooldown
	end
end

function ronin_puncture_tornado:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local ability = caster:FindAbilityByName("ronin_puncture")
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
	ability.spinTornado = true
	ability.projDistance = 900
	ability.effectName = "particles/econ/items/invoker/invoker_ti6/invoker_tornado_ti6.vpcf"
	ability.projVelocity = 800
	ability.tornadoReady = true
	local tornado_duration = ability.projDistance / ability.projVelocity
	caster:RemoveModifierByName("modifier_ronin_hit_count")
	caster:SetAggressive()
	caster:RemoveModifierByName("modifier_ronin_puncture_tornado")
	if not caster:HasModifier("modifier_ronin_dash") then
		caster:AddNewModifier(caster, ability, "modifier_puncture_states", {duration = 0.2})
		EmitSoundOn("sage_ronin_puncture_third_hit", caster)
		RemoveAnimationTranslate(caster)
		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.5})
		if caster.cancelPuncture or caster.puncture == false then caster.cancelPuncture = nil end
		caster.cancelPuncture = true
		caster.punctureCancelTime = GameRules:GetGameTime() + 0.35
		caster.isIdle = true
		caster:SetForwardVector((Vector(target.x, target.y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
		Timers:CreateTimer(0.15, function ()  
			if caster:IsAlive() then
				self.projID = ProjectileManager:CreateLinearProjectile( {
			        Ability             = self,
			        EffectName          = ability.effectName,
			        vSpawnOrigin        = caster:GetAbsOrigin(),
			        fDistance           = ability.projDistance,
			        fStartRadius        = 90,
			        fEndRadius          = 90,
			        Source              = caster,
			        bHasFrontalCone     = false,
			        bReplaceExisting    = false,
			        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
			        iUnitTargetType     = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			        fExpireTime         = GameRules:GetGameTime() + tornado_duration,
			        bDeleteOnHit        = false,
			        vVelocity           = caster:GetForwardVector() * ability.projVelocity,
			        bProvidesVision     = true,
			        iVisionRadius       = 0,
			        iVisionTeamNumber   = caster:GetTeamNumber(),
			    } )
				target.z = 0
				local caster_point = caster:GetAbsOrigin()
				caster_point.z = 0
				local velocity = caster:GetForwardVector() * ability.projVelocity
				local point_difference_normalized = (target - caster_point):Normalized()
				local tornado_velocity_per_frame = velocity * 0.05
				local tornado_dummy_unit = CreateUnitByName("npc_dota_creature_spirit_vessel", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
				tornado_dummy_unit.velocity_per_frame = velocity * 0.05
				local soundModif = tornado_dummy_unit:AddNewModifier(caster, ability, "modifier_dummy_projectile_sound", {duration = tornado_duration, distance = ability.projDistance, velocity_per_frame = tornado_velocity_per_frame, frames = 0.05})
				soundModif:StartIntervalThink(0.05) 
				EmitSoundOn("Hero_Ronin.Puncture_Tornado_Projectile", tornado_dummy_unit);
			end
    	end)
	else
		ability.spinInQueue = true
		--ability:EndCooldown()
	end
end

function ronin_puncture_tornado:OnProjectileHit(target)
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("ronin_puncture")
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
	EmitSoundOn("Hero_Ronin.Puncture_Tornado_Hit", target);
	caster:AddNewModifier(caster, ability, "modifier_tornado_on_hit", {duration = 0.01})
	caster:PerformAttack(target, true, true, true, true, false, false, true)
    if target then
    	local knockbackTable = {
				center_x = target:GetAbsOrigin().x,
				center_y = target:GetAbsOrigin().y,
				center_z = target:GetAbsOrigin().z,
				knockback_duration = ability:GetSpecialValueFor("tornado_stun_duration"),
				knockback_distance = 0,
				knockback_height = 300,
				should_stun = 1,
				duration = 1,
			}
		target:RemoveModifierByName("modifier_knockback")
		target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable) 
	end
end

modifier_tornado_on_hit = class({})

function modifier_tornado_on_hit:IsHidden()
	return false
end

function modifier_tornado_on_hit:IsPassive()
	return false
end

function modifier_tornado_on_hit:IsPermanent()
	return false
end

function modifier_tornado_on_hit:DeclareFunctions()
    return {MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
			MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_tornado_on_hit:GetModifierBaseAttack_BonusDamage()
	local caster = self:GetCaster()
	local bonusDmg = self:GetAbility():GetSpecialValueFor("bonus_damage")
	return bonusDmg + caster:GetTalentValue("special_bonus_unique_sage_ronin_1")
end

function modifier_tornado_on_hit:GetAttackSound()
	return "None"
end

function modifier_tornado_on_hit:GetModifierPreAttack_CriticalStrike()
	local caster = self:GetCaster()
	if caster:HasScepter() then
		return self:GetAbility():GetSpecialValueFor("crit_bonus_scepter")
	else
		return 0
	end
end