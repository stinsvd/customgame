LinkLuaModifier("modifier_neutral_cloak_aura_lua", "abilities/units/neutrals", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutral_cloak_aura_lua_aura", "abilities/units/neutrals", LUA_MODIFIER_MOTION_NONE)

neutral_cloak_aura_lua = neutral_cloak_aura_lua or class(ability_lua_base)
function neutral_cloak_aura_lua:GetIntrinsicModifierName() return "modifier_neutral_cloak_aura_lua" end

modifier_neutral_cloak_aura_lua = modifier_neutral_cloak_aura_lua or class({})
function modifier_neutral_cloak_aura_lua:IsHidden() return true end
function modifier_neutral_cloak_aura_lua:IsPurgable() return false end
function modifier_neutral_cloak_aura_lua:IsAura() return not self:GetParent():PassivesDisabled() end
function modifier_neutral_cloak_aura_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_neutral_cloak_aura_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_neutral_cloak_aura_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_neutral_cloak_aura_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_neutral_cloak_aura_lua:GetModifierAura() return "modifier_neutral_cloak_aura_lua_aura" end

modifier_neutral_cloak_aura_lua_aura = modifier_neutral_cloak_aura_lua_aura or class({})
function modifier_neutral_cloak_aura_lua_aura:IsPurgable() return false end
function modifier_neutral_cloak_aura_lua_aura:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_neutral_cloak_aura_lua_aura:OnCreated()
	if not self:GetAbility() then if IsServer() then self:Destroy() end return end
	self.magical_resistance = self:GetParent():IsHero() and self:GetAbility():GetSpecialValueFor("bonus_magical_armor") or self:GetAbility():GetSpecialValueFor("bonus_magical_armor_creeps")
end
function modifier_neutral_cloak_aura_lua_aura:GetModifierMagicalResistanceBonus() return self.magical_resistance end