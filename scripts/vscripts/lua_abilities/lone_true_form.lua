lone_true_form = class({})
LinkLuaModifier("modifier_lone_true_form", LUA_MODIFIER_MOTION_NONE)

function lone_true_form(event)
  local caster = event.caster
  local ability = event.ability
  caster.caster_attack = caster:GetAttackCapability()
  caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
  caster:AddNewModifier(caster, ability, "modifier_lone_true_form", {})
  caster:SwapAbilities("lone_true_form", "lone_druid_remove_true_form", false, true)
  local ability1 = caster:FindAbilityByName("lone_druid_remove_true_form")
  ability1:SetLevel(1)
      
  caster:SwapAbilities("lone_savagery", "lone_taunt", false, true)

  caster:RemoveModifierByName("modifier_savagery")

  caster:SwapAbilities("lone_heritage", "lone_clap", false, true)

  caster:SwapAbilities("lone_loneliness", "lone_roar", false, true)

end
