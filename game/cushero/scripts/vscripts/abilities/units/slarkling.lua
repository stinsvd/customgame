LinkLuaModifier("modifier_slarkling_dark_pact_lua", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)

slarkling_dark_pact_lua = slarkling_dark_pact_lua or class(ability_lua_base)
boss_slarkling_dark_pact_lua = boss_slarkling_dark_pact_lua or slarkling_dark_pact_lua
function slarkling_dark_pact_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_slarkling_dark_pact_lua", {})
end

modifier_slarkling_dark_pact_lua = modifier_slarkling_dark_pact_lua or class({})
function modifier_slarkling_dark_pact_lua:IsHidden() return true end
function modifier_slarkling_dark_pact_lua:IsPurgable() return false end
function modifier_slarkling_dark_pact_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_slarkling_dark_pact_lua:OnCreated()
	if not IsServer() then return end
	self.pulse_duration = self:GetAbility():GetSpecialValueFor("pulse_duration")
	self.total_pulses = self:GetAbility():GetSpecialValueFor("total_pulses")
	self.self_damage_pct = self:GetAbility():GetSpecialValueFor("self_damage_pct")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.count = 0
	self.damage = self:GetAbility():GetSpecialValueFor("total_damage") / self.total_pulses
	local fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetTeamNumber())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitoc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(fx)
	EmitSoundOnLocationForAllies(self:GetParent():GetAbsOrigin(), "Hero_Slark.DarkPact.PreCast", self:GetParent())
	Timers:CreateTimer({endTime=self:GetAbility():GetSpecialValueFor("delay"), callback=function()
		if self and not self:IsNull() then
			self:StartIntervalThink(self.pulse_duration/self.total_pulses)
			local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(fx, 2, Vector(self.radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(fx)
			self:GetParent():EmitSound("Hero_Slark.DarkPact.Cast")
			self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_1)
		end
	end}, nil, self)
end
function modifier_slarkling_dark_pact_lua:OnIntervalThink()
	for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)) do
		ApplyDamage({attacker=self:GetParent(), victim=enemy, damage=self.damage, damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
	end
	self:GetParent():Dispell(self:GetParent(), true)
	ApplyDamage({attacker=self:GetParent(), victim=self:GetParent(), damage=self.damage*self.self_damage_pct/100, damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NON_LETHAL, ability=self:GetAbility()})
	self.count = self.count + 1
	if self.count >= self.total_pulses then
		self:StartIntervalThink(-1)
		self:Destroy()
	end
end

LinkLuaModifier("modifier_slarkling_pounce_lua", "abilities/units/slarkling", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_slarkling_pounce_lua_debuff", "abilities/units/slarkling", LUA_MODIFIER_MOTION_BOTH)

slarkling_pounce_lua = slarkling_pounce_lua or class(ability_lua_base)
boss_slarkling_pounce_lua = boss_slarkling_pounce_lua or slarkling_pounce_lua
function slarkling_pounce_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_slarkling_pounce_lua", {})
	self:GetCaster():EmitSound("Hero_Slark.Pounce.Cast")
end

modifier_slarkling_pounce_lua = modifier_slarkling_pounce_lua or class({})
function modifier_slarkling_pounce_lua:IsHidden() return true end
function modifier_slarkling_pounce_lua:IsPurgable() return true end
function modifier_slarkling_pounce_lua:CheckState() return {[MODIFIER_STATE_DISARMED] = true} end
function modifier_slarkling_pounce_lua:GetEffectName() return "particles/units/heroes/hero_slark/slark_pounce_trail.vpcf" end
function modifier_slarkling_pounce_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_slarkling_pounce_lua:OnCreated()
	local speed = self:GetAbility():GetSpecialValueFor("pounce_speed")
	local distance = self:GetAbility():GetSpecialValueFor("pounce_distance")
	local duration = distance/speed
	local height = 160
	if not IsServer() then return end
	self.arc = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_generic_arc_lua", {speed = speed, duration = duration, distance = distance, height = height, activity = ACT_DOTA_SLARK_POUNCE})
	self.arc:SetEndCallback(function(interrupted)
		if self:IsNull() then return end
		self.arc = nil
		self:Destroy()
	end)
	self:SetDuration(duration, true)
	self:GetAbility():SetActivated(false)
	self:StartIntervalThink(0.1)
	self:OnIntervalThink()
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(fx)
end
function modifier_slarkling_pounce_lua:OnDestroy()
	if not IsServer() then return end
	self:GetAbility():SetActivated(true)
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetOrigin(), 100, false)
	if self.arc and not self.arc:IsNull() then
		self.arc:Destroy()
	end
end
function modifier_slarkling_pounce_lua:OnIntervalThink()
	local target = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self:GetAbility():GetSpecialValueFor("pounce_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)[1]
	if not target then return end
	target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_slarkling_pounce_lua_debuff", {duration = self:GetAbility():GetSpecialValueFor("leash_duration"), radius = self:GetAbility():GetSpecialValueFor("leash_radius"), purgable = false})
	target:EmitSound("Hero_Slark.Pounce.Impact")
	if target:IsHero() and not target:IsIllusion() then
		local essence_shift = self:GetParent():FindAbilityByName("slarkling_essence_shift_lua") or self:GetParent():FindAbilityByName("boss_slarkling_essence_shift_lua")
		local essence_shift_buff = self:GetParent():FindModifierByNameAndCaster("modifier_slarkling_essence_shift_lua", self:GetParent())
		if essence_shift and essence_shift_buff then
			for i=1, self:GetAbility():GetSpecialValueFor("essence_stacks") do
				target:AddNewModifier(self:GetParent(), essence_shift, "modifier_slarkling_essence_shift_lua_debuff", {duration = essence_shift:GetSpecialValueFor("duration"), stack_duration = essence_shift:GetSpecialValueFor("duration")})
				essence_shift_buff:AddStack(essence_shift:GetSpecialValueFor("duration"))
			end
		end
	end
	ApplyDamage({victim=target, attacker=self:GetParent(), damage=self:GetAbility():GetSpecialValueFor("pounce_damage"), damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
	self:GetParent():SetAttacking(target)
	self:Destroy()
end

modifier_slarkling_pounce_lua_debuff = modifier_slarkling_pounce_lua_debuff or class({})
function modifier_slarkling_pounce_lua_debuff:IsPurgable() return false end
function modifier_slarkling_pounce_lua_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_slarkling_pounce_lua_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_slarkling_pounce_lua_debuff:StatusEffectPriority() return MODIFIER_PRIORITY_NORMAL end
function modifier_slarkling_pounce_lua_debuff:OnCreated(kv)
	if not IsServer() then return end
	self.radius = kv.radius
	self.leash = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_generic_leashed_lua", kv)
	self.leash:SetEndCallback(function()
		if self:IsNull() then return end
		self.leash = nil
		self:Destroy()
	end)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_ground.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetCaster(), PATTACH_WORLDORIGIN, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(fx, 3, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(fx, 4, Vector(self.radius, 0, 0))
	self:AddParticle(fx, false, false, -1, false, false)
	self:GetParent():EmitSound("Hero_Slark.Pounce.Leash")
	local fx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_leash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx2, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(fx2, 3, self:GetParent():GetOrigin())
	self:AddParticle(fx2, false, false, -1, false, false)
end
function modifier_slarkling_pounce_lua_debuff:OnDestroy()
	if not IsServer() then return end
	if self.leash and not self.leash:IsNull() then
		self.leash:Destroy()
	end
	self:GetParent():StopSound("Hero_Slark.Pounce.Leash")
	self:GetParent():EmitSound("Hero_Slark.Pounce.End")
end

LinkLuaModifier("modifier_slarkling_essence_shift_lua", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slarkling_essence_shift_lua_debuff", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slarkling_essence_shift_lua_buff", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)

slarkling_essence_shift_lua = slarkling_essence_shift_lua or class(ability_lua_base)
boss_slarkling_essence_shift_lua = boss_slarkling_essence_shift_lua or slarkling_essence_shift_lua
function slarkling_essence_shift_lua:GetIntrinsicModifierName() return "modifier_slarkling_essence_shift_lua" end

modifier_slarkling_essence_shift_lua = modifier_slarkling_essence_shift_lua or class({})
function modifier_slarkling_essence_shift_lua:IsHidden() return true end
function modifier_slarkling_essence_shift_lua:IsPurgable() return false end
function modifier_slarkling_essence_shift_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_FEEDBACK} end
function modifier_slarkling_essence_shift_lua:GetModifierProcAttack_Feedback(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:PassivesDisabled() or not kv.target:IsHero() or kv.target:IsIllusion() then return end
	kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_slarkling_essence_shift_lua_debuff", {duration=self:GetAbility():GetSpecialValueFor("duration")})
	kv.attacker:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_slarkling_essence_shift_lua_buff", {duration=self:GetAbility():GetSpecialValueFor("duration")})
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_essence_shift.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.target)
	ParticleManager:SetParticleControl(fx, 1, kv.attacker:GetOrigin() + Vector(0, 0, 64))
	ParticleManager:ReleaseParticleIndex(fx)
end

modifier_slarkling_essence_shift_lua_debuff = modifier_slarkling_essence_shift_lua_debuff or class({})
function modifier_slarkling_essence_shift_lua_debuff:IsPurgable() return false end
function modifier_slarkling_essence_shift_lua_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_slarkling_essence_shift_lua_debuff:OnCreated()
	self.stat_loss = self:GetAbility():GetSpecialValueFor("stat_loss")
	if not IsServer() then return end
	self:IncrementStackCount()
	Timers:CreateTimer({endTime=self:GetDuration(), callback=function()
		if not self or self:IsNull() then return end
		self:DecrementStackCount()
	end}, nil, self)
end
function modifier_slarkling_essence_shift_lua_debuff:OnRefresh()
	self:OnCreated()
end
function modifier_slarkling_essence_shift_lua_debuff:GetModifierBonusStats_Strength() return -self.stat_loss * self:GetStackCount() end
function modifier_slarkling_essence_shift_lua_debuff:GetModifierBonusStats_Agility() return -self.stat_loss * self:GetStackCount() end
function modifier_slarkling_essence_shift_lua_debuff:GetModifierBonusStats_Intellect() return -self.stat_loss * self:GetStackCount() end

modifier_slarkling_essence_shift_lua_buff = modifier_slarkling_essence_shift_lua_buff or class({})
function modifier_slarkling_essence_shift_lua_buff:IsPurgable() return false end
function modifier_slarkling_essence_shift_lua_buff:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_slarkling_essence_shift_lua_buff:OnCreated()
	self.agi_gain = self:GetAbility():GetSpecialValueFor("agi_gain")
	if not IsServer() then return end
	self:IncrementStackCount()
	Timers:CreateTimer({endTime=self:GetDuration(), callback=function()
		if not self or self:IsNull() then return end
		self:DecrementStackCount()
	end}, nil, self)
end
function modifier_slarkling_essence_shift_lua_buff:OnRefresh()
	self:OnCreated()
end
function modifier_slarkling_essence_shift_lua_buff:GetModifierPreAttack_BonusDamage() return self.agi_gain * self:GetStackCount() * GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_DAMAGE) end
function modifier_slarkling_essence_shift_lua_buff:GetModifierPhysicalArmorBonus() return math.floor(self.agi_gain * self:GetStackCount() * GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR), 2) end
function modifier_slarkling_essence_shift_lua_buff:GetModifierAttackSpeedBonus_Constant() return self.agi_gain * self:GetStackCount() * GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED) end

LinkLuaModifier("modifier_slarkling_depth_shroud_lua", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slarkling_depth_shroud_lua_thinker", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)

slarkling_depth_shroud_lua = slarkling_depth_shroud_lua or class(ability_lua_base)
boss_slarkling_depth_shroud_lua = boss_slarkling_depth_shroud_lua or slarkling_depth_shroud_lua
function slarkling_depth_shroud_lua:OnSpellStart()
	CreateModifierThinker(self:GetCaster(), self, "modifier_slarkling_depth_shroud_lua_thinker", {duration=self:GetSpecialValueFor("duration")}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end

modifier_slarkling_depth_shroud_lua_thinker = modifier_slarkling_depth_shroud_lua_thinker or class({})
function modifier_slarkling_depth_shroud_lua_thinker:IsHidden() return true end
function modifier_slarkling_depth_shroud_lua_thinker:IsPurgable() return false end
function modifier_slarkling_depth_shroud_lua_thinker:IsAura() return true end
function modifier_slarkling_depth_shroud_lua_thinker:GetModifierAura() return "modifier_slarkling_depth_shroud_lua" end
function modifier_slarkling_depth_shroud_lua_thinker:GetAuraRadius() return self.radius end
function modifier_slarkling_depth_shroud_lua_thinker:GetAuraDuration() return 0.5 end
function modifier_slarkling_depth_shroud_lua_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_slarkling_depth_shroud_lua_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_slarkling_depth_shroud_lua_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_slarkling_depth_shroud_lua_thinker:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shard_depth_shroud.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 2, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 3, self:GetParent():GetAbsOrigin())
	self:AddParticle(fx, false, false, -1, false, false)
end

modifier_slarkling_depth_shroud_lua = modifier_slarkling_depth_shroud_lua or class({})
function modifier_slarkling_depth_shroud_lua:IsPurgable() return false end
function modifier_slarkling_depth_shroud_lua:GetPriority() return MODIFIER_PRIORITY_ULTRA end
function modifier_slarkling_depth_shroud_lua:GetStatusEffectName() return "particles/status_fx/status_effect_slark_shadow_dance.vpcf" end
function modifier_slarkling_depth_shroud_lua:StatusEffectPriority() return MODIFIER_PRIORITY_NORMAL end
function modifier_slarkling_depth_shroud_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_PERSISTENT_INVISIBILITY, MODIFIER_PROPERTY_INVISIBILITY_ATTACK_BEHAVIOR_EXCEPTION, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_slarkling_depth_shroud_lua:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true} end
function modifier_slarkling_depth_shroud_lua:OnCreated()
	self.shadow_dance = self:GetAbility():GetCaster():FindAbilityByName("slarkling_shadow_dance_lua") or self:GetAbility():GetCaster():FindAbilityByName("boss_slarkling_shadow_dance_lua")
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetTeamNumber())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(), true)
	ParticleManager:SetParticleControlEnt(fx, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeR", Vector(), true)
	ParticleManager:SetParticleControlEnt(fx, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeL", Vector(), true)
	self:AddParticle(fx, false, false, -1, false, false)
end
function modifier_slarkling_depth_shroud_lua:GetModifierInvisibilityLevel() return 2 end
function modifier_slarkling_depth_shroud_lua:GetModifierPersistentInvisibility() return 1 end
function modifier_slarkling_depth_shroud_lua:GetModifierInvisibilityAttackBehaviorException() return 1 end
function modifier_slarkling_depth_shroud_lua:GetModifierHealthRegenPercentage() return self.shadow_dance:GetSpecialValueFor("bonus_regen_pct") end
function modifier_slarkling_depth_shroud_lua:GetModifierMoveSpeedBonus_Percentage() return self.shadow_dance:GetSpecialValueFor("bonus_movement_speed") end

LinkLuaModifier("modifier_slarkling_shadow_dance_lua", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slarkling_shadow_dance_lua_passive", "abilities/units/slarkling", LUA_MODIFIER_MOTION_NONE)

slarkling_shadow_dance_lua = slarkling_shadow_dance_lua or class(ability_lua_base)
boss_slarkling_shadow_dance_lua = boss_slarkling_shadow_dance_lua or slarkling_shadow_dance_lua
function slarkling_shadow_dance_lua:GetIntrinsicModifierName() return "modifier_slarkling_shadow_dance_lua_passive" end
function slarkling_shadow_dance_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_slarkling_shadow_dance_lua", {duration = self:GetSpecialValueFor("duration")})
end

modifier_slarkling_shadow_dance_lua = modifier_slarkling_shadow_dance_lua or class({})
function modifier_slarkling_shadow_dance_lua:IsPurgable() return false end
function modifier_slarkling_shadow_dance_lua:GetPriority() return MODIFIER_PRIORITY_ULTRA end
function modifier_slarkling_shadow_dance_lua:GetStatusEffectName() return "particles/status_fx/status_effect_slark_shadow_dance.vpcf" end
function modifier_slarkling_shadow_dance_lua:StatusEffectPriority() return MODIFIER_PRIORITY_NORMAL end
function modifier_slarkling_shadow_dance_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_PERSISTENT_INVISIBILITY, MODIFIER_PROPERTY_INVISIBILITY_ATTACK_BEHAVIOR_EXCEPTION} end
function modifier_slarkling_shadow_dance_lua:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true} end
function modifier_slarkling_shadow_dance_lua:OnCreated()
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetTeamNumber())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(), true)
	ParticleManager:SetParticleControlEnt(fx, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeR", Vector(), true)
	ParticleManager:SetParticleControlEnt(fx, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeL", Vector(), true)
	self:AddParticle(fx, false, false, -1, false, false)
	self:GetParent():EmitSound("Hero_Slark.ShadowDance")
	self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(self.fx, 0, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(self.fx, 1, self:GetParent():GetOrigin())
	self:AddParticle(self.fx, false, false, -1, false, false)
	self:StartIntervalThink(FrameTime())
end
function modifier_slarkling_shadow_dance_lua:OnIntervalThink()
	ParticleManager:SetParticleControl(self.fx, 1, self:GetParent():GetOrigin())
end
function modifier_slarkling_shadow_dance_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("Hero_Slark.ShadowDance")
end
function modifier_slarkling_shadow_dance_lua:GetModifierInvisibilityLevel() return 2 end
function modifier_slarkling_shadow_dance_lua:GetModifierPersistentInvisibility() return 1 end
function modifier_slarkling_shadow_dance_lua:GetModifierInvisibilityAttackBehaviorException() return 1 end

modifier_slarkling_shadow_dance_lua_passive = modifier_slarkling_shadow_dance_lua_passive or class({})
function modifier_slarkling_shadow_dance_lua_passive:IsHidden() return self:GetStackCount()==1 end
function modifier_slarkling_shadow_dance_lua_passive:IsPurgable() return false end
function modifier_slarkling_shadow_dance_lua_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_slarkling_shadow_dance_lua_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("activation_delay"))
	self:OnIntervalThink()
end
function modifier_slarkling_shadow_dance_lua_passive:OnIntervalThink()
	self:SetStackCount(BoolToNum(self:GetParent():CanSeeByEnemy()))
end
function modifier_slarkling_shadow_dance_lua_passive:OnStackCountChanged(prev)
	if not IsServer() then return end
	if prev==self:GetStackCount() then return end
	if self:GetStackCount()==0 then
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_regen.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.fx = fx
	elseif self:GetStackCount()==1 then
		if self.fx then
			ParticleManager:DestroyParticle(self.fx, false)
			ParticleManager:ReleaseParticleIndex(self.fx)
			self.fx = nil
		end
	end
end
function modifier_slarkling_shadow_dance_lua_passive:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.unit~=self:GetParent() or kv.attacker:GetTeamNumber() == DOTA_TEAM_NEUTRALS then return end
	self:SetStackCount(1)
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("neutral_disable"))
end
function modifier_slarkling_shadow_dance_lua_passive:GetModifierHealthRegenPercentage() return self:GetAbility():GetSpecialValueFor("bonus_regen_pct") * (1-self:GetStackCount()) end
function modifier_slarkling_shadow_dance_lua_passive:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") * (1-self:GetStackCount()) end