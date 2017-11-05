LinkLuaModifier("modifier_stout_mail_passive", LUA_MODIFIER_MOTION_NONE)

function ReflectPassive(keys)
    local caster = keys.caster
    local ability = keys.ability

    caster:AddNewModifier(caster, ability, "modifier_stout_mail_passive", {})
end