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

LinkLuaModifier("modifier_responses", "scripts/vscripts/modifiers/modifier_responses.lua", LUA_MODIFIER_MOTION_NONE)
if VoiceResponses == nil then
    VoiceResponses = class({})
end

function VoiceResponses:Start()
    if not VoiceResponses.started then
        VoiceResponses.started = true
    end

    VoiceResponses.responses = {}

    -- Create dummy with response modifier to hook to events
    local dummy = CreateUnitByName('npc_dota_thinker', Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS)
    local modifier = dummy:AddNewModifier(nil, nil, "modifier_responses", {})
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
function VoiceResponses:FireOutput(outputName, data)
    if VoiceResponses[outputName] ~= nil then
        Dynamic_Wrap(VoiceResponses, outputName)(self, data)
    end
end

function VoiceResponses:RegisterUnit(unitName, configFile)
    -- Load unit config
    VoiceResponses.responses[unitName] = LoadKeyValues(configFile)
end

function VoiceResponses:PlayTrigger(responses, response_rules, unit)
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

function VoiceResponses:TriggerSound(triggerName, unit, responses)
    local response_rules = responses[triggerName]
    if response_rules ~= nil then
        self:PlayTrigger(responses, response_rules, unit)
    end
end

function VoiceResponses:TriggerSoundSpecial(triggerName, special, unit, responses)
    local response_rules = responses[triggerName]
    if response_rules ~= nil then
        if response_rules[special] then
            self:PlayTrigger(responses, response_rules[special], unit)
        end
    end
end

function VoiceResponses:PlaySound(soundName, unit, allChat, global)
    print("Playing sound", soundName, allChat, global, unit)
    if allChat and global == true then
        print("ALLCHAT")
        EmitSoundOn(soundName,unit)
    elseif global == 1 then
        print("TRUE GLOBAL")
        EmitAnnouncerSound(soundName)
    elseif global == 2 then
        print("GLOBAL TEAM")
        EmitAnnouncerSoundForTeam(soundName, unit:GetTeam())
    else
        print("ONLY FOR PLAYER")
        if IsInToolsMode() then
            pIDForPlayer = unit:GetPlayerOwnerID()
        else
            pIDForPlayer = unit:GetPlayerOwnerID() + 1
        end
        EmitAnnouncerSoundForPlayer(soundName, pIDForPlayer)
    end
end

