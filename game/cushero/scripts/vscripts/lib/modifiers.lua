modifier_flying_vision_lua = modifier_flying_vision_lua or class({})
function modifier_flying_vision_lua:IsHidden() return true end
function modifier_flying_vision_lua:IsPurgable() return false end
function modifier_flying_vision_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_flying_vision_lua:CheckState() return {[MODIFIER_STATE_FORCED_FLYING_VISION] = true} end

modifier_invulnerable_lua = modifier_invulnerable_lua or class({})
function modifier_invulnerable_lua:IsHidden() return true end
function modifier_invulnerable_lua:IsPurgable() return false end
function modifier_invulnerable_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_invulnerable_lua:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_OUT_OF_GAME] = true} end

modifier_fake_invulnerable = modifier_fake_invulnerable or class({})
function modifier_fake_invulnerable:IsHidden() return true end
function modifier_fake_invulnerable:IsPurgable() return false end
function modifier_fake_invulnerable:CanParentBeAutoAttacked() return false end
function modifier_fake_invulnerable:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fake_invulnerable:CheckState()
	local is_friend = (IsServer() and {false} or {GetLocalPlayerTeam(GetLocalPlayerID()) == self:GetParent():GetTeamNumber()})[1]
	return {[MODIFIER_STATE_ATTACK_IMMUNE] = is_friend, [MODIFIER_STATE_INVULNERABLE] = is_friend, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_CANNOT_TARGET_ENEMIES] = is_friend, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_UNTARGETABLE_ENEMY] = true, [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true, [MODIFIER_STATE_SPECIALLY_UNDENIABLE] = true, [MODIFIER_STATE_DEBUFF_IMMUNE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true}
end
function modifier_fake_invulnerable:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE, MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_EVENT_ON_ATTACK_START} end
function modifier_fake_invulnerable:OnAttackStart(kv)
	if not IsServer() then return end
	if kv.target ~= self:GetParent() then return end
	kv.attacker:Stop()
end
function modifier_fake_invulnerable:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_fake_invulnerable:GetAbsoluteNoDamageMagical() return 1 end
function modifier_fake_invulnerable:GetAbsoluteNoDamagePure() return 1 end
function modifier_fake_invulnerable:GetModifierStatusResistance() return 100 end

modifier_fake_invulnerable_both = modifier_fake_invulnerable_both or class({})
function modifier_fake_invulnerable_both:IsHidden() return true end
function modifier_fake_invulnerable_both:IsPurgable() return false end
function modifier_fake_invulnerable_both:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_fake_invulnerable_both:CheckState()
	return {[MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_CANNOT_TARGET_ENEMIES] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_SPECIALLY_UNDENIABLE] = true, [MODIFIER_STATE_DEBUFF_IMMUNE] = true}
end
function modifier_fake_invulnerable_both:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE, MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_EVENT_ON_ATTACK_START} end
function modifier_fake_invulnerable_both:OnAttackStart(kv)
	if not IsServer() then return end
	if kv.target ~= self:GetParent() then return end
	kv.attacker:Stop()
end
function modifier_fake_invulnerable_both:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_fake_invulnerable_both:GetAbsoluteNoDamageMagical() return 1 end
function modifier_fake_invulnerable_both:GetAbsoluteNoDamagePure() return 1 end
function modifier_fake_invulnerable_both:GetModifierStatusResistance() return 100 end

