CustomHeroArenaFilters = CustomHeroArenaFilters or class({})

function CustomHeroArenaFilters:Init()
	GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(self, "ModifierFilter"), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(self, "DamageFilter"), self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(self, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(self, "ExperienceFilter"), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(self, "GoldFilter"), self)
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(self, "InventoryFilter"), self)
end

local function ProcessOrderFilter(fc, event, unit, ...)
	local new_unit = fc(event, unit, ...)
	if not new_unit then
		local index = tonumber(table.find(event["units"], unit:entindex()))
		for i=index, table.length(event["units"])-1 do
			event["units"][tostring(i)] = event["units"][tostring(i+1)]
		end
		return false
	elseif type(new_unit) == "table" and IsValidEntity(new_unit) then
		event["units"][tonumber(table.find(event["units"], unit:entindex()))] = new_unit:entindex()
	end
	return true
end
local function OrderTauntFilter(event, unit)
	local issuer = (event["issuer_player_id_const"] ~= nil and PlayerResource:IsValidPlayerID(event["issuer_player_id_const"])) and event["issuer_player_id_const"] or unit:GetPlayerOwnerID()
	local ability = event["entindex_ability"] ~= 0 and EntIndexToHScript(event["entindex_ability"]) or nil
	if unit:IsTaunted() and ((event["order_type"] >= DOTA_UNIT_ORDER_MOVE_TO_POSITION and event["order_type"] <= DOTA_UNIT_ORDER_PICKUP_RUNE) or (event["order_type"] >= DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO and event["order_type"] <= DOTA_UNIT_ORDER_STOP) or (event["order_type"] == DOTA_UNIT_ORDER_MOVE_ITEM and (table.contains(BACKPACK_SLOTS, ability:GetItemSlot()) or table.contains(BACKPACK_SLOTS, event["entindex_target"])))) then
		if IsCastOrder(event["order_type"]) and (ability ~= nil and ability.IsCastableWhileTaunted ~= nil and ability:IsCastableWhileTaunted()) and unit:GetCastingAbility() == nil then
			if event["order_type"] == DOTA_UNIT_ORDER_CAST_TARGET or event["order_type"] == DOTA_UNIT_ORDER_CAST_TARGET_TREE then
				unit:CastAbilityOnTarget(target, ability, issuer)
			elseif event["order_type"] == DOTA_UNIT_ORDER_CAST_POSITION then
				unit:CastAbilityOnPosition(point, ability, issuer)
			elseif event["order_type"] == DOTA_UNIT_ORDER_CAST_TOGGLE then
				unit:CastAbilityToggle(ability, issuer)
			elseif event["order_type"] == DOTA_UNIT_ORDER_CAST_NO_TARGET then
				unit:CastAbilityNoTarget(ability, issuer)
			end
			local attacktarget = unit:GetForceAttackTarget()
			Timers:CreateTimer({endTime=ability:GetCastTime()+FrameTime()*3, callback=function()
				if not IsValidEntity(unit) or not IsValidEntity(attacktarget) or not unit:IsAlive() or not attacktarget:IsAlive() or not unit:IsTaunted() then return end
				unit:SetAttacking(attacktarget)
				unit:MoveToTargetToAttack(attacktarget)
			end}, nil, self)
		end
		return false
	end
	return true
end
local function OrderFearFilter(event, unit)
	if unit:IsFeared() and (event["order_type"] >= DOTA_UNIT_ORDER_MOVE_TO_POSITION and event["order_type"] <= DOTA_UNIT_ORDER_PICKUP_RUNE) or (event["order_type"] == DOTA_UNIT_ORDER_STOP) then
		return false
	end
	return true
end
local function OrderBuybackFilter(event, unit)
	local issuer = (event["issuer_player_id_const"] ~= nil and PlayerResource:IsValidPlayerID(event["issuer_player_id_const"])) and event["issuer_player_id_const"] or unit:GetPlayerOwnerID()
	if event["order_type"] == DOTA_UNIT_ORDER_BUYBACK then
		if unit:GetRespawnsDisabled() then
			PlayerResource:DisplayError(issuer, "#DOTA_Hud_NoBuybackLabel")
			return false
		elseif unit:HasModifier("modifier_earthshaker_enchant_totem_slugger_lua") then
			PlayerResource:DisplayError(issuer, "#dota_hud_error_unit_command_restricted")
			return false
		end
	end
	return true
