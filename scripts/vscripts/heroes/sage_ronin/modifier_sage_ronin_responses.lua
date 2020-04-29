modifier_sage_ronin_responses = class({})

-- Hidden, permanent, not purgable
function modifier_sage_ronin_responses:IsHidden() return true end
function modifier_sage_ronin_responses:IsPurgable() return false end
function modifier_sage_ronin_responses:IsPermanent() return true end

function modifier_sage_ronin_responses:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_RESPAWN,
    }
end

function modifier_sage_ronin_responses:OnCreated()
    self:StartIntervalThink(0.4)
    self.lastHitCooldown = 0
    self.pidtest = -3
    self.takenDamageCooldown = 0
end

function modifier_sage_ronin_responses:OnIntervalThink()
    local caster = self:GetCaster()
    local currentLevel = caster:GetLevel()
    if not self.oldLevel then self.oldLevel = caster:GetLevel() end
    if currentLevel ~= self.oldLevel then
        self.oldLevel = nil
        caster.responseCooldown = GameRules:GetGameTime() + 8
        Timers:CreateTimer(1.2, function ()
            if IsInToolsMode() then
                EmitAnnouncerSoundForPlayer("sage_ronin_lvlup", self:GetCaster():GetPlayerID())
            else
                EmitAnnouncerSoundForPlayer("sage_ronin_lvlup", self:GetCaster():GetPlayerID())
            end
        end)
    end
    --Lasthits
    --[[if self.lastHitCooldown <= GameRules:GetGameTime() then
        self.lastHits = GetLastHits(caster:GetPlayerID()-1)
        if not self.lastHits then self.lastHits = 0 end
        if not self.oldLastHits then self.oldLastHits = self.lastHits end
        if self.lastHits > self.oldLastHits then
            self.oldLastHits = nil
            caster.responseCooldown = GameRules:GetGameTime() + 8
            self.lastHitCooldown = GameRules:GetGameTime() + 20
            EmitAnnouncerSoundForPlayer("sage_ronin_lasthit", caster:GetPlayerID())
        end
    end]]

    local state = GameRules:State_Get()
    if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and not self.gameInProgress then
        self.gameInProgress = true
        caster.responseCooldown = GameRules:GetGameTime() + 8
        Timers:CreateTimer(0.8, function ()
            if IsInToolsMode() then
                EmitAnnouncerSoundForPlayer("sage_ronin_battle_begin", self:GetCaster():GetPlayerID())
            else
                EmitAnnouncerSoundForPlayer("sage_ronin_battle_begin", self:GetCaster():GetPlayerID())
            end
        end)
    end
    --print("DESGRACA", state, DOTA_GAMERULES_STATE_POST_GAME, self.postGame)
    if state >= 9 and not self.postGame then
        self.postGame = true
        local winner = DOTA_TEAM_GOODGUYS
        local ancients = FindUnitsInRadius( caster:GetTeam(), Vector(0,0,0), nil, 99999999, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_FARTHEST, false )
        for _,anc in pairs(ancients)do
            if anc:GetUnitName() == "npc_dota_badguys_fort" then
                self.ancient = anc
            elseif anc:GetUnitName() == "npc_dota_goodguys_fort" then
                self.ancient = anc
            end
        end

        if self.ancient then
            self.winner = self.ancient:GetTeam()
        end
                -- Figure out win or loss
        if self.winner and caster:GetTeam() == self.winner then
            Timers:CreateTimer(8, function ()
                if IsInToolsMode() then
                    EmitAnnouncerSoundForPlayer("sage_ronin_victory", self:GetCaster():GetPlayerID())
                else
                    EmitAnnouncerSoundForPlayer("sage_ronin_victory", self:GetCaster():GetPlayerID())
                end
            end)
        else
            Timers:CreateTimer(8, function ()
                if IsInToolsMode() then
                    EmitAnnouncerSoundForPlayer("sage_ronin_defeat", self:GetCaster():GetPlayerID())
                else
                    EmitAnnouncerSoundForPlayer("sage_ronin_defeat", self:GetCaster():GetPlayerID())
                end
            end)
        end
    end
end

