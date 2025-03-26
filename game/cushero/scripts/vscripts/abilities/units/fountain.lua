LinkLuaModifier("modifier_fountain_attack_lua", "abilities/units/fountain", LUA_MODIFIER_MOTION_NONE)

fountain_attack_lua = fountain_attack_lua or class(ability_lua_base)
function fountain_attack_lua:GetIntrinsicModifierName() return "modifier_fountain_attack_lua" end

modifier_fountain_attack_lua = modifier_fountain_attack_lua or class({})
function modifier_fountain_attack_lua:IsHidden() return true end
function modifier_fountain_attack_lua:IsPurgable() return false end
function modifier_fountain_attack_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_fountain_attack_lua:GetModifierProcAttack_BonusDamage_Pure(kv)
	if kv.attacker ~= self:GetParent() then return end
	return kv.target:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("damage_pct") / 100
end
function modifier_fountain_attack_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("bash_chance"), self:GetAbility():entindex(), self:GetParent()) then return end
	kv.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bashed", {duration = self:GetAbility():GetSpecialValueFor("bash_duration")})
end