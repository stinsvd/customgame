LinkLuaModifier("modifier_item_void_blink_lua", "items/void_blink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_void_blink_pull_lua", "items/void_blink", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_ring_of_the_void_lua", "items/boss/ring_of_the_void", LUA_MODIFIER_MOTION_NONE)

item_void_blink_lua = item_void_blink_lua or class(ability_lua_base)
function item_void_blink_lua:GetVectorTargetRange() return 225 end
function item_void_blink_lua:GetVectorTargetStartRadius() return 100 end
function item_void_blink_lua:GetVectorTargetEndRadius() return self:GetVectorTargetStartRadius() end
function item_void_blink_lua:GetBehavior()
	if IsServer() then
		return tonumber(tostring(self.BaseClass.GetBehavior(self))) - DOTA_ABILITY_BEHAVIOR_POINT - DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT
	end
	return self.BaseClass.GetBehavior(self)
end
function item_void_blink_lua:GetIntrinsicModifiers() return {"modifier_item_void_blink_lua", "modifier_item_ring_of_the_void_lua"} end
function item_void_blink_lua:GetCastRange(location, target)
	if IsServer() then return 0 end
	return self:GetSpecialValueFor("blink_range")
end
function item_void_blink_lua:CastFilterResultTarget(target)
	if not IsServer() then return UF_SUCCESS end
	if target == self:GetCaster() then
		local fountain = self:GetCaster():GetFountain()
		if fountain ~= nil then
			local point = fountain:GetAbsOrigin()
			if CalculateDistance(self:GetCaster(), point) > self:GetSpecialValueFor("blink_range") then
				point = self:GetCaster():GetAbsOrigin() + (point - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("blink_range")
			end
			self:GetCaster():ExecuteOrder(DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION, nil, self, point, false)
			self:OrderAbilityOnPosition(point)
			return UF_FAIL_HERO
		end
	end
	return UF_SUCCESS
end
function item_void_blink_lua:OnVectorCastStart(point, direction)
	local target_point = point
	local distance = CalculateDistance(target_point, self:GetCaster())
	if distance > self:GetSpecialValueFor("blink_range") then
		target_point = self:GetCaster():GetAbsOrigin() + (target_point - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("blink_range_clamp")
	end
	self:GetCaster():EmitSound("DOTA_Item.BlinkDagger.Activate")
	local fx = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(fx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fx)
	FindClearSpaceForUnit(self:GetCaster(), target_point, true)
	ProjectileManager:ProjectileDodge(self:GetCaster())
	local pull_point = self:GetCaster():GetAbsOrigin()+direction*self:GetVectorTargetRange()
	self:GetCaster():FaceTowards(pull_point)
	for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), pull_point, nil, self:GetSpecialValueFor("pull_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_NONE, FIND_ANY_ORDER, false)) do
		unit:AddNewModifier(self:GetCaster(), self, "modifier_item_void_blink_pull_lua", {duration=self:GetSpecialValueFor("pull_duration"), x=pull_point.x, y=pull_point.y})
	end
	GridNav:DestroyTreesAroundPoint(pull_point, self:GetSpecialValueFor("pull_radius_tree"), true)
	local fx_pull = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(fx_pull, 0, pull_point)
	ParticleManager:SetParticleControl(fx_pull, 1, Vector(self:GetSpecialValueFor("pull_radius"), self:GetSpecialValueFor("pull_radius"), self:GetSpecialValueFor("pull_radius")))
	ParticleManager:ReleaseParticleIndex(fx_pull)
	EmitSoundOnLocationWithCaster(pull_point, "Hero_Dark_Seer.Vacuum", self:GetCaster())
	local fx_end = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(fx_end)
	if distance > self:GetSpecialValueFor("blink_range") then
		self:GetCaster():EmitSound("DOTA_Item.BlinkDagger.NailedIt")
	end
end

modifier_item_void_blink_lua = modifier_item_void_blink_lua or class({})
function modifier_item_void_blink_lua:IsHidden() return true end
function modifier_item_void_blink_lua:IsPurgable() return false end
function modifier_item_void_blink_lua:RemoveOnDeath() return false end
function modifier_item_void_blink_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_void_blink_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_item_void_blink_lua:OnTakeDamage(kv)
	if not IsServer() then return end
	if self:GetParent() ~= kv.unit or UnitFilter(kv.attacker, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, kv.unit:GetTeamNumber()) ~= UF_SUCCESS or kv.damage <= 0 then return end
	if self:GetAbility():GetCooldownTimeRemaining() < self:GetAbility():GetSpecialValueFor("blink_damage_cooldown") then
		self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("blink_damage_cooldown"))
	end
end

modifier_item_void_blink_pull_lua = modifier_item_void_blink_pull_lua or class({})
function modifier_item_void_blink_pull_lua:IsPurgable() return true end
function modifier_item_void_blink_pull_lua:OnCreated(kv)
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("pull_damage")
	self.direction = Vector(kv.x, kv.y, 0) - self:GetParent():GetOrigin()
	self.speed = self.direction:Length2D()/self:GetDuration()
	self.direction = self.direction:Normalized()
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end
function modifier_item_void_blink_pull_lua:OnRefresh(kv)
	self:OnCreated(kv)
end
function modifier_item_void_blink_pull_lua:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController(self)
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage=self.damage, damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility()})
end
function modifier_item_void_blink_pull_lua:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_item_void_blink_pull_lua:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_item_void_blink_pull_lua:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_item_void_blink_pull_lua:UpdateHorizontalMotion(me, dt)
	me:SetAbsOrigin(me:GetAbsOrigin() + self.direction * self.speed * dt)
end
function modifier_item_void_blink_pull_lua:OnHorizontalMotionInterrupted()
	self:Destroy()
end