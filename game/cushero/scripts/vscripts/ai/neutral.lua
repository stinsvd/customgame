LinkLuaModifier("modifier_neutral_sleep_lua", "ai/neutral", LUA_MODIFIER_MOTION_NONE)

NeutralAI = NeutralAI or class({})

function NeutralAI:CanWakeOthers() return self.bCanWakeOthers end
function NeutralAI:IsWakeUp() return self.bWakeUp end
function NeutralAI:IsSleeping() return self.hUnit:HasModifier("modifier_neutral_sleep_lua") end
function NeutralAI:GetAggroTarget() return self.hAggroTarget or self.hUnit:GetAggroTarget() or self.hAggroAttacker end
function NeutralAI:CanBeAggred() return self.fAggroCooldownRemainingTime <= 0 and not self.bRetreatingHome end
function NeutralAI:GetAggroRadius() return not self:IsSleeping() and (self:IsWakeUp() and self.iAggroRadius or self.iAggroSleepRadius) or 0 end
function NeutralAI:IsNearHome() return CalculateDistance(self.hUnit, self.vSpawnOrigin) <= self.iGuardDistance end
function NeutralAI:CanAttack(hTarget) return IsValidEntity(hTarget) and hTarget:IsAlive() and hTarget:GetTeamNumber() ~= self.hUnit:GetTeamNumber() and not hTarget:IsInvulnerable() and not hTarget:IsAttackImmune() and not hTarget:IsInvisible() end
function NeutralAI:GetAggroPriority(hUnit)
	if hUnit:IsCourier() then
		return nil
	elseif hUnit:IsOther() or hUnit:IsLowAttackPriority() then
		return 0.1
	elseif hUnit:IsTower() then
		return 0.2
	elseif hUnit:IsSiegeCreep() then
		return 0.3
	end
    return 1
end

function NeutralAI:Init(hUnit)
	if self.bInitialized then return end
	self.iWakeRadius = 500
	self.bCanWakeOthers = true
	self.iAggroSleepRadius = 240
	self.iAggroRadius = 500
	self.iDamageAggroRadius = 1800
	self.iInvisMoveRadius = 750
	self.iInvisMoveDuration = 5
	self.iGuardDistance = 400
	self.iGuardAggroDuration = 5
	self.iGuardAggroLoseDamageDuration = 3
	self.iGuardAggroLoseGainDamageDuration = 3
	self.fAIThinkDelay = 0.5
	self.fAggroThinkDelay = 0.1

	self.hUnit = hUnit
	self.hUnit.hAI = self

	self.bWakeUp = false
	self.hAggroAttacker = nil
	self.hAggroTarget = nil
	self.fAggroRemainingTime = -1
	self.fAggroCooldownRemainingTime = 0
	self.bRetreatingHome = false
	self.bCastingAbility = false
	self.vSpawnOrigin = nil
	self.iLastWakeUpTime = 0
	self.fLastTakeDamage = 0
	Timers:CreateTimer({endTime=FrameTime(), callback=function()
		if IsValidEntity(self.hUnit) then
			self.vSpawnOrigin = self.hUnit:GetAbsOrigin()
		end
	end}, nil, self)
	self.vCachedOrigin = self.vSpawnOrigin
	self.bInitialized = true

	Timers:CreateTimer({endTime=self.fAIThinkDelay, callback=self.OnThink}, nil, self)
end

function NeutralAI:OnThink()
	if not IsValidEntity(self.hUnit) or not self.hUnit:IsAlive() then return nil end
	if self:IsSleeping() then if self.hUnit:IsControllableByAnyPlayer() then self:Wake() end return self.fAIThinkDelay end
	self.vCachedOrigin = self.hUnit:GetAbsOrigin()
	local hAggroTarget = self:GetAggroTarget()
	local bIsAggroed = false
	if hAggroTarget ~= nil then
		if self.hAggroTimer == nil and self:CanBeAggred() then
			self:StartAggro()
		end
		if not self.bCastingAbility then
			for i=0, self.hUnit:GetAbilityCount()-1 do
				local ability = self.hUnit:GetAbilityByIndex(i)
				if ability then
					if ability:IsInAbilityPhase() then
						self.bCastingAbility = true
						break
					elseif ability:IsFullyCastable() then
						if self:CastAbility(ability) then
							self.bCastingAbility = true
							break
						end
					end
				end
			end
		end
	elseif self:CanBeAggred() and self:FindAggroTarget() ~= nil then
		self:StartAggro()
		bIsAggroed = true
	end
	if self.bRetreatingHome then
		if self:IsNearHome() then
			self.bRetreatingHome = false
		end
	else
		if self.fAggroRemainingTime == 0 and hAggroTarget == nil and not bIsAggroed then
			self:RetreatHome()
		end
	end
	local iHomeDistance = CalculateDistance(self.hUnit, self.vSpawnOrigin)
	if hAggroTarget == nil and not bIsAggroed then
		if iHomeDistance <= 85 or (iHomeDistance < 150 and CalculateDistance(self.hUnit, self.vCachedOrigin) <= 10) then
			if GameRules:GetDOTATime(true, false)-self.iLastWakeUpTime > self.iGuardAggroDuration then
				self.bWakeUp = false
				if not GameRules:IsDaytime() then
					self.hUnit:AddNewModifier(self.hUnit, nil, "modifier_neutral_sleep_lua", {})
				end
			end
		end
	end
	if self.hAggroTimer == nil then
		self.fAggroCooldownRemainingTime = math.max(self.fAggroCooldownRemainingTime - self.fAIThinkDelay, 0)
	end
	return self.fAIThinkDelay
