bounty_huntling_shuriken_toss_lua = bounty_huntling_shuriken_toss_lua or class(ability_lua_base)
boss_bounty_huntling_shuriken_toss_lua = boss_bounty_huntling_shuriken_toss_lua or bounty_huntling_shuriken_toss_lua
function bounty_huntling_shuriken_toss_lua:OnSpellStart()
	self:LaunchShuriken(self:GetCaster(), self:GetCursorTarget())
	self:GetCaster():EmitSound("Hero_BountyHunter.Shuriken")
end
function bounty_huntling_shuriken_toss_lua:LaunchShuriken(source, target, enemy_table)
	ProjectileManager:CreateTrackingProjectile({
		Target = target,
		Source = source,
		Ability = self,
		EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("speed"),
		bDodgeable = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		bProvidesVision = false,
		ExtraData = {enemy_table=table.join(enemy_table or {target:entindex()}, ",")}
	})
end
function bounty_huntling_shuriken_toss_lua:OnProjectileHit_ExtraData(target, location, extraData)
	if not target then return end
	local enemy_table = string.split(extraData.enemy_table or "", ",")
	if not target:IsMagicImmune() and not target:TriggerSpellAbsorb(self) then
		target:EmitSound("Hero_BountyHunter.Shuriken.Impact")
		target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetSpecialValueFor("ministun")})
		local jinada_ability = self:GetCaster():FindAbilityByName("bounty_huntling_jinada_lua") or self:GetCaster():FindAbilityByName("boss_bounty_huntling_jinada_lua")
		if jinada_ability ~= nil and jinada_ability:IsTrained() and target:IsAlive() then
			jinada_ability:Jinada(target, false)
		end
		local damage = self:GetSpecialValueFor("bonus_damage")
		local track_debuff = target:FindModifierByName("modifier_bounty_huntling_track_lua_debuff")
		ApplyDamage({victim=target, attacker=self:GetCaster(), damage=track_debuff == nil and damage or damage*track_debuff.shuriken_crit, damage_type=self:GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
	end
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("bounce_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)) do
		if enemy:HasModifier("modifier_bounty_huntling_track_lua_debuff") and not table.contains(enemy_table, tostring(enemy:entindex())) then
			table.insert(enemy_table, tostring(enemy:entindex()))
			self:LaunchShuriken(target, enemy, enemy_table)
			break
		end
	end
end

bounty_huntling_jinada_lua = bounty_huntling_jinada_lua or class(ability_lua_base)
boss_bounty_huntling_jinada_lua = boss_bounty_huntling_jinada_lua or bounty_huntling_jinada_lua
function bounty_huntling_jinada_lua:GetIntrinsicModifierName() return "modifier_orb_effect_lua" end
function bounty_huntling_jinada_lua:OnUpgrade()
	if not self:GetAutoCastState() and self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function bounty_huntling_jinada_lua:Jinada(target, isattack)
	if isattack then
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(fx, 0, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(fx)
	end
	ApplyDamage({victim=target, attacker=self:GetCaster(), damage=self:GetSpecialValueFor("bonus_damage"), damage_type=DAMAGE_TYPE_PHYSICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
	if target:IsRealHero() and target:GetPlayerID() then
		target:EmitSound("DOTA_Item.Hand_Of_Midas")
		local actual_gold_to_steal = math.min(self:GetSpecialValueFor("gold_steal"), PlayerResource:GetUnreliableGold(target:GetPlayerID()))
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(fx)
		target:ModifyGold(-actual_gold_to_steal, false, DOTA_ModifyGold_AbilityGold)
	end
end
function bounty_huntling_jinada_lua:OnOrbImpact(kv)
	if kv.fail_type ~= 0 then return end
	if kv.attacker ~= self:GetCaster() or self:GetCaster():GetTeamNumber() == kv.target:GetTeamNumber() then return end
	self:UseResources(true, true, true, true)
	self:Jinada(kv.target, true)
end
function bounty_huntling_jinada_lua:IntervalThink() if IsServer() then return FrameTime() end end
function bounty_huntling_jinada_lua:OnIntervalThink(modifier)
	if self:IsCooldownReady() then
		if self.fx_weapon1 == nil then
			self.fx_weapon1 = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_r.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.fx_weapon1, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon1", self:GetCaster():GetAbsOrigin(), true)
		end
		if self.fx_weapon2 == nil then
			self.fx_weapon2 = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_l.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.fx_weapon2, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon2", self:GetCaster():GetAbsOrigin(), true)
		end
	else
		if self.fx_weapon1 ~= nil then
			ParticleManager:DestroyParticle(self.fx_weapon1, false)
			self.fx_weapon1 = nil
		end
		if self.fx_weapon2 ~= nil then
			ParticleManager:DestroyParticle(self.fx_weapon2, false)
			self.fx_weapon2 = nil
		end
	end
end

LinkLuaModifier("modifier_bounty_huntling_wind_walk_lua", "abilities/units/bounty_huntling", LUA_MODIFIER_MOTION_NONE)

bounty_huntling_wind_walk_lua = bounty_huntling_wind_walk_lua or class(ability_lua_base)
boss_bounty_huntling_wind_walk_lua = boss_bounty_huntling_wind_walk_lua or bounty_huntling_wind_walk_lua
function bounty_huntling_wind_walk_lua:OnSpellStart()
	local invis = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible_lua", {duration=self:GetSpecialValueFor("duration"), delay=self:GetSpecialValueFor("fade_time"), reveal_ability=false, reveal_attack=false, hidden=true})
	invis:destroy_other_me()
	invis:LinkModifier(self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bounty_huntling_wind_walk_lua", {duration=self:GetSpecialValueFor("duration")}), {})
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("Hero_BountyHunter.WindWalk")
end

modifier_bounty_huntling_wind_walk_lua = modifier_bounty_huntling_wind_walk_lua or class({})
function modifier_bounty_huntling_wind_walk_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_INVISIBILITY_ATTACK_BEHAVIOR_EXCEPTION} end
function modifier_bounty_huntling_wind_walk_lua:OnCreated()
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
end
function modifier_bounty_huntling_wind_walk_lua:OnRefresh()
	self:OnCreated()
end
function modifier_bounty_huntling_wind_walk_lua:GetModifierIncomingDamage_Percentage() return -self.damage_reduction end
function modifier_bounty_huntling_wind_walk_lua:GetModifierInvisibilityAttackBehaviorException() return not self.reveal_ability and not self.reveal_attack end

LinkLuaModifier("modifier_bounty_huntling_track_lua_debuff", "abilities/units/bounty_huntling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bounty_huntling_track_lua_buff", "abilities/units/bounty_huntling", LUA_MODIFIER_MOTION_NONE)

bounty_huntling_track_lua = bounty_huntling_track_lua or class(ability_lua_base)
boss_bounty_huntling_track_lua = boss_bounty_huntling_track_lua or bounty_huntling_track_lua
function bounty_huntling_track_lua:OnSpellStart()
	if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_bounty_huntling_track_lua_debuff", {duration=self:GetSpecialValueFor("duration")})
	EmitSoundOnLocationForTeam("Hero_BountyHunter.Target", self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber())
	local fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetCursorTarget(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCursorTarget():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(fx)
end

modifier_bounty_huntling_track_lua_debuff = modifier_bounty_huntling_track_lua_debuff or class({})
function modifier_bounty_huntling_track_lua_debuff:IsPurgable() return true end
function modifier_bounty_huntling_track_lua_debuff:CheckState() return {[MODIFIER_STATE_INVISIBLE] = false} end
function modifier_bounty_huntling_track_lua_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE, MODIFIER_PROPERTY_TOOLTIP} end
function modifier_bounty_huntling_track_lua_debuff:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_bounty_huntling_track_lua_debuff:IsAura() return true end
function modifier_bounty_huntling_track_lua_debuff:GetAuraDuration() return 0.5 end
function modifier_bounty_huntling_track_lua_debuff:GetAuraRadius() return 1200 end
function modifier_bounty_huntling_track_lua_debuff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_bounty_huntling_track_lua_debuff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_bounty_huntling_track_lua_debuff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_bounty_huntling_track_lua_debuff:GetAuraEntityReject(hEntity) return hEntity:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() end
function modifier_bounty_huntling_track_lua_debuff:GetModifierAura() return "modifier_bounty_huntling_track_lua_buff" end
function modifier_bounty_huntling_track_lua_debuff:OnCreated(kv)
	self.haste_radius = self:GetAbility():GetSpecialValueFor("haste_radius")
	self.target_crit_multiplier = self:GetAbility():GetSpecialValueFor("target_crit_multiplier")
	self.shuriken_crit = self:GetAbility():GetSpecialValueFor("shuriken_crit")
	if not IsServer() then return end
	if kv.refreshed then return end
	local fx_shield = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	self:AddParticle(fx_shield, false, false, -1, false, true)
	local fx_trail = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(fx_trail, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(fx_trail, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(fx_trail, 8, Vector(1, 0, 0))
	self:AddParticle(fx_trail, false, false, -1, false, false)
	self:StartIntervalThink(0.03)
end
function modifier_bounty_huntling_track_lua_debuff:OnRefresh()
	self:OnCreated({refreshed=true})
end
function modifier_bounty_huntling_track_lua_debuff:OnIntervalThink()
	self.gold_count = (self:GetParent():IsHero() and self:GetParent().GetGold ~= nil) and self:GetParent():GetGold() or 0
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 32, 0.031, false)
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_bounty_huntling_track_lua_debuff:AddCustomTransmitterData() return {gold_count = self.gold_count} end
function modifier_bounty_huntling_track_lua_debuff:HandleCustomTransmitterData(kv)
	self.gold_count = kv.gold_count
end
function modifier_bounty_huntling_track_lua_debuff:GetModifierPreAttack_Target_CriticalStrike(kv)
	if kv.attacker ~= self:GetCaster() then return end
	return self.target_crit_multiplier
end
function modifier_bounty_huntling_track_lua_debuff:OnTooltip() return self.gold_count end

modifier_bounty_huntling_track_lua_buff = modifier_bounty_huntling_track_lua_buff or class({})
function modifier_bounty_huntling_track_lua_buff:GetEffectName() return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_haste.vpcf" end
function modifier_bounty_huntling_track_lua_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_bounty_huntling_track_lua_buff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_bounty_huntling_track_lua_buff:OnCreated()
	self.bonus_move_speed_pct = self:GetAbility():GetSpecialValueFor("bonus_move_speed_pct")
end
function modifier_bounty_huntling_track_lua_buff:OnRefresh()
	self:OnCreated()
end
function modifier_bounty_huntling_track_lua_buff:GetModifierMoveSpeedBonus_Percentage() return self.bonus_move_speed_pct end