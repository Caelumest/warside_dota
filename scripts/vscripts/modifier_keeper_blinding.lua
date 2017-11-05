modifier_keeper_blinding = class({})
function modifier_keeper_blinding:DeclareFunctions()
    return { MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_keeper_blinding:OnCreated()
    if IsServer() then
        local target = self:GetParent()
        local caster = self:GetCaster();
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        self:AddParticle(particle, false, false, 1, false, false)
    end
end

function modifier_keeper_blinding:GetModifierMiss_Percentage()
    local caster = self:GetCaster();
    local ability = caster:FindAbilityByName("keeper_blinding")
    local blind_pct = ability:GetLevelSpecialValueFor( "blind_pct_base" , ability:GetLevel() - 1  )
    local bonus_blind = caster:GetIntellect() / 5
    local blind = blind_pct + bonus_blind
    return blind
end