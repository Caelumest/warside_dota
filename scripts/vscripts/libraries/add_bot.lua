function WarsideDotaGameMode:OnGameStateChanged()
  local state = GameRules:State_Get()
  if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
    -- load companions and donators
    -- LoadCompanions()
    print("\n\n\nSTATE CUSTOM SETUP\n\n\n")
    CustomNetTables:SetTableValue("game_options", "donators", CHP_DONATORS)
  elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
    HeroSelection:HeroListPreLoad()
    _G.GoodCamera = Entities:FindByName(nil, "dota_goodguys_fort")
    _G.BadCamera = Entities:FindByName(nil, "dota_badguys_fort")
    print("\n\n\nSTATE HERO SELECTION\n\n\n")
  elseif state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
    print("\n\n\nSTATE STRATEGY TIME\n\n\n")
    local num = 0
    local used_hero_name = "npc_dota_hero_luna"
    local brokenBots = {
      "npc_dota_hero_tidehunter",
      "npc_dota_hero_razor",
      "npc_dota_hero_legion_commander",
      "npc_dota_hero_dragon_knight",
      "npc_dota_hero_lone_druid",
      "npc_dota_hero_keeper_of_the_light",
      "npc_dota_hero_monkey_king"}

    local workingBots = {
      "npc_dota_hero_axe",
      "npc_dota_hero_skywrath_mage",
      "npc_dota_hero_nevermore",
      "npc_dota_hero_pudge",
      "npc_dota_hero_phantom_assassin",
      "npc_dota_hero_skeleton_king",
      "npc_dota_hero_lina",
      "npc_dota_hero_luna",
      "npc_dota_hero_bloodseeker",
      "npc_dota_hero_lion",
      "npc_dota_hero_tiny",
      "npc_dota_hero_oracle",
      "npc_dota_hero_bane",
      "npc_dota_hero_bristleback",
      "npc_dota_hero_chaos_knight",
      "npc_dota_hero_crystal_maiden",
      "npc_dota_hero_dazzle",
      "npc_dota_hero_death_prophet",
      "npc_dota_hero_drow_ranger",
      "npc_dota_hero_earthshaker",
      "npc_dota_hero_jakiro",
      "npc_dota_hero_kunkka",
      "npc_dota_hero_necrolyte",
      "npc_dota_hero_sven",
      "npc_dota_hero_lich",
      "npc_dota_hero_juggernaut",
      "npc_dota_hero_omniknight",
      "npc_dota_hero_sand_king",
      "npc_dota_hero_sniper",
      "npc_dota_hero_vengefulspirit",
      "npc_dota_hero_viper",
      "npc_dota_hero_warlock",
      "npc_dota_hero_witch_doctor",
      "npc_dota_hero_zuus"
    }

    for i=0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayer(i) then
            print(i)
            
            -- Random heroes for people who have not picked
            if PlayerResource:HasSelectedHero(i) == false then
                print("Randoming hero for:", i)
                
                local player = PlayerResource:GetPlayer(i)
                player:MakeRandomHeroSelection()
                
                local hero_name = PlayerResource:GetSelectedHeroName(i)
                
                print("Randomed:", hero_name)
            end
            
            used_hero_name = PlayerResource:GetSelectedHeroName(i)
            num = num + 1
        end
    end
        
    self.numPlayers = num
    print("Number of players:", num)
    for j=1,#brokenBots do
        print("Broken:", brokenBots[j])
    end
    totalplayers = self.numPlayers
    print("TOTAL", totalplayers)
    totalradiant=0
    totaldire=0
    for hel=0,9 do
      local teamss = PlayerResource:GetTeam(hel)
        if teamss == 2 then
          totalradiant = totalradiant + 1
        elseif teamss == 3 then
          totaldire = totaldire + 1
        end
      print("TEAMMMM", teamss)
    end
    print("TOTAL RADIANT", totalradiant)
    print("TOTAL DIRE", totaldire)

      if isBotActive == nil then
        isBotActive = 0
      end
      print("ValorFinal",isBotActive)
        if IsServer() == true and 10 - self.numPlayers > 0 and isBotActive == 1 then
            local mode = GameRules:GetGameModeEntity()
            mode:SetBotThinkingEnabled( true )
            print("Adding bots in empty slots")
            local delay = 0
            local ids = 1
            for i=1, 5 do
              Timers:CreateTimer(HERO_SELECTION_TIME, function ()
                local botsToRadiant = 5 - totalradiant
                local botsToDire = 5 - totaldire
                if botsToRadiant > 0 then
                  print("TOTAL IF", totalplayers)
                  while nomebot == nil or nomebot==PlayerResource:GetSelectedHeroName(0) or nomebot==PlayerResource:GetSelectedHeroName(1) or nomebot==PlayerResource:GetSelectedHeroName(2) or nomebot==PlayerResource:GetSelectedHeroName(3) or nomebot==PlayerResource:GetSelectedHeroName(4) or nomebot==PlayerResource:GetSelectedHeroName(5) or nomebot==PlayerResource:GetSelectedHeroName(6) or nomebot==PlayerResource:GetSelectedHeroName(7) or nomebot==PlayerResource:GetSelectedHeroName(8) or nomebot==PlayerResource:GetSelectedHeroName(9) do
                    randomNum = RandomInt(0,#workingBots)
                    print("Random Number:",randomNum)
                    print("Nomebot inside while",nomebot)
                    nomebot = workingBots[randomNum]
                  end
                  print("Nomebot outside while",nomebot)
                  Tutorial:AddBot(nomebot, "","", true)
                  totalradiant = totalradiant + 1
                  print("Total radiant:", totalradiant)
                end
                if botsToDire > 0 then
                  print("TOTAL IF", totalplayers)
                  while nomebot == nil or nomebot==PlayerResource:GetSelectedHeroName(0) or nomebot==PlayerResource:GetSelectedHeroName(1) or nomebot==PlayerResource:GetSelectedHeroName(2) or nomebot==PlayerResource:GetSelectedHeroName(3) or nomebot==PlayerResource:GetSelectedHeroName(4) or nomebot==PlayerResource:GetSelectedHeroName(5) or nomebot==PlayerResource:GetSelectedHeroName(6) or nomebot==PlayerResource:GetSelectedHeroName(7) or nomebot==PlayerResource:GetSelectedHeroName(8) or nomebot==PlayerResource:GetSelectedHeroName(9) do
                    randomNum = RandomInt(0,#workingBots)
                    print("Random Number:",randomNum)
                    print("Nomebot inside while",nomebot)
                    nomebot = workingBots[randomNum]
                  end
         
                  print("Nomebot outside while",nomebot)
                  Tutorial:AddBot(nomebot, "","", false)
                  totaldire = totaldire + 1
                  print("Total dire:", totaldire)
                end
                delay = delay + 2
              end)
            end
            print("Players total",totalplayers)
            for helper=0,9 do
              print(helper,"<< Num  Hero>>",PlayerResource:GetSelectedHeroName(helper))
         
            end
            --GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
            --SendToServerConsole("dota_bot_populate")
            --SendToServerConsole("dota_bot_set_difficulty 2")
        end
    elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
      print("\n\n\nSTATE PRE GAME\n\n\n")
      Tutorial:StartTutorialMode()
        for i=0, DOTA_MAX_TEAM_PLAYERS do
          if PlayerResource:IsFakeClient(i) == true then
                PlayerResource:GetPlayer(i):GetAssignedHero():SetBotDifficulty(bot_difficulty)
                print("Bot",i,"difficulty setted to:",bot_difficulty)
            end
            if starting_Gold ~= nil then
              PlayerResource:ModifyGold(i, starting_Gold, false, 0);
            end
        end
    end
  end