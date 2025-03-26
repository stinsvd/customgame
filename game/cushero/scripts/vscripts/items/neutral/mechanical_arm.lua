LinkLuaModifier("modifier_item_mechanical_arm_lua", "items/neutral/mechanical_arm", LUA_MODIFIER_MOTION_NONE)

item_mechanical_arm_lua = item_mechanical_arm_lua or class(ability_lua_base)
function item_mechanical_arm_lua:GetIntrinsicModifierName() return "modifier_item_mechanical_arm_lua" end

modifier_item_mechanical_arm_lua = modifier_item_mechanical_arm_lua or class({})
function modifier_item_mechanical_arm_lua:IsHidden() return true end
function modifier_item_mechanical_arm_lua:IsPurgable() return false end
function modifier_item_mechanical_arm_lua:DeclareFunctions() return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK} end
function modifier_item_mechanical_arm_lua:GetModifierProcAttack_Feedback(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetParent():GetTeamNumber()) ~= UF_SUCCESS then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("stun_chance"), self:GetAbility():entindex(), self:GetParent()) then return end
	kv.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bashed", {duration=self:GetAbility():GetSpecialValueFor("stun_duration")})
	kv.target:EmitSound("DOTA_Item.SkullBasher")
end
function modifier_item_mechanical_arm_lua:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("bat") end