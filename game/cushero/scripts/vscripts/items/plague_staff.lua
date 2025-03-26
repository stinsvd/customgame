LinkLuaModifier("modifier_item_plague_staff_lua", "items/plague_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plague_staff_aura_lua", "items/plague_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_plague_staff_debuff_lua", "items/plague_staff", LUA_MODIFIER_MOTION_NONE)

item_plague_staff_lua = item_plague_staff_lua or class(ability_lua_base)
function item_plague_staff_lua:GetIntrinsicModifierName() return "modifier_item_plague_staff_lua" end

modifier_item_plague_staff_lua = modifier_item_plague_staff_lua or class({})
function modifier_item_plague_staff_lua:IsHidden() return true end
function modifier_item_plague_staff_lua:IsPurgable() return false end
function modifier_item_plague_staff_lua:IsAura() return true end
function modifier_item_plague_staff_lua:GetModifierAura() return "modifier_item_plague_staff_aura_lua" end
function modifier_item_plague_staff_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_plague_staff_lua:GetAuraDuration() return 0.5 end
function modifier_item_plague_staff_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_plague_staff_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_item_plague_staff_lua:GetAuraSearchFlags() return DOTA_DAMAGE_FLAG_NONE end
function modifier_item_plague_staff_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_plague_staff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE, MODIFIER_PROPERTY_MANA_BONUS} end
function modifier_item_plague_staff_lua:GetModifierSpell_CriticalDamage(kv)
	if not IsServer() then return end
	local victim = EntIndexToHScript(kv.entindex_victim_const)
	local attacker = EntIndexToHScript(kv.entindex_attacker_const)
	if UnitFilter(victim, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility():entindex(), attacker) then return end
	victim:AddNewModifier(attacker, self:GetAbility(), "modifier_item_plague_staff_debuff_lua", {duration=self:GetAbility():GetSpecialValueFor("resist_debuff_duration")})
	SendOverheadEventMessage(attacker:GetPlayerOwner(), OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, victim, kv.damage * (self:GetAbility():GetSpecialValueFor("crit_multiplier")/100), attacker:GetPlayerOwner())
	return self:GetAbility():GetSpecialValueFor("crit_multiplier")
end
function modifier_item_plague_staff_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_plague_staff_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_plague_staff_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_plague_staff_lua:GetModifierExtraManaPercentage() return self:GetAbility():GetSpecialValueFor("bonus_max_mana_percentage") end
function modifier_item_plague_staff_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end

modifier_item_plague_staff_aura_lua = modifier_item_plague_staff_aura_lua or class({})
function modifier_item_plague_staff_aura_lua:IsPurgable() return false end
function modifier_item_plague_staff_aura_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_plague_staff_aura_lua:OnCreated()
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor("aura_mana_regen")
end
function modifier_item_plague_staff_aura_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_plague_staff_aura_lua:GetModifierConstantManaRegen() return self.aura_mana_regen end

modifier_item_plague_staff_debuff_lua = modifier_item_plague_staff_debuff_lua or class({})
function modifier_item_plague_staff_debuff_lua:IsPurgable() return false end
function modifier_item_plague_staff_debuff_lua:GetEffectName() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end
function modifier_item_plague_staff_debuff_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_plague_staff_debuff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_item_plague_staff_debuff_lua:OnCreated()
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp") * (-1)
end
function modifier_item_plague_staff_debuff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_plague_staff_debuff_lua:GetModifierMagicalResistanceBonus() return self.spell_amp end