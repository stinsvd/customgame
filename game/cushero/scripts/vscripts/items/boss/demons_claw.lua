LinkLuaModifier("modifier_item_demons_claw_lua", "items/boss/demons_claw", LUA_MODIFIER_MOTION_NONE)

item_demons_claw_lua = item_demons_claw_lua or class(ability_lua_base)
function item_demons_claw_lua:GetIntrinsicModifierName() return "modifier_item_demons_claw_lua" end

modifier_item_demons_claw_lua = modifier_item_demons_claw_lua or class({})
function modifier_item_demons_claw_lua:IsHidden() return true end
function modifier_item_demons_claw_lua:IsPurgable() return false end
function modifier_item_demons_claw_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_demons_claw_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_item_demons_claw_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end