legion_imprecise_smash = class({})

function legion_imprecise_smash(data)
    local target = data.target
    local caster = data.caster
    local ability = data.ability
    if target:IsStunned() == true then
        local finaldamage1 = {
                        victim = target,
                        attacker = caster,
                        damage = ability:GetLevelSpecialValueFor("max_damage", ability:GetLevel()-1),
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = legion_imprecise_smash
                    }
        ApplyDamage(finaldamage1)
    end
    if target:IsStunned() == false then
        local finaldamage2 = {
                        victim = target,
                        attacker = caster,
                        damage = ability:GetLevelSpecialValueFor("normal_damage", ability:GetLevel()-1),
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = legion_imprecise_smash
                    }
        ApplyDamage(finaldamage2)
    end
end