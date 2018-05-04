require("lib.timers")
require("lib.responses")
require("libraries/animations")
require("libraries/attachments")
require("libraries/notifications")
if CommunityCustomHeroesGameMode == nil then
	CommunityCustomHeroesGameMode = class({})
end

function Precache(context)
	-- Custom Heroes
	PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
	PrecacheUnitByNameSync("npc_dota_hero_legion_commander", context)
	PrecacheUnitByNameSync("npc_dota_hero_monkey_king", context)
	PrecacheUnitByNameSync("npc_dota_hero_lone_druid", context)
	PrecacheUnitByNameSync("npc_dota_hero_keeper_of_the_light", context)
PrecacheResource( "soundfile", "soundevents/game_sounds_ui_imported.vsndevts", context )
	--Items
	PrecacheItemByNameSync("item_aether_core", context)
  	PrecacheItemByNameSync("item_stout_mail", context)
PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_koh.vsndevts", context )
	--[[ Sobek precache
	PrecacheResource( "particle", "particles/econ/generic/generic_buff_1/generic_buff_1.vpcf", context )
	PrecacheResource( "particle", "particles/items2_fx/medallion_of_courage_friend.vpcf", context )
	PrecacheResource( "particle", "particles/ui_mouseactions/range_finder_ward_aoe_ring.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume_base.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_absorption_base.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_absorption_creep.vpcf", context )
	
	
	PrecacheModel("models/creeps/neutral_creeps/n_creep_kobold/kobold_a/n_creep_kobold_a.vmdl", context)

	-- Parasight precache
	PrecacheResource( "particle", "particles/units/heroes/hero_bane/bane_enfeeble.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile_explosion.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/bane/slumbering_terror/bane_slumber_nightmare.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", context )
	PrecacheResource( "particle", "particles/items_fx/ironwood_tree.vpcf", context )
	PrecacheResource( "particle", "particles/econ/courier/courier_trail_international_2013/courier_international_2013.vpcf", context )
	PrecacheResource( "particle", "particles/world_shrine/radiant_shrine_active.vpc", context )
	PrecacheResource( "particle", "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", context )
	PrecacheResource( "model", "models/items/wards/esl_wardchest_toadstool/esl_wardchest_toadstool.vmdl", context )
	PrecacheResource( "model", "models/items/wards/ward_bramble_snatch/ward_bramble_snatch.vmdl", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_parasight.vsndevts", context )
	
	-- Viscous Ooze precache
	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_viscous_ooze.vsndevts", context )
	PrecacheModel("models/heroes/viscous_ooze/viscous_ooze.vmdl", context)
	PrecacheModel("models/heroes/viscous_ooze/oozeling.vmdl", context)]]
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
	PrecacheUnitByNameSync("npc_dota_hero_kringler",context)
	PrecacheUnitByNameSync("npc_dota_hero_juggernaut",context)


	
		--Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
end

-- Create the game mode when we activate
function Activate()

	
	-- TODO: Remove from finished product, we just want spectators for playtests
	--GameRules:SetCustomGameTeamMaxPlayers(1, 5)
	--GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,5)
	--GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)
	
	GameRules.GameMode = CommunityCustomHeroesGameMode()
	GameRules.GameMode:InitGameMode()
	isBotActive = 0
	local mode = GameRules:GetGameModeEntity()
  	mode:SetBotThinkingEnabled( true )
  	CustomGameEventManager:RegisterListener("set_bots_difficulty", Dynamic_Wrap(CommunityCustomHeroesGameMode, 'OnBotDifficulty'))
  	CustomGameEventManager:RegisterListener("player_toggle_bots", Dynamic_Wrap(CommunityCustomHeroesGameMode, 'ToggleBots'))
  	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CommunityCustomHeroesGameMode, 'OnGameStateChanged' ), self )
end

function CommunityCustomHeroesGameMode:ToggleBots( event )
	local botsOn = event.botsOn
	if botsOn == 0 then
		isBotActive = 0
		print("Bots OFF")
	elseif botsOn == 1 then
		isBotActive = 1
		print("Bots ON")
	end
end

