LinkLuaModifier("modifier_ronin_puncture", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_puncture_states", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ronin_hit_count", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ronin_puncture_tornado", "heroes/sage_ronin/ronin_puncture.lua", LUA_MODIFIER_MOTION_NONE)

ronin_puncture = ronin_puncture or class({})

function ronin_puncture:OnUpgrade()
	local caster = self:GetCaster()
	local ability = self
	roninPuncture = ability
	caster:AddNewModifier(caster, self, "modifier_ronin_puncture", {})
end
function ronin_puncture:GetAbilityTextureName()
	local caster = self:GetCaster()
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
	if not stacks or stacks < 1 then
		return "ronin_puncture"
	else
		return "ronin_puncture_2"
	end
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
		ability.projDistance = ability:GetSpecialValueFor("melee_distance")
		ability.effectName = nil
		ability.tornadoReady = nil
	else
		ability.tornadoReady = true
		caster:RemoveModifierByName("modifier_ronin_hit_count")
	end
	if self.subability:IsHidden() then
		ability.spinTornado = nil
	end
	EmitSoundOn("Hero_Ronin.Puncture_Cast", caster)
	Timers:CreateTimer(1.15, function () ability.tornadoReady = nil end)
	caster:SetAggressive()
	if not caster:HasModifier("modifier_ronin_dash") then
		caster:AddNewModifier(caster, self, "modifier_puncture_states", {duration = 0.2})
		local random = RandomInt(1,2)
		if random == 1 then
			if not stacks or stacks == 0 then
				EmitSoundOn("sage_ronin_puncture_first_hit", caster)
			elseif stacks == 1 then
				EmitSoundOn("sage_ronin_puncture_second_hit", caster)
			end
		end
		
		if caster.cancelPuncture or caster.puncture == false then caster.cancelPuncture = nil end
		StartAnimation(caster, {duration=5.25, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
		caster.cancelPuncture = true
		caster.punctureCancelTime = GameRules:GetGameTime() + 0.35
		caster.isIdle = true
		caster:SetForwardVector((Vector(target.x, target.y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
		Timers:CreateTimer(0.15, function ()  
			if caster:IsAlive() then
				local enemies = FindUnitsInLine( 
					caster:GetTeamNumber(),
					caster:GetAbsOrigin(),
					caster:GetAbsOrigin() + caster:GetForwardVector() * ability.projDistance,
					nil,
					90,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
				)
				for _,target in pairs(enemies) do
					stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
					caster:PerformAttack(target, true, true, true, true, false, false, true)
					if self.hittedOne == nil and stacks < 1 and target then
						caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = ability:GetSpecialValueFor("charge_duration")})
				        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 1)
				        self.hittedOne = true
				    elseif self.hittedOne == nil and stacks >= 1 and target then
				    	caster:AddNewModifier(caster, ability.subability, "modifier_ronin_puncture_tornado", {duration = ability:GetSpecialValueFor("charge_duration") + caster:GetTalentValue("special_bonus_unique_sage_ronin_4")})
				    	StartSubAbility(caster, ability.subability)
				    end
				end
				self.projID = ProjectileManager:CreateLinearProjectile( {
			        Ability             = self,
			        EffectName          = "particles/sage_ronin_puncture.vpcf",
			        vSpawnOrigin        = caster:GetAbsOrigin(),
			        fDistance           = ability.projDistance,
			        fStartRadius        = 0,
			        fEndRadius          = 0,
			        Source              = caster,
			        bHasFrontalCone     = false,
			        bReplaceExisting    = false,
			        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_NONE,
			        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
			        iUnitTargetType     = DOTA_UNIT_TARGET_NONE,
			        fExpireTime         = GameRules:GetGameTime() + 0.2,
			        bDeleteOnHit        = false,
			        vVelocity           = caster:GetForwardVector() * 2500,
			        bProvidesVision     = true,
			        iVisionRadius       = 0,
			        iVisionTeamNumber   = caster:GetTeamNumber(),
			    } )
			end
    	end)
	else
		self.spinInQueue = true
	end
end

function StartSubAbility(caster, ability)
	if ability and ability:IsHidden() then
		EmitSoundOn("Hero_Ronin.Puncture_Tornado_Start", caster);
		caster:SwapAbilities("ronin_puncture", "ronin_puncture_tornado", false, true)
		ability:SetLevel(caster:FindAbilityByName("ronin_puncture"):GetLevel())
		ability:StartCooldown(caster:FindAbilityByName("ronin_puncture"):GetCooldownTimeRemaining())
		caster:RemoveModifierByName("modifier_ronin_hit_count")
	end
end

modifier_ronin_puncture_tornado = class({})

function modifier_ronin_puncture_tornado:IsHidden()
	return false
end

function modifier_ronin_puncture_tornado:IsPassive()
	return false
end

function modifier_ronin_puncture_tornado:IsPermanent()
	return false
end

function modifier_ronin_puncture_tornado:GetEffectName()
	return "particles/sage_ronin_puncture_tornado_buff.vpcf"
end

function modifier_ronin_puncture_tornado:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ronin_puncture_tornado:OnDestroy()
	local caster = self:GetParent()
	local ability = self:GetAbility()
    caster:SwapAbilities("ronin_puncture", "ronin_puncture_tornado", true, false)
	roninPuncture:StartCooldown(ability:GetCooldownTimeRemaining())
	roninPuncture:SetLevel(ability:GetLevel())

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

function modifier_ronin_hit_count:OnCreated()
	local caster = self:GetParent()
	local ability = self:GetAbility()
end

function modifier_ronin_hit_count:OnDestroy()
	local caster = self:GetParent()
	local ability = self:GetAbility()
end

modifier_ronin_puncture = class({})

function modifier_ronin_puncture:IsHidden()
	return true
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
	self.interval = 0.05
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

	if caster:HasScepter() then
		ability.cooldown = ability:GetSpecialValueFor("cooldown") - ((caster:GetIncreasedAttackSpeed()) * 2.4)
	else
		ability.cooldown = ability:GetSpecialValueFor("cooldown") - ((caster:GetIncreasedAttackSpeed()) * 2)
	end

	if caster:HasModifier("modifier_ronin_dash") then
		ability.behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	else
		ability.behavior = DOTA_ABILITY_BEHAVIOR_POINT
	end

	if caster:IsDisarmed() and not caster:IsStunned() then
		ability:SetActivated(false)
		if ability.subability then
			ability.subability:SetActivated(false)
		end
	else
		if ability then
			ability:SetActivated(true)
		end
		if ability.subability then
			ability.subability:SetActivated(true)
		end
	end

	if ability.spinInQueue == true and ability.canTornado then
		
		caster:AddNewModifier(caster, ability, "modifier_puncture_states", {duration = 0.1})
		StartAnimation(caster, {duration=0.3, activity=ACT_SPINAROUND, rate=0.5})
		if not ability.spinTornado then
			ability.particleName = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal_core.vpcf"
		else
			ability.particleName = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal.vpcf"
			if ability.spinTornadoParticle then
				ParticleManager:DestroyParticle(ability.spinTornadoParticle, false)
			end
			ability.spinTornadoParticle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal_cyclone_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    		ParticleManager:SetParticleControlEnt(ability.spinTornadoParticle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
		end

		if ability.spinParticle then
			ParticleManager:DestroyParticle(ability.spinParticle, false)
			ParticleManager:DestroyParticle(ability.spinParticle2, false)
		end

		ability.spinParticle = ParticleManager:CreateParticle(ability.particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(ability.spinParticle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(ability.spinParticle, 2, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(ability.spinParticle, 5, Vector(250, 0, 0))

        ability.spinParticle2 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal_cyclone.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(ability.spinParticle2, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(ability.spinParticle2, 2, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)

        Timers:CreateTimer(0.4, function ()  
        	ParticleManager:DestroyParticle(ability.spinParticle, false) 
        	ParticleManager:DestroyParticle(ability.spinParticle2, false)
        	if ability.spinTornadoParticle then
        		ParticleManager:DestroyParticle(ability.spinTornadoParticle, false)
        	end
        end)
		
		local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, ability:GetSpecialValueFor("melee_distance"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
	    for _,target in pairs( units ) do
	    	
	        caster:PerformAttack(target, true, true, true, true, false, false, true)
	        if target and ability.spinTornado then
	        	EmitSoundOn("Hero_Ronin.Dash_SpinTornado", caster);
	        	EmitSoundOn("sage_ronin_puncture_third_hit", caster)
		    	local knockbackTable = {
						center_x = target:GetAbsOrigin().x,
						center_y = target:GetAbsOrigin().y,
						center_z = target:GetAbsOrigin().z,
						knockback_duration = ability:GetSpecialValueFor("tornado_stun_duration"),
						knockback_distance = 0,
						knockback_height = 250,
						should_stun = 1,
						duration = 1,
					}
				if not target:IsMagicImmune() then
					target:RemoveModifierByName("modifier_knockback")
					target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
				end
			end

			if ability.hittedOne == nil and stacks < 1 and target and not ability.spinTornado then
				EmitSoundOn("Hero_Ronin.Dash_Spin", caster);
				caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = ability:GetSpecialValueFor("charge_duration")})
		        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 1)
		        ability.hittedOne = true
		    elseif ability.hittedOne == nil and stacks >= 1 and target then
		    	EmitSoundOn("Hero_Ronin.Dash_Spin", caster);
		    	caster:AddNewModifier(caster, ability.subability, "modifier_ronin_puncture_tornado", {duration = ability:GetSpecialValueFor("charge_duration") + caster:GetTalentValue("special_bonus_unique_sage_ronin_4")})
		    	StartSubAbility(caster, ability.subability)
		    end

	    end
	    ability.hittedOne = nil
		ability.spinInQueue = nil
		ability.spinTornado = nil
		ability.canTornado = false
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
    return { MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
			MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_puncture_states:GetModifierBaseAttack_BonusDamage()
	local caster = self:GetCaster()
	local bonusDmg = self:GetAbility():GetSpecialValueFor("bonus_damage")
	return bonusDmg + caster:GetTalentValue("special_bonus_unique_sage_ronin_1")
end

function modifier_puncture_states:GetAttackSound()
	return "Hero_Ronin.Puncture_Hit"
end

function modifier_puncture_states:OnDestroy()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
end
function modifier_puncture_states:GetModifierPreAttack_CriticalStrike()
	local caster = self:GetCaster()
	if caster:HasScepter() then
		return self:GetAbility():GetSpecialValueFor("crit_bonus_scepter")
	else
		return 0
	end
end