LinkLuaModifier("modifier_dummy_projectile_sound", "modifiers/modifier_dummy_projectile_sound.lua", LUA_MODIFIER_MOTION_NONE)

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

