LinkLuaModifier("modifier_tinker_rearm_lua", "abilities/heroes/tinker", LUA_MODIFIER_MOTION_NONE)

tinker_rearm_lua = tinker_rearm_lua or class(ability_lua_base)
function tinker_rearm_lua:IsRearmable() return true end
function tinker_rearm_lua:GetCastAnimation()
	local lvl = self:GetLevel()
	if lvl == 1 then
		return ACT_DOTA_TINKER_REARM1
	elseif lvl == 2 then
		return ACT_DOTA_TINKER_REARM2
	elseif lvl == 3 then
		return ACT_DOTA_TINKER_REARM3
	end
	return ACT_DOTA_TINKER_REARM1
end
function tinker_rearm_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_tinker_rearm_lua", {duration=self:GetSpecialValueFor("armor_duration")})
	self:GetCaster():EmitSound("Hero_Tinker.Rearm")
	self.cast_main_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_main_pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.cast_main_pfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	self.cast_pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm_b.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_pfx1, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	self.cast_pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm_b.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.cast_pfx2, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack3", self:GetCaster():GetAbsOrigin(), true)
end
function tinker_rearm_lua:OnChannelFinish(bInterrupted)
	self:GetCaster():StopSound("Hero_Tinker.Rearm")
	ParticleManager:DestroyParticle(self.cast_main_pfx, false)
	ParticleManager:ReleaseParticleIndex(self.cast_main_pfx)
	ParticleManager:DestroyParticle(self.cast_pfx1, false)
	ParticleManager:ReleaseParticleIndex(self.cast_pfx1)
	ParticleManager:DestroyParticle(self.cast_pfx2, false)
	ParticleManager:ReleaseParticleIndex(self.cast_pfx2)
	if bInterrupted then return end
	for i=0, self:GetCaster():GetAbilityCount()-1 do
		local ability = self:GetCaster():GetAbilityByIndex(i)
		if ability and ability:IsRearmable() then
			ability:RefreshCharges()
			ability:EndCooldown()
		end
	end
	if self:GetSpecialValueFor("affects_items") == 1 then
		for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
			local item = self:GetCaster():GetItemInSlot(i)
			if item then
				if item:GetPurchaser() == self:GetCaster() and item:IsRearmable() then
					item:EndCooldown()
				end
			end
		end
		local tpscroll = self:GetCaster():GetItemInSlot(DOTA_ITEM_TP_SCROLL)
		if tpscroll then
			if tpscroll:GetPurchaser() == self:GetCaster() and tpscroll:IsRearmable() then
				tpscroll:EndCooldown()
			end
		end
	end
end

modifier_tinker_rearm_lua = modifier_tinker_rearm_lua or class({})
function modifier_tinker_rearm_lua:IsPurgable() return true end
function modifier_tinker_rearm_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_tinker_rearm_lua:OnCreated()
	self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
end
function modifier_tinker_rearm_lua:OnRefresh()
	self:OnCreated()
end
function modifier_tinker_rearm_lua:GetModifierMagicalResistanceBonus() return self.magic_resistance end