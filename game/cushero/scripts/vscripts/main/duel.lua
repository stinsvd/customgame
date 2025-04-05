require("main/duel_trigger")

LinkLuaModifier("modifier_duel_start_lua", "main/duel", LUA_MODIFIER_MOTION_NONE)

CustomHeroArenaDuel = CustomHeroArenaDuel or class({})
_G.DUEL_INFO = DUEL_INFO or {triggers = {}, positions_before_duel = {}, positions = {}}

function CustomHeroArenaDuel:Init()
	for _, trigger in pairs(Entities:FindAllByClassname("trigger_multiple")) do
		if string.find(trigger:GetName(), "duel") ~= nil then
			DUEL_INFO["triggers"][trigger:entindex()] = {}
		end
	end
	CustomNetTables:SetTableValue("duel", "timer", self:GetDuelInfo())
end

function CustomHeroArenaDuel:GetDuelInfo()
	return CustomNetTables:GetTableValue("duel", "timer") or {state="waiting", time=DUEL_FIRST_START, reward={gold=DUEL_REWARD_GOLD, xp=DUEL_REWARD_XP}}
end

function CustomHeroArenaDuel:DuelThink()
	local duel = self:GetDuelInfo()
	if duel["state"] == "waiting" and duel["time"] <= 0 then
		local isDuelStarted = self:OnDuelStart()
		if isDuelStarted then
			duel["state"] = "running"
			duel["time"] = DUEL_DURATION
		else
			duel["state"] = "waiting"
			duel["time"] = DUEL_COOLDOWN
			Notifications:TopToAll({text="#CustomHeroArena_duel_not_enough_players", color="red", duation=5})
		end
	elseif duel["state"] == "running" and duel["time"] <= 0 then
		duel["state"] = "waiting"
		duel["time"] = DUEL_COOLDOWN
		for trigger_entindex, players in pairs(DUEL_INFO["triggers"]) do
			if table.length(table.open(players)) > 0 then
				self:OnDuelEnd(DOTA_TEAM_NOTEAM, trigger_entindex)
			end
		end
	else
		duel["time"] = duel["time"] - 0.5
	end
	duel["reward"] = {gold=DUEL_REWARD_GOLD+DUEL_REWARD_GOLD_PM*math.floor(GameRules:GetDOTATime(false, false)/60), xp=DUEL_REWARD_XP+DUEL_REWARD_XP_PM*math.floor(GameRules:GetDOTATime(false, false)/60)}
	CustomNetTables:SetTableValue("duel", "timer", duel)
	return 0.5
end

function CustomHeroArenaDuel:DuelBorderThink()
	local now = GameRules:GetGameTime()
	for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
		local playerID = unit:GetPlayerOwnerID()
		if PlayerResource:IsValidPlayerID(playerID) and not unit:IsOther() and not unit:IsCourier() then
			local info = DUEL_INFO["positions"][unit:entindex()] or {origin=unit:GetAbsOrigin(), time=now}
			if now-info["time"]>=0.5 then
				local trigger = self:GetDuelTrigger(playerID)
				for trigger_entindex, players in pairs(DUEL_INFO["triggers"]) do
					local trigger = EntIndexToHScript(trigger_entindex)
					if table.contains(table.open(players), playerID) then
						if not trigger:IsTouching(unit) then
							CheckUnitForTeleport(trigger, unit, false)
						else
							info["origin"] = unit:GetAbsOrigin()
						end
					else
						if trigger:IsTouching(unit) then
							CheckUnitForTeleport(trigger, unit, true)
						else
							info["origin"] = unit:GetAbsOrigin()
						end
					end
				end
				info["time"] = now
			end
			DUEL_INFO["positions"][unit:entindex()] = info
		end
	end
	return 0.1
end

local function GetAverageNetWorthForPlayers(players)
	return table.mean(table.map(players, function(_, playerID) return PlayerResource:GetNetWorth(playerID) end))
end

