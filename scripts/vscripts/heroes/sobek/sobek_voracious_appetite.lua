sobek_voracious_appetite = class({})
LinkLuaModifier('modifier_sobek_voracious_appetite', 'scripts/vscripts/heroes/sobek/modifier_sobek_voracious_appetite.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_sobek_voracious_appetite_timer', 'scripts/vscripts/heroes/sobek/modifier_sobek_voracious_appetite.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_sobek_voracious_appetite_buff', 'scripts/vscripts/heroes/sobek/modifier_sobek_voracious_appetite_buff.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_sobek_voracious_appetite_debuff', 'scripts/vscripts/heroes/sobek/modifier_sobek_voracious_appetite_debuff.lua', LUA_MODIFIER_MOTION_NONE)

local SLOW_PERCENT = 25
local SLOW_DURATION = 3

function sobek_voracious_appetite:CastFilterResultTarget(target)
    if target:IsHero() then
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
    else
        if target:IsAncient() then
            return UF_FAIL_ANCIENT
        end
        if target:IsNeutralUnitType() then
            if target:GetLevel() > 4 then
                return UF_FAIL_CUSTOM
            end
        end
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
    end
end

function sobek_voracious_appetite:GetCustomCastError()
    return "TOO BIG!"
end

function sobek_voracious_appetite:OnUpgrade()
    -- Apply the modifier at level 1
    if self:GetLevel() == 1 then
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_sobek_voracious_appetite', {})
        self.modifier:SetStacks(0)
    end
end

function sobek_voracious_appetite:OnSpellStart()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()

    caster:StartGesture(ACT_DOTA_FLAIL)

    -- Play particles
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(particle)

    -- Play sounds
    
    target:EmitSound("Hero_Koh.Voracious_Appetite.Target")

    particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(), true)
    ParticleManager:ReleaseParticleIndex(particle)

    if target:IsHero() then
        -- Play hero sound
        caster:EmitSound("Hero_Koh.Voracious_Appetite.Hero")
        local modifierParams = {
            strength_stolen = self:GetSpecialValueFor("strength_hero"), 
            duration = self:GetSpecialValueFor("duration"), 
            slow_amount = SLOW_PERCENT,
            slow_duration = SLOW_DURATION
        }
        self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_sobek_voracious_appetite_buff', modifierParams)
        target:AddNewModifier(self:GetCaster(), self, 'modifier_sobek_voracious_appetite_debuff', modifierParams)
    else
        -- Play creep sound
        caster:EmitSound("Hero_Koh.Voracious_Appetite.Creep")
        -- Kill target, giving proper credit
        ApplyDamage({
            victim = target,
            attacker = self:GetCaster(),
            damage = target:GetHealth(),
            damage_type = DAMAGE_TYPE_PURE,
            ability = self
        })

        local currentStacks = self.modifier:GetStackCount()
        local maxStacks = self:GetSpecialValueFor("max_creeps")

        local timerModifier = caster:FindModifierByName("modifier_sobek_voracious_appetite_timer")
        if timerModifier then
            timerModifier:Destroy()
        end
        caster:AddNewModifier(caster,self,"modifier_sobek_voracious_appetite_timer",{})

        -- Check for talent
        local talent = caster:FindAbilityByName("special_bonus_unique_sobek_1")
        if talent and talent:GetLevel() > 0 then
           maxStacks = maxStacks + talent:GetSpecialValueFor("value")
        end

        if currentStacks < maxStacks then
            self.modifier:SetStacks(currentStacks + 1)
        end
    end
end

-- function sobek_voracious_appetite:OnOwnerDied()
--     if self:GetLevel() > 0 and not self:GetCaster():IsReincarnating() then
--         local currentStacks = self.modifier:GetStackCount()
--         self.modifier:SetStacks(math.floor(currentStacks/2))
--     end
-- end