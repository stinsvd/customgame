LinkLuaModifier("modifier_item_eye_of_skadi_lua", "items/eye_of_skadi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eye_of_skadi_lua_slow", "items/eye_of_skadi", LUA_MODIFIER_MOTION_NONE)

item_eye_of_skadi_lua = item_eye_of_skadi_lua or class(ability_lua_base)
function item_eye_of_skadi_lua:GetIntrinsicModifierName() return "modifier_item_eye_of_skadi_lua" end

modifier_item_eye_of_skadi_lua = modifier_item_eye_of_skadi_lua or class({})
function modifier_item_eye_of_skadi_lua:IsHidden() return true end
function modifier_item_eye_of_skadi_lua:IsPurgable() return false end
function modifier_item_eye_of_skadi_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_eye_of_skadi_lua:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_item_eye_of_skadi_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_PROJECTILE_NAME} end
function modifier_item_eye_of_skadi_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:IsIllusion() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_item_eye_of_skadi_lua_slow", {duration=self:GetAbility():GetSpecialValueFor("cold_duration")})
	Timers:CreateTimer({endTime=FrameTime(), callback=function()
		kv.target:RemoveModifierByNameAndCaster("modifier_item_skadi_slow", kv.attacker)
	end}, nil, self)
end
function modifier_item_eye_of_skadi_lua:GetModifierProjectileName() return "particles/items2_fx/skadi_projectile.vpcf" end
function modifier_item_eye_of_skadi_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_eye_of_skadi_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_eye_of_skadi_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_eye_of_skadi_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_eye_of_skadi_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end

modifier_item_eye_of_skadi_lua_slow = modifier_item_eye_of_skadi_lua_slow or class({})
function modifier_item_eye_of_skadi_lua_slow:IsDebuff() return true end
function modifier_item_eye_of_skadi_lua_slow:IsPurgable() return true end
function modifier_item_eye_of_skadi_lua_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost_lich.vpcf" end
function modifier_item_eye_of_skadi_lua_slow:StatusEffectPriority() return 10 end
function modifier_item_eye_of_skadi_lua_slow:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE} end
function modifier_item_eye_of_skadi_lua_slow:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() return end
	self.cold_attack_slow = self:GetAbility():GetSpecialValueFor("cold_attack_slow")
	self.cold_slow = self:GetAbility():GetSpecialValueFor("cold_slow")
	self.heal_reduction = self:GetAbility():GetSpecialValueFor("heal_reduction") * (-1)
end
function modifier_item_eye_of_skadi_lua_slow:GetModifierAttackSpeedBonus_Constant() return self.cold_attack_slow end
function modifier_item_eye_of_skadi_lua_slow:GetModifierMoveSpeedBonus_Percentage() return self.cold_slow end
function modifier_item_eye_of_skadi_lua_slow:GetModifierHPRegenAmplify_Percentage() return self.heal_reduction end
function modifier_item_eye_of_skadi_lua_slow:GetModifierLifestealAmplify() return self.heal_reduction end

item_eye_of_skadi_2_lua = item_eye_of_skadi_2_lua or class(item_eye_of_skadi_lua)