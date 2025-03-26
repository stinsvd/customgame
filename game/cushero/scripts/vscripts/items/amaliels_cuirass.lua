LinkLuaModifier("modifier_item_amaliels_cuirass_lua", "items/amaliels_cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_amaliels_cuirass_lua_aura", "items/amaliels_cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_amaliels_cuirass_lua_aura_buff", "items/amaliels_cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_amaliels_cuirass_lua_aura_debuff", "items/amaliels_cuirass", LUA_MODIFIER_MOTION_NONE)

item_amaliels_cuirass_lua = item_amaliels_cuirass_lua or class(ability_lua_base)
function item_amaliels_cuirass_lua:GetIntrinsicModifiers() return {"modifier_item_amaliels_cuirass_lua", "modifier_item_amaliels_cuirass_lua_aura"} end

modifier_item_amaliels_cuirass_lua = modifier_item_amaliels_cuirass_lua or class({})
function modifier_item_amaliels_cuirass_lua:IsHidden() return true end
function modifier_item_amaliels_cuirass_lua:IsPurgable() return false end
function modifier_item_amaliels_cuirass_lua:AllowIllusionDuplicate() return true end
function modifier_item_amaliels_cuirass_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_amaliels_cuirass_lua:IsAura() return true end
function modifier_item_amaliels_cuirass_lua:GetModifierAura() return "modifier_item_amaliels_cuirass_lua_aura_buff" end
function modifier_item_amaliels_cuirass_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_amaliels_cuirass_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_amaliels_cuirass_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end
function modifier_item_amaliels_cuirass_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_amaliels_cuirass_lua:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_amaliels_cuirass_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_amaliels_cuirass_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

modifier_item_amaliels_cuirass_lua_aura = modifier_item_amaliels_cuirass_lua_aura or class({})
function modifier_item_amaliels_cuirass_lua_aura:IsHidden() return true end
function modifier_item_amaliels_cuirass_lua_aura:IsPurgable() return false end
function modifier_item_amaliels_cuirass_lua_aura:AllowIllusionDuplicate() return true end
function modifier_item_amaliels_cuirass_lua_aura:IsAura() return true end
function modifier_item_amaliels_cuirass_lua_aura:GetModifierAura() return "modifier_item_amaliels_cuirass_lua_aura_debuff" end
function modifier_item_amaliels_cuirass_lua_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_amaliels_cuirass_lua_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_amaliels_cuirass_lua_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end
function modifier_item_amaliels_cuirass_lua_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end

modifier_item_amaliels_cuirass_lua_aura_buff = modifier_item_amaliels_cuirass_lua_aura_buff or class({})
function modifier_item_amaliels_cuirass_lua_aura_buff:IsPurgable() return false end
function modifier_item_amaliels_cuirass_lua_aura_buff:GetEffectName() return "particles/items_fx/aura_assault.vpcf" end
function modifier_item_amaliels_cuirass_lua_aura_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_amaliels_cuirass_lua_aura_buff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_amaliels_cuirass_lua_aura_buff:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() return end
	self.aura_attack_speed = self:GetAbility():GetSpecialValueFor("aura_attack_speed")
	self.aura_positive_armor = self:GetAbility():GetSpecialValueFor("aura_positive_armor")
end
function modifier_item_amaliels_cuirass_lua_aura_buff:GetModifierAttackSpeedBonus_Constant() return self.aura_attack_speed end
function modifier_item_amaliels_cuirass_lua_aura_buff:GetModifierPhysicalArmorBonus() return self.aura_positive_armor end

modifier_item_amaliels_cuirass_lua_aura_debuff = modifier_item_amaliels_cuirass_lua_aura_debuff or class({})
function modifier_item_amaliels_cuirass_lua_aura_debuff:IsPurgable() return false end
function modifier_item_amaliels_cuirass_lua_aura_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_amaliels_cuirass_lua_aura_debuff:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() return end
	self.aura_negative_armor = self:GetAbility():GetSpecialValueFor("aura_negative_armor")
end
function modifier_item_amaliels_cuirass_lua_aura_debuff:GetModifierPhysicalArmorBonus() return self.aura_negative_armor end