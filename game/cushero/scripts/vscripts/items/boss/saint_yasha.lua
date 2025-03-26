LinkLuaModifier("modifier_item_saint_yasha_lua", "items/boss/saint_yasha", LUA_MODIFIER_MOTION_NONE)

item_saint_yasha_lua = item_saint_yasha_lua or class(ability_lua_base)
function item_saint_yasha_lua:GetIntrinsicModifierName() return "modifier_item_saint_yasha_lua" end

modifier_item_saint_yasha_lua = modifier_item_saint_yasha_lua or class({})
function modifier_item_saint_yasha_lua:IsHidden() return true end
function modifier_item_saint_yasha_lua:IsPurgable() return false end
function modifier_item_saint_yasha_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_saint_yasha_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE} end
function modifier_item_saint_yasha_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_saint_yasha_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_saint_yasha_lua:GetModifierMoveSpeedBonus_Percentage_Unique() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end