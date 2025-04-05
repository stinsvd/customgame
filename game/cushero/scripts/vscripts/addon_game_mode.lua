GameRules.GetOptionValue = function(self, option)
	local t = CustomNetTables:GetTableValue("options", "options") or {}
	if t[option] ~= nil then
		return t[option]
	end
	return _G.OPTIONS[option]["default"]
end

function Require()
	require("lib/json")
	require("lib/encryption")
	require("main/vars")
	require("lib/timers")
	require("lib/selection")
	require("lib/players")
	require("lib/server")
	require("lib/notifications")
	require("lib/abilities")
	if GameRules.GetGameModeEntity and GameRules:GetGameModeEntity() ~= nil then
		require("lib/vector_targeting")
		require("main/neutral_camps")
		require("main/neutral_fix")
		require("main/runes")
		require("main/duel")
		require("main/spellshop")
		require("main/thinkers")
		require("main/filters")
		require("main/events")
	end
end

Require()
CustomHeroArena = CustomHeroArena or class({})

function Precache(context)
	require("main/precache")
	PrecacheModule:Init(context)
end

function Activate()
	Require()
	CustomHeroArena:InitGameMode()
end

function CustomHeroArena:InitGameMode()
	self:InitGameRules()
	self:InitFountains()
end

function CustomHeroArena:InitGameRules()
	GameRules:SetCustomGameSetupAutoLaunchDelay(not IsInToolsMode() and 15 or 3)
	GameRules:SetHeroSelectionTime(30)
	GameRules:SetShowcaseTime(0)
	GameRules:SetStrategyTime(15)
	GameRules:SetPreGameTime(30)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetAllowOutpostBonuses(true)
	GameRules:SetGoldPerTick(0)
	GameRules:SetStartingGold(725)
	GameRules:SetTreeRegrowTime(60)
	GameRules:GetGameModeEntity():SetAllowNeutralItemDrops(true)
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(#XP_TABLE)
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_TABLE)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride(-1)
	GameRules:GetGameModeEntity():SetRandomHeroBonusItemGrantDisabled(true)
	GameRules:GetGameModeEntity():SetRespawnTimeScale(0.1)
	GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_tpscroll")
--	GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_none")
	GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(false)
	GameRules:GetGameModeEntity():SetFriendlyBuildingMoveToEnabled(true)
	GameRules:GetGameModeEntity():SetCustomBackpackSwapCooldown(0)
	GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath(false)
--	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
--	GameRules:GetGameModeEntity():SetCanSellAnywhere(true)
	Convars:SetInt("tv_delay", 0)
	SendToServerConsole("tv_delay 0")
	if GameRules:IsCheatMode() then
		Convars:SetInt("dota_easybuy", 1)
	end
end

function CustomHeroArena:InitFountains()
	for _, fountain in pairs(Entities:FindAllByClassname("ent_dota_fountain")) do
		fountain:RemoveModifierByName("modifier_fountain_aura")
		fountain:AddNewModifier(fountain, nil, "modifier_fountain_aura_lua", {})
	end
end

-- local hero = PlayerResource:GetSelectedHeroEntity(0)
-- -- hero:ModifyIntellect(-500)
-- for i=0, DOTA_MAX_ABILITIES-1 do
-- 	local ability = hero:GetAbilityByIndex(i)
-- 	if ability then
-- 		print(i, ability:GetAbilityName(), ability:IsHidden())
-- 	end
-- end

-- for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
-- 	if unit:GetUnitName() == "npc_dota_boss_nevermore_magic" then
-- 		unit:ForceKill(false)
-- 	end
-- end