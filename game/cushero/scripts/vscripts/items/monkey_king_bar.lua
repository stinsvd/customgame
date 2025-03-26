LinkLuaModifier("modifier_item_monkey_king_bar_lua", "items/monkey_king_bar", LUA_MODIFIER_MOTION_NONE)

item_monkey_king_bar_lua = item_monkey_king_bar_lua or class(ability_lua_base)
function item_monkey_king_bar_lua:GetIntrinsicModifierName() return "modifier_item_monkey_king_bar_lua" end

modifier_item_monkey_king_bar_lua = modifier_item_monkey_king_bar_lua or class({})
function modifier_item_monkey_king_bar_lua:IsHidden() return true end
function modifier_item_monkey_king_bar_lua:IsPurgable() return false end
function modifier_item_monkey_king_bar_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_monkey_king_bar_lua:CheckState() return {[MODIFIER_STATE_CANNOT_MISS] = true} end
function modifier_item_monkey_king_bar_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_monkey_king_bar_lua:GetModifierProcAttack_BonusDamage_Magical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("bash_chance"), self:GetAbility():entindex(), kv.attacker) then return end
	kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_bashed", {duration=self:GetAbility():GetSpecialValueFor("bash_stun")})
	kv.target:EmitSound("DOTA_Item.MKB.Minibash")
	return self:GetAbility():GetSpecialValueFor("bash_damage")
end
function modifier_item_monkey_king_bar_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_monkey_king_bar_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end