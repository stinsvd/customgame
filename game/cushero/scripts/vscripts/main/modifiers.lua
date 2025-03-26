modifier_global_override_lua = modifier_global_override_lua or class({})
function modifier_global_override_lua:IsHidden() return true end
function modifier_global_override_lua:IsPurgable() return false end
function modifier_global_override_lua:RemoveOnDeath() return IsInToolsMode() end
function modifier_global_override_lua:GetAttributes() return not IsInToolsMode() and MODIFIER_ATTRIBUTE_PERMANENT or MODIFIER_ATTRIBUTE_NONE end
function modifier_global_override_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DIRECT_MODIFICATION, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE} end
function modifier_global_override_lua:OnCreated()
	self.abilities = {
		["ability_lamp_use"] = {"active_duration", "inactive_duration", "AbilityChannelTime"},
		["rattletrap_armor_power"] = {"damage_per_armor"},
		["death_prophet_witchcraft"] = {"movement_speed_pct_per_level", "cooldown_reduction_pct_per_level"},
		["drow_ranger_trueshot"] = {"trueshot_agi_bonus_self", "trueshot_agi_bonus_allies"},
		["leshrac_defilement"] = {"aoe_per_int"},
		["lycan_apex_predator"] = {"damage_amp_per_level"},
		["phantom_assassin_immaterial"] = {"evasion_per_level"},
		["razor_unstable_current"] = {"movespeed_per_level_pct"},
		["razor_dynamo"] = {"spell_amp_mult"},
		["rubick_might_and_magus"] = {"bonus_damage_pct", "bonus_damage_pct_tooltip", "magic_resist_pct", "magic_resist_pct_tooltip"},
	}
	if not IsServer() then return end
	self.refreshing_modifiers = {
		"modifier_rattletrap_armor_power",
		"modifier_death_prophet_witchcraft",
		"modifier_drow_ranger_trueshot",
		"modifier_lycan_apex_predator",
		"modifier_leshrac_defilement",
		"modifier_phantom_assassin_immaterial",
		"modifier_razor_unstable_current",
		"modifier_rubick_might_and_magus",
	}
	self.last_refresh = 0
	self:StartIntervalThink(0.15)
	self:OnIntervalThink()
end
function modifier_global_override_lua:OnIntervalThink()
	local target = self:GetParent():GetCursorCastTarget()
	self:GetParent()._cast_target = target and target:entindex() or -1
	self:GetParent()._cast_position = self:GetParent():GetCursorPosition()
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	local now = GameRules:GetGameTime()
	if now-self.last_refresh > 0.5 then
		self.last_refresh = now
		for _, modifier_name in pairs(self.refreshing_modifiers) do
			local modifier = self:GetParent():FindModifierByName(modifier_name)
			if modifier then
				local caster = modifier:GetCaster()
				local ability = modifier:GetAbility()
				modifier:Destroy()
				modifier = self:GetParent():AddNewModifier(caster, ability, modifier_name, {})
			end
		end
	end
end
function modifier_global_override_lua:AddCustomTransmitterData()
	local position = self:GetParent()._cast_position
	return {target = self:GetParent()._cast_target, last_target = self:GetParent()._last_cast_target, target_x = position.x, target_y = position.y, target_z = position.z}
end
function modifier_global_override_lua:HandleCustomTransmitterData(kv)
	self:GetParent()._cast_target = kv.target
	self:GetParent()._last_cast_target = kv.last_target or -1
	self:GetParent()._cast_position = Vector(target_x, target_y, target_z)
end
function modifier_global_override_lua:GetModifierOverrideAbilitySpecial(kv)
	if not kv.ability then return 0 end
	local info = self.abilities[kv.ability:GetAbilityName()]
	if info == nil then return end
	if info == "all" then
		return 1
	end
	return BoolToNum(table.contains(info, kv.ability_special_value))
