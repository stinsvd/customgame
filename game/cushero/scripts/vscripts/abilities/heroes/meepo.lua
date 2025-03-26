LinkLuaModifier("modifier_meepo_divided_we_stand_lua", "abilities/heroes/meepo", LUA_MODIFIER_MOTION_NONE)

meepo_divided_we_stand_lua = meepo_divided_we_stand_lua or class(ability_lua_base)
function meepo_divided_we_stand_lua:GetCloneSource()
	if IsServer() then
		return PlayerResource:GetSelectedHeroEntity(self:GetCaster():GetPlayerOwnerID())
	end
	return nil
end
function meepo_divided_we_stand_lua:GetClones()
	return table.values(table.filter(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false), function(_, unit)
		return unit:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() and unit:GetUnitName() == self:GetCaster():GetUnitName() and unit:IsClone()
	end))
end
function meepo_divided_we_stand_lua:GetIntrinsicModifierName() return "modifier_meepo_divided_we_stand_lua" end

modifier_meepo_divided_we_stand_lua = modifier_meepo_divided_we_stand_lua or class({})
function modifier_meepo_divided_we_stand_lua:IsHidden() return true end
function modifier_meepo_divided_we_stand_lua:IsPurgable() return false end
function modifier_meepo_divided_we_stand_lua:RemoveOnDeath() return false end
function modifier_meepo_divided_we_stand_lua:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
	if IsServer() and self:GetParent():IsClone() then table.insert(funcs, MODIFIER_PROPERTY_EXP_RATE_BOOST) end
	return funcs
end
function modifier_meepo_divided_we_stand_lua:GetClones()
	return table.values(table.filter(FindUnitsInRadius(self:GetParent():GetTeamNumber(), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false), function(_, unit)
		return unit:GetPlayerOwnerID() == self:GetParent():GetPlayerOwnerID() and unit:GetUnitName() == self:GetParent():GetUnitName() and unit:IsClone()
	end))
end
function modifier_meepo_divided_we_stand_lua:OnCreated()
	if not IsServer() then return end
	self.all_boots = {
		"item_travel_boots_2",
		"item_travel_boots",
		"item_aeon_greaves_lua",
		"item_guardian_greaves",
		"item_might_treads_lua",
		"item_power_treads_lua",
		"item_arcane_boots",
		"item_falcon_boots_lua",
		"item_phase_boots",
		"item_tranquil_boots",
		"item_dead_boots_lua",
		"item_boots",
	}
	if not self:GetParent():IsClone() then
		self:OnCloneCountUpdate()
	end
	self:StartIntervalThink(0.1)
end
function modifier_meepo_divided_we_stand_lua:OnCloneCountUpdate(destroy)
	if not self:GetParent():IsTrueHero() then return end
	local clones = self:GetClones()
	local new_clone_count = (self:GetAbility() ~= nil and not destroy) and self:GetAbility():GetSpecialValueFor("tooltip_clones") or 0
	if new_clone_count ~= #clones then
		if new_clone_count > #clones then
			for i=1, new_clone_count-#clones do
				CreateUnitByNameAsync(self:GetParent():GetUnitName(), self:GetParent():GetAbsOrigin()+RandomVector(16), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber(), function(unit)
					unit:SetControllableByPlayer(self:GetParent():GetPlayerOwnerID(), false)
					unit:CopyAbilities()
					unit:SetHasInventory(false)
				end)
			end
		else
			for i=1, #clones-new_clone_count do
				local clone = clones[i]
				UTIL_Remove(clone)
			end
		end
	end