end
local function OrderCloneFilter(event, unit)
	local ability = event["entindex_ability"] ~= 0 and EntIndexToHScript(event["entindex_ability"]) or nil
	if event["order_type"] == DOTA_UNIT_ORDER_TRAIN_ABILITY and unit:IsClone() then
		return false
	end
	if unit:IsTempestDouble() and ability:GetAbilityName() == "arc_warden_tempest_double" then
		return false
	end
	if IsCastOrder(event["order_type"]) and ability ~= nil and ability:IsItem() and unit:IsClone() then
		if not table.contains({"item_phase_boots", "item_falcon_boots_lua","item_tpscroll"}, ability:GetAbilityName()) or (ability:GetAbilityName() == "item_tpscroll" and not unit:HasItemInInventory("item_travel_boots") and not unit:HasItemInInventory("item_travel_boots_2")) then
			return false
		end
	end
	return true
end
local function OrderToggleFilter(event, unit)
	local ability = event["entindex_ability"] ~= 0 and EntIndexToHScript(event["entindex_ability"]) or nil
	if event["order_type"] == DOTA_UNIT_ORDER_CAST_TOGGLE and ability ~= nil and not ability:IsCooldownReady() then
		return false
	end
	return true
end
local function OrderFakeInvulnerableFilter(event, unit)
	local issuer = (event["issuer_player_id_const"] ~= nil and PlayerResource:IsValidPlayerID(event["issuer_player_id_const"])) and event["issuer_player_id_const"] or unit:GetPlayerOwnerID()
	local target = event["entindex_target"] ~= 0 and EntIndexToHScript(event["entindex_target"]) or nil
	if target and target:IsBaseNPC() and target:HasModifier("modifier_fake_invulnerable") and target:GetTeamNumber() ~= unit:GetTeamNumber() then
		if issuer ~= nil and PlayerResource:IsValidPlayerID(issuer) then
			PlayerResource:DisplayError(issuer, "#dota_hud_error_target_invulnerable")
		end
		return false
	end
	return true
end
local function OrderTPPreventFilter(event, unit)
	if event["queue"] ~= 0 then return true end
	local issuer = (event["issuer_player_id_const"] ~= nil and PlayerResource:IsValidPlayerID(event["issuer_player_id_const"])) and event["issuer_player_id_const"] or unit:GetPlayerOwnerID()
	if not PlayerResource:IsValidPlayerID(issuer) then return true end
	if PlayerResource:ReadSettings(issuer, {tab="OptionsTabContent", text="#dota_settings_teleportrequireshalt", option="CheckBox"}, 1) ~= 1 then
		return true
	end
	local cancel_orders = {
		DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		DOTA_UNIT_ORDER_MOVE_TO_TARGET,
		DOTA_UNIT_ORDER_ATTACK_MOVE,
		DOTA_UNIT_ORDER_ATTACK_TARGET,
		DOTA_UNIT_ORDER_CAST_POSITION,
		DOTA_UNIT_ORDER_CAST_TARGET,
		DOTA_UNIT_ORDER_CAST_TARGET_TREE,
		DOTA_UNIT_ORDER_DROP_ITEM,
		DOTA_UNIT_ORDER_GIVE_ITEM,
		DOTA_UNIT_ORDER_PICKUP_ITEM,
		DOTA_UNIT_ORDER_PICKUP_RUNE,
		DOTA_UNIT_ORDER_CAST_RUNE,
		DOTA_UNIT_ORDER_MOVE_TO_DIRECTION,
		DOTA_UNIT_ORDER_PATROL,
		DOTA_UNIT_ORDER_MOVE_RELATIVE,
	}
	if table.contains(cancel_orders, event["order_type"]) and unit:IsChanneling() then
		for slot, tp in pairs(unit:GetItemsByName({"item_travel_boots_lua", "item_travel_boots_2_lua", "item_tpscroll_lua"}, false, false)) do
			if tp:IsChanneling() then
				event["queue"] = 1
				break
			end
		end
	end
	return true