modifier_dummy_unit = modifier_dummy_unit or class({})
function modifier_dummy_unit:IsHidden() return true end
function modifier_dummy_unit:IsPurgable() return false end
function modifier_dummy_unit:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_dummy_unit:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = self.invulnerable, [MODIFIER_STATE_UNSELECTABLE] = self.unselectable, [MODIFIER_STATE_NOT_ON_MINIMAP] = self.not_on_minimap, [MODIFIER_STATE_NO_HEALTH_BAR] = self.no_healthbar, [MODIFIER_STATE_OUT_OF_GAME] = self.out_of_game} end
function modifier_dummy_unit:OnCreated(kv)
	if not IsServer() then return end
	if kv.invulnerable ~= nil then self.invulnerable = BoolToNum(kv.invulnerable) else self.invulnerable = true end
	if kv.unselectable ~= nil then self.unselectable = BoolToNum(kv.unselectable) else self.unselectable = true end
	if kv.not_on_minimap ~= nil then self.not_on_minimap = BoolToNum(kv.not_on_minimap) else self.not_on_minimap = true end
	if kv.no_healthbar ~= nil then self.no_healthbar = BoolToNum(kv.no_healthbar) else self.no_healthbar = true end
	if kv.out_of_game ~= nil then self.out_of_game = BoolToNum(kv.out_of_game) else self.out_of_game = true end
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_dummy_unit:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_dummy_unit:AddCustomTransmitterData() return {invulnerable = self.invulnerable, unselectable = self.unselectable, not_on_minimap = self.not_on_minimap, no_healthbar = self.no_healthbar, out_of_game = self.out_of_game} end
function modifier_dummy_unit:HandleCustomTransmitterData(kv)
	self.invulnerable = BoolToNum(kv.invulnerable)
	self.unselectable = BoolToNum(kv.unselectable)
	self.not_on_minimap = BoolToNum(kv.not_on_minimap)
	self.no_healthbar = BoolToNum(kv.no_healthbar)
	self.out_of_game = BoolToNum(kv.out_of_game)
end

modifier_invisible_lua = modifier_invisible_lua or class({})
function modifier_invisible_lua:IsHidden() return self.hidden end
function modifier_invisible_lua:IsPurgable() return self.purgable and not self.strong end
function modifier_invisible_lua:IsPurgeException() return self.strong end
function modifier_invisible_lua:GetTexture() if self.texture then return self.texture end end
function modifier_invisible_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_invisible_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_INVISIBILITY_ATTACK_BEHAVIOR_EXCEPTION} end
function modifier_invisible_lua:CheckState()
	if self:GetElapsedTime() > self.delay then
		if self.immune then return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true} end
		return {[MODIFIER_STATE_INVISIBLE] = true}
	end
end
function modifier_invisible_lua:OnCreated(kv)
	if not IsServer() then return end
	if kv.hidden ~= nil then self.hidden = BoolToNum(kv.hidden) else self.hidden = false end
	if kv.purgable ~= nil then self.purgable = BoolToNum(kv.purgable) else self.purgable = false end
	if kv.strong ~= nil then self.strong = BoolToNum(kv.strong) else self.strong = false end
	if kv.delay ~= nil then self.delay = kv.delay else self.delay = 0.5 end
	if kv.reveal_ability ~= nil then self.reveal_ability = BoolToNum(kv.reveal_ability) else self.reveal_ability = true end
	if kv.reveal_attack ~= nil then self.reveal_attack = BoolToNum(kv.reveal_attack) else self.reveal_attack = true end
	if kv.immune ~= nil then self.immune = BoolToNum(kv.immune) else self.immune = false end
	self.texture = kv.texture
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	Timers:CreateTimer({endTime = math.max(self.delay - 0.5, FrameTime()), callback = function()
		if self:IsNull() then return end
		local fx = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(fx)
	end}, nil, self)
end
function modifier_invisible_lua:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_invisible_lua:AddCustomTransmitterData() return {hidden = self.hidden, purgable = self.purgable, strong = self.strong, delay = self.delay, immune = self.immune, texture = self.texture} end
function modifier_invisible_lua:HandleCustomTransmitterData(kv)
	self.hidden = BoolToNum(kv.hidden)
	self.purgable = BoolToNum(kv.purgable)
	self.strong = BoolToNum(kv.strong)
	self.delay = kv.delay
	self.immune = BoolToNum(kv.immune)
	self.texture = kv.texture
