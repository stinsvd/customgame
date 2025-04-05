LinkLuaModifier("modifier_urs_fury_swipes_spell", "abilities/heroes/ursa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_urs_fury_swipes_spell_stacks", "abilities/heroes/ursa", LUA_MODIFIER_MOTION_NONE)

urs_fury_swipes_spell = urs_fury_swipes_spell or class({})
function urs_fury_swipes_spell:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_ursa/ursa_fury_swipes.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf", context)
end
function urs_fury_swipes_spell:GetIntrinsicModifierName() return "modifier_urs_fury_swipes_spell" end


modifier_urs_fury_swipes_spell = modifier_urs_fury_swipes_spell or class({})
function modifier_urs_fury_swipes_spell:IsHidden() return true end
function modifier_urs_fury_swipes_spell:IsPurgable() return false end
function modifier_urs_fury_swipes_spell:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_urs_fury_swipes_spell:OnTakeDamage(kv)
	if not IsServer() then return end
	local unit = kv.unit
	if not unit then return end
	local attacker = kv.attacker
	if not attacker then return end
	if attacker ~= self:GetParent() then return end
	
	local swipes_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_fury_swipes.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControlEnt(swipes_pfx, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(swipes_pfx)
	local duration = self:GetAbility():GetSpecialValueFor("bonus_reset_time")
	local stack = attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_urs_fury_swipes_spell_stacks", {duration = duration})
	if stack then
		stack:AddStack()
	end
end


modifier_urs_fury_swipes_spell_stacks = modifier_urs_fury_swipes_spell_stacks or class({})
function modifier_urs_fury_swipes_spell_stacks:IsHidden() return false end
function modifier_urs_fury_swipes_spell_stacks:IsPurgable() return false end
function modifier_urs_fury_swipes_spell_stacks:GetEffectName() return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf" end
function modifier_urs_fury_swipes_spell_stacks:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_urs_fury_swipes_spell_stacks:OnCreated()
	self:OnRefresh()
	
	if not IsServer() then return end
	self.stacks = {}
	self:StartIntervalThink(0.1)
end
function modifier_urs_fury_swipes_spell_stacks:OnRefresh()
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.spell_dmg_per_stack = self:GetAbility():GetSpecialValueFor("spell_dmg_per_stack")
end
function modifier_urs_fury_swipes_spell_stacks:OnIntervalThink()
	if not IsServer() then return end
	if self.stacks then
		for i = #self.stacks, 1, -1 do
			if GameRules:GetDOTATime(true, true) > self.stacks[i] then
				self:DecrementStackCount()
				table.remove(self.stacks, i)
			end
		end
	end
end
function modifier_urs_fury_swipes_spell_stacks:AddStack()
	if not IsServer() then return end
	if self:GetStackCount() >= self.max_stacks then
		self:DecrementStackCount()
		table.remove(self.stacks, 1)
	end
	self:IncrementStackCount()
	table.insert(self.stacks, GameRules:GetDOTATime(true, true) + self:GetDuration())
end
function modifier_urs_fury_swipes_spell_stacks:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end
function modifier_urs_fury_swipes_spell_stacks:GetModifierSpellAmplify_Percentage() return self.spell_dmg_per_stack * self:GetStackCount() end
