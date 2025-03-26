satyr_soulstealer_mana_burn_lua = satyr_soulstealer_mana_burn_lua or class(ability_lua_base)
function satyr_soulstealer_mana_burn_lua:OnSpellStart()
	if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end
	ApplyDamage({victim = self:GetCursorTarget(), attacker = self:GetCaster(), damage = math.min(self:GetCursorTarget():GetMana(), self:GetSpecialValueFor("burn_amount")), damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self})
	self:GetCursorTarget():SpendMana(self:GetSpecialValueFor("burn_amount"), self)
	local fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCursorTarget())
	ParticleManager:SetParticleControl(fx, 0, self:GetCursorTarget():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fx)
	self:GetCursorTarget():EmitSound("n_creep_SatyrSoulstealer.ManaBurn")
end