LinkLuaModifier("modifier_item_pavise_cape_lua", "items/pavise_cape", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_pavise_cape_lua_active", "items/pavise_cape", LUA_MODIFIER_MOTION_NONE)

item_pavise_cape_lua = item_pavise_cape_lua or class(ability_lua_base)
function item_pavise_cape_lua:GetIntrinsicModifierName() return "modifier_item_pavise_cape_lua" end
function item_pavise_cape_lua:OnSpellStart()
    self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_pavise_cape_lua_active", {duration=self:GetSpecialValueFor("duration")})
	local fx = ParticleManager:CreateParticle("particles/items3_fx/glimmer_cape_initial_flash.vpcf", PATTACH_ABSORIGIN, self:GetCursorTarget())
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCursorTarget():EmitSound("Item.GlimmerCape.Activate")
	self:GetCursorTarget():EmitSound("Item.Pavise.Target")
end

modifier_item_pavise_cape_lua = modifier_item_pavise_cape_lua or class({})
function modifier_item_pavise_cape_lua:IsHidden() return true end
function modifier_item_pavise_cape_lua:IsPurgable() return false end
function modifier_item_pavise_cape_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_pavise_cape_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_item_pavise_cape_lua:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_item_pavise_cape_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_pavise_cape_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_pavise_cape_lua:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("bonus_magical_armor") end

modifier_item_pavise_cape_lua_active = modifier_item_pavise_cape_lua_active or class({})
function modifier_item_pavise_cape_lua_active:IsPurgable() return true end
function modifier_item_pavise_cape_lua_active:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_item_pavise_cape_lua_active:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("active_movement_speed")
    if not IsServer() then return end
	self.shield = self:GetAbility():GetSpecialValueFor("absorb_amount")
	self.invis = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible_lua", {duration=self:GetRemainingTime(), delay=self:GetAbility():GetSpecialValueFor("initial_fade_delay"), hidden=true, texture=GetAbilityTextureNameForAbility(self:GetAbility():GetAbilityName())})
	self.invis:destroy_other_me()
	local fx = ParticleManager:CreateParticle("particles/items3_fx/glimmer_cape_initial.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(fx)
	self.fx = ParticleManager:CreateParticle("particles/items2_fx/pavise_friend.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	self:OnIntervalThink()
	ParticleManager:SetParticleControlEnt(self.fx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.fx, false, false, -1, false, false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	self:StartIntervalThink(0.3)
end
function modifier_item_pavise_cape_lua_active:OnRefresh()
	self.movespeed = self:GetAbility():GetSpecialValueFor("active_movement_speed")
	if not IsServer() then return end
	self.shield = self:GetAbility():GetSpecialValueFor("absorb_amount")
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_item_pavise_cape_lua_active:OnIntervalThink()
	ParticleManager:SetParticleControl(self.fx, 0, self:GetParent():GetAbsOrigin()+Vector(0, 0, 300))
end
function modifier_item_pavise_cape_lua_active:AddCustomTransmitterData() return {shield = self.shield} end
function modifier_item_pavise_cape_lua_active:HandleCustomTransmitterData(kv)
	self.shield = kv.shield
end
function modifier_item_pavise_cape_lua_active:OnDestroy()
	if not IsServer() then return end
	self.invis:Destroy()
end
function modifier_item_pavise_cape_lua_active:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	self.invis = kv.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible_lua", {duration=self:GetRemainingTime(), delay=self:GetAbility():GetSpecialValueFor("secondary_fade_delay"), hidden=true, texture=GetAbilityTextureNameForAbility(self:GetAbility():GetAbilityName())})
	self.invis:destroy_other_me()
end
function modifier_item_pavise_cape_lua_active:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() then return end
	self.invis = kv.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible_lua", {duration=self:GetRemainingTime(), delay=self:GetAbility():GetSpecialValueFor("secondary_fade_delay"), hidden=true, texture=GetAbilityTextureNameForAbility(self:GetAbility():GetAbilityName())})
	self.invis:destroy_other_me()
end
function modifier_item_pavise_cape_lua_active:GetModifierIncomingDamageConstant(kv)
	if not IsServer() then return self.shield end
	if kv.target ~= self:GetParent() then return end
	local health = self.shield
	self.shield = math.max(self.shield - kv.damage, 0)
	self:SetHasCustomTransmitterData(false)
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	return health > kv.damage and (-kv.damage) or (-health)
end
function modifier_item_pavise_cape_lua_active:GetModifierMoveSpeedBonus_Constant(kv) return self.movespeed end