function CommunityCustomHeroesGameMode:OnBotDifficulty( args )

	local botsdifficulty = args.bots_difficulty

	-- If the player who sent the game options is not the host, do nothing
	if tostring(botsdifficulty) == 'BotsOption1' then
		bot_difficulty = 0
		print("BOT DIFFICULTY:", bot_difficulty)
	elseif tostring(botsdifficulty) == "BotsOption2" then
		bot_difficulty = 1
		print("BOT DIFFICULTY:", bot_difficulty)
	elseif tostring(botsdifficulty) == "BotsOption3" then
		bot_difficulty = 2
		print("BOT DIFFICULTY:", bot_difficulty)
	elseif tostring(botsdifficulty) == "BotsOption4" then
		bot_difficulty = 3
		print("BOT DIFFICULTY:", bot_difficulty)
	elseif tostring(botsdifficulty) == "BotsOption5" then
		bot_difficulty = 4
		print("BOT DIFFICULTY:", bot_difficulty)
	end
	GAME_OPTIONS_SET = true
	if isBotActive == 1 then
		if bot_difficulty == 0 then
			GameRules:SendCustomMessage("Bots = <font color='#0F0'>ON</font>", 2, 1)
			GameRules:SendCustomMessage("Difficulty = <font color='#00CCCC'>Passive</font>", 2, 1)
		elseif bot_difficulty == 1 then
			GameRules:SendCustomMessage("Bots = <font color='#0F0'>ON</font>", 2, 1)
			GameRules:SendCustomMessage("Difficulty = <font color='#FF9933'>Easy</font>", 2, 1)
		elseif bot_difficulty == 2 then
			GameRules:SendCustomMessage("Bots = <font color='#0F0'>ON</font>", 2, 1)
			GameRules:SendCustomMessage("Difficulty = <font color='#FFFF33'>Medium</font>", 2, 1)
		elseif bot_difficulty == 3 then
			GameRules:SendCustomMessage("Bots = <font color='#0F0'>ON</font>", 2, 1)
			GameRules:SendCustomMessage("Difficulty = <font color='#99FF99'>Hard</font>", 2, 1)
		elseif bot_difficulty == 4 then
			GameRules:SendCustomMessage("Bots = <font color='#0F0'>ON</font>", DOTA_TEAM_GOODGUYS, 1)
			GameRules:SendCustomMessage("Difficulty = <font color='#FF3333'>Unfair</font>", DOTA_TEAM_GOODGUYS, 1)
		end
	elseif isBotActive == 0 then
		GameRules:SendCustomMessage("Bots = <font color='#F00'>OFF</font>", 2, 1)
	end
end

function CommunityCustomHeroesGameMode:OnGameStateChanged( keys )
    local state = GameRules:State_Get()
    if state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
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
    		isBotActive = 1
    	end
    	print("ValorFinal",isBotActive)
        if IsServer() == true and 10 - self.numPlayers > 0 and isBotActive == 1 then
            print("Adding bots in empty slots")
            for i=1, 5 do
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
    	Tutorial:StartTutorialMode()
        for i=0, DOTA_MAX_TEAM_PLAYERS do
        	if PlayerResource:IsFakeClient(i) == true then
                PlayerResource:GetPlayer(i):GetAssignedHero():SetBotDifficulty(bot_difficulty)
                print("Bot",i,"difficulty setted to:",bot_difficulty)
            end
        end
    end
end

