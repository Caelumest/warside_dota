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
	EmitSoundOn("Hero_Ronin.Puncture_Cast", caster)
	Timers:CreateTimer(1.15, function () ability.tornadoReady = nil end)
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
		--caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 2)
		RemoveAnimationTranslate(caster)

		StartAnimation(caster, {duration=0.4, activity=ACT_DOTA_ATTACK, rate=2, translate="odachi"})
		AddAnimationTranslate(caster, "walk")
		AddAnimationTranslate(caster, "odachi")
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
		--self:EndCooldown()
	end
end

function ronin_puncture:OnProjectileHit(target)
	local caster = self:GetCaster()
	local ability = self
	local stacks = caster:GetModifierStackCount("modifier_ronin_hit_count", caster)
	local flux_ability = caster:FindAbilityByName("ronin_flux")
	local buff_duration = flux_ability:GetLevelSpecialValueFor( "buff_duration", flux_ability:GetLevel() - 1 )
	local flux_stacks = caster:GetModifierStackCount("modifier_ronin_flux_stacks", ability)
	if flux_stacks == 100 and flux_ability:GetAutoCastState() and target then
		EmitSoundOn("Brewmaster_Storm.DispelMagic", caster)
		ParticleManager:DestroyParticle(flux_ability.particleSword, true)
		ParticleManager:DestroyParticle(flux_ability.particleSword2, true)
		ParticleManager:DestroyParticle(flux_ability.particleSword3, true)
		ParticleManager:DestroyParticle(flux_ability.particleSword4, true)
		ParticleManager:DestroyParticle(flux_ability.particleSword5, true)
		flux_ability.particleSword = nil
		caster:SetModifierStackCount("modifier_ronin_flux_stacks", flux_ability, 0)
		flux_ability:ApplyDataDrivenModifier(caster, caster, "modifier_ronin_flux_buff", {duration = buff_duration})
		flux_ability:SetActivated(false)
	end

	--EmitSoundOn("Hero_Ronin.Puncture_Hit", target);
	caster:PerformAttack(target, true, true, true, true, false, false, true)
	if self.hittedOne == nil and stacks < 1 and target then
		caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = ability:GetSpecialValueFor("charge_duration")})
        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 1)
        self.hittedOne = true
    elseif self.hittedOne == nil and stacks >= 1 and target then
    	caster:AddNewModifier(caster, ability.subability, "modifier_ronin_puncture_tornado", {duration = ability:GetSpecialValueFor("charge_duration") + caster:GetTalentValue("special_bonus_unique_sage_ronin_4")})
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
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_ronin_puncture_tornado:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ronin_puncture_tornado:OnCreated()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	EmitSoundOn("Hero_Ronin.Puncture_Tornado_Start", caster);
	caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = ability:GetSpecialValueFor("charge_duration")})
    caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 2)
    ability.hittedOne = true
	caster:SwapAbilities("ronin_puncture", "ronin_puncture_tornado", false, true)
	ability:SetLevel(caster:FindAbilityByName("ronin_puncture"):GetLevel())
	ability:StartCooldown(caster:FindAbilityByName("ronin_puncture"):GetCooldownTimeRemaining())
	caster:RemoveModifierByName("modifier_ronin_hit_count")
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
	ability.cooldown = ability:GetSpecialValueFor("cooldown") - ((caster:GetIncreasedAttackSpeed()) * 1.4)
	if caster:HasScepter() then
		ability.cooldown = ability:GetSpecialValueFor("cooldown") - ((caster:GetIncreasedAttackSpeed()) * 1.8)
	end
	if caster:HasModifier("modifier_ronin_dash") then
		ability.behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	else
		ability.behavior = DOTA_ABILITY_BEHAVIOR_POINT
	end

	if ability.spinInQueue == true and not caster:HasModifier("modifier_ronin_dash") then
		if ability:GetCooldownTimeRemaining() > 0 then
			ability:StartCooldown(ability:GetCooldown())
		end
		caster:AddNewModifier(caster, ability, "modifier_puncture_states", {duration = 0.1})
		StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=0.5})
		AddAnimationTranslate(caster, "odachi")
		if not ability.spinTornado then
			ability.particleName = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal_core.vpcf"
		else
			ability.particleName = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal.vpcf"
			if ability.spinTornadoParticle then
				ParticleManager:DestroyParticle(ability.spinTornadoParticle, false)
			end
			ability.spinTornadoParticle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal_cyclone_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    		ParticleManager:SetParticleControlEnt(ability.spinTornadoParticle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		end
		if ability.spinParticle then
			ParticleManager:DestroyParticle(ability.spinParticle, false)
			ParticleManager:DestroyParticle(ability.spinParticle2, false)
		end
		ability.spinParticle = ParticleManager:CreateParticle(ability.particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(ability.spinParticle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(ability.spinParticle, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(ability.spinParticle, 5, Vector(250, 0, 0))
        ability.spinParticle2 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal_cyclone.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(ability.spinParticle2, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(ability.spinParticle2, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        Timers:CreateTimer(0.4, function ()  
        	ParticleManager:DestroyParticle(ability.spinParticle, false) 
        	ParticleManager:DestroyParticle(ability.spinParticle2, false)  
        	ParticleManager:DestroyParticle(ability.spinTornadoParticle, false)
        end)
		
		local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, ability:GetSpecialValueFor("melee_distance"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
	    for _,target in pairs( units ) do
	    	local flux_ability = caster:FindAbilityByName("ronin_flux")
			local buff_duration = flux_ability:GetLevelSpecialValueFor( "buff_duration", flux_ability:GetLevel() - 1 )
			local flux_stacks = caster:GetModifierStackCount("modifier_ronin_flux_stacks", ability)
			if flux_stacks == 100 and flux_ability:GetAutoCastState() and target then
				EmitSoundOn("Brewmaster_Storm.DispelMagic", caster)
				ParticleManager:DestroyParticle(flux_ability.particleSword, true)
				ParticleManager:DestroyParticle(flux_ability.particleSword2, true)
				ParticleManager:DestroyParticle(flux_ability.particleSword3, true)
				ParticleManager:DestroyParticle(flux_ability.particleSword4, true)
				ParticleManager:DestroyParticle(flux_ability.particleSword5, true)
				flux_ability.particleSword = nil
				caster:SetModifierStackCount("modifier_ronin_flux_stacks", flux_ability, 0)
				flux_ability:ApplyDataDrivenModifier(caster, caster, "modifier_ronin_flux_buff", {duration = buff_duration})
				flux_ability:SetActivated(false)
			end
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
						knockback_height = 300,
						should_stun = 1,
						duration = 1,
					}
				target:RemoveModifierByName("modifier_knockback")
				target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
			end
			if ability.hittedOne == nil and stacks < 1 and target and not ability.spinTornado then
				EmitSoundOn("Hero_Ronin.Dash_Spin", caster);
				caster:AddNewModifier(caster, ability, "modifier_ronin_hit_count", {duration = ability:GetSpecialValueFor("charge_duration")})
		        caster:SetModifierStackCount("modifier_ronin_hit_count", caster, 1)
		        ability.hittedOne = true
		    elseif ability.hittedOne == nil and stacks >= 1 and target then
		    	EmitSoundOn("Hero_Ronin.Dash_Spin", caster);
		    	caster:AddNewModifier(caster, ability.subability, "modifier_ronin_puncture_tornado", {duration = ability:GetSpecialValueFor("charge_duration") + caster:GetTalentValue("special_bonus_unique_sage_ronin_4")})
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