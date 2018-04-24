modifier_dragon_blood_talent = class({})

function modifier_dragon_blood_talent:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_dragon_blood_talent:OnCreated()
    -- Variables
    local caster = self:GetParent()
    ability = self:GetAbility()
    spell_amp = ability:GetSpecialValueFor("spell_amp_per_stack")
    mana_regen = ability:GetSpecialValueFor("mana_regen_per_stack")
    health_ceiling = ability:GetSpecialValueFor("hurt_health_ceiling")
    health_floor = ability:GetSpecialValueFor("hurt_health_floor")
    health_step = ability:GetSpecialValueFor("hurt_health_step")

    self:SetStackCount( 1 )

    self:StartIntervalThink(0.1) 
end

function modifier_dragon_blood_talent:OnIntervalThink()
        -- Variables
        local caster = self:GetParent()
        local oldStackCount = self:GetStackCount()
        local health_perc = caster:GetHealthPercent()/100
        local newStackCount = 1
        local hurt_health_ceiling = health_ceiling
        local hurt_health_floor = health_floor
        local hurt_health_step = health_step

        for current_health=hurt_health_ceiling, hurt_health_floor, -hurt_health_step do
            if health_perc <= current_health then

                newStackCount = newStackCount+1
            else
                break
            end
        end

        local difference = newStackCount - oldStackCount

        -- set stackcount
        if difference ~= 0 then
            self:SetStackCount(newStackCount)
            self:ForceRefresh()
        end
end

function modifier_dragon_blood_talent:OnRefresh()
    local ability = self:GetAbility()
    local StackCount = self:GetStackCount()
    local caster = self:GetParent()

end

function modifier_dragon_blood_talent:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
             MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_dragon_blood_talent:GetModifierConstantManaRegen()
    return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("mana_regen_per_stack")
end

function modifier_dragon_blood_talent:GetModifierSpellAmplify_Percentage()
    local total = (5 + spell_amp) * self:GetStackCount()
    return total
end

