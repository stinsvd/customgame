CustomHeroArenaEvents = CustomHeroArenaEvents or class({})

function CustomHeroArenaEvents:Init()
	local events = {
		{"game_rules_state_change", "OnStateChanged"},
		{"npc_spawned", "OnNPCSpawned"},
		{"entity_killed", "OnEntityKilled"},
		{"entity_hurt", "OnEntityHurt"},
		{"player_chat", "OnPlayerChat"},
		{"dota_rune_activated_server", "OnRuneActivated"},
		{"dota_ability_channel_finished", "OnAbilityChannelFinished"},
		{"dota_player_used_ability", "OnAbilityUsed"},
		{"dota_non_player_used_ability", "OnAbilityUsed"},
	}
	local events_manager = {
		{"spellshop_spell_buy", "OnSpellBuy", CustomHeroArenaSpellShop},
		{"spellshop_spell_sell", "OnSpellSell", CustomHeroArenaSpellShop},
		{"swap_abilities", "OnSpellsSwap", CustomHeroArenaSpellShop},
		{"loading_screen_choose_option", "OnChooseOption"},
	}
	for _, event_table in pairs(events) do
		local context = event_table[3] or self
		ListenToGameEvent(event_table[1], Dynamic_Wrap(context, event_table[2]), context)
	end
	for _, event_table in pairs(events_manager) do
		local context = event_table[3] or self
		CustomGameEventManager:RegisterListener(event_table[1], Dynamic_Wrap(context, event_table[2]))
	end
end

function CustomHeroArenaEvents:OnStateChanged()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		CustomHeroArenaSpellShop:Init()
		local kill_limit = GameRules:GetOptionValue("kill_limit")
		if kill_limit == 0 then kill_limit = "∞" end
		local free_sell = GameRules:GetOptionValue("free_sell")
		Timers:CreateTimer({endTime=1, callback=function()
			GameRules:SendCustomMessage(tostring("KILL LIMIT: "..kill_limit), 0, 0)
			GameRules:SendCustomMessage("FREE SPELLS SELL: "..(free_sell == 1 and "yes" or "no"), 0, 0)
		end}, nil, self)
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for i=0, DOTA_MAX_TEAM_PLAYERS do
			if PlayerResource:IsValidPlayerID(i) and not PlayerResource:HasSelectedHero(i) then
				PlayerResource:SetHasRandomed(i)
				local player = PlayerResource:GetPlayer(i)
				if player then
					player:MakeRandomHeroSelection()
				end
			end
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:StartDay()
		CustomHeroArenaDuel:Init()
		for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
			unit:HandleData()
			if unit:IsOutpost() then
				local team = tonumber(string.split(unit:GetName(), "_")[2])
				unit:ChangeTeam(team)
				unit:SetTeam(team)
			end
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:StartNight()
		NeutralCamps:OnThink()
	end
	CustomHeroArenaThinkers:OnStateChanged()
end

