boss_sandking_burrowstrike_lua = boss_sandking_burrowstrike_lua or class(ability_lua_base)
function boss_sandking_burrowstrike_lua:OnSpellStart()
	local point = self:GetCursorTarget() ~= nil and self:GetCursorTarget():GetAbsOrigin() or self:GetCursorPosition()
	local projectile_direction = (point-self:GetCaster():GetAbsOrigin())
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()
	ProjectileManager:CreateLinearProjectile({Source=self:GetCaster(), Ability=self, vSpawnOrigin=self:GetCaster():GetAbsOrigin(), bDeleteOnHit=false, iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY, iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_NONE, iUnitTargetType=DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, fDistance=(point-self:GetCaster():GetAbsOrigin()):Length2D(), fStartRadius=self:GetSpecialValueFor("burrow_width"), fEndRadius=self:GetSpecialValueFor("burrow_width"), vVelocity=projectile_direction*self:GetSpecialValueFor("burrow_speed")})
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetSpecialValueFor("burrow_anim_time")})
	Timers:CreateTimer({endTime=self:GetSpecialValueFor("burrow_anim_time")/2, callback=function()
		if self:IsNull() then return end
		FindClearSpaceForUnit(self:GetCaster(), point, true)
	end}, nil, self)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(fx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, point)
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("Ability.SandKing_BurrowStrike")
end
function boss_sandking_burrowstrike_lua:OnProjectileHit(target, location)
	if not target then return end
	if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("burrow_duration")})
	target:Knockback(self:GetCaster(), self, 0.52, {stun=true, height=350})
	ApplyDamage({victim=target, attacker=self:GetCaster(), damage=self:GetAbilityDamage(), damage_type=self:GetAbilityDamageType(), ability=self})
end

LinkLuaModifier("modifier_boss_sandking_sand_storm_lua", "abilities/units/sandking", LUA_MODIFIER_MOTION_NONE)

boss_sandking_sand_storm_lua = boss_sandking_sand_storm_lua or class(ability_lua_base)
function boss_sandking_sand_storm_lua:OnSpellStart()
	local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_boss_sandking_sand_storm_lua", {duration=self:GetDuration()})
	modifier.invis = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible_lua", {duration=modifier:GetRemainingTime(), delay=0, texture=GetAbilityTextureNameForAbility(self:GetAbilityName())})
	modifier.invis:destroy_other_me()
	self:GetCaster():EmitSound("Ability.SandKing_SandStorm.start")
end

modifier_boss_sandking_sand_storm_lua = modifier_boss_sandking_sand_storm_lua or class({})
function modifier_boss_sandking_sand_storm_lua:IsHidden() return true end
function modifier_boss_sandking_sand_storm_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_INVISIBILITY_ATTACK_BEHAVIOR_EXCEPTION} end
function modifier_boss_sandking_sand_storm_lua:OnCreated()
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor("sand_storm_radius")
	self.damage_interval = self:GetAbility():GetSpecialValueFor("damage_tick_rate")
	self.damage = self:GetAbility():GetSpecialValueFor("sand_storm_damage")
	self.start_pos = self:GetParent():GetAbsOrigin()
	self.next_damage_time = GameRules:GetGameTime() + self.damage_interval
	self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.effect, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.effect, 1, Vector(self.radius, self.radius, self.radius))
	self:GetParent():EmitSound("Ability.SandKing_SandStorm.start")
	self:StartIntervalThink(FrameTime())
end
function modifier_boss_sandking_sand_storm_lua:OnRefresh()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.effect, false)
	self:OnCreated()
end
function modifier_boss_sandking_sand_storm_lua:OnIntervalThink()
	if CalculateDistance(self.start_pos, self:GetParent():GetAbsOrigin()) > self.radius then
		self:Destroy()
		return
	end
	if GameRules:GetGameTime() >= self.next_damage_time then
		self.next_damage_time = GameRules:GetGameTime() + self.damage_interval
		for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			ApplyDamage({victim=enemy, attacker=self:GetParent(), damage=self.damage * self.damage_interval, damage_type=DAMAGE_TYPE_MAGICAL, ability=self:GetAbility()})
		end
	end
end
function modifier_boss_sandking_sand_storm_lua:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.effect, false)
	self.invis:Destroy()
end
function modifier_boss_sandking_sand_storm_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	self.invis = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_invisible_lua", {duration=self:GetRemainingTime(), delay=self:GetAbility():GetSpecialValueFor("fade_delay"), texture=GetAbilityTextureNameForAbility(self:GetAbility():GetAbilityName())})
	self.invis:destroy_other_me()
end
function modifier_boss_sandking_sand_storm_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() then return end
	self.invis = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_invisible_lua", {duration=self:GetRemainingTime(), delay=self:GetAbility():GetSpecialValueFor("fade_delay"), texture=GetAbilityTextureNameForAbility(self:GetAbility():GetAbilityName())})
	self.invis:destroy_other_me()
end
function modifier_boss_sandking_sand_storm_lua:GetModifierInvisibilityAttackBehaviorException() return 1 end

LinkLuaModifier("modifier_boss_sandking_caustic_finale_lua", "abilities/units/sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_sandking_caustic_finale_lua_debuff", "abilities/units/sandking", LUA_MODIFIER_MOTION_NONE)

