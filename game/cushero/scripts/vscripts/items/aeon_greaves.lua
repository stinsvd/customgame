LinkLuaModifier("modifier_item_aeon_greaves_lua", "items/aeon_greaves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_aeon_greaves_lua_aura", "items/aeon_greaves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_aeon_greaves_lua_save", "items/aeon_greaves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_aeon_greaves_lua_save_cooldown", "items/aeon_greaves", LUA_MODIFIER_MOTION_NONE)

item_aeon_greaves_lua = item_aeon_greaves_lua or class(ability_lua_base)
function item_aeon_greaves_lua:GetIntrinsicModifierName() return "modifier_item_aeon_greaves_lua" end
function item_aeon_greaves_lua:OnSpellStart()
	self:GetCaster():Dispell(self:GetCaster(), false)
	for _, ally in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("replenish_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ally:GiveMana(self:GetSpecialValueFor("replenish_mana"))
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, ally, self:GetSpecialValueFor("replenish_mana"), nil)
		if not ally:HasModifier("modifier_item_mekansm_noheal") then
			ally:Heal(self:GetSpecialValueFor("replenish_health"), self:GetCaster())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, self:GetSpecialValueFor("replenish_health"), nil)
			ally:AddNewModifier(self:GetCaster(), self, "modifier_item_mekansm_noheal", {duration=self:GetEffectiveCooldown(self:GetLevel())})
			local target_fx = ParticleManager:CreateParticle(ally:IsHero() and "particles/items3_fx/warmage_recipient.vpcf" or "particles/items3_fx/warmage_mana_nonhero.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
			ParticleManager:SetParticleControl(target_fx, 0, ally:GetAbsOrigin())
			ally:EmitSound("Item.GuardianGreaves.Target")
		end
	end
	local fx = ParticleManager:CreateParticle("particles/items3_fx/warmage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("Item.GuardianGreaves.Activate")
end

modifier_item_aeon_greaves_lua = modifier_item_aeon_greaves_lua or class({})
function modifier_item_aeon_greaves_lua:IsHidden() return true end
function modifier_item_aeon_greaves_lua:IsPurgable() return false end
function modifier_item_aeon_greaves_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_aeon_greaves_lua:IsAura() return true end
function modifier_item_aeon_greaves_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_aeon_greaves_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_item_aeon_greaves_lua:GetModifierAura() return "modifier_item_aeon_greaves_lua_aura" end
function modifier_item_aeon_greaves_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_aeon_greaves_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_item_aeon_greaves_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if self:GetParent() ~= kv.unit or kv.attacker:IsIllusion() or not kv.unit:IsAlive() then return end
	if not kv.unit:IsTrueHero(true) and not kv.unit:IsClone() then return end
	if kv.unit:GetHealthPercent() <= self:GetAbility():GetSpecialValueFor("save_threshold") and not kv.unit:HasModifier("modifier_item_aeon_greaves_lua_save_cooldown") then
		kv.unit:AddNewModifier(kv.unit, self:GetAbility(), "modifier_item_aeon_greaves_lua_save", {duration=self:GetAbility():GetSpecialValueFor("buff_duration")})
		kv.unit:HealWithParams(math.max(0, (kv.unit:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("save_threshold") / 100) - kv.unit:GetHealth()), self:GetAbility(), false, false, kv.unit, false)
		kv.unit:AddNewModifier(kv.unit, self:GetAbility(), "modifier_item_aeon_greaves_lua_save_cooldown", {duration=self:GetAbility():GetSpecialValueFor("save_cooldown")})
	elseif kv.unit:GetHealthPercent() <= self:GetAbility():GetSpecialValueFor("auto_use_threshold") and not kv.unit:HasModifier("modifier_item_mekansm_noheal") and self:GetAbility():IsCooldownReady() then
		self:GetAbility():OnSpellStart()
		self:GetAbility():UseResources(false, false, false, true)
	end
end
function modifier_item_aeon_greaves_lua:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("bonus_movement") end
function modifier_item_aeon_greaves_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_aeon_greaves_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_aeon_greaves_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_aeon_greaves_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_aeon_greaves_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_aeon_greaves_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_aeon_greaves_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end

modifier_item_aeon_greaves_lua_aura = modifier_item_aeon_greaves_lua_aura or class({})
function modifier_item_aeon_greaves_lua_aura:IsPurgable() return false end
function modifier_item_aeon_greaves_lua_aura:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_aeon_greaves_lua_aura:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() return end
	self.aura_health_regen = self:GetAbility():GetSpecialValueFor("aura_health_regen")
	self.aura_armor = self:GetAbility():GetSpecialValueFor("aura_armor")
	self.aura_health_regen_bonus = self:GetAbility():GetSpecialValueFor("aura_health_regen_bonus")
	self.aura_armor_bonus = self:GetAbility():GetSpecialValueFor("aura_armor_bonus")
	self.aura_bonus_threshold = self:GetAbility():GetSpecialValueFor("aura_bonus_threshold")
end
function modifier_item_aeon_greaves_lua_aura:GetModifierPhysicalArmorBonus()
	return not self:GetParent():IsHero() or self:GetParent():GetHealthPercent() >= self.aura_bonus_threshold and self.aura_armor or self.aura_armor_bonus
end
function modifier_item_aeon_greaves_lua_aura:GetModifierConstantHealthRegen()
	return not self:GetParent():IsHero() or self:GetParent():GetHealthPercent() >= self.aura_bonus_threshold and self.aura_health_regen or self.aura_health_regen_bonus
end

modifier_item_aeon_greaves_lua_save = modifier_item_aeon_greaves_lua_save or class({})
function modifier_item_aeon_greaves_lua_save:IsPurgable() return false end
function modifier_item_aeon_greaves_lua_save:DeclareFunctions() return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE} end
function modifier_item_aeon_greaves_lua_save:OnCreated()
	self:OnRefresh()
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(fx, false, false, -1, true, false)
end
function modifier_item_aeon_greaves_lua_save:OnRefresh()
	if IsServer() and not self:GetAbility() then self:Destroy() return end
	self.damage_penalty = self:GetAbility():GetSpecialValueFor("damage_penalty")
	self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resistance")
	if not IsServer() then return end
	self:GetParent():Dispell(self:GetParent(), true)
	self:GetParent():EmitSound("DOTA_Item.ComboBreaker")
end
function modifier_item_aeon_greaves_lua_save:GetModifierTotalDamageOutgoing_Percentage() return self.damage_penalty * (-1) end
function modifier_item_aeon_greaves_lua_save:GetModifierStatusResistanceStacking() return self.status_resistance end
function modifier_item_aeon_greaves_lua_save:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_item_aeon_greaves_lua_save:GetAbsoluteNoDamageMagical() return 1 end
function modifier_item_aeon_greaves_lua_save:GetAbsoluteNoDamagePure() return 1 end

modifier_item_aeon_greaves_lua_save_cooldown = modifier_item_aeon_greaves_lua_save_cooldown or class({})
function modifier_item_aeon_greaves_lua_save_cooldown:IsPurgable() return false end
function modifier_item_aeon_greaves_lua_save_cooldown:IsDebuff() return true end