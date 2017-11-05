
--[[Author: Pizzalol
    Date: 09.02.2015.
    Forces the target to attack the caster]]
function Taunt( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    -- Clear the force attack target
    target:SetForceAttackTarget(nil)

    -- Give the attack order if the caster is alive
    -- otherwise forces the target to sit and do nothing
    if caster:IsAlive() then
        local order = 
        {
            UnitIndex = target:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = caster:entindex()
        }

        ExecuteOrderFromTable(order)
        target:SetForceAttackTarget(caster)
    else
        target:RemoveModifierByName("modifier_taunt_enemy")
    end

    -- Set the force attack target to be the caster
end

-- Clears the force attack target upon expiration
function TauntEnd( keys )
    local target = keys.target

    target:SetForceAttackTarget(nil)
end