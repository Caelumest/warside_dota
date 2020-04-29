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

	if caster:GetHealthPercent() <= 35 and not caster.isInjured then
        AddAnimationTranslate(caster, "injured")
        caster.isInjured = true
    elseif caster.isInjured and caster:GetHealthPercent() > 35 then
    	RemoveAnimationTranslate(caster)
		AddAnimationTranslate(caster, "walk")
		AddAnimationTranslate(caster, "odachi")
		caster.isInjured = nil
    end
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