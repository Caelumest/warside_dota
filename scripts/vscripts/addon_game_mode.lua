--Loads all custom libraries
require("lib.keyvalues")
require("lib.timers")
require("lib.responses")
require("heroes/sage_ronin/sage_ronin_responses")
require("heroes/new_hero/krigler_responses")
require("heroes/new_hero_2/andrax_responses")
require("heroes/casalmar/casalmar_responses")

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
require("hero_selection")
require("constants")
require("libraries/tables")
require("internal/filters")
softRequire("filters")
--------------------------------------------------------------------------------
--Runs the script to add bots when turned on at options menu. 
--Needs to be below OnGameStateChanged
--------------------------------------------------------------------------------
require("libraries/add_bot")


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

	--Bot Units
	PrecacheUnitByNameSync("npc_dota_hero_casalmar",context)
	PrecacheUnitByNameSync("npc_dota_hero_andrax",context)
	PrecacheUnitByNameSync("npc_dota_hero_soul_tamer",context)
	PrecacheUnitByNameSync("npc_dota_hero_sage_ronin",context)
	PrecacheUnitByNameSync("npc_dota_hero_gravitum",context)
	PrecacheUnitByNameSync("npc_dota_hero_axe",context)
	PrecacheUnitByNameSync("npc_dota_hero_skywrath_mage",context)
	PrecacheUnitByNameSync("npc_dota_hero_nevermore",context)
	PrecacheUnitByNameSync("npc_dota_hero_pudge",context)
	PrecacheUnitByNameSync("npc_dota_hero_phantom_assassin",context)
	PrecacheUnitByNameSync("npc_dota_hero_skeleton_king",context)
	PrecacheUnitByNameSync("npc_dota_hero_lina",context)
	PrecacheUnitByNameSync("npc_dota_hero_luna",context)
	PrecacheUnitByNameSync("npc_dota_hero_bloodseeker",context)
	PrecacheUnitByNameSync("npc_dota_hero_lion",context)
	PrecacheUnitByNameSync("npc_dota_hero_oracle",context)
	PrecacheUnitByNameSync("npc_dota_hero_tiny",context)
	PrecacheUnitByNameSync("npc_dota_hero_bane",context)
	PrecacheUnitByNameSync("npc_dota_hero_bristleback",context)
	PrecacheUnitByNameSync("npc_dota_hero_crystal_maiden",context)
	PrecacheUnitByNameSync("npc_dota_hero_dazzle",context)
	PrecacheUnitByNameSync("npc_dota_hero_chaos_knight",context)
	PrecacheUnitByNameSync("npc_dota_hero_death_prophet",context)
	PrecacheUnitByNameSync("npc_dota_hero_drow_ranger",context)
	PrecacheUnitByNameSync("npc_dota_hero_earthshaker",context)
	PrecacheUnitByNameSync("npc_dota_hero_jakiro",context)
	PrecacheUnitByNameSync("npc_dota_hero_kunkka",context)
	PrecacheUnitByNameSync("npc_dota_hero_necrolyte",context)
	PrecacheUnitByNameSync("npc_dota_hero_sven",context)
	PrecacheUnitByNameSync("npc_dota_hero_lich",context)
	PrecacheUnitByNameSync("npc_dota_hero_juggernaut",context)
	PrecacheUnitByNameSync("npc_dota_hero_omniknight",context)
	PrecacheUnitByNameSync("npc_dota_hero_sand_king",context)
	PrecacheUnitByNameSync("npc_dota_hero_sniper",context)
	PrecacheUnitByNameSync("npc_dota_hero_vengefulspirit",context)
	PrecacheUnitByNameSync("npc_dota_hero_viper",context)
	PrecacheUnitByNameSync("npc_dota_hero_warlock",context)
	PrecacheUnitByNameSync("npc_dota_hero_zuus",context)
	PrecacheUnitByNameSync("npc_dota_hero_witch_doctor",context)
	--Items
	PrecacheItemByNameSync("item_aether_core", context)
  	PrecacheItemByNameSync("item_stout_mail", context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_koh.vsndevts", context )
	--Particles
	PrecacheResource( "particle", "particles/units/heroes/hero_troy/troy_arena_lava.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_ambient.vpcf", context )
	--Sounds
	PrecacheResource( "soundfile", "soundevents/game_sounds_warside_custom.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_ui_imported.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jeremy.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_undying.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sage_ronin.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_undying.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_krigler.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_andrax.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_sage_ronin.vsndevts", context )
	--Precache things we know we'll use.  Possible file types include (but not limited to):
	PrecacheResource( "model", "*.vmdl", context )
	PrecacheResource( "soundfile", "*.vsndevts", context )
	PrecacheResource( "particle", "*.vpcf", context )
	PrecacheResource( "particle_folder", "particles/folder", context )
	LinkLuaModifier("modifier_destroy_illusions_wearables", "modifiers/modifier_destroy_illusions_wearables.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_hide_hero", "modifiers/modifier_hide_hero.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_sage_ronin_responses", "heroes/sage_ronin/modifier_sage_ronin_responses.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_command_restricted", "modifiers/modifier_command_restricted.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_wind_wall_dummy_invulnerability", "heroes/sage_ronin/ronin_wind_wall.lua", LUA_MODIFIER_MOTION_NONE)
end

--------------------------------------------------------------------------------
-- Create the game mode
--------------------------------------------------------------------------------

function Activate()
	_G.TestHit = 0
	FireGameEvent("addon_game_mode_activate",nil)
	GameRules:SetCustomGameTeamMaxPlayers(1, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)
	CustomGameEventManager:RegisterListener("set_starting_gold", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleStartingGold'))
  	CustomGameEventManager:RegisterListener("set_multiplier_gold", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleMultiplierGold'))
  	CustomGameEventManager:RegisterListener("set_multiplier_xp", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleMultiplierExp'))
  	CustomGameEventManager:RegisterListener("set_bots_difficulty", Dynamic_Wrap(WarsideDotaGameMode, 'OnBotDifficulty'))
  	CustomGameEventManager:RegisterListener("player_toggle_bots", Dynamic_Wrap(WarsideDotaGameMode, 'ToggleBots'))
  	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( WarsideDotaGameMode, 'OnGameStateChanged' ), self )
  	GameRules:GetGameModeEntity():SetCustomGameForceHero(DUMMY_HERO)
	GameRules.GameMode = WarsideDotaGameMode()
	GameRules.GameMode:InitGameMode()
end

ListenToGameEvent("addon_game_mode_activate", function()
	print( "Dota Butt Template is loaded." )
end, nil)

--------------------------------------------------------------------------------
-- GameEvent: InitGameMode
--------------------------------------------------------------------------------
function WarsideDotaGameMode:InitGameMode()
	print("Loaded Warside Dota")

	GameRules:SetPreGameTime(PRE_GAME_TIME)
	GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(true)

	ListenToGameEvent("player_chat", Dynamic_Wrap(self, 'OnPlayerChat'), self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(self, 'OrderFilter'), self)
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( WarsideDotaGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( WarsideDotaGameMode, "OnEntityKilled" ), self )
	--ListenToGameEvent("player_chat", Dynamic_Wrap( WarsideDotaGameMode, "OnChat" ), self)
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(WarsideDotaGameMode, "GoldFilter"), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(WarsideDotaGameMode, "ExpFilter"), self)

	Convars:RegisterCommand("chip_toggle_hud", Dynamic_Wrap(self, 'ToggleHUD'), "", 0)
	LinkLuaModifier("modifier_command_restricted", "modifiers/modifier_command_restricted.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_activatable", "scripts/vscripts/modifiers/modifier_activatable.lua", LUA_MODIFIER_MOTION_NONE)
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(35)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	if IsInToolsMode() then
		require("demo")
		self:SetupDemoMode()
	end
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function WarsideDotaGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if killedUnit:IsIllusion() then
		RemoveCustomIllusions(killedUnit)
	end
	if event.entindex_attacker then
		local attacker = EntIndexToHScript( event.entindex_attacker )

		if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() then
		    print("Hero has been killed")   
		    if killedUnit:HasModifier("modifier_necrolyte_reapers_scythe_respawn_time") then
		    	killedUnit:SetTimeUntilRespawn(RESPAWN_PER_LEVEL_TABLE[killedUnit:GetLevel()] + 15 * attacker:FindAbilityByName("necrolyte_reapers_scythe"):GetLevel())
		    else
				killedUnit:SetTimeUntilRespawn(RESPAWN_PER_LEVEL_TABLE[killedUnit:GetLevel()])
			end
		end
	end
end

function WarsideDotaGameMode:GoldFilter(keys)
	if not multiplier_Gold then multiplier_Gold = 1 end
	keys.gold = keys.gold * multiplier_Gold + (multiplier_Gold * (GameRules:GetGameTime()/275))
	return true
end


function WarsideDotaGameMode:ExpFilter(keys)
	if not multiplier_Exp then multiplier_Exp = 1 end
	keys.experience = keys.experience * multiplier_Exp
	return true
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function WarsideDotaGameMode:OnNPCSpawned( event )
	spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsIllusion() then
		--CheckForIllusionsInnate(spawnedUnit)
		if spawnedUnit:GetName() == "npc_dota_hero" then
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_destroy_illusions_wearables", {})
		end
	end
	if spawnedUnit:GetUnitName() == "npc_dota_hero_custom" then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_hide_hero", {})
	end
	CheckForInnates(spawnedUnit)
	if spawnedUnit:IsRealHero() and not spawnedUnit:IsClone() and not spawnedUnit:IsIllusion() and spawnedUnit:GetUnitName() ~= "npc_dota_hero_custom" and spawnedUnit:GetUnitName() ~= "npc_dota_creature_spirit_vessel" then
		
		if IsInToolsMode() and spawnedUnit.toolsmodeflag == nil then
			if spawnedUnit:HasRoomForItem("item_blink", true, true) then
		   		local dagger = CreateItem("item_blink", spawnedUnit, spawnedUnit)
		   		dagger:SetPurchaseTime(0)
		   		spawnedUnit:AddItem(dagger)
    		end
    		spawnedUnit:HeroLevelUp(false)
    		spawnedUnit:HeroLevelUp(false)
    		spawnedUnit:HeroLevelUp(false)
    		spawnedUnit:HeroLevelUp(false)
    		spawnedUnit:HeroLevelUp(false)
    		spawnedUnit.toolsmodeflag = 0
    	end
	end
	if spawnedUnit:IsRealHero() and not spawnedUnit:IsClone() then
		if spawnedUnit.FirstTime == nil then
			spawnedUnit.FirstTime = true
			Timers:CreateTimer(0.1, function()
				if spawnedUnit:IsIllusion() then return end
				if spawnedUnit:GetUnitName() ~= DUMMY_HERO then
					return
				else
					local time_elapsed = 0
					Timers:CreateTimer(function()
						if not spawnedUnit:HasModifier("modifier_command_restricted") then
							spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_command_restricted", {})
							spawnedUnit:AddEffects(EF_NODRAW)
							if spawnedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
								PlayerResource:SetCameraTarget(spawnedUnit:GetPlayerOwnerID(), GoodCamera)
							else
								PlayerResource:SetCameraTarget(spawnedUnit:GetPlayerOwnerID(), BadCamera)					
							end
						end
						if time_elapsed < 0.9 then
							time_elapsed = time_elapsed + 0.1
						else			
							return nil
						end
						return 0.1
					end)

					return
				end
			end)
		end
	end
end

function WarsideDotaGameMode:ToggleHUD()
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(0), "chip_toggle_hud", {})
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

local activationOrders = {
	[DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
	[DOTA_UNIT_ORDER_ATTACK_TARGET] = true
}

local castOrders = {
	[DOTA_UNIT_ORDER_CAST_POSITION] = true,
	[DOTA_UNIT_ORDER_CAST_TARGET] = true,
	[DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
	[DOTA_UNIT_ORDER_CAST_RUNE] = true,
}
local attackOrder = {
	[DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
	[DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
}

function WarsideDotaGameMode:OrderFilter(order)
	local target_unit = nil
	local ability = nil
	if order.entindex_target ~= 0 then
		target_unit = EntIndexToHScript(order.entindex_target)
	end
	if order.entindex_ability ~= 0 then
		ability = EntIndexToHScript(order.entindex_ability)
	end

	-- Check for activatable modifier
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

		------------------YASUO ANIMATIONS-----------------
		if unit:IsAlive() then
			if order and (order.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or order.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or order.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM or order.order_type == DOTA_UNIT_ORDER_PICKUP_RUNE or order.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or order.order_type == DOTA_UNIT_ORDER_CAST_POSITION) and unit:GetUnitName() == "npc_dota_hero_sage_ronin" then
				local pos = Vector(order["position_x"], order["position_y"], order["position_z"])
				unit:RemoveGesture(ACT_IDLE_ANGRY_MELEE)
				unit.lastClickedPos = pos
				if unit.isFast and unit:HasModifier("modifier_rune_haste") then
					AddAnimationTranslate(unit, "run_fast")
				elseif unit.isFast then 
					AddAnimationTranslate(unit, "run")
				else
					AddAnimationTranslate(unit, "walk")
				end
				if (unit.isIdle == nil or unit.isIdle == true) and unit.cancelPuncture == nil then
					if not unit.isFast then
						print("ERA PRA IR")
						StartAnimation(unit, {duration=1, activity=ACT_IDLETORUN, rate=1})
					elseif unit.isFast and not unit:HasModifier("modifier_rune_haste") then
						StartAnimation(unit, {duration=1, activity=ACT_DEPLOY_IDLE, rate=1})
					end
				end
				unit.isIdle = false

				unit:RemoveGesture(ACT_RUNTOIDLE)
				if unit.cancelPuncture then
					unit.cancelPuncture = false
				end
			end

			
			if (order.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or order.order_type == DOTA_UNIT_ORDER_STOP) and unit:GetUnitName() == "npc_dota_hero_sage_ronin" and unit.isIdle == false then
				unit:RemoveGesture(ACT_IDLETORUN)
				unit:RemoveGesture(ACT_DEPLOY_IDLE)
				unit:RemoveGesture(ACT_GESTURE_MELEE_ATTACK1)
				unit:RemoveGesture(ACT_GESTURE_MELEE_ATTACK2)
				if unit.isAggressive then
					RemoveAnimationTranslate(unit)
					unit.isAggressive = false

					if unit:GetIdealSpeed() >= 400 then
						if unit:HasModifier("modifier_rune_haste") then
							RemoveAnimationTranslate(unit)
					        AddAnimationTranslate(unit, "run_fast")
						else
							RemoveAnimationTranslate(unit)
					        AddAnimationTranslate(unit, "run")
						end
				        unit.isFast = true
				    elseif unit:GetIdealSpeed() < 400 then
				    	RemoveAnimationTranslate(unit)
						AddAnimationTranslate(unit, "walk")	
						unit.isFast = nil
				    end
					StartAnimation(unit, {duration=5.5, activity=ACT_IDLE_ANGRY_MELEE, rate=1})
				else
					StartAnimation(unit, {duration=0.75, activity=ACT_RUNTOIDLE, rate=1})
				end
				unit.isIdle = true
			end
		end
		------------------------------------------------------------------------------------

		--The Arena
		if castOrders[order.order_type] or order.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
			if target_unit ~= nil and _G.WIND_WALL_TEAM ~= nil and target_unit:GetUnitName() ~= "npc_dota_creature_spirit_vessel" and unit:GetTeamNumber() ~= target_unit:GetTeamNumber() then
				local units = FindUnitsInLine(unit:GetTeamNumber(), unit:GetAbsOrigin(), target_unit:GetAbsOrigin(), nil, 10, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

				for _,target in pairs( units ) do
					if target:GetUnitName() == "npc_dota_creature_spirit_vessel" and target:HasModifier("modifier_wind_wall_dummy") and _G.TestHit <= 0 and unit:GetTeamNumber() ~= target:GetTeamNumber() then
						order.entindex_target = target:entindex()
						return true
					end
				end
			end
		end
		if castOrders[order.order_type] then


			local arena_modifier = unit:FindModifierByName("modifier_troy_the_arena_check_position")
			if arena_modifier and arena_modifier:GetAbility() and arena_modifier.target_point then
				local radius = arena_modifier:GetAbility():GetSpecialValueFor("radius")
				local origin = unit:GetAbsOrigin()
				if (arena_modifier.target_point - origin):Length2D() < radius then
					if order["position_x"] and not target_unit then
						local posX = order["position_x"]
						local posY = order["position_y"]
						local posZ = order["position_z"]

						local vector = Vector(posX, posY, posZ)
						-- print((arena_modifier.target_point - vector):Length2D())

						if (arena_modifier.target_point - vector):Length2D() > radius then
							-- local newVector = arena_modifier.target_point + (vector - arena_modifier.target_point):Normalized() * (radius - 25)
							-- order["position_x"] = newVector.x
							-- order["position_y"] = newVector.y
							-- order["position_z"] = newVector.z
							-- unit:AddNewModifier(unit, nil, "modifier_command_restricted", {Duration = 0.03})
							--return false
							if unit:GetPlayerOwnerID() then
								local dummy = CreateUnitByName("npc_arena_dummy", arena_modifier.target_point, true, nil, nil, unit:GetTeamNumber())
								dummy:SetControllableByPlayer(unit:GetPlayerOwnerID(), true)
								-- dummy:SetOwner(unit)
								local errorAbility = dummy:FindAbilityByName("arena_cast_error_outside")
								errorAbility:UpgradeAbility(true)
								dummy:AddNewModifier(unit, nil, "modifier_kill", {duration = 0.03})
								dummy:AddNewModifier(unit, nil, "modifier_invulnerable", {})

								order.entindex_ability = errorAbility:entindex()
								order.order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
								order.units["0"] = dummy:entindex()
							end
						end
					elseif target_unit then
						local vector = target_unit:GetAbsOrigin()
						if (arena_modifier.target_point - vector):Length2D() > radius then
							-- local newVector = arena_modifier.target_point + (vector - arena_modifier.target_point):Normalized() * (radius - 25)
							-- local newTarget = CreateUnitByName("npc_dummy", newVector, false, nil, nil, DOTA_TEAM_GOODGUYS)
							-- newTarget:AddNewModifier(unit, nil, "modifier_kill", {duration = 1})
							-- order.entindex_target = newTarget:entindex()
							-- unit:AddNewModifier(unit, nil, "modifier_command_restricted", {Duration = 0.03})
							--return false
							if unit:GetPlayerOwnerID() then
								local dummy = CreateUnitByName("npc_arena_dummy", arena_modifier.target_point, true, nil, nil, unit:GetTeamNumber())
								dummy:SetControllableByPlayer(unit:GetPlayerOwnerID(), true)
								dummy:SetOwner(unit)
								local errorAbility = dummy:FindAbilityByName("arena_cast_error_outside")
								errorAbility:UpgradeAbility(true)
								dummy:AddNewModifier(unit, nil, "modifier_kill", {duration = 0.03})
								dummy:AddNewModifier(unit, nil, "modifier_invulnerable", {})

								order.entindex_ability = errorAbility:entindex()
								order.order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
								order.units["0"] = dummy:entindex()
							end
						end
					else
						local vector = unit:GetAbsOrigin()
						-- print(vector)
						-- print((arena_modifier.target_point - vector):Length2D())
						if (arena_modifier.target_point - vector):Length2D() > radius then
							local newVector = arena_modifier.target_point + (vector - arena_modifier.target_point):Normalized() * (radius - 25)
							unit:SetAbsOrigin(newVector)
						end
					end
				else
					if order["position_x"] and not target_unit then
						local posX = order["position_x"]
						local posY = order["position_y"]
						local posZ = order["position_z"]

						local vector = Vector(posX, posY, posZ)
						-- print((arena_modifier.target_point - vector):Length2D())

						if (arena_modifier.target_point - vector):Length2D() < radius + 25 then
							-- local newVector = arena_modifier.target_point + (vector - arena_modifier.target_point):Normalized() * (radius - 25)
							-- order["position_x"] = newVector.x
							-- order["position_y"] = newVector.y
							-- order["position_z"] = newVector.z
							-- unit:AddNewModifier(unit, nil, "modifier_command_restricted", {Duration = 0.03})
							--return false
							if unit:GetPlayerOwnerID() then
								local dummy = CreateUnitByName("npc_arena_dummy", arena_modifier.target_point, true, nil, nil, unit:GetTeamNumber())
								dummy:SetControllableByPlayer(unit:GetPlayerOwnerID(), true)
								-- dummy:SetOwner(unit)
								local errorAbility = dummy:FindAbilityByName("arena_cast_error_inside")
								errorAbility:UpgradeAbility(true)
								dummy:AddNewModifier(unit, nil, "modifier_kill", {duration = 0.03})
								dummy:AddNewModifier(unit, nil, "modifier_invulnerable", {})

								order.entindex_ability = errorAbility:entindex()
								order.order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
								order.units["0"] = dummy:entindex()
							end
						end
					elseif target_unit then
						local vector = target_unit:GetAbsOrigin()
						if (arena_modifier.target_point - vector):Length2D() < radius + 25 then
							-- local newVector = arena_modifier.target_point + (vector - arena_modifier.target_point):Normalized() * (radius - 25)
							-- local newTarget = CreateUnitByName("npc_dummy", newVector, false, nil, nil, DOTA_TEAM_GOODGUYS)
							-- newTarget:AddNewModifier(unit, nil, "modifier_kill", {duration = 1})
							-- order.entindex_target = newTarget:entindex()
							-- unit:AddNewModifier(unit, nil, "modifier_command_restricted", {Duration = 0.03})
							--return false
							if unit:GetPlayerOwnerID() then
								local dummy = CreateUnitByName("npc_arena_dummy", arena_modifier.target_point, true, nil, nil, unit:GetTeamNumber())
								dummy:SetControllableByPlayer(unit:GetPlayerOwnerID(), true)
								-- dummy:SetOwner(unit)
								local errorAbility = dummy:FindAbilityByName("arena_cast_error_inside")
								errorAbility:UpgradeAbility(true)
								dummy:AddNewModifier(unit, nil, "modifier_kill", {duration = 0.03})
								dummy:AddNewModifier(unit, nil, "modifier_invulnerable", {})

								order.entindex_ability = errorAbility:entindex()
								order.order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
								order.units["0"] = dummy:entindex()
							end
							
						end
					else
						-- local vector = unit:GetAbsOrigin()
						-- print(vector)
						-- print((arena_modifier.target_point - vector):Length2D())
						-- if (arena_modifier.target_point - vector):Length2D() < radius + 25 then
							-- local newVector = arena_modifier.target_point + (vector - arena_modifier.target_point):Normalized() * (radius - 25)
							-- unit:SetAbsOrigin(newVector)
						-- end
					end
				end

				Timers:CreateTimer(0.03, function() 
					if not unit:IsNull() then
						if unit:HasAbility("arena_cast_error_inside") then
							unit:RemoveAbility("arena_cast_error_inside")
						end
						if unit:HasAbility("arena_cast_error_outside") then
							unit:RemoveAbility("arena_cast_error_outside")
						end
					end
				end)
			end
		end

		--Parasitic Invasion
		local invasion_modifier = unit:FindModifierByName("modifier_parasight_parasitic_invasion")

		if invasion_modifier ~= nil and unit:HasModifier("modifier_parasight_parasitic_invasion_control_buff") then
			if invasion_modifier:OrderFilter(order) ~= true then
				return false
			end
		end

		local invasion_target_modifier = unit:FindModifierByName("modifier_parasight_parasitic_invasion_control")
		if invasion_target_modifier ~= nil then
			return invasion_target_modifier:OrderFilter(order)
		end
	end

	return true
end

function WarsideDotaGameMode:DamageFilter(filterTable)
    local damage = filterTable["damage"] --Post reduction
    print("damagefilter ",dump(filterTable))
    local ability
    if filterTable["entindex_inflictor_const"] ~= nil then
	    ability = EntIndexToHScript( filterTable["entindex_inflictor_const"] )
	end

    local victim
	if filterTable["entindex_victim_const"] ~= nil then
	    victim = EntIndexToHScript( filterTable["entindex_victim_const"] )
	end

	local attacker
	if filterTable["entindex_attacker_const"] ~= nil then
	    attacker = EntIndexToHScript( filterTable["entindex_attacker_const"] )
	end
	
    local damagetype = filterTable["damagetype_const"]

    if attacker and IsValidEntity(attacker) and attacker.FindModifierByName then
		
		-- Check for Troy's Arena modifiers
		if victim:HasModifier("modifier_troy_the_arena_check_position") then
			local arena_modifier = victim:FindModifierByName("modifier_troy_the_arena_check_position")
			if arena_modifier and arena_modifier:GetAbility() and arena_modifier.target_point then
				local radius = arena_modifier:GetAbility():GetSpecialValueFor("radius")
				local victim_distance = (arena_modifier.target_point - victim:GetAbsOrigin()):Length2D()
				local attacker_distance = (arena_modifier.target_point - attacker:GetAbsOrigin()):Length2D()
				if (victim_distance < radius and attacker_distance > radius) or (victim_distance > radius and attacker_distance < radius) then
					if attacker == arena_modifier:GetCaster() and victim_distance <= (radius + 100) then
						return true
					else
						return false
					end
				end
			end
		end

    	-- Check for Parasitic Invasion modifier
    	local modifier = attacker:FindModifierByName("modifier_parasight_parasitic_invasion_control")
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

function WarsideDotaGameMode:ModifierFilter(tModifierFilter)
	-- tModifierFilter.duration
	-- tModifierFilter.entindex_caster_const
	-- tModifierFilter.entindex_parent_const
	-- tModifierFilter.name_const

	if not tModifierFilter.entindex_caster_const then return true end

	local duration = tModifierFilter.duration
	local caster = EntIndexToHScript(tModifierFilter.entindex_caster_const)
	local target = EntIndexToHScript(tModifierFilter.entindex_parent_const)

	-- Tenacity handling. Does not apply to friendly or infinite duration modifiers.
	if caster:GetTeam() ~= target:GetTeam() and duration > 0 then

		-- Do nothing if the target has no tenacity.
		if target.GetTenacity and target:GetTenacity() > 0 then

			-- Do nothing if the modifier is an exception
			local exceptions_table = {
				"modifier_dark_willow_cursed_crown",
				"modifier_silencer_last_word"
			}
			for _, exception_name in pairs(exceptions_table) do
				if exception_name == tModifierFilter.name_const then
					return true
				end
			end

			-- If it's not, reduce the modifier's duration
			tModifierFilter.duration = tModifierFilter.duration * (1 - 0.01 * target:GetTenacity())
		end
	end

	-- Check for Troy's Arena modifiers
	if tModifierFilter.name_const == "modifier_troy_the_arena_check_position" then return true end
	
	if target:HasModifier("modifier_troy_the_arena_check_position") then
		local arena_modifier = target:FindModifierByName("modifier_troy_the_arena_check_position")
		if arena_modifier and arena_modifier:GetAbility() and arena_modifier.target_point then
			local radius = arena_modifier:GetAbility():GetSpecialValueFor("radius")
			local victim_distance = (arena_modifier.target_point - target:GetAbsOrigin()):Length2D()
			local attacker_distance = (arena_modifier.target_point - caster:GetAbsOrigin()):Length2D()
			if (victim_distance < radius and attacker_distance > radius) or (victim_distance > radius and attacker_distance < radius) then
				if caster == arena_modifier:GetCaster() and victim_distance <= (radius + 100) then
					return true
				else
					return false
				end
			end
		end
	end

	return true
end
