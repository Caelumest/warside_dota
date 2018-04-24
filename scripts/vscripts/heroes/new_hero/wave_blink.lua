function wave_projectile (event)
	local caster	= event.caster
	local ability	= event.ability
	local maxDist = event.distance
	local radius			= event.radius
	local talent = caster:FindAbilityByName("special_bonus_unique_jugg_1")
	if talent:GetLevel() > 0 then
		maxDist = maxDist + talent:GetSpecialValueFor("value")
	end
	if caster:HasModifier("modifier_item_aether_lens") then
		maxDist = event.distance + 250
	end
	local speed				= event.speed
	local visionRadius		= event.vision
	local visionDuration	= event.vision_duration
	local casterOrigin		= caster:GetAbsOrigin()

	projID = ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		vSpawnOrigin		= casterOrigin,
		fDistance			= maxDist,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime 		= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= false,
		vVelocity			= caster:GetForwardVector() * speed,
		bProvidesVision		= true,
		iVisionRadius		= visionRadius,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )
	EmitSoundOn( "Hero_Magnataur.ShockWave.Particle", caster )
	print("Soltou Wave")

end

function wave_damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	target = keys.target
	local sub_ability = caster:FindAbilityByName("wave_blink_sub")
	local sub_radius = sub_ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = ability:GetAbilityDamage()

	ApplyDamage(damage_table)
	if target:IsHero() == false then
		EmitSoundOn( "Hero_Magnataur.ShockWave.Target", target )
	end
	if target:IsHero() then
		EmitSoundOn( "Hero_Magnataur.Attack.Anvil", target )
		ProjectileManager:DestroyLinearProjectile( projID )
		ability:ApplyDataDrivenModifier(caster, target, "modifier_wave_blink", {})

		local sub_ability_name = keys.sub_ability_name
		local main_ability_name = ability:GetAbilityName()
		local sub_ability = caster:FindAbilityByName("wave_blink_sub")
		sub_ability:SetLevel(ability:GetLevel())
		if sub_ability:IsHidden() then
			caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
		end

		wave_start_time = GameRules:GetGameTime()

		if (target:HasModifier("modifier_wave_blink")) and (caster:GetRangeToUnit(target) <= sub_radius) then
			sub_ability:SetActivated(true)
		else
			sub_ability:SetActivated(false)
		end
	end
end

function LifeBreak( keys )
    -- Variables
    local caster = keys.caster

    local ability = keys.ability
    local ability_prim = caster:FindAbilityByName("wave_blink")
    local charge_speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1)) * 1/30
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_turn", {})
    caster:RemoveModifierByName("modifier_check_area")
    ability:SetActivated(false)
    ability_prim:ApplyDataDrivenModifier(caster, target, "modifier_wave_blink", {})
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_cant_walk", {})
    caster:Stop()
    caster:Stop()
    caster:Stop()
    EmitSoundOn("Hero_Huskar.Life_Break", caster)

    -- Save modifiernames in ability
    ability.modifiername = keys.ModifierName
    ability.modifiername_debuff = keys.ModifierName_Debuff

    -- Motion Controller Data
    ability.target = target
    ability.velocity = charge_speed
    ability.life_break_z = 0
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
    ability.traveled = 0
    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()
    caster:MoveToPosition(target_loc)
    caster:SetForwardVector(direction)
   
end

function AutoAttack(caster, target)
        caster:PerformAttack(target, true, true, true, true, false, false, true)
        local order =
	      {
	         UnitIndex = caster:GetEntityIndex(),
	         OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
	         TargetIndex = target:GetEntityIndex(),
	         Queue = true
	      }
	      ExecuteOrderFromTable(order)

end

function DoDamage(caster, target, ability)
	local dmg_table_target = {
                                victim = target,
                                attacker = caster,
                                damage = 50,
                                damage_type = DAMAGE_TYPE_MAGICAL
                            }
    ApplyDamage(dmg_table_target)
    EmitSoundOn( "Hero_Huskar.Life_Break.Impact", target )
end

