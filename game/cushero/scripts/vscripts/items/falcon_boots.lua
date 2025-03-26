LinkLuaModifier("modifier_item_falcon_boots_lua", "items/falcon_boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_falcon_boots_lua_active", "items/falcon_boots", LUA_MODIFIER_MOTION_NONE)

item_falcon_boots_lua = item_falcon_boots_lua or class(ability_lua_base)
function item_falcon_boots_lua:GetIntrinsicModifierName() return "modifier_item_falcon_boots_lua" end
function item_falcon_boots_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_falcon_boots_lua_active", {duration = self:GetSpecialValueFor("phase_duration")})
	self:GetCaster():EmitSound("DOTA_Item.PhaseBoots.Activate")
end

modifier_item_falcon_boots_lua = modifier_item_falcon_boots_lua or class({})
function modifier_item_falcon_boots_lua:IsPurgable() return false end
function modifier_item_falcon_boots_lua:IsHidden() return true end
function modifier_item_falcon_boots_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_falcon_boots_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_falcon_boots_lua:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_item_falcon_boots_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_falcon_boots_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_falcon_boots_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mp_regen") end
function modifier_item_falcon_boots_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

modifier_item_falcon_boots_lua_active = modifier_item_falcon_boots_lua_active or class({})
function modifier_item_falcon_boots_lua_active:IsPurgable() return false end
function modifier_item_falcon_boots_lua_active:GetEffectName() return "particles/items2_fx/phase_boots.vpcf" end
function modifier_item_falcon_boots_lua_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_falcon_boots_lua_active:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_item_falcon_boots_lua_active:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_item_falcon_boots_lua_active:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.movespeed = self:GetAbility():GetSpecialValueFor("phase_movement_speed")
end
function modifier_item_falcon_boots_lua_active:GetModifierMoveSpeedBonus_Percentage() return self.movespeed end