function CustomHeroArenaEvents:OnNPCSpawned(event)
	if not event["entindex"] then return end
	local npc = EntIndexToHScript(event["entindex"])
	local playerOwnerEntity = PlayerResource:GetSelectedHeroEntity(npc:GetPlayerOwnerID())
	if npc.bFirstSpawn == nil then
		npc:HandleData()
		if npc:IsTrueHero() then
			for i=0, npc:GetAbilityCount()-1 do
				local ability = npc:GetAbilityByIndex(i)
				local remove_exceptions = {"abyssal_underlord_portal_warp", "twin_gate_portal_warp", "ability_pluck_famango", "ability_capture", "ability_lamp_use"}
				if ability ~= nil and not ability:IsInnateAbility() and not ability:IsFacetAbility() and ((not string.startswith(ability:GetAbilityName(), "special_bonus_") and not table.contains(remove_exceptions, ability:GetAbilityName())) or ability:GetAbilityName() == "special_bonus_attributes") then -- TODO: remove talent check
					ability:RemoveSelf()
				end
			end
		elseif npc:IsIllusion() then
			Timers:CreateTimer({endTime=FrameTime()*2, callback=function()
				npc:CopyAbilities()
			end}, nil, self)
		end
		if npc:IsHero() then
			npc:AddNewModifier(npc, nil, "modifier_global_override_lua", {})
		end
		npc.bFirstSpawn = false
	elseif npc.respawninfo ~= nil then
		FindClearSpaceForUnit(npc, GetGroundPosition(npc.respawninfo["origin"], npc), false)
		npc:SetForwardVector(npc.respawninfo["facing"])
		npc:SetHealth((npc.respawninfo["health"]/100)*npc:GetMaxHealth())
		npc:SetMana((npc.respawninfo["mana"]/100)*npc:GetMaxMana())
		npc.respawninfo = nil
	else
		if npc:IsTrueHero() and npc:HasAbility("meepo_divided_we_stand_lua") then
			for _, meepo in pairs(Entities:FindAllByName(npc:GetUnitName())) do
				if meepo ~= npc and meepo:IsClone() then
					meepo:RespawnHero(false, false)
				end
			end
		end
	end
	if IsInToolsMode() then
		if npc:IsHero() then
			npc:AddNewModifier(npc, nil, "modifier_global_override_lua", {})
		end
	end
	if IsValidEntity(playerOwnerEntity) and playerOwnerEntity ~= nil and npc ~= playerOwnerEntity and npc:GetUnitName() == playerOwnerEntity:GetUnitName() then
		if npc:IsTempestDouble() then
			Timers:CreateTimer({endTime=FrameTime()*2, callback=function()
				if not IsValidEntity(npc) then return end
				npc:CopyAbilities()
			end}, nil, self)
		end
	end
end

local function RollDrop(npc, attacker, presets, always_drop)
	local loot = {}
	for _, preset in pairs(presets) do
		if RollPseudoRandomPercentage(tonumber(preset["chance"]), BOSS_LOOT_PRESET_PSEUDORANDOM_ID, attacker) then
			for item, chance in pairs(preset["items"]) do
				if RollPseudoRandomPercentage(tonumber(chance), BOSS_LOOT_PSEUDORANDOM_ID, attacker) then
					table.insert(loot, item)
				end
			end
			break
		end
	end
	if always_drop and table.length(loot) <= 0 then
		return RollDrop(npc, attacker, presets, always_drop)
	end
	return loot
