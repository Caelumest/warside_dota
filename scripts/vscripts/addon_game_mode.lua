require("lib.timers")
require("lib.responses")

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

	--Items
	PrecacheItemByNameSync("item_aether_core", context)
  	PrecacheItemByNameSync("item_stout_mail", context)
	-- Sobek precache
	PrecacheResource( "particle", "particles/econ/generic/generic_buff_1/generic_buff_1.vpcf", context )
	PrecacheResource( "particle", "particles/items2_fx/medallion_of_courage_friend.vpcf", context )
	PrecacheResource( "particle", "particles/ui_mouseactions/range_finder_ward_aoe_ring.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume_base.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_absorption_base.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_sobek/sobek_absorption_creep.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_ui_imported.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_koh.vsndevts", context )
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
	PrecacheUnitByNameSync("npc_dota_hero_venomancer",context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_viscous_ooze.vsndevts", context )
	PrecacheModel("models/heroes/viscous_ooze/viscous_ooze.vmdl", context)
	PrecacheModel("models/heroes/viscous_ooze/oozeling.vmdl", context)



	
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

	local mode = GameRules:GetGameModeEntity()
  	mode:SetBotThinkingEnabled( true )
  	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CommunityCustomHeroesGameMode, 'OnGameStateChanged' ), self )
end

function CommunityCustomHeroesGameMode:OnGameStateChanged( keys )
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        local num = 0
        local used_hero_name = "npc_dota_hero_luna"
        
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

        -- Eanble bots and fill empty slots
        if IsServer() == true and 10 - self.numPlayers > 0 then
            print("Adding bots in empty slots")
            
            for i=1, 5 do
                Tutorial:AddBot(used_hero_name, "", "", true)
                Tutorial:AddBot(used_hero_name, "", "", false)
            end
            
            GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
            --SendToServerConsole("dota_bot_set_difficulty 2")
            --SendToServerConsole("dota_bot_populate")
            --SendToServerConsole("dota_bot_set_difficulty 2")
        end
    elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
        --for i=0, DOTA_MAX_TEAM_PLAYERS do
            --print(i)
            --if PlayerResource:IsFakeClient(i) then
                --print(i)
                --PlayerResource:GetPlayer(i):GetAssignedHero():SetBotDifficulty(4)
            --end
        --end
        Tutorial:StartTutorialMode()
    end
end

function CommunityCustomHeroesGameMode:InitGameMode()
	print("Loaded CommunityCustomHeroes")

	-- Debug
	-- GameRules:SetPreGameTime(20)

	--VoiceResponses:Start()
	--VoiceResponses:RegisterUnit("npc_dota_hero_windrunner", "scripts/responses/sobek_responses.txt")
	--VoiceResponses:RegisterUnit("npc_dota_hero_treant", "scripts/responses/parasight_responses.txt")

	-- Link modifiers
	LinkLuaModifier("modifier_activatable", "scripts/vscripts/modifiers/modifier_activatable.lua", LUA_MODIFIER_MOTION_NONE)

	-- Listen to game events
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CommunityCustomHeroesGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CommunityCustomHeroesGameMode, "OnEntityKilled" ), self )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(35)
	GameRules:SetStartingGold(1400)
	GameRules:SetGoldPerTick(1)
	GameRules:SetGoldTickTime(0.22)
	-- Set order filter
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CommunityCustomHeroesGameMode, 'OrderFilter'), self)
	-- Set damage filter
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(CommunityCustomHeroesGameMode, 'DamageFilter'), self)


	--[[XP_PER_LEVEL_TABLE = {
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
	  }]]--
	  XP_PER_LEVEL_TABLE = {
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
	  }
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

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function CommunityCustomHeroesGameMode:OnEntityKilled( event )

    local killedUnit = EntIndexToHScript( event.entindex_killed )
    local killedTeam = killedUnit:GetTeam()
    local hero = EntIndexToHScript( event.entindex_attacker )
    local heroTeam = hero:GetTeam()
    local extraTime = 0 

    if killedUnit:IsRealHero() and killedUnit:GetRespawnTime() > 100 then
        print("Hero has been killed")   

        print(hero:GetLevel())

        SetRespawnTime( killedteam, killedUnit, respawnTime )   
    end
end

function SetRespawnTime( killedTeam, killedUnit, respawnTime )
    killedUnit:SetTimeUntilRespawn(100)   
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
	if spawnedUnit:IsRealHero() and not spawnedUnit:IsClone() then
		local team = spawnedUnit:GetTeamNumber()
      	local player = spawnedUnit:GetPlayerOwner()
      	local pID = player:GetPlayerID()
      	--player:SetGold(1750, false)
		CheckForInnates(spawnedUnit)
	end

end


function CheckForInnates(spawnedUnit)
	if(spawnedUnit:GetName() == "npc_dota_hero_treant") then
		local innate = spawnedUnit:FindAbilityByName("parasight_combust")
		if innate then innate:SetLevel(1) end
	elseif(spawnedUnit:GetName() == "npc_dota_hero_venomancer") then
		local innate = spawnedUnit:FindAbilityByName("viscous_ooze_size_mutator")
		if innate then innate:SetLevel(1) end
	elseif(spawnedUnit:GetName() == "npc_dota_hero_legion_commander") then
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
	end
end



function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
	armor_reduction = 100 - (armor_reduction * 100)
	return armor_reduction
end
