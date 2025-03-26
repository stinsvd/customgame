LinkLuaModifier("modifier_item_angels_blood_lua", "items/boss/angels_blood", LUA_MODIFIER_MOTION_NONE)

item_angels_blood_lua = item_angels_blood_lua or class(ability_lua_base)
function item_angels_blood_lua:GetIntrinsicModifierName() return "modifier_item_angels_blood_lua" end

modifier_item_angels_blood_lua = modifier_item_angels_blood_lua or class({})
function modifier_item_angels_blood_lua:IsHidden() return true end
function modifier_item_angels_blood_lua:IsPurgable() return false end
function modifier_item_angels_blood_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_angels_blood_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_angels_blood_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end