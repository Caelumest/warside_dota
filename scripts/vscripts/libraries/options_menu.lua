function WarsideDotaGameMode:ToggleStartingGold(event)
  local startingGold = event.startingGold
  
  if tostring(startingGold) == 'GoldOption1' then
    starting_Gold = 600
  elseif tostring(startingGold) == 'GoldOption2' then
    starting_Gold = 1000
  elseif tostring(startingGold) == 'GoldOption3' then
    starting_Gold = 1400
  elseif tostring(startingGold) == 'GoldOption4' then
    starting_Gold = 1800
  elseif tostring(startingGold) == 'GoldOption5' then
    starting_Gold = 2200
  end
  GameRules:SendCustomMessage("Starting Gold = <font color='#0F0'>" .. starting_Gold .."</font>", 2, 1)
  print("START",starting_Gold)
end

function WarsideDotaGameMode:ToggleMultiplierGold(event)
  local multiplierGold = event.multiplierGold

  if tostring(multiplierGold) == 'MultiplierOption1' then
    multiplier_Gold = 1
  elseif tostring(multiplierGold) == 'MultiplierOption2' then
    multiplier_Gold = 2
  elseif tostring(multiplierGold) == 'MultiplierOption3' then
    multiplier_Gold = 3
  elseif tostring(multiplierGold) == 'MultiplierOption4' then
    multiplier_Gold = 4
  end
  GameRules:SendCustomMessage("Gold Multiplier = <font color='#0F0'>" .. multiplier_Gold .."x</font>", 2, 1)
  print("MULT",multiplier_Gold)
end

function WarsideDotaGameMode:ToggleMultiplierExp(event)
  local multiplierExp = event.multiplierExp
  
  if tostring(multiplierExp) == 'ExpOption1' then
    multiplier_Exp = 1
  elseif tostring(multiplierExp) == 'ExpOption2' then
    multiplier_Exp = 2
  elseif tostring(multiplierExp) == 'ExpOption3' then
    multiplier_Exp = 3
  elseif tostring(multiplierExp) == 'ExpOption4' then
    multiplier_Exp = 4
  end
  GameRules:SendCustomMessage("EXP Multiplier = <font color='#0F0'>" .. multiplier_Exp .."x</font>", 2, 1)
  print("MAMAMAMAMAMA",multiplier_Exp)
end

function WarsideDotaGameMode:ToggleBots( event )
  local botsOn = event.botsOn
  if botsOn == 0 then
    isBotActive = 0
    print("Bots OFF")
  elseif botsOn == 1 then
    isBotActive = 1
    print("Bots ON")
  end
end

function WarsideDotaGameMode:OnBotDifficulty( args )

  local botsdifficulty = args.bots_difficulty

  -- If the player who sent the game options is not the host, do nothing
  if tostring(botsdifficulty) == 'BotsOption1' then
    bot_difficulty = 0
  elseif tostring(botsdifficulty) == "BotsOption2" then
    bot_difficulty = 1
  elseif tostring(botsdifficulty) == "BotsOption3" then
    bot_difficulty = 2
  elseif tostring(botsdifficulty) == "BotsOption4" then
    bot_difficulty = 3
  elseif tostring(botsdifficulty) == "BotsOption5" then
    bot_difficulty = 4
  end
  if isBotActive == 1 then
    GameRules:SendCustomMessage("Bots = <font color='#0F0'>ON</font>", 2, 1)
    if bot_difficulty == 0 then
      GameRules:SendCustomMessage("Difficulty = <font color='#00CCCC'>Passive</font>", 2, 1)
    elseif bot_difficulty == 1 then
      GameRules:SendCustomMessage("Difficulty = <font color='#FF9933'>Easy</font>", 2, 1)
    elseif bot_difficulty == 2 then
      GameRules:SendCustomMessage("Difficulty = <font color='#FFFF33'>Medium</font>", 2, 1)
    elseif bot_difficulty == 3 then
      GameRules:SendCustomMessage("Difficulty = <font color='#99FF99'>Hard</font>", 2, 1)
    elseif bot_difficulty == 4 then
      GameRules:SendCustomMessage("Difficulty = <font color='#FF3333'>Unfair</font>", 2, 1)
    end
  elseif isBotActive == 0 or isBotActive == nil then
    print("working properly")
    GameRules:SendCustomMessage("Bots = <font color='#F00'>OFF</font>", 2, 1)
  end
end

function WarsideDotaGameMode:OnPlayerChat(keys)
  local text = keys.text
  local caster = PlayerResource:GetSelectedHeroEntity(keys.playerid)
  local caster_heroname = PlayerResource:GetSelectedHeroName(keys.playerid)
  local team_message = false
--  PrintTable(keys)

  if keys.teamonly == 1 then
    team_message = true
  end

  if caster:HasModifier("modifier_parasight_parasitic_invasion") then
    local target = caster:FindModifierByName("modifier_parasight_parasitic_invasion").target
    Say(PlayerResource:GetPlayer(target:GetPlayerID()), text, team_message)
  end

  -- This Handler is only for commands, ends the function if first character is not "-"
  if not (string.byte(text) == 45) then
    return nil
  end

  for str in string.gmatch(text, "%S+") do
    if IsInToolsMode() or IsDeveloper(keys.playerid) then
      if str == "-replaceherowith" then
        text = string.gsub(text, str, "")
        text = string.gsub(text, " ", "")
        if PlayerResource:GetSelectedHeroName(caster:GetPlayerID()) ~= "npc_dota_hero_"..text then
          if caster.companion then
            caster.companion:ForceKill(false)
            caster.companion = nil
          end

          PrecacheUnitByNameAsync("npc_dota_hero_"..text, function()
            HeroSelection:GiveStartingHero(caster:GetPlayerID(), "npc_dota_hero_"..text, true)
          end)
        end
      end
    end
  end
end
