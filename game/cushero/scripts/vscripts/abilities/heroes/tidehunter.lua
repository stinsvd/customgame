LinkLuaModifier("modifier_tidehunter_blubber_lua", "abilities/heroes/tidehunter" ,LUA_MODIFIER_MOTION_NONE)

tidehunter_blubber_lua = tidehunter_blubber_lua or class(ability_lua_base)
function tidehunter_blubber_lua:GetIntrinsicModifierName() return "modifier_tidehunter_blubber_lua" end

modifier_tidehunter_blubber_lua = modifier_tidehunter_blubber_lua or class({})
function modifier_tidehunter_blubber_lua:IsHidden() return true end
function modifier_tidehunter_blubber_lua:IsPurgable() return false end
function modifier_tidehunter_blubber_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_tidehunter_blubber_lua:OnCreated()
	if not IsServer() then return end
	self.damage_counter = 0
	self.last_take_damage = GameRules:GetGameTime()
end
function modifier_tidehunter_blubber_lua:OnTakeDamage(kv)
	local attacker = kv.attacker
	local target = kv.unit
	if kv.unit ~= self:GetParent() or kv.unit:PassivesDisabled() or kv.unit:IsIllusion() or kv.attacker:IsOther() or (kv.attacker:GetOwnerEntity() == nil and kv.attacker:GetPlayerOwnerID() == nil) or not self:GetAbility():IsCooldownReady() then return end
	if GameRules:GetGameTime()-self.last_take_damage >= self:GetAbility():GetSpecialValueFor("damage_reset_interval") then
		self.damage_counter = 0
	end
	self.damage_counter = self.damage_counter + kv.damage
	self.last_take_damage = GameRules:GetGameTime()
	if self.damage_counter >= self:GetAbility():GetSpecialValueFor("damage_cleanse") then
		kv.unit:Dispell(kv.unit, true)
		self:GetAbility():UseResources(true, true, false, true)
		self.damage_counter = 0
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", PATTACH_ABSORIGIN, kv.unit)
		ParticleManager:ReleaseParticleIndex(fx)
		kv.unit:EmitSound("Hero_Tidehunter.KrakenShell")
	end
end