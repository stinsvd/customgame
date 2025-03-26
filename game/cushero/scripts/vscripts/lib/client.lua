if IsClient() then
-- overriding valve-broken functions
C_DOTA_Ability_Lua.GetCastRangeBonus = function(self, hTarget)
	if not self or self:IsNull() then return 0 end
	if not self:GetCaster() or self:GetCaster():IsNull() then return 0 end
	return self:GetCaster():GetCastRangeBonus()
end
C_DOTABaseAbility.GetCastRangeBonus = function(self, hTarget)
	if not self or self:IsNull() then return 0 end
	if not self:GetCaster() or self:GetCaster():IsNull() then return 0 end
	return self:GetCaster():GetCastRangeBonus()
end
end

-- math
function BoolToNum(v)
	if type(v) == "number" then return v == 1
	elseif type(v) == "boolean" then if v then return 1 else return 0 end end
end
function CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end
function DirectionRange(direction, max, min)
	if max and direction:Length2D() > max then
		return direction:Normalized() * max
	elseif min and direction:Length2D() < min then
		return direction:Normalized() * min
	end
	return direction
end
function VectorIncludes(vect1, vect2, rad)
	local radius = rad or 16
	return math.abs(vect1.x-vect2.x) <= radius and math.abs(vect1.z-vect2.z) <= radius and math.abs(vect1.y-vect2.y) <= radius
end
function math.round(val, decimal)
	local exp = decimal and 10^decimal or 1
	return math.ceil(val * exp - 0.5) / exp
end
function math.symbolsCount(num)
	return #(string.gsub(tostring(num),"%p+",""))
end

-- string
function string.split(str, sep)
	if sep == nil then sep = "%s" end
	local t = {}
	for s in string.gmatch(str, "([^"..sep.."]+)") do
		table.insert(t, s)
	end
	return t
end
function string.startswith(str, find)
	return string.sub(str, 1, string.len(find)) == find
end

-- table
function table.find(t, e)
	for k,v in pairs(t) do
		if (type(v) ~= "table" or type(e) ~= "table") and v == e then
			return k
		elseif type(v) == "table" and type(e) == "table" and table.equals(v, e) then
			return k
		end
	end
end
function table.contains(t, e)
	for k,v in pairs(t) do
		if (type(v) ~= "table" or type(e) ~= "table") and v == e then
			return true
		elseif type(v) == "table" and type(e) == "table" and table.equals(v, e) then
			return true
		end
	end
	return false
end
function table.length(t)
	return #table.values(t)
end
function table.copy(t)
	if t == nil then return {} end
	local result = {}
	for k,v in pairs(t) do
		result[k] = v
	end
	return result
