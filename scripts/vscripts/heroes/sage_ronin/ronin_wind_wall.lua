LinkLuaModifier("modifier_wind_wall_dummy", "heroes/sage_ronin/ronin_wind_wall.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wind_wall_dummy_invulnerability", "heroes/sage_ronin/ronin_wind_wall.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flux_bonus_stacks", "heroes/sage_ronin/modifier_flux_bonus_stacks.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ronin_flux", "heroes/sage_ronin/ronin_wind_wall.lua", LUA_MODIFIER_MOTION_NONE)

ronin_wind_wall = ronin_wind_wall or class({})

function ronin_wind_wall:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT
end

function ronin_wind_wall:GetCooldown()
    local caster = self:GetCaster()
    if self.talent and self.talent:GetLevel() > 0 then
        return self:GetSpecialValueFor("cooldown") + self.talent:GetSpecialValueFor("value")
    else
        return self:GetSpecialValueFor("cooldown")
    end
end

function ronin_wind_wall:OnUpgrade()
   local caster = self:GetCaster()
    self.talent = caster:FindAbilityByName("special_bonus_unique_sage_ronin_2")
    if not caster:HasModifier("modifier_ronin_flux") then
        caster:AddNewModifier(caster, self, "modifier_ronin_flux", {})
    end
end

function ronin_wind_wall:OnSpellStart()
    local caster = self:GetCaster()
    local mousePos = self:GetCursorPosition()
    local direction = (Vector(mousePos.x, mousePos.y, caster:GetAbsOrigin().z) - caster:GetAbsOrigin()):Normalized()
    local wall_length = self:GetSpecialValueFor("wall_length")
    local wall_duration = self:GetSpecialValueFor("duration")
    local spawnLocation = caster:GetAbsOrigin() + direction * 150
    self.spawnDummy = wall_length
    local difference = (mousePos - caster:GetAbsOrigin()):Length2D()
    if difference > 300 + caster:GetCastRangeBonus() then
        difference = 300
    end
    caster:SetAggressive()
    local talent = caster:FindAbilityByName("special_bonus_unique_sage_ronin_2")
    local olddirection = caster:GetForwardVector()
    caster:SetForwardVector(direction)
    local rightvector = caster:GetRightVector() * -1
    local trueRightVector = caster:GetRightVector()
    caster:SetForwardVector(olddirection)
    _G.WIND_WALL_TEAM = caster:GetTeamNumber()
    StartAnimation(caster, {duration=0.7, activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
    EmitSoundOn("sage_ronin_wind_wall_cast", caster)
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() + direction * difference, "Hero_Ronin.Wind_Wall_Cast" ,caster)
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() + direction * difference, "Hero_Ronin.Wind_Wall_Cast_Post" ,caster)
    local angleHelper = difference - 60
    local startTimer = 1 + (((wall_length/25)+1) * 0.02)
    local countHelper = 0
    local timerHelper = 1
    local casterLocation = caster:GetAbsOrigin()
    Timers:CreateTimer(0.15, function ()
        local dummy = CreateUnitByName("npc_dota_creature_spirit_vessel", (casterLocation + direction * (difference - 60)) + (rightvector * -1) * wall_length, false, caster, caster, caster:GetTeamNumber())
        dummy:AddNewModifier(caster, self, "modifier_wind_wall_dummy", {duration = 5})
        local wall_particle = ParticleManager:CreateParticle("particles/sage_ronin_wind_wall_cast.vpcf", PATTACH_CUSTOMORIGIN, dummy)
        local dummyPos = dummy:GetAbsOrigin()
        ParticleManager:SetParticleControlEnt(wall_particle, 0, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, Vector(dummyPos.x, dummyPos.y + 64, dummyPos.z), true)
        local endLocation = (casterLocation + direction * difference) + (rightvector * -1) * (wall_length-100)
        local endLocation2 = (casterLocation + direction * difference) + rightvector * (wall_length-100)
        local endLocation3 = (casterLocation + direction * angleHelper) + rightvector * (wall_length + 50)
        local fissureAnimDur = 0.05
        local knockbackTable = {
                center_x = endLocation.x,
                center_y = endLocation.y,
                center_z = endLocation.z,
                knockback_duration = fissureAnimDur,
                knockback_distance = -116.5,
                knockback_height = 0,
                should_stun = 0,
                duration = fissureAnimDur,
            }
        local knockbackTable2 = {
            center_x = endLocation2.x,
            center_y = endLocation2.y,
            center_z = endLocation2.z,
            knockback_duration = fissureAnimDur*2,
            knockback_distance = (wall_length*2)*-1 +165,
            knockback_height = 0,
            should_stun = 0,
            duration = fissureAnimDur*2,
        }
        local knockbackTable3 = {
                center_x = endLocation3.x,
                center_y = endLocation3.y,
                center_z = endLocation3.z,
                knockback_duration = fissureAnimDur,
                knockback_distance = -116.5,
                knockback_height = 0,
                should_stun = 0,
                duration = fissureAnimDur,
            }
        dummy:AddNewModifier(caster, self, "modifier_knockback", knockbackTable)

        Timers:CreateTimer(0.05, function ()
            dummy:RemoveModifierByName("modifier_knockback")
            dummy:AddNewModifier(caster, self, "modifier_knockback", knockbackTable2)
        end)
        Timers:CreateTimer(0.15, function ()
            dummy:RemoveModifierByName("modifier_knockback")
            dummy:AddNewModifier(caster, self, "modifier_knockback", knockbackTable3)
        end)
    end)
    local test = 0
    for i=0,math.floor(wall_length/25) do
        local dummyHelper = self.spawnDummy
        local location = (casterLocation + direction * difference) + rightvector * dummyHelper

        if i <= 1 or i >= (wall_length/25) - 2 then
            location = (casterLocation + direction * angleHelper) + rightvector * dummyHelper
            if i <= 1 then
                angleHelper = angleHelper + 30
            else
                angleHelper = angleHelper - 30
            end
        end

        local dummy = CreateUnitByName("npc_dota_creature_spirit_vessel", Vector(location.x, location.y, location.z + 150), false, caster, caster, caster:GetTeamNumber())
        dummy:AddNewModifier(caster, self, "modifier_wind_wall_dummy", {duration = wall_duration})
        dummy:SetAbsOrigin(Vector(location.x, location.y, location.z + 150))
        self.spawnDummy = self.spawnDummy - 50
        if i == math.floor((wall_length/25)/2) then
            self.soundDummy = dummy
            EmitSoundOn("Hero_Ronin.Wind_Wall_Cast_Active", dummy)
        end
        Timers:CreateTimer(startTimer, function ()

            local locationparticle = Vector(dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z -150)
            local wall_particle = ParticleManager:CreateParticle("particles/ronin_wind_wall.vpcf", PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControl(wall_particle, 0, locationparticle)
            ParticleManager:SetParticleControl(wall_particle, 1, locationparticle)
            ParticleManager:SetParticleControl(wall_particle, 2, locationparticle)
            ParticleManager:SetParticleControl(wall_particle, 3, locationparticle)
            ParticleManager:SetParticleControl(wall_particle, 4, locationparticle)
            dummy.wall_particle = wall_particle
        end)

        startTimer = startTimer - 0.02 
    end
    if self.walls_active == nil then
        self.walls_active = 0
    end
    self.walls_active = self.walls_active + 1
    Timers:CreateTimer(wall_duration - 0.01, function ()
        self.walls_active = self.walls_active - 1
    end)
end

modifier_wind_wall_dummy = class({})

function modifier_wind_wall_dummy:CheckState()
    local state = 
    {

        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_NO_TEAM_SELECT] = true,
    }

    return state