function CommunityCustomHeroesGameMode:InitGameMode()
	print("Loaded CommunityCustomHeroes")

	-- Debug
	-- GameRules:SetPreGameTime(20)

	VoiceResponses:Start()
	VoiceResponses:RegisterUnit("npc_dota_hero_juggernaut", "scripts/responses/juggernaut_responses.txt")
	VoiceResponses:RegisterUnit("npc_dota_hero_treant", "scripts/responses/sobek_responses.txt")
	--CustomGameEventManager:RegisterListener("player_toggle_camera_lock", Dynamic_Wrap(CommunityCustomHeroesGameMode, 'ToggleCameraLock'))
	-- Link modifiers
	LinkLuaModifier("modifier_activatable", "scripts/vscripts/modifiers/modifier_activatable.lua", LUA_MODIFIER_MOTION_NONE)

	-- Listen to game events
	--ListenToGameEvent( "player_toggle_camera_lock", Dynamic_Wrap( CommunityCustomHeroesGameMode, 'ToggleCameraLock' ), self )
	GameRules:SetCustomGameSetupTimeout(60)
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CommunityCustomHeroesGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CommunityCustomHeroesGameMode, "OnEntityKilled" ), self )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(35)
	--GameRules:SetStartingGold(1400)
	--GameRules:SetGoldPerTick(1)
	--GameRules:SetGoldTickTime(0.22)
	-- Set order filter
	--GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CommunityCustomHeroesGameMode, 'OrderFilter'), self)
	-- Set damage filter
	--GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(CommunityCustomHeroesGameMode, 'DamageFilter'), self)


	XP_PER_LEVEL_TABLE = {
	        0, -- 1
	      200, -- 2
	      500, -- 3
	      900, -- 4
	     1400, -- 5
	     2000, -- 6
	     2640, -- 7
	     3300, -- 8
	     3980, -- 9
	     4680, -- 10
	     5400, -- 11
	     6140, -- 12
	     7340, -- 13
	     8565, -- 14
	     9815, -- 15
	    11090, -- 16
	    12390, -- 17
	    13715, -- 18
	    15115, -- 19
	    16605, -- 20
	    18205, -- 21
	    20105, -- 22
	    22305, -- 23
	    24805, -- 24
	    27500, -- 25
	    30000, -- 26
	    32500, -- 27
	    35000, -- 28
	    38500, -- 29
	  	40500, -- 30
	  	43500, -- 31
	  	47500, -- 32
	  	50500, -- 33
	  	53500, -- 34
	  	56500  -- 35
	  }
	  --[[XP_PER_LEVEL_TABLE = {
	        0, -- 1
	      100, -- 2
	      250, -- 3
	      450, -- 4
	     700, -- 5
	     1000, -- 6
	     1320, -- 7
	     1650, -- 8
	     1990, -- 9
	     2340, -- 10
	     2700, -- 11
	     3050, -- 12
	     3500, -- 13
	     4250, -- 14
	     4700, -- 15
	    5500, -- 16
	    6000, -- 17
	    7000, -- 18
	    7515, -- 19
	    8300, -- 20
	    9200, -- 21
	    10000, -- 22
	    11150, -- 23
	    12000, -- 24
	    13500, -- 25
	    15000, -- 26
	    16500, -- 27
	    17500, -- 28
	    19000, -- 29
	  	20500, -- 30
	  	21500, -- 31
	  	23500, -- 32
	  	25500, -- 33
	  	26500, -- 34
	  	28500  -- 35
	  }]]
	  GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)


	  

end

