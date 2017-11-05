taunt_modifier = class({})
LinkLuaModifier("modifier_taunt_buff", LUA_MODIFIER_MOTION_NONE)

function TauntStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration_buff = ability:GetLevelSpecialValueFor("duration_armor", (ability:GetLevel() - 1))
    local modifier = keys.modifier
    if caster:HasModifier(modifier) then
		-- Get the current stacks
		local stack_count = caster:GetModifierStackCount(modifier, ability)

		-- Check if the current stacks are lower than the maximum allowed
		if stack_count < 20 then
			-- Increase the count if they are
			caster:SetModifierStackCount(modifier, ability, stack_count + 1)
		end
	else
		-- Apply the attack speed modifier and set the starting stack number
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration_buff})
		caster:SetModifierStackCount(modifier, ability, 1)
	end
end