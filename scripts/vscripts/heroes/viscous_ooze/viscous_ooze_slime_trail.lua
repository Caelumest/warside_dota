LinkLuaModifier("modifier_slime_trail","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slime_puddle","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slime_puddle_effect","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)



viscous_ooze_slime_trail = class({})

function viscous_ooze_slime_trail:ProcsMagicStick()
    return false
end

function viscous_ooze_slime_trail:OnToggle()
    if IsServer() then
        local caster = self:GetCaster()
        if self:GetToggleState() then
            self:CreateSlime(caster:GetAbsOrigin(), self:GetSpecialValueFor("start_radius"))
            caster:AddNewModifier(caster,self,"modifier_slime_trail",{})
        else
            caster:RemoveModifierByName("modifier_slime_trail")
        end
    end
end

function viscous_ooze_slime_trail:CreateSlime(position, radius)
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    -- Check for talent
    local talent = caster:FindAbilityByName("special_bonus_unique_viscous_ooze_3")
    if talent and talent:GetLevel() > 0 then
        duration = duration + talent:GetSpecialValueFor("value")
    end

    local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_slime_puddle", {
        Duration = duration, 
        aura_radius = radius, 
        positionX = position.x, 
        positionY = position.y, 
        positionZ = position.z
        }, position, self:GetCaster():GetTeamNumber(), false)

    thinker:EmitSound("Hero_Viscous_Ooze.Slime_trail")
    self:CreateVisibilityNode(position, 200, self:GetSpecialValueFor("duration"))
    -- local puddles = self.slimePuddles or { }
    -- table.insert(puddles, {
    --     position = position, 
    --     modifier = thinker:entindex()
    -- })
    -- self.slimePuddles = puddles
end

modifier_slime_trail = class({})

function modifier_slime_trail:IsHidden()
    return true
end

function modifier_slime_trail:OnCreated(keys)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.lastPosition = caster:GetAbsOrigin()
    self.Distance = 50
    self.interval = 0.1
    if IsServer() then
        self:StartIntervalThink(self.interval)
    end
end

function modifier_slime_trail:OnIntervalThink()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local distance = (self.lastPosition - caster:GetAbsOrigin()):Length()
    if distance > 500 then 
        self.lastPosition = caster:GetAbsOrigin()
        ability:CreateSlime(caster:GetAbsOrigin(), ability:GetSpecialValueFor("start_radius"))
        
    elseif distance > self.Distance then 
        self.lastPosition = caster:GetAbsOrigin()
        ability:CreateSlime(caster:GetAbsOrigin(), ability:GetSpecialValueFor("start_radius") + distance)
    end

    local selfDamage = self.interval * ability:GetSpecialValueFor("self_damage") * caster:GetMaxHealth() / 100
    if selfDamage > caster:GetHealth() then self:GetAbility():ToggleAbility() end

    ApplyDamage({
        victim = caster,
        attacker = caster,
        ability = ability,
        damage = selfDamage,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
        })

    --caster:EmitSound("Hero_Viscous_Ooze.Slime_trail")

    -- table.foreach(self.slimePuddles, function(k, v)
    --     print(k, v)
    --     print(v.position)
    --     print(v.modifier)
    --     end)

end





modifier_slime_puddle = class({})

function modifier_slime_puddle:OnCreated(keys)

    --print(keys.aura_radius)
    self.currentRadius = 0
    self.maxRadius = 50

    self.interval = 0.25

    if IsServer() then
        self.currentRadius = keys.aura_radius
        self.maxRadius = self:GetAbility():GetSpecialValueFor("max_radius")
        self.position = Vector(keys.positionX, keys.positionY, keys.positionZ)
        self:LoadParticle(self.position)
        self:StartIntervalThink(self.interval)
    end
end

function modifier_slime_puddle:OnDestroy()
    --table.remove(self:GetAbility().slimePuddles)
end

function modifier_slime_puddle:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetModifierAura()  return "modifier_slime_puddle_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetAuraRadius() return self.currentRadius or 1 end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        if self:GetAbility():GetToggleState() then 
            local distance = (self.position - caster:GetAbsOrigin()):Length() - 64
            
            if distance < self.currentRadius then
                local ability = self:GetAbility()
                local damageTaken = self.interval * caster:GetMaxHealth() * ability:GetSpecialValueFor("self_damage") / 100
                --local addRadius = damageTaken * (self.currentRadius - distance) / self.currentRadius * (self.maxRadius / (self.currentRadius * 2))
                local addRadius = damageTaken * (self.maxRadius / (self.currentRadius * 2))
                local newRadius = self.currentRadius + addRadius
                if newRadius < self.maxRadius then
                    self.currentRadius = newRadius
                    self:LoadParticle(self.position)
                    --self:GetAbility():CreateSlime(self.position, newRadius)
                    --self:Destroy()
                end
            end
        end
    end
end

function modifier_slime_puddle:LoadParticle(position)
    if self.particle then ParticleManager:DestroyParticle(self.particle, false) end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_viscous_ooze/viscous_ooze_slime_trail.vpcf", PATTACH_WORLDORIGIN ,nil)
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 1, Vector(self.currentRadius, 1, 1))
    --Rainbow puddles
    --ParticleManager:SetParticleControl(particle, 15, Vector(RandomFloat(0,255), RandomFloat(0,255), RandomFloat(0,255)))
    ParticleManager:SetParticleControl(particle, 15, Vector(RandomFloat(15,65), RandomFloat(55,120), 0))
    ParticleManager:SetParticleControl(particle, 16, Vector(1, 0, 0))

    self.particle = particle
    self:AddParticle( particle, false, false, -1, false, false )

    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_viscous_ooze/viscous_ooze_slime_puddle.vpcf", PATTACH_WORLDORIGIN ,nil)
    ParticleManager:SetParticleControl(particle2, 0, position)

    ParticleManager:SetParticleControl(particle2, 1, Vector(self.currentRadius, 1, 1))
    --Rainbow puddles
    --ParticleManager:SetParticleControl(particle2, 15, Vector(RandomFloat(0,255), RandomFloat(0,255), RandomFloat(0,255)))
    ParticleManager:SetParticleControl(particle2, 15, Vector(RandomFloat(15,65), RandomFloat(55,120), 0))
    ParticleManager:SetParticleControl(particle2, 16, Vector(1, 0, 0))

    self:AddParticle( particle2, false, false, -1, false, false )
    
end
---------------------------------------------------------------------------------------------------------- 
modifier_slime_puddle_effect = class({})

function modifier_slime_puddle_effect:IsHidden() 
    return self.hidden or false
end

function modifier_slime_puddle_effect:IsBuff()
    return self.isBuff or false
end

function modifier_slime_puddle_effect:OnCreated()
    if IsServer() then
        self:StartIntervalThink(1)
        self.hidden = self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber()
        self.isBuff = self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber()
        --self:EmitSound("Hero_Viscous_Ooze.Slime_trail")
    end
end

function modifier_slime_puddle_effect:CheckState()
    local states = {}
    if IsServer() and self:GetParent():GetPlayerOwner() == self:GetCaster():GetPlayerOwner() then
        states = {
            [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true
        }
    end
    return states
end

----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_effect:OnIntervalThink()
    if not self.isBuff then
        ApplyDamage({ 
            victim = self:GetParent(), 
            attacker = self:GetCaster(), 
            damage = self:GetAbility():GetSpecialValueFor("damage"),
            damage_type = DAMAGE_TYPE_MAGICAL 
            })
    end
end