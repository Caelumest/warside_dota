modifier_sobek_voracious_appetite = class({})

function modifier_sobek_voracious_appetite:IsPermanent()
    return true
end

function modifier_sobek_voracious_appetite:IsPurgable()
    return false
end

function modifier_sobek_voracious_appetite:IsPurgeException()
    return false
end

function modifier_sobek_voracious_appetite:IsHidden()
    return false
end

function modifier_sobek_voracious_appetite:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_MODEL_SCALE
    }
end

function modifier_sobek_voracious_appetite:SetStacks(stacks)
    self:SetStackCount(stacks)
    self:GetParent():CalculateStatBonus()
end

function modifier_sobek_voracious_appetite:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("strength_creep") * self:GetStackCount()
end

function modifier_sobek_voracious_appetite:GetModifierModelScale()
    return 7 * self:GetStackCount()
end


modifier_sobek_voracious_appetite_timer = class({})

function modifier_sobek_voracious_appetite_timer:IsPermanent()
    return true
end

function modifier_sobek_voracious_appetite_timer:IsPurgable()
    return false
end

function modifier_sobek_voracious_appetite_timer:IsPurgeException()
    return false
end

function modifier_sobek_voracious_appetite_timer:IsHidden()
    return true
end

function modifier_sobek_voracious_appetite_timer:OnCreated()
    self:StartIntervalThink(60)
end

function modifier_sobek_voracious_appetite_timer:OnIntervalThink()
    if IsServer() then
        local target = self:GetParent()
        local modifier = target:FindModifierByName("modifier_sobek_voracious_appetite")
        if modifier then
            local stacks = modifier:GetStackCount()
            if stacks > 0 then
                modifier:SetStackCount(stacks - 1)
                self:GetParent():CalculateStatBonus()
            end
        end
    end
end