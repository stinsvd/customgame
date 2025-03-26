LinkLuaModifier("modifier_doomling_devour_lua", "abilities/units/doomling", LUA_MODIFIER_MOTION_NONE)

doomling_devour_lua = doomling_devour_lua or class(ability_lua_base)
boss_doomling_devour_lua = boss_doomling_devour_lua or doomling_devour_lua
function doomling_devour_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doomling_devour_lua", {duration=self:GetSpecialValueFor("duration")})
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("Hero_DoomBringer.Devour")
end

modifier_doomling_devour_lua = modifier_doomling_devour_lua or class({})
function modifier_doomling_devour_lua:IsPurgable() return false end
function modifier_doomling_devour_lua:OnCreated()
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor("mana_burn_radius")
	self.mana_burn = self:GetAbility():GetSpecialValueFor("mana_burn_pct")
	self.heal = self:GetAbility():GetSpecialValueFor("heal_pct")
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("mana_burn_rate"))
end
function modifier_doomling_devour_lua:OnRefresh()
	self:OnCreated()
end
function modifier_doomling_devour_lua:OnIntervalThink()
	for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, FIND_ANY_ORDER, false)) do
		local mana_burn = enemy:GetMaxMana() * self.mana_burn / 100
		self:GetParent():GiveMana(math.min(enemy:GetMana(), mana_burn))
		enemy:SpendMana(mana_burn, self:GetAbility())
	end
	self:GetParent():Heal(self:GetParent():GetMaxHealth() * self.heal / 100, self:GetAbility())
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("Hero_DoomBringer.DevourCast")
end

LinkLuaModifier("modifier_doomling_scorched_earth_lua", "abilities/units/doomling", LUA_MODIFIER_MOTION_NONE)

doomling_scorched_earth_lua = doomling_scorched_earth_lua or class(ability_lua_base)
boss_doomling_scorched_earth_lua = boss_doomling_scorched_earth_lua or doomling_scorched_earth_lua
function doomling_scorched_earth_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doomling_scorched_earth_lua", {duration = self:GetSpecialValueFor("duration")})
end

modifier_doomling_scorched_earth_lua = modifier_doomling_scorched_earth_lua or class({})
function modifier_doomling_scorched_earth_lua:IsPurgable() return false end
function modifier_doomling_scorched_earth_lua:GetEffectName() return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf" end
function modifier_doomling_scorched_earth_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_doomling_scorched_earth_lua:IsAura() return true end
function modifier_doomling_scorched_earth_lua:GetAuraRadius() return self.radius end
function modifier_doomling_scorched_earth_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_doomling_scorched_earth_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_doomling_scorched_earth_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_doomling_scorched_earth_lua:GetModifierAura() return "modifier_break" end
function modifier_doomling_scorched_earth_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_doomling_scorched_earth_lua:OnCreated()
	self.ms_bonus = self:GetAbility():GetSpecialValueFor("bonus_movement_speed_pct")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("damage_per_second")
	self:StartIntervalThink(1)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(fx, 1, Vector(self.radius, 0, 0))
	self:AddParticle(fx, false, false, -1, false, false)
	self:GetParent():EmitSound("Hero_DoomBringer.ScorchedEarthAura")
end
function modifier_doomling_scorched_earth_lua:OnRefresh()
	self:OnCreated()
end
function modifier_doomling_scorched_earth_lua:OnIntervalThink()
	for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ApplyDamage({victim=enemy, attacker=self:GetParent(), damage=self.damage, damage_type=self:GetAbility():GetAbilityDamageType(), damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:ReleaseParticleIndex(fx)
	end
end
function modifier_doomling_scorched_earth_lua:GetModifierMoveSpeedBonus_Percentage() return self.ms_bonus end

LinkLuaModifier("modifier_doomling_infernal_blade_lua", "abilities/units/doomling", LUA_MODIFIER_MOTION_NONE)

doomling_infernal_blade_lua = doomling_infernal_blade_lua or class(ability_lua_base)
boss_doomling_infernal_blade_lua = boss_doomling_infernal_blade_lua or doomling_infernal_blade_lua
function doomling_infernal_blade_lua:GetIntrinsicModifierName() return "modifier_orb_effect_lua" end
function doomling_infernal_blade_lua:OnUpgrade()
	if not self:GetAutoCastState() and self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function doomling_infernal_blade_lua:OnOrbImpact(kv)
	if kv.fail_type ~= 0 then return end
	kv.target:AddNewModifier(self:GetCaster(), self, "modifier_doomling_infernal_blade_lua", {duration=self:GetSpecialValueFor("burn_duration")})
	kv.target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=self:GetSpecialValueFor("ministun_duration")})
end

modifier_doomling_infernal_blade_lua = modifier_doomling_infernal_blade_lua or class({})
function modifier_doomling_infernal_blade_lua:IsDebuff() return true end
function modifier_doomling_infernal_blade_lua:IsPurgable() return true end
function modifier_doomling_infernal_blade_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_doomling_infernal_blade_lua:GetEffectName() return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf" end
function modifier_doomling_infernal_blade_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_doomling_infernal_blade_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_doomling_infernal_blade_lua:OnCreated()
	self.stat_loss = self:GetAbility():GetSpecialValueFor("stat_loss")
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("burn_damage")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("burn_damage_pct")
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetParent():EmitSound("Hero_DoomBringer.InfernalBlade.Target")
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end
function modifier_doomling_infernal_blade_lua:OnRefresh()
	self:OnCreated()
