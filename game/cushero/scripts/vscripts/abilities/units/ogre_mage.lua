LinkLuaModifier("modifier_ogre_magi_frost_armor_lua", "abilities/neutrals/ogre_magi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_magi_frost_armor_lua_debuff", "abilities/neutrals/ogre_magi", LUA_MODIFIER_MOTION_NONE)

ogre_magi_frost_armor_lua = ogre_magi_frost_armor_lua or class(ability_lua_base)
function ogre_magi_frost_armor_lua:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_ogre_magi_frost_armor_lua", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("n_creep_OgreMagi.FrostArmor")
end

modifier_ogre_magi_frost_armor_lua = modifier_ogre_magi_frost_armor_lua or class({})
function modifier_ogre_magi_frost_armor_lua:IsPurgable() return true end
function modifier_ogre_magi_frost_armor_lua:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_bonus")
	self.duration = self:GetAbility():GetSpecialValueFor("slow_duration")
end
function modifier_ogre_magi_frost_armor_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_ogre_magi_frost_armor_lua:GetModifierPhysicalArmorBonus() return self.armor end
function modifier_ogre_magi_frost_armor_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.target ~= self:GetParent() or UnitFilter(kv.attacker, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, self:GetParent():GetTeamNumber()) ~= UF_SUCCESS then return	end
	kv.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ogre_magi_frost_armor_lua_debuff", {duration = self.duration * (1 - kv.attacker:GetStatusResistance())})
end
function modifier_ogre_magi_frost_armor_lua:GetEffectName() return "particles/units/heroes/hero_lich/lich_frost_armor.vpcf" end
function modifier_ogre_magi_frost_armor_lua:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

modifier_ogre_magi_frost_armor_lua_debuff = modifier_ogre_magi_frost_armor_lua_debuff or class({})
function modifier_ogre_magi_frost_armor_lua_debuff:IsDebuff() return true end
function modifier_ogre_magi_frost_armor_lua_debuff:IsPurgable() return true end
function modifier_ogre_magi_frost_armor_lua_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_ogre_magi_frost_armor_lua_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost_lich.vpcf" end
function modifier_ogre_magi_frost_armor_lua_debuff:OnCreated(kv)
	if not self:GetAbility() then if IsServer() then self:Destroy() end return end
	self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
	self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
end
function modifier_ogre_magi_frost_armor_lua_debuff:GetModifierAttackSpeedBonus_Constant() return self.as_slow end
function modifier_ogre_magi_frost_armor_lua_debuff:GetModifierMoveSpeedBonus_Percentage() return self.ms_slow end