end
function table.max(t, table_type)
	local values = {}
	for k,v in pairs(t) do
		if type(v) == "number" or type(v) == "table" then
			table.insert(values, v)
		end
	end
	local function compare(a, b)
		local a_weight = type(a) == "table" and table.length(a) or a
		local b_weight = type(b) == "table" and table.length(b) or b
		return a_weight < b_weight
	end
	table.sort(values, compare)
	if table_type then
		local max_elements = {}
		local max_weight = type(values[#values]) == "table" and table.length(values[#values]) or values[#values]
		for _, el in pairs(values) do
			local el_weight = type(el) == "table" and table.length(el) or el
			if max_weight == el_weight then
				table.insert(max_elements, el)
			end
		end
		return max_elements
	else
		return values[#values]
	end
end
function table.min(t, table_type)
	local values = {}
	for k, v in pairs(t) do
		if type(v) == "number" or type(v) == "table" then
			table.insert(values, v)
		end
	end
	local function compare(a, b)
		local a_weight = type(a) == "table" and table.length(a) or a
		local b_weight = type(b) == "table" and table.length(b) or b
		return a_weight < b_weight
	end
	table.sort(values, compare)
	if table_type then
		local min_elements = {}
		local max_weight = type(values[1]) == "table" and table.length(values[1]) or values[1]
		for _, el in pairs(values) do
			local el_weight = type(el) == "table" and table.length(el) or el
			if max_weight == el_weight then
				table.insert(min_elements, el)
			end
		end
		return min_elements
	else
		return values[1]
	end
end
function table.keys(t)
	local keys = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end
function table.values(t)
	local values = {}
	for k,v in pairs(t) do
		table.insert(values, v)
	end
	return values
end
function table.reverse(t)
	local reversed = {}
	for k,v in pairs(t) do
		reversed[v] = k
	end
	return reversed
end
function table.join(t, sep)
	return table.concat(table.map(t, function(_, v) return tostring(v) end), sep)
end
function table.sum(t)
	local sum = 0
	for _, i in pairs(t) do
		if type(i) == "number" then
			sum = sum + i
		end
	end
	return sum
end
function table.mean(t)
	return table.length(t) > 0 and table.sum(t)/table.length(t) or 0
end
function table.nearest(t, num)
	local values = table.filter(table.values(t), function(_, v) return type(v) == "number" end)
	table.sort(values, function(a, b)
		return math.abs(num-a) < math.abs(num-b)
	end)
	return values[1]
end
function table.duplicates(t, el)
	local tt = table.copy(t)
	local newtable = table.copy(t)
	local copies = {}
	for k, v in pairs(tt) do
		if table.contains(newtable, v) and not table.contains(copies, v) then
			table.insert(copies, v)
		end
		if el and v == el then
			table.insert(newtable, v)
		end
	end
	return copies
end
function table.merge(t1, t2)
	local t = table.copy(t1)
	if type(t2) == "table" then
		for k, v in pairs(t2) do
			t[k] = v
		end
	end
	return t
end
function table.merge_deep(t1, t2)
	local t = table.copy(t1)
	if type(t2) == "table" then
		for k, v in pairs(t2) do
			if t1 and type(t1[k]) == "table" and type(v) == "table" then
				t[k] = table.merge_deep(t1[k], v)
			else
				t[k] = v
			end
		end
	end
	return t
end
function table.combine(t1, t2)
	local t = table.copy(t1)
	for k, v in pairs(t2) do
		table.insert(t, v)
	end
	return t
end
function table.filter(t, fc)
	local tt = {}
	for k,v in pairs(t) do
		if pcall(fc, k, v) == true and fc(k, v) == true then
			tt[k] = v
		end
	end
	return tt
end
function table.map(t, fc)
	local tt = {}
	for k,v in pairs(t) do
		if pcall(fc, k, v) == true then
			tt[k] = fc(k, v)
		end
	end
	return tt
end
function table.choice(t)
	return table.values(t)[RandomInt(1, table.length(t))]
end
function table.removekey(t, key)
	local element = t[key]
	t[key] = nil
	return element
end
function table.removeElement(t, el)
	local pos = table.find(t, el)
	table.remove(t, pos)
	return pos
end
function table.open(t)
	local tt = {}
	for k, v in pairs(t) do
		for n, d in pairs(v) do
			table.insert(tt, d)
		end
	end
	return tt
end
function table.shuffle(t)
	local tt = table.values(t)
	table.sort(tt, function(a, b) return RandomFloat(0, 1) > RandomFloat(0, 1) end)
	return tt
end
function table.compare(t1, t2, notArray)
	local t3 = {added={}, removed={}, edited={}}
	local function search(t, tt, el)
		if (not notArray or notArray == nil) then return table.find(tt, el) end
		return tt[table.find(t, el)]
	end
	for k, v in pairs(t1) do
		local t2el = search(t1, t2, v)
		if t2el == nil and t2[k] == nil and v ~= nil or ((not notArray or notArray == nil) and t2[t2el] ~= v) then
			table.insert(t3["removed"], {index=k, value=v})
		elseif notArray and v ~= t2el and not table.contains(t3["edited"], {index=k, old_value=v, new_value=t2el}) then
			table.insert(t3["edited"], {index=k, old_value=v, new_value=t2el})
		end
	end
	for k, v in pairs(t2) do
		local t1el = search(t2, t1, v)
		if t1el == nil and t1[k] == nil and v ~= nil or ((not notArray or notArray == nil) and t1[t1el] ~= v) then
			table.insert(t3["added"], {index=k, value=v})
		elseif notArray and v ~= t1el and not table.contains(t3["edited"], {index=k, old_value=t1el, new_value=v}) then
			table.insert(t3["edited"], {index=k, old_value=t1el, new_value=v})
		end
	end
	return t3
end
function table.equals(t1, t2, ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not table.equals(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not table.equals(v1,v2) then return false end
	end
	return true
end

-- global
function GetStringTeam(team)
	local teams = {[DOTA_TEAM_GOODGUYS] = "radiant", [DOTA_TEAM_BADGUYS] = "bad"}
	return teams[team]
end
function GetPlayerID(userID)
	return UserIDToControllerHScript(userID):GetPlayerID()
end
function GetUserID(playerID)
	local t = CustomNetTables:GetTableValue("player_info", "UserIDs") or {}
	return t[tostring(playerID)]
end
function GetCustomAttributeDerivedStatValue(statType)
	if IsServer() then
		return GameRules:GetGameModeEntity():GetCustomAttributeDerivedStatValue(statType)
	end
	local stats = {
		[DOTA_ATTRIBUTE_STRENGTH_DAMAGE] = 1,
		[DOTA_ATTRIBUTE_STRENGTH_HP] = 2,
		[DOTA_ATTRIBUTE_STRENGTH_HP_REGEN] = 0.1,
		[DOTA_ATTRIBUTE_AGILITY_DAMAGE] = 1,
		[DOTA_ATTRIBUTE_AGILITY_ARMOR] = 0.17,
		[DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED] = 1,
		[DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE] = 1,
		[DOTA_ATTRIBUTE_INTELLIGENCE_MANA] = 12,
		[DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN] = 0.05,
		[DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESIST] = 0.1,
		[DOTA_ATTRIBUTE_ALL_DAMAGE] = 0.7,
	}
	return stats[statType]
end

-- abilities
local DOTABaseAbility = IsServer() and CDOTABaseAbility or C_DOTABaseAbility
function DOTABaseAbility:HasSpecialValue(key)
	local kv = self:GetAbilityKeyValues()
	if kv["AbilityValues"] ~= nil then
		return kv["AbilityValues"][key] ~= nil
	end
	return false
end
function HasSpecialValue(abilityname, key)
	local kv = GetAbilityKeyValuesByName(abilityname)
	if kv["AbilityValues"] ~= nil then
		return kv["AbilityValues"][key] ~= nil
	end
	return false
end
function GetSpecialValueFor(abilityname, key, lvl)
	local kv = GetAbilityKeyValuesByName(abilityname)
	if kv["AbilityValues"] ~= nil then
		if kv["AbilityValues"][key] ~= nil then
			values = string.split(kv["AbilityValues"][key], " ")
			return tonumber(values[lvl ~= nil and math.min(lvl, #values) or (kv["ItemBaseLevel"] ~= nil and math.min(kv["ItemBaseLevel"], #values) or #values)])
		end
	end
	return 0
end
function DOTABaseAbility:IsBehavior(behavior)
	return bit.band(self:GetBehaviorNum(), behavior) == behavior
end
function DOTABaseAbility:GetBehaviorNum(behavior)
	return tonumber(tostring(self:GetBehavior()))
end
function DOTABaseAbility:GetMainBehavior(priority)
	priority = priority or {DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, DOTA_ABILITY_BEHAVIOR_POINT, DOTA_ABILITY_BEHAVIOR_TOGGLE, DOTA_ABILITY_BEHAVIOR_NO_TARGET, DOTA_ABILITY_BEHAVIOR_PASSIVE}
	for _, behavior in pairs(priority) do
		if self:IsBehavior(behavior) then return behavior end
	end
end
function DOTABaseAbility:FindTalentValue(talent_name, key)
	key = key or "value"
	local kv = self:GetAbilityKeyValues()
	local val = 0
	if kv["AbilityValues"] ~= nil then
		for name, value in pairs(kv["AbilityValues"]) do
			if type(value) == "table" then
				if value["LinkedSpecialBonus"] ~= nil and value["LinkedSpecialBonus"] == talent_name then
					local operations = {
						SPECIAL_BONUS_SUBTRACT = "minus",
						SPECIAL_BONUS_MULTIPLY = "multiply",
						SPECIAL_BONUS_PERCENTAGE_ADD = "percent",
					}
					local operation = "plus"
					if value["LinkedSpecialBonusOperation"] ~= nil then
						operation = operations[value["LinkedSpecialBonusOperation"]]
					end
					local talent_value = self:GetCaster():FindTalentValue(value["LinkedSpecialBonus"], value["LinkedSpecialBonusField"])
					if operation == "plus" then
						val = val + talent_value
					elseif operation == "minus" then
						val = val - talent_value
					elseif operation == "multiply" then
						val = val * talent_value
					elseif operation == "percent" then
						val = val + val * talent_value / 100
					end
					return val
				end
			end
		end
	end
	return self:GetCaster():FindTalentValue(talent_name, key)
end
function DOTABaseAbility:GetTalentValueFor(value)
	local kv = self:GetAbilityKeyValues()
	local val = self:GetSpecialValueFor(value)
	if kv["AbilityValues"] ~= nil then
		if kv["AbilityValues"][value] ~= nil and type(kv["AbilityValues"][value]) == "table" then
			if kv["AbilityValues"][value]["LinkedSpecialBonus"] ~= nil then
				local operations = {
					SPECIAL_BONUS_SUBTRACT = "minus",
					SPECIAL_BONUS_MULTIPLY = "multiply",
					SPECIAL_BONUS_PERCENTAGE_ADD = "percent",
				}
				local operation = "plus"
				if kv["AbilityValues"][value]["LinkedSpecialBonusOperation"] ~= nil then
					operation = operations[kv["AbilityValues"][value]["LinkedSpecialBonusOperation"]]
				end
				local talent_value = self:GetCaster():FindTalentValue(kv["AbilityValues"][value]["LinkedSpecialBonus"], kv["AbilityValues"][value]["LinkedSpecialBonusField"])
				if operation == "plus" then
					val = val + talent_value
				elseif operation == "minus" then
					val = val - talent_value
				elseif operation == "multiply" then
					val = val * talent_value
				elseif operation == "percent" then
					val = val + val * talent_value / 100
				end
				return val
			end
		end
	elseif kv["AbilitySpecial"] ~= nil then
		for num, info in pairs(kv["AbilitySpecial"]) do
			if info[value] ~= nil then
				local operations = {
					SPECIAL_BONUS_SUBTRACT = "minus",
					SPECIAL_BONUS_MULTIPLY = "multiply",
					SPECIAL_BONUS_PERCENTAGE_ADD = "percent",
				}
				local operation = "plus"
				if info["LinkedSpecialBonusOperation"] ~= nil then
					operation = operations[info["LinkedSpecialBonusOperation"]]
				end
				local talent_value = self:GetCaster():FindTalentValue(info["LinkedSpecialBonus"], info["LinkedSpecialBonusField"])
				if operation == "plus" then
					val = val + talent_value
				elseif operation == "minus" then
					val = val - talent_value
				elseif operation == "multiply" then
					val = val * talent_value
				elseif operation == "percent" then
					val = val + val * talent_value / 100
				end
				return val
			end
		end
	end
	return val
end
function GetKVValue(value, lvl)
	if lvl == 0 then return 0 end
	if type(value) == "number" then
		return value
	end
	local points = string.split(value, " ")
	return tonumber(points[math.min(lvl, #points)])
end
function DOTABaseAbility:GetKVValueFor(path)
	local kv = self:GetAbilityKeyValues()
	local value = kv
	for _, p in pairs(path) do
		value = value[p]
	end
	return GetKVValue(value, self:GetLevel())
end
function DOTABaseAbility:IsRearmable()
	local exceptions = {
		"item_aeon_disk",
		"item_arcane_boots",
		"item_black_king_bar",
		"item_hand_of_midas",
		"item_helm_of_the_dominator",
		"item_helm_of_the_overlord",
		"item_sphere",
		"item_meteor_hammer",
		"item_pipe",
		"item_refresher",
		"item_refresher_shard",
		"item_necronomicon",
		"item_necronomicon_2",
		"item_necronomicon_3",
		"doom_bringer_devour",
		"dark_willow_shadow_realm_lua",
		"invoker_sun_strike_ad",
		"life_stealer_rage",
		"juggernaut_blade_fury",
		"phantom_assassin_blur",
		"spirit_breaker_bulldoze",
		"beastmaster_call_of_the_wild",
		"beastmaster_call_of_the_wild_boar",
		"beastmaster_call_of_the_wild_hawk",
		"broodmother_spawn_spiderlings",
		"enigma_demonic_conversion",
		"invoker_forge_spirit_ad",
		"furion_force_of_nature",
		"undying_tombstone",
		"skeleton_king_vampiric_aura",
		"dark_troll_warlord_raise_dead",
		"pugna_nether_ward",
		"venomancer_plague_ward",
		"zuus_cloud",
	}
	if table.contains(exceptions, self:GetAbilityName()) then
		return false
	end
	if self:GetAbilityType() == ABILITY_TYPE_ULTIMATE and not table.contains({"tinker_keen_teleport"}, self:GetAbilityName()) then
		return false
	end
	if not self:IsRefreshable() then
		return false
	end
	return true
end
function DOTABaseAbility:IsMulticastable()
	local exceptions = {
		"item_power_treads_lua",
		"item_might_treads_lua",
		"brewmaster_primal_split",
		"shredder_chakram",
		"dazzle_bad_juju",
	}
	if table.contains(exceptions, self:GetAbilityName()) then
		return false
	end
	if self:GetMainBehavior() == DOTA_ABILITY_BEHAVIOR_TOGGLE then
		return false
	end
	if self:IsBehavior(DOTA_ABILITY_BEHAVIOR_CHANNELLED) then
		return false
	end
	if self:HasCharges() then
		return false
	end
	return true
end
function DOTABaseAbility:HasCharges()
	return self:GetMaxAbilityCharges(self:GetMaxLevel()) > 0 or self:GetCurrentAbilityCharges() > 0
end
function DOTABaseAbility:IsInnateAbility()
	local ability_kv = GetAbilityKeyValuesByName(self:GetAbilityName())
	return tostring(ability_kv["Innate"]) == "1"
end
function DOTABaseAbility:IsFacetAbility()
	local caster = self:GetCaster()
	if not caster:IsHero() then return false end
	local unit_kv = GetUnitKeyValuesByName(caster:GetUnitName())
	if unit_kv["Facets"] == nil then return false end
	local ability_name = self:GetAbilityName()
	for facet_name, facet in pairs(unit_kv["Facets"]) do
		if facet["Abilities"] ~= nil then
			for _, ability_info in pairs(facet["Abilities"]) do
				if ability_info["AbilityName"] == ability_name then
					return true
				end
			end
		end
	end
	return false
end
function OrderToBehavior(order)
	if order == DOTA_UNIT_ORDER_CAST_NO_TARGET then return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	elseif order == DOTA_UNIT_ORDER_CAST_TARGET then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	elseif order == DOTA_UNIT_ORDER_CAST_POSITION then return DOTA_ABILITY_BEHAVIOR_POINT end
end
function BehaviorToOrder(behavior)
	if behavior == DOTA_ABILITY_BEHAVIOR_NO_TARGET then return DOTA_UNIT_ORDER_CAST_NO_TARGET
	elseif behavior == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then return DOTA_UNIT_ORDER_CAST_TARGET
	elseif behavior == DOTA_ABILITY_BEHAVIOR_POINT then return DOTA_UNIT_ORDER_CAST_POSITION end
end
function IsCastOrder(order)
	return order >= DOTA_UNIT_ORDER_CAST_POSITION and order <= DOTA_UNIT_ORDER_CAST_NO_TARGET
end
if IsClient() then
	function DOTABaseAbility:GetCursorTarget()
		return self:GetCaster():GetCursorCastTarget()
	end
	function DOTABaseAbility:GetCursorPosition()
		return self:GetCaster():GetCursorPosition()
	end
end
function DOTABaseAbility:GetLastCursorTarget()
	return self:GetCaster():GetLastCursorCastTarget()
end

-- items
local DOTABaseItem = IsServer() and CDOTA_Item or C_DOTA_Item
function DOTABaseItem:IsDropsOnDeath()
	return table.contains({"item_rapier", "item_gem"}, self:GetName())
end
function DOTABaseItem:HasCharges()
	return self:GetCurrentCharges() > 0 or self:GetInitialCharges() > 0 or self:GetSecondaryCharges() > 0
end

-- units
local BaseEntity = IsServer() and CBaseEntity or C_BaseEntity
function BaseEntity:IsOutpost()
	return self:GetClassname() == "npc_dota_watch_tower"
end
function BaseEntity:IsLotusPool()
	return self:GetClassname() == "npc_dota_lotus_pool"
end
function BaseEntity:IsWatcher()
	return self:GetClassname() == "npc_dota_lantern" and not (self.IsPortal and self:IsPortal())
end
function BaseEntity:IsFountain()
	return self:GetClassname() == "ent_dota_fountain"
end
function BaseEntity:HasShard()
	return self:HasModifier("modifier_item_aghanims_shard")
end

local DOTABaseNPC = IsServer() and CDOTA_BaseNPC or C_DOTA_BaseNPC
function DOTABaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:FindAbilityByName(talentName) ~= nil then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end
function DOTABaseNPC:FindTalentValue(talentName, key)
	if self:FindAbilityByName(talentName) ~= nil then
		local value_name = key or "value"
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
	end
	return 0
end
function DOTABaseNPC:GetIllusionBounty()
	return self:GetLevel() * 2
end
function DOTABaseNPC:IsRoshan()
	return table.contains({"npc_dota_roshan", "npc_dota_roshan_halloween", "npc_dota_roshan_halloween_minion", "npc_dota_mutation_pocket_roshan"}, self:GetUnitName())
end
function DOTABaseNPC:IsSiegeCreep()
	return self:GetClassname() == "npc_dota_creep_siege"
end
function DOTABaseNPC:IsSpiritBear()
	return self:GetClassname() == "npc_dota_lone_druid_bear"
end
function DOTABaseNPC:IsPortal()
	return self:GetUnitLabel() == "teleport_portal"
end
function DOTABaseNPC:GetBaseAttackSpeed()
	local unit_kv = GetUnitKeyValuesByName(self:GetUnitName())
	return unit_kv["BaseAttackSpeed"] + self:GetAgility() * GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED)
end
if IsClient() then
	function DOTABaseNPC:GetCursorCastTarget()
		return self._cast_target ~= -1 and EntIndexToHScript(self._cast_target) or nil
	end
	function DOTABaseNPC:GetCursorPosition()
		return self._cast_position or Vector(0, 0, 0)
	end
end
function DOTABaseNPC:GetLastCursorCastTarget()
	return self._last_cast_target ~= -1 and self._last_cast_target ~= nil and EntIndexToHScript(self._last_cast_target) or nil
end
if not inited then
	DOTABaseNPC.IsBoss = function(self)
		return self:GetUnitLabel() == "boss"
	end
	local valve_isinvulnerable = DOTABaseNPC.IsInvulnerable
	DOTABaseNPC.IsInvulnerable = function(self, unit)
		return valve_isinvulnerable(self) or (IsValidEntity(unit) and ((unit:GetTeamNumber() == self:GetTeamNumber() and self:HasModifier("modifier_fake_invulnerable")) or (unit:GetTeamNumber() ~= self:GetTeamNumber() and self:HasModifier("modifier_fake_invulnerable_both"))) or self:HasModifier("modifier_fake_invulnerable") or self:HasModifier("modifier_fake_invulnerable_both"))
	end
	local valve_isshrine = DOTABaseNPC.IsShrine
	DOTABaseNPC.IsShrine = function(self)
		return valve_isshrine(self) or self:GetUnitName() == "npc_dota_shrine"
	end
end