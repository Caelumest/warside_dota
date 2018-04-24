function ConjureImage( event )
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerID()
	local ability = event.ability
	local health = caster:GetHealth()
	local unit_name = caster:GetUnitName()
	local talent = caster:FindAbilityByName("special_bonus_unique_mk_1")
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	if talent:GetLevel() > 0 then
        duration_talent = talent:GetSpecialValueFor("value")
    else
        duration_talent = 0
    end

    local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 ) + duration_talent
	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetOwner(caster)
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)
	illusion:RemoveModifierByName("modifier_monkey_king_fur_army_soldier_hidden")
	
	if caster:HasModifier("modifier_effects") then
  		local meta_ability = caster:FindAbilityByName("mk_sage_form")
  		meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_effects", nil)
 	end
 	
	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end
	illusion:SetHealth(health)
	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

end

function StartCooldown( event )
	local caster = event.caster
	local ability = event.ability
	cooldown = ability:GetCooldown( ability:GetLevel() - 1 )
	local cdOctarine = 25/100
	
	if caster:HasModifier("modifier_item_octarine_core") then
		cooldown = ability:GetCooldown( ability:GetLevel() - 1 ) - ability:GetCooldown( ability:GetLevel() - 1 )*cdOctarine	
	elseif caster:FindAbilityByName("special_bonus_cooldown_reduction_20"):GetLevel() > 0 then
		cooldown = ability:GetCooldown( ability:GetLevel() - 1 ) - ability:GetCooldown( ability:GetLevel() - 1 )*20/100
	end

	if caster:HasModifier("modifier_item_octarine_core") and caster:FindAbilityByName("special_bonus_cooldown_reduction_20"):GetLevel() > 0  then
		cooldown = ability:GetCooldown( ability:GetLevel() - 1 ) - ability:GetCooldown( ability:GetLevel() - 1 )*40/100
	end
	local modifierName = "modifier_mk_staff_orb"

	-- Start cooldown
	ability:EndCooldown()
	ability:StartCooldown( cooldown )
	caster:SpendMana(ability:GetLevelSpecialValueFor( "mana_cost", ability:GetLevel() - 1 ), ability) --[[Returns:void
	Spend mana from this unit, this can be used for spending mana from abilities or item usage.
	]]

	-- Disable orb modifier
	caster:RemoveModifierByName( "modifier_mk_staff_orb" )

	-- Re-enable orb modifier after for the duration
	ability:SetContextThink( DoUniqueString("activateMkStaff"), function ()
		-- Here's a magic
		-- Reset the ability level in order to restore a passive modifier
	if ability:IsHidden() then
        caster:RemoveModifierByName("modifier_mk_staff_orb")
    else
		ability.mk_staff_forceEnableOrb = true
		ability:SetLevel( ability:GetLevel() )	
	end
	end, cooldown + 0.05)
end