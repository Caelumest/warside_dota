modifier_krigler_effects = class({})

-- Hidden, permanent, not purgable
function modifier_krigler_effects:IsHidden() return true end
function modifier_krigler_effects:IsPurgable() return false end
function modifier_krigler_effects:IsPermanent() return true end

function modifier_krigler_effects:OnCreated()
    local caster = self:GetCaster()
    particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_favorite_body_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    self:AddParticle(particle, false, false, 1, false, false)
    if caster:HasModifier("modifier_release_angers") then
        if particle_ult ~= nil then
            ParticleManager:DestroyParticle(particle_ult, false)
        end
        particle_ult = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_ambient.vpcf", PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particle_ult, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 2, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 3, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 4, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 5, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 6, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 7, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_ult, 8, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        if particle_normal ~= nil then
            ParticleManager:DestroyParticle(particle_normal, false)
        end
        if particle4 ~= nil then
            ParticleManager:DestroyParticle(particle4, false)
        end
    else
        if particle_normal ~= nil then
            ParticleManager:DestroyParticle(particle_normal, false)
        end
        particle_normal = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_ambient.vpcf", PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particle_normal, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 2, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 3, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 4, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 5, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 6, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 7, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_normal, 8, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        if particle4 ~= nil then
            ParticleManager:DestroyParticle(particle4, false)
        end
        if particle_ult ~= nil then
            ParticleManager:DestroyParticle(particle_ult, false)
        end
    end
    particle4 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_sword_script/jugg_weapon_glow_variation_script.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle4, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
end

function modifier_krigler_effects:OnDestroy()
    local caster = self:GetCaster()
    ParticleManager:DestroyParticle(particle4, false)
    ParticleManager:DestroyParticle(particle, false)
    if particle_ult ~= nil then
        ParticleManager:DestroyParticle(particle_ult, false)
    end
    if particle_normal ~= nil then
        ParticleManager:DestroyParticle(particle_normal, false)
    end
end