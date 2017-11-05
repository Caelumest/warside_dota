function ConjureImage( event )
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerID()
	local ability = event.ability
	local health = caster:GetHealth()
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin()
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )
    local fv = caster:GetForwardVector() -- Vector the hero is facing
    local distance = 300 
    local position = origin + fv + distance
	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetOwner(caster)
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)
	illusion:RemoveModifierByName("modifier_monkey_king_fur_army_soldier_hidden")
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

	if caster:HasModifier("modifier_effects") then
  		local meta_ability = caster:FindAbilityByName("mk_sage_form")
  		meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_effects", nil)
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
    -- Choose a Position
	illusion:MakeIllusion()
	illusion:SetForwardVector(fv)
	local illusionfv = illusion:GetForwardVector()
	illusion:MoveToPosition(illusionfv+RandomVector(300) --[[Returns:Vector
	Get a random 2D ''vector''. Argument (''float'') is the minimum length of the returned vector.
	]]) --[[Returns:void
	Issue a Move-To command
	]]
	

end
