LinkLuaModifier("modifier_nevermore_unit_shadowraze_lua", "abilities/units/nevermore", LUA_MODIFIER_MOTION_NONE)

nevermore_unit_shadowraze_lua = nevermore_unit_shadowraze_lua or class(ability_lua_base)
boss_nevermore_magic_shadowraze_1_lua = boss_nevermore_magic_shadowraze_1_lua or nevermore_unit_shadowraze_lua
boss_nevermore_magic_shadowraze_2_lua = boss_nevermore_magic_shadowraze_2_lua or nevermore_unit_shadowraze_lua
boss_nevermore_magic_shadowraze_3_lua = boss_nevermore_magic_shadowraze_3_lua or nevermore_unit_shadowraze_lua
boss_nevermore_physic_shadowraze_1_lua = boss_nevermore_physic_shadowraze_1_lua or nevermore_unit_shadowraze_lua
boss_nevermore_physic_shadowraze_2_lua = boss_nevermore_physic_shadowraze_2_lua or nevermore_unit_shadowraze_lua
boss_nevermore_physic_shadowraze_3_lua = boss_nevermore_physic_shadowraze_3_lua or nevermore_unit_shadowraze_lua
function nevermore_unit_shadowraze_lua:OnSpellStart()
	local pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector():Normalized() * self:GetSpecialValueFor("shadowraze_range")
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), pos, nil, self:GetSpecialValueFor("shadowraze_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		local modifier = enemy:FindModifierByName("modifier_nevermore_unit_shadowraze_lua")
		local damage = self:GetSpecialValueFor("shadowraze_damage")+(self:GetSpecialValueFor("stack_bonus_damage") > 0 and (modifier ~= nil and modifier:GetStackCount() or 0)*self:GetSpecialValueFor("stack_bonus_damage") or 0)
		ApplyDamage({victim=enemy, attacker=self:GetCaster(), damage=damage, damage_type=self:GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
		if self:GetSpecialValueFor("duration") > 0 then
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_nevermore_unit_shadowraze_lua", {duration=self:GetSpecialValueFor("duration")})
		end
		if self:GetSpecialValueFor("perform_attack") > 0 then
			self:GetCaster():PerformAttack(enemy, true, true, true, false, false, false, true)
		end
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(fx, 0, pos)
	ParticleManager:SetParticleControl(fx, 1, Vector(self:GetSpecialValueFor("shadowraze_radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(fx)
	EmitSoundOnLocationWithCaster(pos, "Hero_Nevermore.Shadowraze", self:GetCaster())
end

modifier_nevermore_unit_shadowraze_lua = modifier_nevermore_unit_shadowraze_lua or class({})
function modifier_nevermore_unit_shadowraze_lua:IsDebuff() return true end
function modifier_nevermore_unit_shadowraze_lua:IsPurgable() return true end
function modifier_nevermore_unit_shadowraze_lua:GetEffectName() return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf" end
function modifier_nevermore_unit_shadowraze_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_nevermore_unit_shadowraze_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE} end
function modifier_nevermore_unit_shadowraze_lua:OnCreated()
	self.slow_ms = self:GetAbility():GetSpecialValueFor("movement_speed_pct")
	self.slow_turn = self:GetAbility():GetSpecialValueFor("turn_rate_pct")
	if not IsServer() then return end
	self:IncrementStackCount()
end
function modifier_nevermore_unit_shadowraze_lua:OnRefresh()
	self:OnCreated()
end
function modifier_nevermore_unit_shadowraze_lua:GetModifierMoveSpeedBonus_Percentage() return self.slow_ms * self:GetStackCount() end
function modifier_nevermore_unit_shadowraze_lua:GetModifierTurnRate_Percentage() return self.slow_turn * self:GetStackCount() end

LinkLuaModifier("modifier_nevermore_unit_necromastery_lua", "abilities/units/nevermore", LUA_MODIFIER_MOTION_NONE)

nevermore_unit_necromastery_lua = nevermore_unit_necromastery_lua or class(ability_lua_base)
boss_nevermore_magic_necromastery_lua = boss_nevermore_magic_necromastery_lua or nevermore_unit_necromastery_lua
boss_nevermore_physic_necromastery_lua = boss_nevermore_physic_necromastery_lua or nevermore_unit_necromastery_lua
function nevermore_unit_necromastery_lua:OnUpgrade()
	if self:IsBehavior(DOTA_ABILITY_BEHAVIOR_AUTOCAST) and not self:GetAutoCastState() and self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function nevermore_unit_necromastery_lua:GetIntrinsicModifierName() return "modifier_nevermore_unit_necromastery_lua" end

modifier_nevermore_unit_necromastery_lua = modifier_nevermore_unit_necromastery_lua or class({})
function modifier_nevermore_unit_necromastery_lua:IsPurgable() return false end
function modifier_nevermore_unit_necromastery_lua:RemoveOnDeath() return false end
function modifier_nevermore_unit_necromastery_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_nevermore_unit_necromastery_lua:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(self:GetAbility():GetSpecialValueFor("necromastery_max_souls"))
end
function modifier_nevermore_unit_necromastery_lua:GetModifierPreAttack_CriticalStrike(kv)
	if not IsServer() then return end
	if not self:GetAbility():IsCooldownReady() and self:GetAbility():GetAutoCastState() then return end
	self.record = kv.record
	self:GetAbility():UseResources(true, true, true, true)
	return self:GetAbility():GetSpecialValueFor("crit_pct")
end
function modifier_nevermore_unit_necromastery_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.record ~= self.record then return end
	self.record = nil
	local modifier = kv.unit:FindModifierByNameAndAbility("modifier_fear", self:GetAbility())
	if modifier == nil then
		kv.unit:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_fear", {duration=self:GetAbility():GetSpecialValueFor("fear_duration")})
	else
		modifier:SetDuration(modifier:GetRemainingTime()+self:GetAbility():GetSpecialValueFor("fear_duration"), true)
	end
end
function modifier_nevermore_unit_necromastery_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("necromastery_damage_per_soul") * self:GetStackCount() end
function modifier_nevermore_unit_necromastery_lua:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("necromastery_spell_amplify_per_soul") * self:GetStackCount() end

LinkLuaModifier("modifier_nevermore_unit_dark_lord_lua", "abilities/units/nevermore", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nevermore_unit_dark_lord_debuff_lua", "abilities/units/nevermore", LUA_MODIFIER_MOTION_NONE)

nevermore_unit_dark_lord_lua = nevermore_unit_dark_lord_lua or class(ability_lua_base)
boss_nevermore_magic_dark_lord_lua = boss_nevermore_magic_dark_lord_lua or nevermore_unit_dark_lord_lua
boss_nevermore_physic_dark_lord_lua = boss_nevermore_physic_dark_lord_lua or nevermore_unit_dark_lord_lua

function nevermore_unit_dark_lord_lua:GetIntrinsicModifierName() return "modifier_nevermore_unit_dark_lord_lua" end

modifier_nevermore_unit_dark_lord_lua = modifier_nevermore_unit_dark_lord_lua or class({})
function modifier_nevermore_unit_dark_lord_lua:IsHidden() return true end
function modifier_nevermore_unit_dark_lord_lua:IsAura() return true end
function modifier_nevermore_unit_dark_lord_lua:GetModifierAura() return "modifier_nevermore_unit_dark_lord_debuff_lua" end
function modifier_nevermore_unit_dark_lord_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_nevermore_unit_dark_lord_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_nevermore_unit_dark_lord_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_nevermore_unit_dark_lord_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("presence_radius") end

modifier_nevermore_unit_dark_lord_debuff_lua = modifier_nevermore_unit_dark_lord_debuff_lua or class({})
function modifier_nevermore_unit_dark_lord_debuff_lua:IsHidden() return self.hidden end
function modifier_nevermore_unit_dark_lord_debuff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_nevermore_unit_dark_lord_debuff_lua:OnCreated()
	if not self:GetAbility() then if IsServer() then self:Destroy() end return end
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("presence_armor_reduction")
	self.magical_reduction = self:GetAbility():GetSpecialValueFor("presence_magic_reduction")
end
function modifier_nevermore_unit_dark_lord_debuff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_nevermore_unit_dark_lord_debuff_lua:OnIntervalThink()
	self.hidden = not self:GetParent():CanEntityBeSeenByMyTeam(self:GetCaster())
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_nevermore_unit_dark_lord_debuff_lua:AddCustomTransmitterData() return {hidden = self.hidden} end
function modifier_nevermore_unit_dark_lord_debuff_lua:HandleCustomTransmitterData(kv)
	self.hidden = BoolToNum(kv.hidden)
end
function modifier_nevermore_unit_dark_lord_debuff_lua:GetModifierPhysicalArmorBonus() return self.armor_reduction end
function modifier_nevermore_unit_dark_lord_debuff_lua:GetModifierMagicalResistanceBonus() return self.magical_reduction end

LinkLuaModifier("modifier_nevermore_unit_requiem_lua", "abilities/units/nevermore", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nevermore_unit_requiem_cast_lua", "abilities/units/nevermore", LUA_MODIFIER_MOTION_NONE)

nevermore_unit_requiem_lua = nevermore_unit_requiem_lua or class(ability_lua_base)
boss_nevermore_magic_requiem_lua = boss_nevermore_magic_requiem_lua or nevermore_unit_requiem_lua
boss_nevermore_physic_requiem_lua = boss_nevermore_magic_requiem_lua or nevermore_unit_requiem_lua
function nevermore_unit_requiem_lua:GetCastAnimation() return ACT_DOTA_CAST_ABILITY_6 end
function nevermore_unit_requiem_lua:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nevermore_unit_requiem_cast_lua", {duration=self:GetCastTime()})
	self.effect_precast = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_wings.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	EmitSoundOn("Hero_Nevermore.RequiemOfSoulsCast", self:GetCaster())
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)
	return true
end
function nevermore_unit_requiem_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveModifierByName("modifier_nevermore_unit_requiem_cast_lua")
	ParticleManager:DestroyParticle(self.effect_precast, true)
	ParticleManager:ReleaseParticleIndex(self.effect_precast)
	StopSoundOn("Hero_Nevermore.RequiemOfSoulsCast", self:GetCaster())
	self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
end
function nevermore_unit_requiem_lua:OnSpellStart()
	self:GetCaster():RemoveModifierByName("modifier_nevermore_unit_requiem_cast_lua")
	self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_6)
	local lines = math.floor(self:GetCaster():GetModifierStackCount("modifier_nevermore_unit_necromastery_lua", self:GetCaster()) / self:GetSpecialValueFor("requiem_soul_conversion"))
	self:Explode(lines, false)
	if self:GetSpecialValueFor("requiem_heal_pct") > 0 then
		Timers:CreateTimer({endTime=self:GetSpecialValueFor("requiem_radius") / self:GetSpecialValueFor("requiem_line_speed"), callback=function()
			self:Explode(lines, true)
		end}, nil, self)
	end
end
function nevermore_unit_requiem_lua:OnProjectileHit_ExtraData(hTarget, vLocation, params)
	if hTarget == nil then return end
	if params.implode == 0 and hTarget:IsHero() then
		self.heal = self.heal + (self:GetAbilityDamage() * (self:GetSpecialValueFor("requiem_damage_pct")/100) * self:GetSpecialValueFor("requiem_heal_pct"))
	end
	ApplyDamage({victim=hTarget, attacker=self:GetCaster(), damage=self:GetAbilityDamage(), damage_type=self:GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
	if self:GetSpecialValueFor("requiem_slow_duration") > 0 then
		local debuff = hTarget:AddNewModifier(self:GetCaster(), self, "modifier_nevermore_unit_requiem_lua", {duration=self:GetSpecialValueFor("requiem_slow_duration")}) or hTarget:FindModifierByName("modifier_nevermore_unit_requiem_lua")
		if debuff then
			debuff:LinkModifier(hTarget:AddNewModifier(self:GetCaster(), self, "modifier_fear", {duration=self:GetSpecialValueFor("requiem_slow_duration")}), {})
		end
	end
end
function nevermore_unit_requiem_lua:OnOwnerDied()
	if not self:IsTrained() then return end
	local lines = math.floor(self:GetCaster():GetModifierStackCount("modifier_nevermore_unit_necromastery_lua", self:GetCaster()) / self:GetSpecialValueFor("requiem_soul_conversion"))
	self:Explode(math.floor(lines/2))
end
function nevermore_unit_requiem_lua:Explode(lines, implode)
	for i=1, lines do
		local facing_angle_deg = self:GetCaster():GetAnglesAsVector().y + 360/lines * i
		if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
		local facing_angle = math.rad(facing_angle_deg)
		local facing_vector = Vector(math.cos(facing_angle), math.sin(facing_angle), 0):Normalized()
		local velocity = facing_vector * self:GetSpecialValueFor("requiem_line_speed")
		local spawn_vector = self:GetCaster():GetAbsOrigin()
		if implode then
			spawn_vector = spawn_vector + (facing_vector*self:GetSpecialValueFor("requiem_radius"))
			velocity = -velocity
		end
		ProjectileManager:CreateLinearProjectile({Source=self:GetCaster(), Ability=self, EffectName="particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", vSpawnOrigin=spawn_vector, fDistance=self:GetSpecialValueFor("requiem_radius"), vVelocity=velocity, fStartRadius=self:GetSpecialValueFor("requiem_line_width_start"), fEndRadius=self:GetSpecialValueFor("requiem_line_width_end"), iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY, iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_SPELL_IMMUNE_ENEMIES, iUnitTargetType=DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, bReplaceExisting=false, bProvidesVision=false, ExtraData={implode=implode}})
		local fx_line = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(fx_line, 0, spawn_vector)
		ParticleManager:SetParticleControl(fx_line, 1, velocity)
		ParticleManager:SetParticleControl(fx_line, 2, Vector(0, self:GetSpecialValueFor("requiem_radius")/self:GetSpecialValueFor("requiem_line_speed"), 0))
		ParticleManager:ReleaseParticleIndex(fx_line)
	end
	if self.effect_precast ~= nil then
		ParticleManager:ReleaseParticleIndex(self.effect_precast)
	end
	if not implode then
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(fx, 1, Vector(lines, 0, 0))
		ParticleManager:SetParticleControlForward(fx, 2, self:GetCaster():GetForwardVector())
		ParticleManager:ReleaseParticleIndex(fx)
	end
	EmitSoundOn("Hero_Nevermore.RequiemOfSouls", self:GetCaster())
	if implode then
		local heal = self.heal
		Timers:CreateTimer({endTime=self:GetSpecialValueFor("requiem_radius") / self:GetSpecialValueFor("requiem_line_speed"), callback=function()
			self:GetCaster():Lifesteal(100, heal, self, true)
		end}, nil, self)
	else
		self.heal = 0
	end
end

modifier_nevermore_unit_requiem_lua = modifier_nevermore_unit_requiem_lua or class({})
function modifier_nevermore_unit_requiem_lua:IsHidden() return true end
function modifier_nevermore_unit_requiem_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_nevermore_unit_requiem_lua:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("requiem_reduction_ms")
	self.magic_resist = self:GetAbility():GetSpecialValueFor("requiem_reduction_mres")
	if not IsServer() then return end
	-- local fx = ParticleManager:CreateParticleForPlayer("particles/units/nevermore/screen_requiem_indicator.vpcf", PATTACH_EYES_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
	-- self:AddParticle(fx, false, false, -1, false, false)
end
function modifier_nevermore_unit_requiem_lua:OnRefresh()
	if not IsServer() then return end
	self:SetDuration(math.min(self:GetRemainingTime()+self:GetDuration(), self:GetAbility():GetSpecialValueFor("requiem_slow_duration_max")), true)
end
function modifier_nevermore_unit_requiem_lua:GetModifierMoveSpeedBonus_Percentage() return self.slow end
function modifier_nevermore_unit_requiem_lua:GetModifierMagicalResistanceBonus() return self.magic_resist end

modifier_nevermore_unit_requiem_cast_lua = modifier_nevermore_unit_requiem_cast_lua or class({})
function modifier_nevermore_unit_requiem_cast_lua:IsHidden() return true end
function modifier_nevermore_unit_requiem_cast_lua:IsPurgable() return false end
function modifier_nevermore_unit_requiem_cast_lua:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_EVENT_ON_ORDER} end
function modifier_nevermore_unit_requiem_cast_lua:OnOrder(kv)
	if not IsServer() then return end
	local parent = self:GetParent()
	if not parent:IsBoss() or kv.unit ~= parent.combotarget or kv.order_type ~= DOTA_UNIT_ORDER_CAST_NO_TARGET then return end
	if table.contains({"item_black_king_bar", "item_cyclone", "item_charons_scepter", "item_wind_waker"}, kv.ability:GetName()) then
		Timers:CreateTimer({endTime=self:GetRemainingTime()-0.1, callback=function()
			parent.requiemcombing = false
			parent.razecombing = false
			parent.razeing = false
			parent.combotarget = nil
			parent:Stop()
		end}, nil, self)
	end
end
function modifier_nevermore_unit_requiem_cast_lua:GetOverrideAnimation() return ACT_DOTA_CAST_ABILITY_6 end