LinkLuaModifier("modifier_item_blessed_essence_lua", "items/boss/blessed_essence", LUA_MODIFIER_MOTION_NONE)

item_blessed_essence_lua = item_blessed_essence_lua or class(ability_lua_base)
function item_blessed_essence_lua:GetIntrinsicModifierName() return "modifier_item_blessed_essence_lua" end

modifier_item_blessed_essence_lua = modifier_item_blessed_essence_lua or class({})
function modifier_item_blessed_essence_lua:IsHidden() return true end
function modifier_item_blessed_essence_lua:IsPurgable() return false end
function modifier_item_blessed_essence_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_blessed_essence_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_item_blessed_essence_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_blessed_essence_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_blessed_essence_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_blessed_essence_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end