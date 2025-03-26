LinkLuaModifier("modifier_item_veil_of_phylactery_lua", "items/veil_of_phylactery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_veil_of_phylactery_aura_lua", "items/veil_of_phylactery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_veil_of_phylactery_debuff_lua", "items/veil_of_phylactery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_veil_of_phylactery_debuff_slow_lua", "items/veil_of_phylactery", LUA_MODIFIER_MOTION_NONE)

item_veil_of_phylactery_lua = item_veil_of_phylactery_lua or class(ability_lua_base)
function item_veil_of_phylactery_lua:GetAOERadius() return self:GetSpecialValueFor("debuff_radius") end
function item_veil_of_phylactery_lua:GetIntrinsicModifierName() return "modifier_item_veil_of_phylactery_lua" end
function item_veil_of_phylactery_lua:OnSpellStart()
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("debuff_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		enemy:RemoveModifierByName("modifier_item_veil_of_phylactery_debuff_lua")
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_item_veil_of_phylactery_debuff_lua", {duration=self:GetSpecialValueFor("resist_debuff_duration")})
	end
	local fx = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(fx, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(fx, 1, Vector(self:GetSpecialValueFor("debuff_radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCaster():EmitSound("DOTA_Item.VeilofDiscord.Activate")
end

modifier_item_veil_of_phylactery_lua = modifier_item_veil_of_phylactery_lua or class({})
function modifier_item_veil_of_phylactery_lua:IsHidden() return true end
function modifier_item_veil_of_phylactery_lua:IsPurgable() return false end
function modifier_item_veil_of_phylactery_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_veil_of_phylactery_lua:IsAura() return true end
function modifier_item_veil_of_phylactery_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_veil_of_phylactery_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_item_veil_of_phylactery_lua:GetModifierAura() return "modifier_item_veil_of_phylactery_aura_lua" end
function modifier_item_veil_of_phylactery_lua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_veil_of_phylactery_lua:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_item_veil_of_phylactery_lua:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_veil_of_phylactery_lua:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_item_veil_of_phylactery_lua:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_veil_of_phylactery_lua:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_item_veil_of_phylactery_lua:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end

modifier_item_veil_of_phylactery_aura_lua = modifier_item_veil_of_phylactery_aura_lua or class({})
function modifier_item_veil_of_phylactery_aura_lua:IsPurgable() return false end
function modifier_item_veil_of_phylactery_aura_lua:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor("aura_mana_regen")
end
function modifier_item_veil_of_phylactery_aura_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_item_veil_of_phylactery_aura_lua:GetModifierConstantManaRegen() return self.aura_mana_regen end

modifier_item_veil_of_phylactery_debuff_lua = modifier_item_veil_of_phylactery_debuff_lua or class({})
function modifier_item_veil_of_phylactery_debuff_lua:IsPurgable() return true end
function modifier_item_veil_of_phylactery_debuff_lua:GetEffectName() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end
function modifier_item_veil_of_phylactery_debuff_lua:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_veil_of_phylactery_debuff_lua:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_item_veil_of_phylactery_debuff_lua:OnCreated()
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
	if not IsServer() then return end
	self.triggered_abilities = {}
end
function modifier_item_veil_of_phylactery_debuff_lua:OnRefresh()
	self:OnCreated()
end
function modifier_item_veil_of_phylactery_debuff_lua:GetModifierIncomingDamage_Percentage(kv)
	if kv.target ~= self:GetParent() or kv.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL then return end
	if IsServer() and kv.inflictor ~= nil and kv.inflictor ~= self:GetAbility() and kv.attacker:GetTeamNumber() ~= kv.target:GetTeamNumber() and not table.contains(self.triggered_abilities, kv.inflictor:entindex()) then
		ApplyDamage({victim=kv.target, attacker=self:GetCaster(), damage=self:GetAbility():GetSpecialValueFor("bonus_spell_damage"), damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE, ability=self:GetAbility()})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, kv.target, self:GetAbility():GetSpecialValueFor("bonus_spell_damage"), self:GetCaster():GetPlayerOwner())
		kv.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_veil_of_phylactery_debuff_slow_lua", {duration=self:GetAbility():GetSpecialValueFor("slow_duration")})
		local fx = ParticleManager:CreateParticle("particles/items_fx/phylactery.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(fx, 0, kv.attacker:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, kv.target:GetAbsOrigin())
		kv.target:EmitSound("Item.Phylactery.Target")
		table.insert(self.triggered_abilities, kv.inflictor:entindex())
	end
	return self.spell_amp
end

modifier_item_veil_of_phylactery_debuff_slow_lua = modifier_item_veil_of_phylactery_debuff_slow_lua or class({})
function modifier_item_veil_of_phylactery_debuff_slow_lua:IsPurgable() return true end
function modifier_item_veil_of_phylactery_debuff_slow_lua:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_item_veil_of_phylactery_debuff_slow_lua:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow") * (-1)
end
function modifier_item_veil_of_phylactery_debuff_slow_lua:GetModifierMoveSpeedBonus_Percentage() return self.slow end