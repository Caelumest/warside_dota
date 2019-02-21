function PlaySound(keys)
    local caster = keys.caster
    local ability = keys.ability
    local random = RandomInt(1, 4)
    print(random,"Random")
    if random == 1 then
        EmitSoundOn("juggernaut_jugsc_arc_ability_bladefury_02", caster)
    elseif random == 2 then
        EmitSoundOn("juggernaut_jugsc_arc_ability_bladefury_09", caster)
    elseif random == 3 then
        EmitSoundOn("juggernaut_jugsc_arc_ability_bladefury_12", caster)
    else
        EmitSoundOn("juggernaut_jugsc_arc_ability_bladefury_16", caster)
    end
end


function WhenLossHealth(keys)
	local caster = keys.caster
    local ability = keys.ability
    local health_treshold = keys.treshold
    local stack_modifier = keys.stack_modifier
    local charges_duration = keys.charges_duration
    local max_health = caster:GetMaxHealth()
    local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
    local healthpercent = max_health*health_treshold
    local talent = caster:FindAbilityByName("special_bonus_unique_jugg_2")
    if talent:GetLevel() > 0 then
        healthpercent = max_health * 0.014
    end
    if caster:HasModifier("modifier_release_angers") then
        healthpercent =healthpercent / 2
    end
    local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
    if total_damage == nil then
        total_damage = 0
    end
    if stacks_buffer == nil then
        stacks_buffer = 0
    end
    total_damage = total_damage + keys.Damage
    print("Damage:",total_damage)
    stacks = total_damage/healthpercent + stacks_buffer
    stack_variable = math.floor(stacks)
    stacks_buffer = stacks - stack_variable
    print("Stack Buffer", stacks_buffer)
    if stacks > 1 and caster:IsIllusion() == false then
        ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {duration = charges_duration})
        local total_stack = stack_count + stack_variable
        caster:SetModifierStackCount(stack_modifier, ability, total_stack)
        if total_stack > max_stacks then
            caster:SetModifierStackCount(stack_modifier, ability, 100)
        end
    end
    print("Stack variable:",stack_variable)
    total_damage = 0
end

function OnHit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage = keys.Damage
    local target = keys.target
    local stack_modifier = keys.stack_modifier
    local lifesteal_buff = keys.lifesteal_buff
    local stun_multiplier = keys.stun_multiplier
    local slow_duration = keys.slow_duration
    if stack_count == nil then
        stack_count = 0
    end
    local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
    local stun_dur = stun_multiplier*stack_count
    local damage_table = {}

    --[[damage_table.attacker = caster
    damage_table.victim = target
    damage_table.ability = ability
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.damage = stack_count*5]]
    if stack_count > 0 then
        --ApplyDamage(damage_table)
        local heal = damage * ((stack_count*lifesteal_buff)/100)
        if target:IsBuilding() == false and caster:GetTeam() ~= target:GetTeam() then
            if heal > 0 then
                if heal > target:GetHealth() then
                    heal = target:GetHealth() * ((stack_count*lifesteal_buff)/100)
                end
                caster:Heal(heal, ability)
                print("HEAL",heal)
                print("DAMAGE", damage)
                ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
            end
            if stack_count < 20 and target:IsMagicImmune() == false then
                local slow_dur = slow_duration * stack_count
                ability:ApplyDataDrivenModifier(caster, target, "modifier_anger_slow", {duration = slow_dur})
            elseif stack_count >= 20 and target:IsMagicImmune() == false then
                if stun_dur > 2.5 then
                    stun_dur = 2.5
                end
                target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_dur})
                EmitSoundOn("Hero_Slardar.Bash", target)
            end
        end
        caster:RemoveModifierByName("modifier_effects")
        caster:RemoveModifierByName(stack_modifier)
    end
end

function WhenActivate(keys)
    local caster = keys.caster
    local ability = keys.ability
    local stack_modifier = keys.stack_modifier
    local charges_duration = keys.charges_duration
    local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
    local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
    local activate_stack = ability:GetLevelSpecialValueFor("stack_bonus", (ability:GetLevel() - 1))

    if caster:HasModifier("modifier_release_angers") then
        activate_stack = activate_stack * 2
        local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_trigger.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:ReleaseParticleIndex(particle)
    else
        local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_trigger.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:ReleaseParticleIndex(particle)
    end
    local total_stacks = stack_count + activate_stack
    if total_stacks > max_stacks then
        total_stacks = max_stacks
    end
    ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {duration = charges_duration})
    caster:SetModifierStackCount(stack_modifier, ability, total_stacks)
    local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false )
    for _,enemy in pairs( units ) do
        if enemy:IsHero() and insatiableFlag == nil then
            ExecuteOrderFromTable({
                UnitIndex = caster:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                AbilityIndex = ability:entindex(),
                TargetIndex = enemy:entindex(),
                Queue = false,
            })
            insatiableFlag = true
        end
    end
    if insatiableFlag == nil then
        caster:Stop()
    end
    insatiableFlag = nil
end

function CheckStacks(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ultimate = caster:FindAbilityByName("release_anger")
    local stack_modifier = keys.stack_modifier
    local stacks = caster:GetModifierStackCount(stack_modifier, ability)
    if flag == nil then
        flag = 0
    end
    if stacks < 1 or stacks == nil then
        ultimate:SetActivated(false)
    else
        ultimate:SetActivated(true)
    end
    if caster:HasModifier("modifier_release_angers") == false then
        RemoveOneAnimationTranslate(caster, "odachi")
        RemoveOneAnimationTranslate(caster, "run_fast")
    end
end
