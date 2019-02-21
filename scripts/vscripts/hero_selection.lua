-- Copyright (C) 2018  The Dota IMBA Development Team
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Editors:
--     EarthSalamander #42
--
LinkLuaModifier("modifier_krigler_effects", "heroes/new_hero/modifier_krigler_effects.lua", LUA_MODIFIER_MOTION_NONE)
--Class definition
if HeroSelection == nil then
	HeroSelection = {}
	HeroSelection.__index = HeroSelection
end

function HeroSelection:HeroListPreLoad()
	-- Retrieve heroes info
	NPC_HEROES = LoadKeyValues("scripts/npc/npc_heroes.txt")
	NPC_HEROES_CUSTOM = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")

	HeroSelection.str_heroes = {}
	HeroSelection.agi_heroes = {}
	HeroSelection.int_heroes = {}
	HeroSelection.custom_str_heroes = {}
	HeroSelection.custom_agi_heroes = {}
	HeroSelection.custom_int_heroes = {}
	HeroSelection.all_heroes = {}
	HeroSelection.custom_heroes = {}
	HeroSelection.new_heroes = {}
	HeroSelection.disabled_heroes = {}
	HeroSelection.disabled_silent_heroes = {}
	HeroSelection.picked_heroes = {}

	for hero, attributes in pairs(NPC_HEROES) do
		if hero == "Version" or hero == "npc_dota_hero_base" or hero == "npc_dota_hero_target_dummy" then
		else
			table.insert(HeroSelection.all_heroes, hero)
			HeroSelection:AddVanillaHeroToList(hero)
		end
	end

	for hero, attributes in pairs(NPC_HEROES_CUSTOM) do
		if string.find(hero, "npc_dota_hero_") then
			if GetKeyValueByHeroName(hero, "IsDisabled") == 1 then
				table.insert(HeroSelection.disabled_heroes, hero)
			elseif GetKeyValueByHeroName(hero, "IsDisabled") == 2 then
				table.insert(HeroSelection.disabled_silent_heroes, hero)
			end

			if GetKeyValueByHeroName(hero, "IsCustom") == 1 then
				if hero == DUMMY_HERO then
				else
					HeroSelection:AddCustomHeroToList(hero)
					table.insert(HeroSelection.custom_heroes, hero)
				end
			end

			-- Add a specific label
			if GetKeyValueByHeroName(hero, "IsNew") == 1 then
				table.insert(HeroSelection.new_heroes, hero)
			end

			table.insert(HeroSelection.all_heroes, hero)
		end
	end

	HeroSelection:HeroList()
end

function HeroSelection:AddVanillaHeroToList(hero_name)
	if GetKeyValueByHeroName(hero_name, "AttributePrimary") == "DOTA_ATTRIBUTE_STRENGTH" then
		table.insert(HeroSelection.str_heroes, hero_name)
	elseif GetKeyValueByHeroName(hero_name, "AttributePrimary") == "DOTA_ATTRIBUTE_AGILITY" then
		table.insert(HeroSelection.agi_heroes, hero_name)
	elseif GetKeyValueByHeroName(hero_name, "AttributePrimary") == "DOTA_ATTRIBUTE_INTELLECT" then
		table.insert(HeroSelection.int_heroes, hero_name)
	end

	a = {}
	for k, n in pairs(HeroSelection.str_heroes) do
		table.insert(a, n)
		HeroSelection.str_heroes = {}
	end
	table.sort(a)
	for i,n in ipairs(a) do
		table.insert(HeroSelection.str_heroes, n)
	end

	a = {}
	for k, n in pairs(HeroSelection.agi_heroes) do
		table.insert(a, n)
		HeroSelection.agi_heroes = {}
	end
	table.sort(a)
	for i,n in ipairs(a) do
		table.insert(HeroSelection.agi_heroes, n)
	end

	a = {}
	for k, n in pairs(HeroSelection.int_heroes) do
		table.insert(a, n)
		HeroSelection.int_heroes = {}
	end
	table.sort(a)
	for i,n in ipairs(a) do
		table.insert(HeroSelection.int_heroes, n)
	end
