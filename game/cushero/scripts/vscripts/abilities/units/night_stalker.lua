LinkLuaModifier("modifier_boss_night_stalker_void_lua", "abilities/units/night_stalker", LUA_MODIFIER_MOTION_NONE)

night_stalker_ability_base = night_stalker_ability_base or class(ability_lua_base)
function night_stalker_ability_base:GetNightValueFor(key)
	return self:GetSpecialValueFor(key..(GameRules:IsDaytime() and "_day" or "_night"))
end

boss_night_stalker_void_lua = boss_night_stalker_void_lua or class(night_stalker_ability_base)
function boss_night_stalker_void_lua:Void(target)
	ApplyDamage({victim=target, attacker=self:GetCaster(), damage=self:GetSpecialValueFor("damage"), damage_type=self:GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
	target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetSpecialValueFor("ministun_duration")})
	target:AddNewModifier(self:GetCaster(), self, "modifier_boss_night_stalker_void_lua", {duration=self:GetNightValueFor("duration")})
end
function boss_night_stalker_void_lua:OnSpellStart()
	if self:GetCursorTarget() then
		if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end
		self:Void(self:GetCursorTarget())
	else
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			self:Void(enemy)
		end
	end
	self:GetCaster():EmitSound("Hero_Nightstalker.Void")
end

modifier_boss_night_stalker_void_lua = modifier_boss_night_stalker_void_lua or class({})
function modifier_boss_night_stalker_void_lua:IsPurgable() return true end
function modifier_boss_night_stalker_void_lua:GetEffectName() return "particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf" end
function modifier_boss_night_stalker_void_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_boss_night_stalker_void_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_boss_night_stalker_void_lua:OnCreated()
	self.movespeed_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
	self.attackspeed_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
end
function modifier_boss_night_stalker_void_lua:OnRefresh()
	self:OnCreated()
end
function modifier_boss_night_stalker_void_lua:GetModifierMoveSpeedBonus_Percentage() return self.movespeed_slow end
function modifier_boss_night_stalker_void_lua:GetModifierAttackSpeedBonus_Constant() return self.attackspeed_slow end

LinkLuaModifier("modifier_boss_night_stalker_crippling_fear_lua", "abilities/units/night_stalker", LUA_MODIFIER_MOTION_NONE)

boss_night_stalker_crippling_fear_lua = boss_night_stalker_crippling_fear_lua or class(night_stalker_ability_base)
function boss_night_stalker_crippling_fear_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_boss_night_stalker_crippling_fear_lua", {duration=self:GetNightValueFor("duration")})
	self:GetCaster():EmitSound("Hero_Nightstalker.Trickling_Fear")
end

modifier_boss_night_stalker_crippling_fear_lua = modifier_boss_night_stalker_crippling_fear_lua or class({})
function modifier_boss_night_stalker_crippling_fear_lua:IsPurgable() return false end
function modifier_boss_night_stalker_crippling_fear_lua:IsAura() return true end
function modifier_boss_night_stalker_crippling_fear_lua:GetAuraDuration() return 0.5 end
function modifier_boss_night_stalker_crippling_fear_lua:GetAuraRadius() return self.radius end
function modifier_boss_night_stalker_crippling_fear_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_boss_night_stalker_crippling_fear_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_boss_night_stalker_crippling_fear_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_boss_night_stalker_crippling_fear_lua:GetModifierAura() return "modifier_silence" end
function modifier_boss_night_stalker_crippling_fear_lua:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(fx, 2, Vector(self.radius, self.radius, self.radius))
	self:AddParticle(fx, false, false, -1, false, false)
	self:GetParent():EmitSound("Hero_Nightstalker.Trickling_Fear_lp")
end
function modifier_boss_night_stalker_crippling_fear_lua:OnRefresh()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_boss_night_stalker_crippling_fear_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("Hero_Nightstalker.Trickling_Fear_lp")
	self:GetParent():EmitSound("Hero_Nightstalker.Trickling_Fear_end")
end

LinkLuaModifier("modifier_boss_night_stalker_hunter_in_the_night_lua", "abilities/units/night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_night_stalker_hunter_in_the_night_lua_thinker", "abilities/units/night_stalker", LUA_MODIFIER_MOTION_NONE)

boss_night_stalker_hunter_in_the_night_lua = boss_night_stalker_hunter_in_the_night_lua or class(night_stalker_ability_base)
function boss_night_stalker_hunter_in_the_night_lua:GetIntrinsicModifierName() return "modifier_boss_night_stalker_hunter_in_the_night_lua_thinker" end

