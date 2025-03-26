LinkLuaModifier("modifier_teleport_portal_lua", "abilities/buildings/portal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_teleport_portal_casting_lua", "abilities/buildings/portal", LUA_MODIFIER_MOTION_NONE)

teleport_portal_lua = teleport_portal_lua or class(ability_lua_base)
function teleport_portal_lua:IsHiddenAbilityCastable() return true end
function teleport_portal_lua:ProcsMagicStick() return false end
function teleport_portal_lua:IsStealable() return false end
function teleport_portal_lua:CastFilterResultTarget(target)
	return target:IsPortal() and UF_SUCCESS or UF_FAIL_CUSTOM
end
function teleport_portal_lua:GetCustomCastErrorTarget(target) return "#dota_hud_error_divine_favor_invalid_target" end
function teleport_portal_lua:GetTeleportPosition(portal_in)
	if not IsValidEntity(portal_in) then return end
	local teleports = {
		["twin_gate_1"] = "twin_gate_2",
		["twin_gate_2"] = "twin_gate_1",
		["twin_gate_3"] = "twin_gate_4",
		["twin_gate_4"] = "twin_gate_3",
	}
	local portal_out = Entities:FindByName(nil, teleports[portal_in:GetName()])
	if IsValidEntity(portal_out) then
		return GetGroundPosition(portal_out:GetAbsOrigin() + portal_out:GetForwardVector() * 100, self:GetCaster())
	end
	return nil
end
function teleport_portal_lua:OnSpellStart()
	self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_teleport_portal_lua", {duration=self:GetChannelTime(), target=self:GetCursorTarget():entindex()})
	self:GetCaster():EmitSound("TwinGate.Channel")
end
function teleport_portal_lua:OnChannelThink(flInterval)
	if self:GetCaster():IsRooted() then
		self:GetCaster():InterruptChannel()
	end
end
function teleport_portal_lua:OnChannelFinish(bInterrupted)
	if self.modifier ~= nil then
		local target = self.modifier.hTarget
		local position = self:GetTeleportPosition(target)
		self.modifier:Destroy()
		target:EmitSound("TwinGate.Channel.End")
		if not bInterrupted and target ~= nil and position ~= nil then
			FindClearSpaceForUnit(self:GetCaster(), position, false)
			self:GetCaster():EmitSound("TwinGate.Teleport.Appear")
		end
	end
	self:GetCaster():StopSound("TwinGate.Channel")
	self:GetCaster():RemoveAbilityByHandle(self)
end

modifier_teleport_portal_lua = modifier_teleport_portal_lua or class({})
function modifier_teleport_portal_lua:IsHidden() return true end
function modifier_teleport_portal_lua:IsPurgable() return false end
function modifier_teleport_portal_lua:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_teleport_portal_lua:OnCreated(kv)
	if not IsServer() then return end
	self.hTarget = EntIndexToHScript(kv.target)
	self:LinkModifier(self.hTarget:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_teleport_portal_casting_lua", {duration=self:GetRemainingTime()}))
end
function modifier_teleport_portal_lua:OnRefresh(kv)
	if not IsServer() then return end
	self:UnlinkModifier()
	self:OnCreated(kv)
end
function modifier_teleport_portal_lua:OnDestroy()
	if not IsServer() then return end
	self:OnDestroyLink()
end
function modifier_teleport_portal_lua:GetOverrideAnimation() return ACT_DOTA_GENERIC_CHANNEL_1 end

modifier_teleport_portal_casting_lua = modifier_teleport_portal_casting_lua or class({})
function modifier_teleport_portal_casting_lua:IsHidden() return true end
function modifier_teleport_portal_casting_lua:IsPurgable() return false end
function modifier_teleport_portal_casting_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_teleport_portal_casting_lua:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_teleport_portal_casting_lua:GetOverrideAnimation() return ACT_DOTA_CHANNEL_ABILITY_1 end