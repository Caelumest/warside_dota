LinkLuaModifier("modifier_stout_mail_active", LUA_MODIFIER_MOTION_NONE)

function Reflect(keys)
	-- Ability properties
	local caster = keys.caster
	local ability = keys.ability
	local modifier_active = "modifier_stout_mail_active"

	-- Ability specials
	local return_duration = ability:GetSpecialValueFor("return_duration")

	-- Apply blade mail on caster!
	caster:AddNewModifier(caster, ability, modifier_active, {duration = return_duration})
end