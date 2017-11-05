LinkLuaModifier("modifier_stout_mail_passive", LUA_MODIFIER_MOTION_NONE)

function ReflectPassive(keys)
    local caster = keys.caster
    local ability = keys.ability

    caster:RemoveModifierByName("modifier_stout_mail_passive")
end