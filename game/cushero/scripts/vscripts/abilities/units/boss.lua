LinkLuaModifier("modifier_boss_ability", "abilities/units/boss", LUA_MODIFIER_MOTION_NONE)

boss_ability = boss_ability or class(ability_lua_base)
function boss_ability:GetIntrinsicModifierName() return "modifier_boss_ability" end

modifier_boss_ability = modifier_boss_ability or class({})
function modifier_boss_ability:IsHidden() return true end
function modifier_boss_ability:IsPurgable() return false end
function modifier_boss_ability:CheckState() return {[MODIFIER_STATE_CANNOT_MISS] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_UNSLOWABLE] = true} end
function modifier_boss_ability:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_boss_ability:IsAura() return true end
function modifier_boss_ability:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("true_sight_radius") end
function modifier_boss_ability:GetModifierAura() return "modifier_truesight" end
function modifier_boss_ability:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_boss_ability:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_boss_ability:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER end
function modifier_boss_ability:GetAuraDuration() return 0.5 end
function modifier_boss_ability:OnCreated()
	if not IsServer() then return end
	Timers:CreateTimer({endTime=0.1, callback=function()
		self:GetParent().spawnpos = self:GetParent():GetAbsOrigin()
	end}, nil, self)
end
function modifier_boss_ability:OnDeath(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.unit:IsIllusion() then return end
	local npc_info = {name=kv.unit:GetUnitName(), position=kv.unit.spawnpos}
	Timers:CreateTimer({endTime=BOSS_RESPAWN, callback=function()
		CreateUnitByNameAsync(npc_info["name"], npc_info["position"], true, nil, nil, DOTA_TEAM_NEUTRALS, function(unit) end)
	end}, nil, self)
end
function modifier_boss_ability:GetModifierPureResistanceBonus() return self:GetAbility():GetSpecialValueFor("pure_resistance") end

LinkLuaModifier("modifier_idle_stone", "abilities/units/boss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_idle_stone_active", "abilities/units/boss", LUA_MODIFIER_MOTION_NONE)

idle_stone = idle_stone or class(ability_lua_base)
function idle_stone:GetIntrinsicModifierName() return "modifier_idle_stone" end

modifier_idle_stone = modifier_idle_stone or class({})
function modifier_idle_stone:IsHidden() return true end
function modifier_idle_stone:IsPurgable() return false end
function modifier_idle_stone:OnCreated()
	self:OnRefresh()
	if not IsServer() then return end
	self:StartIntervalThink(3)
end
function modifier_idle_stone:OnRefresh()
	self.fade_delay = self:GetAbility():GetSpecialValueFor("fade_delay")
end
function modifier_idle_stone:OnIntervalThink()
	if self:GetParent():GetAggroTarget() == nil and self:GetParent().combotarget == nil and (self:GetParent().spawnpos == nil or CalculateDistance(self:GetParent().spawnpos, self:GetParent():GetAbsOrigin()) < 100) then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_idle_stone_active", {})
		self:StartIntervalThink(-1)
	end
end

modifier_idle_stone_active = modifier_idle_stone_active or class({})
function modifier_idle_stone_active:IsPurgable() return false end
function modifier_idle_stone_active:GetStatusEffectName() return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf" end
function modifier_idle_stone_active:StatusEffectPriority() return MODIFIER_PRIORITY_ULTRA end
function modifier_idle_stone_active:CheckState() return {[MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_BLOCK_DISABLED] = true, [MODIFIER_STATE_EVADE_DISABLED] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true} end
function modifier_idle_stone_active:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end
function modifier_idle_stone_active:OnCreated()
	self:OnRefresh()
	if not IsServer() then return end
	self:OnIntervalThink()
end
function modifier_idle_stone_active:OnRefresh()
	self.health_regen_pct = self:GetAbility():GetSpecialValueFor("health_regen_pct")
	self.destroy_damage = self:GetAbility():GetSpecialValueFor("destroy_damage")
	self.destroy_damage_reset = self:GetAbility():GetSpecialValueFor("destroy_damage_reset")
end
function modifier_idle_stone_active:OnIntervalThink()
	self:SetStackCount(self.destroy_damage)
	self:StartIntervalThink(-1)
end
function modifier_idle_stone_active:OnDestroy()
	if not IsServer() then return end
	local modifier = self:GetParent():FindModifierByName("modifier_idle_stone")
	if modifier then
		modifier:StartIntervalThink(modifier.fade_delay)
	end
end
function modifier_idle_stone_active:OnStackCountChanged(iStackCount)
	if not IsServer() then return end
	if iStackCount ~= self:GetStackCount() and self:GetStackCount() <= 0 then
		self:Destroy()
	end
end
function modifier_idle_stone_active:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() then return end
	self:StartIntervalThink(self.destroy_damage_reset)
	self:SetStackCount(math.max(math.ceil(self:GetStackCount() - kv.original_damage), 0))
end
function modifier_idle_stone_active:GetAbsoluteNoDamageMagical() return 1 end
function modifier_idle_stone_active:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_idle_stone_active:GetAbsoluteNoDamagePure() return 1 end
function modifier_idle_stone_active:GetModifierHealthRegenPercentage() return self.health_regen_pct end