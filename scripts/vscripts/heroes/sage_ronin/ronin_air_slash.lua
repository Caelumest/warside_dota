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
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    count = 0
    for _,target in pairs( units ) do
        count = count + 1
        local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
        if target:HasModifier("modifier_knockback") then
            local modif = target:FindModifierByName("modifier_knockback"):GetRemainingTime()
            print(modif)
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_slash_can_slash", {duration = modif})
        elseif target:GetAbsOrigin().z > (groundpos.z + 10)  then
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_slash_can_slash", {duration = 0.01})
        end
    end
    if caster:HasModifier("modifier_air_slash_can_slash") and count > 0 then
        ability:SetActivated(true)
    else
        caster:RemoveModifierByName("modifier_air_slash_can_slash")
        ability:SetActivated(false)
    end
end

function PerformAirSlash(keys)
	local caster = keys.caster
	local ability = keys.ability
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    for _,target in pairs( units ) do
        if target:HasModifier("modifier_knockback") or target:GetAbsOrigin().z > (GetGroundPosition(target:GetAbsOrigin(), target).z) then
            target:InterruptMotionControllers(false)
        	ability:ApplyDataDrivenModifier(caster, target, "modifier_air_slash_debuff", {duration = 2})
        	ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_slash_debuff", {duration = 2})
        	local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
    		caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
    		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, groundpos.z + 400) + RandomVector(100))
    		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
        	local unitsInArea = FindUnitsInRadius( caster:GetTeam(), target:GetOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
        	for _,subtarget in pairs( units ) do
        		if subtarget:HasModifier("modifier_knockback") or subtarget:GetAbsOrigin().z > (GetGroundPosition(subtarget:GetAbsOrigin(), subtarget).z) then
                    subtarget:InterruptMotionControllers(false)
        			ability:ApplyDataDrivenModifier(caster, subtarget, "modifier_air_slash_debuff", {duration = 2})
        		end
        	end
        	Timers:CreateTimer(0.5, function () 
        		local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
        		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, groundpos.z + 400) + RandomVector(100))
        		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
        	end)
        	Timers:CreateTimer(1, function ()
        		local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
        		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, groundpos.z + 400) + RandomVector(100))
        		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
        	end)
        	Timers:CreateTimer(1.5, function ()
        		local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
        		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, groundpos.z + 400) + RandomVector(100))
        		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
        	end)
        	Timers:CreateTimer(2, function ()
        		local groundpos = GetGroundPosition(target:GetAbsOrigin(), target)
        		caster:SetAbsOrigin(Vector(groundpos.x, groundpos.y, groundpos.z + 400) + RandomVector(100))
        		caster:SetForwardVector((Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized())
        	end)
        end
        return
    end
end

function SetPositions(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    target.roninAirPos = 0
    target.roninAirDesc = nil
    caster.roninAirPos = 0
    caster.roninAirDesc = nil
	if target ~= caster then
		Timers:CreateTimer(0.05, function () ability:ApplyDataDrivenModifier(caster, target, "modifier_air_slash_gesture", {duration = 4}) end)
		target:RemoveModifierByName("modifier_knockback")
		target:SetAbsOrigin(Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, GetGroundPosition(target:GetAbsOrigin(), target).z))
	end
end

function SetPositionThink(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    if target ~= caster then
        target:SetAbsOrigin(Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, GetGroundPosition(target:GetAbsOrigin(), target).z + target.roninAirPos))
        if target.roninAirPos < 400 and not target.roninAirDesc then
            target.roninAirPos = target.roninAirPos + 2.22
        else
            target.roninAirPos = target.roninAirPos - 20
            target.roninAirDesc = true
        end
    else
        caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, GetGroundPosition(caster:GetAbsOrigin(), caster).z + caster.roninAirPos))
        if caster.roninAirPos < 400 and not caster.roninAirDesc then
            caster.roninAirPos = caster.roninAirPos + 2.22
        else
            caster.roninAirPos = caster.roninAirPos - 20
            caster.roninAirDesc = true
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
	caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
	FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
end