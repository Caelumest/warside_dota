LinkLuaModifier("modifier_dynamic_attraction_attracted", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dynamic_attraction_knockback", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)

gravitum_timeless_gap = gravitum_timeless_gap or class({})

function gravitum_timeless_gap:OnUpgrade()
	local caster = self:GetCaster()
	local ability = self
end

function gravitum_timeless_gap:GetBehavior()
	local caster = self:GetCaster()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function gravitum_timeless_gap:GetCastPoint()
	return 0.1
end

function gravitum_timeless_gap:GetCooldown()
	return 5
end

function gravitum_timeless_gap:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local distance = self:GetSpecialValueFor("distance")
	local velocity = 10000	
	local pull_duration = self:GetSpecialValueFor("pull_duration")
	local width = self:GetSpecialValueFor("max_width")
	local expirationTime = distance / velocity
 	local direction = caster:GetAbsOrigin() + caster:GetForwardVector()
	ability.IdProj = ProjectileManager:CreateLinearProjectile( {
			        Ability             = ability,
			        EffectName          = nil,
			        vSpawnOrigin        = direction,
			        fDistance           = distance,
			        fStartRadius        = 100,
			        fEndRadius          = 100,
			        Source              = caster,
			        bHasFrontalCone     = false,
			        bReplaceExisting    = false,
			        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
			        iUnitTargetType     = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			        fExpireTime         = GameRules:GetGameTime() + expirationTime,
			        bDeleteOnHit 		= false,
			        vVelocity           = caster:GetForwardVector() * velocity,
			        bProvidesVision     = true,
			        iVisionRadius       = 0,
			        iVisionTeamNumber   = caster:GetTeamNumber(),
			        ExtraData = {
						proj = 1,
					}
			    } )
	--EmitSoundOn("Hero_VoidSpirit.AstralStep.Start", caster)
	EmitSoundOn("Hero_VoidSpirit.AstralStep.End", caster)

	--local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_singularity_explode.vpcf", PATTACH_CUSTOMORIGIN, caster)
    --ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())

    local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/travel_strike/void_spirit_travel_strike_path.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle3, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle3, 1, caster:GetAbsOrigin() + (caster:GetForwardVector() * distance))
    
	caster:SetAbsOrigin(caster:GetAbsOrigin() + (caster:GetForwardVector() * distance))
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function gravitum_timeless_gap:OnProjectileHit_ExtraData(target, location, extraData)
	local dmg = self:GetSpecialValueFor("damage")
	if target then
		ApplyDamage({victim = target, attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end
