--[[ Available triggers:
* OnMoveOrder
* OnAttackOrder
* OnBuyback
* OnDeath
* OnSpawn
* OnFirstSpawn
* OnTakeDamage
* OnHeroKill
* OnCreepKill
* OnCreepDeny
* OnAbilityCast
* OnArcaneRune
* OnDoubleDamageRune
* OnBountyRune
* OnHasteRune
* OnIllusionRune
* OnInvisibilityRune
* OnRegenRune
* OnFirstBlood
* OnItemPurchased
* OnItemPickup
* OnVictory
* OnDefeat
]]

local VO_DEFAULT_COOLDOWN = 6

LinkLuaModifier("modifier_responses_single", "scripts/vscripts/modifiers/modifier_responses_single.lua", LUA_MODIFIER_MOTION_NONE)
if AndraxResponses == nil then
    AndraxResponses = class({})
end

function AndraxResponses:Start(hero)
    if not AndraxResponses.started then
        AndraxResponses.started = true
    end
    self.hero = hero
    AndraxResponses.responses = {}

    -- Create dummy with response modifier to hook to events
    --local dummy = CreateUnitByName('npc_dota_thinker', Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS)
    local modifier = hero:AddNewModifier(nil, nil, "modifier_responses_single", {})
    modifier.FireOutput = function(outputName, data) self:FireOutput(outputName, data) end

    -- Listen for unit spawns
    ListenToGameEvent("dota_player_gained_level", function(context, event) self:FireOutput('OnLvlUp', event) end, self)
    ListenToGameEvent("npc_spawned", function(context, event) self:FireOutput('OnUnitSpawn', event) end, self)
    ListenToGameEvent("player_chat", function(context, event) self:FireOutput('OnPlayerChat', event) end, self)
    ListenToGameEvent("dota_rune_activated_server", function(context, event) self:FireOutput('OnRunePickup', event) end, self)
    ListenToGameEvent("dota_item_purchased", function(context, event) self:FireOutput('OnItemBought', event) end, self)
    ListenToGameEvent("dota_inventory_player_got_item", function(context, event) self:FireOutput('GetItemName', event) end, self)
    ListenToGameEvent("dota_item_picked_up", function(context, event) self:FireOutput('OnItemPickup', event) end, self)
    ListenToGameEvent("game_rules_state_change", function(context, event) self:FireOutput('OnGameRulesStateChange', event) end, self)
end
-- Wrap events in dynamic_wraps
function AndraxResponses:FireOutput(outputName, data)
    if AndraxResponses[outputName] ~= nil then
        Dynamic_Wrap(AndraxResponses, outputName)(self, data)
    end
end

function AndraxResponses:RegisterUnit(unitName, configFile)
    -- Load unit config
    AndraxResponses.responses[unitName] = LoadKeyValues(configFile)
    local unitResponses = AndraxResponses.responses[self.hero:GetUnitName()]
    Timers:CreateTimer(1.5, function ()
        --self:TriggerSound("OnFirstSpawn", self.hero, unitResponses)
        --self:TriggerSound("OnFirstSpawn", self.hero, unitResponses)
        self.hero.responseFirstSpawn = true
    end)
end

