LinkLuaModifier("modifier_item_sacred_butterfly_lua", "items/sacred_butterfly", LUA_MODIFIER_MOTION_NONE)

item_sacred_butterfly_lua = item_sacred_butterfly_lua or class(ability_lua_base)
function item_sacred_butterfly_lua:GetIntrinsicModifierName() return "modifier_item_sacred_butterfly_lua" end

modifier_item_sacred_butterfly_lua = modifier_item_sacred_butterfly_lua or class({})
function modifier_item_sacred_butterfly_lua:IsHidden() return true end
function modifier_item_sacred_butterfly_lua:IsPurgable() return false end
function modifier_item_sacred_butterfly_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_sacred_butterfly_lua:DeclareFunctions() return {MODIFIER_PROPERTY_AVOID_DAMAGE, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_sacred_butterfly_lua:GetModifierAvoidDamage(kv)
	if not IsServer() then return end
	if kv.target ~= self:GetParent() then return end
	if self:GetAbility():GetSpecialValueFor("backtrack_chance") <= 0 then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("backtrack_chance"), self:GetAbility():entindex(), kv.target) then return end
	return 1
end
function modifier_item_sacred_butterfly_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_sacred_butterfly_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_sacred_butterfly_lua:GetModifierEvasion_Constant() return self:GetAbility():GetSpecialValueFor("bonus_evasion") end
function modifier_item_sacred_butterfly_lua:GetModifierAttackSpeedBonus_Constant() return self:GetParent():GetBaseAttackSpeed() * self:GetAbility():GetSpecialValueFor("bonus_attack_speed_pct") / 100 end

item_burning_butterfly_lua = item_burning_butterfly_lua or class(item_sacred_butterfly_lua)