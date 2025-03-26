CustomHeroArenaThinkers = CustomHeroArenaThinkers or class({})

function CustomHeroArenaThinkers:Init()
	-- Timers:CreateTimer({useGameTime = false, endTime = 0.5, callback = self.OnThinkHalfIgnore})
end

function CustomHeroArenaThinkers:OnStateChanged()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Timers:CreateTimer({endTime = NEUTRAL_CAMPS_RESPAWN, callback = NeutralCamps.OnThink}, nil, NeutralCamps)
		Timers:CreateTimer({endTime = GOLD_TICK_TIME, callback = CustomHeroArenaThinkers.GoldThink}, nil, CustomHeroArenaThinkers)
		Timers:CreateTimer({endTime = FrameTime(), callback = CustomHeroArenaDuel.DuelThink}, nil, CustomHeroArenaDuel)
		Timers:CreateTimer({endTime = FrameTime(), callback = CustomHeroArenaDuel.DuelBorderThink}, nil, CustomHeroArenaDuel)
		Timers:CreateTimer({endTime = BOUNTY_RUNE_SPAWN_INIT, callback = CustomHeroArenaRunes.BountyThink}, nil, CustomHeroArenaRunes)
		Timers:CreateTimer({endTime = POWERUP_RUNE_SPAWN_INIT, callback = CustomHeroArenaRunes.PowerupThink}, nil, CustomHeroArenaRunes)
		Timers:CreateTimer({endTime = XP_RUNE_SPAWN_INIT+FrameTime()*2, callback = CustomHeroArenaRunes.XPThink}, nil, CustomHeroArenaRunes)
		Timers:CreateTimer({endTime = 0.1, callback = NeutralCampsFixer.OnThink}, nil, NeutralCampsFixer)
	end
end

function CustomHeroArenaThinkers:GoldThink()
	for _, i in pairs(PlayerResource:GetPlayerIDs()) do
		PlayerResource:ModifyGold(i, GOLD_PER_TICK, true, DOTA_ModifyGold_GameTick)
	end
	return GOLD_TICK_TIME
end