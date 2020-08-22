LinkLuaModifier("modifier_flux_bonus_stacks", "heroes/sage_ronin/modifier_flux_bonus_stacks.lua", LUA_MODIFIER_MOTION_NONE)
function CheckDistance(keys)
	local caster = keys.caster
	local ability = keys.ability
	local distance_needed = (ability:GetLevelSpecialValueFor( "distance_needed", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_sage_ronin_2")) /100
	--local damage_cap_amount = ability:GetLevelSpecialValueFor( "damage_cap_amount", ability:GetLevel() - 1 )
	
	if caster.fluxPos == nil then
		caster.fluxPos = caster:GetAbsOrigin()
	end


	local vector_distance = caster.fluxPos - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()

	if ability.distanceWalked == nil then
		ability.distanceWalked = 0
	end

	ability.distanceWalked = ability.distanceWalked + distance

	if ability.distanceWalked >= 500 then
		ability.distanceWalked = 0
	end

	if ability.distanceWalked >= distance_needed then
		local current_stacks = caster:GetModifierStackCount("modifier_ronin_flux_stacks", ability)
		--local int_distance = math.floor(ability.distanceWalked)
		local stacks = ability.distanceWalked / distance_needed
		local int_stacks = math.floor(stacks)
		local helper = (stacks - int_stacks)*distance_needed
    	ability.distanceWalked = helper
    	local total_stacks = int_stacks + current_stacks
    	if total_stacks >= 100 then
    		caster:SetModifierStackCount("modifier_ronin_flux_stacks", ability, 100)
    		ability.distanceWalked = 0
    		if not ability.particleSword then
    			EmitSoundOn("Hero_Ronin.Flux_Ready", caster)
    			ability.particleSword = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_sword_script/jugg_weapon_glow_variation_script.vpcf", PATTACH_POINT_FOLLOW, caster)
    			ParticleManager:SetParticleControlEnt(ability.particleSword, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
    			ability.particleSword2 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_sword_script/jugg_weapon_glow_variation_script.vpcf", PATTACH_POINT_FOLLOW, caster)
    			ParticleManager:SetParticleControlEnt(ability.particleSword2, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
    			ability.particleSword3 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_sword_script/jugg_weapon_glow_variation_script.vpcf", PATTACH_POINT_FOLLOW, caster)
    			ParticleManager:SetParticleControlEnt(ability.particleSword3, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
    			ability.particleSword4 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_sword_script/jugg_weapon_glow_variation_script.vpcf", PATTACH_POINT_FOLLOW, caster)
    			ParticleManager:SetParticleControlEnt(ability.particleSword4, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
    			ability.particleSword5 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_sword_script/jugg_weapon_glow_variation_script.vpcf", PATTACH_POINT_FOLLOW, caster)
    			ParticleManager:SetParticleControlEnt(ability.particleSword5, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
    			ability:SetActivated(true)
    		end
    	else
    		caster:SetModifierStackCount("modifier_ronin_flux_stacks", ability, total_stacks)
    		ability:SetActivated(false)
    	end
	end
	if caster:IsAlive() then
		caster.fluxPos = caster:GetAbsOrigin()
	else
		caster.fluxPos = nil
	end
end


function CheckIfInjured(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:IsAlive() and caster:GetUnitName() == "npc_dota_hero_sage_ronin" then
		if not caster.particleSword then
			caster.particleSword = ParticleManager:CreateParticle("particles/yasuo_blade_ambient_glow_full.vpcf", PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(caster.particleSword, 0, caster, PATTACH_POINT_FOLLOW, "blade_attachment", caster:GetAbsOrigin(), true)
			local particle2 = ParticleManager:CreateParticle("particles/yasuo_blade_ambient.vpcf", PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(particle2, 0, caster, PATTACH_POINT_FOLLOW, "blade_attachment", caster:GetAbsOrigin(), true)
			local particle3 = ParticleManager:CreateParticle("particles/yasuo_main_effect.vpcf", PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(particle3, 0, caster, PATTACH_POINT_FOLLOW, nil, caster:GetAbsOrigin(), true)
		end

		AddVelocityTranslate(caster)

		if caster:IsMoving() then
			if caster.cancelPuncture then
				caster.cancelPuncture = false
			end
			if caster.cancelPuncture ~= nil and caster.cancelPuncture == false and caster.punctureCancelTime <= GameRules:GetGameTime() then

				caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
				caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_5)
				caster.isIdle = false
			end
		else
			caster:RemoveGesture(ACT_IDLETORUN)
			caster:RemoveGesture(ACT_DEPLOY_IDLE)
			caster:RemoveGesture(ACT_GESTURE_MELEE_ATTACK1)
			caster:RemoveGesture(ACT_GESTURE_MELEE_ATTACK2)
			caster:RemoveGesture(ACT_MP_ATTACK_STAND_PRIMARY)
		end

		if caster.cancelPuncture ~= nil and caster.cancelPuncture == false and caster.punctureCancelTime <= GameRules:GetGameTime() and caster.isIdle == false then
			RemoveActions(caster)
			if caster.isAggressive then
				if caster.isFast then
					StartAnimation(caster, {duration=2.9, activity=ACT_GESTURE_MELEE_ATTACK2, rate=1})
				else
					StartAnimation(caster, {duration=2.7, activity=ACT_GESTURE_MELEE_ATTACK1, rate=1})
				end
			end
			caster.isIdle = false

			caster.cancelPuncture = nil
		end

		if caster.isAggressive and caster.aggressiveTime <= GameRules:GetGameTime() then
			RemoveAnimationTranslate(caster, "aggressive")
			caster.translateRemoved = true
			caster.isAggressive = false

			--AddVelocityTranslate(caster)

		    if not caster.isIdle then
				StartAnimation(caster, {duration=1.7, activity=ACT_MP_ATTACK_STAND_PRIMARY, rate=1})
			end

		end

	    if caster.isIdle ~= nil and caster.isIdle == false and caster.lastClickedPos ~= nil and (caster.lastClickedPos - caster:GetAbsOrigin()):Length2D() < 10 then
	    	if caster.isAggressive then
	    		RemoveAnimationTranslate(caster, "aggressive")
	    		caster.translateRemoved = true
				caster.isAggressive = false

				--AddVelocityTranslate(caster)

			    if not caster:IsMoving() then
					StartAnimation(caster, {duration=5.5, activity=ACT_IDLE_ANGRY_MELEE, rate=1})
				end
			else
				caster:RemoveGesture(ACT_GESTURE_MELEE_ATTACK1)
				caster:RemoveGesture(ACT_GESTURE_MELEE_ATTACK2)
				print("STOPEd")
				StartAnimation(caster, {duration=0.75, activity=ACT_RUNTOIDLE, rate=1})
			end
	    	caster.isIdle = true
	    	caster.cancelPuncture = nil
	    end
	end
end

function OnAttackStarted(keys)
	local caster = keys.caster
	caster:SetAggressive()
	RemoveActions(caster)
end

function RemoveActions(caster)
	caster:RemoveGesture(ACT_IDLETORUN)
	caster:RemoveGesture(ACT_DEPLOY_IDLE)
	caster:RemoveGesture(ACT_IDLE_ANGRY_MELEE)
	caster:RemoveGesture(ACT_GESTURE_MELEE_ATTACK1)
	caster:RemoveGesture(ACT_GESTURE_MELEE_ATTACK2)
	if caster.punctureCancelTime and caster.punctureCancelTime <= GameRules:GetGameTime() then
		caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
	end
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
	caster:RemoveGesture(ACT_MP_ATTACK_STAND_PRIMARY)
	caster:RemoveGesture(ACT_MP_ATTACK_STAND_SECONDARY)
end

function SetActive(keys)
	local caster = keys.caster
	local ability = keys.ability
	local current_stacks = caster:GetModifierStackCount("modifier_ronin_flux_stacks", ability)
	if current_stacks < 100 then
		ability:SetActivated(false)
	end
end


function OnAttackLanded(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local buff_duration = ability:GetLevelSpecialValueFor( "buff_duration", ability:GetLevel() - 1 )
	local stacks = caster:GetModifierStackCount("modifier_ronin_flux_stacks", ability)
	if stacks == 100 and ability:GetAutoCastState() then
		EmitSoundOn("Brewmaster_Storm.DispelMagic", caster)
		ParticleManager:DestroyParticle(ability.particleSword, true)
		ParticleManager:DestroyParticle(ability.particleSword2, true)
		ParticleManager:DestroyParticle(ability.particleSword3, true)
		ParticleManager:DestroyParticle(ability.particleSword4, true)
		ParticleManager:DestroyParticle(ability.particleSword5, true)
		ability.particleSword = nil
		caster:SetModifierStackCount("modifier_ronin_flux_stacks", ability, 0)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ronin_flux_buff", {duration = buff_duration})
		ability:SetActivated(false)
	end
end

function StartFlux(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local buff_duration = ability:GetLevelSpecialValueFor( "buff_duration", ability:GetLevel() - 1 )
	local stacks = caster:GetModifierStackCount("modifier_ronin_flux_stacks", ability)
	if stacks == 100 then
		EmitSoundOn("Brewmaster_Storm.DispelMagic", caster)
		ParticleManager:DestroyParticle(ability.particleSword, true)
		ParticleManager:DestroyParticle(ability.particleSword2, true)
		ParticleManager:DestroyParticle(ability.particleSword3, true)
		ParticleManager:DestroyParticle(ability.particleSword4, true)
		ParticleManager:DestroyParticle(ability.particleSword5, true)
		ability.particleSword = nil
		caster:SetModifierStackCount("modifier_ronin_flux_stacks", ability, 0)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ronin_flux_buff", {duration = buff_duration})
		ability:SetActivated(false)
	end
end

function RemoveSwordEffects(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability.particleSword then
		ParticleManager:DestroyParticle(ability.particleSword, true)
		ParticleManager:DestroyParticle(ability.particleSword2, true)
		ParticleManager:DestroyParticle(ability.particleSword3, true)
		ParticleManager:DestroyParticle(ability.particleSword4, true)
		ParticleManager:DestroyParticle(ability.particleSword5, true)
		ability.particleSword = nil
	end
end

function OnHeroKill(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_flux_bonus_stacks") then
		--ability:ApplyDataDrivenModifier(caster, caster, "modifier_flux_bonus_kills", {})
		caster:AddNewModifier(caster, ability, "modifier_flux_bonus_stacks", {})
	end
	local current_stacks = caster:GetModifierStackCount("modifier_flux_bonus_stacks", ability)
	caster:SetModifierStackCount("modifier_flux_bonus_stacks", ability, current_stacks + 1)
end

function AttachEffects(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability.buff_particle then
		ability.buff_particle = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_ti6/invoker_tornado_ti6_base_swirl.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControlEnt(ability.buff_particle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(ability.buff_particle, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)

		ability.buff_particle2 = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_ti6/invoker_tornado_ti6_base_magicbits.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControlEnt(ability.buff_particle2, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(ability.buff_particle2, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	end
end

function RemoveEffects(keys)
	local caster = keys.caster
	local ability = keys.ability
	ParticleManager:DestroyParticle(ability.buff_particle, false)
	ParticleManager:DestroyParticle(ability.buff_particle2, false)
	ability.buff_particle = nil
	ability.buff_particle2 = nil
end