LinkLuaModifier("modifier_item_polar_spear_lua", "items/polar_spear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_polar_spear_active_lua", "items/polar_spear", LUA_MODIFIER_MOTION_HORIZONTAL)

item_polar_spear_lua = item_polar_spear_lua or class(ability_lua_base)
function item_polar_spear_lua:GetIntrinsicModifierName() return "modifier_item_polar_spear_lua" end
function item_polar_spear_lua:OnSpellStart()
	if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_polar_spear_active_lua", {})
end

modifier_item_polar_spear_lua = modifier_item_polar_spear_lua or class({})
function modifier_item_polar_spear_lua:IsHidden() return true end
function modifier_item_polar_spear_lua:IsPurgable() return false end
function modifier_item_polar_spear_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_polar_spear_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_BONUS} end
function modifier_item_polar_spear_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_polar_spear_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_polar_spear_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end

modifier_item_polar_spear_active_lua = class({})
function modifier_item_polar_spear_active_lua:IsHidden() return true end
function modifier_item_polar_spear_active_lua:IsPurgable() return false end
function modifier_item_polar_spear_active_lua:GetEffectName() return "particles/void_stick/void_stick_pull.vpcf" end
function modifier_item_polar_spear_active_lua:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_item_polar_spear_active_lua:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_item_polar_spear_active_lua:OnCreated()
	if not IsServer() then return end
	self.vPoint = self:GetCaster():GetAbsOrigin()
	if not self:ApplyHorizontalMotionController() then self:Destroy() end
end
function modifier_item_polar_spear_active_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_polar_spear_active_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():InterruptMotionControllers(true)
end
function modifier_item_polar_spear_active_lua:UpdateHorizontalMotion(me, dt)
	if not IsServer() then return end
	if self:GetParent():IsAlive() then
		if (self.vPoint - self:GetParent():GetAbsOrigin()):Length2D() < 150 then
			GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 150, true)
			self:GetParent():InterruptMotionControllers(true)
		else
			self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin() + ((self.vPoint - self:GetParent():GetAbsOrigin()):Normalized()) * 30)
		end
	else
		self:GetParent():InterruptMotionControllers(true)
	end
end
function modifier_item_polar_spear_active_lua:OnHorizontalMotionInterrupted()
	if not IsServer() then return end
	self:Destroy()
end
function modifier_item_polar_spear_active_lua:GetOverrideAnimation() return ACT_DOTA_FLAIL end