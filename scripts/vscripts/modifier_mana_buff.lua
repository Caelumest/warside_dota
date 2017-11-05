modifier_mana_buff = class({})
function modifier_mana_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function modifier_mana_buff:GetModifierConstantManaRegen()
    local radius = 9999999
    local caster = self:GetCaster();
    local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    local count = 0
    for k, v in pairs(units) do
        count = count + 1
    end
    local mana_regen_bonus = caster:GetManaRegen() / count
    return mana_regen_bonus
end