end

function HeroSelection:AddCustomHeroToList(hero_name)
	if GetKeyValueByHeroName(hero_name, "AttributePrimary") == "DOTA_ATTRIBUTE_STRENGTH" then
		table.insert(HeroSelection.custom_str_heroes, hero_name)
	elseif GetKeyValueByHeroName(hero_name, "AttributePrimary") == "DOTA_ATTRIBUTE_AGILITY" then
		table.insert(HeroSelection.custom_agi_heroes, hero_name)
	elseif GetKeyValueByHeroName(hero_name, "AttributePrimary") == "DOTA_ATTRIBUTE_INTELLECT" then
		table.insert(HeroSelection.custom_int_heroes, hero_name)
	end

	a = {}
	for k, n in pairs(HeroSelection.custom_str_heroes) do
		table.insert(a, n)
		HeroSelection.custom_str_heroes = {}
	end
	table.sort(a)
	for i,n in ipairs(a) do
		table.insert(HeroSelection.custom_str_heroes, n)
	end

	a = {}
	for k, n in pairs(HeroSelection.custom_agi_heroes) do
		table.insert(a, n)
		HeroSelection.custom_agi_heroes = {}
	end
	table.sort(a)
	for i,n in ipairs(a) do
		table.insert(HeroSelection.custom_agi_heroes, n)
	end

	a = {}
	for k, n in pairs(HeroSelection.custom_int_heroes) do
		table.insert(a, n)
		HeroSelection.custom_int_heroes = {}
	end
	table.sort(a)
	for i,n in ipairs(a) do
		table.insert(HeroSelection.custom_int_heroes, n)
	end
end

local only_once = false
local only_once_alt = false
function HeroSelection:HeroList()
	CustomNetTables:SetTableValue("game_options", "hero_list", {
		str = HeroSelection.str_heroes,
		agi = HeroSelection.agi_heroes,
		int = HeroSelection.int_heroes,
		custom_str = HeroSelection.custom_str_heroes,
		custom_agi = HeroSelection.custom_agi_heroes,
		custom_int = HeroSelection.custom_int_heroes,
		new = HeroSelection.new_heroes,
		disabled_10v10 = HeroSelection.disabled_10v10_heroes,
		disabled = HeroSelection.disabled_heroes,
		disabled_silent = HeroSelection.disabled_silent_heroes,
		picked = HeroSelection.picked_heroes
	})

	if only_once_alt == false then
		only_once_alt = true
		HeroSelection:Start()
	end
end
--[[
	Start
	Call this function from your gamemode once the gamestate changes
	to pre-game to start the hero selection.
]]
function HeroSelection:Start()
	HeroSelection.HorriblyImplementedReconnectDetection = {}
	HeroSelection.radiantPicks = {}
	HeroSelection.direPicks = {}
	HeroSelection.playerPicks = {}
	HeroSelection.playerPickState = {}
	HeroSelection.numPickers = 0

--	HeroSelection.pick_sound_dummy_good = CreateUnitByName("npc_dummy_unit", Entities:FindByName(nil, "dota_goodguys_fort"):GetAbsOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)
--	HeroSelection.pick_sound_dummy_good:EmitSound("Imba.PickPhaseDrums")

