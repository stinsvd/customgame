LinkLuaModifier("modifier_item_fireblend_lua", "items/fireblend", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_fireblend_proc_lua", "items/fireblend", LUA_MODIFIER_MOTION_NONE)

item_fireblend_lua = item_fireblend_lua or class(ability_lua_base)
function item_fireblend_lua:GetIntrinsicModifiers() return {"modifier_item_fireblend_lua", "modifier_item_fireblend_proc_lua"} end
function item_fireblend_lua:GetAOERadius() return self:GetSpecialValueFor("chop_radius") end
function item_fireblend_lua:OnSpellStart()
	GridNav:DestroyTreesAroundPoint(self:GetCursorTarget():GetAbsOrigin(), self:GetSpecialValueFor("chop_radius"), true)
end

modifier_item_fireblend_lua = modifier_item_fireblend_lua or class({})
function modifier_item_fireblend_lua:IsHidden() return true end
function modifier_item_fireblend_lua:IsPurgable() return false end
function modifier_item_fireblend_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_fireblend_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_fireblend_lua:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_item_fireblend_lua:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end

modifier_item_fireblend_proc_lua = modifier_item_fireblend_proc_lua or class({})
function modifier_item_fireblend_proc_lua:IsHidden() return true end
function modifier_item_fireblend_proc_lua:IsPurgable() return false end
function modifier_item_fireblend_proc_lua:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL} end
function modifier_item_fireblend_proc_lua:GetModifierProcAttack_BonusDamage_Physical(kv)
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