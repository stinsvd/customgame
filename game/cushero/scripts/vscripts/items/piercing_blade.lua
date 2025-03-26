LinkLuaModifier("modifier_item_piercing_blade_lua", "items/piercing_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_piercing_blade_lua_active", "items/piercing_blade", LUA_MODIFIER_MOTION_NONE)

item_piercing_blade_lua = item_piercing_blade_lua or class(ability_lua_base)
function item_piercing_blade_lua:GetIntrinsicModifierName() return "modifier_item_piercing_blade_lua" end

modifier_item_piercing_blade_lua = modifier_item_piercing_blade_lua or class({})
function modifier_item_piercing_blade_lua:IsHidden() return true end
function modifier_item_piercing_blade_lua:IsPurgable() return false end
function modifier_item_piercing_blade_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_piercing_blade_lua:CheckState() if self.next_proc then return {[MODIFIER_STATE_CANNOT_MISS] = true} end end
function modifier_item_piercing_blade_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_piercing_blade_lua:OnAttackRecord(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("pierce_chance"), self:GetAbility():entindex(), kv.attacker) then
		self.next_proc = true
	end
end
function modifier_item_piercing_blade_lua:GetModifierProcAttack_BonusDamage_Pure(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	if self.next_proc then
		kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_item_piercing_blade_lua_active", {duration=0.5})
		return self:GetAbility():GetSpecialValueFor("pierce_damage")
	end
end
function modifier_item_piercing_blade_lua:GetModifierAttackDamageConversion() if self.next_proc then self.next_proc = false return DAMAGE_TYPE_PURE end end
function modifier_item_piercing_blade_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_piercing_blade_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_piercing_blade_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_piercing_blade_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

modifier_item_piercing_blade_lua_active = modifier_item_piercing_blade_lua_active or class({})
function modifier_item_piercing_blade_lua_active:IsHidden() return true end
function modifier_item_piercing_blade_lua_active:IsPurgable() return false end
function modifier_item_piercing_blade_lua_active:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR} end
function modifier_item_piercing_blade_lua_active:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.attacker ~= self:GetCaster() then return end
	self:Destroy()
end
function modifier_item_piercing_blade_lua_active:GetModifierIgnorePhysicalArmor() return 1 end