end
local function OrderSlotFilter(event, unit)
	local issuer = (event["issuer_player_id_const"] ~= nil and PlayerResource:IsValidPlayerID(event["issuer_player_id_const"])) and event["issuer_player_id_const"] or unit:GetPlayerOwnerID()
	local ability = event["entindex_ability"] ~= 0 and EntIndexToHScript(event["entindex_ability"]) or nil
	if event.order_type == DOTA_UNIT_ORDER_MOVE_ITEM and event.entindex_target and ability and ability:IsItem() then
		if (event.entindex_target == DOTA_ITEM_TP_SCROLL or ability:GetItemSlot() == DOTA_ITEM_TP_SCROLL) and (event.entindex_target ~= DOTA_ITEM_NEUTRAL_ACTIVE_SLOT and ability:GetItemSlot() ~= DOTA_ITEM_NEUTRAL_ACTIVE_SLOT) then
			local other_slot_item = unit:GetItemInSlot(event.entindex_target)
			local tp_slot_item = unit:GetItemInSlot(DOTA_ITEM_TP_SCROLL)
			if (ability == nil or (not ability:IsActiveNeutral() and not ability:IsDropsOnDeath())) and (other_slot_item == nil or (not other_slot_item:IsActiveNeutral() and not other_slot_item:IsDropsOnDeath())) then
				if event.entindex_target == DOTA_ITEM_TP_SCROLL then
					ability.__order_filter_can_be_used_out_of_inventory = ability:CanBeUsedOutOfInventory()
					ability:SetCanBeUsedOutOfInventory(true)
					if tp_slot_item ~= nil then
						if tp_slot_item.__order_filter_can_be_used_out_of_inventory ~= nil then
							tp_slot_item:SetCanBeUsedOutOfInventory(tp_slot_item.__order_filter_can_be_used_out_of_inventory)
							tp_slot_item.__order_filter_can_be_used_out_of_inventory = nil
						end
					end
				elseif ability:GetItemSlot() == DOTA_ITEM_TP_SCROLL then
					if tp_slot_item ~= nil then
						tp_slot_item.__order_filter_can_be_used_out_of_inventory = tp_slot_item:CanBeUsedOutOfInventory()
						tp_slot_item:SetCanBeUsedOutOfInventory(true)
					end
					if ability.__order_filter_can_be_used_out_of_inventory ~= nil then
						ability:SetCanBeUsedOutOfInventory(ability.__order_filter_can_be_used_out_of_inventory)
					end
				end
				unit:SwapItems(event.entindex_target, ability:GetItemSlot())
			else
				return false
			end
		end
	end
	return true
end
local function OrderBadCastFilter(event, unit)
	local issuer = (event["issuer_player_id_const"] ~= nil and PlayerResource:IsValidPlayerID(event["issuer_player_id_const"])) and event["issuer_player_id_const"] or unit:GetPlayerOwnerID()
	local point = Vector(event["position_x"], event["position_y"], event["position_z"])
	local target = event["entindex_target"] ~= 0 and EntIndexToHScript(event["entindex_target"]) or nil
	local ability = event["entindex_ability"] ~= 0 and EntIndexToHScript(event["entindex_ability"]) or nil
	if IsCastOrder(event["order_type"]) and ability ~= nil then
		if order == DOTA_UNIT_ORDER_CAST_TARGET and target ~= nil and ability:GetAbilityName() == "clinkz_death_pact" and ((target:IsControllableByAnyPlayer() and target:IsCreep()) or target:IsBoss()) then
			PlayerResource:DisplayError(issuer, "#dota_hud_error_cant_cast_on_summoned")
			return false
		end
	end
	return true
