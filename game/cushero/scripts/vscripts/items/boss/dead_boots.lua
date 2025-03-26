LinkLuaModifier("modifier_item_dead_boots_lua", "items/boss/dead_boots", LUA_MODIFIER_MOTION_NONE)

item_dead_boots_lua = item_dead_boots_lua or class(ability_lua_base)
function item_dead_boots_lua:GetIntrinsicModifierName() return "modifier_item_dead_boots_lua" end

modifier_item_dead_boots_lua = modifier_item_dead_boots_lua or class({})
function modifier_item_dead_boots_lua:IsHidden() return true end
function modifier_item_dead_boots_lua:IsPurgable() return false end
function modifier_item_dead_boots_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_dead_boots_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE} end
function modifier_item_dead_boots_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_dead_boots_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_dead_boots_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_dead_boots_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_dead_boots_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_dead_boots_lua:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end