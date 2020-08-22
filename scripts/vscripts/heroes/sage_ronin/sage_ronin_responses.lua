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

local VO_DEFAULT_COOLDOWN = 8

LinkLuaModifier("modifier_responses_single", "scripts/vscripts/modifiers/modifier_responses_single.lua", LUA_MODIFIER_MOTION_NONE)
if SageRoninResponses == nil then
    SageRoninResponses = class({})
end

function SageRoninResponses:Start(hero)
    if not SageRoninResponses.started then
        SageRoninResponses.started = true
    end
    self.hero = hero
    SageRoninResponses.responses = {}

    -- Create dummy with response modifier to hook to events
    --local dummy = CreateUnitByName('npc_dota_thinker', Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS)
    local modifier = hero:AddNewModifier(hero, nil, "modifier_responses_single", {})
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
function SageRoninResponses:FireOutput(outputName, data)
    if SageRoninResponses[outputName] ~= nil then
        Dynamic_Wrap(SageRoninResponses, outputName)(self, data)
    end
end

function SageRoninResponses:RegisterUnit(unitName, configFile)
    -- Load unit config
    SageRoninResponses.responses[unitName] = LoadKeyValues(configFile)
    local unitResponses = SageRoninResponses.responses[self.hero:GetUnitName()]
    Timers:CreateTimer(1.5, function ()
        --self:TriggerSound("OnFirstSpawn", self.hero, unitResponses)
        --self:TriggerSound("OnFirstSpawn", self.hero, unitResponses)
        self.hero.responseFirstSpawn = true
    end)
end

function SageRoninResponses:PlayTrigger(responses, response_rules, unit)
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

function SageRoninResponses:TriggerSound(triggerName, unit, responses)
    local response_rules = responses[triggerName]
    if response_rules ~= nil then
        self:PlayTrigger(responses, response_rules, unit)
    end
end

function SageRoninResponses:TriggerSoundSpecial(triggerName, special, unit, responses)
    local response_rules = responses[triggerName]
    if response_rules ~= nil then
        if response_rules[special] then
            self:PlayTrigger(responses, response_rules[special], unit)
        end
    end
end

function SageRoninResponses:PlaySound(soundName, unit, allChat, global)
    --print("Playing sound", soundName, allChat, global, unit)
    if allChat and global == true then
        EmitSoundOn(soundName,unit)
    elseif global == 1 then
        EmitAnnouncerSound(soundName)
    elseif global == 2 then
        EmitAnnouncerSoundForTeam(soundName, unit:GetTeam())
    else
        --if IsInToolsMode() then
            pIDForPlayer = unit:GetPlayerID()
        --else
        --    pIDForPlayer = unit:GetPlayerOwnerID() + 1
        --end
        EmitAnnouncerSoundForPlayer(soundName, pIDForPlayer)
    end
end

--================================================================================
-- EVENT HANDLERS
--================================================================================


