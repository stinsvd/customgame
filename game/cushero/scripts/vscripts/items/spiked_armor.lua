LinkLuaModifier("modifier_item_spiked_armor_lua", "items/spiked_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spiked_armor_lua_unique", "items/spiked_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spiked_armor_lua_active", "items/spiked_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spiked_armor_lua_aura_buff", "items/spiked_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spiked_armor_lua_aura_debuff", "items/spiked_armor", LUA_MODIFIER_MOTION_NONE)

item_spiked_armor_lua = item_spiked_armor_lua or class(ability_lua_base)
function item_spiked_armor_lua:GetIntrinsicModifiers() return {"modifier_item_spiked_armor_lua", "modifier_item_spiked_armor_lua_unique"} end
function item_spiked_armor_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_spiked_armor_lua_active", {duration=self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
end

modifier_item_spiked_armor_lua = modifier_item_spiked_armor_lua or class({})
function modifier_item_spiked_armor_lua:IsHidden() return true end
function modifier_item_spiked_armor_lua:IsPurgable() return false end
function modifier_item_spiked_armor_lua:AllowIllusionDuplicate() return true end
function modifier_item_spiked_armor_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_spiked_armor_lua:IsAura() return true end
function modifier_item_spiked_armor_lua:GetModifierAura() return "modifier_item_spiked_armor_lua_aura_buff" end
function modifier_item_spiked_armor_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_spiked_armor_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_spiked_armor_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end
function modifier_item_spiked_armor_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_spiked_armor_lua:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_spiked_armor_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_spiked_armor_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

modifier_item_spiked_armor_lua_unique = modifier_item_spiked_armor_lua_unique or class({})
function modifier_item_spiked_armor_lua_unique:IsHidden() return true end
function modifier_item_spiked_armor_lua_unique:IsPurgable() return false end
function modifier_item_spiked_armor_lua_unique:AllowIllusionDuplicate() return true end
function modifier_item_spiked_armor_lua_unique:IsAura() return true end
function modifier_item_spiked_armor_lua_unique:GetModifierAura() return "modifier_item_spiked_armor_lua_aura_debuff" end
function modifier_item_spiked_armor_lua_unique:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_spiked_armor_lua_unique:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_spiked_armor_lua_unique:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end
function modifier_item_spiked_armor_lua_unique:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_spiked_armor_lua_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_item_spiked_armor_lua_unique:OnCreated()
	self.passive_reflection_pct = self:GetAbility():GetSpecialValueFor("passive_reflection_pct")
	self.passive_reflection_constant = self:GetAbility():GetSpecialValueFor("passive_reflection_constant")
	self.active_reflection_pct = self:GetAbility():GetSpecialValueFor("active_reflection_pct")
end
function modifier_item_spiked_armor_lua_unique:OnRefresh()
	self:OnCreated()
end
function modifier_item_spiked_armor_lua_unique:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or UnitFilter(kv.attacker, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, kv.unit:GetTeamNumber()) ~= UF_SUCCESS or bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION or bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end
	local active = self:GetParent():HasModifier("modifier_item_spiked_armor_lua_active")
	if not active and kv.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end
	local reflection = kv.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self.passive_reflection_pct or 0
	if active then
		reflection = reflection + self.active_reflection_pct
	end
	ApplyDamage({attacker=kv.unit, victim=kv.attacker, damage=kv.original_damage * reflection/100 + (kv.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self.passive_reflection_constant or 0), damage_type=kv.damage_type, damage_flags=DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, ability=self:GetAbility()})
	if active then
		kv.attacker:EmitSoundOnClient("DOTA_Item.BladeMail.Damage")
	end
end

modifier_item_spiked_armor_lua_aura_buff = modifier_item_spiked_armor_lua_aura_buff or class({})
function modifier_item_spiked_armor_lua_aura_buff:IsPurgable() return false end
function modifier_item_spiked_armor_lua_aura_buff:GetEffectName() return "particles/items_fx/aura_assault.vpcf" end
function modifier_item_spiked_armor_lua_aura_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_spiked_armor_lua_aura_buff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_spiked_armor_lua_aura_buff:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() return end
	self.aura_attack_speed = self:GetAbility():GetSpecialValueFor("aura_attack_speed")
	self.aura_positive_armor = self:GetAbility():GetSpecialValueFor("aura_positive_armor")
end
function modifier_item_spiked_armor_lua_aura_buff:GetModifierAttackSpeedBonus_Constant() return self.aura_attack_speed end
function modifier_item_spiked_armor_lua_aura_buff:GetModifierPhysicalArmorBonus() return self.aura_positive_armor end

modifier_item_spiked_armor_lua_aura_debuff = modifier_item_spiked_armor_lua_aura_debuff or class({})
function modifier_item_spiked_armor_lua_aura_debuff:IsPurgable() return false end
function modifier_item_spiked_armor_lua_aura_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_spiked_armor_lua_aura_debuff:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() return end
	self.aura_negative_armor = self:GetAbility():GetSpecialValueFor("aura_negative_armor")
end
function modifier_item_spiked_armor_lua_aura_debuff:GetModifierPhysicalArmorBonus() return self.aura_negative_armor end

modifier_item_spiked_armor_lua_active = modifier_item_spiked_armor_lua_active or class({})
function modifier_item_spiked_armor_lua_active:IsPurgable() return false end
function modifier_item_spiked_armor_lua_active:GetEffectName() return "particles/items_fx/blademail.vpcf" end
function modifier_item_spiked_armor_lua_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_spiked_armor_lua_active:GetStatusEffectName() return "particles/status_fx/status_effect_blademail.vpcf" end