LinkLuaModifier("modifier_techies_land_mines_lua", "abilities/heroes/techies", LUA_MODIFIER_MOTION_NONE)

techies_land_mines_lua = techies_land_mines_lua or class(ability_lua_base)
function techies_land_mines_lua:IsHiddenWhenStolen() return false end
function techies_land_mines_lua:IsNetherWardStealable() return false end
function techies_land_mines_lua:GetIntrinsicModifierName() return "modifier_custom_indicator_lua" end
function techies_land_mines_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self.BaseClass.GetCastRange(self, vLocation, hTarget) + self:GetSpecialValueFor("cast_range_scepter_bonus")
	end
	return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end
function techies_land_mines_lua:CastFilterResultLocation(location)
	if IsServer() then
		for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if unit:GetUnitName() == "npc_dota_techies_land_mine_lua" then
				return UF_FAIL_CUSTOM
			end
		end
	end
	return UF_SUCCESS
end
function techies_land_mines_lua:GetCustomCastErrorLocation(location) return "#dota_hud_error_cant_place_near_mine" end
function techies_land_mines_lua:GetAOERadius() return self:GetSpecialValueFor("radius") end
function techies_land_mines_lua:UpdateCustomIndicator(vLocation, bOnMinimap)
	self.preview_fx = self.preview_fx or {}
	for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vLocation, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if unit:GetUnitName() == "npc_dota_techies_land_mine_lua" then
			self.preview_fx[unit:entindex()] = self.preview_fx[unit:entindex()] or ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/range_finder_tp_dest.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit, self:GetCaster():GetPlayerOwner())
			ParticleManager:SetParticleControl(self.preview_fx[unit:entindex()], 0, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.preview_fx[unit:entindex()], 2, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.preview_fx[unit:entindex()], 3, Vector(self:GetSpecialValueFor("radius"), 1, 1))
			ParticleManager:SetParticleControl(self.preview_fx[unit:entindex()], 4, Vector(255, 22, 22))
			ParticleManager:SetParticleShouldCheckFoW(self.preview_fx[unit:entindex()], true)
			ParticleManager:SetParticleFoWProperties(self.preview_fx[unit:entindex()], 0, 1, -1)
		end
	end
	return true
end
function techies_land_mines_lua:DestroyCustomIndicator()
	for mine_index, fx in pairs(self.preview_fx) do
		ParticleManager:DestroyParticle(fx, true)
		ParticleManager:ReleaseParticleIndex(fx)
	end
	self.preview_fx = {}
end
function techies_land_mines_lua:OnSpellStart()
	local mine = CreateUnitByName("npc_dota_techies_land_mine_lua", self:GetCursorPosition(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	mine:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), true)
	mine:SetOwner(self:GetCaster())
	mine:AddNewModifier(self:GetCaster(), self, "modifier_techies_land_mines_lua", {})
	FindClearSpaceForUnit(mine, mine:GetAbsOrigin(), true)
	local cast_response = {"techies_tech_setmine_01", "techies_tech_setmine_02", "techies_tech_setmine_04", "techies_tech_setmine_05", "techies_tech_setmine_06", "techies_tech_setmine_07", "techies_tech_setmine_08", "techies_tech_setmine_09", "techies_tech_setmine_10", "techies_tech_setmine_11", "techies_tech_setmine_13", "techies_tech_setmine_14", "techies_tech_setmine_16", "techies_tech_setmine_17", "techies_tech_setmine_18", "techies_tech_setmine_19", "techies_tech_setmine_20", "techies_tech_setmine_21", "techies_tech_setmine_22", "techies_tech_setmine_23", "techies_tech_setmine_24", "techies_tech_setmine_25", "techies_tech_setmine_26", "techies_tech_setmine_28", "techies_tech_setmine_29", "techies_tech_setmine_30", "techies_tech_setmine_32", "techies_tech_setmine_33", "techies_tech_setmine_34", "techies_tech_setmine_35", "techies_tech_setmine_36", "techies_tech_setmine_37", "techies_tech_setmine_38", "techies_tech_setmine_39", "techies_tech_setmine_41", "techies_tech_setmine_42", "techies_tech_setmine_43", "techies_tech_setmine_44", "techies_tech_setmine_45", "techies_tech_setmine_46", "techies_tech_setmine_47", "techies_tech_setmine_48", "techies_tech_setmine_50", "techies_tech_setmine_51", "techies_tech_setmine_52", "techies_tech_setmine_54"}
	self:GetCaster():EmitSoundOnClient(table.choice(cast_response))
	self:GetCaster():EmitSound("Hero_Techies.LandMine.Plant")