--	HeroSelection.pick_sound_dummy_bad = CreateUnitByName("npc_dummy_unit", Entities:FindByName(nil, "npc_dota_badguys_fort"):GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)
--	HeroSelection.pick_sound_dummy_bad:EmitSound("Imba.PickPhaseDrums")

	-- Figure out which players have to pick
	for pID = 0, DOTA_MAX_PLAYERS -1 do
		if PlayerResource:IsValidPlayer( pID ) then
			HeroSelection.numPickers = HeroSelection.numPickers + 1
			HeroSelection.playerPickState[pID] = {}
			HeroSelection.playerPickState[pID].pick_state = "selecting_hero"
			print("Pick State:", pID, HeroSelection.playerPickState[pID].pick_state)
			HeroSelection.playerPickState[pID].repick_state = false
			HeroSelection.HorriblyImplementedReconnectDetection[pID] = true
		end
	end

	-- Start the pick timer
	HeroSelection.TimeLeft = HERO_SELECTION_TIME
	Timers:CreateTimer( 0.04, HeroSelection.Tick )

	-- Keep track of the number of players that have picked
	HeroSelection.playersPicked = 0

	-- Listen for pick and repick events
	HeroSelection.listener_select = CustomGameEventManager:RegisterListener("hero_selected", HeroSelection.HeroSelect )
	HeroSelection.listener_random = CustomGameEventManager:RegisterListener("hero_randomed", HeroSelection.RandomHero )
	HeroSelection.listener_repick = CustomGameEventManager:RegisterListener("hero_repicked", HeroSelection.HeroRepicked )
	HeroSelection.listener_ui_initialize = CustomGameEventManager:RegisterListener("ui_initialized", HeroSelection.UiInitialized )
	HeroSelection.listener_abilities_requested = CustomGameEventManager:RegisterListener("pick_abilities_requested", HeroSelection.PickAbilitiesRequested )

	-- Play relevant pick lines
	if IMBA_PICK_MODE_ALL_RANDOM or IMBA_PICK_MODE_ALL_RANDOM_SAME_HERO then
		EmitGlobalSound("announcer_announcer_type_all_random")
	elseif IMBA_PICK_MODE_ARENA_MODE then
		EmitGlobalSound("announcer_announcer_type_death_match")
	else
		EmitGlobalSound("announcer_announcer_type_all_pick")
	end
end

-- Horribly implemented reconnection detection
function HeroSelection:UiInitialized(event)
	Timers:CreateTimer(0.04, function()
		HeroSelection.HorriblyImplementedReconnectDetection[event.PlayerID] = true
	end)
end

