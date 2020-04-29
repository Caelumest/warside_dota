LinkLuaModifier("modifier_dynamic_attraction_attracted", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dynamic_attraction_knockback", "heroes/gravitum/dynamic_attraction.lua", LUA_MODIFIER_MOTION_NONE)

gravitum_dimensional_break = gravitum_dimensional_break or class({})

function gravitum_dimensional_break:OnUpgrade()
	local caster = self:GetCaster()
	local ability = self
end

function gravitum_dimensional_break:GetBehavior()
	local caster = self:GetCaster()
	return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT
end

function gravitum_dimensional_break:GetCooldown()
	return 5
end

function gravitum_dimensional_break:GetAOERadius()
	return 200
end

function gravitum_dimensional_break:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local distance = self:GetSpecialValueFor("distance")
	local mousePos = self:GetCursorPosition()
	local time = 2

	local units = FindUnitsInRadius( caster:GetTeam(), mousePos, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )

    local vector_distance = caster:GetAbsOrigin() - mousePos
    local distance = (vector_distance):Length2D()
    local direction = (vector_distance):Normalized()
    local firstPos = caster:GetAbsOrigin()

    self.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_warp_travel_nonhero_trail_base.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(self.particle2, 0, firstPos)
    ParticleManager:SetParticleControl(self.particle2, 1, firstPos + -direction * (distance*0.1))

    for i=1,10 do
    	Timers:CreateTimer(i/5, function () 
    		ParticleManager:DestroyParticle(self.particle2, false)
			self.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_warp_travel_nonhero_trail_base.vpcf", PATTACH_CUSTOMORIGIN, caster)
		    ParticleManager:SetParticleControl(self.particle2, 0, firstPos + -direction * (distance*((i)/10)))
		    ParticleManager:SetParticleControl(self.particle2, 1, firstPos + -direction * (distance*((i+1)/10)))
		    if i == 10 then
		    	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_CUSTOMORIGIN, caster)
			    ParticleManager:SetParticleControl(particle, 0, mousePos)
			    ParticleManager:SetParticleControl(particle, 1, Vector(200, 200, 200))
			    ParticleManager:DestroyParticle(self.particle2, false)
		    end
			end)
    end

end

function gravitum_dimensional_break:OnProjectileHit_ExtraData(target, location, extraData)
	local dmg = self:GetSpecialValueFor("damage")
	if target then
		ApplyDamage({victim = target, attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end
