LinkLuaModifier("modifier_huskar_berserkers_blood_lua", "abilities/heroes/huskar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_huskar_berserkers_blood_active_lua", "abilities/heroes/huskar", LUA_MODIFIER_MOTION_NONE)

huskar_berserkers_blood_lua = huskar_berserkers_blood_lua or class({})
function huskar_berserkers_blood_lua:GetIntrinsicModifierName() return "modifier_huskar_berserkers_blood_lua" end
function huskar_berserkers_blood_lua:GetBehavior()
	if self:GetSpecialValueFor("activatable") >= 1 then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return tonumber(tostring(self.BaseClass.GetBehavior(self)))
end
function huskar_berserkers_blood_lua:GetHealthCost(level)
	return self:GetCaster():GetHealth() * self:GetSpecialValueFor("activation_healthcost_pct") / 100
end
function huskar_berserkers_blood_lua:GetCooldown(iLevel)
	return self:GetSpecialValueFor("activation_cooldown")
end
function huskar_berserkers_blood_lua:OnSpellStart()
	local dispelled_modifiers = self:GetCaster():Dispell(self:GetCaster(), false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_huskar_berserkers_blood_active_lua", {dispelled=#dispelled_modifiers, duration=self:GetSpecialValueFor("activation_delay")})
	self:GetCaster():EmitSound("Hero_Huskar.BerserkersBlood.Cast")
end

modifier_huskar_berserkers_blood_lua = modifier_huskar_berserkers_blood_lua or class({})
function modifier_huskar_berserkers_blood_lua:IsHidden() return true end
function modifier_huskar_berserkers_blood_lua:IsPurgable() return false end
function modifier_huskar_berserkers_blood_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_huskar_berserkers_blood_lua:OnCreated()
	self.hp_threshold_max = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	self.range = 100 - self.hp_threshold_max
	self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(self.fx, false, false, -1, false, false)
end
function modifier_huskar_berserkers_blood_lua:OnRefresh()
	self.hp_threshold_max = self:GetAbility():GetSpecialValueFor("hp_threshold_max")
	self.range = 100 - self.hp_threshold_max
end
function modifier_huskar_berserkers_blood_lua:GetModifierMagicalResistanceBonus() if not self:GetParent():IsIllusion() and not self:GetParent():PassivesDisabled() then return (1-math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0))*self:GetAbility():GetSpecialValueFor("maximum_resistance") end end
function modifier_huskar_berserkers_blood_lua:GetModifierAttackSpeedBonus_Constant() if not self:GetParent():PassivesDisabled() then return (1-math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0))*self:GetAbility():GetSpecialValueFor("maximum_attack_speed") end end
function modifier_huskar_berserkers_blood_lua:GetModifierConstantHealthRegen() if not self:GetParent():PassivesDisabled() then return (1-math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0))*self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("maximum_health_regen") * 0.01 end end
function modifier_huskar_berserkers_blood_lua:GetModifierModelScale()
	local pct = not self:GetParent():PassivesDisabled() and math.max((self:GetParent():GetHealthPercent()-self.hp_threshold_max)/self.range, 0) or 1
	if IsServer() then ParticleManager:SetParticleControl(self.fx, 1, Vector((1-pct)*100, 0, 0)) end
	return (1-pct)*35
end
function modifier_huskar_berserkers_blood_lua:GetActivityTranslationModifiers() return "berserkers_blood" end

modifier_huskar_berserkers_blood_active_lua = modifier_huskar_berserkers_blood_active_lua or class({})
function modifier_huskar_berserkers_blood_active_lua:IsPurgable() return false end
function modifier_huskar_berserkers_blood_active_lua:OnCreated(kv)
	if not IsServer() then return end
	local activation_healthcost_pct = self:GetAbility():GetSpecialValueFor("activation_healthcost_pct")
	local health, max_health = self:GetParent():GetHealth(), self:GetParent():GetMaxHealth()
	local health_before_cast = math.min(math.floor(health * 100 / (100 - activation_healthcost_pct)), max_health);
	local health_cost = health_before_cast * activation_healthcost_pct / 100
	self:SetStackCount(health_cost + self:GetAbility():GetSpecialValueFor("activation_heal_pct_per_debuff") * kv.dispelled * max_health / 100)
end
function modifier_huskar_berserkers_blood_active_lua:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_huskar_berserkers_blood_active_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():HealWithParams(self:GetStackCount(), self:GetAbility(), false, true, self:GetParent(), false)
	local fx = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(fx)
	SendOverheadEventMessage(self:GetParent():GetPlayerOwner(), OVERHEAD_ALERT_HEAL, self:GetParent(), self:GetStackCount(), self:GetParent():GetPlayerOwner())
end