function AndraxResponses:PlayTrigger(responses, response_rules, unit)
    local lastCast = response_rules.lastCast or 0
    local cooldown = response_rules.Cooldown or VO_DEFAULT_COOLDOWN
    local allChat = response_rules.AllChat or false
    local delay = response_rules.Delay or 0

    -- Priority 0 = follows default cooldown (move & attack)
    -- Priority 1 = follows priority cooldown (abilities, taking damage)
    -- Priority 2 = always triggers (runes, kills/death/respawn, victory/defeat)
    local priority = response_rules.Priority or 0

    --Prevents overlap
    local priorityCooldown = 1.5 + delay

    local lastSound = responses.lastSound or 0
    local lastCooldown = responses.Cooldown or 0 

    local global = true
    if response_rules.Global ~= nil then
        global = response_rules.Global
    end

    if response_rules.Sounds == nil then return end

    -- Check cooldown
    local gameTime = GameRules:GetGameTime()
    if gameTime - lastSound < lastCooldown and priority == 0 then
        return
    end

    if gameTime - lastSound < priorityCooldown and priority < 2 then
        return
    end

    if gameTime - lastCast < cooldown then
        return
    end

    responses.lastSound = gameTime
    if cooldown > VO_DEFAULT_COOLDOWN then
        responses.Cooldown = VO_DEFAULT_COOLDOWN
    else
        responses.Cooldown = cooldown
    end
    response_rules.lastCast = gameTime

    -- Get total weight of sounds
    local total_weight = response_rules.total_weight
    if total_weight == nil then
        response_rules.total_weight = 0
        for sound, weight in pairs(response_rules.Sounds) do
            response_rules.total_weight = response_rules.total_weight + weight
        end
        total_weight = response_rules.total_weight
    end

    -- Selected a sound by weight
    local selection = RandomInt(1, total_weight)
    local count = 0
    for soundName, weight in pairs(response_rules.Sounds) do
        count = count + weight
        if count >= selection then
            return Timers:CreateTimer(delay, function () self:PlaySound(soundName, unit, allChat, global) end)
        end
    end
end

function AndraxResponses:TriggerSound(triggerName, unit, responses)
    local response_rules = responses[triggerName]
    if response_rules ~= nil then
        self:PlayTrigger(responses, response_rules, unit)
    end
end

function AndraxResponses:TriggerSoundSpecial(triggerName, special, unit, responses)
    local response_rules = responses[triggerName]
    if response_rules ~= nil then
        if response_rules[special] then
            self:PlayTrigger(responses, response_rules[special], unit)
        end
    end
end

function AndraxResponses:PlaySound(soundName, unit, allChat, global)
    if allChat and global == true then
        EmitSoundOn(soundName,unit)
    elseif global == 1 then
        EmitAnnouncerSound(soundName)
    elseif global == 2 then
        EmitAnnouncerSoundForTeam(soundName, unit:GetTeam())
    else
        pIDForPlayer = unit:GetPlayerID()
        EmitAnnouncerSoundForPlayer(soundName, pIDForPlayer)
    end
end

--================================================================================
-- EVENT HANDLERS
--================================================================================
function AndraxResponses:OnOrder(order)
    local unitResponses = AndraxResponses.responses[self.hero:GetUnitName()]
    if unitResponses ~= nil and GetKeyValueByHeroName(order.unit:GetUnitName(), "IsCustom") == 1 and order.unit == self.hero then
        -- Move order
        if order.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION
          or order.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
                self:TriggerSound("OnMoveOrder", order.unit, unitResponses)
        end


        -- Attack order
        if order.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET 
            or order.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
            self:TriggerSound("OnAttackOrder", order.unit, unitResponses)
        end

        -- Buyback
        if order.order_type == DOTA_UNIT_ORDER_BUYBACK then
            self:TriggerSound("OnBuyback", order.unit, unitResponses)
            buybackflag = true
        end
    end
end

