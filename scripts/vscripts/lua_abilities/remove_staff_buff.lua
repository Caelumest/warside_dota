function OnCreated( keys )
    local caster = keys.caster
    local ability = keys.ability
    if ability:IsHidden() then
        caster:RemoveModifierByName("modifier_mk_staff_orb")
    end
end