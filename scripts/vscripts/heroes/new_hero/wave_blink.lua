function wave_projectile (event)
	caster	= event.caster
	local ability	= event.ability
	local maxDist = event.distance
	main_ability = caster:FindAbilityByName("wave_blink")
	sub_ability = caster:FindAbilityByName("wave_blink_sub")
	local radius			= event.radius
	talent = caster:FindAbilityByName("special_bonus_unique_jugg_1")
	if talent:GetLevel() > 0 then
		maxDist = maxDist + talent:GetSpecialValueFor("value")
	end
	if caster:HasModifier("modifier_item_aether_lens") then
		maxDist = maxDist + 250
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
end

function wave_damage( keys )
	local ability = keys.ability
	target = keys.target
	sub_radius = sub_ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
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
		caster:RemoveModifierByName("modifier_hide_ability")
		EmitSoundOn( "Hero_Magnataur.Attack.Anvil", target )
		ProjectileManager:DestroyLinearProjectile( projID )
		ability:ApplyDataDrivenModifier(caster, target, "modifier_wave_blink", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_marked", {duration = 5})
		sub_ability:SetLevel(ability:GetLevel())
		if sub_ability:IsHidden() then
			caster:SwapAbilities("wave_blink", "wave_blink_sub", false, true)
		end
		if (target:HasModifier("modifier_wave_blink")) and (caster:GetRangeToUnit(target) <= sub_radius) and caster:CanEntityBeSeenByMyTeam(target) and target:IsAlive() then
			sub_ability:SetActivated(true)
		else
			sub_ability:SetActivated(false)
		end
		wave_start_time = GameRules:GetGameTime()
	end
end

function StartSub()
    local charge_speed = sub_ability:GetLevelSpecialValueFor("speed", (sub_ability:GetLevel() - 1)) * 1/30
    sub_ability:SetActivated(false)
    main_ability:ApplyDataDrivenModifier(caster, target, "modifier_wave_blink", {})
    sub_ability:ApplyDataDrivenModifier(caster, caster, "modifier_cant_walk", {})
    EmitSoundOn("Hero_Huskar.Life_Break", caster)
    -- Motion Controller Data
    sub_ability.target = target
    sub_ability.velocity = charge_speed
    sub_ability.life_break_z = 0
    sub_ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
    sub_ability.traveled = 0
    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()
    caster:MoveToPosition(target_loc)
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

function OnMotionDone(caster, target, sub_ability)
	local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
	local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
	target:RemoveModifierByName("modifier_wave_blink")
	target:RemoveModifierByName("modifier_marked")
	main_ability:SetLevel(sub_ability:GetLevel())
	if main_ability:IsHidden() then
		caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
	end
	if (target_loc - caster_loc):Length2D() <= 100 and target:IsAlive() and caster:IsStunned() == false then
	    EmitSoundOn("Hero_Huskar.Life_Break.Impact", target)
	    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	    ParticleManager:ReleaseParticleIndex(particle)
	    caster:RemoveModifierByName("modifier_hide_ability")
	    AutoAttack(caster, target)
	end
end

function MoveTo()
    if target:HasModifier("modifier_wave_blink") and target:IsHero() then
    	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
    	sub_ability:ApplyDataDrivenModifier(caster, caster, "modifier_hide_ability", {})
    	sub_ability:SetActivated(false)

	    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
	    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
	    local direction = (target_loc - caster_loc):Normalized()
	    local max_distance = sub_ability:GetLevelSpecialValueFor("max_distance", sub_ability:GetLevel()-1)

	    -- Max distance break condition
	    if (target_loc - caster_loc):Length2D() >= max_distance then
	    	caster:InterruptMotionControllers(true)
			main_ability:SetLevel(sub_ability:GetLevel())
	    	caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
	    	caster:RemoveModifierByName("modifier_hide_ability")
	    end

	    -- Moving the caster closer to the target until it reaches the enemy
	    if (target_loc - caster_loc):Length2D() > 100 and target:IsAlive() and caster:IsStunned() == false then
	        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * sub_ability.velocity)
	        sub_ability.traveled = sub_ability.traveled + sub_ability.velocity
		else
			caster:InterruptMotionControllers(true)
	        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
			OnMotionDone(caster, target, sub_ability)
	    end
	end
end

function CheckStunned()
	if caster:HasModifier("modifier_cant_walk") then
		if caster:IsStunned() or target:IsAlive() == false or caster:IsHexed() or caster:IsRooted() or caster:HasModifier("modifier_drowranger_wave_of_silence_knockback") or
			caster:HasModifier("modifier_blinding_light_knockback") or caster:HasModifier("modifier_invoker_deafening_blast_knockback") or caster:HasModifier("modifier_flamebreak_knockback") or 
			caster:HasModifier("modifier_flamebreak_knockback") or caster:HasModifier("modifier_knockback") then
			if caster:HasModifier("modifier_drowranger_wave_of_silence_knockback") or caster:IsStunned() or caster:HasModifier("modifier_blinding_light_knockback") or 
				caster:HasModifier("modifier_invoker_deafening_blast_knockback") or caster:HasModifier("modifier_flamebreak_knockback") or 
				caster:HasModifier("modifier_flamebreak_knockback") or caster:HasModifier("modifier_knockback") then
				caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
			else
	    		caster:InterruptMotionControllers(true)
	    	end
	        if main_ability:IsHidden() then
	        	caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
	        	main_ability:SetLevel(sub_ability:GetLevel())
	        end
	        target:RemoveModifierByName("modifier_marked")
	        caster:RemoveModifierByName("modifier_hide_ability")
	    end
    end
end

function CheckArea()
	local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
	local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
	local distance = (target_loc - caster_loc):Length2D()
	if caster:HasModifier("modifier_hide_ability") == false then
		caster:RemoveModifierByName("modifier_cant_walk")
	    caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
	end
	if talent:GetLevel() > 0 then
		sub_radius = sub_radius + talent:GetSpecialValueFor("value")
	end
	if (target:HasModifier("modifier_wave_blink")) and (distance <= sub_radius) and caster:CanEntityBeSeenByMyTeam(target) and target:IsAlive() and caster:HasModifier("modifier_hide_ability") == false and target:IsMagicImmune() == false then
		sub_ability:SetActivated(true)
	else
		sub_ability:SetActivated(false)
		if (target:HasModifier("modifier_wave_blink")) and target:IsAlive() and caster:HasModifier("modifier_hide_ability") and caster:HasModifier("modifier_cant_walk") then
	    	caster:MoveToPosition(target_loc)
		end
	end
end

function Respawn()
	if main_ability:IsHidden() then
		main_ability:SetLevel(sub_ability:GetLevel())
		caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
	end
end

function CheckTime()
	local expiration_time = GameRules:GetGameTime() - wave_start_time
	if expiration_time > 5 and caster:FindAbilityByName("wave_blink"):IsHidden() and caster:HasModifier("modifier_hide_ability") == false then
		main_ability:SetLevel(sub_ability:GetLevel())
		caster:SwapAbilities("wave_blink_sub", "wave_blink", false, true)
	end
end