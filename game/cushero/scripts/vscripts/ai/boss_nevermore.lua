function Spawn(entityKeyValues)
	if not IsServer() then return end
	if thisEntity == nil then return end
	thisEntity:SetContextThink("AiThink", AiThink, AI_UPDATE)
end
function AiThink()
	if not thisEntity:IsAlive() or thisEntity:IsControllableByAnyPlayer() then return -1 end
	if GameRules:IsGamePaused() or thisEntity:IsChanneling() or thisEntity:HasModifier("modifier_idle_stone_active") then return AI_UPDATE end
	if not thisEntity.bInitialized then
		thisEntity.vInitialSpawnPos = thisEntity:GetAbsOrigin()
		thisEntity.iAggro = 0
		thisEntity.bInitialized = true
		thisEntity.bCasting = false
	end
	thisEntity.bAggroSleep = false
	if not thisEntity.bCasting and not thisEntity.requiemcombing then
		local aggro_target = thisEntity:GetAggroTarget()
		if aggro_target and (not aggro_target:IsAlive() or (aggro_target:GetTeamNumber() == thisEntity:GetTeamNumber() and not thisEntity:IsTaunted())) then thisEntity:SetAggroTarget(nil) end
		if aggro_target ~= nil then
			if CalculateDistance(thisEntity, thisEntity.vInitialSpawnPos) > 400 then
				thisEntity.iAggro = thisEntity.iAggro + AI_UPDATE
			else
				thisEntity.iAggro = 0
			end
			thisEntity.last_aggro_target = aggro_target
			for _, ally in pairs(FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)) do
				if ally ~= thisEntity and ally.bInitialized and ally:IsAlive() and CalculateDistance(ally, ally.vInitialSpawnPos) + (CalculateDistance(ally, aggro_target) - ally:Script_GetAttackRange()) <= 5*ally:GetIdealSpeed() and ally.bAggroSleep == false and not ally:IsChanneling() and ally.bCasting == false then
					ally.iSleepCooldown = 2
					ally:SetAggroTarget(aggro_target)
					ExecuteOrderFromTable({UnitIndex = ally:entindex(), OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, TargetIndex = ally:GetAggroTarget():entindex(), Position = ally:GetAggroTarget():GetAbsOrigin(), Queue = false})
				end
			end
		elseif CalculateDistance(thisEntity, thisEntity.vInitialSpawnPos) > 100 then
			ExecuteOrderFromTable({UnitIndex = thisEntity:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = thisEntity.vInitialSpawnPos})
		end
		if CalculateDistance(thisEntity, thisEntity.vInitialSpawnPos) > 5*thisEntity:GetIdealSpeed() or thisEntity.iAggro >= 5 then
			ExecuteOrderFromTable({UnitIndex = thisEntity:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = thisEntity.vInitialSpawnPos})
			thisEntity.iAggro = 0
			thisEntity.bAggroSleep = true
			return AI_UPDATE * 15
		end
		local aggro = aggro_target ~= nil and 750 or 50
		local enemy = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, aggro, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)[1]
		if IsValidEntity(enemy) and CanCastCombo() then
			thisEntity.combotarget = enemy
			CastCombo(enemy, false)
		end
	end
	thisEntity.bCasting = thisEntity.requiemcombing or thisEntity.razecombing or thisEntity:GetCastingAbility() ~= nil
	return AI_UPDATE
end
function CanCastCombo()
	local requiem = thisEntity:GetAbilityByIndex(5)
	local ethereal = table.values(thisEntity:GetItemsByName({"item_ethereal_blade"}))[1]
	local blink = table.values(thisEntity:GetItemsByName({"item_blink", "item_arcane_blink", "item_swift_blink", "item_overwhelming_blink"}))[1]
	local eul = table.values(thisEntity:GetItemsByName({"item_cyclone", "item_wind_waker"}))[1]
	return requiem:IsCooldownReady() and ethereal:IsCooldownReady() and eul:IsCooldownReady()