end

function NeutralAI:StartAggro(hTarget, iAggroDuration)
	if not self:IsWakeUp() then
		self:WakeUp(hTarget)
	end
	self.fAggroRemainingTime = iAggroDuration or self.iGuardAggroDuration
    if self.hAggroTimer ~= nil then
		Timers:RemoveTimer(self.hAggroTimer)
	end
    self.hAggroTimer = Timers:CreateTimer({endTime=FrameTime(), callback=function()
		if not IsValidEntity(self.hUnit) or not self.hUnit:IsAlive() or self.hUnit:IsControllableByAnyPlayer() or self:IsSleeping() then return nil end
		self.fAggroCooldownRemainingTime = math.max(self.fAggroCooldownRemainingTime - self.fAggroThinkDelay, 0)
		if self.bRetreatingHome and self:IsNearHome() then self.bRetreatingHome = false end
		self.hAggroTarget = self:CanBeAggred() and (hTarget or self:FindAggroTarget() or self.hAggroAttacker) or nil
		if self.hAggroTarget ~= nil and self.fAggroRemainingTime > 0 then
			if not self:IsWakeUp() then
				self:WakeUp(self.hAggroTarget)
			end
			if not self.hAggroTarget:IsInvisible() then
				if self:IsNearHome() and self.fAggroRemainingTime >= 3 then
					self.fAggroRemainingTime = iAggroDuration or self.iGuardAggroDuration
				else
					self.fAggroRemainingTime = math.max(self.fAggroRemainingTime - self.fAggroThinkDelay, 0)
				end
				self:Attack(self.hAggroTarget)
			else
				if not self.hUnit:IsMoving() then
					self.fAggroRemainingTime = self.iInvisMoveDuration
					self:Move(self.vSpawnOrigin + RandomVector(self.iInvisMoveRadius))
				else
					self.fAggroRemainingTime = math.max(self.fAggroRemainingTime - self.fAggroThinkDelay, 0)
				end
			end
		else
			self:RetreatHome()
			self:StopAggro(not self:IsNearHome() and self.iGuardAggroLoseDamageDuration or nil)
			return nil
		end
        return self.fAggroThinkDelay
    end}, nil, self)
end

function NeutralAI:OnTakeDamage(hAttacker, nDamage, hAbility)
	local now = GameRules:GetDOTATime(true, false)
	if now-self.fLastTakeDamage < 0.5 then return end
	local distance = CalculateDistance(self.hUnit, hAttacker)
	if distance <= self.iDamageAggroRadius then
		self.fLastTakeDamage = now
		self:WakeUp(hAttacker)
		if self.bRetreatingHome and self.fAggroCooldownRemainingTime <= 0 and distance <= self.iAggroRadius then
			self:StartAggro(nil, self.iGuardAggroLoseGainDamageDuration)
			self:WakeUp(hAttacker)
		end
	end
end

function NeutralAI:OnAbilityCast(hAttacker, hAbility)
	if CalculateDistance(self.hUnit, hAttacker) <= self.iDamageAggroRadius then
		self:WakeUp(hAttacker)
	end
end

function NeutralAI:OnOrderAttackAggro(hAttacker)
	if CalculateDistance(self.hUnit, hAttacker) <= self.iAggroRadius then
		if self:CanBeAggred() then
			self:StartAggro(hAttacker)
		elseif self.bRetreatingHome and self.fAggroCooldownRemainingTime <= 0 then
			self:StartAggro(hAttacker, self.iGuardAggroLoseGainDamageDuration)
		end
	end
