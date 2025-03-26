LinkLuaModifier("modifier_ability_lua_base", "lib/abilities", LUA_MODIFIER_MOTION_NONE)

ability_lua_base = ability_lua_base or {}
function ability_lua_base:GetIntrinsicModifierName() return "modifier_ability_lua_base" end

modifier_ability_lua_base = modifier_ability_lua_base or class({})
function modifier_ability_lua_base:IsHidden() return true end
function modifier_ability_lua_base:IsPurgable() return false end
function modifier_ability_lua_base:RemoveOnDeath() return false end
function modifier_ability_lua_base:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ability_lua_base:OnCreated()
	if not IsServer() then return end
	self.modifiers = {}
	self:StartIntervalThink(0.1)
end
function modifier_ability_lua_base:OnIntervalThink()
	if self:GetAbility().GetIntrinsicModifiers ~= nil then
		for _, mod_name in pairs(self:GetAbility():GetIntrinsicModifiers()) do
			local mods = table.values(table.filter(self:GetCaster():FindAllModifiersByName(mod_name), function(_, mod)
				return mod:GetCaster() == self:GetCaster() and mod:GetAbility() == self:GetAbility() and mod:GetDuration() == -1
			end))
			if mods[1] == nil then
				table.insert(self.modifiers, self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), mod_name, {}))
			end
		end
	end
end
function modifier_ability_lua_base:OnDestroy()
	if not IsServer() then return end
	for _, mod in pairs(self.modifiers) do
		if not mod:IsNull() then
			mod:Destroy()
		end
	end
end

return ability_lua_base