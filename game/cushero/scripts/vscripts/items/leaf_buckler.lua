LinkLuaModifier("modifier_item_leaf_buckler_lua", "items/leaf_buckler", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_leaf_buckler_lua_active", "items/leaf_buckler", LUA_MODIFIER_MOTION_NONE)

item_leaf_buckler_lua = item_leaf_buckler_lua or class(ability_lua_base)
function item_leaf_buckler_lua:GetIntrinsicModifierName() return "modifier_item_leaf_buckler_lua" end

modifier_item_leaf_buckler_lua = modifier_item_leaf_buckler_lua or class({})
function modifier_item_leaf_buckler_lua:IsHidden() return true end
function modifier_item_leaf_buckler_lua:IsPurgable() return false end
function modifier_item_leaf_buckler_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_leaf_buckler_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_leaf_buckler_lua:GetModifierPhysical_ConstantBlock(kv)
	if not IsServer() then return end
	if kv.target ~= self:GetParent() then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("block_chance"), self:GetAbility():entindex(), self:GetParent()) then return end
	if self:GetAbility():IsCooldownReady() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_leaf_buckler_lua_active", {duration=self:GetAbility():GetSpecialValueFor("active_duration")})
		self:GetAbility():UseResources(true, true, false, true)
	end
	return self:GetAbility():GetSpecialValueFor("damage_block")
end
function modifier_item_leaf_buckler_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_leaf_buckler_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") + self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_leaf_buckler_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_leaf_buckler_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

modifier_item_leaf_buckler_lua_active = modifier_item_leaf_buckler_lua_active or class({})
function modifier_item_leaf_buckler_lua_active:IsPurgable() return true end
function modifier_item_leaf_buckler_lua_active:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_item_leaf_buckler_lua_active:OnCreated()
	self.agility = self:GetAbility():GetSpecialValueFor("active_agility")
end
function modifier_item_leaf_buckler_lua_active:GetModifierBonusStats_Agility() return self.agility end