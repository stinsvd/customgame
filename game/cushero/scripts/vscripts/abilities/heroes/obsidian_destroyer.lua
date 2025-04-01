LinkLuaModifier("modifier_obsidian_destroyer_equilibrium_lua", "abilities/heroes/obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_equilibrium_lua_buff", "abilities/heroes/obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_equilibrium_lua_debuff", "abilities/heroes/obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_equilibrium_lua_mana_increase", "abilities/heroes/obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)

obsidian_destroyer_equilibrium_lua = obsidian_destroyer_equilibrium_lua or class(ability_lua_base)
function obsidian_destroyer_equilibrium_lua:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return self.BaseClass.GetBehavior(self)
end
function obsidian_destroyer_equilibrium_lua:GetIntrinsicModifierName() return "modifier_obsidian_destroyer_equilibrium_lua" end
function obsidian_destroyer_equilibrium_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_obsidian_destroyer_equilibrium_lua_buff", {duration=self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("Hero_ObsidianDestroyer.Equilibrium.Cast")
end

modifier_obsidian_destroyer_equilibrium_lua = modifier_obsidian_destroyer_equilibrium_lua or class({})
function modifier_obsidian_destroyer_equilibrium_lua:IsHidden() return true end
function modifier_obsidian_destroyer_equilibrium_lua:IsPurgable() return false end
function modifier_obsidian_destroyer_equilibrium_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_obsidian_destroyer_equilibrium_lua:OnCreated()
	self.mana_steal = self:GetAbility():GetSpecialValueFor("mana_steal")
	self.mana_steal_cap_pct = self:GetAbility():GetSpecialValueFor("mana_steal_cap_pct")
	self.mana_steal_active = self:GetAbility():GetSpecialValueFor("mana_steal_active")
	self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	self.mana_increase_duration = self:GetAbility():GetSpecialValueFor("mana_increase_duration")
end
function modifier_obsidian_destroyer_equilibrium_lua:OnRefresh()
	self:OnCreated()
end
function modifier_obsidian_destroyer_equilibrium_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	local active = kv.attacker:HasModifier("modifier_obsidian_destroyer_equilibrium_lua_buff")
	if kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		local steal = active and self.mana_steal_active or self.mana_steal
		local mana = kv.damage * steal / 100
		if not active then
			mana = math.min(mana, kv.attacker:GetMaxMana()*self.mana_steal_cap_pct/100)
		end
		kv.attacker:GiveMana(mana)
		if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("mana_increase_chance"), self:GetAbility():entindex(), kv.attacker) then
			kv.attacker:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_obsidian_destroyer_equilibrium_lua_mana_increase", {duration=self.mana_increase_duration})
		end
	end
	if active then
		kv.unit:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_obsidian_destroyer_equilibrium_lua_debuff", {duration=self.slow_duration})
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.attacker)
		ParticleManager:SetParticleControlEnt(fx, 0, kv.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(fx, 1, kv.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(fx, 2, kv.unit:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(fx)
		local fx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.attacker)
		ParticleManager:ReleaseParticleIndex(fx2)
		kv.unit:EmitSound("Hero_ObsidianDestroyer.Equilibrium.Damage")
	elseif kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_manasteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.unit)
		ParticleManager:ReleaseParticleIndex(fx)
	end
end
function modifier_obsidian_destroyer_equilibrium_lua:GetModifierMoveSpeedBonus_Constant() return self:GetParent():GetMana() * self:GetAbility():GetSpecialValueFor("mana_as_ms") / 100 end

modifier_obsidian_destroyer_equilibrium_lua_buff = modifier_obsidian_destroyer_equilibrium_lua_buff or class({})
function modifier_obsidian_destroyer_equilibrium_lua_buff:IsPurgable() return true end
function modifier_obsidian_destroyer_equilibrium_lua_buff:GetStatusEffectName() return "particles/status_fx/status_effect_obsidian_matter.vpcf" end
function modifier_obsidian_destroyer_equilibrium_lua_buff:GetEffectName() return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_buff.vpcf" end
function modifier_obsidian_destroyer_equilibrium_lua_buff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

modifier_obsidian_destroyer_equilibrium_lua_debuff = modifier_obsidian_destroyer_equilibrium_lua_debuff or class({})
function modifier_obsidian_destroyer_equilibrium_lua_debuff:IsPurgable() return true end
function modifier_obsidian_destroyer_equilibrium_lua_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_obsidian_matter_debuff.vpcf" end
function modifier_obsidian_destroyer_equilibrium_lua_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_obsidian_destroyer_equilibrium_lua_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("movement_slow") * (-1)
end
function modifier_obsidian_destroyer_equilibrium_lua_debuff:OnRefresh()
	self:OnCreated()
end
function modifier_obsidian_destroyer_equilibrium_lua_debuff:GetModifierMoveSpeedBonus_Percentage() return self.slow end

modifier_obsidian_destroyer_equilibrium_lua_mana_increase = modifier_obsidian_destroyer_equilibrium_lua_mana_increase or class({})
function modifier_obsidian_destroyer_equilibrium_lua_mana_increase:IsPurgable() return true end
function modifier_obsidian_destroyer_equilibrium_lua_mana_increase:DeclareFunctions() return {MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE} end
function modifier_obsidian_destroyer_equilibrium_lua_mana_increase:OnCreated()
	self.mana_increase = self:GetAbility():GetSpecialValueFor("mana_increase")
	if not IsServer() then return end
	self:IncrementStackCount()
	Timers:CreateTimer({endTime=self:GetDuration(), callback=function()
		if not self or self:IsNull() then return end
		self:DecrementStackCount()
	end}, nil, self)
end
function modifier_obsidian_destroyer_equilibrium_lua_mana_increase:OnRefresh()
	self:OnCreated()
	if not IsServer() then return end
	self:GetParent():CalculateStatBonus(false)
end
function modifier_obsidian_destroyer_equilibrium_lua_mana_increase:GetModifierExtraManaPercentage() return self.mana_increase * self:GetStackCount() end