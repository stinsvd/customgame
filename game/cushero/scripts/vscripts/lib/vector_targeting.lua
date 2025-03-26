VectorTargeting = VectorTargeting or class({})

function VectorTargeting:Init()
	CustomGameEventManager:RegisterListener("vector_target_start", Dynamic_Wrap(self, "OnVectorTargetStart"))
end

local function oncast(event)
	local ability = EntIndexToHScript(event["ability"])
	if ability == nil then return end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(event["PlayerID"]), "vector_target_start", {
		fStartWidth = ability:GetVectorTargetStartRadius(),
		fEndWidth = ability:GetVectorTargetEndRadius(),
		fCastLength = ability:GetVectorTargetRange(),
		bDual = ability:IsDualVectorDirection(),
		bIgnoreArrow = ability:IgnoreVectorArrowWidth(),
	})
end

function VectorTargeting:OnVectorTargetStart(event)
	return oncast(event)
end

function VectorTargeting:OrderFilter(event)
	if not event["units"]["0"] then return true end
	local ability = EntIndexToHScript(event["entindex_ability"])
	if not ability then return true end
	local unit = EntIndexToHScript(event["units"]["0"])
	local target = event["entindex_target"] ~= nil and (EntIndexToHScript(event["entindex_target"]) or EntIndexToHScript(GetEntityIndexForTreeId(event["entindex_target"]))) or nil
	local position = Vector(event["position_x"], event["position_y"], event["position_z"])
	local position_normalized = Vector(position.x, position.y, 0)
	local order = event["order_type"]
	if order == DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION and ability:IsBehavior(DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) then
		ability.vectorTargetPosition2 = position_normalized
	end
	if ((table.contains({DOTA_UNIT_ORDER_CAST_TARGET, DOTA_UNIT_ORDER_CAST_TARGET_TREE}, order) and target ~= nil) or (order == DOTA_UNIT_ORDER_CAST_POSITION)) and ability:IsBehavior(DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) then
		if order == DOTA_UNIT_ORDER_CAST_POSITION then
			ability.vectorTargetPosition = position_normalized
		else
			ability.vectorTargetUnit = target
		end
		local point = order == DOTA_UNIT_ORDER_CAST_POSITION and ability.vectorTargetPosition or target:GetAbsOrigin()
		local point2 = ability.vectorTargetPosition2
		local direction = (point2 - (point ~= point2 and point or unit:GetAbsOrigin())):Normalized()
		direction.z = 0
		ability.vectorTargetDirection = direction
		local function OverrideSpellStart(self, start, direction)
			self:OnVectorCastStart(start, direction)
		end
		ability.OnSpellStart = function(self) return OverrideSpellStart(self, order == DOTA_UNIT_ORDER_CAST_POSITION and point or target, direction) end
	end
	return true
end

function CDOTABaseAbility:GetVectorTargetRange() return 800 end
function CDOTABaseAbility:GetVectorTargetStartRadius() return 125 end
function CDOTABaseAbility:GetVectorTargetEndRadius() return self:GetVectorTargetStartRadius() end
function CDOTABaseAbility:GetVectorPosition() return self.vectorTargetPosition end
function CDOTABaseAbility:GetVector2Position() return self.vectorTargetPosition2 end
function CDOTABaseAbility:GetVectorDirection() return self.vectorTargetDirection end
function CDOTABaseAbility:OnVectorCastStart(vStartLocation, vDirection) end
function CDOTABaseAbility:IsDualVectorDirection() return false end
function CDOTABaseAbility:IgnoreVectorArrowWidth() return false end

if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then
	VectorTargeting:Init()
end