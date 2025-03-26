LinkLuaModifier("modifier_item_cursed_sange_lua", "items/boss/cursed_sange", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cursed_sange_bonus_lua", "items/boss/cursed_sange", LUA_MODIFIER_MOTION_NONE)

item_cursed_sange_lua = item_cursed_sange_lua or class(ability_lua_base)
function item_cursed_sange_lua:GetIntrinsicModifiers() return {"modifier_item_cursed_sange_lua", "modifier_item_cursed_sange_bonus_lua"} end

modifier_item_cursed_sange_lua = modifier_item_cursed_sange_lua or class({})
function modifier_item_cursed_sange_lua:IsHidden() return true end
function modifier_item_cursed_sange_lua:IsPurgable() return false end
function modifier_item_cursed_sange_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_cursed_sange_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_item_cursed_sange_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end

modifier_item_cursed_sange_bonus_lua = modifier_item_cursed_sange_bonus_lua or class({})
function modifier_item_cursed_sange_bonus_lua:IsHidden() return true end
function modifier_item_cursed_sange_bonus_lua:IsPurgable() return false end
function modifier_item_cursed_sange_bonus_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE} end
function modifier_item_cursed_sange_bonus_lua:GetModifierStatusResistanceStacking() return self:GetAbility():GetSpecialValueFor("status_resistance") end
function modifier_item_cursed_sange_bonus_lua:GetModifierHPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end
function modifier_item_cursed_sange_bonus_lua:GetModifierLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end