end

modifier_techies_land_mines_lua = modifier_techies_land_mines_lua or class({})
function modifier_techies_land_mines_lua:IsHidden() return true end
function modifier_techies_land_mines_lua:IsPurgable() return false end
function modifier_techies_land_mines_lua:CanParentBeAutoAttacked() return false end
function modifier_techies_land_mines_lua:CheckState()
	local states = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true}
	if self:GetElapsedTime() > self.activation_delay and not self.triggered then states[MODIFIER_STATE_INVISIBLE] = true end
	return states
end
function modifier_techies_land_mines_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE} end
function modifier_techies_land_mines_lua:OnCreated()
	self.activation_delay = self:GetAbility():GetSpecialValueFor("activation_delay")
	if not IsServer() then return end
	self.triggered = false
	self.trigger_time = 0
	self.tick_interval = 0.1
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.proximity_threshold = self:GetAbility():GetSpecialValueFor("proximity_threshold")
	self.building_damage_pct = self:GetAbility():GetSpecialValueFor("building_damage_pct")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 2, Vector(0, 0, self.radius))
	ParticleManager:SetParticleControl(fx, 3, self:GetParent():GetAbsOrigin())
	self:AddParticle(fx, false, false, -1, false, false)
	self:GetParent():SetMoveCapability(self:GetParent():GetOwner():HasTalent("special_bonus_unique_mines_movespeed") and DOTA_UNIT_CAP_MOVE_GROUND or DOTA_UNIT_CAP_MOVE_NONE)
	self:StartIntervalThink(self.tick_interval)