end
function modifier_invisible_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or self:GetElapsedTime() <= self.delay or not self.reveal_attack then return end
	self:Destroy()
end
function modifier_invisible_lua:OnAbilityFullyCast(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() or self:GetElapsedTime() <= self.delay or not self.reveal_ability then return end
	self:Destroy()
end
function modifier_invisible_lua:GetModifierInvisibilityLevel() return math.min(self:GetElapsedTime() / self.delay, 1) end
function modifier_invisible_lua:GetModifierInvisibilityAttackBehaviorException() if not self.reveal_ability and not self.reveal_attack then return 1 end end

modifier_custom_indicator_lua = modifier_custom_indicator_lua or class({})
function modifier_custom_indicator_lua:IsHidden() return true end
function modifier_custom_indicator_lua:IsPurgable() return false end
function modifier_custom_indicator_lua:RemoveOnDeath() return false end
function modifier_custom_indicator_lua:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_custom_indicator_lua:OnCreated()
	if not IsServer() then return end
	self.has_indicator = false
	self:StartIntervalThink(FrameTime())
end
function modifier_custom_indicator_lua:OnDestroy()
	if not IsServer() then return end
	self:GetAbility():DestroyCustomIndicator()
end
function modifier_custom_indicator_lua:OnIntervalThink()
	local active_ability = PlayerResource:GetActiveAbility(self:GetParent():GetPlayerOwnerID())
	local on_minimap = PlayerResource:IsCursorOnMinimap(self:GetParent():GetPlayerOwnerID())
	if active_ability ~= nil and active_ability == self:GetAbility() then
		local has = self:GetAbility():UpdateCustomIndicator(PlayerResource:GetCursorPosition(self:GetCaster():GetPlayerOwnerID()), on_minimap)
		if has then
			self.has_indicator = true
		end
	elseif self.has_indicator then
		self:GetAbility():DestroyCustomIndicator()
		self.has_indicator = false
	end
end

modifier_unselectable_lua = modifier_unselectable_lua or class({})
function modifier_unselectable_lua:IsHidden() return self.hidden end
function modifier_unselectable_lua:IsPurgable() return self.purgable and not self.strong end
function modifier_unselectable_lua:IsPurgeException() return self.strong end
function modifier_unselectable_lua:GetTexture() if self.texture then return self.texture end end
function modifier_unselectable_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_unselectable_lua:CheckState() return {[MODIFIER_STATE_UNSELECTABLE] = true} end
function modifier_unselectable_lua:OnCreated(kv)
	if not IsServer() then return end
	if kv.hidden ~= nil then self.hidden = BoolToNum(kv.hidden) else self.hidden = false end
	if kv.purgable ~= nil then self.purgable = BoolToNum(kv.purgable) else self.purgable = false end
	if kv.strong ~= nil then self.strong = BoolToNum(kv.strong) else self.strong = false end
	self.texture = kv.texture
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
end
function modifier_unselectable_lua:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_unselectable_lua:AddCustomTransmitterData() return {hidden = self.hidden, purgable = self.purgable, strong = self.strong, texture = self.texture} end
function modifier_unselectable_lua:HandleCustomTransmitterData(kv)
	self.hidden = BoolToNum(kv.hidden)
	self.purgable = BoolToNum(kv.purgable)
	self.strong = BoolToNum(kv.strong)
	self.texture = kv.texture
end

modifier_taunted_lua = modifier_taunted_lua or class({})
function modifier_taunted_lua:IsHidden() return self.hidden end
function modifier_taunted_lua:IsPurgable() return self.purgable and not self.strong end
function modifier_taunted_lua:IsPurgeException() return self.strong end
function modifier_taunted_lua:GetTexture() if self.texture then return self.texture elseif self:GetAbility() then return GetAbilityTextureNameForAbility(self:GetAbility():GetAbilityName()) end end
function modifier_taunted_lua:CheckState() return {[MODIFIER_STATE_TAUNTED] = true} end
function modifier_taunted_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_taunted_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_taunted_lua:GetPriority() return self.priority end
function modifier_taunted_lua:GetEffectName() if self.effect then return self.effect end end
function modifier_taunted_lua:GetEffectAttachType() if self.effect and self.effect_attach then return self.effect_attach end end
function modifier_taunted_lua:GetStatusEffectName() if self.status_effect then return self.status_effect end end
function modifier_taunted_lua:StatusEffectPriority() if self.status_effect and self.status_priority then return self.status_priority end end
function modifier_taunted_lua:GetHeroEffectName() if self.hero_effect then return self.hero_effect end end
function modifier_taunted_lua:StatusEffectPriority() if self.hero_effect and self.hero_priority then return self.hero_priority end end
function modifier_taunted_lua:OnCreated(kv)
	if not IsServer() then return end
	self:destroy_other_me()
	if kv.hidden ~= nil then self.hidden = BoolToNum(kv.hidden) else self.hidden = false end
	if kv.purgable ~= nil then self.purgable = BoolToNum(kv.purgable) else self.purgable = false end
	if kv.strong ~= nil then self.strong = BoolToNum(kv.strong) else self.strong = false end
	self.texture = kv.texture
	if kv.target ~= nil then self.target = kv.target else self.target = self:GetCaster() end
	if kv.priority ~= nil then self.priority = kv.priority else self.priority = MODIFIER_PRIORITY_NORMAL end
	self.priority = kv.priority ~= nil and kv.priority or MODIFIER_PRIORITY_NORMAL
	self.effect = kv.effect
	if kv.effect_attach ~= nil then self.effect_attach = kv.effect_attach else self.effect_attach = PATTACH_ABSORIGIN_FOLLOW end
	self.status_effect = kv.status_effect
	self.status_priority = kv.status_priority
	self.hero_effect = kv.hero_effect
	self.hero_priority = kv.hero_priority
	self:SetHasCustomTransmitterData(true)
	self:SendBuffRefreshToClients()
	self:StartIntervalThink(FrameTime())
	if not self:is_highest() then return end
	self:GetParent():Stop()
end
function modifier_taunted_lua:OnRefresh(kv)
	if not IsServer() then return end
	self:destroy_other_me()
	self:OnCreated(kv)
end
function modifier_taunted_lua:OnIntervalThink()
	if not self:is_highest() then return end
	if self:GetParent():CanEntityBeSeenByMyTeam(self.target) then
		if self:GetParent():IsCreep() then
			if self:GetParent():GetTeamNumber() ~= self.target:GetTeamNumber() then
				self:GetParent():SetForceAttackTarget(self.target)
			else
				self:GetParent():SetForceAttackTargetAlly(self.target)
			end
			self:GetParent():MoveToTargetToAttack(self.target)
		else
			ExecuteOrderFromTable({UnitIndex = self:GetParent():entindex(), OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, TargetIndex = self.target:entindex(), Position = self.target:GetAbsOrigin(), Queue = false})
		end
	else
		self:GetParent():Interrupt()
		self:GetParent():Stop()
	end
end
function modifier_taunted_lua:OnDestroy()
	if not IsServer() then return end
	if not self:is_highest() then return end
	self:GetParent():SetForceAttackTarget(nil)
	self:GetParent():SetForceAttackTargetAlly(nil)
end
function modifier_taunted_lua:OnDeath(kv)
	if not IsServer() then return end
	if kv.unit == self.target then self:Destroy() end
end
function modifier_taunted_lua:AddCustomTransmitterData() return {hidden = self.hidden, purgable = self.purgable, strong = self.strong, texture = self.texture, priority = self.priority, effect = self.effect, effect_attach = self.effect_attach, status_effect = self.status_effect, status_priority = self.status_priority, hero_effect = self.hero_effect, hero_priority = self.hero_priority} end
function modifier_taunted_lua:HandleCustomTransmitterData(kv)
	self.hidden = BoolToNum(kv.hidden)
	self.purgable = BoolToNum(kv.purgable)
	self.strong = BoolToNum(kv.strong)
	self.texture = kv.texture
	self.priority = kv.priority
	self.effect = kv.effect
	self.effect_attach = kv.effect_attach
	self.status_effect = kv.status_effect
	self.status_priority = kv.status_priority
	self.hero_effect = kv.hero_effect
	self.hero_priority = kv.hero_priority
end

modifier_truesight_aura_lua = modifier_truesight_aura_lua or class({})
function modifier_truesight_aura_lua:IsHidden() return true end
function modifier_truesight_aura_lua:IsPurgable() return false end
function modifier_truesight_aura_lua:IsAura() return true end
function modifier_truesight_aura_lua:GetAuraRadius() return self.radius end
function modifier_truesight_aura_lua:GetModifierAura() return "modifier_truesight" end
function modifier_truesight_aura_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_truesight_aura_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_truesight_aura_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER end
function modifier_truesight_aura_lua:GetAuraDuration() return 0.5 end
function modifier_truesight_aura_lua:OnCreated(kv)
	if not IsServer() then return end
	if kv.radius ~= nil then self.radius = kv.radius else self.radius = 900 end
end

modifier_orb_effect_lua = class({})
function modifier_orb_effect_lua:IsHidden() return true end
function modifier_orb_effect_lua:IsDebuff() return false end
function modifier_orb_effect_lua:IsPurgable() return false end
function modifier_orb_effect_lua:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_orb_effect_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_FAIL, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK, MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, MODIFIER_EVENT_ON_ORDER, MODIFIER_PROPERTY_PROJECTILE_NAME} end
function modifier_orb_effect_lua:OnCreated()
	self.ability = self:GetAbility()
	self.cast = false
	self.records = {}
	if self:GetAbility().IntervalThink then
		local interval = self:GetAbility():IntervalThink(self)
		if interval then
			self:StartIntervalThink(interval)
		end
	end
