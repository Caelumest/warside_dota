modifier_sage_ronin_translate_attack = class({})

-- Hidden, permanent, not purgable
function modifier_sage_ronin_translate_attack:IsHidden() return true end
function modifier_sage_ronin_translate_attack:IsPurgable() return false end
function modifier_sage_ronin_translate_attack:IsPermanent() return true end

function modifier_sage_ronin_translate_attack:DeclareFunctions()
    return {MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND}
end

function modifier_sage_ronin_translate_attack:GetAttackSound()
    return "Hero_Ronin.Attack"
end