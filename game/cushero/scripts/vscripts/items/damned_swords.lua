LinkLuaModifier("modifier_item_damned_swords_lua", "items/damned_swords", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_damned_swords_bonus_lua", "items/damned_swords", LUA_MODIFIER_MOTION_NONE)

item_damned_swords_lua = item_damned_swords_lua or class(ability_lua_base)
function item_damned_swords_lua:GetIntrinsicModifiers() return {"modifier_item_damned_swords_lua", "modifier_item_damned_swords_bonus_lua"} end

modifier_item_damned_swords_lua = modifier_item_damned_swords_lua or class({})
function modifier_item_damned_swords_lua:IsHidden() return true end
function modifier_item_damned_swords_lua:IsPurgable() return false end
function modifier_item_damned_swords_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_damned_swords_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE} end
function modifier_item_damned_swords_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_damned_swords_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_damned_swords_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_damned_swords_lua:GetModifierMoveSpeedBonus_Percentage_Unique() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end

modifier_item_damned_swords_bonus_lua = modifier_item_damned_swords_bonus_lua or class({})
function modifier_item_damned_swords_bonus_lua:IsHidden() return true end
function modifier_item_damned_swords_bonus_lua:IsPurgable() return false end
function modifier_item_damned_swords_bonus_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE} end
function modifier_item_damned_swords_bonus_lua:GetModifierStatusResistanceStacking() return self:GetAbility():GetSpecialValueFor("status_resistance") end
function modifier_item_damned_swords_bonus_lua:GetModifierHPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end
function modifier_item_damned_swords_bonus_lua:GetModifierLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end