boss_sandking_caustic_finale_lua = boss_sandking_caustic_finale_lua or class(ability_lua_base)
function boss_sandking_caustic_finale_lua:GetIntrinsicModifierName() return "modifier_boss_sandking_caustic_finale_lua" end

modifier_boss_sandking_caustic_finale_lua = modifier_boss_sandking_caustic_finale_lua or class({})
function modifier_boss_sandking_caustic_finale_lua:IsHidden() return true end
function modifier_boss_sandking_caustic_finale_lua:IsPurgable() return false end
function modifier_boss_sandking_caustic_finale_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_FEEDBACK} end
function modifier_boss_sandking_caustic_finale_lua:GetModifierProcAttack_Feedback(kv)
	if not IsServer() then return end
	if self:GetParent():PassivesDisabled() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetParent():GetTeamNumber()) ~= UF_SUCCESS then return end
	kv.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_sandking_caustic_finale_lua_debuff", {duration=self:GetAbility():GetSpecialValueFor("caustic_finale_delay")})
end

modifier_boss_sandking_caustic_finale_lua_debuff = modifier_boss_sandking_caustic_finale_lua_debuff or class({})
function modifier_boss_sandking_caustic_finale_lua_debuff:IsPurgable() return true end
function modifier_boss_sandking_caustic_finale_lua_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_boss_sandking_caustic_finale_lua_debuff:GetEffectName() return "particles/units/heroes/hero_sandking/sandking_caustic_finale_debuff.vpcf" end
function modifier_boss_sandking_caustic_finale_lua_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_boss_sandking_caustic_finale_lua_debuff:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("caustic_finale_radius")
	self.damage = self:GetAbility():GetSpecialValueFor("caustic_finale_damage_base")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("caustic_finale_damage_pct")
	self.stun_duration = self:GetAbility():GetSpecialValueFor("caustic_finale_stun_duration")
end
function modifier_boss_sandking_caustic_finale_lua_debuff:OnDestroy()
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration=self.stun_duration})
	for _,enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ApplyDamage({attacker = self:GetCaster(), victim = enemy, damage = self.damage + (self:GetParent():GetMaxHealth() * self.damage_pct / 100), damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetParent():EmitSound("Ability.SandKing_CausticFinale")
end

LinkLuaModifier("modifier_boss_sandking_epicenter_lua", "abilities/units/sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_sandking_epicenter_lua_slow", "abilities/units/sandking", LUA_MODIFIER_MOTION_NONE)

boss_sandking_epicenter_lua = boss_sandking_epicenter_lua or class(ability_lua_base)
function boss_sandking_epicenter_lua:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Ability.SandKing_Epicenter.spell")
	return true
end
function boss_sandking_epicenter_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Ability.SandKing_Epicenter.spell")
end
function boss_sandking_epicenter_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_boss_sandking_epicenter_lua", {duration=self:GetDuration()})
	self:GetCaster():EmitSound("Ability.SandKing_Epicenter")
end

modifier_boss_sandking_epicenter_lua = modifier_boss_sandking_epicenter_lua or class({})
function modifier_boss_sandking_epicenter_lua:IsPurgable() return false end
function modifier_boss_sandking_epicenter_lua:DestroyOnExpire() return false end
function modifier_boss_sandking_epicenter_lua:RemoveOnDeath() return false end
function modifier_boss_sandking_epicenter_lua:OnCreated()
	self.pulses = self:GetAbility():GetSpecialValueFor("epicenter_pulses")
	self.damage = self:GetAbility():GetSpecialValueFor("epicenter_damage")
	self.slow = self:GetAbility():GetSpecialValueFor("epicenter_slow_duration_tooltip")
	if not IsServer() then return end
	self.pulse = 0
	self:StartIntervalThink(self:GetDuration()/self.pulses)
end
function modifier_boss_sandking_epicenter_lua:OnIntervalThink()
	self.pulse = self.pulse + 1
	local radius = self:GetAbility():GetLevelSpecialValueFor("epicenter_radius", self.pulse)
	for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ApplyDamage({victim=enemy, attacker=self:GetParent(), damage=self.damage, damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
		enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_sandking_epicenter_lua_slow", {duration = self.slow})
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(fx)
	local fx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(fx2, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(fx2)
	if self.pulse>=self.pulses then
		self:Destroy()
	end
end

modifier_boss_sandking_epicenter_lua_slow = modifier_boss_sandking_epicenter_lua_slow or class({})
function modifier_boss_sandking_epicenter_lua_slow:IsPurgable() return true end
function modifier_boss_sandking_epicenter_lua_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_boss_sandking_epicenter_lua_slow:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("epicenter_slow")
	self.slow_as = self:GetAbility():GetSpecialValueFor("epicenter_slow_as")
end
function  modifier_boss_sandking_epicenter_lua_slow:OnRefresh()
	self:OnCreated()
end
function modifier_boss_sandking_epicenter_lua_slow:GetModifierMoveSpeedBonus_Percentage() return self.slow end
function modifier_boss_sandking_epicenter_lua_slow:GetModifierAttackSpeedBonus_Constant() return self.slow_as end