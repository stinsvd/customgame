LinkLuaModifier("modifier_monkey_king_wukongs_command_thinker_lua", "abilities/heroes/monkey_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_wukongs_command_buff_lua", "abilities/heroes/monkey_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_wukongs_command_clone_lua", "abilities/heroes/monkey_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_wukongs_command_scepter_lua", "abilities/heroes/monkey_king", LUA_MODIFIER_MOTION_NONE)

monkey_king_wukongs_command_lua = monkey_king_wukongs_command_lua or class(ability_lua_base)
function monkey_king_wukongs_command_lua:Spawn()
	self:GetCaster().wukongs_command_clones = self:GetCaster().wukongs_command_clones ~= nil and table.values(table.filter(self:GetCaster().wukongs_command_clones, function(_, ent) return IsValidEntity(ent) end)) or {}
end
function monkey_king_wukongs_command_lua:GetIntrinsicModifierName() return "modifier_monkey_king_wukongs_command_scepter_lua" end
function monkey_king_wukongs_command_lua:GetAOERadius()
	return math.max(self:GetSpecialValueFor("first_radius"), self:GetSpecialValueFor("second_radius"), self:GetSpecialValueFor("third_radius"))
end
function monkey_king_wukongs_command_lua:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_MK_FUR_ARMY)
	self:GetCaster():EmitSound("Hero_MonkeyKing.FurArmy.Channel")
	self.precast_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_fur_army_cast.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	return true
end
function monkey_king_wukongs_command_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():FadeGesture(ACT_DOTA_MK_FUR_ARMY)
	self:GetCaster():StopSound("Hero_MonkeyKing.FurArmy.Channel")
	if self.precast_fx then
		ParticleManager:DestroyParticle(self.precast_fx, true)
		ParticleManager:ReleaseParticleIndex(self.precast_fx)
	end
