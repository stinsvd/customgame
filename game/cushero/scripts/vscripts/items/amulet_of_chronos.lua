LinkLuaModifier("modifier_item_amulet_of_chronos_lua", "items/amulet_of_chronos", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_amulet_of_chronos_unique_lua", "items/amulet_of_chronos", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_amulet_of_chronos_aura_lua", "items/amulet_of_chronos", LUA_MODIFIER_MOTION_NONE)

item_amulet_of_chronos_lua = item_amulet_of_chronos_lua or class(ability_lua_base)
function item_amulet_of_chronos_lua:GetIntrinsicModifiers() return {"modifier_item_amulet_of_chronos_lua", "modifier_item_amulet_of_chronos_unique_lua"} end
function item_amulet_of_chronos_lua:Glimpse(target, location)
	local direction = location-target:GetAbsOrigin()
	local distance = direction:Length2D()
	direction = direction:Normalized()
	local duration = math.max(0.05, math.min(1.8, distance / 600))
	ProjectileManager:CreateLinearProjectile({vSpawnOrigin=target:GetAbsOrigin(), vVelocity=direction*(distance/duration), fMaxSpeed=distance/duration, fDistance=distance, fStartRadius=0, fEndRadius=0, iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_NONE, iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_NONE, iUnitTargetType=DOTA_UNIT_TARGET_DOTA_UNIT_TARGET_NONE, bIgnoreSource=true, bDrawsOnMinimap=false, EffectName="particles/units/heroes/hero_disruptor/disruptor_glimpse_travel.vpcf", Ability=self, Source=self:GetCaster(), bProvidesVision=true, iVisionRadius=300, iVisionTeamNumber=self:GetCaster():GetTeamNumber()})
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_travel.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(fx, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(fx, 1, location)
	ParticleManager:SetParticleControl(fx, 2, Vector(duration, duration, duration))
	local fx_pos = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_targetend.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(fx_pos, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(fx_pos, 1, location)
	ParticleManager:SetParticleControl(fx_pos, 2, Vector(duration, duration, duration))
	local fx_target = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_targetstart.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(fx_target, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl( fx_target, 2, Vector(duration, duration, duration))
	target:EmitSound("Hero_Disruptor.Glimpse.Target")
	Timers:CreateTimer({endTime=duration, callback=function()
		if target:IsMagicImmune() then return end
		FindClearSpaceForUnit(target, location, true)
		target:Interrupt()
		target:EmitSound("Hero_Disruptor.Glimpse.End")
		local debuff = target:FindModifierByNameAndCaster("modifier_item_amulet_of_chronos_aura_lua", self:GetCaster())
		if debuff then
			debuff:ForceRefresh()
		end
	end}, nil, self)
end

modifier_item_amulet_of_chronos_lua = modifier_item_amulet_of_chronos_lua or class({})
function modifier_item_amulet_of_chronos_lua:IsHidden() return true end
function modifier_item_amulet_of_chronos_lua:IsPurgable() return false end
function modifier_item_amulet_of_chronos_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_amulet_of_chronos_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_item_amulet_of_chronos_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_amulet_of_chronos_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_amulet_of_chronos_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end

modifier_item_amulet_of_chronos_unique_lua = modifier_item_amulet_of_chronos_unique_lua or class({})
function modifier_item_amulet_of_chronos_unique_lua:IsHidden() return true end
function modifier_item_amulet_of_chronos_unique_lua:IsPurgable() return false end
function modifier_item_amulet_of_chronos_unique_lua:IsAura() return true end
function modifier_item_amulet_of_chronos_unique_lua:GetModifierAura() return "modifier_item_amulet_of_chronos_aura_lua" end
function modifier_item_amulet_of_chronos_unique_lua:GetAuraRadius() return FIND_UNITS_EVERYWHERE end
function modifier_item_amulet_of_chronos_unique_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_amulet_of_chronos_unique_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_item_amulet_of_chronos_unique_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_item_amulet_of_chronos_unique_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_FEEDBACK} end
function modifier_item_amulet_of_chronos_unique_lua:OnCreated()
	if not IsServer() then return end
	self:OnIntervalThink()
end
function modifier_item_amulet_of_chronos_unique_lua:GetModifierProcAttack_Feedback(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or UnitFilter(kv.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, kv.attacker:GetTeamNumber()) ~= UF_SUCCESS or not self:GetAbility():IsCooldownReady() or kv.target:FindModifierByNameAndCaster(self:GetModifierAura(), self:GetCaster()) == nil then return end
	local debuff = kv.target:FindModifierByNameAndCaster(self:GetModifierAura(), self:GetCaster())
	self:GetAbility():Glimpse(kv.target, debuff.all_possible_positions[1])
	self:GetAbility():UseResources(true, true, false, true)
end

modifier_item_amulet_of_chronos_aura_lua = modifier_item_amulet_of_chronos_aura_lua or class({})
function modifier_item_amulet_of_chronos_aura_lua:IsHidden() return true end
function modifier_item_amulet_of_chronos_aura_lua:IsPurgable() return false end
function modifier_item_amulet_of_chronos_aura_lua:RemoveOnDeath() return false end
function modifier_item_amulet_of_chronos_aura_lua:OnCreated()
    self.backtrack_time = self:GetAbility():GetSpecialValueFor("revert_time")
    self.all_possible_positions = {}
    self.all_ticks = self.backtrack_time / 0.1
    for i=1, self.all_ticks do
        table.insert(self.all_possible_positions, self:GetParent():GetAbsOrigin())
    end
    self:StartIntervalThink(0.1)
end
function modifier_item_amulet_of_chronos_aura_lua:OnIntervalThink()
    for i=1, #self.all_possible_positions-1 do
        self.all_possible_positions[i] = self.all_possible_positions[i+1]
    end
    self.all_possible_positions[#self.all_possible_positions] = self:GetParent():GetAbsOrigin()
end