end
function modifier_doomling_infernal_blade_lua:OnIntervalThink()
	ApplyDamage({victim=self:GetParent(), attacker=self:GetCaster(), damage=self.damage + (self.damage_pct/100)*self:GetParent():GetMaxHealth(), damage_type=self:GetAbility():GetAbilityDamageType(), ability=self:GetAbility()})
end
function modifier_doomling_infernal_blade_lua:GetModifierBonusStats_Strength() return -self.stat_loss end
function modifier_doomling_infernal_blade_lua:GetModifierBonusStats_Agility() return -self.stat_loss end
function modifier_doomling_infernal_blade_lua:GetModifierBonusStats_Intellect() return -self.stat_loss end

LinkLuaModifier("modifier_doomling_doom_lua", "abilities/units/doomling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doomling_doom_lua_aura", "abilities/units/doomling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doomling_doom_lua_invulnerable", "abilities/units/doomling", LUA_MODIFIER_MOTION_NONE)

doomling_doom_lua = doomling_doom_lua or class(ability_lua_base)
boss_doomling_doom_lua = boss_doomling_doom_lua or doomling_doom_lua
function doomling_doom_lua:OnSpellStart()
	self:GetCaster():Stop()
	ProjectileManager:ProjectileDodge(self:GetCaster())
	self:GetCaster():Dispell(self:GetCaster(), false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doomling_doom_lua_invulnerable", {duration=self:GetSpecialValueFor("invuln_duration")})
	self:GetCaster():EmitSound("Hero_NagaSiren.MirrorImage")
end

modifier_doomling_doom_lua_invulnerable = modifier_doomling_doom_lua_invulnerable or class({})
function modifier_doomling_doom_lua_invulnerable:IsHidden() return true end
function modifier_doomling_doom_lua_invulnerable:IsPurgable() return false end
function modifier_doomling_doom_lua_invulnerable:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_STUNNED] = true} end
function modifier_doomling_doom_lua_invulnerable:GetEffectName() return "particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf" end
function modifier_doomling_doom_lua_invulnerable:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_doomling_doom_lua_invulnerable:OnCreated()
	self.count = self:GetAbility():GetSpecialValueFor("images_count")
	self.duration = self:GetAbility():GetSpecialValueFor("illusion_duration")
	self.outgoing = self:GetAbility():GetSpecialValueFor("outgoing_damage") - 100
	self.incoming = self:GetAbility():GetSpecialValueFor("incoming_damage") - 100
end
function modifier_doomling_doom_lua_invulnerable:OnDestroy()
	if not IsServer() then return end
	if self:GetAbility().illusions ~= nil then
		for _, illusion in pairs(self:GetAbility().illusions) do
			if IsValidEntity(illusion) then
				illusion:ForceKill(false)
			end
		end
	end
	self:GetAbility().illusions = self:GetParent():CreateCreepIllusions(self:GetParent(), {outgoing_damage = self.outgoing, incoming_damage = self.incoming, duration = self.duration}, self.count, 72, true)
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_doomling_doom_lua_aura", {duration=self:GetAbility():GetSpecialValueFor("duration")})
end

modifier_doomling_doom_lua_aura = modifier_doomling_doom_lua_aura or class({})
function modifier_doomling_doom_lua_aura:IsPurgable() return false end
function modifier_doomling_doom_lua_aura:IsHidden() return true end
function modifier_doomling_doom_lua_aura:IsAura() return true end
function modifier_doomling_doom_lua_aura:GetModifierAura() return "modifier_doomling_doom_lua" end
function modifier_doomling_doom_lua_aura:GetAuraRadius() return 900 end
function modifier_doomling_doom_lua_aura:GetAuraDuration() return 1 end
function modifier_doomling_doom_lua_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_doomling_doom_lua_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_doomling_doom_lua_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_doomling_doom_lua_aura:GetAuraEntityReject(hEntity)
	if not IsServer() then return true end
	return hEntity:GetOwner() ~= self:GetParent() and hEntity ~= self:GetParent()
end

modifier_doomling_doom_lua = modifier_doomling_doom_lua or class({})
function modifier_doomling_doom_lua:IsPurgable() return false end
function modifier_doomling_doom_lua:CheckState() if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then return {[MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_PASSIVES_DISABLED] = true} end end
function modifier_doomling_doom_lua:IsAura() return true end
function modifier_doomling_doom_lua:GetModifierAura() return self:GetName() end
function modifier_doomling_doom_lua:GetAuraRadius() return self.radius end
function modifier_doomling_doom_lua:GetAuraDuration() return 0.5 end
function modifier_doomling_doom_lua:GetAuraSearchTeam() return self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() and DOTA_UNIT_TARGET_TEAM_ENEMY or DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_doomling_doom_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_doomling_doom_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_doomling_doom_lua:GetStatusEffectName() return "particles/status_fx/status_effect_doom.vpcf" end
function modifier_doomling_doom_lua:StatusEffectPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_doomling_doom_lua:GetEffectName() return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf" end
function modifier_doomling_doom_lua:GetAuraEntityReject(hEntity) return hEntity == self:GetParent() end
function modifier_doomling_doom_lua:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self:StartIntervalThink(1)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_doom_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(fx, 1, Vector(self.radius, 0, 0))
	self:AddParticle(fx, false, false, -1, false, false)
	self:GetParent():EmitSound("Hero_DoomBringer.Doom")
end
function modifier_doomling_doom_lua:OnRefresh()
	self:OnCreated()
end
function modifier_doomling_doom_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("Hero_DoomBringer.Doom")
end
function modifier_doomling_doom_lua:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility()})
end