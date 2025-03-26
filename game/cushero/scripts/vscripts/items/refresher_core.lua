LinkLuaModifier("modifier_item_refresher_core_lua", "items/refresher_core", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_refresher_core_cooldown_lua", "items/refresher_core", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_refresher_core_recharge_lua", "items/refresher_core", LUA_MODIFIER_MOTION_NONE)

item_refresher_core_lua = item_refresher_core_lua or class(ability_lua_base)
function item_refresher_core_lua:GetIntrinsicModifiers() return {"modifier_item_refresher_core_lua", "modifier_item_refresher_core_cooldown_lua"} end
function item_refresher_core_lua:IsRefreshable() return false end
function item_refresher_core_lua:IsMulticastable() return false end
function item_refresher_core_lua:OnSpellStart()
	for i=0, self:GetCaster():GetAbilityCount()-1 do
		local ability = self:GetCaster():GetAbilityByIndex(i)
		if ability ~= nil and ability:IsRefreshable() then
			ability:RefreshCharges()
			ability:EndCooldown()
		end
	end
	for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_NEUTRAL_PASSIVE_SLOT do
		local item = self:GetCaster():GetItemInSlot(i)
		if item ~= nil then
			if item:GetName() ~= "item_refresher_orb" and item:IsRefreshable() then
				item:EndCooldown()
			end
		end
	end
	local fx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("DOTA_Item.Refresher.Activate")
end

modifier_item_refresher_core_lua = modifier_item_refresher_core_lua or class({})
function modifier_item_refresher_core_lua:IsHidden() return true end
function modifier_item_refresher_core_lua:IsPurgable() return false end
function modifier_item_refresher_core_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS} end
function modifier_item_refresher_core_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_refresher_core_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_refresher_core_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_refresher_core_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_refresher_core_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_refresher_core_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end

modifier_item_refresher_core_cooldown_lua = modifier_item_refresher_core_cooldown_lua or class({})
function modifier_item_refresher_core_cooldown_lua:IsHidden() return true end
function modifier_item_refresher_core_cooldown_lua:IsPurgable() return false end
function modifier_item_refresher_core_cooldown_lua:DeclareFunctions() return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_item_refresher_core_cooldown_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or not kv.ability:IsMulticastable() then return end
	if not RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("instant_recharge_chance"), self:GetAbility():entindex(), kv.unit) then return end
	kv.ability:EndCooldown()
	kv.unit:AddNewModifier(kv.unit, self:GetAbility(), "modifier_item_refresher_core_recharge_lua", {duration=self:GetAbility():GetSpecialValueFor("instant_recharge_duration")})
end
function modifier_item_refresher_core_cooldown_lua:GetModifierPercentageCooldown() if not self:GetParent():HasModifier("modifier_item_octarine_core") then return self:GetAbility():GetSpecialValueFor("bonus_cooldown") end end

modifier_item_refresher_core_recharge_lua = modifier_item_refresher_core_recharge_lua or class({})
function modifier_item_refresher_core_recharge_lua:IsPurgable() return false end
function modifier_item_refresher_core_recharge_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE} end
function modifier_item_refresher_core_recharge_lua:OnCreated()
	if IsServer() and not self:GetAbility() then self:Destroy() end
	self.mana_cost_reduction = self:GetAbility():GetSpecialValueFor("instant_recharge_mana_cost")
	self.cooldown_reduction = self:GetAbility():GetSpecialValueFor("instant_recharge_cooldown")
	self.spell_lifesteal = self:GetAbility():GetSpecialValueFor("instant_recharge_spell_lifesteal")
	self.cast_point_reduction = self:GetAbility():GetSpecialValueFor("instant_recharge_cast_point_reduction")
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/clock_overclock_buff_recharge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetParent():EmitSound("DOTA_Item.Refresher.Activate")
end
function modifier_item_refresher_core_recharge_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_refresher_core_recharge_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.inflictor == nil or UnitFilter(kv.unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	kv.attacker:Lifesteal(self.spell_lifesteal, kv.damage, self:GetAbility(), true, false)
end
function modifier_item_refresher_core_recharge_lua:GetModifierPercentageManacost() return self.mana_cost_reduction end
function modifier_item_refresher_core_recharge_lua:GetModifierPercentageCooldown() return self.cooldown_reduction end
function modifier_item_refresher_core_recharge_lua:GetModifierPercentageCasttime(kv)
	if not IsServer() then return end
	if kv.ability == nil then return end
	return kv.ability:GetCastPoint() * self.cast_point_reduction / 100
end