LinkLuaModifier("modifier_item_war_axe_lua", "items/war_axe", LUA_MODIFIER_MOTION_NONE)

item_war_axe_lua = item_war_axe_lua or class(ability_lua_base)
function item_war_axe_lua:GetIntrinsicModifierName() return "modifier_item_war_axe_lua" end

modifier_item_war_axe_lua = modifier_item_war_axe_lua or class({})
function modifier_item_war_axe_lua:IsHidden() return true end
function modifier_item_war_axe_lua:IsPurgable() return false end
function modifier_item_war_axe_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_war_axe_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_war_axe_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_war_axe_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_war_axe_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_war_axe_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end