modifier_boss_night_stalker_hunter_in_the_night_lua_thinker = modifier_boss_night_stalker_hunter_in_the_night_lua_thinker or class({})
function modifier_boss_night_stalker_hunter_in_the_night_lua_thinker:IsHidden() return true end
function modifier_boss_night_stalker_hunter_in_the_night_lua_thinker:IsPurgable() return false end
function modifier_boss_night_stalker_hunter_in_the_night_lua_thinker:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end
function modifier_boss_night_stalker_hunter_in_the_night_lua_thinker:OnIntervalThink()
	if (not GameRules:IsDaytime()) and (not self:GetParent():HasModifier("modifier_boss_night_stalker_hunter_in_the_night_lua")) and self:GetParent():IsAlive() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_night_stalker_hunter_in_the_night_lua", {})
	end
	if GameRules:IsDaytime() and self:GetParent():HasModifier("modifier_boss_night_stalker_hunter_in_the_night_lua") and self:GetParent():IsAlive() then
		self:GetParent():RemoveModifierByName("modifier_boss_night_stalker_hunter_in_the_night_lua")
	end
end

modifier_boss_night_stalker_hunter_in_the_night_lua = modifier_boss_night_stalker_hunter_in_the_night_lua or class({})
function modifier_boss_night_stalker_hunter_in_the_night_lua:IsPurgable() return false end
function modifier_boss_night_stalker_hunter_in_the_night_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_boss_night_stalker_hunter_in_the_night_lua:OnCreated()
	if not IsServer() then return end
	Timers:CreateTimer({endTime=FrameTime(), callback=function()
		if self:GetParent():IsRealHero() then
			local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 1, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(fx)
		end
	end}, nil, self)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_night_buff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, Vector(1,0,0))
	self:AddParticle(fx, false, false, -1, false, false)
	if not self:GetAbility():IsStolen() then
		self:GetParent():SetModel("models/heroes/nightstalker/nightstalker_night.vmdl")
		self:GetParent():SetOriginalModel("models/heroes/nightstalker/nightstalker_night.vmdl")
		if self.wings then
			UTIL_Remove(self.wings)
			UTIL_Remove(self.legs)
			UTIL_Remove(self.tail)
		end
		self.wings = self:GetParent():SpawnAttachment("models/items/nightstalker/black_nihility/black_nihility_night_back.vmdl")
		self.legs = self:GetParent():SpawnAttachment("models/items/nightstalker/endless_nightmare_legs_v2/endless_nightmare_legs_v2_night.vmdl")
		self.tail = self:GetParent():SpawnAttachment("models/items/nightstalker/endless_nightmare_tail/endless_nightmare_tail_night.vmdl")
	end
end
function modifier_boss_night_stalker_hunter_in_the_night_lua:OnDestroy()
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fx)
	if not self:GetAbility():IsStolen() then
		self:GetParent():SetModel("models/heroes/nightstalker/nightstalker.vmdl")
		self:GetParent():SetOriginalModel("models/heroes/nightstalker/nightstalker.vmdl")
		if self.wings then
			UTIL_Remove(self.wings)
			UTIL_Remove(self.legs)
			UTIL_Remove(self.tail)
		end
	end
end
function modifier_boss_night_stalker_hunter_in_the_night_lua:GetModifierMoveSpeedBonus_Percentage() if not self:GetParent():PassivesDisabled() then return self:GetAbility():GetSpecialValueFor("bonus_movement_speed_pct_night") end end
function modifier_boss_night_stalker_hunter_in_the_night_lua:GetModifierAttackSpeedBonus_Constant() if not self:GetParent():PassivesDisabled() then return self:GetAbility():GetSpecialValueFor("bonus_attack_speed_night") end end

LinkLuaModifier("modifier_boss_night_stalker_darkness_lua", "abilities/units/night_stalker", LUA_MODIFIER_MOTION_NONE)

boss_night_stalker_darkness_lua = boss_night_stalker_darkness_lua or class(night_stalker_ability_base)
function boss_night_stalker_darkness_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_boss_night_stalker_darkness_lua", {duration = self:GetSpecialValueFor("duration")})
	EmitGlobalSound("Hero_Nightstalker.Darkness")
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(fx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fx)
end

modifier_boss_night_stalker_darkness_lua = modifier_boss_night_stalker_darkness_lua or class({})
function modifier_boss_night_stalker_darkness_lua:IsPurgable() return false end
function modifier_boss_night_stalker_darkness_lua:CheckState() return {[MODIFIER_STATE_FLYING] = true, [MODIFIER_STATE_FORCED_FLYING_VISION] = true} end
function modifier_boss_night_stalker_darkness_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_boss_night_stalker_darkness_lua:OnCreated()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	if not IsServer() then return end
	GameRules:BeginNightstalkerNight(self:GetDuration())
end
function modifier_boss_night_stalker_darkness_lua:OnDestroy()
	if not IsServer() then return end
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
end
function modifier_boss_night_stalker_darkness_lua:GetModifierPreAttack_BonusDamage() return self.bonus_damage end
function modifier_boss_night_stalker_darkness_lua:GetActivityTranslationModifiers() return "hunter_night" end