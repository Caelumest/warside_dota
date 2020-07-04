InternalFilters = class({})

ListenToGameEvent("addon_game_mode_activate",function()
	local contxt = {}
	GameRules:GetGameModeEntity():SetTrackingProjectileFilter( InternalFilters.TrackingProjectileFilter, contxt )
	if not _G.Filters then
		_G.Filters = {}
		for k,v in pairs(InternalFilters) do
			_G.Filters[k] = function()end
			print("TESTEFILTER", dump(_G.Filters))
		end
	end
end, nil)

function InternalFilters:TrackingProjectileFilter(event)
	return Filters:TrackingProjectileFilter(event)
end