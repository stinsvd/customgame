LinkLuaModifier("modifier_boss_lumberjack_hellfire_blast_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)

boss_lumberjack_hellfire_blast_lua = boss_lumberjack_hellfire_blast_lua or class(ability_lua_base)
function boss_lumberjack_hellfire_blast_lua:OnSpellStart()
	ProjectileManager:CreateTrackingProjectile({vSourceLoc=self:GetCaster():GetAbsOrigin(), Target=self:GetCursorTarget(), iMoveSpeed=self:GetSpecialValueFor("blast_speed"), bDodgeable=true, bIsAttack=false, bReplaceExisting=false, iSourceAttachment=DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, bDrawsOnMinimap=false, bVisibleToEnemies=true, EffectName="particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf", Ability=self, Source=self:GetCaster(), bProvidesVision=false})
	self:GetCaster():EmitSound("Hero_SkeletonKing.Hellfire_Blast")
end
function boss_lumberjack_hellfire_blast_lua:OnProjectileHit(hTarget, vLocation)
	if hTarget == nil or hTarget:TriggerSpellAbsorb(self) then return end
	ApplyDamage({victim=hTarget, attacker=self:GetCaster(), damage=self:GetAbilityDamage(), damage_type=self:GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
	hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetSpecialValueFor("blast_stun_duration")})
	hTarget:AddNewModifier(self:GetCaster(), self, "modifier_boss_lumberjack_hellfire_blast_lua", {duration=self:GetSpecialValueFor("blast_stun_duration")+self:GetSpecialValueFor("blast_dot_duration")})
	hTarget:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")
end

modifier_boss_lumberjack_hellfire_blast_lua = modifier_boss_lumberjack_hellfire_blast_lua or class({})
function modifier_boss_lumberjack_hellfire_blast_lua:IsPurgable() return true end
function modifier_boss_lumberjack_hellfire_blast_lua:GetEffectName() return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf" end
function modifier_boss_lumberjack_hellfire_blast_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_boss_lumberjack_hellfire_blast_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_boss_lumberjack_hellfire_blast_lua:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end
function modifier_boss_lumberjack_hellfire_blast_lua:OnIntervalThink()
	ApplyDamage({victim=self:GetParent(), attacker=self:GetCaster(), damage=self:GetAbility():GetSpecialValueFor("blast_dot_damage"), damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
end
function modifier_boss_lumberjack_hellfire_blast_lua:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("blast_slow") end

LinkLuaModifier("modifier_boss_lumberjack_vampiric_aura_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_lumberjack_vampiric_aura_skeleton_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)

boss_lumberjack_vampiric_aura_lua = boss_lumberjack_vampiric_aura_lua or class(ability_lua_base)
function boss_lumberjack_vampiric_aura_lua:GetIntrinsicModifierName() return "modifier_boss_lumberjack_vampiric_aura_lua" end
function boss_lumberjack_vampiric_aura_lua:SpawnSkeletons(count)
	local i = 0
	Timers:CreateTimer({endTime=self:GetSpecialValueFor("spawn_interval"), callback=function()
		CreateUnitByNameAsync("npc_dota_wraith_king_skeleton_warrior", self:GetCaster():GetAbsOrigin() + RandomVector(300), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber(), function(unit)
			unit:AddNewModifier(self:GetCaster(), self, "modifier_boss_lumberjack_vampiric_aura_skeleton_lua", {respawn=true})
			unit:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration=self:GetSpecialValueFor("skeleton_duration")})
		end)
		i = i + 1
		if i >= count then return end
		return self:GetSpecialValueFor("spawn_interval")
	end}, nil, self)
	self:GetCaster():EmitSound("Hero_SkeletonKing.MortalStrike.Cast")
end
function boss_lumberjack_vampiric_aura_lua:OnSpellStart()
	self:SpawnSkeletons(self:GetSpecialValueFor("skeleton_spawn"))
end

modifier_boss_lumberjack_vampiric_aura_skeleton_lua = modifier_boss_lumberjack_vampiric_aura_skeleton_lua or class({})
function modifier_boss_lumberjack_vampiric_aura_skeleton_lua:IsHidden() return true end
function modifier_boss_lumberjack_vampiric_aura_skeleton_lua:IsPurgable() return false end
function modifier_boss_lumberjack_vampiric_aura_skeleton_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_boss_lumberjack_vampiric_aura_skeleton_lua:OnCreated(kv)
	if not IsServer() then return end
	self.respawn = BoolToNum(kv.respawn)
end
function modifier_boss_lumberjack_vampiric_aura_skeleton_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetCaster() or kv.ability:GetAbilityName() ~= "boss_lumberjack_hellfire_blast_lua" then return end
	ExecuteOrderFromTable({UnitIndex=self:GetParent():entindex(), OrderType=DOTA_UNIT_ORDER_STOP, Queue=false})
	self:GetParent():SetAggroTarget(kv.target)
	self:GetParent():SetAttacking(kv.target)
	self:GetParent():SetForceAttackTarget(kv.target)
	self:GetParent():SetForceAttackTarget(nil)
	ExecuteOrderFromTable({UnitIndex=self:GetParent():entindex(), OrderType=DOTA_UNIT_ORDER_ATTACK_TARGET, TargetIndex=kv.target:entindex(), Queue=false})
	self:GetParent():AddNewModifier(kv.unit, kv.ability, "modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua", {duration=kv.ability:GetSpecialValueFor("blast_stun_duration")+kv.ability:GetSpecialValueFor("blast_dot_duration")})
end
function modifier_boss_lumberjack_vampiric_aura_skeleton_lua:OnDeath(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or not self.respawn then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	CreateUnitByNameAsync(kv.unit:GetUnitName(), kv.unit:GetAbsOrigin(), true, kv.unit:GetOwner(), kv.unit:GetOwnerEntity(), kv.unit:GetTeamNumber(), function(unit)
		unit:AddNewModifier(caster, ability, "modifier_boss_lumberjack_vampiric_aura_skeleton_lua", {respawn=false})
		unit:AddNewModifier(caster, ability, "modifier_kill", {duration=ability:GetSpecialValueFor("skeleton_duration")})
	end)
end

modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua = modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua or class({})
function modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua:IsPurgable() return true end
function modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_move_speed") end
function modifier_boss_lumberjack_vampiric_aura_skeleton_buff_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end

modifier_boss_lumberjack_vampiric_aura_lua = modifier_boss_lumberjack_vampiric_aura_lua or class({})
function modifier_boss_lumberjack_vampiric_aura_lua:IsHidden() return true end
function modifier_boss_lumberjack_vampiric_aura_lua:IsPurgable() return false end
function modifier_boss_lumberjack_vampiric_aura_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_boss_lumberjack_vampiric_aura_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	self:GetParent():Lifesteal(self:GetAbility():GetSpecialValueFor("vampiric_aura"), kv.damage, self:GetAbility(), false, false)
end

LinkLuaModifier("modifier_boss_lumberjack_mortal_strike_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_lumberjack_mortal_strike_debuff_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_lumberjack_mortal_strike_debuff_form_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)

boss_lumberjack_mortal_strike_lua = boss_lumberjack_mortal_strike_lua or class(ability_lua_base)
function boss_lumberjack_mortal_strike_lua:GetIntrinsicModifierName() return "modifier_boss_lumberjack_mortal_strike_lua" end

modifier_boss_lumberjack_mortal_strike_lua = modifier_boss_lumberjack_mortal_strike_lua or class({})
function modifier_boss_lumberjack_mortal_strike_lua:IsHidden() return true end
function modifier_boss_lumberjack_mortal_strike_lua:IsPurgable() return false end
function modifier_boss_lumberjack_mortal_strike_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE} end
function modifier_boss_lumberjack_mortal_strike_lua:GetModifierPreAttack_CriticalStrike(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility():entindex(), kv.attacker) then return end
	if kv.attacker:HasModifier("modifier_boss_lumberjack_reincarnation_lua_form") then
		kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_boss_lumberjack_mortal_strike_debuff_form_lua", {duration=self:GetAbility():GetSpecialValueFor("chop_duration")})
		kv.target:EmitSound("Hero_Axe.Culling_Blade_Fail")
	else
		kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_boss_lumberjack_mortal_strike_debuff_lua", {duration=self:GetAbility():GetSpecialValueFor("chop_duration")})
		kv.target:EmitSound("Hero_Brewmaster.Brawler.Crit")
	end
	local fx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_armor_of_the_favorite_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.attacker)
	ParticleManager:ReleaseParticleIndex(fx)
	kv.target:EmitSound("Hero_SkeletonKing.CriticalStrike")
	return self:GetAbility():GetSpecialValueFor("crit_mult")
end

modifier_boss_lumberjack_mortal_strike_debuff_lua = modifier_boss_lumberjack_mortal_strike_debuff_lua or class({})
function modifier_boss_lumberjack_mortal_strike_debuff_lua:IsPurgable() return true end
function modifier_boss_lumberjack_mortal_strike_debuff_lua:GetEffectName() return "particles/woodchopper_king_chop_blood.vpcf" end
function modifier_boss_lumberjack_mortal_strike_debuff_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_boss_lumberjack_mortal_strike_debuff_lua:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
end
function modifier_boss_lumberjack_mortal_strike_debuff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_boss_lumberjack_mortal_strike_debuff_lua:OnIntervalThink()
	ApplyDamage({victim=self:GetParent(), attacker=self:GetCaster(), damage=self:GetAbility():GetSpecialValueFor("damage_pct")*self:GetParent():GetHealth()/100, damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
end

modifier_boss_lumberjack_mortal_strike_debuff_form_lua = modifier_boss_lumberjack_mortal_strike_debuff_form_lua or class({})
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:IsPurgable() return false end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:IsPurgeException() return true end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:CheckState()
	local states = {[MODIFIER_STATE_STUNNED] = true}
	if self:GetElapsedTime() < 0.6 then states[MODIFIER_STATE_FROZEN] = true end
	return states
end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:DeclareFunctions() return {MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:OnCreated()
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/woodchopper_king_blood_meer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(fx, false, false, -1, false, false)
	self.damage = math.ceil(self:GetParent():GetMaxHealth()/self:GetDuration()*self:GetAbility():GetSpecialValueFor("damage_interval"))
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:OnRefresh()
	self:OnCreated()
end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:OnIntervalThink()
	ApplyDamage({victim=self:GetParent(), attacker=self:GetCaster(), damage=self.damage, damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:GetDisableHealing() return 1 end
function modifier_boss_lumberjack_mortal_strike_debuff_form_lua:GetOverrideAnimation() return ACT_DOTA_DIE end

LinkLuaModifier("modifier_boss_lumberjack_reincarnation_lua", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_lumberjack_reincarnation_lua_hidden", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_lumberjack_reincarnation_lua_debuff", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_lumberjack_reincarnation_lua_form", "abilities/units/lumberjack", LUA_MODIFIER_MOTION_NONE)

boss_lumberjack_reincarnation_lua = boss_lumberjack_reincarnation_lua or class(ability_lua_base)
function boss_lumberjack_reincarnation_lua:GetIntrinsicModifierName() return "modifier_boss_lumberjack_reincarnation_lua" end

modifier_boss_lumberjack_reincarnation_lua = modifier_boss_lumberjack_reincarnation_lua or class({})
function modifier_boss_lumberjack_reincarnation_lua:IsHidden() return true end
function modifier_boss_lumberjack_reincarnation_lua:IsPurgable() return false end
function modifier_boss_lumberjack_reincarnation_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_boss_lumberjack_reincarnation_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.damage < kv.unit:GetHealth() or kv.unit:HasModifier("modifier_boss_lumberjack_reincarnation_lua_form") then return end
	if self:GetAbility():IsFullyCastable() then
		self:GetAbility():UseResources(true, true, false, true)
		for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("slow_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_lumberjack_reincarnation_lua_debuff", {duration=self:GetAbility():GetSpecialValueFor("slow_duration")})
		end
		local vampiric_spirit = self:GetParent():FindAbilityByName("boss_lumberjack_vampiric_aura_lua")
		if vampiric_spirit then
			vampiric_spirit:SpawnSkeletons(self:GetAbility():GetSpecialValueFor("skeleton_count"))
		end
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetOrigin())
		ParticleManager:SetParticleControl(fx, 1, Vector(self:GetAbility():GetSpecialValueFor("reincarnate_time"), 0, 0))
		ParticleManager:ReleaseParticleIndex(fx)
		self:GetParent():EmitSound("Hero_SkeletonKing.Reincarnate")
		self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_lumberjack_reincarnation_lua_hidden", {duration=self:GetAbility():GetSpecialValueFor("reincarnate_time")})
	else
		kv.unit:AddNewModifier(kv.unit, self:GetAbility(), "modifier_boss_lumberjack_reincarnation_lua_form", {duration=self:GetAbility():GetSpecialValueFor("form_duration"), killer=kv.attacker:entindex(), ability=kv.inflictor ~= nil and kv.inflictor:entindex() or nil})
	end
end
function modifier_boss_lumberjack_reincarnation_lua:GetMinHealth() return 1 end

modifier_boss_lumberjack_reincarnation_lua_hidden = modifier_boss_lumberjack_reincarnation_lua_hidden or class({})
function modifier_boss_lumberjack_reincarnation_lua_hidden:IsHidden() return true end
function modifier_boss_lumberjack_reincarnation_lua_hidden:IsPurgable() return false end
function modifier_boss_lumberjack_reincarnation_lua_hidden:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_STUNNED] = true} end
function modifier_boss_lumberjack_reincarnation_lua_hidden:OnCreated()
	if not IsServer() then return end
	self:GetParent():AddNoDraw()
end
function modifier_boss_lumberjack_reincarnation_lua_hidden:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveNoDraw()
end

modifier_boss_lumberjack_reincarnation_lua_debuff = modifier_boss_lumberjack_reincarnation_lua_debuff or class({})
function modifier_boss_lumberjack_reincarnation_lua_debuff:IsPurgable() return true end
function modifier_boss_lumberjack_reincarnation_lua_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_boss_lumberjack_reincarnation_lua_debuff:GetEffectName() return "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_slow_debuff.vpcf" end
function modifier_boss_lumberjack_reincarnation_lua_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_boss_lumberjack_reincarnation_lua_debuff:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attackslow") end
function modifier_boss_lumberjack_reincarnation_lua_debuff:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("movespeed") end

modifier_boss_lumberjack_reincarnation_lua_form = modifier_boss_lumberjack_reincarnation_lua_form or class({})
function modifier_boss_lumberjack_reincarnation_lua_form:IsPurgable() return false end
function modifier_boss_lumberjack_reincarnation_lua_form:GetStatusEffectName() return "particles/status_fx/status_effect_wraithking_ghosts.vpcf" end
function modifier_boss_lumberjack_reincarnation_lua_form:StatusEffectPriority() return MODIFIER_PRIORITY_SUPER_ULTRA+999 end
function modifier_boss_lumberjack_reincarnation_lua_form:CheckState() return {[MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_boss_lumberjack_reincarnation_lua_form:DeclareFunctions() return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_boss_lumberjack_reincarnation_lua_form:OnCreated(kv)
	if not IsServer() then return end
	self.attacker = EntIndexToHScript(kv.killer)
	self.inflictor = kv.ability ~= nil and EntIndexToHScript(kv.ability) or nil
	self:GetParent():EmitSound("Hero_SkeletonKing.Reincarnate.Ghost")
end
function modifier_boss_lumberjack_reincarnation_lua_form:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_boss_lumberjack_reincarnation_lua_form:OnDestroy()
	if not IsServer() then return end
	self:GetParent():TrueKill(self.inflictor, self.attacker)
end
function modifier_boss_lumberjack_reincarnation_lua_form:GetMinHealth() return 1 end
function modifier_boss_lumberjack_reincarnation_lua_form:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("form_move_speed_pct") end
function modifier_boss_lumberjack_reincarnation_lua_form:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("form_attack_speed") end