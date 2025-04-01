if CustomHeroArenaSpellShop == nil then
	_G.CustomHeroArenaSpellShop = class({})
end

function CustomHeroArenaSpellShop:Init()
	local blockedHeroes = {
		npc_dota_hero_target_dummy = true,
		npc_dota_hero_base = true,
	--	npc_dota_hero_kez = true,
	}
	local blockedAbil = {
		generic_hidden = true,
		arc_warden_tempest_double = true,
		meepo_divided_we_stand = true,
		morphling_morph_agi = true,
		morphling_morph_str = true,
		morphling_replicate = true,
		ringmaster_empty_souvenir = true,
		rubick_spell_steal = true,
	}
	local spells = {}
	local heroes = {}
	local function AddHeroToList(heroname)
		--[[
		local heroinfo = GetUnitKeyValuesByName(heroname)
		heroes[heroname] = {attribute=heroinfo["AttributePrimary"]}
		spells[heroname] = spells[heroname] or {}
		for i=1, (heroinfo["AbilityTalentStart"] or 10)-1 do
			local spell = heroinfo[tostring("Ability"..i)]
			if spell and not blockedAbil[spell] then
				local kv = GetAbilityKeyValuesByName(spell)
				if kv ~= nil and not string.find(kv.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_HIDDEN") and not string.find(kv.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_SHOW_IN_GUIDES") and tostring(kv["Innate"]) ~= "1" then
					spells[heroname][tostring(i)] = {
						name = spell,
						scepter = tostring(kv["IsGrantedByScepter"]) == "1",
						shard = tostring(kv["IsGrantedByShard"]) == "1",
					}
				end
			end
		end
		]]
		local heroinfo = GetUnitKeyValuesByName(heroname)
		heroes[heroname] = {attribute = heroinfo["AttributePrimary"]}
		spells[heroname] = _abilitiesShop[heroname]
	end
	for heroname, _heroinfo in pairs(LoadKeyValues("scripts/npc/npc_heroes.txt")) do
		if type(_heroinfo) == "table" and not blockedHeroes[heroname] then
			AddHeroToList(heroname)
		end
	end
	for heroname, _heroinfo in pairs(LoadKeyValues("scripts/npc/npc_heroes_custom.txt")) do
		if type(_heroinfo) == "table" and not blockedHeroes[heroname] then
			AddHeroToList(heroname)
		end
	end
	CustomNetTables:SetTableValue("spells_info", "heroes", heroes)
	for heroname, herospells in pairs(spells) do
		CustomNetTables:SetTableValue("spells_info", heroname, herospells)
	end
	
	local bannedPool = CustomNetTables:GetTableValue("spells_info", "banned") or {}
	bannedPool["abilities"] = bannedPool["abilities"] or {}
	bannedPool["banAttempts"] = bannedPool["banAttempts"] or {}
	for i = 0, 11 do
		bannedPool["banAttempts"][tostring(i)] = 2
		CustomNetTables:SetTableValue("spells_info", "banned", bannedPool)
	end
end

function CustomHeroArenaSpellShop:OnSpellAdded(hero, abilities)
	-- for _, ability_name in pairs(abilities) do
	-- 	local ability = hero:FindAbilityByName(ability_name)
	-- 	if ability then
	-- 		local kv = ability:GetAbilityKeyValues()
	-- 	end
	-- end
end

function CustomHeroArenaSpellShop:IsSpellAllowed(abilityname)
	local heroes = CustomNetTables:GetTableValue("spells_info", "heroes")
	for heroname, _ in pairs(heroes) do
		local spells = table.values(CustomNetTables:GetTableValue("spells_info", heroname))
		if spells then
			for _, spell in pairs(spells) do
				if spell["name"] == abilityname then
					return true
				end
			end
		end
	end
	return false
end

function CustomHeroArenaSpellShop:HasLinkenSpell(abilityname)
	local heroes = CustomNetTables:GetTableValue("spells_info", "heroes")
	for heroname, _ in pairs(heroes) do
	--	local spells = table.values(CustomNetTables:GetTableValue("spells_info", heroname))
		local heroinfo = GetUnitKeyValuesByName(heroname)
		for i = 1, (heroinfo["AbilityTalentStart"] or 10) - 1 do
			local spell = heroinfo[tostring("Ability"..i)]
			if spell == abilityname then
				return true
			end
		end
	end
	return false
end

function CustomHeroArenaSpellShop:GetSpellOwner(abilityname)
	local heroes = CustomNetTables:GetTableValue("spells_info", "heroes")
	for heroname, _ in pairs(heroes) do
		local spells = CustomNetTables:GetTableValue("spells_info", heroname)
		if spells then
			for _, spell in pairs(spells) do
				if spell["name"] == abilityname then
					return true
				end
			end
		end
	end
	return "npc_dota_hero_base"
