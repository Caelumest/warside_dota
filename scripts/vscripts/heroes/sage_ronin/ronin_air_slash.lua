function OnUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:GetLevel() == 1 then
		ability:SetActivated(false)
	end
end

function CheckIfInAir(keys)
	local caster = keys.caster
	local ability = keys.ability
    local find_radius = ability:GetSpecialValueFor("find_radius")
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, find_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_FARTHEST, false )
    count = 0
    for _,target in pairs( units ) do
        count = count + 1
        local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
        if target:HasModifier("modifier_knockback") and not target:IsInvulnerable() then
            local modif = target:FindModifierByName("modifier_knockback"):GetRemainingTime()
            ability.target = target
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_slash_can_slash", {duration = modif})
        elseif target:GetAbsOrigin().z > (groundpos.z + 10) and not target:IsInvulnerable() then
            ability.target = target
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_slash_can_slash", {duration = 0.01})
        end
    end
    if caster:HasModifier("modifier_air_slash_can_slash") and count > 0 then
        ability:SetActivated(true)
    else
        caster:RemoveModifierByName("modifier_air_slash_can_slash")
        ability:SetActivated(false)
        ability.target = nil
    end
end

function PerformAirSlash(keys)
	local caster = keys.caster
	local ability = keys.ability
    local target = ability.target
    caster:SetAggressive()
    ability.damage = ability:GetAbilityDamage()
    local bonus_damage = ability:GetSpecialValueFor("damage_bonus")
    local find_radius = ability:GetSpecialValueFor("find_radius")
    local sub_find_radius = ability:GetSpecialValueFor("sub_find_radius")
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, find_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    EmitSoundOn("Hero_Ronin.Ultimate_Cast", caster)
    EmitSoundOn("sage_ronin_ultimate_hits", caster)
    --for _,target in pairs( units ) do
        --if target:HasModifier("modifier_knockback") or target:GetAbsOrigin().z > (GetGroundPosition(target:GetAbsOrigin(), target).z) then
        	ability:ApplyDataDrivenModifier(caster, target, "modifier_air_slash_debuff", {})
        	ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_slash_debuff", {duration = 2})
            local dummy = CreateUnitByName("npc_dota_creature_spirit_vessel", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
            ability:ApplyDataDrivenModifier(caster, dummy, "modifier_air_slash_dummy", {})
        	local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
            caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,1)
    		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, caster.roninAirPos) + RandomVector(120))
    		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
            local trailFxIndex = ParticleManager:CreateParticle("particles/sage_ronin_last_whisper.vpcf", PATTACH_CUSTOMORIGIN, target )
            ParticleManager:SetParticleControl( trailFxIndex, 0, Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster.roninAirPos) )
            ParticleManager:SetParticleControl( trailFxIndex, 1, dummy:GetAbsOrigin() )
        	local unitsInArea = FindUnitsInRadius( caster:GetTeam(), target:GetOrigin(), nil, sub_find_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
        	for _,subtarget in pairs(unitsInArea) do
        		if subtarget:HasModifier("modifier_knockback") or subtarget:GetAbsOrigin().z > (GetGroundPosition(subtarget:GetAbsOrigin(), subtarget).z) then
                    subtarget:SetAbsOrigin(Vector(subtarget:GetAbsOrigin().x, subtarget:GetAbsOrigin().y, ability.roninInitialPos))
        			ability:ApplyDataDrivenModifier(caster, subtarget, "modifier_air_slash_debuff", {})
                    ability.damage = ability.damage + bonus_damage
        		end
        	end
            EmitSoundOn("Hero_Ronin.Ultimate_Slashs", caster)
            --Timers:CreateTimer(0.5, function () StopSoundOn("Hero_Ronin.Ultimate_Slashs", caster) end)
            Timers:CreateTimer(0.6, function () 
        		local groundpos = GetGroundPosition(ability.target:GetAbsOrigin(), ability.target)
                dummy:SetAbsOrigin(caster:GetAbsOrigin())
        		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, caster.roninAirPos) + RandomVector(120))
        		caster:SetForwardVector((Vector(ability.target:GetAbsOrigin().x, ability.target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
                local trailFxIndex = ParticleManager:CreateParticle("particles/sage_ronin_last_whisper.vpcf", PATTACH_CUSTOMORIGIN, target )
                ParticleManager:SetParticleControl( trailFxIndex, 0, Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster.roninAirPos) )
                ParticleManager:SetParticleControl( trailFxIndex, 1, dummy:GetAbsOrigin() )                
        	end)
        	Timers:CreateTimer(1.2, function ()
        		local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
                dummy:SetAbsOrigin(caster:GetAbsOrigin())
        		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, caster.roninAirPos) + RandomVector(120))
        		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
                caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
                --caster:StartGesture(ACT_DOTA_ATTACK_TAUNT)
                ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_animation", {duration = 0.9})
                local trailFxIndex = ParticleManager:CreateParticle("particles/sage_ronin_last_whisper.vpcf", PATTACH_CUSTOMORIGIN, target )
                ParticleManager:SetParticleControl( trailFxIndex, 0, Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster.roninAirPos) )
                ParticleManager:SetParticleControl( trailFxIndex, 1, dummy:GetAbsOrigin() ) 
        	end)
        	--[[Timers:CreateTimer(1.5, function ()
        		local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
        		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, caster.roninAirPos) + RandomVector(100))
        		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
        	end)]]
            
            
            Timers:CreateTimer(2, function ()
                EmitSoundOn("Hero_Ronin.Ultimate_Damage", target)
                dummy:RemoveSelf()
                local unitsInArea = FindUnitsInRadius( caster:GetTeam(), target:GetOrigin(), nil, sub_find_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )
                for _,target in pairs(unitsInArea) do
                    ApplyDamage({victim = target, attacker = caster, damage = ability.damage, damage_type = ability:GetAbilityDamageType()})
                    target:RemoveModifierByName("modifier_air_slash_debuff")
                end
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_ABSORIGIN, target)
                ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN, nil, target:GetAbsOrigin(), true)
                ParticleManager:SetParticleControl(particle, 1, Vector(sub_find_radius, 0, 0))
                ParticleManager:SetParticleControl(particle, 2, Vector(100, 0, 255))

        	end)
        --end
        --return
    --end