end
function modifier_techies_land_mines_lua:OnIntervalThink()
	if not self:GetParent():IsAlive() then self:Destroy() end
	self:GetParent():SetMoveCapability(self:GetParent():GetOwner():HasTalent("special_bonus_unique_mines_movespeed") and DOTA_UNIT_CAP_MOVE_GROUND or DOTA_UNIT_CAP_MOVE_NONE)
	if self:GetElapsedTime() <= self.activation_delay then return end
	local enemy_found = false
	for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
		if not enemy:HasFlyMovementCapability() then
			enemy_found = true
			break
		end
	end
	if not self.triggered then
		if enemy_found then
			self.triggered = true
			self.trigger_time = 0
			EmitSoundOn("Hero_Techies.LandMine.Priming", self:GetParent())
		end
	else
		if enemy_found then
			self.trigger_time = self.trigger_time + self.tick_interval
			if self.trigger_time >= self.proximity_threshold then
				local enemy_killed = false
				EmitSoundOn("Hero_Techies.LandMine.Detonate", self:GetParent())
				local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 1, Vector(1, 1, self.radius))
				ParticleManager:SetParticleControl(fx, 2, Vector(1, 1, self.radius))
				ParticleManager:SetParticleShouldCheckFoW(fx, true)
				ParticleManager:SetParticleFoWProperties(fx, 0, 1, -1)
				ParticleManager:ReleaseParticleIndex(fx)
				for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
					if not enemy:HasFlyMovementCapability() then
						local damage = not enemy:IsBuilding() and self.damage or self.damage * self.building_damage_pct / 100
						ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
						if enemy:IsTrueHero() then
							Timers:CreateTimer({endTime = FrameTime(), callback = function()
								if not enemy:IsAlive() then
									enemy_killed = true
								end
							end}, nil, self)
						end
					end
				end
				if enemy_killed and RollPercentage(25) then
					local owner = self:GetParent():GetOwner()
					Timers:CreateTimer({endTime = FrameTime() * 2, callback = function()
						local kill_response = {"techies_tech_mineblowsup_01", "techies_tech_mineblowsup_02", "techies_tech_mineblowsup_03", "techies_tech_mineblowsup_04", "techies_tech_mineblowsup_05", "techies_tech_mineblowsup_06", "techies_tech_mineblowsup_08", "techies_tech_mineblowsup_09", "techies_tech_minekill_01", "techies_tech_minekill_02", "techies_tech_minekill_03"}
						owner:EmitSoundOnClient(kill_response[RandomInt(1, #kill_response)])
					end}, nil, self)
				end
				AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 300, 1, false)
				self:GetParent():ForceKill(false)
				UTIL_Remove(self:GetParent())
				self:Destroy()
			end
		else
			self.triggered = false
			self.trigger_time = 0
		end
	end
end
function modifier_techies_land_mines_lua:GetModifierMoveSpeed_Absolute() return self:GetAbility() ~= nil and math.max(0.1, self:GetAbility():FindTalentValue("special_bonus_unique_mines_movespeed")) or false end

LinkLuaModifier("modifier_techies_stasis_trap_lua", "abilities/heroes/techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_techies_stasis_trap_lua_root", "abilities/heroes/techies", LUA_MODIFIER_MOTION_NONE)

techies_stasis_trap_lua = techies_stasis_trap_lua or class(ability_lua_base)
function techies_stasis_trap_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self.BaseClass.GetCastRange(self, vLocation, hTarget) + self:GetSpecialValueFor("cast_range_scepter_bonus")
	end
	return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end
function techies_stasis_trap_lua:GetAOERadius() return self:GetSpecialValueFor("activation_radius") end
function techies_stasis_trap_lua:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Techies.StasisTrap.Plant")
	return true
end
function techies_stasis_trap_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_Techies.StasisTrap.Plant")
	return true
end
function techies_stasis_trap_lua:OnSpellStart()
	local trap = CreateUnitByName("npc_dota_techies_stasis_trap_lua", self:GetCursorPosition(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	trap:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), true)
	trap:SetOwner(self:GetCaster())
	Timers:CreateTimer({endTime = 1.13, callback = function()
		if not IsValidEntity(trap) then return end
		trap:StartGesture(ACT_DOTA_IDLE)
	end}, nil, self)
	trap:AddNewModifier(self:GetCaster(), self, "modifier_techies_stasis_trap_lua", {})
	FindClearSpaceForUnit(trap, trap:GetAbsOrigin(), true)
	local cast_response = {"techies_tech_settrap_01", "techies_tech_settrap_02", "techies_tech_settrap_03", "techies_tech_settrap_04", "techies_tech_settrap_06", "techies_tech_settrap_07", "techies_tech_settrap_08", "techies_tech_settrap_09", "techies_tech_settrap_10", "techies_tech_settrap_11"}
	if RollPercentage(75) then
		self:GetCaster():EmitSoundOnClient(cast_response[math.random(1,#cast_response)])
	end
end

modifier_techies_stasis_trap_lua = modifier_techies_stasis_trap_lua or class({})
function modifier_techies_stasis_trap_lua:IsHidden() return true end
function modifier_techies_stasis_trap_lua:IsPurgable() return false end
function modifier_techies_stasis_trap_lua:IsDebuff() return false end
function modifier_techies_stasis_trap_lua:CanParentBeAutoAttacked() return false end
function modifier_techies_stasis_trap_lua:CheckState()
	local states = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true}
	if self:GetElapsedTime() > self.activation_time then states[MODIFIER_STATE_INVISIBLE] = true end
	return states
end
function modifier_techies_stasis_trap_lua:OnCreated()
	self.activation_time = self:GetAbility():GetSpecialValueFor("activation_time")
	if not IsServer() then return end
	self.root_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
	self.activation_radius = self:GetAbility():GetSpecialValueFor("activation_radius")
	self.root_radius = self:GetAbility():GetSpecialValueFor("stun_radius")
	self:GetParent():SetMoveCapability(self:GetParent():GetOwner():HasTalent("special_bonus_unique_mines_movespeed") and DOTA_UNIT_CAP_MOVE_GROUND or DOTA_UNIT_CAP_MOVE_NONE)
	self:StartIntervalThink(0.1)
end
function modifier_techies_stasis_trap_lua:OnIntervalThink()
	if not self:GetParent():IsAlive() then self:Destroy() return end
	self:GetParent():SetMoveCapability(self:GetParent():GetOwner():HasTalent("special_bonus_unique_mines_movespeed") and DOTA_UNIT_CAP_MOVE_GROUND or DOTA_UNIT_CAP_MOVE_NONE)
	if self:GetElapsedTime() <= self.activation_time then return end
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.activation_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	if #enemies > 0 then
		EmitSoundOn("Hero_Techies.StasisTrap.Stun", self:GetParent())
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, Vector(self.root_radius, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(fx)
		for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.root_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_techies_stasis_trap_lua_root", {duration = self.root_duration})
		end
		for _, trap in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.root_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if trap:GetUnitName() == self:GetParent():GetUnitName() and trap ~= self:GetParent() then
				trap:AddNoDraw()
				UTIL_Remove(trap)
			end
		end
		AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 600, 1, false)
		self:GetParent():ForceKill(false)
		UTIL_Remove(self:GetParent())
		self:Destroy()
	end
end
function modifier_techies_stasis_trap_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE} end
function modifier_techies_stasis_trap_lua:GetModifierMoveSpeed_Absolute() return self:GetAbility() ~= nil and math.max(0.1, self:GetAbility():FindTalentValue("special_bonus_unique_mines_movespeed")) or false end

modifier_techies_stasis_trap_lua_root = modifier_techies_stasis_trap_lua_root or class({})
function modifier_techies_stasis_trap_lua_root:IsPurgable() return true end
function modifier_techies_stasis_trap_lua_root:IsDebuff() return true end
function modifier_techies_stasis_trap_lua_root:GetStatusEffectName() return "particles/status_fx/status_effect_techies_stasis.vpcf" end
function modifier_techies_stasis_trap_lua_root:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end

LinkLuaModifier("modifier_techies_suicide_lua", "abilities/heroes/techies", LUA_MODIFIER_MOTION_BOTH)

techies_suicide_lua = techies_suicide_lua or class(ability_lua_base)
function techies_suicide_lua:GetAOERadius() return self:GetSpecialValueFor("radius") end
function techies_suicide_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasShard() then
		return self.BaseClass.GetCastRange(self, vLocation, hTarget) + self:GetSpecialValueFor("shard_bonus_cast_range")
	end
	return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end
function techies_suicide_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_techies_suicide_lua", {vLocX = self:GetCursorPosition().x, vLocY = self:GetCursorPosition().y, vLocZ = self:GetCursorPosition().z})
	self:GetCaster():EmitSound("Hero_Techies.BlastOff.Cast")
end
function techies_suicide_lua:BlowUp()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_silence", {duration = self:GetSpecialValueFor("silence_duration")})
		ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("damage") + (enemy:GetHealth()*self:GetSpecialValueFor("hp_dmg")/100), damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE})
		if self:GetCaster():HasShard() then
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("shard_stun_duration")})
		end
	end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(fx, 0, self:GetCaster():GetOrigin())
	ParticleManager:SetParticleControl(fx, 1, Vector(self:GetSpecialValueFor("radius"), 0.0, 1.0))
	ParticleManager:SetParticleControl(fx, 2, Vector(self:GetSpecialValueFor("radius"), 0.0, 1.0))
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("Hero_Techies.Suicide")
	GridNav:DestroyTreesAroundPoint(self:GetCaster():GetOrigin(), 150, false)
	if self:GetCaster():IsAlive() then
		ApplyDamage({victim = self:GetCaster(), attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("hp_cost") * self:GetCaster():GetMaxHealth() / 100, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	end
end

modifier_techies_suicide_lua = modifier_techies_suicide_lua or class({})
function modifier_techies_suicide_lua:IsHidden() return true end
function modifier_techies_suicide_lua:IsPurgable() return false end
function modifier_techies_suicide_lua:RemoveOnDeath() return false end
function modifier_techies_suicide_lua:OnCreated(kv)
	if not IsServer() then return end
	self.bHorizontalMotionInterrupted = false
	if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
		self:Destroy()
		return
	end
	self.vStartPosition = GetGroundPosition(self:GetParent():GetOrigin(), self:GetParent())
	self.flCurrentTimeHoriz = 0.0
	self.flCurrentTimeVert = 0.0
	self.vLoc = Vector(kv.vLocX, kv.vLocY, kv.vLocZ)
	self.vLastKnownTargetPos = self.vLoc
	local flAccelerationZ = 4000
	local flDesiredHeight = 500 * self:GetAbility():GetSpecialValueFor("duration") * self:GetAbility():GetSpecialValueFor("duration")
	local flLowZ = math.min(self.vLastKnownTargetPos.z, self.vStartPosition.z)
	local flHighZ = math.max(self.vLastKnownTargetPos.z, self.vStartPosition.z)
	local flArcTopZ = math.max(flLowZ + flDesiredHeight, flHighZ + 100)
	local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
	self.flInitialVelocityZ = math.sqrt(2.0 * flArcDeltaZ * flAccelerationZ)
	local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
	local flSqrtDet = math.sqrt(math.max(0, (self.flInitialVelocityZ * self.flInitialVelocityZ) - 2.0 * flAccelerationZ * flDeltaZ))
	self.flPredictedTotalTime = math.max((self.flInitialVelocityZ + flSqrtDet) / flAccelerationZ, (self.flInitialVelocityZ - flSqrtDet) / flAccelerationZ)
	self.vHorizontalVelocity = (self.vLastKnownTargetPos - self.vStartPosition) / self.flPredictedTotalTime
	self.vHorizontalVelocity.z = 0.0
	local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
	self:AddParticle(nFXIndex, false, false, -1, false, false)
end
function modifier_techies_suicide_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController(self)
	self:GetParent():RemoveVerticalMotionController(self)
end
function modifier_techies_suicide_lua:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_techies_suicide_lua:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_techies_suicide_lua:UpdateHorizontalMotion(me, dt)
	self.flCurrentTimeHoriz = math.min(self.flCurrentTimeHoriz + dt, self.flPredictedTotalTime)
	local vOldPos = me:GetOrigin()
	local vToDesired = (self.vStartPosition + (self.flCurrentTimeHoriz / self.flPredictedTotalTime) * (self.vLastKnownTargetPos - self.vStartPosition)) - vOldPos
	vToDesired.z = 0.0
	local vVelDif = (vToDesired / dt) - self.vHorizontalVelocity
	local flVelDif = vVelDif:Length2D()
	vVelDif = vVelDif:Normalized()
	self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * math.min(flVelDif, 3000) * dt
	me:SetOrigin(vOldPos + self.vHorizontalVelocity * dt)
end
function modifier_techies_suicide_lua:UpdateVerticalMotion(me, dt)
	local flAccelerationZ = 4000
	self.flCurrentTimeVert = self.flCurrentTimeVert + dt
	local vNewPos = me:GetOrigin()
	vNewPos.z = self.vStartPosition.z + (-0.5 * flAccelerationZ * (self.flCurrentTimeVert * self.flCurrentTimeVert) + self.flInitialVelocityZ * self.flCurrentTimeVert)
	local flGroundHeight = GetGroundHeight(vNewPos, self:GetParent())
	local bLanded = false
	if (vNewPos.z < flGroundHeight and (-flAccelerationZ * self.flCurrentTimeVert + self.flInitialVelocityZ) < 0) then
		vNewPos.z = flGroundHeight
		bLanded = true
	end
	me:SetOrigin(vNewPos)
	if bLanded == true then
		if self.bHorizontalMotionInterrupted == false then
			self:GetAbility():BlowUp()
		end
		self:GetParent():RemoveHorizontalMotionController(self)
		self:GetParent():RemoveVerticalMotionController(self)
		self:SetDuration(0.15, true)
	end
end
function modifier_techies_suicide_lua:OnHorizontalMotionInterrupted()
	self.bHorizontalMotionInterrupted = true
end
function modifier_techies_suicide_lua:OnVerticalMotionInterrupted()
	self:Destroy()
end
function modifier_techies_suicide_lua:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_2 end

LinkLuaModifier("modifier_techies_remote_mines_lua", "abilities/heroes/techies", LUA_MODIFIER_MOTION_NONE)

techies_remote_mines_lua = techies_remote_mines_lua or class(ability_lua_base)
function techies_remote_mines_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self.BaseClass.GetCastRange(self, vLocation, hTarget) + self:GetSpecialValueFor("cast_range_scepter_bonus")
	end
	return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end
function techies_remote_mines_lua:GetAssociatedSecondaryAbilities() return "techies_focused_detonate_lua" end
function techies_remote_mines_lua:OnUpgrade()
	self:GetCaster():FindAbilityByName("techies_focused_detonate_lua"):SetLevel(1)
end
function techies_remote_mines_lua:OnAbilityPhaseStart()
	self.mine = CreateUnitByName("npc_dota_techies_remote_mine_lua", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	self.mine:MakeDummy()
	self.mine:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = 3.0})
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mine_plant.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_remote", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.pfx, 1, self:GetCursorPosition())
	ParticleManager:SetParticleControlEnt(self.pfx, 2, self.mine, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.mine:GetAbsOrigin(), true)
	self:GetCaster():EmitSound("Hero_Techies.RemoteMine.Toss")
	return true
end
function techies_remote_mines_lua:OnAbilityPhaseInterrupted()
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	if IsValidEntity(self.mine) then
		UTIL_Remove(self.mine)
	end
end
function techies_remote_mines_lua:OnSpellStart()
	if IsValidEntity(self.mine) then
		UTIL_Remove(self.mine)
	end
	local mine = CreateUnitByName("npc_dota_techies_remote_mine_lua", self:GetCursorPosition(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	mine:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	mine:FindAbilityByName("techies_remote_mines_self_detonate_lua"):SetLevel(1)
	mine:SetOwner(self:GetCaster())
	mine:AddNewModifier(self:GetCaster(), self, "modifier_techies_remote_mines_lua", {})
	mine:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	FindClearSpaceForUnit(mine, mine:GetAbsOrigin(), true)
	mine:SetForwardVector(self:GetCaster():GetForwardVector())
	mine:SetAngles(RandomFloat(10, 15) * (RollPercentage(50) and 1 or -1), 0, 0)
	mine:EmitSound("Hero_Techies.RemoteMine.Plant")
	local cast_response = {"techies_tech_remotemines_03", "techies_tech_remotemines_04", "techies_tech_remotemines_05", "techies_tech_remotemines_07", "techies_tech_remotemines_08", "techies_tech_remotemines_09", "techies_tech_remotemines_13", "techies_tech_remotemines_14", "techies_tech_remotemines_15", "techies_tech_remotemines_17", "techies_tech_remotemines_18", "techies_tech_remotemines_19", "techies_tech_remotemines_20", "techies_tech_remotemines_25", "techies_tech_remotemines_26", "techies_tech_remotemines_27", "techies_tech_remotemines_30", "techies_tech_remotemines_02", "techies_tech_remotemines_10", "techies_tech_remotemines_11", "techies_tech_remotemines_16", "techies_tech_remotemines_21", "techies_tech_remotemines_22", "techies_tech_remotemines_23", "techies_tech_remotemines_28", "techies_tech_remotemines_29"}
	local sound = RollPercentage(1) and "techies_tech_remotemines_01" or cast_response[math.random(1, #cast_response)]
	self:GetCaster():EmitSoundOnClient(sound)
end
techies_remote_mines_self_detonate_lua = techies_remote_mines_self_detonate_lua or class(ability_lua_base)
function techies_remote_mines_self_detonate_lua:ProcsMagicStick() return false end
function techies_remote_mines_self_detonate_lua:OnSpellStart()
	local mines = table.values(table.filter(table.map(PlayerResource:GetSelectedEntities(self:GetCaster():GetOwner():GetPlayerOwnerID()), function(k, v)
		return EntIndexToHScript(v)
	end), function(k, v)
		return v:GetUnitName() == self:GetCaster():GetUnitName() and v:GetTeamNumber() == self:GetCaster():GetOwner():GetTeamNumber() and v:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() and not v:IsDummy() and v ~= self:GetCaster()
	end))
	if not table.contains(mines, self:GetCaster()) then table.insert(mines, self:GetCaster()) end
	local i = 1
	Timers:CreateTimer({endTime = 0.03, callback = function()
		if i > table.length(mines) then return end
		if IsValidEntity(mines[i]) then
			mines[i]:FindAbilityByName(self:GetAbilityName()):Explode()
		end
		i = i + 1
		return 0.03
	end}, nil, self)
end
function techies_remote_mines_self_detonate_lua:Explode()
	local lvl = self:GetCaster():FindModifierByName("modifier_techies_remote_mines_lua").lvl
	local ability = self:GetCaster():GetOwner():FindAbilityByName("techies_remote_mines_lua")
	local damage = ability == nil and 0 or not self:GetCaster():GetOwner():HasScepter() and ability:GetLevelSpecialValueFor("damage", lvl) or ability:GetLevelSpecialValueFor("damage_scepter", lvl)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(fx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, Vector(ability == nil and 0 or ability:GetSpecialValueFor("radius"), 1, 1))
	ParticleManager:SetParticleControl(fx, 3, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fx)
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, ability == nil and 0 or ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
	end
	self:GetCaster():ForceKill(false)
	Timers:CreateTimer({endTime = RandomFloat(0.01, 0.08), callback = function()
		if not self:IsNull() and IsValidEntity(self:GetCaster()) then
			EmitSoundOn("Hero_Techies.RemoteMine.Detonate", self:GetCaster())
			UTIL_Remove(self:GetCaster())
		end
	end}, nil, self)
end
modifier_techies_remote_mines_lua = modifier_techies_remote_mines_lua or class({})
function modifier_techies_remote_mines_lua:IsHidden() return true end
function modifier_techies_remote_mines_lua:IsPurgable() return false end
function modifier_techies_remote_mines_lua:IsDebuff() return false end
function modifier_techies_remote_mines_lua:CanParentBeAutoAttacked() return false end
function modifier_techies_remote_mines_lua:CheckState()
	local states = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true}
	if self:GetElapsedTime() > self.activation_time then states[MODIFIER_STATE_INVISIBLE] = true end
	return states
end
function modifier_techies_remote_mines_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE} end
function modifier_techies_remote_mines_lua:OnCreated()
	self.model_scale = self:GetAbility():GetSpecialValueFor("model_scale")
	self.lvl = self:GetAbility():GetLevel()
	self.activation_time = self:GetAbility():GetSpecialValueFor("activation_time")
	if not IsServer() then return end
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mine.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(fx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 3, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetParent():SetMoveCapability(self:GetParent():GetOwner():HasTalent("special_bonus_unique_mines_movespeed") and DOTA_UNIT_CAP_MOVE_GROUND or DOTA_UNIT_CAP_MOVE_NONE)
	self:StartIntervalThink(0.1)
end
function modifier_techies_remote_mines_lua:OnIntervalThink()
	self:GetParent():SetMoveCapability(self:GetParent():GetOwner():HasTalent("special_bonus_unique_mines_movespeed") and DOTA_UNIT_CAP_MOVE_GROUND or DOTA_UNIT_CAP_MOVE_NONE)
end
function modifier_techies_remote_mines_lua:GetModifierModelScale() return self.model_scale end
function modifier_techies_remote_mines_lua:GetModifierMoveSpeed_Absolute() return self:GetAbility() ~= nil and math.max(0.1, self:GetAbility():FindTalentValue("special_bonus_unique_mines_movespeed")) or false end

techies_focused_detonate_lua = techies_focused_detonate_lua or class(ability_lua_base)
function techies_focused_detonate_lua:IsStealable() return false end
function techies_focused_detonate_lua:GetAOERadius() return self:GetSpecialValueFor("radius") end
function techies_focused_detonate_lua:RequiresFacing() return false end
function techies_focused_detonate_lua:GetAssociatedPrimaryAbilities() return "techies_remote_mines_lua" end
function techies_focused_detonate_lua:OnSpellStart()
	local mines = table.values(table.filter(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false), function(k, v)
		return v:GetUnitName() == "npc_dota_techies_remote_mine_lua" and v:GetOwner():GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() and not v:IsDummy()
	end))
	for _, mine in pairs(mines) do
		EmitSoundOn("Hero_Techies.RemoteMine.Activate", mine)
		Timers:CreateTimer({endTime = self:GetCaster():FindAbilityByName("techies_remote_mines_lua"):GetSpecialValueFor("detonate_delay"), callback = function()
			if IsValidEntity(mine) then
				mine:FindAbilityByName("techies_remote_mines_self_detonate_lua"):Explode()
			end
		end}, nil, self)
	end
end

LinkLuaModifier("modifier_techies_minefield_sign_lua", "abilities/heroes/techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_techies_minefield_sign_lua_detection", "abilities/heroes/techies", LUA_MODIFIER_MOTION_NONE)

techies_minefield_sign_lua = techies_minefield_sign_lua or class(ability_lua_base)
function techies_minefield_sign_lua:IsStealable() return false end
function techies_minefield_sign_lua:GetCastRange(vLocation, hTarget)
	local cast_range = self.BaseClass.GetCastRange(self, vLocation, hTarget)
	if self:GetCaster():GetCastRangeBonus() + cast_range < 150 then
		return 150
	end
	return cast_range
end
function techies_minefield_sign_lua:GetAOERadius() return self:GetSpecialValueFor("aura_radius") end
function techies_minefield_sign_lua:OnSpellStart()
	if self.assigned_sign and IsValidEntity(self.assigned_sign) then
		self.assigned_sign:ForceKill(false)
	end
	local sign = CreateUnitByName("npc_dota_techies_minefield_sign_lua", self:GetCursorPosition(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	self.assigned_sign = sign
	sign:AddNewModifier(self:GetCaster(), self, "modifier_techies_minefield_sign_lua", {})
	sign:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("lifetime")})
	FindClearSpaceForUnit(sign, sign:GetAbsOrigin(), true)
	sign:SetForwardVector(Vector(RandomFloat(-0.5, 0.5), RandomFloat(-0.5, -1), 0))
	self:GetCaster():EmitSound("Hero_Techies.Sign")
end
modifier_techies_minefield_sign_lua = modifier_techies_minefield_sign_lua or class({})
function modifier_techies_minefield_sign_lua:IsHidden() return false end
function modifier_techies_minefield_sign_lua:IsPurgable() return false end
function modifier_techies_minefield_sign_lua:IsDebuff() return false end
function modifier_techies_minefield_sign_lua:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_STUNNED] = true} end
function modifier_techies_minefield_sign_lua:GetAuraEntityReject(hTarget)
	return not table.contains({"npc_dota_techies_remote_mine_lua", "npc_dota_techies_stasis_trap_lua", "npc_dota_techies_land_mine_lua"}, hTarget:GetUnitName())
end
function modifier_techies_minefield_sign_lua:GetAuraRadius() return self.aura_radius end
function modifier_techies_minefield_sign_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_techies_minefield_sign_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_techies_minefield_sign_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_OTHER end
function modifier_techies_minefield_sign_lua:GetAuraDuration() return 0.1 end
function modifier_techies_minefield_sign_lua:GetModifierAura() return "modifier_techies_minefield_sign_lua_detection" end
function modifier_techies_minefield_sign_lua:IsAura() return self:GetCaster():HasScepter() end
function modifier_techies_minefield_sign_lua:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
end
modifier_techies_minefield_sign_lua_detection = modifier_techies_minefield_sign_lua_detection or class({})
function modifier_techies_minefield_sign_lua_detection:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_techies_minefield_sign_lua_detection:CheckState() return {[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true, [MODIFIER_STATE_INVISIBLE] = true} end
function modifier_techies_minefield_sign_lua_detection:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_techies_minefield_sign_lua_detection:GetModifierInvisibilityLevel() return 1 end