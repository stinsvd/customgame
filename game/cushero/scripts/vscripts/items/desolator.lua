LinkLuaModifier("modifier_item_desolator_lua_debuff", "items/desolator", LUA_MODIFIER_MOTION_NONE)

item_desolator_lua = item_desolator_lua or class(ability_lua_base)
function item_desolator_lua:Desolate(target, duration)
	if not target:HasModifier("modifier_item_desolator_lua_debuff") then
		target:EmitSound("Item_Desolator.Target")
	end
	local debuff = target:AddNewModifier(self:GetCaster(), self, "modifier_item_desolator_lua_debuff", {duration=duration})
	Timers:CreateTimer({endTime=FrameTime(), callback=function()
		target:RemoveModifierByNameAndCaster("modifier_blight_stone_buff", self:GetCaster())
	end}, nil, self)
	return debuff
end

modifier_item_desolator_lua_debuff = modifier_item_desolator_lua_debuff or class({})
function modifier_item_desolator_lua_debuff:IsDebuff() return true end
function modifier_item_desolator_lua_debuff:IsPurgable() return true end
function modifier_item_desolator_lua_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_desolator_lua_debuff:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
end
function modifier_item_desolator_lua_debuff:OnRefresh()
	self:OnCreated()
end
function modifier_item_desolator_lua_debuff:GetModifierPhysicalArmorBonus() return self.armor_reduction end

LinkLuaModifier("modifier_item_angels_desolator_lua", "items/desolator", LUA_MODIFIER_MOTION_NONE)

item_angels_desolator_lua = item_angels_desolator_lua or class(item_desolator_lua)
function item_angels_desolator_lua:GetIntrinsicModifierName() return "modifier_item_angels_desolator_lua" end

modifier_item_angels_desolator_lua = modifier_item_angels_desolator_lua or class({})
function modifier_item_angels_desolator_lua:IsHidden() return true end
function modifier_item_angels_desolator_lua:IsPurgable() return false end
function modifier_item_angels_desolator_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_angels_desolator_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_HERO_KILLED, MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_item_angels_desolator_lua:GetPriority() return MODIFIER_PRIORITY_ULTRA end
function modifier_item_angels_desolator_lua:OnCreated()
	if not IsServer() or not self:GetParent():IsTrueHero() then return end
	self.assists = self:GetParent():GetAssists()
end
function modifier_item_angels_desolator_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if self:GetParent() ~= kv.attacker or kv.attacker:IsIllusion() then return end
	self:GetAbility():Desolate(kv.target, self:GetAbility():GetSpecialValueFor("duration"))
end
function modifier_item_angels_desolator_lua:OnHeroKilled(kv)
	if not IsServer() then return end
	if not self:GetParent():IsTrueHero() then return end
	local assists = self:GetParent():GetAssists()
	if kv.attacker ~= self:GetParent() and self.assists <= assists then return end
	self:GetAbility():SetCurrentCharges(math.min(self:GetAbility():GetCurrentCharges() + self:GetAbility():GetSpecialValueFor(kv.attacker == self:GetParent() and "bonus_damage_per_kill" or "bonus_damage_per_assist"), self:GetAbility():GetSpecialValueFor("max_damage")))
	self.assists = assists
end
function modifier_item_angels_desolator_lua:GetModifierProjectileName() return "particles/items_fx/desolator_projectile.vpcf" end
function modifier_item_angels_desolator_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetAbility():GetCurrentCharges() end

LinkLuaModifier("modifier_item_burning_blades_lua", "items/desolator", LUA_MODIFIER_MOTION_NONE)

item_burning_blades_lua = item_burning_blades_lua or class(item_desolator_lua)
function item_burning_blades_lua:GetIntrinsicModifiers() return {"modifier_item_burning_blades_lua"} end

modifier_item_burning_blades_lua = modifier_item_burning_blades_lua or class(modifier_item_angels_desolator_lua)
function modifier_item_burning_blades_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_HERO_KILLED, MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_burning_blades_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_burning_blades_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_burning_blades_lua:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end