function modifier_sage_ronin_responses:OnRespawn(event)
    if event.unit == self:GetCaster() then
        self:GetCaster().responseCooldown = GameRules:GetGameTime() + 8
        if not self.firstSpawned then
            self.firstSpawned = true
            Timers:CreateTimer(1, function ()
                if IsInToolsMode() then
                    EmitAnnouncerSoundForPlayer("sage_ronin_first_spawn", self:GetCaster():GetPlayerID())
                else
                    EmitAnnouncerSoundForPlayer("sage_ronin_first_spawn", self:GetCaster():GetPlayerID())
                end
            end)
        else
            Timers:CreateTimer(1, function ()
                --self.pidtest = self.pidtest + 1
                --if self.pidtest > 5 then self.pidtest = -1 end
                --GameRules:SendCustomMessage("PID: " .. self.pidtest .. " ID: " .. self:GetCaster():GetPlayerID() .."</font>", 2, 1)
                if IsInToolsMode() then
                    EmitAnnouncerSoundForPlayer("sage_ronin_respawn", self:GetCaster():GetPlayerID())
                else
                    EmitAnnouncerSoundForPlayer("sage_ronin_respawn", self:GetCaster():GetPlayerID())
                end
            end)
        end
    end
end

function modifier_sage_ronin_responses:OnOrder(order)
    if order.unit:GetUnitName() == self:GetCaster():GetUnitName() then
        --GameRules:SendCustomMessage("Starting Gold = <font color='#0F0'>" .. self:GetCaster():GetUnitName() .. " ID: " .. self:GetCaster():GetPlayerID() .."</font>", 2, 1)
        local gameTime = GameRules:GetGameTime()
        if not order.unit.responseCooldown then
            order.unit.responseCooldown = GameRules:GetGameTime() + 8
        end
        if order.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION
          or order.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then

            if not order.unit.moveFlag then
                order.unit.moveFlag = true
                if not order.unit.metSkywrath or not order.unit.metZeus then
                    local random = RandomInt(1, 5)
                    local units = FindUnitsInRadius(order.unit:GetTeamNumber(), order.unit:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
                    for _, unit in pairs(units) do
                        if unit:GetUnitName() == "npc_dota_hero_skywrath_mage" and random == 1 and not order.unit.metSkywrath then
                            order.unit.metSkywrath = true
                        elseif unit:GetUnitName() == "npc_dota_hero_zuus" and random == 1 and not order.unit.metZeus then
                            order.unit.metZeus = true
                        end
                    end
                    Timers:CreateTimer(10, function () order.unit.moveFlag = nil end)
                end
            end

            if order.unit.metSkywrath == true then
                if IsInToolsMode() then
                    EmitAnnouncerSoundForPlayer("sage_ronin_meet_skywrath", self:GetCaster():GetPlayerID())
                else
                    EmitAnnouncerSoundForPlayer("sage_ronin_meet_skywrath", self:GetCaster():GetPlayerID())
                end
                order.unit.metSkywrath = 0
            elseif order.unit.metZeus == true then
                if IsInToolsMode() then
                    EmitAnnouncerSoundForPlayer("sage_ronin_meet_zeus", self:GetCaster():GetPlayerID())
                else
                    EmitAnnouncerSoundForPlayer("sage_ronin_meet_zeus", self:GetCaster():GetPlayerID())
                end
                order.unit.metZeus = 0
            else
                if order.unit.responseCooldown <= gameTime then
                    order.unit.responseCooldown = nil
                    if IsInToolsMode() then
                        EmitAnnouncerSoundForPlayer("sage_ronin_move", self:GetCaster():GetPlayerID())
                    else
                        EmitAnnouncerSoundForPlayer("sage_ronin_move", self:GetCaster():GetPlayerID())
                    end
                end
            end
        end


        -- Attack order
        if order.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET 
            or order.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
            if order.unit.responseCooldown <= gameTime then
                order.unit.responseCooldown = nil
                if IsInToolsMode() then
                    EmitAnnouncerSoundForPlayer("sage_ronin_attack", self:GetCaster():GetPlayerID())
                else
                    EmitAnnouncerSoundForPlayer("sage_ronin_attack", self:GetCaster():GetPlayerID())
                end
            end
            --print("ATTACK")
        end

        -- Buyback
        if order.order_type == DOTA_UNIT_ORDER_BUYBACK then
            EmitAnnouncerSound("sage_ronin_respawn")
            order.unit.buybackflag = true
        end
    end
end

function modifier_sage_ronin_responses:OnDeath(event)
end

function modifier_sage_ronin_responses:OnTakeDamage(event)
    local caster = self:GetCaster()
    if self.takenDamageCooldown <= GameRules:GetGameTime() and event.unit == caster then
        if event.attacker:IsHero() or event.attacker:IsTower() then
            caster.responseCooldown = GameRules:GetGameTime() + 8
            self.takenDamageCooldown = GameRules:GetGameTime() + 20
            if IsInToolsMode() then
                EmitAnnouncerSoundForPlayer("sage_ronin_pain", self:GetCaster():GetPlayerID())
            else
                EmitAnnouncerSoundForPlayer("sage_ronin_pain", self:GetCaster():GetPlayerID())
            end
        end
    end
end

function modifier_sage_ronin_responses:OnAbilityExecuted(event)
end