--[[
	Tick
	A tick of the pick timer.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:Tick()
	-- Send a time update to all clients
	if HeroSelection.TimeLeft >= 0 then
		CustomGameEventManager:Send_ServerToAllClients( "picking_time_update", {time = HeroSelection.TimeLeft} )
	end

	--Check if all heroes have been picked
	if HeroSelection.playersPicked >= HeroSelection.numPickers then
		--End picking
		HeroSelection.TimeLeft = 0
	end

	-- Tick away a second of time
	HeroSelection.TimeLeft = HeroSelection.TimeLeft - 1
	if HeroSelection.TimeLeft < 0 then
		-- End picking phase
		HeroSelection:EndPicking()
		return nil
	elseif HeroSelection.TimeLeft >= 0 then
		return 1
	end
end

function HeroSelection:RandomHero(event)
	local id = event.PlayerID
	if PlayerResource:GetConnectionState(id) == 1 then
		print("Bot, ignoring..")
	else
		if HeroSelection.playerPickState[id].pick_state ~= "selecting_hero" then
			return nil
		end
	end

	-- Roll a random hero
	local random_hero = HeroSelection.all_heroes[RandomInt(1, #HeroSelection.all_heroes)]

	for _, picked_hero in pairs(HeroSelection.disabled_heroes) do
		if random_hero == picked_hero then
			print("Hero disabled, random again...")
			HeroSelection:RandomHero({PlayerID = id})
			break
		end
	end

	for _, picked_hero in pairs(HeroSelection.disabled_silent_heroes) do
		if random_hero == picked_hero then
			print("Hero disabled silently, random again...")
			HeroSelection:RandomHero({PlayerID = id})
			break
		end
	end

	for _, picked_hero in pairs(HeroSelection.picked_heroes) do
		if random_hero == picked_hero then
			print("Hero picked, random again...")
			HeroSelection:RandomHero({PlayerID = id})
			break
		end
	end

	-- Flag the player as having randomed
	PlayerResource:SetHasRandomed(id)

	-- If it's a valid hero, allow the player to select it
	HeroSelection:HeroSelect({PlayerID = id, HeroName = random_hero, HasRandomed = true})

	-- The person has randomed (separate from Set/HasRandomed, because those cannot be unset)
	HeroSelection.playerPickState[id].random_state = true

	-- Send a Custom Message in PreGame Chat to tell other players this player has randomed
--	Chat:PlayerRandomed(id, PlayerResource:GetPlayer(id), PlayerResource:GetTeam(id), random_hero)
end

function HeroSelection:RandomSameHero()
	--	if id ~= -1 and HeroSelection.playerPickState[id].pick_state ~= "selecting_hero" then return end

	-- Roll a random hero, and keep it stored
	local random_hero = HeroSelection.all_heroes[RandomInt(1, #HeroSelection.all_heroes)]

	for _, picked_hero in pairs(HeroSelection.disabled_heroes) do
		if random_hero == picked_hero then
			print("Hero disabled, random again...")
			HeroSelection:RandomHero({PlayerID = id})
			break
		end
	end

	for _, picked_hero in pairs(HeroSelection.disabled_silent_heroes) do
		if random_hero == picked_hero then
			print("Hero disabled silently, random again...")
			HeroSelection:RandomHero({PlayerID = id})
			break
		end
	end

	-- backend feature not implented in CHIP
--	if HeroIsHotDisabled(random_hero) then
--		print("Hero is Hot Disabled!")
--		HeroSelection:RandomHero({PlayerID = id})
--		return
--	end

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		PlayerResource:SetHasRandomed(hero:GetPlayerOwnerID())
		HeroSelection:HeroSelect({PlayerID = hero:GetPlayerOwnerID(), HeroName = random_hero, HasRandomed = true})
		HeroSelection.playerPickState[hero:GetPlayerOwnerID()].random_state = true
	end

	Chat:PlayerRandomed(0, PlayerResource:GetPlayer(0), PlayerResource:GetTeam(0), random_hero)
end

--[[
	HeroSelect
	A player has selected a hero. This function is caled by the CustomGameEventManager
	once a 'hero_selected' event was seen.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:HeroSelect(event)

	-- If this player has not picked yet give him the hero
	if PlayerResource:GetConnectionState(event.PlayerID) == 1 then
		HeroSelection:AssignHero( event.PlayerID, event.HeroName )
	else
		if not HeroSelection.playerPicks[ event.PlayerID ] then
			HeroSelection.playersPicked = HeroSelection.playersPicked + 1
			HeroSelection.playerPicks[ event.PlayerID ] = event.HeroName

			-- Add the picked hero to the list of picks of the relevant team
			if PlayerResource:GetTeam(event.PlayerID) == DOTA_TEAM_GOODGUYS then
				HeroSelection.radiantPicks[#HeroSelection.radiantPicks + 1] = event.HeroName
			else
				HeroSelection.direPicks[#HeroSelection.direPicks + 1] = event.HeroName
			end

			print("Added "..event.HeroName.." to the picked heroes list.")
			table.insert(HeroSelection.picked_heroes, event.HeroName)

			-- Send a pick event to all clients
			local has_randomed = false
			if event.HasRandomed then has_randomed = true end
			CustomGameEventManager:Send_ServerToAllClients("hero_picked", {PlayerID = event.PlayerID, HeroName = event.HeroName, Team = PlayerResource:GetTeam(event.PlayerID), HasRandomed = has_randomed})
			if PlayerResource:GetConnectionState(event.PlayerID) ~= 1 then
				HeroSelection.playerPickState[event.PlayerID].pick_state = "selected_hero"
				print("Pick State:", event.PlayerID, HeroSelection.playerPickState[event.PlayerID].pick_state)
			end

			-- Assign the hero if picking is over
			if HeroSelection.TimeLeft <= 0 and HeroSelection.playerPickState[event.PlayerID].pick_state ~= "in_game" then
				HeroSelection:AssignHero( event.PlayerID, event.HeroName )
				HeroSelection.playerPickState[event.PlayerID].pick_state = "in_game"
				print("Pick State:", event.PlayerID, HeroSelection.playerPickState[event.PlayerID].pick_state)
				CustomGameEventManager:Send_ServerToAllClients("hero_loading_done", {} )
			end

			-- Play pick sound to the player
			EmitSoundOnClient("HeroPicker.Selected", PlayerResource:GetPlayer(event.PlayerID))
		end
	end

	-- If this is All Random and the player picked a hero manually, refuse it
	if IMBA_PICK_MODE_ALL_RANDOM or IMBA_PICK_MODE_ALL_RANDOM_SAME_HERO and (not event.HasRandomed) then
		return nil
	end

	for _, picked_hero in pairs(HeroSelection.radiantPicks) do
		if event.HeroName == picked_hero then
			return nil
		end
	end

	for _, picked_hero in pairs(HeroSelection.direPicks) do
		if event.HeroName == picked_hero then
			return nil
		end
	end
end

-- Handles player repick
function HeroSelection:HeroRepicked( event )
	local player_id = event.PlayerID
	local hero_name = HeroSelection.playerPicks[player_id]

	-- Fire repick event to all players
	CustomGameEventManager:Send_ServerToAllClients("hero_unpicked", {PlayerID = player_id, HeroName = hero_name, Team = PlayerResource:GetTeam(player_id)})

	-- Remove the player's currently picked hero
	HeroSelection.playerPicks[ player_id ] = nil

	-- Remove the picked hero to the list of picks of the relevant team
	if PlayerResource:GetTeam(player_id) == DOTA_TEAM_GOODGUYS then
		for pick_index, team_pick in pairs(HeroSelection.radiantPicks) do
			if team_pick == hero_name then
				table.remove(HeroSelection.radiantPicks, pick_index)
			end
		end
	else
		for pick_index, team_pick in pairs(HeroSelection.direPicks) do
			if team_pick == hero_name then
				table.remove(HeroSelection.direPicks, pick_index)
			end
		end
	end

	-- Decrement player pick count
	HeroSelection.playersPicked = HeroSelection.playersPicked - 1

	-- Flag the player as having repicked
	PlayerResource:CustomSetHasRepicked(player_id, true)
	HeroSelection.playerPickState[player_id].pick_state = "selecting_hero"
	print("Pick State:", player_id, HeroSelection.playerPickState[player_id].pick_state)
	HeroSelection.playerPickState[player_id].repick_state = true
	HeroSelection.playerPickState[player_id].random_state = false

	-- Play pick sound to the player
	EmitSoundOnClient("ui.pick_repick", PlayerResource:GetPlayer(player_id))
end

--[[
	EndPicking
	The final function of hero selection which is called once the selection is done.
	This function spawns the heroes for the players and signals the picking screen
	to disappear.
]]
function HeroSelection:EndPicking()
	local time = 0.0

	--Stop listening to events (except picks)
	CustomGameEventManager:UnregisterListener( HeroSelection.listener_repick )

	-- Let all clients know the picking phase has ended
	CustomGameEventManager:Send_ServerToAllClients("picking_done", {} )

	-- Assign the picked heroes to all players that have picked
	for player_id = 0, HeroSelection.numPickers do
		if HeroSelection.playerPicks[player_id] and HeroSelection.playerPickState[player_id].pick_state ~= "in_game" then
			HeroSelection:AssignHero(player_id, HeroSelection.playerPicks[player_id])
			HeroSelection.playerPickState[player_id].pick_state = "in_game"
			print("Pick State:", player_id, HeroSelection.playerPickState[player_id].pick_state)
		end
	end

	-- Let all clients know hero loading has ended
	CustomGameEventManager:Send_ServerToAllClients("hero_loading_done", {} )

	-- Stop picking phase music
	StopSoundOn("Imba.PickPhaseDrums", HeroSelection.pick_sound_dummy_good)
	StopSoundOn("Imba.PickPhaseDrums", HeroSelection.pick_sound_dummy_bad)

	-- Destroy dummy!
	UTIL_Remove(HeroSelection.pick_sound_dummy_good)
	UTIL_Remove(HeroSelection.pick_sound_dummy_bad)
end

--[[
	AssignHero
	Assign a hero to the player. Replaces the current hero of the player
	with the selected hero, after it has finished precaching.
	Params:
		- player_id {integer} - The playerID of the player to assign to.
		- hero_name {string} - The unit name of the hero to assign (e.g. 'npc_dota_hero_rubick')
]]
function HeroSelection:AssignHero(player_id, hero_name, dev_command)
	PrecacheUnitByNameAsync(hero_name, function()
		-- Dummy invisible wisp
		local wisp = PlayerResource:GetPlayer(player_id):GetAssignedHero()
		local hero = PlayerResource:ReplaceHeroWith(player_id, hero_name, 0, 0 )

		-------------------------------------------------------------------------------------------------
		-- IMBA: First hero spawn initialization
		-------------------------------------------------------------------------------------------------

		hero:RespawnHero(false, false)
		PlayerResource:SetCameraTarget(player_id, hero)
		Timers:CreateTimer(FrameTime(), function()
			PlayerResource:SetCameraTarget(player_id, nil)
		end)

		-- Initializes player data if this is a bot
		if PlayerResource:GetConnectionState(player_id) == 1 then
			PlayerResource:InitPlayerData(player_id)
		end

		-- Make heroes briefly visible on spawn (to prevent bad fog interactions)
		Timers:CreateTimer(0.5, function()
			hero:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, 0.5)
			hero:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, 0.5)
		end)

		-- Set killstreak hero value
		hero.killstreak = 0

		-- Set up initial gold
		-- local has_randomed = PlayerResource:HasRandomed(player_id)
		-- This randomed variable gets reset when the player chooses to Repick, so you can detect a rerandom
		local has_randomed = HeroSelection.playerPickState[player_id].random_state
--		local has_repicked = PlayerResource:CustomGetHasRepicked(player_id)

--		local initial_gold = tonumber(CustomNetTables:GetTableValue("game_options", "initial_gold")["1"]) or 600
		local initial_gold = 600

--		if has_repicked and has_randomed then
			PlayerResource:SetGold(player_id, initial_gold +100, false)
--		elseif has_repicked then
--			PlayerResource:SetGold(player_id, initial_gold -100, false)
		if has_randomed or IMBA_PICK_MODE_ALL_RANDOM or IMBA_PICK_MODE_ALL_RANDOM_SAME_HERO then
			PlayerResource:SetGold(player_id, initial_gold +200, false)
		else
			PlayerResource:SetGold(player_id, initial_gold, false)
		end

		-- add modifier for custom mechanics handling
--		hero:AddNewModifier(hero, nil, "modifier_custom_mechanics", {})

		-- If a custom hero has been choosed
		for int, unit in pairs(HeroSelection.custom_heroes) do
			if unit == hero_name then
				print("Custom hero picked!")
				HeroSelection:CustomHeroAttachments(hero)
			end
		end

		-- init override of talent window
--		InitializeTalentsOverride(hero)

--		PlayerResource:SetCameraTarget(player_id, nil)
		Timers:CreateTimer(1.0, function()
			hero:RemoveEffects(EF_NODRAW)
			UTIL_Remove(wisp)
		end)

		-- Set initial spawn setup as having been done
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(player_id), "picking_done", {})

		-- TODO: in js, remove the function that gray out a hero when picked, since this function should do it in real time
		HeroSelection:HeroList(0.1) -- send the picked hero list once a hero is picked
	end, player_id)
end

-- Sends this hero's nonhidden abilities to the client
function HeroSelection:PickAbilitiesRequested(event)
	--	PlayerResource:ReplaceHeroWith(event.PlayerID, event.HeroName, 0, 0 )
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(event.PlayerID), "pick_abilities", { heroAbilities = HeroSelection:GetPickScreenAbilities(event.HeroName) })
end

-- Returns an array with the hero's non-hidden abilities
function HeroSelection:GetPickScreenAbilities(hero_name)
local hero_abilities = {}
local custom_hero = false

--	for k, v in pairs(HeroSelection.custom_heroes) do
--		if v == hero_name then
--			custom_hero = true
--			break
--		end
--	end

--	if custom_hero == true then
--		for i = 1, 9 do
--			if GetKeyValueByUnitName(hero_name, "Ability"..i) ~= nil then
--				hero_abilities[i] = GetKeyValueByUnitName(hero_name, "Ability"..i)
--			end
--		end
--		return
--	end

	for i = 1, 9 do
		if GetKeyValueByHeroName(hero_name, "Ability"..i) ~= nil then
			hero_abilities[i] = GetKeyValueByHeroName(hero_name, "Ability"..i)
		end
	end
	return hero_abilities
end

function HeroSelection:CustomHeroAttachments(hero)
	hero_name = string.gsub(hero:GetUnitName(), "npc_dota_hero_", "")

	if hero_name == "troy" then
		hero:SetRenderColor(140, 140, 140)
		hero.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/axe/axe_practos_weapon/axe_practos_weapon.vmdl"})
		hero.weapon:FollowEntity(hero, true)
		hero.weapon:SetRenderColor(200, 200, 200)
	end

	if hero_name == "casalmar" then
		hero:SetRenderColor(155, 146, 80)
	end

	if hero_name == "andrax" then
		hero.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_weapon.vmdl"})
		hero.weapon:FollowEntity(hero, true)
		hero.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_head.vmdl"})
		hero.head:FollowEntity(hero, true)
		hero.armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pangolier/pangolier_armor.vmdl"})
		hero.armor:FollowEntity(hero, true)
		AddAnimationTranslate(hero, "walk")
	end

	if hero_name == "soul_tamer" then
    AddAnimationTranslate(hero, "walk")
    if not hero.soul then
      local move_soul_ab = hero:FindAbilityByName("tamer_move_soul")
      local target_soul_ab = hero:FindAbilityByName("tamer_target_soul")
      if move_soul_ab then
        move_soul_ab:SetLevel(1)
      end
      if target_soul_ab then
        target_soul_ab:SetLevel(1)
      end
      hero.body = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/dragon_knight/dragon_knight.vmdl"})
      hero.body:FollowEntity(hero, true)
      hero.arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/the_havoc_of_dragon_palacesix_ear_armor/the_havoc_of_dragon_palacesix_ear_shoulders.vmdl"})
      hero.arms:FollowEntity(hero, true)
      hero.arms2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/arc_warden/arc_warden_bracers.vmdl"})
      hero.arms2:FollowEntity(hero, true)
      hero.legs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"})
      hero.legs:FollowEntity(hero, true)
      hero.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/ti8_dk_third_awakening_head/ti8_dk_third_awakening_head.vmdl"})
      hero.head:FollowEntity(hero, true)
      hero.soul = CreateUnitByName("npc_dota_creature_spirit_vessel", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
      hero.soul:SetAbsOrigin(Vector(0,0,0)) --Just to trigger the follow caster modifier
      hero.soul:AddNewModifier(hero, nil, "modifier_soul_tamer", {})
      local ability = hero:FindAbilityByName("tamer_move_soul")
      ability:ApplyDataDrivenModifier(hero, hero, "modifier_soul_check_distance", {})
    end
  end

	if hero_name == "krigler" then
	AddAnimationTranslate(hero, "walk")
      AddAnimationTranslate(hero, "arcana")
      hero.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/krigler/jugg_sword.vmdl"})
      hero.weapon:FollowEntity(hero, true)
      hero.weapon:SetRenderColor(200, 200, 200)
      hero.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/krigler/jugg_mask.vmdl"})
      hero.head:FollowEntity(hero, true)
      hero.head:SetRenderColor(200, 200, 200)
      hero.pants = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"})
      hero.pants:FollowEntity(hero, true)
      hero:AddNewModifier(hero, nil, "modifier_krigler_effects", {})
  end
	  if hero_name == "sage_ronin" then
		  AddAnimationTranslate(hero, "walk")
	      hero.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/krigler/jugg_sword.vmdl"})
	      hero.weapon:FollowEntity(hero, true)
	      hero.weapon:SetRenderColor(200, 200, 200)
	      hero.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/krigler/jugg_mask.vmdl"})
	      hero.head:FollowEntity(hero, true)
	      hero.head:SetRenderColor(200, 200, 200)
	      hero.pants = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"})
	      hero.pants:FollowEntity(hero, true)
	  end

	if hero_name == "lathaal" then
		hero.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/the_family_values_weapon/the_family_values_weapon.vmdl"})
		hero.weapon:FollowEntity(hero, true)
		hero.weapon:SetRenderColor(200, 200, 200)

	end

	if hero_name == "brax" then
		hero:SetRenderColor(240, 25, 25)
		hero.hat = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/storm_spirit/tormenta_head/tormenta_head.vmdl"})
		hero.hat:FollowEntity(hero, true)
		hero.hat:SetRenderColor(240, 25, 25)
	end
end

function HeroSelection:GiveStartingHero(playerID, heroName, keepProgress)

	if keepProgress then
		local player = PlayerResource:GetPlayer(playerID)
		local hero = player:GetAssignedHero()

		local level = hero:GetLevel()
		local items = {}
		for i = 0, 9 do
			local item = hero:GetItemInSlot(i)
			if item then 
				table.insert(items, item:GetName())
				item:RemoveHeroSelection()
			else
				table.insert(items, "item_banana")
			end
		end

		local XP = PlayerResource:GetTotalEarnedXP(hero:GetPlayerOwnerID())
		local newHero = PlayerResource:ReplaceHeroWith(playerID, heroName, PlayerResource:GetGold(hero:GetPlayerOwnerID()), hero:GetCurrentXP())	
		
		--newHero:RemoveItem(newHero:FindItemInInventory("item_tpscroll"))

		for _, item in pairs(items) do
			newHero:AddItem(CreateItem(item, newHero, newHero))
		end

		for i = 0, 9 do
			local item = hero:GetItemInSlot(i)
			if item and item:GetName() == "item_banana" then
				newHero:RemoveItem(item)
			end
		end

		for i = 2, level do
			newHero:HeroLevelUp(false)
		end

		newHero:AddExperience(XP,0,false,true)
		--newHero:SetCustomHeroMaxLevel(25)
		return newHero
	else
		PlayerResource:ReplaceHeroWith(playerID, heroName, 0, 0)
		return nil
	end

end

--[[
	Restart
	Call this function in demo tools when changing heroes
]]
function HeroSelection:Restart()
	for pID = 0, DOTA_MAX_PLAYERS -1 do
		if PlayerResource:IsValidPlayer( pID ) then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID), "picking_restart", {PlayerID = pID, HeroName = HeroSelection.playerPicks[pID], Team = PlayerResource:GetTeam(pID)})
			HeroSelection.playerPickState[pID].pick_state = "selecting_hero"
			HeroSelection.playerPicks[pID] = nil
		end
	end
end