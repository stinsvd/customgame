LinkLuaModifier("modifier_item_heart_of_alaron_lua", "items/heart_of_alaron", LUA_MODIFIER_MOTION_NONE)

item_heart_of_alaron_lua = item_heart_of_alaron_lua or class(ability_lua_base)
function item_heart_of_alaron_lua:GetIntrinsicModifierName() return "modifier_item_heart_of_alaron_lua" end

modifier_item_heart_of_alaron_lua = modifier_item_heart_of_alaron_lua or class({})
function modifier_item_heart_of_alaron_lua:IsHidden() return true end
function modifier_item_heart_of_alaron_lua:IsPurgable() return false end
function modifier_item_heart_of_alaron_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_heart_of_alaron_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_item_heart_of_alaron_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_heart_of_alaron_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_heart_of_alaron_lua:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("mana_regen_amplify_pct") end