end
function modifier_global_override_lua:GetModifierOverrideAbilitySpecialValue(kv)
	if not kv.ability then return 0 end
	local ability_name = kv.ability:GetAbilityName()
	local info = self.abilities[ability_name]
	if info == nil then return 0 end
	local caster = kv.ability:GetCaster()
	local current_target = kv.ability:GetCursorTarget()
	local last_target = kv.ability:GetLastCursorTarget()
	local target = (IsServer() and {current_target} or {current_target or last_target})[1]
	local point = kv.ability:GetCursorPosition()
	if ability_name == "ability_lamp_use" then
		local unit_info = target and GetUnitKeyValuesByName(target:GetUnitName()) or nil
		if target ~= nil and unit_info ~= nil and unit_info["CaptureData"] ~= nil and unit_info["CaptureData"]["values"] ~= nil and unit_info["CaptureData"]["values"][kv.ability_special_value] ~= nil then
			return GetKVValue(unit_info["CaptureData"]["values"][kv.ability_special_value], kv.ability_special_level+1)
		end
	elseif kv.ability:IsInnateAbility() or kv.ability:IsFacetAbility() then
		local stackers = {
			["per_armor"] = function() return caster:GetPhysicalArmorValue(false) end,
			["per_level"] = function() return caster:GetLevel() end,
			["per_int"] = function() return caster:GetIntellect(false) end,
			["per_agi"] = function() return caster:GetAgility() end,
			["agi"] = function() return caster:GetAgility() end,
		}
		local abilityname_stackers = {
			["razor_dynamo"] = {
				["spell_amp_mult"] = function() return caster:GetBonusAttackDamage() end,
			},
		}
		local divisors = {
			["razor_dynamo"] = {["spell_amp_mult"] = "spell_amp_damage_divisor"}
		}
		local stacker = stackers[kv.ability_special_value]
		if stacker == nil then
			if abilityname_stackers[ability_name] ~= nil then
				stacker = abilityname_stackers[ability_name][kv.ability_special_value]
			end
		end
		if stacker == nil then
			for pattern, func in pairs(stackers) do
				if string.find(kv.ability_special_value, pattern) ~= nil then
					stacker = func
					break
				end
			end
		end
		if stacker ~= nil then
			local max_value = kv.ability:GetLevelSpecialValueFor(kv.ability_special_value.."_limit", kv.ability_special_level)
			if max_value then
				local divisor = divisors[ability_name] ~= nil and divisors[ability_name][kv.ability_special_value] or 1
				local base_multiplier = kv.ability:GetLevelSpecialValueNoOverride(kv.ability_special_value, kv.ability_special_level)
				local stacks = stacker()/divisor
				if base_multiplier*stacks > max_value then
					return max_value/stacks
				end
			end
		end
	end
	return kv.ability:GetLevelSpecialValueNoOverride(kv.ability_special_value, kv.ability_special_level)
end
function modifier_global_override_lua:GetModifierMagicalResistanceDirectModification() return math.min(MAX_MAGICAL_RESISTANCE_PER_INTELLIGENCE-self:GetParent():GetIntellect(false) * GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESIST), 0) end

modifier_fountain_aura_lua = modifier_fountain_aura_lua or class({})
function modifier_fountain_aura_lua:IsHidden() return true end
function modifier_fountain_aura_lua:IsAura() return true end
function modifier_fountain_aura_lua:GetModifierAura() return "modifier_fountain_buff_lua" end
function modifier_fountain_aura_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fountain_aura_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_fountain_aura_lua:GetAuraDuration() return 0.1 end
function modifier_fountain_aura_lua:GetAuraRadius() return 1200 end

modifier_fountain_buff_lua = modifier_fountain_buff_lua or class({})
function modifier_fountain_buff_lua:GetTexture() return "fountain_heal" end
function modifier_fountain_buff_lua:CheckState() return {[MODIFIER_STATE_ATTACK_IMMUNE] = true, [MODIFIER_STATE_UNTARGETABLE_ENEMY] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_NO_HEALTH_BAR_FOR_ENEMIES] = true} end
function modifier_fountain_buff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_fountain_buff_lua:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end
function modifier_fountain_buff_lua:OnIntervalThink()
	self:GetParent():Dispell(self:GetCaster(), true)
	for _, i in pairs(INVENTORY_SLOTS) do
		local item = self:GetParent():GetItemInSlot(i)
		if item then
			if item:GetName() == "item_bottle" then
				item:SetCurrentCharges(3)
			end
		end
	end
end
function modifier_fountain_buff_lua:GetModifierHealthRegenPercentage() return 20 end
function modifier_fountain_buff_lua:GetModifierTotalPercentageManaRegen() return 20 end
function modifier_fountain_buff_lua:GetModifierConstantManaRegen() return 30 end