LinkLuaModifier("modifier_item_reapers_mask_lua", "items/reapers_mask", LUA_MODIFIER_MOTION_NONE)

item_reapers_mask_lua = item_reapers_mask_lua or class(ability_lua_base)
function item_reapers_mask_lua:GetIntrinsicModifierName() return "modifier_item_reapers_mask_lua" end

modifier_item_reapers_mask_lua = modifier_item_reapers_mask_lua or class({})
function modifier_item_reapers_mask_lua:IsHidden() return true end
function modifier_item_reapers_mask_lua:IsPurgable() return false end
function modifier_item_reapers_mask_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_reapers_mask_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_item_reapers_mask_lua:IsAura() return true end
function modifier_item_reapers_mask_lua:GetModifierAura() return "modifier_item_vladmir_aura" end
function modifier_item_reapers_mask_lua:GetAuraDuration() return 0.5 end
function modifier_item_reapers_mask_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_reapers_mask_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_reapers_mask_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_item_reapers_mask_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_reapers_mask_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_reapers_mask_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_reapers_mask_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_stats") end