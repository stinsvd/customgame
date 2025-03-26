LinkLuaModifier("modifier_item_angels_armor_lua", "items/boss/angels_armor", LUA_MODIFIER_MOTION_NONE)

item_angels_armor_lua = item_angels_armor_lua or class(ability_lua_base)
function item_angels_armor_lua:GetIntrinsicModifierName() return "modifier_item_angels_armor_lua" end

modifier_item_angels_armor_lua = modifier_item_angels_armor_lua or class({})
function modifier_item_angels_armor_lua:IsHidden() return true end
function modifier_item_angels_armor_lua:IsPurgable() return false end
function modifier_item_angels_armor_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_angels_armor_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_angels_armor_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_angels_armor_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_angels_armor_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_angels_armor_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_angels_armor_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_angels_armor_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end