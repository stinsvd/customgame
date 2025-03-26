LinkLuaModifier("modifier_item_power_treads_lua", "items/power_treads", LUA_MODIFIER_MOTION_NONE)

item_power_treads_lua = item_power_treads_lua or class(ability_lua_base)
function item_power_treads_lua:GetAbilityTextureName()
	if IsServer() or self.attribute == nil then return "item_power_treads" end
	local attrs = {[DOTA_ATTRIBUTE_STRENGTH]="str", [DOTA_ATTRIBUTE_AGILITY]="agi", [DOTA_ATTRIBUTE_INTELLECT]="int"}
	return "item_power_treads_"..attrs[self.attribute]
end
function item_power_treads_lua:GetIntrinsicModifierName() return "modifier_item_power_treads_lua" end
function item_power_treads_lua:OnSpellStart()
	if not self:GetCaster():IsHero() or self:GetCaster():IsClone() then return end
	local modifier = self:FindAllModifiers(self:GetIntrinsicModifierName())[1]
	if modifier then
		modifier:SwitchAttribute()
	end
end

modifier_item_power_treads_lua = modifier_item_power_treads_lua or class({})
function modifier_item_power_treads_lua:IsHidden() return true end
function modifier_item_power_treads_lua:IsPurgable() return false end
function modifier_item_power_treads_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_power_treads_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_power_treads_lua:SwitchAttribute(attribute)
	local attributes = {DOTA_ATTRIBUTE_STRENGTH, DOTA_ATTRIBUTE_INTELLECT, DOTA_ATTRIBUTE_AGILITY}
	if self:GetAbility().attribute == nil then self:GetAbility().attribute = self:GetParent():GetPrimaryAttribute() end
	self:SetStackCount(attribute or attributes[table.find(attributes, self:GetAbility().attribute)+1] or attributes[1])
	self:GetParent():CalculateStatBonus(false)
end
function modifier_item_power_treads_lua:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	if not IsServer() then return end
	if self:GetParent():IsClone() or not self:GetParent():IsHero() then return end
	if self:GetParent():IsRealHero() then
		Timers:CreateTimer({endTime=0.1, callback=function()
			local attr = self:GetAbility().attribute or self:GetParent():GetPrimaryAttribute()
			self:GetAbility():OrderAbilityNoTarget()
			Timers:CreateTimer({endTime=FrameTime(), callback=function()
				self:SwitchAttribute(attr)
				self:GetAbility().attribute = attr
			end}, nil, self)
		end}, nil, self)
	else
		Timers:CreateTimer({endTime=FrameTime(), callback=function()
			if self:IsNull() or not IsValidEntity(self:GetParent()) then return end
			local owner = self:GetParent():GetSource()
			if owner then
				local item = owner:GetItemInSlot(self:GetAbility():GetItemSlot())
				if item and item:GetName() == self:GetAbility():GetName() then
					self:SwitchAttribute(item.attribute)
					self.attribute = item.attribute
				end
			end
		end}, nil, self)
	end
end
function modifier_item_power_treads_lua:OnStackCountChanged(stackCount)
	self:GetAbility().attribute = self:GetStackCount()
end
function modifier_item_power_treads_lua:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_item_power_treads_lua:GetModifierBonusStats_Strength() if not self:GetParent():IsClone() and self:GetAbility().attribute == DOTA_ATTRIBUTE_STRENGTH then return self:GetAbility():GetSpecialValueFor("bonus_stat") end end
function modifier_item_power_treads_lua:GetModifierBonusStats_Agility() if not self:GetParent():IsClone() and self:GetAbility().attribute == DOTA_ATTRIBUTE_AGILITY then return self:GetAbility():GetSpecialValueFor("bonus_stat") end end
function modifier_item_power_treads_lua:GetModifierBonusStats_Intellect() if not self:GetParent():IsClone() and self:GetAbility().attribute == DOTA_ATTRIBUTE_INTELLECT then return self:GetAbility():GetSpecialValueFor("bonus_stat") end end
function modifier_item_power_treads_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end