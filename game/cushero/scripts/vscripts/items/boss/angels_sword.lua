LinkLuaModifier("modifier_item_angels_sword_lua", "items/boss/angels_sword", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_angels_sword_active_lua", "items/boss/angels_sword", LUA_MODIFIER_MOTION_NONE)

item_angels_sword_lua = item_angels_sword_lua or class(ability_lua_base)
function item_angels_sword_lua:GetIntrinsicModifierName() return "modifier_item_angels_sword_lua" end
function item_angels_sword_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_angels_sword_active_lua", {duration=self:GetSpecialValueFor("shield_duration")})
	self:GetCaster():EmitSound("DOTA_Item.Pipe.Activate")
end

modifier_item_angels_sword_lua = modifier_item_angels_sword_lua or class({})
function modifier_item_angels_sword_lua:IsHidden() return true end
function modifier_item_angels_sword_lua:IsPurgable() return false end
function modifier_item_angels_sword_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_angels_sword_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_item_angels_sword_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end

modifier_item_angels_sword_active_lua = modifier_item_angels_sword_active_lua or class({})
function modifier_item_angels_sword_active_lua:IsPurgable() return true end
function modifier_item_angels_sword_active_lua:GetEffectName() return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf" end
function modifier_item_angels_sword_active_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_angels_sword_active_lua:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL} end
function modifier_item_angels_sword_active_lua:GetAbsoluteNoDamageMagical() return 1 end