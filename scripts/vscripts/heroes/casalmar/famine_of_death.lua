function OnKill(event)
	local target = event.unit
	local caster = event.caster
	local ability = event.ability
	local bonus = ability:GetSpecialValueFor("bonus") + caster:GetTalentValue("special_bonus_unique_casalmar_famine")
	local enemy_bonus = ability:GetSpecialValueFor("bonus_creep")
	local deny_mult = ability:GetSpecialValueFor("bonus_deny")
	local hero_mult = ability:GetSpecialValueFor("hero_mult")
	local tower_mult = ability:GetSpecialValueFor("tower_mult")
	local siege_mult = ability:GetSpecialValueFor("siege_mult")
	local barrack_mult = ability:GetSpecialValueFor("barrack_mult")
	local ancient_mult = ability:GetSpecialValueFor("ancient_mult")
	local roshan_mult = ability:GetSpecialValueFor("bonus_roshan")
	local total_stacks = caster:GetModifierStackCount("modifier_hp_bonus", ability)
	print("TARGET", target:GetName())

	if target:IsCreep() and target:GetTeam() ~= caster:GetTeam() then
		multiplier = enemy_bonus
		if target:IsAncient() and target:GetTeam() ~= caster:GetTeam() then
			if target:GetName() == "npc_dota_roshan" then
        		multiplier = roshan_mult
        	else
        		multiplier = ancient_mult
        	end
        elseif target:GetName() == "npc_dota_creep_siege" then
        	multiplier = siege_mult
        end
    elseif target:IsRealHero() and target ~= caster then
        multiplier = hero_mult
    elseif target:IsBuilding() and target:GetTeam() ~= caster:GetTeam() then
    	if target:IsTower() and target:GetTeam() ~= caster:GetTeam() then
        	multiplier = tower_mult
    	elseif target:IsBarracks() and target:GetTeam() ~= caster:GetTeam() then
        	multiplier = barrack_mult
    	else
        	multiplier = 8
        end
    elseif target:IsCreep() and target:GetTeam() == caster:GetTeam() then
    	multiplier = deny_mult
	end
	local total_mult = bonus * multiplier
	local total = total_stacks + total_mult
	print("MULTIPLIER", multiplier, "BONUS", total_stacks + (bonus * multiplier))
	if total_mult > 0 then
		if caster:HasModifier("modifier_hp_bonus") == false and flag == nil then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_hp_bonus", {})
			flag = 0
		end
		caster:SetModifierStackCount("modifier_hp_bonus", ability, total)
		caster:CalculateStatBonus()
	end
end