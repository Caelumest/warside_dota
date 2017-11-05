function OnCreated( keys )
    local caster = keys.caster
    local ability = keys.ability
    if caster:HasModifier("modifier_dk_dragon_form") then
        caster:RemoveModifierByName("modifier_dk_fire_sword_orb")
    end
end