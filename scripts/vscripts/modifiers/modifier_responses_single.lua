modifier_responses_single = class({})

-- Hidden, permanent, not purgable
function modifier_responses_single:IsHidden() return true end
function modifier_responses_single:IsPurgable() return false end
function modifier_responses_single:IsPermanent() return true end

function modifier_responses_single:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_responses_single:OnOrder(event) self.FireOutput('OnOrder', event, self:GetParent()) end
function modifier_responses_single:OnDeath(event) self.FireOutput('OnUnitDeath', event) end
function modifier_responses_single:OnTakeDamage(event) self.FireOutput('OnTakeDamage', event) end
function modifier_responses_single:OnAbilityExecuted(event) self.FireOutput('OnAbilityExecuted', event) end
