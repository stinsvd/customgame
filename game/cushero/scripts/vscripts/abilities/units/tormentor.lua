LinkLuaModifier("modifier_tormentor_reflecting_shield_lua", "abilities/units/tormentor", LUA_MODIFIER_MOTION_NONE)

tormentor_reflecting_shield_lua = tormentor_reflecting_shield_lua or class(ability_lua_base)
function tormentor_reflecting_shield_lua:Spawn()
	if not IsServer() then return end
	self:SetLevel(1)
end
function tormentor_reflecting_shield_lua:GetIntrinsicModifierName() return "modifier_tormentor_reflecting_shield_lua" end

modifier_tormentor_reflecting_shield_lua = modifier_tormentor_reflecting_shield_lua or class({})
function modifier_tormentor_reflecting_shield_lua:IsHidden() return true end
function modifier_tormentor_reflecting_shield_lua:IsPurgable() return false end
function modifier_tormentor_reflecting_shield_lua:GetEffectName() return "particles/neutral_fx/miniboss_shield.vpcf" end
function modifier_tormentor_reflecting_shield_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_tormentor_reflecting_shield_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT} end
function modifier_tormentor_reflecting_shield_lua:OnCreated()
	if not IsServer() then return end
	self.shield = self:GetAbility():GetSpecialValueFor("damage_absorb")
	self:GetParent():EmitSound("Miniboss.Tormenter.Spawn")
	self:StartIntervalThink(0.1)
end
function modifier_tormentor_reflecting_shield_lua:OnIntervalThink()
	self.shield = math.min(self.shield + (self:GetAbility():GetSpecialValueFor("regen_per_second") * 0.1), self:GetAbility():GetSpecialValueFor("damage_absorb"))
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_tormentor_reflecting_shield_lua:AddCustomTransmitterData() return {shield = self.shield} end
function modifier_tormentor_reflecting_shield_lua:HandleCustomTransmitterData(kv)
	self.shield = kv.shield
end
function modifier_tormentor_reflecting_shield_lua:GetModifierIncomingDamageConstant(kv)
	if not IsServer() then return self.shield end
	if kv.target ~= self:GetParent() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and UnitFilter(kv.attacker, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, kv.target:GetTeamNumber()) == UF_SUCCESS then
		local heroes = FindUnitsInRadius(kv.target:GetTeamNumber(), kv.target:GetAbsOrigin(), nil, self:GetAbility():GetEffectiveCastRange(kv.target:GetAbsOrigin(), kv.target), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
		local enemies = FindUnitsInRadius(kv.target:GetTeamNumber(), kv.target:GetAbsOrigin(), nil, self:GetAbility():GetEffectiveCastRange(kv.target:GetAbsOrigin(), kv.target), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		if not table.contains(enemies, kv.attacker) then table.insert(enemies, kv.attacker) end
		for _, unit in pairs(enemies) do
			ApplyDamage({victim=unit, attacker=kv.target, damage=((kv.original_damage*self:GetAbility():GetSpecialValueFor("reflection")/100)/math.max(#heroes, 1)) * (unit:IsIllusion() and 2 or 1), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_REFLECTION, ability=self:GetAbility()})
			local fx = ParticleManager:CreateParticle("particles/neutral_fx/miniboss_damage_reflect.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.target)
			ParticleManager:SetParticleControl(fx, 0, kv.target:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(fx, 1, unit, PATTACH_POINT_FOLLOW, "attach_attack1", unit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(fx, 2, kv.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(fx)
			unit:EmitSound("Miniboss.Tormenter.Target")
		end
	end
	local fx = ParticleManager:CreateParticle("particles/neutral_fx/miniboss_damage_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.target)
	ParticleManager:ReleaseParticleIndex(fx)
	kv.target:EmitSound("Miniboss.Tormenter.Reflect")
	local health = self.shield
	self.shield = math.max(self.shield - kv.damage, 0)
	return health > kv.damage and (-kv.damage) or (-health)
end

LinkLuaModifier("modifier_tormentor_harden_skin_lua", "abilities/units/tormentor", LUA_MODIFIER_MOTION_NONE)

tormentor_harden_skin_lua = tormentor_harden_skin_lua or class(ability_lua_base)
function tormentor_harden_skin_lua:GetIntrinsicModifierName() return "modifier_tormentor_harden_skin_lua" end

modifier_tormentor_harden_skin_lua = modifier_tormentor_harden_skin_lua or class({})
function modifier_tormentor_harden_skin_lua:IsHidden() return true end
function modifier_tormentor_harden_skin_lua:IsPurgable() return false end
function modifier_tormentor_harden_skin_lua:CheckState() return {[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true} end
function modifier_tormentor_harden_skin_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BASE_PERCENTAGE} end
function modifier_tormentor_harden_skin_lua:OnCreated()
	self.armor = GetUnitKeyValuesByName(self:GetParent():GetUnitName())["ArmorPhysical"]
end
function modifier_tormentor_harden_skin_lua:GetModifierPhysicalArmorBonus() return self.armor end
function modifier_tormentor_harden_skin_lua:GetModifierPhysicalArmorBase_Percentage() return 0 end