end
function monkey_king_wukongs_command_lua:OnSpellStart()
	self:GetCaster().wukongs_command_clones = self:GetCaster().wukongs_command_clones ~= nil and table.values(table.filter(self:GetCaster().wukongs_command_clones, function(_, ent) return IsValidEntity(ent) end)) or {}
	if IsValidEntity(self:GetCaster().wukongs_command_ring) then
		local ring = self:GetCaster().wukongs_command_ring:FindModifierByName("modifier_monkey_king_wukongs_command_thinker_lua")
		ring:Destroy()
	end
	self:GetCaster().wukongs_command_ring = CreateModifierThinker(self:GetCaster(), self, "modifier_monkey_king_wukongs_command_thinker_lua", {duration=self:GetSpecialValueFor("duration")}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end
function monkey_king_wukongs_command_lua:SpawnMonkey(label)
	local clone = nil
	for _, _clone in pairs(self:GetCaster().wukongs_command_clones) do
		if IsValidEntity(_clone) then
			local modifier = _clone:FindModifierByName("modifier_monkey_king_wukongs_command_clone_lua")
			if (modifier == nil or modifier.hidden) and (modifier.label == nil or modifier.label == label) then
				clone = _clone
				break
			end
		end
	end
	if clone == nil then
		clone = CreateUnitByName(self:GetCaster():GetUnitName(), self:GetCaster():GetAbsOrigin(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		clone:AddNewModifier(self:GetCaster(), self, "modifier_monkey_king_wukongs_command_clone_lua", {})
		table.insert(self:GetCaster().wukongs_command_clones, clone)
	end
	local modifier = clone:FindModifierByName("modifier_monkey_king_wukongs_command_clone_lua") or clone:AddNewModifier(self:GetCaster(), self, "modifier_monkey_king_wukongs_command_clone_lua", {})
	modifier.label = label
	modifier:UnHide()
	clone:CopyAbilities()
	clone:SetBaseStrength(self:GetCaster():GetBaseStrength())
	clone:SetBaseAgility(self:GetCaster():GetBaseAgility())
	clone:SetBaseIntellect(self:GetCaster():GetBaseIntellect())
	for _, i in pairs(INVENTORY_SLOTS) do
		local item = self:GetCaster():GetItemInSlot(i)
		local clone_item = clone:GetItemInSlot(i)
		if item ~= nil and not table.contains({"item_gem", "item_aegis", "item_stormcrafter", "item_basher", "item_abyssal_blade"}, item:GetName()) and item:GetPurchaser() == self:GetCaster() then
			if clone_item == nil or clone_item:GetName() ~= item:GetName() then
				if clone_item ~= nil then clone:RemoveItem(clone_item) end
				clone_item = clone:AddItemByName(item:GetName())
			end
			clone_item:SetToggleState(item:GetName() ~= "item_armlet")
			if table.contains({"item_echo_sabre", "item_enchanted_quiver", "item_mind_breaker"}, item:GetName()) then
				clone_item:StartCooldown(99999)
				clone_item:SetFrozenCooldown(true)
			end
		elseif clone_item ~= nil then
			clone:RemoveItem(clone_item)
		end
	end
	return clone
end
function monkey_king_wukongs_command_lua:HideMonkey(clone)
	if not IsValidEntity(clone) then return end
	local modifier = clone:FindModifierByName("modifier_monkey_king_wukongs_command_clone_lua") or clone:AddNewModifier(self:GetCaster(), self, "modifier_monkey_king_wukongs_command_clone_lua", {})
	modifier.label = nil
	modifier:Hide()
end
function monkey_king_wukongs_command_lua:GetMonkeys(label)
	self:GetCaster().wukongs_command_clones = self:GetCaster().wukongs_command_clones ~= nil and table.values(table.filter(self:GetCaster().wukongs_command_clones, function(_, ent) return IsValidEntity(ent) end)) or {}
	local clones = {}
	for _, clone in pairs(self:GetCaster().wukongs_command_clones) do
		local modifier = clone:FindModifierByName("modifier_monkey_king_wukongs_command_clone_lua") or clone:AddNewModifier(self:GetCaster(), self, "modifier_monkey_king_wukongs_command_clone_lua", {})
		if modifier.label == nil or modifier.label == label or label == nil then
			table.insert(clones, clone)
		end
	end
	return clones
end

modifier_monkey_king_wukongs_command_scepter_lua = modifier_monkey_king_wukongs_command_scepter_lua or class({})
function modifier_monkey_king_wukongs_command_scepter_lua:IsHidden() return true end
function modifier_monkey_king_wukongs_command_scepter_lua:IsPurgable() return false end
function modifier_monkey_king_wukongs_command_scepter_lua:OnCreated()
	if not IsServer() then return end
	if not self:GetParent():IsTrueHero() then return end
	self.spawn_timer = 0
	self.spawn_interval = 4 -- self:GetAbility():GetSpecialValueFor("scepter_spawn_interval")
	self:StartIntervalThink(0.03)
end
function modifier_monkey_king_wukongs_command_scepter_lua:OnIntervalThink()
	if not self:GetParent():HasScepter() then
		self:OnDestroy()
		return
	end
	self.spawn_timer = self.spawn_timer + 0.03
	if self:GetParent():HasModifier("modifier_monkey_king_bounce_leap") or self:GetParent():HasModifier("modifier_monkey_king_bounce_perch") or self:GetParent():HasModifier("modifier_monkey_king_transform") or self:GetParent():IsInvisible() or self:GetParent():IsOutOfGame() or not self:GetParent():IsAlive() then return end
	if self.spawn_timer > self.spawn_interval then
		local clone = self:GetAbility():SpawnMonkey(self:GetName())
		local point = GetGroundPosition(self:GetParent():GetAbsOrigin()+RandomVector(300), clone)
		FindClearSpaceForUnit(clone, self:GetParent():GetAbsOrigin(), true)
		Timers:CreateTimer({endTime=0.1, callback=function()
			clone:MoveToPosition(point)
			Timers:CreateTimer({endTime=(CalculateDistance(clone, point)/clone:GetIdealSpeed())+((0.03 * math.pi) / 0.6), callback=function()
				clone:AddNewModifier(nil, nil, "modifier_rooted", {})
			end}, nil, self)
		end}, nil, self)
		Timers:CreateTimer({endTime=self:GetAbility():GetSpecialValueFor("scepter_spawn_duration"), callback=function()
			self:GetAbility():HideMonkey(clone)
		end}, nil, self)
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_fur_army_positions.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(fx, 0, point)
		ParticleManager:ReleaseParticleIndex(fx)
		self.spawn_timer = 0
	end
end
function modifier_monkey_king_wukongs_command_scepter_lua:OnDestroy()
	if not IsServer() or self:GetParent().wukongs_command_clones == nil then return end
	for _, clone in pairs(self:GetParent().wukongs_command_clones) do
		if IsValidEntity(clone) then
			local modifier = clone:FindModifierByName("modifier_monkey_king_wukongs_command_clone_lua")
			if modifier ~= nil and modifier.label == self:GetName() then
				UTIL_Remove(clone)
			end
		end
	end
end

modifier_monkey_king_wukongs_command_thinker_lua = modifier_monkey_king_wukongs_command_thinker_lua or class({})
function modifier_monkey_king_wukongs_command_thinker_lua:IsPurgable() return false end
function modifier_monkey_king_wukongs_command_thinker_lua:IsAura() return true end
function modifier_monkey_king_wukongs_command_thinker_lua:GetAuraDuration() return FrameTime() end
function modifier_monkey_king_wukongs_command_thinker_lua:GetAuraRadius() return self.radius + self:GetAbility():GetSpecialValueFor("leadership_radius_buffer") end
function modifier_monkey_king_wukongs_command_thinker_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_monkey_king_wukongs_command_thinker_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_monkey_king_wukongs_command_thinker_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_monkey_king_wukongs_command_thinker_lua:GetModifierAura() return "modifier_monkey_king_wukongs_command_buff_lua" end
function modifier_monkey_king_wukongs_command_thinker_lua:OnCreated()
	local first_radius = self:GetAbility():GetSpecialValueFor("first_radius")
	local second_radius = self:GetAbility():GetSpecialValueFor("second_radius")
	local third_radius = self:GetAbility():GetSpecialValueFor("third_radius")
	self.radius = math.max(first_radius, second_radius, third_radius)
	if not IsServer() then return end
	self.leadership_buffer = 0
	self.leadership_time_buffer = self:GetAbility():GetSpecialValueFor("leadership_time_buffer")
	self:GetParent():EmitSound("Hero_MonkeyKing.FurArmy")
	self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.fx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.fx, 1, Vector(self.radius, 0, 0))
	self:StartIntervalThink(0.05)
	if first_radius > 0 then
		self:CreateMonkeys(first_radius, self:GetAbility():GetSpecialValueFor("num_first_soldiers"))
	end
	if second_radius > 0 then
		self:CreateMonkeys(second_radius, self:GetAbility():GetSpecialValueFor("num_second_soldiers"))
	end
	if third_radius > 0 then
		self:CreateMonkeys(third_radius, self:GetAbility():GetSpecialValueFor("num_third_soldiers"))
	end
end
function modifier_monkey_king_wukongs_command_thinker_lua:OnIntervalThink()
	if not self:GetCaster():HasModifier(self:GetModifierAura()) then
		if self.leadership_buffer < self.leadership_time_buffer then
			self.leadership_buffer = self.leadership_buffer + 0.05
		else
			self:Destroy()
		end
	elseif self.leadership_buffer > 0 then
		self.leadership_buffer = 0
	end
end
function modifier_monkey_king_wukongs_command_thinker_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_MonkeyKing.FurArmy.End")
	self:GetParent():StopSound("Hero_MonkeyKing.FurArmy")
	ParticleManager:DestroyParticle(self.fx, false)
	ParticleManager:ReleaseParticleIndex(self.fx)
	self:RemoveMonkeys()
end
function modifier_monkey_king_wukongs_command_thinker_lua:CreateMonkeys(radius, count)
	local center = self:GetParent():GetAbsOrigin()
	local angle = 360/count
	for i=1, count do
		local current_angle = angle + (math.pi/(count/2))*i
		local point = GetGroundPosition(Vector(center.x+radius*math.sin(current_angle), center.y+radius*math.cos(current_angle), center.z), self:GetCaster())
		local clone = self:GetAbility():SpawnMonkey(self:GetName())
		clone.ring = self
		FindClearSpaceForUnit(clone, center, true)
		clone:FaceTowards(point)
		Timers:CreateTimer({endTime=(0.03 * math.pi) / 0.6, callback=function()
			clone:MoveToPosition(point)
			Timers:CreateTimer({endTime=CalculateDistance(clone, point)/clone:GetIdealSpeed(), callback=function()
				clone:AddNewModifier(nil, nil, "modifier_rooted", {})
			end}, nil, self)
		end}, nil, self)
	end
end
function modifier_monkey_king_wukongs_command_thinker_lua:RemoveMonkeys()
	if self:GetAbility() == nil then return end
	for _, clone in pairs(self:GetAbility():GetMonkeys(self:GetName())) do
		clone.ring = nil
		self:GetAbility():HideMonkey(clone)
	end
end

modifier_monkey_king_wukongs_command_buff_lua = modifier_monkey_king_wukongs_command_buff_lua or class({})
function modifier_monkey_king_wukongs_command_buff_lua:IsPurgable() return false end
function modifier_monkey_king_wukongs_command_buff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_monkey_king_wukongs_command_buff_lua:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_monkey_king_wukongs_command_buff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_monkey_king_wukongs_command_buff_lua:GetModifierPhysicalArmorBonus() return self.armor end

modifier_monkey_king_wukongs_command_clone_lua = modifier_monkey_king_wukongs_command_clone_lua or class({})
function modifier_monkey_king_wukongs_command_clone_lua:IsHidden() return true end
function modifier_monkey_king_wukongs_command_clone_lua:IsPurgable() return false end
function modifier_monkey_king_wukongs_command_clone_lua:GetStatusEffectName() return "particles/status_fx/status_effect_monkey_king_fur_army.vpcf" end
function modifier_monkey_king_wukongs_command_clone_lua:CheckState() return {[MODIFIER_STATE_DISARMED] = self.hidden or GameRules:GetDOTATime(true, true)-self.attack_time<self.attack_rate or self.target == nil, [MODIFIER_STATE_ATTACK_IMMUNE] = true, [MODIFIER_STATE_INVISIBLE] = self.hidden, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_COMMAND_RESTRICTED] = self.hidden, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_monkey_king_wukongs_command_clone_lua:DeclareFunctions() return {MODIFIER_PROPERTY_EXP_RATE_BOOST, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_monkey_king_wukongs_command_clone_lua:OnCreated()
	self.attack_rate = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.move_speed = self:GetAbility():GetSpecialValueFor("move_speed")
	self.attack_range_buffer = self:GetAbility():GetSpecialValueFor("outer_attack_buffer")
	self.attack_time = 0
	if not IsServer() then return end
	self:StartIntervalThink(AI_UPDATE/2)
end
function modifier_monkey_king_wukongs_command_clone_lua:OnRefresh()
	self:OnCreated()
end
function modifier_monkey_king_wukongs_command_clone_lua:OnIntervalThink()
	if self.hidden or not self:GetParent():IsRooted() then return end
	if GameRules:GetDOTATime(true, true)-self.attack_time<self.attack_rate then
		self:GetParent():SetForceAttackTarget(nil)
		self:GetParent():Stop()
		return
	end
	if self.target == nil then
		self:GetParent():Stop()
	end
	local target = nil
	for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange()+50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + (self.label == "modifier_monkey_king_wukongs_command_scepter_lua" and DOTA_UNIT_TARGET_BASIC or DOTA_UNIT_TARGET_NONE), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)) do
		if not enemy:IsAttackImmune() and ((self:GetParent().ring == nil or self:GetParent().ring:IsNull()) or CalculateDistance(self:GetParent().ring:GetParent(), enemy) < self:GetParent().ring.radius+self.attack_range_buffer) then
			target = enemy
			break
		end
	end
	self.target = target
	if self:GetParent():IsAttackingEntity(self.target) then return end
	self:GetParent():SetForceAttackTarget(self.target)
	self:GetParent():SetAggroTarget(self.target)
	self:GetParent():SetAttacking(self.target)
	if self.target == nil then
		self:GetParent():Stop()
	else
		self:GetParent():ExecuteOrder(DOTA_UNIT_ORDER_ATTACK_TARGET, self.target, nil, self.target:GetAbsOrigin())
	end
end
function modifier_monkey_king_wukongs_command_clone_lua:Hide()
	self.hidden = true
	if not IsServer() then return end
	self:GetParent():AddNoDraw()
	self:GetParent():RemoveModifierByName("modifier_rooted")
	self:GetParent():Stop()
	self:GetParent():SetDayTimeVisionRange(0)
	self:GetParent():SetNightTimeVisionRange(0)
	self:GetParent():SetAggroTarget(nil)
	self:GetParent():SetAttacking(nil)
	self:GetParent():SetForceAttackTarget(nil)
	self.target = nil
	self.stacks = 0
	if self.stack_particle ~= nil then
		ParticleManager:DestroyParticle(self.stack_particle, true)
		ParticleManager:ReleaseParticleIndex(self.stack_particle)
		self.stack_particle = nil
	end
	self:GetParent():RemoveModifierByName("modifier_monkey_king_quadruple_tap_bonuses")
end
function modifier_monkey_king_wukongs_command_clone_lua:UnHide()
	self.hidden = false
	if not IsServer() then return end
	self:GetParent():SetAggroTarget(nil)
	self:GetParent():SetAttacking(nil)
	self:GetParent():SetForceAttackTarget(nil)
	self.target = nil
	self:GetParent():RemoveNoDraw()
	self:GetParent():RemoveModifierByName("modifier_rooted")
	self:GetParent():Stop()
	self:GetParent():SetDayTimeVisionRange(600)
	self:GetParent():SetNightTimeVisionRange(600)
	self.stacks = 0
	if self.stack_particle ~= nil then
		ParticleManager:DestroyParticle(self.stack_particle, true)
		ParticleManager:ReleaseParticleIndex(self.stack_particle)
		self.stack_particle = nil
	end
	self:GetParent():RemoveModifierByName("modifier_monkey_king_quadruple_tap_bonuses")
end
function modifier_monkey_king_wukongs_command_clone_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	self.attack_time = GameRules:GetDOTATime(true, true)
	local jingu_mastery = self:GetParent():FindAbilityByName("monkey_king_jingu_mastery")
	if jingu_mastery == nil or not jingu_mastery:IsTrained() or not kv.attacker:HasScepter() or kv.attacker:PassivesDisabled() or kv.attacker:HasModifier("modifier_monkey_king_quadruple_tap_bonuses") or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS then return end
	self.stacks = self.stacks + 1
	if self.stacks >= jingu_mastery:GetSpecialValueFor("required_hits") then
		if self.stack_particle ~= nil then
			ParticleManager:DestroyParticle(self.stack_particle, true)
			ParticleManager:ReleaseParticleIndex(self.stack_particle)
			self.stack_particle = nil
		end
		local buff = kv.attacker:AddNewModifier(kv.attacker, jingu_mastery, "modifier_monkey_king_quadruple_tap_bonuses", {duration=jingu_mastery:GetSpecialValueFor("max_duration")})
		buff:SetStackCount(jingu_mastery:GetSpecialValueFor("charges"))
		self.stacks = 0
	else
		if self.stack_particle == nil then
			self.stack_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, kv.attacker)
		end
		ParticleManager:SetParticleControl(self.stack_particle, 1, Vector(0, self.stacks, 0))
	end
end
function modifier_monkey_king_wukongs_command_clone_lua:GetModifierMoveSpeed_Absolute() return self.move_speed end
function modifier_monkey_king_wukongs_command_clone_lua:GetActivityTranslationModifiers() return "fur_army_soldier" end
function modifier_monkey_king_wukongs_command_clone_lua:GetModifierPercentageExpRateBoost() return -100 end