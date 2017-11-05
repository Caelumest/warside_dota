modifier_sobek_voracious_appetite_debuff = class({})

function modifier_sobek_voracious_appetite_debuff:OnCreated(params)
    self.strength_steal = params.strength_stolen or 0
    self.slow_amount = params.slow_amount or 0
    self.slow_duration = params.slow_duration or 0

    if IsServer() then
        self:SetStackCount(self.strength_steal)
        self:GetParent():CalculateStatBonus()
    end
end

function modifier_sobek_voracious_appetite_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_sobek_voracious_appetite_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_sobek_voracious_appetite_debuff:GetModifierBonusStats_Strength()
    return -1 * self.strength_steal
end

function modifier_sobek_voracious_appetite_debuff:GetModifierMoveSpeedBonus_Percentage()
    if self:GetElapsedTime() < self.slow_duration then
        return -1 * self.slow_amount
    else
        return 0
    end
end

