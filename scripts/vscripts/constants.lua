if IsInToolsMode() then
	HERO_INITIAL_GOLD = 99999
	HERO_SELECTION_TIME = 5.0
	PRE_GAME_TIME = 15
else
	HERO_INITIAL_GOLD = 625
	HERO_SELECTION_TIME = 30.0
	PRE_GAME_TIME = 90.0 + HERO_SELECTION_TIME
end

DUMMY_HERO = "npc_dota_hero_custom"

function WarsideDotaGameMode:BroadcastMsg( sMsg )
	-- Display a message about the button action that took place
	local buttonEventMessage = sMsg
	--print( buttonEventMessage )
	local centerMessage = {
		message = buttonEventMessage,
		duration = 1.0,
		clearQueue = true -- this doesn't seem to work
	}
	FireGameEvent( "show_center_message", centerMessage )
end