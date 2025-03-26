LinkLuaModifier("modifier_ogre_magi_multicast_lua", "abilities/heroes/ogre_magi", LUA_MODIFIER_MOTION_NONE)

ogre_magi_multicast_lua = ogre_magi_multicast_lua or class(ability_lua_base)
function ogre_magi_multicast_lua:GetIntrinsicModifierName() return "modifier_ogre_magi_multicast_lua" end

modifier_ogre_magi_multicast_lua = modifier_ogre_magi_multicast_lua or class({})
function modifier_ogre_magi_multicast_lua:IsHidden() return true end
function modifier_ogre_magi_multicast_lua:IsPurgable() return false end
function modifier_ogre_magi_multicast_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE} end
function modifier_ogre_magi_multicast_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.unit:PassivesDisabled() or not kv.ability:IsMulticastable() then return end
	local max_multicast = 0
	if RandomInt(0, 100) <= self:GetAbility():GetSpecialValueFor("multicast_4_times") then max_multicast = 4
	elseif RandomInt(0, 100) <= self:GetAbility():GetSpecialValueFor("multicast_3_times") then max_multicast = 3
	elseif RandomInt(0, 100) <= self:GetAbility():GetSpecialValueFor("multicast_2_times") then max_multicast = 2
	else return end
	local multicast = 1
	local pos = kv.ability:GetCursorPosition()
	if pos == Vector(0, 0, 0) then
		pos = kv.unit:GetCursorPosition()
	end
	local delay = (kv.ability:IsItem() or table.contains({"ogre_magi_bloodlust"}, kv.ability:GetAbilityName())) and kv.target ~= nil and 0 or self:GetAbility():GetSpecialValueFor("multicast_delay")
	Timers:CreateTimer({endTime=delay, callback=function()
		multicast = multicast + 1
		local target = kv.target
		if (kv.ability:IsItem() or table.contains({"ogre_magi_ignite", "ogre_magi_bloodlust"}, kv.ability:GetAbilityName())) and kv.target ~= nil then
			target = table.choice(FindUnitsInRadius(kv.unit:GetTeamNumber(), kv.unit:GetAbsOrigin(), nil, kv.ability:GetEffectiveCastRange(pos, target)+self:GetAbility():GetSpecialValueFor("multicast_buffer_range"), kv.ability:GetAbilityTargetTeam(), kv.ability:GetAbilityTargetType(), kv.ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false))
		end
		kv.unit:SetCursorCastTarget(target)
		kv.unit:SetCursorPosition(pos)
		kv.ability:OnSpellStart()
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, kv.unit)
		ParticleManager:SetParticleControl(fx, 1, Vector(multicast, multicast==max_multicast and 1 or 2, 0))
		ParticleManager:ReleaseParticleIndex(fx)
		kv.unit:EmitSound("Hero_OgreMagi.Fireblast.x"..math.min(math.max(multicast-1, 1), 3))
		if multicast < max_multicast then return delay end
		return nil
	end}, nil, self)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, kv.unit)
	ParticleManager:SetParticleControl(fx, 1, Vector(multicast, multicast==max_multicast and 1 or 2, 0))
	ParticleManager:ReleaseParticleIndex(fx)
end
function modifier_ogre_magi_multicast_lua:GetModifierOverrideAbilitySpecial(kv)
	if kv.ability ~= self:GetAbility() then return end
	return BoolToNum(string.find(kv.ability_special_value, "multicast_%d_times") ~= nil)
end
function modifier_ogre_magi_multicast_lua:GetModifierOverrideAbilitySpecialValue(kv)
	if kv.ability ~= self:GetAbility() or string.find(kv.ability_special_value, "multicast_%d_times") == nil then return end
	local kv = kv.ability:GetLevelSpecialValueNoOverride(kv.ability_special_value, kv.ability_special_level)
	return kv + math.floor(self:GetParent():GetStrength()*self:GetAbility():GetSpecialValueFor("strength_mult"))
end

LinkLuaModifier("modifier_ogre_magi_dumb_luck_lua", "abilities/heroes/ogre_magi", LUA_MODIFIER_MOTION_NONE)

ogre_magi_dumb_luck_lua = ogre_magi_dumb_luck_lua or class(ability_lua_base)
function ogre_magi_dumb_luck_lua:GetIntrinsicModifierName() return "modifier_ogre_magi_dumb_luck_lua" end

modifier_ogre_magi_dumb_luck_lua = modifier_ogre_magi_dumb_luck_lua or class({})
function modifier_ogre_magi_dumb_luck_lua:IsHidden() return true end
function modifier_ogre_magi_dumb_luck_lua:IsPurgable() return false end
function modifier_ogre_magi_dumb_luck_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_ogre_magi_dumb_luck_lua:OnCreated()
	if not IsServer() then return end
	self:GetParent():UpdatePrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
end
function modifier_ogre_magi_dumb_luck_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():ResetPrimaryAttribute()
end
function modifier_ogre_magi_dumb_luck_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("mana_per_str") * self:GetParent():GetStrength() - GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA) * self:GetParent():GetIntellect(false) end
function modifier_ogre_magi_dumb_luck_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen_per_str") * self:GetParent():GetStrength() - GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN) * self:GetParent():GetIntellect(false) end