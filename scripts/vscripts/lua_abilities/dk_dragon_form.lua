
dk_dragon_form = class({})
LinkLuaModifier("modifier_dragon_blood_talent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dk_dragon_form", LUA_MODIFIER_MOTION_NONE)

function dk_dragon_form(event)
	local caster = event.caster
	local ability = event.ability
    local ability2 = caster:FindAbilityByName("remove_dk_dragon_form")
    local ability3 = caster:FindAbilityByName("dk_dragon_blood")
    local talent = caster:FindAbilityByName("special_bonus_unique_dk_2")
    local projectile_model = event.projectile_model
    caster.caster_attack = caster:GetAttackCapability()
    caster:SetRangedProjectileName(projectile_model)
    caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    if ability3:GetLevel() > 0 and talent:GetLevel() == 0 then
        caster:AddNewModifier(caster, ability3, "modifier_dragon_blood", {})
    end

    if ability3:GetLevel() > 0 and talent:GetLevel() > 0 then
        caster:AddNewModifier(caster, ability3, "modifier_dk_dragon_blood_talent", {})
    end
    caster:AddNewModifier(caster, ability2, "remove_dragon_form_on_death", {})
    caster:AddNewModifier(caster, ability, "modifier_dk_dragon_form", {})
	caster:SwapAbilities("dk_dragon_form", "remove_dk_dragon_form", false, true)
    local ability1 = caster:FindAbilityByName("remove_dk_dragon_form")
    	ability1:SetLevel(1)

   	caster:SwapAbilities("dk_shield_push", "dk_pull", false, true)

	caster:SwapAbilities("dk_intimidate", "dk_breathe_fire", false, true)

	caster:SwapAbilities("dk_fire_sword", "dk_dragon_blood", false, true)
	caster:RemoveModifierByName("modifier_dk_fire_sword_orb")
   
end