end
function CastCombo(target, repeating)
	thisEntity.requiemcombing = true
	local has_linken = target:HasSpellAbsorb()
	local razes = {thisEntity:GetAbilityByIndex(0), thisEntity:GetAbilityByIndex(1), thisEntity:GetAbilityByIndex(2)}
	local requiem = thisEntity:GetAbilityByIndex(5)
	local ethereal = table.values(thisEntity:GetItemsByName({"item_ethereal_blade"}))[1]
	local blink = table.values(thisEntity:GetItemsByName({"item_blink", "item_arcane_blink", "item_swift_blink", "item_overwhelming_blink"}))[1]
	local bkb = table.values(thisEntity:GetItemsByName({"item_black_king_bar"}))[1]
	local refresher = table.values(thisEntity:GetItemsByName({"item_refresher"}))[1]
	local eul = table.values(thisEntity:GetItemsByName({"item_cyclone", "item_wind_waker"}))[1]
	if has_linken then
		if not repeating then
			CastAbility(ethereal, target)
		end
		if thisEntity.requiemcombing then
			Timers:CreateTimer({endTime=CalculateDistance(thisEntity, target)/ethereal:GetSpecialValueFor("projectile_speed")*1.5, callback=function()
				CastCombo(target, true)
			end}, nil, self)
		end
		return false
	end
	CastAbility(bkb, target)
	blink:EndCooldown()
	CastAbility(blink, target)
	if ethereal:IsCooldownReady() then
		CastAbility(ethereal, target)
	end
	CastAbility(eul, target)
	ExecuteOrderFromTable({UnitIndex=thisEntity:entindex(), OrderType=DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position=target:GetAbsOrigin(), Queue=true})
	Timers:CreateTimer({endTime=math.max(eul:GetSpecialValueFor("cyclone_duration")-requiem:GetCastTime(), 0)+FrameTime()*5, callback=function()
		if target:IsAlive() then
			CastAbility(requiem, target)
			Timers:CreateTimer({endTime=requiem:GetCastTime()+FrameTime(), callback=function()
				if not requiem:IsCooldownReady() and target:IsAlive() then
					if not thisEntity.razecombing and thisEntity.requiemcombing and RazeCombo(target) then
						if target:IsAlive() and refresher:IsCooldownReady() then
							CastAbility(refresher, target)
							Timers:CreateTimer({endTime=FrameTime(), callback=function()
								CastCombo(target, false)
							end}, nil, self)
							return nil
						else
							thisEntity.requiemcombing = false
							thisEntity.combotarget = nil
						end
						return nil
					end
					return FrameTime()
				end
				thisEntity.requiemcombing = false
				thisEntity.razecombing = false
				thisEntity.razeing = false
				thisEntity.combotarget = nil
			end}, nil, self)
		end
	end}, nil, self)
	return true
end
function RazeCombo(target)
	for _, raze in pairs({thisEntity:GetAbilityByIndex(0), thisEntity:GetAbilityByIndex(1), thisEntity:GetAbilityByIndex(2)}) do
		if UseRaze(target, raze) then
			thisEntity.razecombing = true
			Timers:CreateTimer({endTime=raze:GetCastTime()+FrameTime(), callback=function()
				if thisEntity:GetCastingAbility() ~= nil or thisEntity.razeing then return FrameTime() end
				RazeCombo(target)
			end}, nil, self)
			return false
		end
	end
	thisEntity.razecombing = false
	return true
end
function UseRaze(target, raze)
	if raze:IsCooldownReady() and target:IsAlive() then
		local range = raze:GetSpecialValueFor("shadowraze_range")
		local radius = raze:GetSpecialValueFor("shadowraze_radius")
		local distance = CalculateDistance(thisEntity, target)
		thisEntity.razeing = true
		if distance > range-radius and distance < range+radius then
			thisEntity:FaceTowards(target:GetAbsOrigin())
			Timers:CreateTimer({endTime=0.3, callback=function()
				CastAbility(raze, target)
				Timers:CreateTimer({endTime=raze:GetCastTime()+FrameTime(), callback=function()
					thisEntity.razeing = false
				end}, nil, self)
			end}, nil, self)
			return true
		else
			local blink = table.values(thisEntity:GetItemsByName({"item_blink", "item_arcane_blink", "item_swift_blink", "item_overwhelming_blink"}))[1]
			thisEntity:SetCursorPosition(target:GetAbsOrigin()+((thisEntity:GetAbsOrigin()-target:GetAbsOrigin()):Normalized()*range))
			blink:OnSpellStart()
			thisEntity:FaceTowards(target:GetAbsOrigin())
			Timers:CreateTimer({endTime=0.2, callback=function()
				CastAbility(raze, target)
				Timers:CreateTimer({endTime=raze:GetCastTime()+FrameTime(), callback=function()
					thisEntity.razeing = false
				end}, nil, self)
			end}, nil, self)
			return true
		end
	end
	return false
end
function CastAbility(ability, target)
	if ability:IsCooldownReady() then
		if ability:GetCastPoint() > 0 then
			if ability:GetMainBehavior() == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
				ability:OrderAbilityNoTarget()
			elseif ability:GetMainBehavior() == DOTA_ABILITY_BEHAVIOR_TOGGLE then
				ability:OrderAbilityToggle(ability, -1)
			elseif ability:GetMainBehavior() == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
				ability:OrderAbilityOnTarget(target)
			elseif ability:GetMainBehavior() == DOTA_ABILITY_BEHAVIOR_POINT then
				ability:OrderAbilityOnPosition((target.IsBaseNPC ~= nil and target:IsBaseNPC()) and target:GetAbsOrigin() or target)
			end
		else
			thisEntity:SetCursorPosition((target.IsBaseNPC ~= nil and target:IsBaseNPC()) and target:GetAbsOrigin() or target)
			thisEntity:SetCursorCastTarget(target)
			ability:OnSpellStart()
			ability:UseResources(true, true, true, true)
		end
	end
end