function CommunityCustomHeroesGameMode:OrderFilter(order)
	local target_unit = nil
	if order.entindex_target ~= 0 then
		target_unit = EntIndexToHScript(order.entindex_target)
	end

	-- Check for activatable modifier
	local activationOrders = {
		[DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
		[DOTA_UNIT_ORDER_ATTACK_TARGET] = true
	}

	if order.queue == 0 and activationOrders[order.order_type] and target_unit ~= nil then
		if target_unit.FindModifierByName then
			local modifier = target_unit:FindModifierByName("modifier_activatable")
			if modifier ~= nil then
				local activator = EntIndexToHScript(order.units["0"])
				if not modifier:CanActivate(activator) then
					-- Move on if this can not be activated by this activator
					return true
				end

				if modifier:IsInRange(activator) then
					if modifier:IsCooldownReady() then
						modifier:Activate(activator)
						return false
					end
				else
					ExecuteOrderFromTable({
						UnitIndex = order.units["0"],
						OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
						Position = target_unit:GetAbsOrigin() - (target_unit:GetAbsOrigin() - activator:GetAbsOrigin()):Normalized() * (modifier.distance - 10)
					})

					ExecuteOrderFromTable({
						UnitIndex = order.units["0"],
						OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
						TargetIndex = order.entindex_target,
						Queue = true
					})
					return false
				end
			end
		end
	end

	-- Check for modifier
	for key, unit_index in pairs(order.units) do
		local unit = EntIndexToHScript(order.units["0"])
		local invasion_modifier = unit:FindModifierByName("modifier_parasight_parasitic_invasion")

		if invasion_modifier ~= nil then
			if invasion_modifier:OrderFilter(order) ~= true then
				return false
			end
		end

		local invasion_target_modifier = unit:FindModifierByName("modifier_parasight_parasitic_invasion_target")
		if invasion_target_modifier ~= nil then
			return invasion_target_modifier:OrderFilter(order)
		end
	end

	return true
end

function CommunityCustomHeroesGameMode:ToggleCameraLock( event )
	local pID = event.pID
	local locked = event.locked
	local hero = PlayerResource:GetSelectedHeroEntity( pID )
	if locked == 0 then
		PlayerResource:SetCameraTarget( pID, nil )
	elseif locked == 1 then
		PlayerResource:SetCameraTarget( pID, hero )
	end
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function CommunityCustomHeroesGameMode:OnEntityKilled( event )

    local killedUnit = EntIndexToHScript( event.entindex_killed )
    local killedTeam = killedUnit:GetTeam()
    local hero = EntIndexToHScript( event.entindex_attacker )
    local heroTeam = hero:GetTeam()
    local extraTime = 0 

    if killedUnit:IsRealHero() and killedUnit:GetLevel() > 25 then
        print("Hero has been killed")   

        print(hero:GetLevel())

        SetRespawnTime( killedteam, killedUnit, respawnTime )   
    end
end

function SetRespawnTime( killedTeam, killedUnit, respawnTime )
	if killedUnit:IsReincarnating() ==false then
    	killedUnit:SetTimeUntilRespawn(100)
    end
end

function CommunityCustomHeroesGameMode:DamageFilter(filterTable)
    local damage = filterTable["damage"] --Post reduction
    local ability
    if filterTable["entindex_inflictor_const"] ~= nil then
	    ability = EntIndexToHScript( filterTable["entindex_inflictor_const"] )
	end

    local victim
	if filterTable["entindex_victim_const"] ~= nil then
	    victim = EntIndexToHScript( filterTable["entindex_victim_const"] )
	end
	
    local attacker = EntIndexToHScript( filterTable["entindex_attacker_const"] )
    local damagetype = filterTable["damagetype_const"]

    if IsValidEntity(attacker) and attacker.FindModifierByName then
    	local modifier = attacker:FindModifierByName("modifier_parasight_parasitic_invasion_target")
    	if modifier then
            if damagetype == 1 then -- physical
                damage = damage / (1 - victim:GetPhysicalArmorReduction() / 100 )
            elseif damagetype == 2 then -- magical damage
                damage = damage /  (1 - victim:GetMagicalArmorValue())
            end

            attacker = modifier:GetCaster()

            if ability then
    			ApplyDamage({victim = victim, attacker = attacker, damage = damage, damage_type = damagetype, ability = ability})
    		else 
    			ApplyDamage({victim = victim, attacker = attacker, damage = damage, damage_type = damagetype}) 
    		end

    		return false
		end
    end

    return true
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function CommunityCustomHeroesGameMode:OnNPCSpawned( event )
	spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() and not spawnedUnit:IsClone() and not spawnedUnit:IsIllusion() then
		CheckForInnates(spawnedUnit)
	end

end


function CheckForInnates(spawnedUnit)
	if(spawnedUnit:GetName() == "npc_dota_hero_legion_commander") then
		local innate = spawnedUnit:FindAbilityByName("legion_demon_form")
		if innate then innate:SetLevel(1) end
	elseif(spawnedUnit:GetName() == "npc_dota_hero_dragon_knight") then
		local innate = spawnedUnit:FindAbilityByName("dk_dragon_form")
		if innate then innate:SetLevel(1) end
	elseif(spawnedUnit:GetName() == "npc_dota_hero_monkey_king") then
		local innate = spawnedUnit:FindAbilityByName("mk_sage_form")
		if innate then innate:SetLevel(1) end
	elseif(spawnedUnit:GetName() == "npc_dota_hero_lone_druid") then
		local innate = spawnedUnit:FindAbilityByName("lone_true_form")
		if innate then innate:SetLevel(1) end
	elseif(spawnedUnit:GetName() == "npc_dota_hero_keeper_of_the_light") then
		local innate = spawnedUnit:FindAbilityByName("spirit_form")
		if innate then innate:SetLevel(1) end
	elseif(spawnedUnit:GetName() == "npc_dota_hero_juggernaut") then
 		--AddAnimationTranslate(spawnedUnit, "arcana")
 	end
end



function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
	armor_reduction = 100 - (armor_reduction * 100)
	return armor_reduction
end
