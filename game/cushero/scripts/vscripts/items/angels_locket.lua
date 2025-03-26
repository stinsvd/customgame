LinkLuaModifier("modifier_item_angels_locket_lua", "items/angels_locket", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_angels_locket_aura_lua", "items/angels_locket", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_angels_locket_buff_lua", "items/angels_locket", LUA_MODIFIER_MOTION_NONE)

item_angels_locket_lua = item_angels_locket_lua or class(ability_lua_base)
function item_angels_locket_lua:GetIntrinsicModifierName() return "modifier_item_angels_locket_lua" end
function item_angels_locket_lua:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_angels_locket_buff_lua", {duration=self:GetSpecialValueFor("buff_duration")})
	self:GetCursorTarget():EmitSound("DOTA_Item.HealingSalve.Activate")
end

modifier_item_angels_locket_lua = modifier_item_angels_locket_lua or class({})
function modifier_item_angels_locket_lua:IsHidden() return true end
function modifier_item_angels_locket_lua:IsPurgable() return false end
function modifier_item_angels_locket_lua:IsAura() return true end
function modifier_item_angels_locket_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_angels_locket_lua:GetModifierAura() return "modifier_item_angels_locket_aura_lua" end
function modifier_item_angels_locket_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_angels_locket_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_angels_locket_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_item_angels_locket_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_angels_locket_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_item_angels_locket_lua:GetModifierHealAmplify_PercentageSource() return self:GetAbility():GetSpecialValueFor("heal_increase") end
function modifier_item_angels_locket_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_angels_locket_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_angels_locket_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end

modifier_item_angels_locket_aura_lua = modifier_item_angels_locket_aura_lua or class({})
function modifier_item_angels_locket_aura_lua:IsPurgable() return false end
function modifier_item_angels_locket_aura_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_angels_locket_aura_lua:OnCreated()
	self.health_regen = self:GetAbility():GetSpecialValueFor("aura_health_regen")
end
function modifier_item_angels_locket_aura_lua:GetModifierConstantHealthRegen() return self.health_regen end

modifier_item_angels_locket_buff_lua = modifier_item_angels_locket_buff_lua or class({})
function modifier_item_angels_locket_buff_lua:IsPurgable() return true end
function modifier_item_angels_locket_buff_lua:GetEffectName() return "particles/items_fx/healing_flask.vpcf" end
function modifier_item_angels_locket_buff_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_angels_locket_buff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET} end
function modifier_item_angels_locket_buff_lua:OnCreated()
	self.heal_per_heal = self:GetAbility():GetSpecialValueFor("buff_heal_per_heal")
	if not IsServer() then return end
	self.healing = false
end
function modifier_item_angels_locket_buff_lua:GetModifierHealAmplify_PercentageTarget()
	if not IsServer() then return end
	if self.healing then return end
	self.healing = true
	self:GetParent():HealWithParams(self.heal_per_heal, self:GetAbility(), false, true, self:GetCaster(), false)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), self.heal_per_heal, self:GetCaster():GetPlayerOwner())
	self.healing = false
end