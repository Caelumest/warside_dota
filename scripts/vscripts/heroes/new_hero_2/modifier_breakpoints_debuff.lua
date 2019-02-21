modifier_breakpoints_debuff = class({})

function modifier_breakpoints_debuff:OnCreated()
    if IsServer() then
        local target = self:GetParent()
        local ability = self:GetAbility()
        local regen = ability:GetSpecialValueFor("regen_pct")
        local total_regen = self:GetParent():GetHealthRegen() * regen * -1
        target.total_degen = total_regen
    end
end

function modifier_breakpoints_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_breakpoints_debuff:OnDestroy()
    if IsServer() then
        local target = self:GetParent()
        target.total_degen = nil
    end
end

function modifier_breakpoints_debuff:GetEffectName()
    return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf"
end

function modifier_breakpoints_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_breakpoints_debuff:IsHidden()
    return false
end

function modifier_breakpoints_debuff:IsPurgable()
    return false
end

function modifier_breakpoints_debuff:AllowIllusionDuplicate()
    return false
end

function modifier_breakpoints_debuff:GetModifierConstantHealthRegen()
    local target = self:GetParent()
    local ability = self:GetAbility()
    local stack_count = target:GetModifierStackCount("modifier_breakpoints_stacks", ability)
    print("STACKCOUNT",stack_count)
    print(target.total_degen,"REGEN DO DIABO")
    if target.total_degen ~= nil then
        return target.total_degen * stack_count
    else
        return target.total_degen
    end
end