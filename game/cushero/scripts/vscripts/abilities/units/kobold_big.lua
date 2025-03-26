LinkLuaModifier("modifier_kobold_taskmaster_speed_aura_lua", "abilities/units/kobold_big", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kobold_taskmaster_speed_aura_lua_aura", "abilities/units/kobold_big", LUA_MODIFIER_MOTION_NONE)

kobold_taskmaster_speed_aura_lua = kobold_taskmaster_speed_aura_lua or class(ability_lua_base)
function kobold_taskmaster_speed_aura_lua:GetIntrinsicModifierName() return "modifier_kobold_taskmaster_speed_aura_lua" end

modifier_kobold_taskmaster_speed_aura_lua = modifier_kobold_taskmaster_speed_aura_lua or class({})
function modifier_kobold_taskmaster_speed_aura_lua:IsHidden() return true end
function modifier_kobold_taskmaster_speed_aura_lua:IsPurgable() return false end
function modifier_kobold_taskmaster_speed_aura_lua:IsAura() return not self:GetParent():PassivesDisabled() end
function modifier_kobold_taskmaster_speed_aura_lua:GetModifierAura() return "modifier_kobold_taskmaster_speed_aura_lua_aura" end
function modifier_kobold_taskmaster_speed_aura_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_kobold_taskmaster_speed_aura_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kobold_taskmaster_speed_aura_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_kobold_taskmaster_speed_aura_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end

modifier_kobold_taskmaster_speed_aura_lua_aura = modifier_kobold_taskmaster_speed_aura_lua_aura or class({})
function modifier_kobold_taskmaster_speed_aura_lua_aura:IsPurgable() return false end
function modifier_kobold_taskmaster_speed_aura_lua_aura:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_kobold_taskmaster_speed_aura_lua_aura:OnCreated()
	if not self:GetAbility() then if IsServer() then self:Destroy() end return end
	self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end
function modifier_kobold_taskmaster_speed_aura_lua_aura:GetModifierMoveSpeedBonus_Percentage() return self.movespeed end