end
local function OrderRightClickFilter(event, unit)
	if unit:IsIllusion() and not unit:IsClone() and not unit:IsTempestDouble() then return true end
	local target = event["entindex_target"] ~= 0 and EntIndexToHScript(event["entindex_target"]) or nil
	local targetInfo = target ~= nil and (target:IsBaseNPC() and GetUnitKeyValuesByName(target:GetUnitName())) or {}
	local ability = event["entindex_ability"] ~= nil and EntIndexToHScript(event["entindex_ability"]) or nil
	if target and table.contains({DOTA_UNIT_ORDER_ATTACK_TARGET, DOTA_UNIT_ORDER_MOVE_TO_TARGET, DOTA_UNIT_ORDER_CAST_TARGET}, event["order_type"]) and (ability == nil or not table.contains({"cast_unit", "teleport_portal_lua"}, ability:GetName())) then
		if targetInfo and targetInfo["CustomData"] ~= nil and targetInfo["CustomData"]["RightClickOpen"] ~= nil and targetInfo["CustomData"]["RightClickOpen"] == 1 then
			if targetInfo["CustomData"]["RightClickTrueHero"] == 1 and not unit:IsTrueHero() then return true end
			if unit:IsChanneling() and unit:GetCursorCastTarget() == target then return false end
			local abil = unit:FindAbilityByName("cast_unit")
			if not abil then
				abil = unit:AddAbility("cast_unit")
				abil:SetAbilityIndex(DOTA_MAX_ABILITIES-1)
				abil:SetLevel(1)
			end
			abil:OrderAbilityOnTarget(target)
			return false
		elseif ability == nil then
			if target:IsLotusPool() then
				local lotus_pool_pickup = unit:FindAbilityByName("ability_pluck_famango")
				if lotus_pool_pickup ~= nil then
					event["entindex_ability"] = lotus_pool_pickup:entindex()
					event["order_type"] = DOTA_UNIT_ORDER_CAST_TARGET
					return true
				end
			elseif target:IsWatcher() then
				local watcher_capture = unit:FindAbilityByName("ability_lamp_use")
				if watcher_capture ~= nil then
					event["entindex_ability"] = watcher_capture:entindex()
					event["order_type"] = DOTA_UNIT_ORDER_CAST_TARGET
					return true
				end
			end
		end
	end
	return true
end
local function OrderModifierFilter(event, unit)
	local modifiers = table.filter(unit:FindAllModifiers(), function(_, mod) return mod.OrderFilter ~= nil and mod.GetPriority ~= nil end)
	table.sort(modifiers, function(a, b) return a:GetPriority() > b:GetPriority() end)
	for _, mod in pairs(modifiers) do
		if not mod:OrderFilter(event) then
			return false
		end
	end
	return true
end
local function OrderVectorTargetFilter(event, unit)
	return VectorTargeting:OrderFilter(event, unit)