end
function modifier_meepo_divided_we_stand_lua:OnIntervalThink()
	local owner = self:GetAbility():GetCloneSource()
	if self:GetParent():IsClone() then
		local item = nil
		for _, item_name in pairs(self.all_boots) do
			local temp_item = table.values(owner:GetItemsByName({item_name}, true, false))[1]
			if temp_item ~= nil then
				item = temp_item
				break
			end
		end
		local boots_found = nil
		for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
			local temp_item = self:GetParent():GetItemInSlot(i)
			if temp_item ~= nil then
				if boots_found ~= nil or item == nil or temp_item:GetName() ~= item:GetName() then
					UTIL_Remove(temp_item)
				else
					boots_found = temp_item
				end
			end
		end
		if boots_found == nil and item ~= nil then
			boots_found = self:GetParent():AddItemByName(item:GetName())
			boots_found:SetDroppable(false)
			boots_found:SetSellable(false)
			if table.contains({"item_power_treads_lua", "item_might_treads_lua"}, boots_found:GetName()) then
				local modifier = self:GetParent():FindModifierByNameAndAbility(boots_found:GetIntrinsicModifierName(), boots_found)
				if modifier then
					boots_found:OrderAbilityNoTarget()
					Timers:CreateTimer({endTime=FrameTime(), callback=function()
						modifier:SwitchAttribute()
					end}, nil, self)
				end
			end
		end
		if boots_found ~= nil and item ~= nil and boots_found:GetItemSlot() ~= item:GetItemSlot() then
			self:GetParent():SwapItems(boots_found:GetItemSlot(), item:GetItemSlot())
		end
		if boots_found ~= nil and table.contains({"item_power_treads_lua", "item_might_treads_lua"}, boots_found:GetName()) then
			if item.attribute ~= boots_found.attribute then
				local modifier = self:GetParent():FindModifierByNameAndAbility(boots_found:GetIntrinsicModifierName(), boots_found)
				if modifier then
					modifier:SwitchAttribute(item.attribute)
				end
			end
		end
		for i=1, owner:GetLevel()-self:GetParent():GetLevel() do
			self:GetParent():HeroLevelUp(false)
		end
		if owner:HasShard() and not self:GetParent():HasShard() then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_item_aghanims_shard", {})
		elseif not owner:HasShard() and self:GetParent():HasShard() then
			self:GetParent():RemoveModifierByName("modifier_item_aghanims_shard")
		end
		if owner:HasScepter() and not self:GetParent():HasScepter() then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_item_ultimate_scepter_consumed", {})
		elseif not owner:HasScepter() and self:GetParent():HasScepter() then
			self:GetParent():RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
		end
		self:GetParent():SetBaseStrength(owner:GetStrength()-self:GetParent():GetAdditionalStrength())
		self:GetParent():SetBaseAgility(owner:GetAgility()-self:GetParent():GetAdditionalAgility())
		self:GetParent():SetBaseIntellect(owner:GetIntellect(false)-self:GetParent():GetAdditionalIntellect())
		self:GetParent():CopyAbilities()
		self:GetParent():SetAbilityPoints(0)
		self:GetParent():CalculateStatBonus(true)
	else
		self:OnCloneCountUpdate()
	end
end
function modifier_meepo_divided_we_stand_lua:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():IsTrueHero() then
		self:OnCloneCountUpdate(true)
	end
end
function modifier_meepo_divided_we_stand_lua:OnDeath(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or not kv.unit:IsRealHero() or kv.unit:IsTempestDouble() or kv.unit:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") or kv.unit:HasModifier("modifier_monkey_king_fur_army_soldier") or kv.unit:HasModifier("modifier_monkey_king_fur_army_soldier_in_position") or kv.unit:HasModifier("modifier_monkey_king_fur_army_soldier_inactive") or kv.unit:HasModifier("modifier_vengefulspirit_command_aura_illusion") then return end
	local owner = self:GetAbility():GetCloneSource()
	for _, clone in pairs(self:GetClones()) do
		if clone ~= self:GetParent() and clone:IsAlive() then
			clone:TrueKill(self:GetAbility(), nil)
		end
	end
	if self:GetParent() ~= owner and owner:IsAlive() then
		owner:TrueKill(self:GetAbility(), nil)
	end
end
function modifier_meepo_divided_we_stand_lua:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("magic_resist") end
function modifier_meepo_divided_we_stand_lua:GetModifierPercentageExpRateBoost() return 30-100 end