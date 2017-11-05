remove_lone_true_form = class({})
LinkLuaModifier("modifier_lone_true_form", LUA_MODIFIER_MOTION_NONE)

function remove_lone_true_form(event)
local caster = event.caster
local ability = event.ability
local lone_savagery = caster:FindAbilityByName("lone_savagery")
local ability3 = caster:FindAbilityByName("lone_true_form")
  if ability3:IsHidden() then
    caster.caster_attack = caster:GetAttackCapability()
    caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    caster:RemoveModifierByName("modifier_lone_true_form")
    caster:SwapAbilities("lone_true_form", "lone_druid_remove_true_form", true, false)
      local ability1 = caster:FindAbilityByName("lone_true_form")
        ability1:SetLevel(1)
    caster:SwapAbilities("lone_savagery", "lone_taunt", true, false)
    if lone_savagery:GetLevel() > 0 then
      lone_savagery:ApplyDataDrivenModifier(caster, caster, "modifier_savagery", {})
    end
    caster:SwapAbilities("lone_heritage", "lone_clap", true, false)
    caster:SwapAbilities("lone_loneliness", "lone_roar", true, false)
  end
end
