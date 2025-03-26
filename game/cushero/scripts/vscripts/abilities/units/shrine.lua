LinkLuaModifier("modifier_shrine_lua_active", "abilities/units/shrine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shrine_lua_active_aura", "abilities/units/shrine", LUA_MODIFIER_MOTION_NONE)

shrine_lua = shrine_lua or class(ability_lua_base)
function shrine_lua:GetBehavior()
	if IsClient() then return DOTA_ABILITY_BEHAVIOR_PASSIVE else return DOTA_ABILITY_BEHAVIOR_NO_TARGET end
end
function shrine_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shrine_lua_active", {duration = self:GetSpecialValueFor("active_duration")})
	self:GetCaster():EmitSound("Shrine.Cast")
end

modifier_shrine_lua_active = modifier_shrine_lua_active or class({})
function modifier_shrine_lua_active:IsHidden() return true end
function modifier_shrine_lua_active:IsPurgable() return false end
function modifier_shrine_lua_active:IsAura() return true end
function modifier_shrine_lua_active:GetModifierAura() return "modifier_shrine_lua_active_aura" end
function modifier_shrine_lua_active:GetAuraRadius() return self:GetAbility():GetEffectiveCastRange(self:GetParent():GetAbsOrigin(), self:GetParent()) end
function modifier_shrine_lua_active:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_shrine_lua_active:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_shrine_lua_active:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_shrine_lua_active:OnCreated()
	if not IsServer() then return end
	local fx_name = self:GetCaster():GetTeamNumber() == DOTA_TEAM_GOODGUYS and "particles/world_shrine/radiant_shrine_active.vpcf" or "particles/world_shrine/dire_shrine_active.vpcf"
	local fx = ParticleManager:CreateParticle(fx_name, PATTACH_ABSORIGIN, self:GetCaster())
	self:AddParticle(fx, false, false, -1, false, false)
	ParticleManager:ReleaseParticleIndex(fx)
end

modifier_shrine_lua_active_aura = modifier_shrine_lua_active_aura or class({})
function modifier_shrine_lua_active_aura:IsPurgable() return false end
function modifier_shrine_lua_active_aura:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE} end
function modifier_shrine_lua_active_aura:GetModifierHealthRegenPercentage() return self:GetAbility():GetSpecialValueFor("active_heal_hp_pct") end
function modifier_shrine_lua_active_aura:GetModifierTotalPercentageManaRegen() return self:GetAbility():GetSpecialValueFor("active_heal_mp_pct") end