end
function modifier_orb_effect_lua:OnIntervalThink()
	if self:GetAbility().OnIntervalThink then
		local new_interval = self:GetAbility():OnIntervalThink()
		if new_interval ~= nil and type(new_interval) == "number" then
			self:StartIntervalThink(new_interval)
		end
	end
end
function modifier_orb_effect_lua:OnAttack(kv)
	if kv.attacker ~= self:GetParent() then return end
	if self:ShouldLaunch(kv.target) then
		self.ability:UseResources(true, true, false, true)
		self.records[kv.record] = true
		if self.ability.OnOrbFire then self.ability:OnOrbFire(kv) end
	end
	self.cast = false
end
function modifier_orb_effect_lua:GetModifierProcAttack_Feedback(kv)
	if self.records[kv.record] then
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact(kv) end
	end
end
function modifier_orb_effect_lua:OnAttackFail(kv)
	if self.records[kv.record] then
		if self.ability.OnOrbFail then self.ability:OnOrbFail(kv) end
	end
end
function modifier_orb_effect_lua:OnAttackRecordDestroy(kv)
	self.records[kv.record] = nil
end
function modifier_orb_effect_lua:OnOrder(kv)
	if kv.unit ~= self:GetParent() then return end
	if kv.ability then
		if kv.ability==self:GetAbility() then
			self.cast = true
			return
		end
		local pass = false
		if kv.ability:IsBehavior(DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL) or kv.ability:IsBehavior(DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT) or kv.ability:IsBehavior(DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL) then
			pass = true
		end
		if self.cast and not pass then
			self.cast = false
		end
	else
		if self.cast then
			if kv.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or kv.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or kv.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or kv.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or kv.order_type == DOTA_UNIT_ORDER_STOP or kv.order_type == DOTA_UNIT_ORDER_HOLD_POSITION
			then
				self.cast = false
			end
		end
	end
