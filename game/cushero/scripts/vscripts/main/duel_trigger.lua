function TeleportUnit(unit, position)
	unit:InterruptMotionControllers(false)
	FindClearSpaceForUnit(unit, position, false)
	unit:AddNewModifier(unit, nil, "modifier_stunned", {duration=1})
	DUEL_INFO["positions"][unit:entindex()] = {origin=GetGroundPosition(position, unit), time=GameRules:GetGameTime()}
end

function ValidateAndTeleportPosition(trigger, unit, invading, position)
	local hero_dummy = CreateDummy(unit:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, nil, true, true, true)
	Timers:CreateTimer({endTime=FrameTime(), callback=function()
		local h_touching = trigger:IsTouching(hero_dummy)
		if (h_touching and invading) or (not h_touching and not invading) then
			local dummy = CreateDummy(position, DOTA_TEAM_NEUTRALS, nil, true, true, true)
			Timers:CreateTimer({endTime=FrameTime(), callback=function()
				local touching = trigger:IsTouching(dummy)
				if (touching and invading) or (not touching and not invading) then
					if invading then
						position = PlayerResource:GetRespawnPosition(unit:GetTeamNumber())
					else
						position = Entities:FindByName(nil, tostring(trigger:GetName().."_teleport_"..unit:GetTeamNumber())):GetAbsOrigin()
					end
				end
				TeleportUnit(unit, position)
				UTIL_Remove(dummy)
			end}, nil, self)
		end
	end}, nil, self)
end

function CheckUnitForTeleport(trigger, unit, invading)
	local touching = trigger:IsTouching(unit)
	if (touching and invading) or (not touching and not invading) then
		ValidateAndTeleportPosition(trigger, unit, invading, DUEL_INFO["positions"][unit:entindex()]["origin"])
	end
end

function OnStartTouch(event)
	local unit = event.activator
	local trigger = event.caller
	if not IsValidEntity(unit) or not unit:IsControllableByAnyPlayer() or unit:IsOther() or unit:IsCourier() then return end
	if not table.contains(table.open(DUEL_INFO["triggers"][trigger:entindex()]), unit:GetPlayerOwnerID()) and unit.afterduel == nil then
		CheckUnitForTeleport(trigger, unit, true)
	end
end

function OnEndTouch(event)
	local unit = event.activator
	local trigger = event.caller
	if not IsValidEntity(unit) or not unit:IsControllableByAnyPlayer() or unit:IsOther() or unit:IsCourier() then return end
	if table.contains(table.open(DUEL_INFO["triggers"][trigger:entindex()]), unit:GetPlayerOwnerID()) then
		CheckUnitForTeleport(trigger, unit, false)
	end
end