function CustomHeroArenaDuel:OnDuelStart()
	local now = GameRules:GetGameTime()
	local bSuccessfull = false
	DUEL_INFO["positions_before_duel"] = {}
	for trigger_index, _ in pairs(DUEL_INFO["triggers"]) do
		local trigger = EntIndexToHScript(trigger_index)
		local playersMin = 1
		local playersMax = 5
		local plIncGold = 25000
		local players = {}
		--[[
		for _, team in pairs(table.shuffle(PlayerResource:GetTeams())) do
			local playerID = table.choice(PlayerResource:GetPlayerIDsInTeam(team))
			if table.length(players) > 0 then
				local avg_networth = table.mean(table.map(players, function(t, pIDs) return GetAverageNetWorthForPlayers(pIDs) end))
				local team_networth = PlayerResource:GetNetWorthInTeam(team)
				playerID = table.find(team_networth, table.nearest(team_networth, avg_networth))
			end
			players[team] = {playerID}
		end
		]]
		local teamPlayers = {}
		for _, playerID in pairs(PlayerResource:GetPlayerIDs()) do
			local team = PlayerResource:GetTeam(playerID)
			if not teamPlayers[team] then
				teamPlayers[team] = {}
			end
			table.insert(teamPlayers[team], {playerID, PlayerResource:GetNetWorth(playerID)})
		end
		for _, team in pairs(PlayerResource:GetTeams()) do
			players[team] = {}
			table.sort(teamPlayers[team], function(a, b) return a[2] > b[2] end)
		end
		local totalNetWorth = table.sum(table.map(teamPlayers, function(_, team) return table.sum(table.map(team, function(_, v) return v[2] end)) end))
		local count = math.min(playersMax, math.max(playersMin, math.floor(totalNetWorth / plIncGold) + 1))
		for i = 1, count do
			for _, team in pairs(PlayerResource:GetTeams()) do
				local playerID = teamPlayers[team][i] and teamPlayers[team][i][1] or nil
				if playerID then
					table.insert(players[team], playerID)
				end
			end
		end
		if table.length(players) >= 2 then
			DUEL_INFO["triggers"][trigger_index] = players
			for team, playerIDs in pairs(players) do
				for _, playerID in pairs(playerIDs) do
					local hero = PlayerResource:GetSelectedHeroEntity(playerID)
					for _, unit in pairs(FindUnitsInRadius(team, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false)) do
						if not unit:IsCourier() and not unit:IsOther() and unit:GetPlayerOwnerID() == playerID and (unit:IsAlive() or unit:IsRealHero()) then
							DUEL_INFO["positions_before_duel"][unit:entindex()] = {
								origin=unit:GetAbsOrigin(), facing=unit:GetForwardVector(), respawnable=unit:IsTrueHero(),
								health=unit:GetHealthPercent(), mana=unit:GetManaPercent(), abilities={}, respawn=unit:IsAlive() and 0 or unit:GetTimeUntilRespawn(),
							}
							for _, mod in pairs(DUEL_REMOVE_MODIFIERS) do
								unit:RemoveModifierByName(mod)
							end
							if not unit:IsAlive() then
								unit:RespawnHero(false, false)
							end
							unit:InterruptMotionControllers(true)
							for i=0, unit:GetAbilityCount()-1 do
								local ability = unit:GetAbilityByIndex(i)
								if ability then
									DUEL_INFO["positions_before_duel"][unit:entindex()]["abilities"][ability:entindex()] = {cooldown=ability:GetCooldownTimeRemaining(), charges=ability:GetMaxAbilityCharges(ability:GetLevel()) > 0 and ability:GetCurrentAbilityCharges() or nil}
									ability:RefreshCharges()
									ability:EndCooldown()
								end
							end
							unit:SetHealth(unit:GetMaxHealth())
							unit:SetMana(unit:GetMaxMana())
							unit:Dispell(unit, true)
							unit:AddNewModifier(unit, nil, "modifier_duel_start_lua", {duration=1})
							unit:AddNewModifier(unit, nil, "modifier_item_third_eye_lua", {_duration=45})
							local spawn_position = Entities:FindByName(nil, tostring(trigger:GetName().."_teleport_"..team))
							FindClearSpaceForUnit(unit, GetGroundPosition(spawn_position:GetAbsOrigin(), unit), false)
							ProjectileManager:ProjectileDodge(unit)
							PlayerResource:SetCameraTarget(playerID, unit)
							PlayerResource:SetCameraTarget(playerID, nil)
							DUEL_INFO["positions"][unit:entindex()] = {origin=GetGroundPosition(spawn_position:GetAbsOrigin(), unit), time=now}
						end
					end
				end
			end
			bSuccessfull = true
		end
	end
	return bSuccessfull
