dk_pull_skill = class({})
function dk_pull_skill(event)
    local target = event.target
    local caster = event.caster
    local ability = event.ability
    local talent = caster:FindAbilityByName("special_bonus_unique_dk_1")
    local max_damage = ability:GetLevelSpecialValueFor( "damage_max", ability:GetLevel() - 1 )

    if talent:GetLevel() > 0 then
        damage = max_damage + talent:GetSpecialValueFor("value")
    else
        damage = max_damage
    end

    local min_damage = ability:GetLevelSpecialValueFor( "damage_min", ability:GetLevel() - 1 )
    local totaldamage = (damage / 700)*target:GetRangeToUnit(caster)
    if target:GetRangeToUnit(caster) > 700 then
        local finaldamage = {
                        victim = target,
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = ability
                    }
        ApplyDamage(finaldamage)
    elseif target:GetRangeToUnit(caster) <= 700 and totaldamage > min_damage then
        local finaldamage = {
                        victim = target,
                        attacker = caster,
                        damage = totaldamage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = ability
                    }
        ApplyDamage(finaldamage)
    elseif totaldamage <= min_damage then
        local finaldamagemin = {
                        victim = target,
                        attacker = caster,
                        damage = min_damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = ability
                    }
        ApplyDamage(finaldamagemin)
    end
end