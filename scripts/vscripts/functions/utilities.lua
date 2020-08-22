LinkLuaModifier("modifier_dummy_projectile_sound", "modifiers/modifier_dummy_projectile_sound.lua", LUA_MODIFIER_MOTION_NONE)
function _G.softRequire(file)
  _G.dummyEnt = dummyEnt or Entities:CreateByClassname("info_target")
  local happy,msg = pcall(require,file)
  if not happy then
    dummyEnt:SetThink(function()
      error(msg)
    end)
  end
end

function CDOTA_BaseNPC:GetTalentValue(talentName)
	local talent = self:FindAbilityByName(talentName)
	if talent and talent:GetLevel() > 0 then
		return talent:GetSpecialValueFor("value")
	end
	
	return 0
end

function CDOTA_BaseNPC:HasTalent(talentName)
	local talent = self:FindAbilityByName(talentName)
	if talent and talent:GetLevel() > 0 then
		return true
	end

	return false
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. [[
          ]]
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function CDOTA_BaseNPC:SetAggressive()
  AddAnimationTranslate(self, "aggressive")
  self.isAggressive = true
  self.aggressiveTime = GameRules:GetGameTime() + RandomFloat(5.0, 9.0)
end

function AddVelocityTranslate(caster)
    if caster:GetIdealSpeed() >= 400 then
      if caster:HasModifier("modifier_rune_haste") then
        RemoveAnimationTranslate(caster,"run")
        RemoveAnimationTranslate(caster,"walk")
        AddAnimationTranslate(caster, "run_fast")
      else
        RemoveAnimationTranslate(caster,"run_fast")
        RemoveAnimationTranslate(caster,"walk")
        AddAnimationTranslate(caster, "run")
      end
      caster.isFast = true
    elseif caster:GetIdealSpeed() < 400 then
      RemoveAnimationTranslate(caster,"run_fast")
      RemoveAnimationTranslate(caster,"run")
      AddAnimationTranslate(caster,"walk") 
      caster.isFast = nil
    end
end