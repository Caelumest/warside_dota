--Loads all custom libraries
require("lib.timers")
require("lib.responses")
require("libraries/animations")
require("libraries/attachments")
require("libraries/notifications")
--Loads all custom functions
require("functions/utilities")
require("functions/multiply_gold_xp")
require("functions/check_for_innates")

if WarsideDotaGameMode == nil then
	_G.WarsideDotaGameMode = class({})
end

require("libraries/options_menu") --Loads the menu options

--------------------------------------------------------------------------------
-- Preloads everything before the game is created
--------------------------------------------------------------------------------
function Precache(context)
	--Custom Heroes
	PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
	PrecacheUnitByNameSync("npc_dota_hero_legion_commander", context)
	PrecacheUnitByNameSync("npc_dota_hero_monkey_king", context)
	PrecacheUnitByNameSync("npc_dota_hero_lone_druid", context)
	PrecacheUnitByNameSync("npc_dota_hero_keeper_of_the_light", context)
	PrecacheUnitByNameSync("npc_dota_hero_krigler",context)
	PrecacheUnitByNameSync("npc_dota_hero_juggernaut",context)
	--Items
	PrecacheItemByNameSync("item_aether_core", context)
  	PrecacheItemByNameSync("item_stout_mail", context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_koh.vsndevts", context )
	--Particles
	PrecacheResource( "particle", "particles/units/heroes/hero_troy/troy_arena_lava.vpcf", context )
	--Sounds
	PrecacheResource( "soundfile", "soundevents/game_sounds_ui_imported.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jeremy.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
	--Precache things we know we'll use.  Possible file types include (but not limited to):
	PrecacheResource( "model", "*.vmdl", context )
	PrecacheResource( "soundfile", "*.vsndevts", context )
	PrecacheResource( "particle", "*.vpcf", context )
	PrecacheResource( "particle_folder", "particles/folder", context )
	CustomGameEventManager:RegisterListener("set_starting_gold", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleStartingGold'))
end

--------------------------------------------------------------------------------
-- Create the game mode
--------------------------------------------------------------------------------
function Activate()
  	CustomGameEventManager:RegisterListener("set_multiplier_gold", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleMultiplierGold'))
  	CustomGameEventManager:RegisterListener("set_multiplier_xp", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleMultiplierExp'))
  	CustomGameEventManager:RegisterListener("set_bots_difficulty", Dynamic_Wrap(WarsideDotaGameMode, 'OnBotDifficulty'))
  	CustomGameEventManager:RegisterListener("player_toggle_bots", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleBots'))
  	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( WarsideDotaGameMode, 'OnGameStateChanged' ), self )
	GameRules.GameMode = WarsideDotaGameMode()
	GameRules.GameMode:InitGameMode()
end

--------------------------------------------------------------------------------
--Execute commands when the game state change
--------------------------------------------------------------------------------
function WarsideDotaGameMode:OnGameStateChanged( keys )
    local state = GameRules:State_Get()
    if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
    	print("HERO SELECTION")
    end
end

--------------------------------------------------------------------------------
--Runs the script to add bots when turned on at options menu. 
--Needs to be below OnGameStateChanged
--------------------------------------------------------------------------------
require("libraries/add_bot")

--------------------------------------------------------------------------------
-- GameEvent: InitGameMode
--------------------------------------------------------------------------------
function WarsideDotaGameMode:InitGameMode()
	print("Loaded Warside Dota")
	-- GameRules:SetPreGameTime(20)
	VoiceResponses:Start()
	VoiceResponses:RegisterUnit("npc_dota_hero_juggernaut", "scripts/responses/juggernaut_responses.txt")
	-- Link modifiers
	LinkLuaModifier("modifier_activatable", "scripts/vscripts/modifiers/modifier_activatable.lua", LUA_MODIFIER_MOTION_NONE)
	-- Listen to game events
	GameRules:SetCustomGameSetupTimeout(60)
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( WarsideDotaGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( WarsideDotaGameMode, "OnEntityKilled" ), self )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )
	GameRules:SetSameHeroSelectionEnabled(true)
	require("libraries/xp_table")
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function WarsideDotaGameMode:OnEntityKilled( event )
    local killedUnit = EntIndexToHScript( event.entindex_killed )
    local attacker = EntIndexToHScript( event.entindex_attacker )

    MultiplyGoldXp(killedUnit, attacker)

    if killedUnit:IsRealHero() and killedUnit:GetLevel() > 25 and killedUnit:IsReincarnating() == false then
        print("Hero has been killed")   
        print(attacker:GetLevel())
    	killedUnit:SetTimeUntilRespawn(100)
    end
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function WarsideDotaGameMode:OnNPCSpawned( event )
	spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() and not spawnedUnit:IsClone() and not spawnedUnit:IsIllusion() then
		CheckForInnates(spawnedUnit)
		if GameRules:IsCheatMode() then
			if spawnedUnit:HasRoomForItem("item_blink", true, true) then
		   		local dagger = CreateItem("item_blink", spawnedUnit, spawnedUnit)
		   		dagger:SetPurchaseTime(0)
		   		spawnedUnit:AddItem(dagger)
    		end
    	end
	end
end

--------------------------------------------------------------------------------
-- GameEvent: GetPhysicalArmorReduction
--------------------------------------------------------------------------------
function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
	armor_reduction = 100 - (armor_reduction * 100)
	return armor_reduction
end