function AndraxResponses:OnUnitDeath(event)
    -- Unit death
    if event.unit == self.hero then
        event.unit.reincarnateflag = nil
        local unitResponses = AndraxResponses.responses[event.unit:GetUnitName()]
        if unitResponses ~= nil and not event.unit:IsIllusion() and event.unit:IsReincarnating() then
            event.unit.reincarnateflag = true
            self:TriggerSound("OnReincarnate", event.unit, unitResponses)
        elseif unitResponses ~= nil and not event.unit:IsIllusion() then
            self:TriggerSound("OnDeath", event.unit, unitResponses)
        end
    end

    -- Unit kill
    if event.attacker == self.hero then
        unitResponses = AndraxResponses.responses[event.attacker:GetUnitName()]
        if unitResponses ~= nil then
            if event.unit:IsRealHero() then
                if GetTeamHeroKills(DOTA_TEAM_GOODGUYS) + GetTeamHeroKills(DOTA_TEAM_BADGUYS) == 1 then
                    self:TriggerSound("OnFirstBlood", event.attacker, unitResponses)
                else
                    if not event.unit:IsReincarnating() then
                        self:TriggerSound("OnHeroKill", event.attacker, unitResponses)
                    end
                end
            else
                if event.unit:GetTeam() == event.attacker:GetTeam() then
                    if denyFlag == nil then
                        denyFlag = 0
                    end
                    local units = FindUnitsInRadius(event.attacker:GetTeamNumber(), event.unit:GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
                    for _, unit in pairs(units) do
                        denyFlag = denyFlag + 1
                    end
                    if denyFlag > 0 then
                        self:TriggerSound("OnCreepDeny", event.attacker, unitResponses)
                        denyFlag = 0
                    end
                else
                    self:TriggerSound("OnCreepKill", event.attacker, unitResponses)
                end
            end
        end
    end
end

function AndraxResponses:OnUnitSpawn(event)
    local unit = EntIndexToHScript(event.entindex)
    local unitResponses = AndraxResponses.responses[unit:GetUnitName()]

    if unitResponses and unit:IsRealHero() and unit == self.hero then
        if not unit.buybackflag and not unit.reincarnateflag and self.hero.responseFirstSpawn then
            self:TriggerSound("OnSpawn", unit, unitResponses)
        end
        unit.reincarnateflag = nil
        unit.buybackflag = nil
    end
end

function AndraxResponses:OnTakeDamage(event)
    local unitResponses = AndraxResponses.responses[event.unit:GetUnitName()]
    if unitResponses and event.unit:IsRealHero() and event.unit == self.hero then
        -- Only trigger on hero or tower damage
        local attacker = event.attacker
        if attacker then
            if attacker:IsHero() or attacker:IsTower() then
                if attacker ~= event.unit then
                    self:TriggerSound("OnTakeDamage", event.unit, unitResponses)
                end
            end
        end
    end
end

function AndraxResponses:OnAbilityStart(event)
    local unitResponses = AndraxResponses.responses[event.unit:GetUnitName()]
    print("Working ability response")
end

function AndraxResponses:OnAbilityExecuted(event)
    local unitResponses = AndraxResponses.responses[event.unit:GetUnitName()]
    if unitResponses ~= nil and event.unit == self.hero then
        self:TriggerSoundSpecial("OnAbilityCast", event.ability:GetAbilityName(), event.unit, unitResponses)
    end
end

function AndraxResponses:OnRunePickup(event)
    local unit = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local unitResponses = AndraxResponses.responses[unit:GetUnitName()]
    if unitResponses and unit == self.hero then
        if event.rune == DOTA_RUNE_DOUBLEDAMAGE then
            self:TriggerSound("OnDoubleDamageRune", unit, unitResponses)
        elseif event.rune == DOTA_RUNE_HASTE then
            self:TriggerSound("OnHasteRune", unit, unitResponses)
        elseif event.rune == DOTA_RUNE_ILLUSION then
            self:TriggerSound("OnIllusionRune", unit, unitResponses)
        elseif event.rune == DOTA_RUNE_INVISIBILITY then
            self:TriggerSound("OnInvisibilityRune", unit, unitResponses)
        elseif event.rune == DOTA_RUNE_REGENERATION then
            self:TriggerSound("OnRegenRune", unit, unitResponses)
        elseif event.rune == DOTA_RUNE_BOUNTY then
            self:TriggerSound("OnBountyRune", unit, unitResponses)
        elseif event.rune == DOTA_RUNE_ARCANE  then
            self:TriggerSound("OnArcaneRune", unit, unitResponses)
        end
    end
end

function AndraxResponses:OnItemBought(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if GetKeyValueByHeroName(hero:GetUnitName(), "IsCustom") == 1 and hero == self.hero then
        local unitResponses = SageRoninResponses.responses[hero:GetUnitName()]
        function AndraxResponses:GetItemName(event)
            hero.nomeItem = event.itemname
        end
        if unitResponses and hero.nomeItem then
            self:TriggerSoundSpecial("OnItemPurchase", hero.nomeItem, hero, unitResponses)
            hero.nomeItem = nil
        end
    end
end

function AndraxResponses:OnPlayerChat(event)
    local text = event.text
    local hero = PlayerResource:GetSelectedHeroEntity(event.playerid)
    local heroname = hero:GetUnitName()
    local unitResponses = AndraxResponses.responses[hero:GetUnitName()]
    if hero == self.hero then
        if event.teamonly == 1 then
            teamResponse = "Ally"
        else
            teamResponse = "Global"
        end

        if teamResponse == nil then
            teamResponse = ""
        end

        if text:lower() == 'lol' or text:lower() == 'jaja' or text:lower() == 'haha' then
            suffix = "Laugh"
        elseif text:lower() == "ty" or text:lower() == "thx" or text:lower() == "thanks" or text:lower() == "vlw" or text:lower() == "obrigado" or text:lower() == "obg" then
            suffix = "Thanks"
        end
        if suffix and GetKeyValueByHeroName(heroname, "IsCustom") == 1 then
            self:TriggerSound("On"..teamResponse..suffix, hero, unitResponses)
            suffix = nil
        end
    end
end

function AndraxResponses:OnItemPickup(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local item = EntIndexToHScript(event.ItemEntityIndex)
    local unitResponses = SageRoninResponses.responses[hero:GetUnitName()]
    if unitResponses and hero == self.hero then
        if item:GetPurchaser() == hero then
            self:TriggerSoundSpecial("OnItemPickup", event.itemname, hero, unitResponses)
        end
    end
end

function AndraxResponses:OnLvlUp(event)
    if IsInToolsMode() then 
        self.herolvlid = PlayerResource:GetSelectedHeroEntity(event.player-1) 
    else 
        self.herolvlid = PlayerResource:GetSelectedHeroEntity(event.player-2) 
    end
    local hero = self.herolvlid
    local lvl = event.level
    if hero and hero == self.hero then
        local unitResponses = AndraxResponses.responses[hero:GetUnitName()]
        if unitResponses and lvl < 35 then
            self:TriggerSound("OnLvlUp", hero, unitResponses)
        end
    end
end

function AndraxResponses:OnGameRulesStateChange()
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        --local heroes = HeroList:GetAllHeroes()
        --for _, hero in pairs(heroes) do
            -- Check if unit has responses
            --if hero == self.hero then
                local responses = AndraxResponses.responses[self.hero:GetUnitName()]
                self:TriggerSound("OnGameStart", self.hero, responses)
            --end
        --end
        
    end

    if state >= DOTA_GAMERULES_STATE_POST_GAME then
        -- Figure out winner
        local winner = DOTA_TEAM_GOODGUYS
        local ancients = FindUnitsInRadius( self.hero:GetTeam(), Vector(0,0,0), nil, 99999999, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_FARTHEST, false )
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

        -- Loop over heroes
        --local heroes = HeroList:GetAllHeroes()
        --for _, hero in pairs(heroes) do
            -- Check if unit has responses
            local responses = AndraxResponses.responses[self.hero:GetUnitName()]
            if responses then
                -- Figure out win or loss
                if self.winner and self.hero:GetTeam() == self.winner then
                    self:TriggerSound("OnVictory", self.hero, responses)
                else
                    self:TriggerSound("OnDefeat", self.hero, responses)
                end
            end
        --end
    end
end
