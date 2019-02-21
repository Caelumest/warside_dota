modifier_soul_tamer = class({})

--------------------------------------------------------------------------------

function modifier_soul_tamer:IsHidden()
	return true
end

function modifier_soul_tamer:OnCreated()
    if IsServer() then
        local target = self:GetParent()
        --target.particle_soul = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        --ParticleManager:SetParticleControlEnt(target.particle_soul, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        --ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    end
end

--------------------------------------------------------------------------------

function modifier_soul_tamer:CheckState()
	local state = 
	{
		[MODIFIER_STATE_COMMAND_RESTRICTED] = false,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_STUNNED] = false,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}

	return state
end

function modifier_soul_tamer:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
}
end

function modifier_soul_tamer:GetModifierMoveSpeed_Absolute()
	if self:GetParent():GetUnitName() == "npc_dota_creature_spirit_vessel" then
		local caster = self:GetParent():GetOwner()
		local talent = caster:FindAbilityByName("special_bonus_unique_tamer_5")
		print("MOVESPEED", self:GetParent():GetBaseMoveSpeed() + talent:GetSpecialValueFor("value"))
	    return 700 + talent:GetSpecialValueFor("value")
	else
		local caster = self:GetParent()
		local talent = caster:FindAbilityByName("special_bonus_unique_tamer_5")
		print("MOVESPEED", self:GetParent():GetBaseMoveSpeed() + talent:GetSpecialValueFor("value"))
	    return 700 + talent:GetSpecialValueFor("value")
	end
end