end

function SetPositions(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    target.roninAirDesc = nil
    caster.roninAirDesc = nil
    if target ~= caster then
        target.roninAirPos = target:GetAbsOrigin().z + 10
        target:InterruptMotionControllers(false)
        print("AIRPOS", target.roninAirPos)
        if target.roninAirPos > (GetGroundPosition(Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y ,target.roninAirPos), target).z + 300) then
            target.roninAirPos = GetGroundPosition(Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y ,target.roninAirPos), target).z + 150
        end
        ability.roninInitialPos = target.roninAirPos
		Timers:CreateTimer(0.05, function () ability:ApplyDataDrivenModifier(caster, target, "modifier_air_slash_gesture", {duration = 4}) end)
		target:RemoveModifierByName("modifier_knockback")
        ability.maxpos = (GetGroundPosition(Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y ,target.roninAirPos), target).z + 350)
        ability.difference = ability.maxpos - target.roninAirPos
		target:SetAbsOrigin(Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target.roninAirPos))
	end
    caster.roninAirPos = target.roninAirPos - 50
end

function SetPositionThink(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    if target ~= caster then
        target:SetAbsOrigin(Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target.roninAirPos))
        if target.roninAirPos < ability.maxpos and not target.roninAirDesc then
            target.roninAirPos = target.roninAirPos + (ability.difference/185)
        end
    else
        caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster.roninAirPos))
        if caster.roninAirPos < ability.maxpos and not caster.roninAirDesc then
            caster.roninAirPos = caster.roninAirPos + (ability.difference/185)
        end
    end
end

function SetEndPositions(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
	local castergroundpos = GetGroundPosition(caster:GetAbsOrigin(), caster)
	target:SetAbsOrigin(groundpos)
	caster:SetAbsOrigin(castergroundpos)
	target:RemoveGesture(ACT_DOTA_FLAIL)

	FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
end