--================================================================================
-- EVENT HANDLERS
--================================================================================
function VoiceResponses:OnOrder(order)
    local unitResponses = VoiceResponses.responses[order.unit:GetUnitName()]
    print("UNITRES", unitResponses)
    if unitResponses ~= nil and GetKeyValueByHeroName(order.unit:GetUnitName(), "IsCustom") == 1 then
        -- Move order
        if order.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION
          or order.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
            if order.unit.moveFlag == nil then
                order.unit.moveFlag = 0
            end

            if order.unit.moveFlag == 0 and order.unit:GetUnitName() == "npc_dota_hero_krigler" and order.unit.metCasalmar == nil then
                order.unit.moveFlag = 1
                local random = RandomInt(1, 5)
                local units = FindUnitsInRadius(order.unit:GetTeamNumber(), order.unit:GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
                for _, unit in pairs(units) do
                    if unit:GetUnitName() == "npc_dota_hero_casalmar" and random == 1 then
                        order.unit.metCasalmar = true
                        print("ACHOCASAMO")
                    end
                end
                print("CASAMO")
                Timers:CreateTimer(10, function () order.unit.moveFlag = 0 end)
            end

            if order.unit.metCasalmar == true and order.unit.casalmarFlag == nil then
                self:TriggerSound("OnMeetCasalmar", order.unit, unitResponses)
                order.unit.casalmarFlag = 1
            else
                self:TriggerSound("OnMoveOrder", order.unit, unitResponses)
            end
        end


        -- Attack order
        if order.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET 
            or order.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
            self:TriggerSound("OnAttackOrder", order.unit, unitResponses)
            print("ATTACK")
        end

        -- Buyback
        if order.order_type == DOTA_UNIT_ORDER_BUYBACK then
            self:TriggerSound("OnBuyback", order.unit, unitResponses)
            print("BUYBACK")
            buybackflag = 1
        end
    end
end

function VoiceResponses:OnUnitDeath(event)
    -- Unit death
    if reincarnateflag == nil then
        reincarnateflag = 0
    end
    local unitResponses = VoiceResponses.responses[event.unit:GetUnitName()]
    if unitResponses ~= nil and not event.unit:IsIllusion() and event.unit:IsReincarnating() then
        reincarnateflag = 1  
        self:TriggerSound("OnReincarnate", event.unit, unitResponses)
        Timers:CreateTimer(7, function () reincarnateflag = 0 end)
    elseif unitResponses ~= nil and not event.unit:IsIllusion() then
        self:TriggerSound("OnDeath", event.unit, unitResponses)
    end

    -- Unit kill
    if event.attacker then
        unitResponses = VoiceResponses.responses[event.attacker:GetUnitName()]
        if unitResponses ~= nil then
            if event.unit:IsRealHero() then
                if GetTeamHeroKills(DOTA_TEAM_GOODGUYS) + GetTeamHeroKills(DOTA_TEAM_BADGUYS) == 1 then
                    self:TriggerSound("OnFirstBlood", event.attacker, unitResponses)
                else
                    local random = RandomInt(1, 3) --Add a 33% chance to occur
                    print(random)
                    if event.attacker:GetUnitName() == "npc_dota_hero_krigler" and random == 3 then
                        if event.unit:GetUnitName() == "npc_dota_hero_viper" then
                            self:TriggerSound("OnKillViper", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_casalmar" then
                            self:TriggerSound("OnKillCasalmar", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_omniknight" then
                            self:TriggerSound("OnKillOmni", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_skeleton_king" then
                            self:TriggerSound("OnKillWk", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_pudge" then
                            self:TriggerSound("OnKillPudge", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_alchemist" then
                            self:TriggerSound("OnKillAlche", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_sniper" then
                            self:TriggerSound("OnKillSniper", event.attacker, unitResponses)
                        elseif event.unit:IsReincarnating() == false then
                            self:TriggerSound("OnHeroKill", event.attacker, unitResponses)
                        end
                    elseif event.unit:IsReincarnating() == false then
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

function VoiceResponses:OnUnitSpawn(event)
    local unit = EntIndexToHScript(event.entindex)
    local unitResponses = VoiceResponses.responses[unit:GetUnitName()]

    if unitResponses ~= nil and not unit:IsIllusion() then
        -- Check first spawn or not
        if buybackflag == nil then
            Timers:CreateTimer(5, function () 
                buybackflag = 0  
                print("BB FLAG", buybackflag)
                end)
        end
        if unit._responseFirstSpawn == true and buybackflag == 0 and reincarnateflag == 0 then
            self:TriggerSound("OnSpawn", unit, unitResponses)
            buybackflag = 0
        elseif unit._responseFirstSpawn == nil then
            self:TriggerSound("OnFirstSpawn", unit, unitResponses)
            unit._responseFirstSpawn = true
        end
    end
end

function VoiceResponses:OnTakeDamage(event)
    local unitResponses = VoiceResponses.responses[event.unit:GetUnitName()]
    if unitResponses ~= nil and not event.unit:IsIllusion() then
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

function VoiceResponses:OnAbilityStart(event)
    local unitResponses = VoiceResponses.responses[event.unit:GetUnitName()]
    print("Working ability response")
end

function VoiceResponses:OnAbilityExecuted(event)
    local unitResponses = VoiceResponses.responses[event.unit:GetUnitName()]
    if unitResponses ~= nil then
        self:TriggerSoundSpecial("OnAbilityCast", event.ability:GetAbilityName(), event.unit, unitResponses)
    end
end

function VoiceResponses:OnRunePickup(event)
    local unit = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local unitResponses = VoiceResponses.responses[unit:GetUnitName()]
    if unitResponses then
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

function VoiceResponses:OnItemBought(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if GetKeyValueByHeroName(hero:GetUnitName(), "IsCustom") == 1 then
        print("ASDASDAS",event.PlayerID)
        local unitResponses = VoiceResponses.responses[hero:GetUnitName()]
        function VoiceResponses:GetItemName(event)
            hero.nomeItem = event.itemname
            print(hero.nomeItem)
        end
        if unitResponses and hero.nomeItem then
            self:TriggerSoundSpecial("OnItemPurchase", hero.nomeItem, hero, unitResponses)
            hero.nomeItem = nil
        end
    end
end

function VoiceResponses:OnPlayerChat(event)
    local text = event.text
    local hero = PlayerResource:GetSelectedHeroEntity(event.playerid)
    local heroname = PlayerResource:GetSelectedHeroName(event.playerid)
    local unitResponses = VoiceResponses.responses[hero:GetUnitName()]

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

function VoiceResponses:OnItemPickup(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local item = EntIndexToHScript(event.ItemEntityIndex)
    print(event.PlayerID)
    local unitResponses = VoiceResponses.responses[hero:GetUnitName()]
    if unitResponses then
        if item:GetPurchaser() == hero then
            self:TriggerSoundSpecial("OnItemPickup", event.itemname, hero, unitResponses)
        end
    end
end

function VoiceResponses:OnLvlUp(event)
    if IsInToolsMode() then 
        herolvlid = PlayerResource:GetSelectedHeroEntity(event.player-1) 
    else 
        herolvlid = PlayerResource:GetSelectedHeroEntity(event.player-2) 
    end
    local hero = herolvlid
    local lvl = event.level
    if hero then
        print(event.player)
        print(hero:GetUnitName(),",", lvl,",",event.player)
        local unitResponses = VoiceResponses.responses[hero:GetUnitName()]
        if unitResponses and lvl < 35 then
            self:TriggerSound("OnLvlUp", hero, unitResponses)
        end
    end
end

function VoiceResponses:OnGameRulesStateChange()
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        local heroes = HeroList:GetAllHeroes()
        for _, hero in pairs(heroes) do
            -- Check if unit has responses
            local responses = VoiceResponses.responses[hero:GetUnitName()]
            if responses then
                self:TriggerSound("OnGameStart", hero, responses)
                print("AAASDASD")
            end
        end
        
    end

    if state >= DOTA_GAMERULES_STATE_POST_GAME then
        -- Figure out winner
        local winner = DOTA_TEAM_GOODGUYS
        local ancients = Entities:FindAllByClassname("npc_dota_fort")
        if ancients[1] then
            winner = ancients[1]:GetTeam()
        end

        -- Loop over heroes
        local heroes = HeroList:GetAllHeroes()
        for _, hero in pairs(heroes) do
            -- Check if unit has responses
            local responses = VoiceResponses.responses[hero:GetUnitName()]
            if responses then
                -- Figure out win or loss
                if hero:GetTeam() == winner then
                    self:TriggerSound("OnVictory", hero, responses)
                else
                    self:TriggerSound("OnDefeat", hero, responses)
                end
            end
        end
    end
end
