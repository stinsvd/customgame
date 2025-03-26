LinkLuaModifier("modifier_item_demons_reaper_lua", "items/demons_reaper", LUA_MODIFIER_MOTION_NONE)

item_demons_reaper_lua = item_demons_reaper_lua or class(ability_lua_base)
function item_demons_reaper_lua:GetIntrinsicModifierName() return "modifier_item_demons_reaper_lua" end

modifier_item_demons_reaper_lua = modifier_item_demons_reaper_lua or class({})
function modifier_item_demons_reaper_lua:IsHidden() return true end
function modifier_item_demons_reaper_lua:IsPurgable() return false end
function modifier_item_demons_reaper_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_demons_reaper_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_demons_reaper_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	kv.attacker:Lifesteal(self:GetAbility():GetSpecialValueFor("lifesteal_percent"), kv.damage, self:GetAbility(), false, false)
end
function modifier_item_demons_reaper_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	return kv.target:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("hp_leech_percent") / 100
end
function modifier_item_demons_reaper_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_demons_reaper_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end