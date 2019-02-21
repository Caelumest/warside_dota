function OnHit(keys)
    local caster = keys.attacker
    local ability = keys.ability
    local target = keys.target
    local modifier = keys.mod_debuff
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    local degen = ability:GetLevelSpecialValueFor("degen", (ability:GetLevel() - 1))
    local stack_count = target:GetModifierStackCount(modifier, ability)
    if not target:HasModifier(modifier) then
        ability:ApplyDataDrivenModifier(caster, target, modifier, {Duration = duration + caster:GetTalentValue("special_bonus_unique_andrax_break_dur")})
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_breakpoints_stacks_regen_caster", {Duration = duration + caster:GetTalentValue("special_bonus_unique_andrax_break_dur")})
    end
    local total_stack = stack_count + 1
    target:SetModifierStackCount(modifier, ability, total_stack)
    target.breakpoints_stacks = total_stack
    local total_degen_caster = caster:GetModifierStackCount("modifier_breakpoints_stacks_regen_caster", ability) + 1
    caster:SetModifierStackCount("modifier_breakpoints_stacks_regen_caster", ability, total_degen_caster)
end

function OnDestroyed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local stack_count = caster:GetModifierStackCount("modifier_breakpoints_stacks_regen_caster", ability) - target.breakpoints_stacks
    caster:SetModifierStackCount("modifier_breakpoints_stacks_regen_caster", ability, stack_count)
    target.breakpoints_stacks = 0
    if stack_count <= 0 then
        caster:RemoveModifierByName("modifier_breakpoints_stacks_regen_caster")
    end
end