end

function CustomHeroArenaSpellShop:GetSpellCost(abilityname)
	local kv = GetAbilityKeyValuesByName(abilityname)
	if kv["AbilityType"] ~= nil and string.find(kv["AbilityType"], "ABILITY_TYPE_ULTIMATE") then
		return 3
	end
	return 1
end

local function GetLinkedAbilities(ability, filter)
	local kv = ability:GetAbilityKeyValues()
	local abilities = {
		primary = {},
		secondary = {},
		linked = {},
	}
	if ability:GetAssociatedPrimaryAbilities() ~= nil then
		for _, spell in pairs(string.split(ability:GetAssociatedPrimaryAbilities(), ";")) do
			if (CustomHeroArenaSpellShop:IsSpellAllowed(spell) or CustomHeroArenaSpellShop:HasLinkenSpell(spell)) and (filter == nil or filter(spell)) then
				table.insert(abilities["primary"], spell)
			end
		end
	end
	if ability:GetAssociatedSecondaryAbilities() ~= nil then
		for _, spell in pairs(string.split(ability:GetAssociatedSecondaryAbilities(), ";")) do
			if (CustomHeroArenaSpellShop:IsSpellAllowed(spell) or CustomHeroArenaSpellShop:HasLinkenSpell(spell)) and (filter == nil or filter(spell)) then
				table.insert(abilities["secondary"], spell)
			end
		end
	end
	if kv["LinkedAbility"] ~= nil then
		if (CustomHeroArenaSpellShop:IsSpellAllowed(kv["LinkedAbility"]) or CustomHeroArenaSpellShop:HasLinkenSpell(kv["LinkedAbility"])) and (filter == nil or filter(kv["LinkedAbility"])) then
			table.insert(abilities["linked"], kv["LinkedAbility"])
		end
	end
	abilities["all"] = table.open(table.values(abilities))
	return abilities
end

local function AddSpell(hero, abilityname)
	if not hero:HasAbility(abilityname) then
		return hero:AddAbility(abilityname)
	end
end

function CustomHeroArenaSpellShop:AddSpell(hero, abilityname)
	--[[
	local ability = AddSpell(hero, abilityname)
	local abilities = {}
	if ability then
		table.insert(abilities, ability:GetAbilityName())
		local linked = GetLinkedAbilities(ability)
		local primary = table.length(linked["primary"]) > 0 and linked["primary"][1] or ability:GetAbilityName()
		if hero:GetAbilityPoints() < self:GetSpellCost(primary) then
			hero:RemoveAbilityByHandle(ability)
			return -1
		end
		for _, spell in pairs(linked["all"]) do
			local abil = AddSpell(hero, spell)
			if abil then
				abil.zero_points = true
				if not abil:IsHidden() then
					table.insert(abilities, spell)
				end
			end
		end
		hero:FindAbilityByName(primary):SetLevel(1)
		hero:ModifyAbilityPoints(self:GetSpellCost(primary)*(-1))
	end
	return abilities
	]]
	if not hero:HasAbility(abilityname) then
		local apCost = self:GetSpellCost(abilityname)
		if hero:GetAbilityPoints() < apCost then return end
		local ability = hero:AddAbility(abilityname)
		if ability then
			local abilities = {}
			table.insert(abilities, abilityname)
			ability:SetLevel(1)
			hero:ModifyAbilityPoints(self:GetSpellCost(abilityname) * (-1))
			for heroName, spells in pairs(_abilitiesShop) do
				for _, spell in pairs(spells) do
					if spell["name"] == abilityname then
						local sub = spell["sub"]
						if sub then
							local abil = hero:AddAbility(sub)
							if abil then
								abil:SetLevel(1)
								abil:SetHidden(false)
								table.insert(abilities, sub)
								abil.zero_points = true
							end
						end
						local sub2 = spell["sub2"]
						if sub2 then
							local abil = hero:AddAbility(sub2)
							if abil then
								abil:SetLevel(1)
								abil:SetHidden(false)
								table.insert(abilities, sub2)
								abil.zero_points = true
							end
						end
					end
				end
			end
			return abilities
		end
	end
end