end
function modifier_orb_effect_lua:GetModifierProjectileName()
	if not self.ability.GetProjectileName then return end
	if self:ShouldLaunch(self:GetCaster():GetAggroTarget()) then
		return self.ability:GetProjectileName()
	end
end
function modifier_orb_effect_lua:ShouldLaunch(target)
	if self.ability:GetAutoCastState() then
		if self.ability.CastFilterResultTarget ~= CDOTA_Ability_Lua.CastFilterResultTarget then
			if self.ability:CastFilterResultTarget(target) == UF_SUCCESS then
				self.cast = true
			end
		else
			local nResult = UnitFilter(target, self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(), self.ability:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber())
			if nResult == UF_SUCCESS then
				self.cast = true
			end
		end
	end
	if self.cast and self.ability:IsFullyCastable() and (not self:GetParent():IsSilenced()) then
		return true
	end
	return false
end

modifier_generic_arc_lua = modifier_generic_arc_lua or class({})
function modifier_generic_arc_lua:IsHidden() return true end
function modifier_generic_arc_lua:IsPurgable() return true end
function modifier_generic_arc_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_generic_arc_lua:CheckState() return {[MODIFIER_STATE_STUNNED] = self.isStun or false, [MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_generic_arc_lua:DeclareFunctions() return {MODIFIER_PROPERTY_DISABLE_TURNING, MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_generic_arc_lua:OnCreated(kv)
	if not IsServer() then return end
	self.interrupted = false
	self:SetJumpParameters(kv)
	self:Jump()
end
function modifier_generic_arc_lua:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_generic_arc_lua:OnDestroy()
	if not IsServer() then return end
	local pos = self:GetParent():GetOrigin()
	self:GetParent():RemoveHorizontalMotionController(self)
	self:GetParent():RemoveVerticalMotionController(self)
	if self.end_offset~=0 then
		self:GetParent():SetOrigin(pos)
	end
	if self.endCallback then
		self.endCallback(self.interrupted)
	end
end
function modifier_generic_arc_lua:GetModifierDisableTurning() if not self.isForward then return end return 1 end
function modifier_generic_arc_lua:GetOverrideAnimation() if self:GetStackCount() > 0 then return self:GetStackCount() end end
function modifier_generic_arc_lua:UpdateHorizontalMotion(me, dt)
	if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
	me:SetOrigin(me:GetOrigin() + self.direction * self.speed * dt)
end
function modifier_generic_arc_lua:UpdateVerticalMotion(me, dt)
	if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
	local pos = me:GetOrigin()
	local time = self:GetElapsedTime()
	local height = pos.z
	local speed = self:GetVerticalSpeed(time)
	pos.z = height + speed * dt
	me:SetOrigin(pos)
	if not self.fix_duration then
		local ground = GetGroundHeight(pos, me) + self.end_offset
		if pos.z <= ground then
			pos.z = ground
			me:SetOrigin(pos)
			self:Destroy()
		end
	end
end
function modifier_generic_arc_lua:OnHorizontalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end
function modifier_generic_arc_lua:OnVerticalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end
function modifier_generic_arc_lua:SetJumpParameters(kv)
	self.parent = self:GetParent()
	self.fix_end = true
	self.fix_duration = true
	self.fix_height = true
	if kv.fix_end then
		self.fix_end = kv.fix_end==1
	end
	if kv.fix_duration then
		self.fix_duration = kv.fix_duration==1
	end
	if kv.fix_height then
		self.fix_height = kv.fix_height==1
	end
	self.isStun = kv.isStun==1
	self.isRestricted = kv.isRestricted==1
	self.isForward = kv.isForward==1
	self.activity = kv.activity or 0
	self:SetStackCount(self.activity)
	if kv.target_x and kv.target_y then
		local origin = self.parent:GetOrigin()
		local dir = Vector(kv.target_x, kv.target_y, 0) - origin
		dir.z = 0
		dir = dir:Normalized()
		self.direction = dir
	end
	if kv.dir_x and kv.dir_y then
		self.direction = Vector(kv.dir_x, kv.dir_y, 0):Normalized()
	end
	if not self.direction then
		self.direction = self.parent:GetForwardVector()
	end
	self.duration = kv.duration
	self.distance = kv.distance
	self.speed = kv.speed
	if not self.duration then
		self.duration = self.distance/self.speed
	end
	if not self.distance then
		self.speed = self.speed or 0
		self.distance = self.speed*self.duration
	end
	if not self.speed then
		self.distance = self.distance or 0
		self.speed = self.distance/self.duration
	end
	self.height = kv.height or 0
	self.start_offset = kv.start_offset or 0
	self.end_offset = kv.end_offset or 0
	local pos_start = self.parent:GetOrigin()
	local pos_end = pos_start + self.direction * self.distance
	local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
	local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
	local height_max
	if not self.fix_height then
		self.height = math.min(self.height, self.distance/4)
	end
	if self.fix_end then
		height_end = height_start
		height_max = height_start + self.height
	else
		local tempmin, tempmax = height_start, height_end
		if tempmin>tempmax then
			tempmin,tempmax = tempmax, tempmin
		end
		local delta = (tempmax-tempmin)*2/3
		height_max = tempmin + delta + self.height
	end
	if not self.fix_duration then
		self:SetDuration(-1, false)
	else
		self:SetDuration(self.duration, true)
	end
	self:InitVerticalArc(height_start, height_max, height_end, self.duration)
end
function modifier_generic_arc_lua:Jump()
	if self.distance>0 then
		if not self:ApplyHorizontalMotionController() then
			self.interrupted = true
			self:Destroy()
		end
	end
	if self.height>0 then
		if not self:ApplyVerticalMotionController() then
			self.interrupted = true
			self:Destroy()
		end
	end
end
function modifier_generic_arc_lua:InitVerticalArc(height_start, height_max, height_end, duration)
	local height_end = height_end - height_start
	local height_max = height_max - height_start
	if height_max<height_end then
		height_max = height_end+0.01
	end
	if height_max<=0 then
		height_max = 0.01
	end
	local duration_end = (1 + math.sqrt(1 - height_end/height_max))/2
	self.const1 = 4*height_max*duration_end/duration
	self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end
function modifier_generic_arc_lua:GetVerticalPos(time)
	return self.const1*time - self.const2*time*time
end
function modifier_generic_arc_lua:GetVerticalSpeed(time)
	return self.const1 - 2*self.const2*time
end
function modifier_generic_arc_lua:SetEndCallback(func)
	self.endCallback = func
end

modifier_generic_leashed_lua = modifier_generic_leashed_lua or class({})
function modifier_generic_leashed_lua:IsHidden() return true end
function modifier_generic_leashed_lua:IsDebuff() return true end
function modifier_generic_leashed_lua:IsPurgable()
	if not IsServer() then return end
	return self.purgable
end
function modifier_generic_leashed_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_generic_leashed_lua:OnCreated(kv)
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.rooted = true
	self.purgable = true
	if kv.rooted then self.rooted = kv.rooted==1 end
	if kv.purgable then self.purgable = kv.purgable==1 end
	if self.rooted then self:SetStackCount(1) end
	self.radius = kv.radius or 300
	if kv.center_x and kv.center_y then
		self.center = Vector(kv.center_x, kv.center_y, 0)
	else
		self.center = self:GetParent():GetOrigin()
	end
	self.max_speed = 550
	self.min_speed = 0.1
	self.max_min = self.max_speed-self.min_speed
	self.half_width = 50
end
function modifier_generic_leashed_lua:OnDestroy()
	if not IsServer() then return end
	if self.endCallback then
		self.endCallback()
	end
end
function modifier_generic_leashed_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_LIMIT} end
function modifier_generic_leashed_lua:GetModifierMoveSpeed_Limit(params)
	if not IsServer() then return end
	local parent_vector = self.parent:GetOrigin()-self.center
	local parent_direction = parent_vector:Normalized()
	local actual_distance = parent_vector:Length2D()
	local wall_distance = self.radius-actual_distance
	if wall_distance<(-self.half_width) then
		self:Destroy()
		return 0
	end
	local parent_angle = VectorToAngles(parent_direction).y
	local unit_angle = self:GetParent():GetAnglesAsVector().y
	local wall_angle = math.abs(AngleDiff(parent_angle, unit_angle))
	local limit = 0
	if wall_angle<=90 then
		if wall_distance<0 then
			limit = self.min_speed
		else
			limit = (wall_distance/self.half_width)*self.max_min + self.min_speed
		end
	end
	return limit
end
function modifier_generic_leashed_lua:CheckState() return {[MODIFIER_STATE_TETHERED] = self:GetStackCount()==1} end
function modifier_generic_leashed_lua:SetEndCallback(func)
	self.endCallback = func
end

modifier_summon_extra_health_lua = modifier_summon_extra_health_lua or class({})
function modifier_summon_extra_health_lua:IsHidden() return true end
function modifier_summon_extra_health_lua:IsPurgable() return self.purgable and not self.strong end
function modifier_summon_extra_health_lua:IsPurgeException() return self.strong end
function modifier_summon_extra_health_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_summon_extra_health_lua:OnCreated(kv)
	if not IsServer() then return end
	self.health = kv.health
	if self.health == nil then
		self:Destroy()
		return
	end
	if kv.purgable ~= nil then self.purgable = BoolToNum(kv.purgable) else self.purgable = false end
	if kv.strong ~= nil then self.strong = BoolToNum(kv.strong) else self.strong = false end
	self:GetParent():SetBaseMaxHealth(math.max(1, self:GetParent():GetBaseMaxHealth() + self.health))
	self:GetParent():SetMaxHealth(math.max(1, self:GetParent():GetMaxHealth() + self.health))
	self:GetParent():SetHealth(math.max(1, self:GetParent():GetHealth() + self.health))
end
function modifier_summon_extra_health_lua:OnDestroy()
	if not IsServer() then return end
	if self.health == nil then return end
	self:GetParent():SetBaseMaxHealth(math.max(1, self:GetParent():GetBaseMaxHealth() - self.health))
	self:GetParent():SetMaxHealth(math.max(1, self:GetParent():GetMaxHealth() - self.health))
	self:GetParent():SetHealth(math.max(1, self:GetParent():GetHealth() - self.health))
end
function modifier_summon_extra_health_lua:UpdateHealth(health)
	if health == nil or health < 0 then return end
	self:GetParent():SetBaseMaxHealth(math.max(1, self:GetParent():GetBaseMaxHealth() - self.health + health))
	self:GetParent():SetMaxHealth(math.max(1, self:GetParent():GetMaxHealth() - self.health + health))
	self:GetParent():SetHealth(math.max(1, self:GetParent():GetHealth() - self.health + health))
	self.health = health
end

modifier_primary_attribute_lua = modifier_primary_attribute_lua or class({})
function modifier_primary_attribute_lua:IsHidden() return true end
function modifier_primary_attribute_lua:IsPurgable() return false end
function modifier_primary_attribute_lua:RemoveOnDeath() return false end
function modifier_primary_attribute_lua:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_primary_attribute_lua:OnCreated(kv)
	if not IsServer() then return end
	self.default_attribute = self:GetParent():GetPrimaryAttribute()
	self:GetParent():SetPrimaryAttribute(kv.attribute)
	self:GetParent():CalculateStatBonus(true)
end
function modifier_primary_attribute_lua:OnRefresh(kv)
	if not IsServer() then return end
	self:GetParent():SetPrimaryAttribute(kv.attribute)
	self:GetParent():CalculateStatBonus(true)
end
function modifier_primary_attribute_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SetPrimaryAttribute(self.default_attribute)
	self:GetParent():CalculateStatBonus(true)
end