end

function CustomHeroArenaDuel:OnDuelKill(event, trigger_entindex)
	local duel = self:GetDuelInfo()
	if duel["state"] ~= "running" then return end
	local npc = EntIndexToHScript(event["entindex_killed"])
	if not npc:IsReincarnating() then
		npc:SetRespawnsDisabled(true)
	end
	local alive_teams = table.filter(DUEL_INFO["triggers"][trigger_entindex], function(team, players)
		return table.length(table.filter(players, function(_, playerID)
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			return IsValidEntity(hero) and (hero:IsAlive() or hero:IsReincarnating())
		end)) > 0
	end)
	if table.length(alive_teams) == 1 then
		self:OnDuelEnd(table.keys(alive_teams)[1], trigger_entindex)
	end
end

function CustomHeroArenaDuel:OnDuelEnd(WinnerTeam, trigger_entindex)
	local nettable = self:GetDuelInfo()
	local DuelTeams = table.keys(DUEL_INFO["triggers"][trigger_entindex])
	if WinnerTeam ~= DOTA_TEAM_NOTEAM then
		local LosersTeam = table.values(table.filter(DuelTeams, function(_, team) return team ~= WinnerTeam end))
		local team_networths = {}
		for _, team in pairs(DuelTeams) do
			local gold = table.mean(PlayerResource:GetNetWorthInTeam(team))
			if gold > 0 then
				team_networths[team] = gold
			end
		end
		local bonus = nettable["reward"]
		local team_networth_info = PlayerResource:GetNetWorthInTeam(WinnerTeam)
		local max_multiplier = #table.keys(team_networth_info)
		local team_networth = table.sum(team_networth_info)
		local max_networth = table.max(team_networths)
		if max_networth ~= nil then
			local networth_gap_perc = (team_networth/max_networth)*100
			if networth_gap_perc < 50 then
				local multiplier = math.max(100/networth_gap_perc, 10-max_multiplier)
				max_multiplier = max_multiplier + math.round(RandomFloat(math.min(0, multiplier-1), math.max(multiplier+1, 10-max_multiplier)), 2)
			end
		end
		for playerID, networth in pairs(team_networth_info) do
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			local multiplier = (networth/team_networth)*max_multiplier
			PlayerResource:ModifyGold(playerID, bonus["gold"]*multiplier, false, DOTA_ModifyGold_HeroKill)
			hero:AddExperience(bonus["xp"]*multiplier, DOTA_ModifyXP_HeroKill, true, true)
			hero:RemoveModifierByName("modifier_item_third_eye_lua")
		end
	end
	Notifications:TopToAll({text=WinnerTeam ~= DOTA_TEAM_NOTEAM and tostring("#CustomHeroArena_duel_win_"..WinnerTeam) or "#CustomHeroArena_duel_draw", duration=5, color=WinnerTeam ~= DOTA_TEAM_NOTEAM and "white" or "red"})
	DUEL_INFO["triggers"][trigger_entindex] = {}
	for unit_entindex, info in pairs(DUEL_INFO["positions_before_duel"]) do
		local unit = EntIndexToHScript(unit_entindex)
		if IsValidEntity(unit) and unit ~= nil and unit.GetPlayerOwnerID ~= nil then
			local ownerTeam = PlayerResource:GetTeam(unit:GetPlayerOwnerID())
			if table.contains(DuelTeams, ownerTeam) then
				Timers:CreateTimer({endTime=FrameTime(), callback=function()
					if unit.SetRespawnsDisabled ~= nil then
						unit:SetRespawnsDisabled(false)
					end
					if info["respawnable"] then
						if info["respawn"] > 0 then
							unit:SetTimeUntilRespawn(info["respawn"])
						elseif not unit:IsAlive() then
							unit.respawninfo = info
							unit:SetTimeUntilRespawn(0.2)
						end
					end
					unit.afterduel = true
					if info["health"] <= 0 then
						unit:Kill(nil, unit)
					elseif unit:IsAlive() then
						unit:SetHealth((info["health"]/100)*unit:GetMaxHealth())
						unit:SetMana((info["mana"]/100)*unit:GetMaxMana())
						ProjectileManager:ProjectileDodge(unit)
						FindClearSpaceForUnit(unit, GetGroundPosition(info["origin"], unit), false)
						unit:SetForwardVector(info["facing"])
						for _, mod in pairs(DUEL_REMOVE_MODIFIERS) do
							unit:RemoveModifierByName(mod)
						end
					end
					PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), unit)
					PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), nil)
					for i=0, unit:GetAbilityCount()-1 do
						local ability = unit:GetAbilityByIndex(i)
						if ability then
							local abilityinfo = info["abilities"][ability:entindex()]
							if abilityinfo then
								if abilityinfo["cooldown"] <= 0 then
									ability:EndCooldown()
								else
									ability:StartCooldown(abilityinfo["cooldown"])
								end
								if abilityinfo["charges"] ~= nil then
									ability:SetCurrentAbilityCharges(abilityinfo["charges"])
								end
							end
						end
					end
					Timers:CreateTimer({endTime = 0.5, callback = function()
						unit.afterduel = nil
					end}, nil, self)
				end}, nil, self)
			end
		end
	end
	DUEL_INFO["positions_before_duel"] = table.filter(DUEL_INFO["positions_before_duel"], function(unit_entindex, _)
		local unit = EntIndexToHScript(unit_entindex)
		return not IsValidEntity(unit) or not table.contains(DuelTeams, PlayerResource:GetTeam(unit:GetPlayerOwnerID()))
	end)
	local duel = self:GetDuelInfo()
	if duel["state"] == "running" then
		local doNotStopDuels = false
		for trigger_entindex, players in pairs(DUEL_INFO["triggers"]) do
			local alive_players = table.length(table.filter(players, function(_, playerID)
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				return IsValidEntity(hero) and hero:IsAlive()
			end)) > 0
			for _, playerID in pairs(players) do
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				if IsValidEntity(hero) and hero:IsAlive() then
					doNotStopDuels = true
					break
				end
			end
			if doNotStopDuels then break end
		end
		if not doNotStopDuels then
			duel["state"] = "waiting"
			duel["time"] = DUEL_COOLDOWN
			CustomNetTables:SetTableValue("duel", "timer", duel)
		end
	end
end

function CustomHeroArenaDuel:GetDuelTrigger(playerID)
	for trigger_entindex, players in pairs(DUEL_INFO["triggers"]) do
		if table.contains(table.open(players), playerID) then
			return EntIndexToHScript(trigger_entindex)
		end
	end
	return nil
end

function CustomHeroArenaDuel:IsOnDuel(playerID)
	return self:GetDuelTrigger(playerID) ~= nil
end

if GameRules and GameRules.State_Get and GameRules:State_Get() < (DOTA_GAMERULES_STATE_PRE_GAME or 8) then
	CustomHeroArenaDuel:Init()
end


modifier_duel_start_lua = modifier_duel_start_lua or class({})
function modifier_duel_start_lua:IsPurgable() return false end
function modifier_duel_start_lua:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_duel_start_lua:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE} end
function modifier_duel_start_lua:GetAbsoluteNoDamageMagical() return 1 end
function modifier_duel_start_lua:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_duel_start_lua:GetAbsoluteNoDamagePure() return 1 end