local function IsRemovableSpell(ability)
	local blocking_modifiers = {
		["snapfire_mortimer_kisses"] = {"modifier_snapfire_mortimer_kisses"},
	}
	if ability ~= nil then
		if not ability:IsCooldownReady() then
			return "#dota_hud_error_ability_in_cooldown"
		elseif ability:GetToggleState() then
			return "#dota_hud_error_cant_drag_channeling_item"
		elseif ability:IsChanneling() then
			return "#dota_hud_error_cant_drag_channeling_item"
		elseif blocking_modifiers[ability:GetAbilityName()] ~= nil and table.length(table.filter(blocking_modifiers[ability:GetAbilityName()], function(_, mod) return ability:GetCaster():FindModifierByNameAndAbility(mod, ability) ~= nil end)) > 0 then
			return "#dota_hud_error_cant_drag_channeling_item"
			--[[
		else
			if ability:NumModifiersUsingAbility() == 1 then
				if ability:GetIntrinsicModifierName() ~= nil then
					local find_intrinsic = ability:GetCaster():FindModifierByName(ability:GetIntrinsicModifierName())
					if find_intrinsic then
						find_intrinsic:Destroy()
					end
				end
			end
			if ability:NumModifiersUsingAbility() > 0 then
				return "#dota_hud_error_cant_drag_channeling_item"
			end
			]]
		end
	end
	return nil
end

local function RemoveSpell(hero, ability)
	if not ability then return 0 end
	if ability:GetAbilityName() == "monkey_king_wukongs_command_lua" then
		for _, monkey in pairs(ability:GetMonkeys()) do
			if IsValidEntity(monkey) then
				UTIL_Remove(monkey)
			end
		end
	elseif table.contains({"shredder_chakram", "shredder_chakram_2"}, ability:GetAbilityName()) then
		for _, unit in pairs(Entities:FindAllByClassname("npc_dota_thinker")) do
			local mod = unit:FindAllModifiers()[1]
			if mod ~= nil and mod:GetName() == "modifier_shredder_chakram_thinker" then
				mod:Destroy()
				UTIL_Remove(unit)
			end
		end
		for _, mod in pairs(hero:FindAllModifiersByName("modifier_shredder_chakram_disarm")) do
			if mod:GetAbility() == ability then
				mod:Destroy()
			end
		end
	end
	local points = not ability:IsBehavior(DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) and ability:GetLevel()-1+CustomHeroArenaSpellShop:GetSpellCost(ability:GetAbilityName()) or 0
	hero:RemoveAbilityByHandle(ability)
	if ability.zero_points then
		points = 0
	end
	return math.max(points, 0)
end

function CustomHeroArenaSpellShop:RemoveSpell(hero, ability)
	local abilities = table.combine({ability:GetAbilityName()}, GetLinkedAbilities(ability, function(spell) return hero:HasAbility(spell) end)["all"])
	for _, spell_name in pairs(abilities) do
		local error = IsRemovableSpell(hero:FindAbilityByName(spell_name))
		if error ~= nil then
			PlayerResource:DisplayError(hero:GetPlayerOwnerID(), error)
			return -1
		end
	end
	if ability:GetAbilityName() == "storm_spirit_ball_lightning" then
		if hero:HasAbility("storm_spirit_galvanized") then
			PlayerResource:DisplayError(hero:GetPlayerOwnerID(), "#dota_hud_error_ability_is_hidden")
			return -1
		end
	end
	if ability:GetAbilityName() == "life_stealer_infest" then
		if hero:HasModifier("modifier_life_stealer_infest") then
			hero:RemoveModifierByName("modifier_life_stealer_infest")
		end
	end
	local points = 0
	for _, spell_name in pairs(abilities) do
		points = points + RemoveSpell(hero, hero:FindAbilityByName(spell_name))
	end
	hero:ModifyAbilityPoints(points)
	return abilities
end

function CustomHeroArenaSpellShop:OnSpellBuy(event)
	if event == nil or event.PlayerID == nil or event.spell == nil then return end
	if GameRules:IsGamePaused() then return end
	local bannedPool = CustomNetTables:GetTableValue("spells_info", "banned")
	if bannedPool["abilities"][event["spell"]] then return end
	local hero = PlayerResource:GetSelectedHeroEntity(event["PlayerID"])
	if hero and hero:GetAbilityPoints() > 0 then
		hero.abilities = hero.abilities or {}
		if (not hero:HasAbility(event["spell"]) and not table.contains(hero.abilities, event["spell"])) and table.length(hero.abilities) < MAX_ABILITY_COUNT then
			local heroname = CustomHeroArenaSpellShop:GetSpellOwner(event["spell"])
			if heroname == "npc_dota_hero_base" then return end
			local abilities = CustomHeroArenaSpellShop:AddSpell(hero, event["spell"])
			if abilities == -1 then return end
			CustomHeroArenaSpellShop:OnSpellAdded(hero, abilities)
			hero.abilities = table.combine(hero.abilities, abilities) or abilities
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(event["PlayerID"]), "spellshop_spellpoints_update", {})
			local scepter_buff = hero:FindModifierByName("modifier_item_ultimate_scepter")
			if scepter_buff then
				local scepter_ability = scepter_buff:GetAbility()
				scepter_buff:Destroy()
				hero:AddNewModifier(hero, scepter_ability, "modifier_item_ultimate_scepter", {})
			end
			if hero:HasModifier("modifier_item_ultimate_scepter_consumed") then
				hero:RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
				hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
			end
			local scepter_alchemist_buff = hero:FindModifierByName("modifier_item_ultimate_scepter_consumed_alchemist")
			if scepter_alchemist_buff then
				local scepter_caster = scepter_alchemist_buff:GetCaster()
				local scepter_ability = scepter_alchemist_buff:GetAbility()
				scepter_alchemist_buff:Destroy()
				hero:AddNewModifier(scepter_caster or hero, scepter_ability, "modifier_item_ultimate_scepter_consumed_alchemist", {})
			end
			if hero:HasModifier("modifier_item_aghanims_shard") then
				hero:RemoveModifierByName("modifier_item_aghanims_shard")
				hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
			end
		end
	else
		PlayerResource:DisplayError(event["PlayerID"], "#dota_hud_error_ability_cant_upgrade_no_points")
	end
