LinkLuaModifier("modifier_faceless_void_time_lock_lua", "abilities/heroes/faceless_void", LUA_MODIFIER_MOTION_NONE)

faceless_void_time_lock_lua = faceless_void_time_lock_lua or class(ability_lua_base)
function faceless_void_time_lock_lua:GetIntrinsicModifierName() return "modifier_faceless_void_time_lock_lua" end
function faceless_void_time_lock_lua:TimeLock(target)
	target:AddNewModifier(self:GetCaster(), self, "modifier_bashed", {duration=target:IsHero() and self:GetSpecialValueFor("duration") or self:GetSpecialValueFor("duration_creep")})
	Timers:CreateTimer({endTime=self:GetSpecialValueFor("delay"), callback = function()
		if RollPseudoRandomPercentage(self:GetSpecialValueFor("chance_pct"), self:entindex(), self:GetCaster()) then
			if target and target:IsAlive() then
				local damage = self:TimeLock(target)
				ApplyDamage({
					attacker = self:GetCaster(),
					victim = target,
					damage = damage,
					damage_type = self:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		end
		ApplyDamage({
			attacker = self:GetCaster(),
			victim = target,
			damage = self:GetCaster():GetAverageTrueAttackDamage(nil),
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
		})
	end}, nil, self)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(fx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(fx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(fx, 4, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 5, Vector(1, 1, 1))
	ParticleManager:ReleaseParticleIndex(fx)
	target:EmitSound("Hero_FacelessVoid.TimeLockImpact")
	return self:GetSpecialValueFor("bonus_damage")
end

modifier_faceless_void_time_lock_lua = modifier_faceless_void_time_lock_lua or class({})
function modifier_faceless_void_time_lock_lua:IsHidden() return true end
function modifier_faceless_void_time_lock_lua:IsPurgable() return false end
function modifier_faceless_void_time_lock_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL} end
function modifier_faceless_void_time_lock_lua:GetModifierProcAttack_BonusDamage_Magical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:PassivesDisabled() or kv.attacker:IsIllusion() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("chance_pct"), self:GetAbility():entindex(), kv.attacker) then return end
	return self:GetAbility():TimeLock(kv.target)
end