end
function CustomHeroArenaFilters:OrderFilter(event)
	local unit = event["units"]["0"] ~= nil and EntIndexToHScript(event["units"]["0"]) or nil
	local units = table.values(table.filter(table.map(event["units"], function(_, entindex) return EntIndexToHScript(entindex) end), function(_, unit) return IsValidEntity(unit) end))
	if unit == nil then return end
	local pid = unit:GetPlayerOwnerID()
	local issuer = (event["issuer_player_id_const"] ~= nil and PlayerResource:IsValidPlayerID(event["issuer_player_id_const"])) and event["issuer_player_id_const"] or pId
	local point = Vector(event["position_x"], event["position_y"], event["position_z"])
	local target = event["entindex_target"] ~= 0 and EntIndexToHScript(event["entindex_target"]) or nil
	local targetInfo = target ~= nil and (target:IsBaseNPC() and GetUnitKeyValuesByName(target:GetUnitName())) or {}
	local ability = event["entindex_ability"] ~= 0 and EntIndexToHScript(event["entindex_ability"]) or nil
	local order = event["order_type"]
	if order == DOTA_UNIT_ORDER_GLYPH then
		local team = PlayerResource:GetTeam(issuer)
		if GLYPH_COOLDOWNS[team] == nil or (GameRules:GetGameTime()-GLYPH_COOLDOWNS[team]) > GameRules:GetGameModeEntity():GetCustomGlyphCooldown() then
			GLYPH_COOLDOWNS[team] = GameRules:GetGameTime()
			ColosseumRebornControlPoints:OnGlyphUsed(PlayerResource:GetTeam(issuer))
			return true
		else
			PlayerResource:DisplayError(issuer, "#dota_hud_error_cant_glyph")
			return false
		end
	-- elseif order == DOTA_UNIT_ORDER_BUYBACK then
	-- 	PlayerResource:SetCustomBuybackCooldown(issuer, BUYBACK_COOLDOWN)
	end
	for _, npc in pairs(units) do
		if ProcessOrderFilter(OrderTauntFilter, event, npc)
		and ProcessOrderFilter(OrderFearFilter, event, npc)
		and ProcessOrderFilter(OrderBuybackFilter, event, npc)
		and ProcessOrderFilter(OrderCloneFilter, event, npc)
		and ProcessOrderFilter(OrderToggleFilter, event, npc)
		and ProcessOrderFilter(OrderFakeInvulnerableFilter, event, npc)
		and ProcessOrderFilter(OrderTPPreventFilter, event, npc)
	--	and ProcessOrderFilter(OrderSlotFilter, event, npc)
		and ProcessOrderFilter(OrderBadCastFilter, event, npc)
		and ProcessOrderFilter(OrderRightClickFilter, event, npc)
		and ProcessOrderFilter(OrderModifierFilter, event, npc) then
			if event["queue"] == 0
			and ProcessOrderFilter(OrderVectorTargetFilter, event, npc) then
			end
		end
	end
	units = table.values(table.filter(table.map(event["units"], function(_, entindex) return EntIndexToHScript(entindex) end), function(_, unit) return IsValidEntity(unit) end))
	if #units == 0 then return false end
	if order == DOTA_UNIT_ORDER_ATTACK_TARGET and target ~= nil and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS and target:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
		for _, neutral in pairs(FindUnitsInRadius(DOTA_TEAM_NEUTRALS, unit:GetAbsOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
			local ai = neutral:AI()
			if not neutral:IsBoss() and ai ~= nil then
				if ai:GetAggroTarget() == target then
					ai:OnOrderAttackAggro(unit)
				end
			end
		end
	end
	return true
end

function CustomHeroArenaFilters:ModifierFilter(event)
	local caster = event["entindex_caster_const"] ~= nil and EntIndexToHScript(event["entindex_caster_const"]) or nil
	local unit = event["entindex_parent_const"] ~= nil and EntIndexToHScript(event["entindex_parent_const"]) or nil
	local ability = event["entindex_ability_const"] ~= nil and EntIndexToHScript(event["entindex_ability_const"]) or nil
	local name = event["name_const"]
	local duration = event["duration"]
	if unit == nil then return true end
	if table.contains({}, name) then return false end
	local duel = CustomHeroArenaDuel:GetDuelInfo()
	if name == "modifier_fountain_invulnerability" and (DUEL_INFO["positions_before_duel"][unit:entindex()] ~= nil or unit.respawninfo ~= nil) then
		return false
	end
	if name == "modifier_fountain_buff_lua" and unit.respawninfo ~= nil then
		return false
	end
	if name == "modifier_bashed" then
		local next_bash = unit.next_bash or 0
		local now = GameRules:GetGameTime()
		if now < next_bash then
			return false
		end
		unit.next_bash = now + duration * BASH_COOLDOWN_MULTIPLIER
	end
	for _, mod in pairs(unit:FindAllModifiers()) do
		if mod.OnModifierFilter ~= nil then
			local result = mod:OnModifierFilter(event)
			if result == false then
				return false
			end
		end
	end
	return true
end

function CustomHeroArenaFilters:DamageFilter(event)
	local attacker = event.entindex_attacker_const ~= nil and EntIndexToHScript(event.entindex_attacker_const) or nil
	local victim = event.entindex_victim_const ~= nil and EntIndexToHScript(event.entindex_victim_const) or nil
	local ability = event.entindex_inflictor_const ~= nil and EntIndexToHScript(event.entindex_inflictor_const) or nil
	local damage_type = tonumber(event.damagetype_const)
	if not victim then return true end
	if attacker.IsBaseNPC and attacker:IsBaseNPC() then
		if attacker.GetPlayerOwnerID ~= nil and victim.GetPlayerOwnerID ~= nil then
			for trigger_entindex, _players in pairs(DUEL_INFO["triggers"]) do
				local players = table.open(_players)
				if (table.contains(players, victim:GetPlayerOwnerID()) and not table.contains(players, attacker:GetPlayerOwnerID())) or (table.contains(players, attacker:GetPlayerOwnerID()) and not table.contains(players, victim:GetPlayerOwnerID())) then
					event.damage = 0
					return true
				end
			end
		end
		if attacker:IsFountain() and (victim:GetTeamNumber() == DOTA_TEAM_NEUTRALS or victim:IsBoss()) then
			event.damage = 0
			return true
		end
		if attacker:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS and attacker:GetTeamNumber() ~= victim:GetTeamNumber() and (attacker:HasModifier("modifier_fountain_buff_lua") or victim:HasModifier("modifier_fountain_buff_lua")) then
			event.damage = 0
			return true
		end
		local has_spell_crit = false
		local pure_resistance = 0
		for _, mod in pairs(attacker:FindAllModifiers()) do
			if mod.GetModifierAttackDamageConversion then
				local damagetype = mod:GetModifierAttackDamageConversion()
				if damagetype then
					event.damagetype_const = damagetype
				end
			end
			if ability ~= nil then
				if mod.GetModifierSpell_CriticalDamage and not has_spell_crit then
					local multiplier = mod:GetModifierSpell_CriticalDamage(event)
					if multiplier then
						event.damage = event.damage + (event.damage * (multiplier / 100))
					end
					has_spell_crit = true
				end
			end
		end
		for _, mod in pairs(victim:FindAllModifiers()) do
			if mod.GetModifierPureResistanceBonus ~= nil then
				local resistance = mod:GetModifierPureResistanceBonus()
				if resistance then
					pure_resistance = pure_resistance + resistance
				end
			end
		end
		if event.damagetype_const ~= damage_type then
			ApplyDamage({victim=victim, attacker=attacker, damage=event.damage, damage_type=event.damagetype_const, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=ability})
			return false
		end
		if event.damagetype_const == DAMAGE_TYPE_PURE and pure_resistance ~= 0 then
			event.damage = event.damage * (1 - pure_resistance/100)
		end
		if event.damage >= victim:GetHealth() and attacker:IsMonkey() then
			ApplyDamage({victim=victim, attacker=attacker:GetSource(), damage=event.damage, damage_type=event.damagetype_const, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=ability})
			return false
		end
	end
	return true
end

function CustomHeroArenaFilters:ExperienceFilter(event)
	local npc = event["hero_entindex_const"] ~= nil and EntIndexToHScript(event["hero_entindex_const"]) or nil
	if npc == nil then return end
	local playerID = event["player_id_const"]
	local reason = event["reason_const"]
	local xp = event["experience"]
	if npc:IsClone() then
		local owner = PlayerResource:GetSelectedHeroEntity(playerID)
		owner:AddExperience(xp, reason, true, false)
		event["experience"] = 0
	end
	return true
end

function CustomHeroArenaFilters:GoldFilter(event)
	local playerID = event["player_id_const"]
	local reason = event["reason_const"]
	local gold = event["gold"]
	local reliable = event["reliable"]
	local team = PlayerResource:GetTeam(playerID)
	local player = PlayerResource:GetPlayer(playerID)
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if gold > 0 then
		if table.contains({DOTA_ModifyGold_CreepKill, DOTA_ModifyGold_NeutralKill, DOTA_ModifyGold_BountyRune}, reason) then
			local team_networths = {}
			for _, team in pairs(PlayerResource:GetTeams()) do
				team_networths[team] = table.sum(PlayerResource:GetNetWorthInTeam(team))
			end
			local max_networth = table.max(team_networths)
			local max_networth_team = table.find(team_networths, max_networth)
			if max_networth ~= nil and max_networth_team ~= team then
				local team_networth_info = PlayerResource:GetNetWorthInTeam(team)
				local team_networth = table.sum(team_networth_info)
				if max_networth-team_networth > 1500 then
					local max_networth_team_info = PlayerResource:GetNetWorthInTeam(max_networth_team)
					local max_networth_player = table.find(max_networth_team_info, table.max(max_networth_team_info))
					local max_networth_player_info = PlayerResource:GetNetWorth(max_networth_player)
					local multiplier = math.floor((1-(team_networth_info[playerID]/max_networth_player_info))*100)/100
					local bonus_gold = math.floor(event["gold"] * multiplier)
					if player ~= nil then
						SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, hero, bonus_gold, player)
					end
					event["gold"] = event["gold"] + bonus_gold
				end
			end
		end
	end
	return true
end

function CustomHeroArenaFilters:InventoryFilter(event)
	local parent = event["inventory_parent_entindex_const"] ~= nil and EntIndexToHScript(event["inventory_parent_entindex_const"]) or nil
	local item_parent = event["item_parent_entindex_const"] ~= nil and EntIndexToHScript(event["item_parent_entindex_const"]) or nil
	local item = event["item_entindex_const"] ~= nil and EntIndexToHScript(event["item_entindex_const"]) or nil
	local suggested_slot = event["suggested_slot"]
	if event["suggested_slot"] == -1 and not parent:HasAnyAvailableInventorySlot(true) then
		if parent:GetItemInSlot(DOTA_ITEM_TP_SCROLL) == nil then
			event["suggested_slot"] = DOTA_ITEM_TP_SCROLL
		end
	end
	return true
end

if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then
	CustomHeroArenaFilters:Init()
end