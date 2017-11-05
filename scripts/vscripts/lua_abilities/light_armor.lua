function Return( event )
    -- Variables
    local caster = event.caster
    local attacker = event.attacker
    local ability = event.ability
    local casterINT = caster:GetIntellect()
    local int_return = ability:GetLevelSpecialValueFor( "int_pct" , ability:GetLevel() - 1  ) * 0.01
    local damage = ability:GetLevelSpecialValueFor( "return_damage" , ability:GetLevel() - 1  )
    local damageType = ability:GetAbilityDamageType()
    local return_damage = damage + ( casterINT * int_return )

    -- Damage
    if attacker:GetTeamNumber() ~= caster:GetTeamNumber() and attacker:IsTower() == false then
        EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Target", attacker)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/kotl_illuminate_impact_creep.vpcf", PATTACH_POINT, attacker)
        ParticleManager:SetParticleControl(particle, 0, attacker:GetAbsOrigin())
        ApplyDamage({ victim = attacker, attacker = caster, damage = return_damage, damage_type = damageType })
        print("done "..return_damage)
    end

end