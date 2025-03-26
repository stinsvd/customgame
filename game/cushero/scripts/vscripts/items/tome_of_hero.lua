item_tome_of_hero_lua = item_tome_of_hero_lua or class(ability_lua_base)
function item_tome_of_hero_lua:OnSpellStart()
	self:GetCaster():AddExperience(GetXPNeededToReachNextLevel(self:GetCaster():GetLevel())-GetXPNeededToReachNextLevel(self:GetCaster():GetLevel()-1), DOTA_ModifyXP_TomeOfKnowledge, true, false)
	self:SpendCharge(0)
end