function OnMotionDone(caster, target, ability)
	target:RemoveModifierByName("modifier_wave_blink")
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_check_area", {} )
	local main_ability = caster:FindAbilityByName("wave_blink")
	local sub_ability = caster:FindAbilityByName("wave_blink_sub")
	main_ability:SetLevel(ability:GetLevel())
	caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
    EmitSoundOn("Hero_Huskar.Life_Break.Impact", target)
    --Particles and effects
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)
    caster:RemoveModifierByName("modifier_cant_walk")
    caster:RemoveModifierByName("modifier_turn")
    DoDamage(caster, target, ability)

    AutoAttack(caster, target)
end

function JumpHorizonal( keys )
    -- Variables
    local caster = keys.target
    local ability = keys.ability
    if target:HasModifier("modifier_wave_blink") and target:IsHero() then
    	caster:StartGesture( ACT_DOTA_RUN )
	    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
	    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
	    local direction = (target_loc - caster_loc):Normalized()
	    local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel()-1)

	    -- Max distance break condition
	    if (target_loc - caster_loc):Length2D() >= max_distance then
	    	caster:InterruptMotionControllers(true)
	    	caster:FadeGesture( ACT_DOTA_RUN )
	    	local main_ability = caster:FindAbilityByName("wave_blink")
			local sub_ability = caster:FindAbilityByName("wave_blink_sub")
			main_ability:SetLevel(sub_ability:GetLevel())
	    	caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
	    	sub_ability:ApplyDataDrivenModifier( caster, caster, "modifier_check_area", {} )
	    	caster:RemoveModifierByName("modifier_cant_walk")
    		caster:RemoveModifierByName("modifier_turn")
	    end

	    -- Moving the caster closer to the target until it reaches the enemy
	    if (target_loc - caster_loc):Length2D() > 100 and target:IsAlive() and caster:IsStunned() == false then
	        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
	        ability.traveled = ability.traveled + ability.velocity
		else
			caster:InterruptMotionControllers(true)
	        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
	        caster:FadeGesture( ACT_DOTA_RUN )
			OnMotionDone(caster, target, ability)
	    end
	end
end

function CheckStunned(args)
	local caster = args.caster
	local ability = args.ability

	if caster:HasModifier("modifier_cant_walk") and caster:IsStunned() then
    	--caster:InterruptMotionControllers(true)
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
        caster:FadeGesture( ACT_DOTA_RUN )
        caster:RemoveModifierByName("modifier_cant_walk")
        caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
    end
end

function CheckArea(args)
	local caster = args.caster
	local ability = args.ability
	local talent = caster:FindAbilityByName("special_bonus_unique_jugg_1")
	local sub_radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
	local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)

	local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
	local distance = (target_loc - caster_loc):Length2D()
	print(distance)
	if talent:GetLevel() > 0 then
		sub_radius = sub_radius + talent:GetSpecialValueFor("value")
	end
	if (target:HasModifier("modifier_wave_blink")) and (distance <= sub_radius) and caster:CanEntityBeSeenByMyTeam(target) and target:IsAlive() then
		ability:SetActivated(true)
	else
		ability:SetActivated(false)
	end
end

function Respawn(args)
	local caster = args.caster
	local main_ability = caster:FindAbilityByName("wave_blink")
	local sub_ability = caster:FindAbilityByName("wave_blink_sub")
	if main_ability:IsHidden() then
		main_ability:SetLevel(sub_ability:GetLevel())
		caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
		sub_ability:ApplyDataDrivenModifier( caster, caster, "modifier_check_area", {} )
	end
end

function CheckTime(args)
	local caster = args.caster
	local ability = args.ability

	local expiration_time = GameRules:GetGameTime() - wave_start_time
	if expiration_time > 5 and caster:FindAbilityByName("wave_blink"):IsHidden() then
		local main_ability = caster:FindAbilityByName("wave_blink")
		local sub_ability = caster:FindAbilityByName("wave_blink_sub")
		main_ability:SetLevel(ability:GetLevel())
		caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
	end
end