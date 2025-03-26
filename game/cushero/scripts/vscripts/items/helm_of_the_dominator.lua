LinkLuaModifier("modifier_item_helm_of_the_dominator_lua", "items/helm_of_the_dominator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_helm_of_the_dominator_buff_lua", "items/helm_of_the_dominator", LUA_MODIFIER_MOTION_NONE)

item_helm_of_the_dominator_lua = item_helm_of_the_dominator_lua or class(ability_lua_base)
function item_helm_of_the_dominator_lua:GetIntrinsicModifierName() return "modifier_item_helm_of_the_dominator_lua" end

modifier_item_helm_of_the_dominator_lua = modifier_item_helm_of_the_dominator_lua or class({})
function modifier_item_helm_of_the_dominator_lua:IsHidden() return true end
function modifier_item_helm_of_the_dominator_lua:IsPurgable() return false end
function modifier_item_helm_of_the_dominator_lua:RemoveOnDeath() return false end
function modifier_item_helm_of_the_dominator_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_helm_of_the_dominator_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_item_helm_of_the_dominator_lua:IsAura() return true end
function modifier_item_helm_of_the_dominator_lua:GetModifierAura() return "modifier_item_helm_of_the_dominator_buff_lua" end
function modifier_item_helm_of_the_dominator_lua:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_item_helm_of_the_dominator_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_helm_of_the_dominator_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_OTHER end
function modifier_item_helm_of_the_dominator_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end
function modifier_item_helm_of_the_dominator_lua:GetAuraEntityReject(hEntity)
	if not IsServer() then return end
	return hEntity:GetMainControllingPlayer() ~= self:GetParent():GetPlayerOwnerID() or (hEntity:IsHero() and not hEntity:IsConsideredHero() and not hEntity:IsSpiritBear()) or (hEntity:IsRealHero() and not hEntity:IsSpiritBear()) or hEntity:GetAttackCapability() == DOTA_UNIT_CAP_NO_ATTACK
end
function modifier_item_helm_of_the_dominator_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_item_helm_of_the_dominator_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_item_helm_of_the_dominator_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_item_helm_of_the_dominator_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_helm_of_the_dominator_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_regen") end
function modifier_item_helm_of_the_dominator_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end

modifier_item_helm_of_the_dominator_buff_lua = modifier_item_helm_of_the_dominator_buff_lua or class({})
function modifier_item_helm_of_the_dominator_buff_lua:IsHidden() return true end
function modifier_item_helm_of_the_dominator_buff_lua:IsPurgable() return false end
function modifier_item_helm_of_the_dominator_buff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_item_helm_of_the_dominator_buff_lua:OnCreated()
	self:OnIntervalThink()
	self:StartIntervalThink(1)
end
function modifier_item_helm_of_the_dominator_buff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_helm_of_the_dominator_buff_lua:OnIntervalThink()
	self.bonus_damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct_per_primary")
	self.bonus_health_pct = self:GetAbility():GetSpecialValueFor("health_pct_per_strength")
	self.bonus_health_regen = self:GetAbility():GetSpecialValueFor("hp_regen_per_strength")
	self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed_per_agility")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("armor_per_agility")
	self.bonus_spell_amplify = self:GetAbility():GetSpecialValueFor("spell_amplify_per_intellect")
	self.strength = self:GetCaster():GetStrength()
	self.agility = self:GetCaster():GetAgility()
	self.intellect = self:GetCaster():GetIntellect(false)
	if not IsServer() then return end
	self.primary = self:GetCaster():GetPrimaryStatValue()
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	self:GetParent():CalculateGenericBonuses()
	if self:GetParent().CalculateStatBonus then
		self:GetParent():CalculateStatBonus(false)
	end
end
function modifier_item_helm_of_the_dominator_buff_lua:AddCustomTransmitterData() return {primary = self.primary} end
function modifier_item_helm_of_the_dominator_buff_lua:HandleCustomTransmitterData(kv)
	self.primary = kv.primary
end
function modifier_item_helm_of_the_dominator_buff_lua:GetModifierBaseDamageOutgoing_Percentage() return self.bonus_damage_pct * self.primary end
function modifier_item_helm_of_the_dominator_buff_lua:GetModifierExtraHealthPercentage() return self.bonus_health_pct * self.strength end
function modifier_item_helm_of_the_dominator_buff_lua:GetModifierConstantHealthRegen() if not self:GetParent():IsOther() then return self.bonus_health_regen * self.strength end end
function modifier_item_helm_of_the_dominator_buff_lua:GetModifierAttackSpeedBonus_Constant() return self.bonus_attack_speed * self.agility end
function modifier_item_helm_of_the_dominator_buff_lua:GetModifierPhysicalArmorBonus() return self.bonus_armor * self.agility end
function modifier_item_helm_of_the_dominator_buff_lua:GetModifierSpellAmplify_Percentage() return self.bonus_spell_amplify * self.intellect end

item_helm_of_the_overlord_lua = item_helm_of_the_overlord_lua or class(item_helm_of_the_dominator_lua)

item_helm_of_tyrant_lua = item_helm_of_tyrant_lua or class(item_helm_of_the_dominator_lua)