function SageRoninResponses:OnUnitDeath(event)
    -- Unit death
    if event.unit == self.hero then
        event.unit.reincarnateflag = nil
        local unitResponses = SageRoninResponses.responses[event.unit:GetUnitName()]
        if unitResponses ~= nil and not event.unit:IsIllusion() and event.unit:IsReincarnating() then
            event.unit.reincarnateflag = true
            self:TriggerSound("OnReincarnate", event.unit, unitResponses)
        elseif unitResponses ~= nil and not event.unit:IsIllusion() then
            self:TriggerSound("OnDeath", event.unit, unitResponses)
        end
    end

    -- Unit kill
    if event.attacker == self.hero then
        unitResponses = SageRoninResponses.responses[event.attacker:GetUnitName()]
        if unitResponses ~= nil then
            if event.unit:IsRealHero() then
                if GetTeamHeroKills(DOTA_TEAM_GOODGUYS) + GetTeamHeroKills(DOTA_TEAM_BADGUYS) == 1 then
                    self:TriggerSound("OnFirstBlood", event.attacker, unitResponses)
                else
                    local random = RandomInt(2, 3) --Add a 33% chance to occur
                    if random == 3 then
                        if event.unit:GetUnitName() == "npc_dota_hero_juggernaut" or event.unit:GetUnitName() == "npc_dota_hero_krigler" then
                            self:TriggerSound("OnKillJuggernaut", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_dragon_knight" or event.unit:GetUnitName() == "npc_dota_hero_lycan" or event.unit:GetUnitName() == "npc_dota_hero_morphling" or event.unit:GetUnitName() == "npc_dota_hero_lone_druid" then
                            self:TriggerSound("OnKillShapeshifter", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_nevermore" then
                            self:TriggerSound("OnKillDarker", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_oracle" then
                            self:TriggerSound("OnKillOracle", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_ember_spirit" then
                            self:TriggerSound("OnKillEmber", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_antimage" then
                            self:TriggerSound("OnKillAntimage", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_sven" then
                            self:TriggerSound("OnKillSven", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_lion" or event.unit:GetUnitName() == "npc_dota_hero_terrorblade" or event.unit:GetUnitName() == "npc_dota_hero_lion" or event.unit:GetUnitName() == "npc_dota_hero_doom_bringer" then
                            self:TriggerSound("OnKillDemon", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_skywrath_mage" then
                            self:TriggerSound("OnKillSky", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_ogre_magi" or event.unit:GetUnitName() == "npc_dota_hero_jakiro" or event.unit:GetUnitName() == "npc_dota_hero_alchemist" then
                            self:TriggerSound("OnKillTwins", event.attacker, unitResponses)
                        elseif event.unit:GetUnitName() == "npc_dota_hero_keeper_of_the_light" or event.unit:GetUnitName() == "npc_dota_hero_wisp" or event.unit:GetUnitName() == "npc_dota_hero_chen" then
                            self:TriggerSound("OnKillLightHeroes", event.attacker, unitResponses)
                        elseif not event.unit:IsReincarnating() then
                            self:TriggerSound("OnHeroKill", event.attacker, unitResponses)
                        end
                    elseif not event.unit:IsReincarnating() then
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
                end
            end
        end
    end
end


function SageRoninResponses:OnAbilityStart(event)
    local unitResponses = SageRoninResponses.responses[event.unit:GetUnitName()]
    print("Working ability response")
end

function SageRoninResponses:OnAbilityExecuted(event)
    local unitResponses = SageRoninResponses.responses[event.unit:GetUnitName()]
    if unitResponses ~= nil and event.unit == self.hero then
        self:TriggerSoundSpecial("OnAbilityCast", event.ability:GetAbilityName(), event.unit, unitResponses)
    end
end

function SageRoninResponses:OnRunePickup(event)
    local unit = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local unitResponses = SageRoninResponses.responses[unit:GetUnitName()]
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

function SageRoninResponses:OnItemBought(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if GetKeyValueByHeroName(hero:GetUnitName(), "IsCustom") == 1 and hero == self.hero then
        local unitResponses = SageRoninResponses.responses[hero:GetUnitName()]
        function SageRoninResponses:GetItemName(event)
            hero.nomeItem = event.itemname
            --print(hero.nomeItem)
        end
        if unitResponses and hero.nomeItem then
            self:TriggerSoundSpecial("OnItemPurchase", hero.nomeItem, hero, unitResponses)
            hero.nomeItem = nil
        end
    end
end

function SageRoninResponses:OnPlayerChat(event)
    local text = event.text
    local hero = PlayerResource:GetSelectedHeroEntity(event.playerid)
    local heroname = hero:GetUnitName()
    local unitResponses = SageRoninResponses.responses[hero:GetUnitName()]
    if hero == self.hero then
        if event.teamonly == 1 then
            teamResponse = "Ally"
        else
            teamResponse = "Global"
        end

        if teamResponse == nil then
            teamResponse = ""
        end
        if text:lower() == '123teste' then
            if not self.testeId then
                self.testeId = -5
            end
            if self.testeId >= 10 then
                self.testeId = -5
            end
            print("teste123", hero:GetPlayerID(), self.testeId)
            EmitAnnouncerSoundForPlayer("sage_ronin_lvlup", self.testeId)
            self.testeId = self.testeId + 1
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

function SageRoninResponses:OnItemPickup(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local item = EntIndexToHScript(event.ItemEntityIndex)
    local unitResponses = SageRoninResponses.responses[hero:GetUnitName()]
    if unitResponses and hero == self.hero then
        if item:GetPurchaser() == hero then
            self:TriggerSoundSpecial("OnItemPickup", event.itemname, hero, unitResponses)
        end
    end
end
