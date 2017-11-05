function OnKill( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local stack_modifier = keys.stack_modifier
    local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
    local duration_buff = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) )
    ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {})
    caster:SetModifierStackCount(stack_modifier, ability, stack_count + 1)
end