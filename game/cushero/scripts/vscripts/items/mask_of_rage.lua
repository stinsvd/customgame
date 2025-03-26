LinkLuaModifier("modifier_item_mask_of_rage_lua", "items/mask_of_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mask_of_rage_active_lua", "items/mask_of_rage", LUA_MODIFIER_MOTION_NONE)

item_mask_of_rage_lua = item_mask_of_rage_lua or class(ability_lua_base)
function item_mask_of_rage_lua:GetIntrinsicModifierName() return "modifier_item_mask_of_rage_lua" end
function item_mask_of_rage_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_mask_of_rage_active_lua", {duration=self:GetSpecialValueFor("berserk_duration")})
	self:GetCaster():EmitSound("DOTA_Item.MaskOfMadness.Activate")
end

modifier_item_mask_of_rage_lua = modifier_item_mask_of_rage_lua or class({})
function modifier_item_mask_of_rage_lua:IsHidden() return true end
function modifier_item_mask_of_rage_lua:IsPurgable() return false end
function modifier_item_mask_of_rage_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mask_of_rage_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_mask_of_rage_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	kv.attacker:Lifesteal(self:GetAbility():GetSpecialValueFor("lifesteal_percent"), kv.damage, self:GetAbility(), false, false)
end
function modifier_item_mask_of_rage_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_mask_of_rage_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end

modifier_item_mask_of_rage_active_lua = modifier_item_mask_of_rage_active_lua or class({})
function modifier_item_mask_of_rage_active_lua:IsPurgable() return true end
function modifier_item_mask_of_rage_active_lua:GetEffectName() return "particles/items2_fx/mask_of_madness.vpcf" end
function modifier_item_mask_of_rage_active_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_mask_of_rage_active_lua:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_item_mask_of_rage_active_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_mask_of_rage_active_lua:OnCreated()
	self.berserk_bonus_attack_speed = self:GetAbility():GetSpecialValueFor("berserk_bonus_attack_speed")
	self.berserk_bonus_movement_speed = self:GetAbility():GetSpecialValueFor("berserk_bonus_movement_speed")
	self.berserk_armor_reduction = -self:GetAbility():GetSpecialValueFor("berserk_armor_reduction")
	self.berserk_hp_leech_percent = self:GetAbility():GetSpecialValueFor("berserk_hp_leech_percent")
end
function modifier_item_mask_of_rage_active_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	return kv.target:GetMaxHealth() * self.berserk_hp_leech_percent / 100
end
function modifier_item_mask_of_rage_active_lua:GetModifierAttackSpeedBonus_Constant() return self.berserk_bonus_attack_speed end
function modifier_item_mask_of_rage_active_lua:GetModifierMoveSpeedBonus_Constant() return self.berserk_bonus_movement_speed end
function modifier_item_mask_of_rage_active_lua:GetModifierPhysicalArmorBonus() return self.berserk_armor_reduction end