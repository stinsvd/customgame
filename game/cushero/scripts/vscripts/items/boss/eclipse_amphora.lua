LinkLuaModifier("modifier_item_eclipse_amphora_lua", "items/boss/eclipse_amphora", LUA_MODIFIER_MOTION_NONE)

item_eclipse_amphora_lua = item_eclipse_amphora_lua or class(ability_lua_base)
function item_eclipse_amphora_lua:IsRefreshable() return false end
function item_eclipse_amphora_lua:OnSpellStart()
	for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetEffectiveCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		unit:AddNewModifier(self:GetCaster(), self, "modifier_item_eclipse_amphora_lua", {duration=self:GetSpecialValueFor("duration")})
	end
end

modifier_item_eclipse_amphora_lua = modifier_item_eclipse_amphora_lua or class({})
function modifier_item_eclipse_amphora_lua:IsPurgable() return false end
function modifier_item_eclipse_amphora_lua:GetEffectName() return "particles/units/heroes/hero_bane/bane_nightmare.vpcf" end
function modifier_item_eclipse_amphora_lua:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_item_eclipse_amphora_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_item_eclipse_amphora_lua:CheckState() return {[MODIFIER_STATE_NIGHTMARED] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true} end
function modifier_item_eclipse_amphora_lua:OnCreated()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_Bane.Nightmare")
	self:GetParent():EmitSound("Hero_Bane.Nightmare.Loop")
end
function modifier_item_eclipse_amphora_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("Hero_Bane.Nightmare.Loop")
end
function modifier_item_eclipse_amphora_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() then return end
	self:Destroy()
end
function modifier_item_eclipse_amphora_lua:GetOverrideAnimation() return ACT_DOTA_FLAIL end