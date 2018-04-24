function OnCreated( keys )
    local caster = keys.caster
    local ability = keys.ability
    local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
    local modifierName = "modifier_lone_loneliness2"

    local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false )
    local count = 0
    for k, v in pairs(units) do
        count = count + 1
    end

    if count == 1 and not caster:HasModifier(modifierName) then
        caster:RemoveModifierByName("modifier_lone_loneliness")
        ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
    elseif count ~= 1 and not caster:HasModifier("modifier_lone_loneliness") then
        caster:RemoveModifierByName( modifierName )
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_lone_loneliness", {})
    end
end