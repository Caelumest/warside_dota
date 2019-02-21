modifier_hide_hero = class({})

--------------------------------------------------------------------------------

function modifier_hide_hero:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_hide_hero:CheckState()
	local state = 
	{
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end
