LinkLuaModifier("modifier_medical_tractate_lua", "items/medical_tractate", LUA_MODIFIER_MOTION_NONE)

item_medical_tractate_lua = item_medical_tractate_lua or class(ability_lua_base)
function item_medical_tractate_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_medical_tractate_lua", {})
	self:SpendCharge(0)
end

modifier_medical_tractate_lua = modifier_medical_tractate_lua or class({})
function modifier_medical_tractate_lua:IsHidden() return true end
function modifier_medical_tractate_lua:IsPurgable() return false end
function modifier_medical_tractate_lua:RemoveOnDeath() return false end
function modifier_medical_tractate_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_medical_tractate_lua:OnCreated()
	self.health_bonus = self:GetAbility():GetSpecialValueFor("health_bonus")
end
function modifier_medical_tractate_lua:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end
function modifier_medical_tractate_lua:OnStackCountChanged(iStackCount)
	if not IsServer() then return end
	self:GetParent():CalculateStatBonus(true)
end
function modifier_medical_tractate_lua:GetModifierHealthBonus() return self.health_bonus*self:GetStackCount() end