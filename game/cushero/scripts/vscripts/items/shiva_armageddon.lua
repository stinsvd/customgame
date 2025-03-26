LinkLuaModifier("modifier_shiva_armageddon_lua", "items/shiva_armageddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shiva_armageddon_aura_debuff_lua", "items/shiva_armageddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shiva_armageddon_blast_lua", "items/shiva_armageddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shiva_armageddon_weak_lua", "items/shiva_armageddon", LUA_MODIFIER_MOTION_NONE)

item_shiva_armageddon_lua = item_shiva_armageddon_lua or class(ability_lua_base)
function item_shiva_armageddon_lua:GetIntrinsicModifierName() return "modifier_shiva_armageddon_lua" end
function item_shiva_armageddon_lua:OnSpellStart()
	local fx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(fx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, Vector(self:GetSpecialValueFor("blast_radius"), (self:GetSpecialValueFor("blast_radius") / self:GetSpecialValueFor("blast_speed")) * 1.33, self:GetSpecialValueFor("blast_speed")))
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("DOTA_Item.ShivasGuard.Activate")
	local freezing_field_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(freezing_field_pfx, 1, Vector(self:GetSpecialValueFor("blast_radius"), self:GetSpecialValueFor("blast_radius"), 1))
	self:GetCaster():EmitSound("hero_Crystal.freezingField.wind")
	local targets_hit = {}
	local current_radius = 0
	local quartal = -1
	Timers:CreateTimer({endTime=0.1, callback=function()
		ParticleManager:SetParticleControl(freezing_field_pfx, 0, self:GetCaster():GetAbsOrigin())
		AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), current_radius, 2, false)
		current_radius = current_radius + self:GetSpecialValueFor("blast_speed") * 0.1
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, current_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if not table.contains(targets_hit, enemy:entindex()) then
				local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
				ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
				ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(hit_pfx)
				local damage = self:GetSpecialValueFor("blast_damage")
				if enemy:IsIllusion() then
					damage = damage * self:GetSpecialValueFor("illusion_multiplier_pct") / 100
				end
				ApplyDamage({attacker=self:GetCaster(), victim=enemy, damage=self:GetSpecialValueFor("blast_damage"), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_shiva_armageddon_blast_lua", {duration=self:GetSpecialValueFor("blast_debuff_duration")})
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_shiva_armageddon_weak_lua", {duration=self:GetSpecialValueFor("resist_debuff_duration")})
				table.insert(targets_hit, enemy:entindex())
			end
		end
		quartal = quartal<3 and quartal+1 or 0
		local a = RandomInt(0,90) + quartal*90
		local r = RandomInt(self:GetSpecialValueFor("explosion_min_range"), current_radius)
		local explosion_point = self:GetCaster():GetAbsOrigin() + (Vector(math.cos(a), math.sin(a), 0):Normalized() * r)
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), explosion_point, nil, self:GetSpecialValueFor("explosion_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			local damage = self:GetSpecialValueFor("explosion_damage")
			if enemy:IsIllusion() then
				damage = damage * self:GetSpecialValueFor("illusion_multiplier_pct") / 100
			end
			ApplyDamage({attacker=self:GetCaster(), victim=enemy, damage=damage+self:GetSpecialValueFor("explosion_damage_per_int")*self:GetCaster():GetIntellect(false), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self})
		end
		local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(hit_pfx, 0, explosion_point)
		ParticleManager:ReleaseParticleIndex(hit_pfx)
		EmitSoundOnLocationWithCaster(explosion_point, "hero_Crystal.freezingField.explosion", self:GetCaster())
		if current_radius >= self:GetSpecialValueFor("blast_radius") then
			ParticleManager:DestroyParticle(freezing_field_pfx, false)
			ParticleManager:ReleaseParticleIndex(freezing_field_pfx)
			self:GetCaster():StopSound("hero_Crystal.freezingField.wind")
			return nil
		end
		return 0.1
	end}, nil, self)
end

modifier_shiva_armageddon_lua = modifier_shiva_armageddon_lua or class({})
function modifier_shiva_armageddon_lua:IsHidden() return true end
function modifier_shiva_armageddon_lua:IsPurgable() return false end
function modifier_shiva_armageddon_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_shiva_armageddon_lua:IsAura() return true end
function modifier_shiva_armageddon_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_shiva_armageddon_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_shiva_armageddon_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_shiva_armageddon_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_shiva_armageddon_lua:GetModifierAura() return "modifier_shiva_armageddon_aura_debuff_lua" end
function modifier_shiva_armageddon_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_shiva_armageddon_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_shiva_armageddon_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_shiva_armageddon_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_shiva_armageddon_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_shiva_armageddon_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_shiva_armageddon_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end

modifier_shiva_armageddon_aura_debuff_lua = modifier_shiva_armageddon_aura_debuff_lua or class({})
function modifier_shiva_armageddon_aura_debuff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_shiva_armageddon_aura_debuff_lua:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.attack_speed_slow = self:GetAbility():GetSpecialValueFor("aura_attack_speed")
	self.hp_degen = self:GetAbility():GetSpecialValueFor("hp_regen_degen_aura")
end
function modifier_shiva_armageddon_aura_debuff_lua:GetModifierAttackSpeedBonus_Constant() return -self.attack_speed_slow end
function modifier_shiva_armageddon_aura_debuff_lua:GetModifierHPRegenAmplify_Percentage() return -self.hp_degen end
function modifier_shiva_armageddon_aura_debuff_lua:GetModifierLifestealRegenAmplify_Percentage() return -self.hp_degen end

modifier_shiva_armageddon_blast_lua = modifier_shiva_armageddon_blast_lua or class({})
function modifier_shiva_armageddon_blast_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_shiva_armageddon_blast_lua:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.slow = self:GetAbility():GetSpecialValueFor("blast_movement_speed")
end
function modifier_shiva_armageddon_blast_lua:GetModifierMoveSpeedBonus_Percentage() return self.slow end

modifier_shiva_armageddon_weak_lua = modifier_shiva_armageddon_weak_lua or class({})
function modifier_shiva_armageddon_weak_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_shiva_armageddon_weak_lua:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
end
function modifier_shiva_armageddon_weak_lua:GetModifierIncomingDamage_Percentage(kv)
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL then return end
	return self.spell_amp
end