LinkLuaModifier("modifier_slardar_bash_lua", "abilities/heroes/slardar", LUA_MODIFIER_MOTION_NONE)

slardar_bash_lua = slardar_bash_lua or class(ability_lua_base)
function slardar_bash_lua:GetIntrinsicModifierName() return "modifier_slardar_bash_lua" end

modifier_slardar_bash_lua = modifier_slardar_bash_lua or class({})
function modifier_slardar_bash_lua:IsHidden() return true end
function modifier_slardar_bash_lua:IsPurgable() return false end
function modifier_slardar_bash_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL} end
function modifier_slardar_bash_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:PassivesDisabled() or kv.attacker:IsIllusion() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("bash_chance"), self:GetAbility():entindex(), kv.attacker) then return end
	kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_bashed", {duration=self:GetAbility():GetSpecialValueFor("duration")})
	kv.target:EmitSound("Hero_Slardar.Bash")
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end