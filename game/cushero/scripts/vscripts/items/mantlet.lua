LinkLuaModifier("modifier_item_mantlet_lua", "items/mantlet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mantlet_lua_active", "items/mantlet", LUA_MODIFIER_MOTION_NONE)

item_mantlet_lua = item_mantlet_lua or class(ability_lua_base)
function item_mantlet_lua:GetIntrinsicModifierName() return "modifier_item_mantlet_lua" end
function item_mantlet_lua:OnSpellStart()
	for _, ally in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetEffectiveCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ally:AddNewModifier(self:GetCaster(), self, "modifier_item_mantlet_lua_active", {duration=self:GetSpecialValueFor("active_duration")})
	end
	self:GetCaster():EmitSound("DOTA_Item.Buckler.Activate")
end

modifier_item_mantlet_lua = modifier_item_mantlet_lua or class({})
function modifier_item_mantlet_lua:IsHidden() return true end
function modifier_item_mantlet_lua:IsPurgable() return false end
function modifier_item_mantlet_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mantlet_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_mantlet_lua:GetModifierPhysical_ConstantBlock(kv)
	if not IsServer() then return end
	if kv.target ~= self:GetParent() then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("block_chance"), self:GetAbility():entindex(), self:GetParent()) then return end
	return self:GetAbility():GetSpecialValueFor("damage_block")
end
function modifier_item_mantlet_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_mantlet_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_mantlet_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_mantlet_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_mantlet_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_mantlet_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_mantlet_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

modifier_item_mantlet_lua_active = modifier_item_mantlet_lua_active or class({})
function modifier_item_mantlet_lua_active:IsPurgable() return false end
function modifier_item_mantlet_lua_active:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT} end
function modifier_item_mantlet_lua_active:OnCreated()
    if not IsServer() then return end
	self.shield = self:GetAbility():GetSpecialValueFor("active_absorb")
	self.fx = ParticleManager:CreateParticle("particles/items2_fx/pavise_friend.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	self:OnIntervalThink()
	ParticleManager:SetParticleControlEnt(self.fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.fx, false, false, -1, false, false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	self:StartIntervalThink(0.3)
end
function modifier_item_mantlet_lua_active:OnRefresh()
	if not IsServer() then return end
	self.shield = self:GetAbility():GetSpecialValueFor("active_absorb")
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_item_mantlet_lua_active:OnIntervalThink()
	ParticleManager:SetParticleControl(self.fx, 0, self:GetParent():GetAbsOrigin()+Vector(0, 0, 300))
end
function modifier_item_mantlet_lua_active:AddCustomTransmitterData() return {shield = self.shield} end
function modifier_item_mantlet_lua_active:HandleCustomTransmitterData(kv)
	self.shield = kv.shield
end
function modifier_item_mantlet_lua_active:GetModifierIncomingPhysicalDamageConstant(kv)
	if not IsServer() then return self.shield end
	if kv.target ~= self:GetParent() then return end
	local health = self.shield
	self.shield = math.max(self.shield - kv.damage, 0)
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	return health > kv.damage and (-kv.damage) or (-health)
end