end
function CustomHeroArenaEvents:OnEntityKilled(event)
	if not event["entindex_killed"] then return end
	local npc = EntIndexToHScript(event["entindex_killed"])
	local attacker = event["entindex_attacker"] ~= nil and EntIndexToHScript(event["entindex_attacker"]) or nil
	local ability = event["entindex_inflictor"] ~= nil and EntIndexToHScript(event["entindex_inflictor"]) or nil
	local damage_flags = event["damagebits"] -- NOTE: unknown
	local unit_kv = GetUnitKeyValuesByName(npc:GetUnitName())
	local deadOnDuel = npc:IsTrueHero() and CustomHeroArenaDuel:IsOnDuel(npc:GetPlayerOwnerID())
	if deadOnDuel then
		CustomHeroArenaDuel:OnDuelKill(event, CustomHeroArenaDuel:GetDuelTrigger(npc:GetPlayerOwnerID()):entindex())
	end
	if npc:IsReincarnating() then return end
	if npc:IsTrueHero() then
		for _, i in pairs(table.combine(INVENTORY_SLOTS, BACKPACK_SLOTS)) do
			local item = npc:GetItemInSlot(i)
			if item ~= nil then
				if item.OnDeath ~= nil then
					item:OnDeath()
				end
			end
		end
		if not deadOnDuel then
			local units = {npc}
			if npc:HasAbility("meepo_divided_we_stand_lua") then
				for _, meepo in pairs(Entities:FindAllByName(npc:GetUnitName())) do
					if meepo ~= npc and meepo:IsClone() or meepo:IsTrueHero() and meepo:GetPlayerOwnerID() == npc:GetPlayerOwnerID() then
						table.insert(units, meepo)
					end
				end
			end
			for _, unit in pairs(units) do
				unit:SetTimeUntilRespawn(unit:GetRespawnTimeFormula())
			end
		end
	end
	if npc:GetTeamNumber() == DOTA_TEAM_NEUTRALS and not npc:IsBoss() and not npc:IsControllableByAnyPlayer() then
		local friends = table.values(table.filter(FindUnitsInRadius(attacker:GetTeamNumber(), npc:GetAbsOrigin(), nil, 750, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false), function(_, unit) return unit:IsTrueHero() end))
		if table.length(friends) > 0 or attacker:IsTrueHero() then
			if RollPseudoRandomPercentage(35, DOTA_PSEUDO_RANDOM_NEUTRAL_DROP_TIER1, attacker) then
				local now = GameRules:GetDOTATime(false, false)

				local kv = LoadKeyValues("scripts/npc/npc_neutral_items_custom.txt")

				local tiers = table.filter(kv["neutral_tiers"], function(tier, data)
					local minute, second = unpack(string.split(data["start_time"], ":"))
					return now >= tonumber(minute) * 60 + tonumber(second)
				end)

				if table.length(tiers) > 0 then
					local item = CreateItem("item_madstone_bundle", nil, nil)
					item:SetLevel(npc:IsAncient() and 1 or 2)
					local drop = CreateItemOnPositionForLaunch(npc:GetAbsOrigin(), item)

					item:LaunchLoot(true, 200, 0.5, attacker:GetAbsOrigin(), attacker:IsHero() and owner or undefined)
				end
			end
		end
	end
	if unit_kv["CustomData"] ~= nil then
		if unit_kv["CustomData"]["Drop"] ~= nil and not npc:IsControllableByAnyPlayer() then
			local always_drop = unit_kv["CustomData"]["Drop"]["AlwaysDrop"] ~= nil and BoolToNum(unit_kv["CustomData"]["Drop"]["AlwaysDrop"]) or false
			local loot_table = RollDrop(npc, attacker, unit_kv["CustomData"]["Drop"]["Presets"], always_drop)
			for _, item_name in pairs(loot_table) do
				local item = CreateItem(item_name, nil, nil)
				item:SetPurchaser(nil)
				local drop = CreateItemOnPositionSync(GetGroundPosition(npc:GetAbsOrigin(), npc), item)
				item:LaunchLoot(false, 250, 0.65, GetGroundPosition(npc:GetAbsOrigin() + RandomVector(RandomInt(10, 250)), npc), nil)
			end
		end
	end
	local kill_limit = GameRules:GetOptionValue("kill_limit")
	if npc:GetUnitName() == "npc_dota_boss_tormentor" then
		GameRules:SetGameWinner(attacker:GetTeamNumber())
	elseif kill_limit ~= 0 and GetTeamHeroKills(attacker:GetTeamNumber()) >= kill_limit then
		GameRules:SetGameWinner(attacker:GetTeamNumber())
	end
end

function CustomHeroArenaEvents:OnEntityHurt(event)
	if not event["entindex_killed"] then return end
	local npc = EntIndexToHScript(event["entindex_killed"])
	local attacker = event["entindex_attacker"] ~= nil and EntIndexToHScript(event["entindex_attacker"]) or nil
	local ability = event["entindex_inflictor"] ~= nil and EntIndexToHScript(event["entindex_inflictor"]) or nil
	local damage = event["damage"]
	local damage_flags = event["damagebits"] -- NOTE: unknown
	if npc:GetTeamNumber() == DOTA_TEAM_NEUTRALS and not npc:IsBoss() then
		npc.__neutralcampsfixer_take_damage = GameRules:GetDOTATime(true, false)
		if npc:AI() ~= nil then
			npc:AI():OnTakeDamage(attacker, damage, ability)
		end
	end
end

