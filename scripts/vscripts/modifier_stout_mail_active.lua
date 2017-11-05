modifier_stout_mail_active = class({})

function modifier_stout_mail_active:IsHidden() return false end
function modifier_stout_mail_active:IsDebuff() return false end
function modifier_stout_mail_active:IsPurgable() return false end

function modifier_stout_mail_active:OnCreated()
    -- Ability properties
    self.parent = self:GetParent()
    self.ability = self:GetAbility()    

    -- Ability specials
    self.return_damage_pct = self.ability:GetSpecialValueFor("return_damage_pct")
end

function modifier_stout_mail_active:GetEffectName()
    return "particles/items_fx/blademail.vpcf"
end

function modifier_stout_mail_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_stout_mail_active:GetStatusEffectName()
    return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_stout_mail_active:OnDestroy()
    return self.parent:EmitSound("DOTA_Item.BladeMail.Deactivate")
end

function modifier_stout_mail_active:DeclareFunctions()
    local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

    return decFuncs
end

function modifier_stout_mail_active:OnTakeDamage(keys)
    local attacker = keys.attacker
    local target = keys.unit
    local original_damage = keys.original_damage
    local damage_type = keys.damage_type
    local damage_flags = keys.damage_flags

    -- Only apply if the one taking damage is the parent
    if target == self.parent then        

        -- If the damage was self-inflicted or from an ally, ignore it
        if attacker:GetTeamNumber() == target:GetTeamNumber() then
            return nil
        end

        -- If the damage is flagged as HP Removal, ignore it
        if bit.band(damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then
            return nil
        end

        -- If the damage is flagged as a reflection, ignore it
        if bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
            return nil
        end

        -- If the damage came from a ward or a building, ignore it
        if attacker:IsOther() or attacker:IsBuilding() then
            return nil
        end

        -- If the target is invulnerable, do nothing
        if target:IsInvulnerable() then
            return nil
        end

        -- If we're here, it's time to return the favor
        EmitSoundOn("DOTA_Item.BladeMail.Damage", attacker)
        local damageTable = {victim = attacker,
                            damage = original_damage,
                            damage_type = damage_type,
                            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                            attacker = self.parent,
                            ability = self.ability
                            }
        ApplyDamage(damageTable)
    end
end