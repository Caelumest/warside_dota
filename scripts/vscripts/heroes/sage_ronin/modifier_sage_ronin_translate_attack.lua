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

function modifier_sage_ronin_translate_attack:OnCreated() 
    local caster = self:GetCaster()
    print("CASTER", caster:GetUnitName())
    --self:StartIntervalThink(0.1)
    --AddAnimationTranslate(caster, "injured")
end

function modifier_sage_ronin_translate_attack:OnIntervalThink()
    local caster = self:GetParent()
    print("CASTER", caster:GetUnitName())
    if caster:GetHealthPercent() < 30 then
        AddAnimationTranslate(caster, "injured")
    end
end