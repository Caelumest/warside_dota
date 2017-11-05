LinkLuaModifier("modifier_mana_buff", LUA_MODIFIER_MOTION_NONE)
function ManaAura( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local radius = 9999999
    local modifierName = "modifier_mana_buff"
    local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    local count = 0
    for k, v in pairs(units) do
        count = count + 1
    end
    units:AddNewModifier(caster, ability, modifierName, {})
end