LinkLuaModifier("modifier_ronin_puncture", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_puncture_states", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ronin_hit_count", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)

ronin_puncture = ronin_puncture or class({})

function ronin_puncture:OnUpgrade()
	local caster = self:GetCaster()
	local ability = self
	caster:AddNewModifier(caster, self, "modifier_ronin_puncture", {})
end

function ronin_puncture:GetBehavior()
	local caster = self:GetCaster()
	return self.behavior
end

function ronin_puncture:GetCooldown()
	if not self.cooldown then
		return self:GetSpecialValueFor("cooldown")
	elseif self.cooldown <= 1.5 then
		return 1.5
	else
		return self.cooldown
	end
end

function ronin_puncture:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	self.subability = caster:FindAbilityByName("ronin_puncture_tornado")
	self.hittedOne = nil
	local ability = self
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
	if stacks < 2 then
		ability.projDistance = 220
		ability.effectName = nil
		ability.projVelocity = 99999
		ability.tornadoReady = nil
	else
		ability.projDistance = 800
		ability.effectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf"
		ability.projVelocity = 800
		ability.tornadoReady = true
		caster:RemoveModifierByName("modifier_ronin_hit_count")
	end
	if self.subability:IsHidden() then
		ability.spinTornado = nil
	end
	Timers:CreateTimer(1.15, function () ability.tornadoReady = nil end)
	if not caster:HasModifier("modifier_ronin_dash") then
		caster:AddNewModifier(caster, self, "modifier_puncture_states", {duration = 0.2})
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
			    if stacks == 2 then
					ability.currentProj = ability.projID
					print("currentfoi")
				end
			end
    	end)
	else
		self.spinInQueue = true
	end
end

function ronin_puncture:OnProjectileHit(target)
	local caster = self:GetCaster()
	local ability = self
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
	EmitSoundOn("Hero_Leshrac.Lightning_Storm", target);
	caster:PerformAttack(target, true, true, true, true, false, false, true)
	if self.hittedOne == nil and stacks < 1 and target then
		caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = 5})
        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 1)
        self.hittedOne = true
    elseif self.hittedOne == nil and stacks >= 1 and target then
		caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = 5})
        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 2)
        self.hittedOne = true
    	caster:SwapAbilities("ronin_puncture", "ronin_puncture_tornado", false, true)
    	self.subability:SetLevel(self:GetLevel())
    	self.subability:StartCooldown(ability:GetCooldownTimeRemaining())
    	ability:SetHidden(true)
    	self.subability:SetHidden(false)
    	caster:RemoveModifierByName("modifier_ronin_hit_count")
    end
end


modifier_ronin_hit_count = class({})

function modifier_ronin_hit_count:IsHidden()
	return false
end

function modifier_ronin_hit_count:IsPassive()
	return false
end

function modifier_ronin_hit_count:IsPermanent()
	return false
end

modifier_ronin_puncture = class({})

function modifier_ronin_puncture:IsHidden()
	return false
end

function modifier_ronin_puncture:IsPassive()
	return true
end

function modifier_ronin_puncture:IsPermanent()
	return true
end

function modifier_ronin_puncture:OnCreated()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	ability.cooldown = ability:GetSpecialValueFor("cooldown")
	self.interval = 0.01
	self:StartIntervalThink(self.interval)
end

function modifier_ronin_puncture:OnDestroy()
	local caster = self:GetParent()
	local ability = self:GetAbility()
end

function modifier_ronin_puncture:OnIntervalThink()
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
	    for _,target in pairs( units ) do
	        caster:PerformAttack(target, true, true, true, true, false, false, true)
	        if target and ability.spinTornado then
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
			if ability.hittedOne == nil and stacks < 1 and target and not ability.spinTornado then
				caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = 5})
		        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 1)
		        ability.hittedOne = true
		    elseif ability.hittedOne == nil and stacks >= 1 and target then
				caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = 5})
		        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 2)
		        ability.hittedOne = true
		    	caster:SwapAbilities("ronin_puncture", "ronin_puncture_tornado", false, true)
		    	ability.subability:SetLevel(ability:GetLevel())
		    	ability.subability:StartCooldown(ability:GetCooldownTimeRemaining())
		    	ability:SetHidden(true)
		    	ability.subability:SetHidden(false)
		    	caster:RemoveModifierByName("modifier_ronin_hit_count")
		    end
	    end
	    ability.hittedOne = nil
		ability.spinInQueue = nil
		ability.spinTornado = nil
	end

end

modifier_puncture_states = class({})

function modifier_puncture_states:IsHidden()
	return true
end

function modifier_puncture_states:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_puncture_states:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_puncture_states:GetModifierPreAttack_BonusDamage()
	local bonusDmg = self:GetAbility():GetSpecialValueFor("bonus_damage")
	return bonusDmg
end