end

function NeutralAI:OnWakeUp(hAttacker, hWakeUpper)
	self.iLastWakeUpTime = GameRules:GetDOTATime(true, false)+FrameTime()
	self.hAggroAttacker = hAttacker
	Timers:CreateTimer({endTime=FrameTime(), callback=function()
		self:Wake()
		if self:CanBeAggred() then
			self:StartAggro()
		end
	end})
    return true
end

function NeutralAI:StopAggro(iAggroLoseDuration)
	if self.hAggroTimer ~= nil then
		Timers:RemoveTimer(self.hAggroTimer)
	end
	self.hAggroTimer = nil
	self.hAggroTarget = nil
	self.hAggroAttacker = nil
	if iAggroLoseDuration ~= nil then
		self.fAggroRemainingTime = 0
	end
	self.fAggroCooldownRemainingTime = iAggroLoseDuration or 0
end

function NeutralAI:FindAggroTarget(iRadius)
    local tTarget = {nil, nil, 0, false}
    for _, hUnit in ipairs(FindUnitsInRadius(self.hUnit:GetTeamNumber(), self.hUnit:GetAbsOrigin(), nil, iRadius or self:GetAggroRadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
		if self:CanAttack(hUnit) then
			local iPriority = self:GetAggroPriority(hUnit)
			if iPriority then
				local iDistance = CalculateDistance(self.hUnit, hUnit)
				local hTargetAggro = hUnit:GetAggroTarget()
				local bAttacking = hTargetAggro ~= nil and hTargetAggro:GetTeamNumber() == DOTA_TEAM_NEUTRALS or false
				if (tTarget[2] == nil) or (iPriority < tTarget[2]) or (iPriority == tTarget[2] and (tTarget[3] == nil or tTarget[3] == iDistance) and not tTarget[4] and bAttacking) then
					tTarget = {hUnit, iPriority, iDistance, bAttacking}
				end
			end
		end
    end
	return tTarget[1] or (self:CanAttack(self.hAggroAttacker) and self.hAggroAttacker or nil)
end

function NeutralAI:WakeUp(hAttacker, iRadius)
    if not self:IsWakeUp() then
		if self:OnWakeUp(hAttacker, self.hUnit) then
			self.bWakeUp = true
        	self.hAggroAttacker = hAttacker
		end
    end
	if self:CanWakeOthers() then
		local iRadius = iRadius or self.iWakeRadius
		for _, hAlly in pairs(FindUnitsInRadius(self.hUnit:GetTeamNumber(), self.hUnit:GetAbsOrigin(), nil, iRadius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
			if hAlly.hAI ~= nil and not hAlly.hAI:IsWakeUp() then
				if hAlly.hAI:OnWakeUp(hAttacker, self.hUnit) then
					hAlly.hAI.bWakeUp = true
					hAlly.hAI.hAggroAttacker = hAttacker
				end
			end
		end
	end
end

function NeutralAI:Stop()
	self.hUnit:SetAggroTarget(nil)
	self.hUnit:SetAttacking(nil)
	self.hUnit:ExecuteOrder(DOTA_UNIT_ORDER_HOLD_POSITION)
end

function NeutralAI:Attack(hUnit)
	if hUnit:IsAttackImmune() then return end
	self.hUnit:SetAggroTarget(hUnit)
	self.hUnit:SetAttacking(hUnit)
	if CalculateDistance(self.hUnit, hUnit) >= self.hUnit:Script_GetAttackRange()*1.5 then
		self:Move(hUnit:GetAbsOrigin())
	else
		self.hUnit:ExecuteOrder(DOTA_UNIT_ORDER_ATTACK_TARGET, hUnit, nil, hUnit:GetAbsOrigin())
	end
end

function NeutralAI:Move(vPosition)
	self.hUnit:ExecuteOrder(DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, nil, vPosition)
end

function NeutralAI:RetreatHome(fAggroDelay)
	self.bRetreatingHome = not self:IsNearHome()
	if self.bRetreatingHome then
		self.hUnit:SetAggroTarget(nil)
		self.hUnit:SetAttacking(nil)
	end
    self:Move(self.vSpawnOrigin)
	self.fAggroCooldownRemainingTime = fAggroDelay or self.fAggroCooldownRemainingTime
end

function NeutralAI:Wake()
    self.hUnit:RemoveModifierByName("modifier_neutral_sleep_lua")
end

function NeutralAI:CastAbility(ability)
	local iMainBehavior = ability:GetMainBehavior()
	if iMainBehavior == DOTA_ABILITY_BEHAVIOR_PASSIVE then return false end
	local hAggroTarget = self:GetAggroTarget()
	local iTargetDistance = hAggroTarget ~= nil and CalculateDistance(self.hUnit, hAggroTarget) or -1
	local iAggroRadius = self:GetAggroRadius()
	local vCasterLocation = self.hUnit:GetAbsOrigin()
	local iCasterTeam = DOTA_TEAM_NEUTRALS
	local iCastRange = ability:GetEffectiveCastRange(vCasterLocation, self.hUnit)
	local iSearchRange = iMainBehavior == DOTA_ABILITY_BEHAVIOR_NO_TARGET and iCastRange or iAggroRadius
	local iTargetTeam = ability:GetAbilityTargetTeam()
	local iTargetType = ability:GetAbilityTargetType()
	local iTargetFlags = ability:GetAbilityTargetFlags()
	local sAbilityName = ability:GetAbilityName()
	if table.contains(AI_SPELLS["never_use"], sAbilityName) then
		return true
	elseif table.contains(AI_SPELLS["heal"], sAbilityName) then
		local allies = FindUnitsInRadius(iCasterTeam, vCasterLocation, nil, iCastRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, iTargetType, iTargetFlags, FIND_CLOSEST, false)
		table.sort(allies, function(ally1, ally2) return ally1:GetHealthPercent() < ally2:GetHealthPercent() end)
		local ally = allies[1]
		if ally ~= nil and ally:GetHealthPercent() < 100 then
			ability:OrderAbility(ally)
			return true
		end
	elseif table.contains(AI_SPELLS["only_enemy"], sAbilityName) then
		if hAggroTarget and iTargetDistance <= iSearchRange then
			ability:OrderAbility(hAggroTarget)
			return true
		end
	elseif table.contains(table.keys(AI_SPELLS["buffs"]), sAbilityName) then
		local modifier_name = AI_SPELLS["buffs"][sAbilityName]
		for _, ally in pairs(FindUnitsInRadius(iCasterTeam, vCasterLocation, nil, iCastRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, iTargetType, iTargetFlags, FIND_ANY_ORDER, false)) do
			if not ally:HasModifier(modifier_name) then
				ability:OrderAbility(ally)
				return true
			end
		end
	else
		local team = (iTargetTeam ~= DOTA_UNIT_TARGET_TEAM_ENEMY and iTargetTeam ~= DOTA_UNIT_TARGET_TEAM_FRIENDLY and iTargetTeam ~= DOTA_UNIT_TARGET_TEAM_BOTH and iTargetTeam ~= DOTA_UNIT_TARGET_TEAM_CUSTOM) and DOTA_UNIT_TARGET_TEAM_ENEMY or iTargetTeam
		local targets = iTargetType == DOTA_UNIT_TARGET_NONE and DOTA_UNIT_TARGET_HERO or iTargetType
		local flags = bit.band(iTargetFlags, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE) ~= DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE and iTargetFlags + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE or iTargetFlags
		if (team == DOTA_UNIT_TARGET_TEAM_ENEMY or team == DOTA_UNIT_TARGET_TEAM_BOTH) and hAggroTarget and iTargetDistance <= iSearchRange then
			ability:OrderAbility(aggro_target)
			return true
		elseif (team == DOTA_UNIT_TARGET_TEAM_FRIENDLY or team == DOTA_UNIT_TARGET_TEAM_BOTH) then
			local units = FindUnitsInRadius(iCasterTeam, vCasterLocation, nil, iSearchRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, targets, flags, FIND_CLOSEST, false)
			if #units > 1 then
				ability:OrderAbility(units[1])
			end
			return true
		end
	end
	return false
end

function Spawn(entityKeyValues)
	if not IsServer() then return end
	if thisEntity == nil then return end
	NeutralAI:Init(thisEntity)
end

modifier_neutral_sleep_lua = modifier_neutral_sleep_lua or class({})
function modifier_neutral_sleep_lua:IsHidden() return true end
function modifier_neutral_sleep_lua:IsPurgable() return false end
function modifier_neutral_sleep_lua:CheckState() if IsServer() then return {[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true} end end
function modifier_neutral_sleep_lua:DeclareFunctions() return {MODIFIER_PROPERTY_DISABLE_AUTOATTACK} end
function modifier_neutral_sleep_lua:GetEffectName() return "particles/neutral_fx/generic_creep_sleep.vpcf" end
function modifier_neutral_sleep_lua:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_neutral_sleep_lua:GetDisableAutoAttack() return 1 end