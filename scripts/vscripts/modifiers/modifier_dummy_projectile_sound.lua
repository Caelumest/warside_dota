modifier_dummy_projectile_sound = class({})

function modifier_dummy_projectile_sound:OnCreated(kv)
    local unit = self:GetParent()
    self.interval = kv.frames
    self.distance = kv.distance
    self.tornado_velocity_per_frame = unit.velocity_per_frame
end

function modifier_dummy_projectile_sound:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
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

function modifier_dummy_projectile_sound:OnIntervalThink()
    local unit = self:GetParent()
    local ability = self:GetAbility()
    unit:SetAbsOrigin(unit:GetAbsOrigin() + unit.velocity_per_frame)
end

function modifier_dummy_projectile_sound:OnDestroy()
    local unit = self:GetParent()
    unit:RemoveSelf()
end