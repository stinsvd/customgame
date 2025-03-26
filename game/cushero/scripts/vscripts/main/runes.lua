CustomHeroArenaRunes = CustomHeroArenaRunes or class({})

function CustomHeroArenaRunes:BountyThink()
	for _, spawner in pairs(Entities:FindAllByName("dota_rune_spawner_bounty")) do
		if IsValidEntity(spawner.rune) then
			UTIL_Remove(spawner.rune)
		end
		spawner.rune = CreateRune(spawner:GetAbsOrigin(), DOTA_RUNE_BOUNTY)
	end
	return BOUNTY_RUNE_SPAWN_INTERVAL
end

function CustomHeroArenaRunes:PowerupThink()
	local runes = {
		DOTA_RUNE_DOUBLEDAMAGE,
		DOTA_RUNE_HASTE,
		DOTA_RUNE_ILLUSION,
		DOTA_RUNE_INVISIBILITY,
		DOTA_RUNE_REGENERATION,
		DOTA_RUNE_ARCANE,
		DOTA_RUNE_SHIELD,
	}
	for _, spawner in pairs(Entities:FindAllByName("dota_rune_spawner_powerup")) do
		if IsValidEntity(spawner.rune) then
			UTIL_Remove(spawner.rune)
		end
		spawner.rune = CreateRune(spawner:GetAbsOrigin(), table.choice(runes))
	end
	return POWERUP_RUNE_SPAWN_INTERVAL
end

function CustomHeroArenaRunes:XPThink()
	for _, spawner in pairs(Entities:FindAllByName("dota_rune_spawner_xp")) do
		if IsValidEntity(spawner.rune) then
			UTIL_Remove(spawner.rune)
		end
		spawner.rune = CreateRune(spawner:GetAbsOrigin(), DOTA_RUNE_XP)
	end
	return XP_RUNE_SPAWN_INTERVAL
end