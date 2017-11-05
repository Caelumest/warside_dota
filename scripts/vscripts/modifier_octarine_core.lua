modifier_octarine_core = class({})

function modifier_octarine_core:RemoveOnDeath()
  return false
end
function modifier_octarine_core:IsPurgable()
  return false
end

function modifier_octarine_core:IsHidden()
  return true
end

function modifier_octarine_core:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE
  }
  return funcs
end

function modifier_octarine_core:OnTakeDamage(keys)
   local caster = self:GetCaster()

   local attacker = keys.attacker
   local unit = keys.unit
   local damage = keys.damage
   local inflictor = keys.inflictor
   local damage_flags = keys.damage_flags

   if IsServer() and attacker == caster and inflictor then

      local parent = self:GetParent() 
      if parent:IsIllusion() or parent:IsClone() or parent:IsTempestDouble() then
         return
      end

      if bit.band(damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then
         return nil
      end

      if bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
         return nil
      end

      local healFactor = self:GetAbility():GetSpecialValueFor("hero_lifesteal") * 0.01
      if not unit:IsHero() then
         healFactor = self:GetAbility():GetSpecialValueFor("creep_lifesteal") * 0.01
      end

      local heal = healFactor * damage
      caster:Heal(heal,self:GetAbility())
      ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN, caster)
   end
end