LinkLuaModifier("modifier_item_demons_fury_lua", "items/desolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_demons_fury_unique_lua", "items/desolator", LUA_MODIFIER_MOTION_NONE)

item_demons_fury_lua = item_demons_fury_lua or class(item_burning_blades_lua)
function item_demons_fury_lua:GetIntrinsicModifiers() return {"modifier_item_demons_fury_lua", "modifier_item_demons_fury_unique_lua"} end
function item_demons_fury_lua:OnSpellStart()
	GridNav:DestroyTreesAroundPoint(self:GetCursorTarget():GetAbsOrigin(), self:GetSpecialValueFor("chop_radius"), true)
end

modifier_item_demons_fury_lua = modifier_item_demons_fury_lua or class(modifier_item_burning_blades_lua)
function modifier_item_demons_fury_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_HERO_KILLED, MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_demons_fury_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end
	if not kv.attacker:IsIllusion() then
		self:GetAbility():Desolate(kv.target, self:GetAbility():GetSpecialValueFor("duration"))
		kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_item_angels_desolator_lua_debuff", {duration=self:GetAbility():GetSpecialValueFor("duration")})
	end
	if not kv.attacker:IsRangedAttacker() then
		DoCleaveAttack(kv.attacker, kv.target, self:GetAbility(), kv.attacker:GetAverageTrueAttackDamage(kv.target) * self:GetAbility():GetSpecialValueFor("cleave_damage_percent") / 100, self:GetAbility():GetSpecialValueFor("cleave_starting_width"), self:GetAbility():GetSpecialValueFor("cleave_ending_width"), self:GetAbility():GetSpecialValueFor("cleave_distance"), "particles/items_fx/battlefury_cleave.vpcf")
	else
		local distance = CalculateDistance(kv.attacker, kv.target)
		local overdistance = math.max(distance - 150, 0)
		DoCleaveAttack(kv.attacker, kv.target, self:GetAbility(), kv.attacker:GetAverageTrueAttackDamage(kv.target) * self:GetAbility():GetSpecialValueFor("cleave_damage_percent") / 100, math.max(self:GetAbility():GetSpecialValueFor("cleave_starting_width")-overdistance/2, 0), self:GetAbility():GetSpecialValueFor("cleave_ending_width"), self:GetAbility():GetSpecialValueFor("cleave_distance")+overdistance, "particles/items_fx/battlefury_cleave.vpcf")
	end
end
function modifier_item_demons_fury_lua:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_demons_fury_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_demons_fury_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_demons_fury_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end

modifier_item_demons_fury_unique_lua = modifier_item_demons_fury_unique_lua or class({})
function modifier_item_demons_fury_unique_lua:IsHidden() return true end
function modifier_item_demons_fury_unique_lua:IsPurgable() return false end
function modifier_item_demons_fury_unique_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL} end
function modifier_item_demons_fury_unique_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or not kv.target:IsCreep() or kv.target:IsHero() or kv.target:IsRoshan() then return end
	return self:GetAbility():GetSpecialValueFor(not kv.attacker:IsRangedAttacker() and "damage_bonus" or "damage_bonus_ranged")
end

