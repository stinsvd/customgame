item_third_eye_lua = item_third_eye_lua or class(ability_lua_base)
function item_third_eye_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_third_eye_lua", {duration=nil, _duration=self:GetSpecialValueFor("duration")})
	self:SpendCharge(0)
end

modifier_item_third_eye_lua = modifier_item_third_eye_lua or class({})
function modifier_item_third_eye_lua:IsPurgable() return false end
function modifier_item_third_eye_lua:RemoveOnDeath() return false end
function modifier_item_third_eye_lua:DestroyOnExpire() return false end
function modifier_item_third_eye_lua:GetTexture() return self.texture or "item_third_eye" end
function modifier_item_third_eye_lua:IsAura() return true end
function modifier_item_third_eye_lua:GetAuraRadius() return self.radius end
function modifier_item_third_eye_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_third_eye_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_OTHER end
function modifier_item_third_eye_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_third_eye_lua:GetModifierAura() return "modifier_truesight" end
function modifier_item_third_eye_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_item_third_eye_lua:OnCreated(kv)
	if self:GetAbility() ~= nil then
		self.texture = GetAbilityTextureNameForAbility(self:GetAbility():GetAbilityName())
		self.radius = self:GetAbility():GetSpecialValueFor("radius") > 0 and self:GetAbility():GetSpecialValueFor("radius") or 900
	else
		self.radius = self.radius or 900
	end
	if not IsServer() then return end
	self.max_stacks = kv.max_stacks or (self:GetAbility() ~= nil and self:GetAbility():GetSpecialValueFor("max_stacks") or self.max_stacks) or 0
	self.duration = kv._duration
	self.stack_durations = self.stack_durations or {}
	self.last_stack = self.last_stack or self:GetCreationTime()
	if self:GetStackCount() > 0 then
		self.stack_durations[self:GetStackCount()] = self:GetDuration() - (GameRules:GetGameTime()-self.last_stack)
	end
	if self.max_stacks > 0 then
		self:SetStackCount(math.min(self:GetStackCount()+1, self:GetAbility():GetSpecialValueFor("max_stacks")))
	else
		self:IncrementStackCount()
	end
	self:StartIntervalThink(0.1)
end
function modifier_item_third_eye_lua:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_item_third_eye_lua:OnIntervalThink()
	if self:GetRemainingTime() <= 0 then
		self:DecrementStackCount()
	end
end
function modifier_item_third_eye_lua:OnStackCountChanged(old_stacks)
	if not IsServer() then return end
	if self:GetStackCount() <= 0 then
		self:Destroy()
		return
	end
	if self:GetStackCount() >= old_stacks then
		self.stack_durations[self:GetStackCount()] = self.duration
	else
		self.stack_durations[old_stacks] = nil
	end
	self:SetDuration(self.stack_durations[self:GetStackCount()], true)
	self.last_stack = GameRules:GetGameTime()
end
function modifier_item_third_eye_lua:OnDeath(kv)
	if not IsServer() then return end
	if kv.unit ~= self:GetParent() then return end
	if kv.unit:IsReincarnating() then return end
	self:DecrementStackCount()
end