end

function CustomHeroArenaSpellShop:OnSpellSell(event)
	if event == nil or event.PlayerID == nil or event.spell == nil then return end
	if GameRules:IsGamePaused() then return end
	local hero = PlayerResource:GetSelectedHeroEntity(event["PlayerID"])
	local cocktails = table.values(hero:GetItemsByName({"item_spellshop_sell_lua"}, true, true))
	if hero:HasAbility(event["spell"]) and (event.free or table.length(cocktails) > 0 or GameRules:IsCheatMode() or GameRules:GetOptionValue("free_sell") == 1) then
		local ability = hero:FindAbilityByName(event["spell"])
		local info = CustomHeroArenaSpellShop:RemoveSpell(hero, ability)
		if info == -1 then return end
		if not GameRules:IsCheatMode() and GameRules:GetOptionValue("free_sell") ~= 1 then
			cocktails[1]:SpendCharge(0)
		end
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(event["PlayerID"]), "spellshop_spellpoints_update", {})
		hero.abilities = table.filter(hero.abilities, function(k, v) return not table.contains(info, v) end) or {}
	end
end

function CustomHeroArenaSpellShop:OnSpellBan(event)
	if event == nil or event.PlayerID == nil or event.spell == nil then return end
	local bannedPool = CustomNetTables:GetTableValue("spells_info", "banned")
	if bannedPool and bannedPool["banAttempts"][tostring(event.PlayerID)] > 0 then
		local heroes = CustomNetTables:GetTableValue("spells_info", "heroes")
		local pass = false
		local localPool = {}
		if heroes then
			for heroname, _ in pairs(heroes) do
				local abilities = CustomNetTables:GetTableValue("spells_info", heroname)
				if abilities then
					for _, ability in pairs(abilities) do
						if ability["name"] == event.spell and not ability["banned"] then
							ability["banned"] = true
							pass = true
						end
						if ability["banned"] then
							table.insert(localPool, ability["name"])
						end
					end
					CustomNetTables:SetTableValue("spells_info", heroname, abilities)
				end
			end
		end
		if pass then
			bannedPool["banAttempts"][tostring(event.PlayerID)] = bannedPool["banAttempts"][tostring(event.PlayerID)] - 1
			for i = 0, 11 do
				if PlayerResource:IsValidPlayerID(i) then
					local hero = PlayerResource:GetSelectedHeroEntity(i)
					if hero then
						CustomHeroArenaSpellShop:OnSpellSell({
							PlayerID = i,
							spell = event.spell
						})
					end
				end
				CustomNetTables:SetTableValue("spells_info", "banned", bannedPool)
			end
		end
		bannedPool["abilities"] = localPool
		CustomNetTables:SetTableValue("spells_info", "banned", bannedPool)
		CustomGameEventManager:Send_ServerToAllClients("spellshop_spellpoints_update", {})
	end
end

function CustomHeroArenaSpellShop:OnSpellsSwap(event)
	if event == nil or event.PlayerID == nil then return end
	if GameRules:IsGamePaused() then return end
	local hero = PlayerResource:GetSelectedHeroEntity(event["PlayerID"])
	local ability1 = hero:GetAbilityByIndex(event["slot1"])
	local ability2 = hero:GetAbilityByIndex(event["slot2"])
	if ability1 and ability2 and string.find(ability1:GetAbilityName(), "special_bonus_") == nil and string.find(ability2:GetAbilityName(), "special_bonus_") == nil then
		hero:SwapAbilities(ability1:GetAbilityName(), ability2:GetAbilityName(), not ability1:IsHidden(), not ability2:IsHidden())
	end
end
