LinkLuaModifier("modifier_item_blaze_lance_lua", "items/blaze_lance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blaze_lance_proc_lua", "items/blaze_lance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blaze_lance_reduction_lua", "items/blaze_lance", LUA_MODIFIER_MOTION_NONE)

item_blaze_lance_lua = item_blaze_lance_lua or class(ability_lua_base)
function item_blaze_lance_lua:GetIntrinsicModifiers() return {"modifier_item_blaze_lance_lua", "modifier_item_blaze_lance_proc_lua"} end
function item_blaze_lance_lua:GetAOERadius() return self:GetSpecialValueFor("chop_radius") end
function item_blaze_lance_lua:OnSpellStart()
	GridNav:DestroyTreesAroundPoint(self:GetCursorTarget():GetAbsOrigin(), self:GetSpecialValueFor("chop_radius"), true)
end
function item_blaze_lance_lua:OnProjectileHit(hTarget, vLocation)
	if hTarget == nil then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_blaze_lance_reduction_lua", {})
	if self:GetCaster():HasModifier("modifier_muerta_gunslinger") then
		ApplyDamage({victim=hTarget, attacker=self:GetCaster(), damage=self:GetCaster():GetAverageTrueAttackDamage(hTarget), damage_type=DAMAGE_TYPE_PHYSICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=nil})
	else
		self:GetCaster():PerformAttack(hTarget, false, false, true, false, false, false, false)
	end
	self:GetCaster():RemoveModifierByName("modifier_item_blaze_lance_reduction_lua")
end

modifier_item_blaze_lance_lua = modifier_item_blaze_lance_lua or class({})
function modifier_item_blaze_lance_lua:IsHidden() return true end
function modifier_item_blaze_lance_lua:IsPurgable() return false end
function modifier_item_blaze_lance_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_blaze_lance_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_blaze_lance_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_blaze_lance_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_item_blaze_lance_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_blaze_lance_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end

modifier_item_blaze_lance_proc_lua = modifier_item_blaze_lance_proc_lua or class({})
function modifier_item_blaze_lance_proc_lua:IsHidden() return true end
function modifier_item_blaze_lance_proc_lua:IsPurgable() return false end
function modifier_item_blaze_lance_proc_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_item_blaze_lance_proc_lua:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or not kv.attacker:IsRangedAttacker() or kv.no_attack_cooldown then return end
	local enemies = 0
	for _, enemy in pairs(FindUnitsInRadius(kv.attacker:GetTeamNumber(), kv.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("split_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)) do
		if enemy ~= kv.target then
			ProjectileManager:CreateTrackingProjectile({vSourceLoc=kv.target:GetAbsOrigin(), Target=enemy, iMoveSpeed=kv.attacker:GetProjectileSpeed(), bDodgeable=true, bIsAttack=false, bReplaceExisting=false, iSourceAttachment=DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, bDrawsOnMinimap=false, bVisibleToEnemies=true, EffectName=kv.attacker:GetRangedProjectileName(), Ability=self:GetAbility(), bProvidesVision=false})
			enemies = enemies + 1
			if enemies > self:GetAbility():GetSpecialValueFor("split_count") then break end
		end
	end
end
function modifier_item_blaze_lance_proc_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() or kv.attacker:IsIllusion() then return end
	if self:GetAbility():IsCooldownReady() and RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("explosion_chance"), self:GetAbility():entindex(), kv.attacker) then
		for _, unit in pairs(FindUnitsInRadius(kv.attacker:GetTeamNumber(), kv.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("explosion_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			ApplyDamage({victim=unit, attacker=kv.attacker, damage=self:GetAbility():GetSpecialValueFor("explosion_damage"), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
		end
		local fx = ParticleManager:CreateParticle("particles/fireblend_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.target)
		ParticleManager:SetParticleControlEnt(fx, 3, kv.target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", kv.target:GetAbsOrigin(), false)
		ParticleManager:ReleaseParticleIndex(fx)
		kv.target:EmitSound("Hero_Jakiro.LiquidFire")
		self:GetAbility():UseResources(true, true, false, true)
	end
	if not kv.target:IsCreep() or kv.target:IsHero() or kv.target:IsRoshan() then return end
	return self:GetAbility():GetSpecialValueFor(not kv.attacker:IsRangedAttacker() and "damage_bonus" or "damage_bonus_ranged")
end
function modifier_item_blaze_lance_proc_lua:GetModifierAttackRangeBonus() if self:GetParent():IsRangedAttacker() then return self:GetAbility():GetSpecialValueFor("base_attack_range") end end

modifier_item_blaze_lance_reduction_lua = modifier_item_blaze_lance_reduction_lua or class({})
function modifier_item_blaze_lance_reduction_lua:IsHidden() return true end
function modifier_item_blaze_lance_reduction_lua:IsPurgable() return false end
function modifier_item_blaze_lance_reduction_lua:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_item_blaze_lance_reduction_lua:OnCreated()
	self.reduction = self:GetAbility():GetSpecialValueFor("splash_damage") - 100
end
function modifier_item_blaze_lance_reduction_lua:GetModifierBaseDamageOutgoing_Percentage() return self.reduction end

LinkLuaModifier("modifier_item_blaze_lance_2_lua", "items/blaze_lance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blaze_lance_2_proc_lua", "items/blaze_lance", LUA_MODIFIER_MOTION_NONE)

item_blaze_lance_2_lua = item_blaze_lance_2_lua or class(item_blaze_lance_lua)
function item_blaze_lance_2_lua:GetIntrinsicModifiers() return {"modifier_item_blaze_lance_2_lua", "modifier_item_blaze_lance_2_proc_lua"} end

modifier_item_blaze_lance_2_lua = modifier_item_blaze_lance_2_lua or class(modifier_item_blaze_lance_lua)
function modifier_item_blaze_lance_2_lua:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE} end
function modifier_item_blaze_lance_2_lua:GetModifierMoveSpeedBonus_Percentage_Unique() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end

modifier_item_blaze_lance_2_proc_lua = modifier_item_blaze_lance_2_proc_lua or class(modifier_item_blaze_lance_proc_lua)
function modifier_item_blaze_lance_2_proc_lua:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE} end
function modifier_item_blaze_lance_2_proc_lua:GetModifierStatusResistanceStacking() return self:GetAbility():GetSpecialValueFor("status_resistance") end
function modifier_item_blaze_lance_2_proc_lua:GetModifierHPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end
function modifier_item_blaze_lance_2_proc_lua:GetModifierLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("hp_regen_amp") end