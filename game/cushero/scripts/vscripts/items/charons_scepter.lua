LinkLuaModifier("modifier_charons_scepter_lua", "items/charons_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_charons_scepter_active_lua", "items/charons_scepter", LUA_MODIFIER_MOTION_NONE)

item_charons_scepter_lua = item_charons_scepter_lua or class(ability_lua_base)
function item_charons_scepter_lua:GetIntrinsicModifierName() return "modifier_charons_scepter_lua" end
function item_charons_scepter_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_charons_scepter_active_lua", {duration=self:GetSpecialValueFor("cyclone_duration")})
	self:GetCaster():Dispell(self:GetCaster(), false)
	self:GetCaster():EmitSound("Hero_PhantomLancer.Doppelganger.Cast")
end

modifier_charons_scepter_lua = modifier_charons_scepter_lua or class({})
function modifier_charons_scepter_lua:IsHidden() return true end
function modifier_charons_scepter_lua:IsPurgable() return false end
function modifier_charons_scepter_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_charons_scepter_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_charons_scepter_lua:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_charons_scepter_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_charons_scepter_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

modifier_charons_scepter_active_lua = modifier_charons_scepter_active_lua or class({})
function modifier_charons_scepter_active_lua:IsPurgable() return false end
function modifier_charons_scepter_active_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end
function modifier_charons_scepter_active_lua:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_ATTACK_IMMUNE] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true} end
function modifier_charons_scepter_active_lua:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.hp_regen_pct = self:GetAbility():GetSpecialValueFor("hp_regen_pct")
	if not IsServer() then return end
	self:GetParent():AddNoDraw()
end
function modifier_charons_scepter_active_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveNoDraw()
end
function modifier_charons_scepter_active_lua:GetModifierHealthRegenPercentage() return self.hp_regen_pct end