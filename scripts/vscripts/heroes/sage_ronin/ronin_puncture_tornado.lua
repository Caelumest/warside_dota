LinkLuaModifier("modifier_ronin_puncture_tornado", "heroes/sage_ronin/ronin_puncture_tornado.lua", LUA_MODIFIER_MOTION_NONE)

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
	ability.projDistance = 800
	ability.effectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf"
	ability.projVelocity = 800
	ability.tornadoReady = true
	caster:RemoveModifierByName("modifier_ronin_hit_count")
	caster:SwapAbilities("ronin_puncture", "ronin_puncture_tornado", true, false)
	ability:StartCooldown(self:GetCooldownTimeRemaining())
	ability:SetLevel(self:GetLevel())
    self:SetHidden(true)
    ability:SetHidden(false)
	if not caster:HasModifier("modifier_ronin_dash") then
		caster:AddNewModifier(caster, ability, "modifier_puncture_states", {duration = 0.2})
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 2)
		caster:SetForwardVector((Vector(target.x, target.y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
		Timers:CreateTimer(0.15, function ()  
			if caster:IsAlive() then
				self.projID = ProjectileManager:CreateLinearProjectile( {
			        Ability             = self,
			        EffectName          = ability.effectName,
			        vSpawnOrigin        = caster:GetAbsOrigin(),
			        fDistance           = ability.projDistance,
			        fStartRadius        = 70,
			        fEndRadius          = 70,
			        Source              = caster,
			        bHasFrontalCone     = false,
			        bReplaceExisting    = false,
			        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
			        iUnitTargetType     = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			        fExpireTime         = GameRules:GetGameTime() + 0.9,
			        bDeleteOnHit        = false,
			        vVelocity           = caster:GetForwardVector() * ability.projVelocity,
			        bProvidesVision     = true,
			        iVisionRadius       = 0,
			        iVisionTeamNumber   = caster:GetTeamNumber(),
			    } )
			end
    	end)
	else
		ability.spinInQueue = true
	end
end

function ronin_puncture_tornado:OnProjectileHit(target)
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("ronin_puncture")
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
	EmitSoundOn("Hero_Leshrac.Lightning_Storm", target);
	caster:PerformAttack(target, true, true, true, true, false, false, true)
    if target then
    	local knockbackTable = {
				center_x = target:GetAbsOrigin().x,
				center_y = target:GetAbsOrigin().y,
				center_z = target:GetAbsOrigin().z,
				knockback_duration = 1,
				knockback_distance = 0,
				knockback_height = 400,
				should_stun = 1,
				duration = 1,
			}
		target:RemoveModifierByName("modifier_knockback")
		target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable) 
	end
end

modifier_ronin_puncture_tornado = class({})

function modifier_ronin_puncture_tornado:IsHidden()
	return false
end

function modifier_ronin_puncture_tornado:IsPassive()
	return true
end

function modifier_ronin_puncture_tornado:IsPermanent()
	return true
end

function modifier_ronin_puncture_tornado:OnCreated()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	ability.cooldown = ability:GetSpecialValueFor("cooldown")
	self.interval = 0.01
	self:StartIntervalThink(self.interval)
end

function modifier_ronin_puncture_tornado:OnDestroy()
	local caster = self:GetParent()
	local ability = self:GetAbility()
end

function modifier_ronin_puncture_tornado:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)

	ability.cooldown = ability:GetSpecialValueFor("cooldown") - (caster:GetIncreasedAttackSpeed())

	if caster:HasModifier("modifier_ronin_dash") then
		ability.behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	else
		ability.behavior = DOTA_ABILITY_BEHAVIOR_POINT
	end

	if ability.spinInQueue == true and not caster:HasModifier("modifier_ronin_dash") then
		caster:AddNewModifier(caster, ability, "modifier_puncture_states", {duration = 0.2})
		StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1})
		local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
	    for _,enemy in pairs( units ) do
	        caster:PerformAttack(enemy, true, true, true, true, false, false, true)
	        if target then
		    	local knockbackTable = {
						center_x = target:GetAbsOrigin().x,
						center_y = target:GetAbsOrigin().y,
						center_z = target:GetAbsOrigin().z,
						knockback_duration = 1,
						knockback_distance = 0,
						knockback_height = 400,
						should_stun = 1,
						duration = 1,
					}
				target:RemoveModifierByName("modifier_knockback")
				target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable) 
			end
	    end
		ability.spinInQueue = nil
	end

end