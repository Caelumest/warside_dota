function OnHit( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local stack_modifier = keys.stack_modifier
    local stack_count = target:GetModifierStackCount(stack_modifier, ability)
    local duration_buff = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) )
    if target:IsBuilding() == false then
        ability:ApplyDataDrivenModifier(caster, target, stack_modifier, {duration = duration_buff})
        target:SetModifierStackCount(stack_modifier, ability, stack_count + 1)
        if stack_count == 2 then
            ability:ApplyDataDrivenModifier(caster, target, "modifier_explosion", {duration = 0})
            target:RemoveModifierByName(stack_modifier)
        end
    end
end

function OnDeath( keys )
	local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    ability:ApplyDataDrivenModifier(caster, target, "modifier_explosion", {duration = 0})
end