function CustomHeroArenaEvents:OnPlayerChat(event)
	local playerID = event["playerid"]
	local teamonly = event["teamonly"]
	local text = event["text"]
	local userID = event["userid"]
	local npc = PlayerResource:GetSelectedHeroEntity(playerID)
	if string.startswith(text, "!") then
		if text == "!fixduel" then
			if npc:IsTrueHero() then
				if npc.SetRespawnsDisabled ~= nil and npc:GetRespawnsDisabled() then
					local deadOnDuel = false
					for trigger_entindex, units in pairs(DUEL_INFO["triggers"]) do
						if table.contains(table.open(units), playerID) then
							deadOnDuel = true
							break
						end
					end
					if not deadOnDuel then
						npc:SetRespawnsDisabled(false)
						npc:RespawnHero(false, false)
						GameRules:SendCustomMessageToTeam("[DEBUG] Trying to enable respawn for "..npc:GetUnitName(), PlayerResource:GetTeam(playerID), 0, 0)
					else
						GameRules:SendCustomMessageToTeam("[DEBUG] Could not respawn "..npc:GetUnitName()..", unit is on duel!", PlayerResource:GetTeam(playerID), 0, 0)
					end
				elseif npc:GetRespawnTime() > 130 then
					npc:SetTimeUntilRespawn(npc:GetRespawnTimeFormula())
				end
				npc:RemoveModifierByName("modifier_life_stealer_infest")
			end
		elseif text == "!ents" then
			local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false)
			GameRules:SendCustomMessage(tostring("[DEBUG] Entity count: "..#units), 0, 0)
		end
	end
end

function CustomHeroArenaEvents:OnRuneActivated(event)
	local playerID = event["PlayerID"]
	local rune = event["rune"]
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if hero == nil then return end
	hero:TriggerAbilitiesCustomCallback("OnRuneActivated", rune)
end

function CustomHeroArenaEvents:OnAbilityChannelFinished(event)
	local abilityname = event["abilityname"]
	local interrupted = event["interrupted"] == 1
	local caster = event["caster_entindex"] ~= nil and EntIndexToHScript(event["caster_entindex"]) or nil
	if caster == nil or abilityname == nil then return end
	local ability = caster:FindAbilityByName(abilityname)
	local target = caster:GetCursorCastTarget()
	if not interrupted then
		if abilityname == "ability_pluck_famango" then
			if table.values(caster:GetItemsByName({"item_famango"}, true, false))[1] ~= nil or caster:HasAnyAvailableInventorySlot() then
				caster:TriggerAbilitiesCustomCallback("OnLotusPickup", target)
			end
		elseif abilityname == "ability_lamp_use" then
			caster:TriggerAbilitiesCustomCallback("OnWatcherCaptured", target, target ~= nil and target:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS)
		end
	end
end

function CustomHeroArenaEvents:OnAbilityUsed(event)
	local playerID = event["PlayerID"]
	local abilityname = event["abilityname"]
	local caster = event["caster_entindex"] ~= nil and EntIndexToHScript(event["caster_entindex"]) or nil
	if caster == nil or abilityname == nil then return end
	local ability = caster:FindAbilityByName(abilityname) or caster:GetItemsByName({abilityname}, true)[1]
	if not ability then return end
	local target = caster:GetCursorCastTarget()
	local point = ability:GetCursorPosition() or caster:GetCursorPosition()
	caster._last_cast_target = target ~= nil and target:entindex() or -1
	if IsValidEntity(target) and target:GetTeamNumber() == DOTA_TEAM_NEUTRALS and not target:IsBoss() and target:AI() ~= nil then
		target:AI():OnAbilityCast(caster, ability)
	end
end

function CustomHeroArenaEvents:OnChooseOption(event)
	local playerID = event["PlayerID"]
	local player = PlayerResource:GetPlayer(playerID)
	local is_host = GameRules:PlayerHasCustomGameHostPrivileges(player)
	if player == nil then return end
	local option = event["option"]
	local value = event["value"]
	if OPTIONS[option] == nil then return end
	if not table.contains(OPTIONS[option]["values"], value) then return end
	if OPTIONS[option]["host_only"] and not is_host then return end
	if OPTIONS[option]["state"] ~= nil and GameRules:State_Get() ~= OPTIONS[option]["state"] then return end
	local t = CustomNetTables:GetTableValue("options", "options") or {}
	t[option] = OPTIONS[option]["validating"](value)
	CustomNetTables:SetTableValue("options", "options", t)
end

if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	CustomHeroArenaEvents:Init()
end