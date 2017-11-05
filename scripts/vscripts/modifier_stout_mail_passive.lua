modifier_stout_mail_passive = class({})

function modifier_stout_mail_passive:IsHidden() return true end
function modifier_stout_mail_passive:IsDebuff() return false end
function modifier_stout_mail_passive:IsPurgable() return false end

function modifier_stout_mail_passive:OnCreated()
    -- Ability properties
    self.parent = self:GetParent()
    self.ability = self:GetAbility()    

    -- Ability specials
    self.return_damage_pct = self.ability:GetSpecialValueFor("return_damage_pct_passive")
end

function modifier_stout_mail_passive:DeclareFunctions()
    local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

    return decFuncs
end

function modifier_stout_mail_passive:OnTakeDamage(keys)
    local attacker = keys.attacker
    local target = keys.unit
    local original_damage = keys.original_damage*self.return_damage_pct/100
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