-- LinkLuaModifier("modifier_item_demons_lance_proc_lua", "items/desolator", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_item_demons_lance_reduction_lua", "items/desolator", LUA_MODIFIER_MOTION_NONE)

-- item_demons_lance_lua = item_demons_lance_lua or class(item_desolator_lua)
-- function item_demons_lance_lua:GetIntrinsicModifiers() return {"modifier_item_burning_blades_lua", "modifier_item_demons_lance_proc_lua"} end
-- function item_demons_lance_lua:GetAOERadius() return self:GetSpecialValueFor("chop_radius") end
-- function item_demons_lance_lua:OnSpellStart()
-- 	GridNav:DestroyTreesAroundPoint(self:GetCursorTarget():GetAbsOrigin(), self:GetSpecialValueFor("chop_radius"), true)
-- end
-- function item_demons_lance_lua:OnProjectileHit(hTarget, vLocation)
-- 	if hTarget == nil then return end
-- 	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_demons_lance_reduction_lua", {})
-- 	if self:GetCaster():HasModifier("modifier_muerta_gunslinger") then
-- 		ApplyDamage({victim=hTarget, attacker=self:GetCaster(), damage=self:GetCaster():GetAverageTrueAttackDamage(hTarget), damage_type=DAMAGE_TYPE_PHYSICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=nil})
-- 	else
-- 		self:GetCaster():PerformAttack(hTarget, true, false, true, false, false, false, false)
-- 	end
-- 	self:GetCaster():RemoveModifierByName("modifier_item_demons_lance_reduction_lua")
-- end

-- modifier_item_demons_lance_proc_lua = modifier_item_demons_lance_proc_lua or class(modifier_item_burning_blades_unique_lua)
-- function modifier_item_demons_lance_proc_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE} end
-- function modifier_item_demons_lance_proc_lua:OnAttackLanded(kv)
-- 	if not IsServer() then return end
-- 	if kv.attacker ~= self:GetParent() or not kv.attacker:IsRangedAttacker() then return end
-- 	local enemies = 0
-- 	for _, enemy in pairs(FindUnitsInRadius(kv.attacker:GetTeamNumber(), kv.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("split_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)) do
-- 		if enemy ~= kv.target then
-- 			ProjectileManager:CreateTrackingProjectile({vSourceLoc=kv.target:GetAbsOrigin(), Target=enemy, iMoveSpeed=kv.attacker:GetProjectileSpeed(), bDodgeable=true, bIsAttack=false, bReplaceExisting=false, iSourceAttachment=DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, bDrawsOnMinimap=false, bVisibleToEnemies=true, EffectName=kv.attacker:GetRangedProjectileName(), Ability=self:GetAbility(), bProvidesVision=false})
-- 			enemies = enemies + 1
-- 			if enemies > self:GetAbility():GetSpecialValueFor("split_count") then break end
-- 		end
-- 	end
-- end
-- function modifier_item_demons_lance_proc_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
-- 	if not IsServer() then return end
-- 	if kv.attacker ~= self:GetParent() or kv.attacker:IsIllusion() then return end
-- 	if self:GetAbility():IsCooldownReady() and RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("explosion_chance"), self:GetAbility():entindex(), kv.attacker) then
-- 		for _, unit in pairs(FindUnitsInRadius(kv.attacker:GetTeamNumber(), kv.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("explosion_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
-- 			ApplyDamage({victim=unit, attacker=kv.attacker, damage=self:GetAbility():GetSpecialValueFor("explosion_damage"), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
-- 		end
-- 		local fx = ParticleManager:CreateParticle("particles/fireblend_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.target)
-- 		ParticleManager:SetParticleControlEnt(fx, 3, kv.target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", kv.target:GetAbsOrigin(), false)
-- 		ParticleManager:ReleaseParticleIndex(fx)
-- 		kv.target:EmitSound("Hero_Jakiro.LiquidFire")
-- 		self:GetAbility():UseResources(true, true, false, true)
-- 	end
-- 	if not kv.target:IsCreep() or kv.target:IsHero() or kv.target:IsRoshan() then return end
-- 	return self:GetAbility():GetSpecialValueFor(not kv.attacker:IsRangedAttacker() and "damage_bonus" or "damage_bonus_ranged")
-- end
-- function modifier_item_demons_lance_proc_lua:GetModifierAttackRangeBonus() if self:GetParent():IsRangedAttacker() then return self:GetAbility():GetSpecialValueFor("base_attack_range") end end

-- modifier_item_demons_lance_reduction_lua = modifier_item_demons_lance_reduction_lua or class({})
-- function modifier_item_demons_lance_reduction_lua:IsHidden() return true end
-- function modifier_item_demons_lance_reduction_lua:IsPurgable() return false end
-- function modifier_item_demons_lance_reduction_lua:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
-- function modifier_item_demons_lance_reduction_lua:OnCreated()
-- 	self.reduction = self:GetAbility():GetSpecialValueFor("splash_damage") - 100
-- end
-- function modifier_item_demons_lance_reduction_lua:GetModifierBaseDamageOutgoing_Percentage() return self.reduction end