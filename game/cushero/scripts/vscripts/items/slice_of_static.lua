LinkLuaModifier("modifier_item_slice_of_static_lua", "items/slice_of_static", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_slice_of_static_unique_lua", "items/slice_of_static", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_slice_of_static_active_lua", "items/slice_of_static", LUA_MODIFIER_MOTION_NONE)

item_slice_of_static_lua = item_slice_of_static_lua or class(ability_lua_base)
function item_slice_of_static_lua:GetManaCost(iLevel)
	return math.floor(self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_cost_pct") / 100)
end
function item_slice_of_static_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_slice_of_static_active_lua", {duration=self:GetSpecialValueFor("active_duration")})
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/clock_overclock_buff_recharge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("Hero_Rattletrap.Overclock.Cast")
end
function item_slice_of_static_lua:GetIntrinsicModifiers() return {"modifier_item_slice_of_static_lua", "modifier_item_slice_of_static_unique_lua"} end

modifier_item_slice_of_static_lua = modifier_item_slice_of_static_lua or class({})
function modifier_item_slice_of_static_lua:IsHidden() return true end
function modifier_item_slice_of_static_lua:IsPurgable() return false end
function modifier_item_slice_of_static_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_slice_of_static_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_slice_of_static_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_slice_of_static_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_slice_of_static_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") + self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_slice_of_static_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_slice_of_static_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

modifier_item_slice_of_static_unique_lua = modifier_item_slice_of_static_unique_lua or class({})
function modifier_item_slice_of_static_unique_lua:IsHidden() return true end
function modifier_item_slice_of_static_unique_lua:IsPurgable() return false end
function modifier_item_slice_of_static_unique_lua:DeclareFunctions() return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE} end
function modifier_item_slice_of_static_unique_lua:GetModifierExtraManaPercentage() return self:GetAbility():GetSpecialValueFor("bonus_max_mana_percentage") end
function modifier_item_slice_of_static_unique_lua:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp_per_int") * self:GetParent():GetIntellect(false) end

modifier_item_slice_of_static_active_lua = modifier_item_slice_of_static_active_lua or class({})
function modifier_item_slice_of_static_active_lua:IsPurgable() return false end
function modifier_item_slice_of_static_active_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_item_slice_of_static_active_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or kv.ability:GetCooldown(kv.ability:GetLevel()) <= 0 or kv.ability:GetMainBehavior() == DOTA_ABILITY_BEHAVIOR_TOGGLE then return end
	if kv.ability == self:GetAbility() then return end
	for _, enemy in pairs(FindUnitsInRadius(kv.unit:GetTeamNumber(), kv.unit:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("damage_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ApplyDamage({victim=enemy, attacker=kv.unit, damage=enemy:GetHealth()*self:GetAbility():GetSpecialValueFor("damage_pct")/100, damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
	end
end

item_static_amulet_lua = item_static_amulet_lua or class(item_slice_of_static_lua)