end

function modifier_wind_wall_dummy:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATUS_RESISTANCE,
            MODIFIER_PROPERTY_ABSORB_SPELL,
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_wind_wall_dummy:GetModifierStatusResistance()
    return 120
end

function modifier_wind_wall_dummy:GetModifierIncomingDamage_Percentage()
    
    return -100
end

function modifier_wind_wall_dummy:GetAbsorbSpell(param)
    local wall_particle = ParticleManager:CreateParticle("particles/ronin_wind_wall_hit.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(wall_particle, 0, self:GetParent():GetAbsOrigin())
    EmitSoundOn("Hero_Ronin.Wind_Wall_Hitted", self:GetParent())
    return 1
end

function modifier_wind_wall_dummy:OnDestroy()
    local parent = self:GetParent()
    if parent ~= nil then
        if parent.wall_particle ~= nil then
            ParticleManager:DestroyParticle(parent.wall_particle, false)
        end
        if _G.WIND_WALL_TEAM ~= nil and self:GetAbility().walls_active == 0 then
            _G.WIND_WALL_TEAM = nil
        end
        if self:GetAbility().soundDummy and parent == self:GetAbility().soundDummy then
            StopSoundOn("Hero_Ronin.Wind_Wall_Cast_Active", self:GetAbility().soundDummy)
            EmitSoundOnLocationWithCaster(parent:GetAbsOrigin(), "Hero_Ronin.Wind_Wall_End" ,self:GetCaster())
            self:GetAbility().soundDummy = nil
        end
        parent:RemoveSelf()
    end
end

modifier_wind_wall_dummy_invulnerability = class({})

function modifier_wind_wall_dummy_invulnerability:CheckState()
    local state = 
    {

        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
    }

    return state
end

modifier_ronin_flux = class({})

function modifier_ronin_flux:DeclareFunctions()
    return {MODIFIER_EVENT_ON_HERO_KILLED}
end

function modifier_ronin_flux:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ronin_flux:IsHidden()
  return true
end

function modifier_ronin_flux:IsPassive()
  return true
end

function modifier_ronin_flux:IsDebuff() 
  return false
end

function modifier_ronin_flux:IsPurgable() 
  return false
end

function modifier_ronin_flux:OnHeroKilled(event)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if event.attacker == caster then
        if not caster:HasModifier("modifier_flux_bonus_stacks") then
            caster:AddNewModifier(caster, ability, "modifier_flux_bonus_stacks", {})
        end
        local current_stacks = caster:GetModifierStackCount("modifier_flux_bonus_stacks", ability)
        caster:SetModifierStackCount("modifier_flux_bonus_stacks", ability, current_stacks + 1)
    end
end