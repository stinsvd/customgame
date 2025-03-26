cast_unit = cast_unit or class(ability_lua_base)
function cast_unit:IsHiddenAbilityCastable() return true end
function cast_unit:ProcsMagicStick() return false end
function cast_unit:IsStealable() return false end
function cast_unit:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()
	local info = GetUnitKeyValuesByName(target:GetUnitName())
	if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		if info["CustomData"]["RightClickOpenEvent"] ~= nil then
			CustomGameEventManager:Send_ServerToPlayer(self:GetCaster():GetPlayerOwner(), info["CustomData"]["RightClickOpenEvent"], {})
		elseif target:IsShrine() then
			target:CastAbilityNoTarget(target:FindAbilityByName("shrine_lua"), self:GetCaster():GetPlayerOwnerID())
		end
	end
	if target:IsPortal() then
		local abil = self:GetCaster():FindAbilityByName("teleport_portal_lua")
		if not abil then
			abil = self:GetCaster():AddAbility("teleport_portal_lua")
			abil:SetAbilityIndex(DOTA_MAX_ABILITIES-2)
			abil:SetLevel(1)
		end
		abil:OrderAbilityOnTarget(target)
	end
	self:GetCaster():RemoveAbilityByHandle(self)
	return false
end