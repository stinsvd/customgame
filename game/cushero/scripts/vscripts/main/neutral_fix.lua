NeutralCampsFixer = NeutralCampsFixer or class({})

function NeutralCampsFixer:Init()
	self.HIDDEN_NEUTRALS = {}
end

function NeutralCampsFixer:RespawnCreep(entindex)
	local data = table.copy(self.HIDDEN_NEUTRALS[entindex])
	local name = data["name"]
	local position = data["position"]
	local health = data["health"]
	local health_regen = data["health_regen"]
	local max_health = data["max_health"]
	local mana = data["mana"]
	local mana_regen = data["mana_regen"]
	local max_mana = data["max_mana"]
	local abilities = data["abilities"]
	local items = data["items"]
	local time = data["time"]
	CreateUnitByNameAsync(name, position, true, nil, nil, DOTA_TEAM_NEUTRALS, function(unit)
		local now = GameRules:GetDOTATime(true, false)
		local elapsed_time = now-time
		unit.__neutralcampsfixer_hide_cooldown = now
		unit:SetBaseMaxHealth(max_health)
		unit:SetMaxHealth(max_health)
		unit:SetHealth(health+(elapsed_time*health_regen))
		unit:SetMaxMana(max_mana)
		unit:SetMana(mana+(elapsed_time*mana_regen))
		for i=0, unit:GetAbilityCount()-1 do
			if abilities[i] == nil then
				local ability = unit:GetAbilityByIndex(i)
				if ability ~= nil then
					ability:RemoveAbilityByHandle(ability)
				end
			end
		end
		for ability_index, ability_data in pairs(abilities) do
			local ability = unit:GetAbilityByIndex(ability_index)
			if ability == nil or ability:GetAbilityName() ~= ability_data["name"] then
				unit:RemoveAbilityByHandle(ability)
				ability = unit:AddAbility(ability_data["name"])
				ability:SetAbilityIndex(ability_index)
			end
			local cooldown = math.ceil(ability_data["cooldown"]-elapsed_time)
			if cooldown <= 0 then
				ability:StartCooldown(cooldown)
			else
				ability:EndCooldown()
			end
			ability:SetActivated(ability_data["activated"])
			ability:SetCurrentAbilityCharges(ability_data["charges"])
			ability:SetStolen(ability_data["stolen"])
			local toggled = ability_data["toggle"]
			local autocast = ability_data["autocast"]
			Timers:CreateTimer({endTime=FrameTime()*2, callback=function()
				ability:SetToggleState(toggled)
				ability:SetAutoCastState(autocast)
			end}, nil, self)
		end
		for _, i in pairs(table.combine(INVENTORY_SLOTS, BACKPACK_SLOTS)) do
			if items[i] == nil then
				local item = unit:GetItemInSlot(i)
				if item ~= nil then
					unit:RemoveItem(item)
				end
			end
		end
		for slot, item_data in pairs(items) do
			local item = unit:GetItemInSlot(slot)
			if item == nil or item:GetAbilityName() ~= item_data["name"] then
				unit:RemoveItem(item)
				item = unit:AddItemByName(item_data["name"])
				item:SwapItems(slot, item:GetItemSlot())
			end
			local cooldown = math.ceil(item_data["cooldown"]-elapsed_time)
			if cooldown <= 0 then
				item:StartCooldown(cooldown)
			else
				item:EndCooldown()
			end
			item:SetActivated(item_data["activated"])
			item:SetCurrentCharges(item_data["charges"])
			item:SetSecondaryCharges(item_data["secondary_charges"])
			item:SetCanBeUsedOutOfInventory(item_data["out_of_inventory"])
			item:SetCombineLocked(item_data["combine_locked"])
			item:SetDroppable(item_data["droppable"])
			item:SetPurchaser(item_data["purchaser"])
			item:SetPurchaseTime(item_data["purchase_time"])
			item:SetSellable(item_data["sellable"])
			item:SetShareability(item_data["shareability"])
			local toggled = item_data["toggle"]
			local autocast = item_data["autocast"]
			Timers:CreateTimer({endTime=FrameTime()*2, callback=function()
				item:SetToggleState(toggled)
				item:SetAutoCastState(autocast)
			end}, nil, self)
		end
		for index, camp_info in pairs(CAMPS_INFO) do
			if table.contains(camp_info["stacks"], entindex) then
				CAMPS_INFO[index]["stacks"][table.find(camp_info["stacks"], entindex)] = unit:entindex()
				break
			end
		end
		Timers:CreateTimer({endTime=1, callback=function()
			HIDDEN_ENTINDEXES[entindex] = nil
		end}, nil, self)
	end)
	self.HIDDEN_NEUTRALS[entindex] = nil
