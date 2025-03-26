LinkLuaModifier("modifier_dark_willow_shadow_realm_lua", "abilities/heroes/dark_willow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dark_willow_shadow_realm_lua_buff", "abilities/heroes/dark_willow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dark_willow_shadow_realm_lua_throwing_shade_lua", "abilities/heroes/dark_willow", LUA_MODIFIER_MOTION_NONE)

dark_willow_shadow_realm_lua = dark_willow_shadow_realm_lua or class(ability_lua_base)
function dark_willow_shadow_realm_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_dark_willow_shadow_realm_lua", {duration=self:GetSpecialValueFor("duration")})
end

modifier_dark_willow_shadow_realm_lua = modifier_dark_willow_shadow_realm_lua or class({})
function modifier_dark_willow_shadow_realm_lua:IsPurgable() return false end
function modifier_dark_willow_shadow_realm_lua:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_EVENT_ON_ATTACK} end
function modifier_dark_willow_shadow_realm_lua:CheckState() return {[MODIFIER_STATE_ATTACK_IMMUNE] = true, [MODIFIER_STATE_UNTARGETABLE_ENEMY] = true} end
function modifier_dark_willow_shadow_realm_lua:GetStatusEffectName() return "particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf" end
function modifier_dark_willow_shadow_realm_lua:IsAura() return true end
function modifier_dark_willow_shadow_realm_lua:GetAuraDuration() return self.aura_linger end
function modifier_dark_willow_shadow_realm_lua:GetAuraRadius() return self.aura_radius end
function modifier_dark_willow_shadow_realm_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_dark_willow_shadow_realm_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_dark_willow_shadow_realm_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_NONE end
function modifier_dark_willow_shadow_realm_lua:GetModifierAura() return "modifier_dark_willow_shadow_realm_lua_throwing_shade_lua" end
function modifier_dark_willow_shadow_realm_lua:OnCreated()
	self:OnRefresh()
	if not IsServer() then return end
	if self:GetParent():GetAggroTarget() then
		self:GetParent():Stop()
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	self:AddParticle(fx, false, false, -1, false, false)
	self:GetParent():EmitSound("Hero_DarkWillow.Shadow_Realm")
end
function modifier_dark_willow_shadow_realm_lua:OnRefresh()
	self.bonus_range = self:GetAbility():GetSpecialValueFor("attack_range_bonus")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("damage")
	self.bonus_max = self:GetAbility():GetSpecialValueFor("max_damage_duration")
	self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
	self.aura_linger = self:GetAbility():GetSpecialValueFor("aura_linger")
	if not IsServer() then return end
	ProjectileManager:ProjectileDodge(self:GetParent())
	self:SetStackCount(self:GetAbility():GetSpecialValueFor("max_attacks"))
end
function modifier_dark_willow_shadow_realm_lua:OnStackCountChanged(iStackCount)
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end
function modifier_dark_willow_shadow_realm_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("Hero_DarkWillow.Shadow_Realm")
end
function modifier_dark_willow_shadow_realm_lua:GetModifierAttackRangeBonus() return self.bonus_range end
function modifier_dark_willow_shadow_realm_lua:GetModifierProjectileName() return "particles/units/heroes/hero_dark_willow/dark_willow_shadow_attack_dummy.vpcf" end
function modifier_dark_willow_shadow_realm_lua:OnAttack(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	local time = math.min(self:GetElapsedTime()/self.bonus_max, 1)
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_dark_willow_shadow_realm_lua_buff", {duration = self:GetDuration(), record = kv.record, damage = self.bonus_damage, time = time, target = kv.target:entindex()})
    self:DecrementStackCount()
	self:GetParent():EmitSound("Hero_DarkWillow.Shadow_Realm.Attack")
end

modifier_dark_willow_shadow_realm_lua_buff = modifier_dark_willow_shadow_realm_lua_buff or class({})
function modifier_dark_willow_shadow_realm_lua_buff:IsHidden() return true end
function modifier_dark_willow_shadow_realm_lua_buff:IsPurgable() return false end
function modifier_dark_willow_shadow_realm_lua_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_dark_willow_shadow_realm_lua_buff:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL, MODIFIER_EVENT_ON_PROJECTILE_DODGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE} end
function modifier_dark_willow_shadow_realm_lua_buff:OnCreated(kv)
	if not IsServer() then return end
	self.damage = kv.damage
	self.record = kv.record
	self.time = kv.time
	self.target = EntIndexToHScript(kv.target)
	self.target_pos = self.target:GetOrigin()
	self.target_prev = self.target_pos
	self.effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_shadow_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0, 0, 0), true)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:SetParticleControl(self.effect_cast, 2, Vector(self:GetParent():GetProjectileSpeed(), 0, 0))
	ParticleManager:SetParticleControl(self.effect_cast, 5, Vector(self.time, 0, 0))
end
function modifier_dark_willow_shadow_realm_lua_buff:OnAttackRecordDestroy(kv)
	if not IsServer() then return end
	if kv.record ~= self.record then return end
	ParticleManager:DestroyParticle(self.effect_cast, false)
	ParticleManager:ReleaseParticleIndex(self.effect_cast)
	self:Destroy()
end
function modifier_dark_willow_shadow_realm_lua_buff:GetModifierProcAttack_BonusDamage_Magical(kv)
	if kv.record ~= self.record then return end
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, kv.target, self.damage * self.time, self:GetParent():GetPlayerOwner())
	self:GetParent():EmitSound("Hero_DarkWillow.Shadow_Realm.Damage")
	ParticleManager:DestroyParticle(self.effect_cast, false)
	ParticleManager:ReleaseParticleIndex(self.effect_cast)
	return self.damage * self.time
end
function modifier_dark_willow_shadow_realm_lua_buff:OnProjectileDodge(kv)
	if not IsServer() then return end
	if kv.target~=self.target then return end
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.target, PATTACH_CUSTOMORIGIN, "attach_hitloc", self.target_prev, true)
	ParticleManager:DestroyParticle(self.effect_cast, true)
	ParticleManager:ReleaseParticleIndex(self.effect_cast)
end
function modifier_dark_willow_shadow_realm_lua_buff:GetModifierBaseAttack_BonusDamage()
	if not IsServer() then return end
	self.target_prev = self.target_pos
	self.target_pos = self.target:GetOrigin()
	return 0
end

modifier_dark_willow_shadow_realm_lua_throwing_shade_lua = modifier_dark_willow_shadow_realm_lua_throwing_shade_lua or class({})
function modifier_dark_willow_shadow_realm_lua_throwing_shade_lua:IsPurgable() return false end
function modifier_dark_willow_shadow_realm_lua_throwing_shade_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_dark_willow_shadow_realm_lua_throwing_shade_lua:OnCreated()
	self.aura_damage_pct = self:GetAbility():GetSpecialValueFor("aura_damage_pct")
	self.max_damage_duration = self:GetAbility():GetSpecialValueFor("max_damage_duration")
end
function modifier_dark_willow_shadow_realm_lua_throwing_shade_lua:OnRefresh()
	self:OnCreated()
end
function modifier_dark_willow_shadow_realm_lua_throwing_shade_lua:GetModifierIncomingDamage_Percentage(kv)
	if not IsServer() then return end
	if kv.attacker:GetPlayerOwnerID() ~= self:GetCaster():GetPlayerOwnerID() then return end
	local buff = self:GetCaster():FindModifierByName("modifier_dark_willow_shadow_realm_lua")
	local time = buff ~= nil and math.min(buff:GetElapsedTime()/self.max_damage_duration, 1) or 0
	return self.aura_damage_pct * time
end