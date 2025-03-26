local camps = LoadKeyValues("scripts/npc/neutral_camps.txt")
_G.CAMPS_INFO = CAMPS_INFO or {}
_G.HIDDEN_ENTINDEXES = HIDDEN_ENTINDEXES or {}
NeutralCamps = NeutralCamps or class({})

function NeutralCamps:Init()
	for _, trigger in pairs(Entities:FindAllByClassname("trigger_multiple")) do
		if string.find(trigger:GetName(), "neutralcamp_") then
			CAMPS_INFO[tostring(trigger:entindex())] = {last = 0, stacks = {}}
		end
	end
end

function NeutralCamps:OnThink()
	local sizes = {"small", "medium", "hard", "ancient"}
	for index, camp_info in pairs(CAMPS_INFO) do
		local camp = EntIndexToHScript(tonumber(index))
		for _, creep_index in pairs(table.copy(camp_info["stacks"])) do
			local creep = EntIndexToHScript(creep_index)
			if (IsValidEntity(creep) and creep:IsBaseNPC() and creep:IsAlive() and creep:GetTeamNumber() == DOTA_TEAM_NEUTRALS and (creep.IsControllableByAnyPlayer == nil or not creep:IsControllableByAnyPlayer())) or (HIDDEN_ENTINDEXES[creep_index] ~= nil) then
				-- NOTE: stacked
			else
				table.remove(CAMPS_INFO[index]["stacks"], table.find(CAMPS_INFO[index]["stacks"], creep_index))
			end
		end
		if table.length(CAMPS_INFO[index]["stacks"]) < MAX_CAMPS_UNITS then
			local camp_data = string.split(camp:GetName(), "_")
			local size = string.find(camp_data[2], "random") ~= nil and table.keys(camps)[RandomInt(1, table.length(camps))] or camp_data[2]
			local season = camp_data[3]
			local neutrals_index = RandomInt(1, table.length(camps[size][season]))
			for i=1, RandomInt(2, table.length(camps[size])) do
				neutrals_index = RandomInt(1, table.length(camps[size][season]))
			end
			local neutrals = camps[size][season][tostring(neutrals_index)]
			CAMPS_INFO[index]["last"] = neutrals_index
			for creep, count in pairs(neutrals) do
				for i=1, count do
					CreateUnitByNameAsync(creep, camp:GetAbsOrigin() + RandomVector(50), true, nil, nil, DOTA_TEAM_NEUTRALS, function(unit)
						table.insert(CAMPS_INFO[index]["stacks"], unit:entindex())
						if unit:IsCreature() then
							unit:CreatureLevelUp(GET_NEUTRAL_LVL()-unit:GetLevel())
						end
					end)
				end
			end
		end
	end
	return NEUTRAL_CAMPS_RESPAWN
end

if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then
	NeutralCamps:Init()
end