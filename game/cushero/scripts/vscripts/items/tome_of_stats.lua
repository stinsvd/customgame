LinkLuaModifier("modifier_item_tome_of_strength_lua", "items/tome_of_stats", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_agility_lua", "items/tome_of_stats", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_intellect_lua", "items/tome_of_stats", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_gods_lua", "items/tome_of_stats", LUA_MODIFIER_MOTION_NONE)

item_tome_of_strength_lua = item_tome_of_strength_lua or class(ability_lua_base)
function item_tome_of_strength_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_"..self:GetName(), {})
	self:SpendCharge(0)
end

modifier_item_tome_of_strength_lua = modifier_item_tome_of_strength_lua or class({})
function modifier_item_tome_of_strength_lua:IsHidden() return true end
function modifier_item_tome_of_strength_lua:IsPurgable() return false end
function modifier_item_tome_of_strength_lua:RemoveOnDeath() return false end
function modifier_item_tome_of_strength_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_item_tome_of_strength_lua:OnCreated()
	self.strength_bonus = self:GetAbility():GetSpecialValueFor("strength_bonus")
	self.agility_bonus = self:GetAbility():GetSpecialValueFor("agility_bonus")
	self.intellect_bonus = self:GetAbility():GetSpecialValueFor("intellect_bonus")
	if not IsServer() then return end
	self:IncrementStackCount()
end
function modifier_item_tome_of_strength_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_tome_of_strength_lua:OnStackCountChanged(iStackCount)
	if not IsServer() then return end
	self:GetParent():CalculateStatBonus(true)
end
function modifier_item_tome_of_strength_lua:GetModifierBonusStats_Strength() return self.strength_bonus*self:GetStackCount() end
function modifier_item_tome_of_strength_lua:GetModifierBonusStats_Agility() return self.agility_bonus*self:GetStackCount() end
function modifier_item_tome_of_strength_lua:GetModifierBonusStats_Intellect() return self.intellect_bonus*self:GetStackCount() end

item_tome_of_agility_lua = item_tome_of_agility_lua or class(item_tome_of_strength_lua)

modifier_item_tome_of_agility_lua = modifier_item_tome_of_agility_lua or class(modifier_item_tome_of_strength_lua)

item_tome_of_intellect_lua = item_tome_of_intellect_lua or class(item_tome_of_strength_lua)

modifier_item_tome_of_intellect_lua = modifier_item_tome_of_intellect_lua or class(modifier_item_tome_of_strength_lua)

item_tome_of_gods_lua = item_tome_of_gods_lua or class(item_tome_of_strength_lua)

modifier_item_tome_of_gods_lua = modifier_item_tome_of_gods_lua or class(modifier_item_tome_of_strength_lua)