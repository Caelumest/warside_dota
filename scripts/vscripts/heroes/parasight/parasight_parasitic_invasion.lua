parasight_parasitic_invasion = class({})
LinkLuaModifier("modifier_parasight_parasitic_invasion", "scripts/vscripts/heroes/parasight/modifier_parasight_parasitic_invasion.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_parasight_parasitic_invasion_target", "scripts/vscripts/heroes/parasight/modifier_parasight_parasitic_invasion_target.lua", LUA_MODIFIER_MOTION_NONE)

function parasight_parasitic_invasion:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_parasight/parasight_parasitic_invasion.vpcf", PATTACH_CENTER_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", Vector(), true)
    ParticleManager:ReleaseParticleIndex(particle)

    -- Play sounds
    EmitGlobalSound("Hero_Parasight.Parasitic_Invasion.Cast")
    target:EmitSound("Hero_Parasight.Parasitic_Invasion.Target")

    -- Get duration
    local duration = self:GetSpecialValueFor("duration")

    local modifier = caster:AddNewModifier(caster, self, "modifier_parasight_parasitic_invasion", {duration = duration})
    modifier:SetTarget(target)
end