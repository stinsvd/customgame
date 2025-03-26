LinkLuaModifier("modifier_item_awful_mask_lua", "items/boss/awful_mask", LUA_MODIFIER_MOTION_NONE)

item_awful_mask_lua = item_awful_mask_lua or class(ability_lua_base)
function item_awful_mask_lua:GetIntrinsicModifierName() return "modifier_item_awful_mask_lua" end

modifier_item_awful_mask_lua = modifier_item_awful_mask_lua or class({})
function modifier_item_awful_mask_lua:IsHidden() return true end
function modifier_item_awful_mask_lua:IsPurgable() return false end
function modifier_item_awful_mask_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_awful_mask_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_item_awful_mask_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	kv.attacker:Lifesteal(self:GetAbility():GetSpecialValueFor("lifesteal"), kv.damage, self.ability, false, false)
end
function modifier_item_awful_mask_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_awful_mask_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_awful_mask_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_awful_mask_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end