end

function NeutralCampsFixer:HideCreep(unit)
	HIDDEN_ENTINDEXES[unit:entindex()] = true
	self.HIDDEN_NEUTRALS[unit:entindex()] = {
		time=GameRules:GetDOTATime(true, false),
		name=unit:GetUnitName(),
		position=unit:AI() ~= nil and unit:AI().vSpawnOrigin or unit:GetAbsOrigin(),
		health=unit:GetHealth(),
		health_regen=unit:GetHealthRegen(),
		max_health=unit:GetBaseMaxHealth(),
		mana=unit:GetMana(),
		mana_regen=unit:GetManaRegen(),
		max_mana=unit:GetMaxMana(),
		abilities={},
		items={},
	}
	for i=0, unit:GetAbilityCount()-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability ~= nil then
			self.HIDDEN_NEUTRALS[unit:entindex()]["abilities"][i] = {
				name=ability:GetAbilityName(),
				cooldown=ability:GetCooldownTimeRemaining(),
				activated=ability:IsActivated(),
				toggled=ability:GetToggleState(),
				autocast=ability:GetAutoCastState(),
				charges=ability:GetCurrentAbilityCharges(),
				stolen=ability:IsStolen(),
			}
		end
	end
	for _, i in pairs(table.combine(INVENTORY_SLOTS, BACKPACK_SLOTS)) do
		local item = unit:GetItemInSlot(i)
		if item ~= nil then
			self.HIDDEN_NEUTRALS[unit:entindex()]["items"][i] = {
				name=item:GetAbilityName(),
				cooldown=item:GetCooldownTimeRemaining(),
				activated=item:IsActivated(),
				toggled=item:GetToggleState(),
				autocast=item:GetAutoCastState(),
				charges=item:GetCurrentCharges(),
				secondary_charges=item:GetSecondaryCharges(),
				out_of_inventory=item:CanBeUsedOutOfInventory(),
				combine_locked=item:IsCombineLocked(),
				droppable=item:IsDroppable(),
				purchaser=item:GetPurchaser(),
				purchase_time=item:GetPurchaseTime(),
				sellable=item:IsSellable(),
				shareability=item:GetShareability(),
			}
		end
	end
	UTIL_Remove(unit)
end

function NeutralCampsFixer:OnThink()
	local now = GameRules:GetDOTATime(true, false)
	for entindex, data in pairs(self.HIDDEN_NEUTRALS) do
		local position = data["position"]
		if GridNav:IsLocationVisibleForAnyTeam(position) or #FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, 2600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false) >= 1 then
			self:RespawnCreep(entindex)
		end
	end
	for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
		if not unit:IsBoss() and (unit.__neutralcampsfixer_hide_cooldown == nil or now-unit.__neutralcampsfixer_hide_cooldown > 5) and (unit.__neutralcampsfixer_take_damage == nil or now-unit.__neutralcampsfixer_take_damage > 5) then
			local position = unit:GetAbsOrigin()
			if not GridNav:IsLocationVisibleForAnyTeam(position) and #FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, 3200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false) <= 0 then
				local has_external_modifier = false
				for _, mod in pairs(unit:FindAllModifiers()) do
					local caster = mod:GetCaster()
					if caster ~= unit and caster ~= nil then
						has_external_modifier = true
						break
					end
				end
				if not has_external_modifier then
					self:HideCreep(unit)
				end
			end
		end
	end
	return 1
end

if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then
	NeutralCampsFixer:Init()
end