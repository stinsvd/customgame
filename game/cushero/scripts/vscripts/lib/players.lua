Players = Players or class({})

local _info = {}

function Players:Init()
	CustomGameEventManager:RegisterListener("players_update", Dynamic_Wrap(Players, "OnUpdate"))
	CustomGameEventManager:RegisterListener("players_update_setting", Dynamic_Wrap(Players, "OnUpdateSetting"))
	Convars:RegisterCommand("reload_settings", Dynamic_Wrap(Players, "ReloadSettings"), "Reloads settings, which already had been read by custom game", FCVAR_HIDDEN)
end

function Players:OnUpdate(event)
	local info = table.copy(event)
	info["PlayerID"] = nil
	if _info[tostring(event["PlayerID"])] == nil then
		_info[tostring(event["PlayerID"])] = {}
	end
	for k, v in pairs(info) do
		_info[tostring(event["PlayerID"])][k] = v
	end
end

function Players:OnUpdateSetting(event)
	if _info[tostring(event["PlayerID"])] == nil then
		_info[tostring(event["PlayerID"])] = {}
	end
	if _info[tostring(event["PlayerID"])]["settings"] == nil then
		_info[tostring(event["PlayerID"])]["settings"] = {}
	end
	_info[tostring(event["PlayerID"])]["settings"][event["setting"]] = event["value"]
end

function Players:ReloadSettings()
	local playerID = Convars:GetCommandClient():GetController():GetPlayerID()
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "reload_settings", {})
end

function CDOTA_PlayerResource:GetCursorPosition(playerID)
	if _info[tostring(playerID)] ~= nil and _info[tostring(playerID)]["cursor_position"] ~= nil then
		return Vector(_info[tostring(playerID)]["cursor_position"]["0"], _info[tostring(playerID)]["cursor_position"]["1"], _info[tostring(playerID)]["cursor_position"]["2"])
	end
	return Vector(0, 0, 0)
end

function CDOTA_PlayerResource:IsCursorOnMinimap(playerID)
	if _info[tostring(playerID)] ~= nil and _info[tostring(playerID)]["is_cursor_on_minimap"] ~= nil then
		return BoolToNum(_info[tostring(playerID)]["is_cursor_on_minimap"])
	end
	return false
end

function CDOTA_PlayerResource:GetActiveAbility(playerID)
	if _info[tostring(playerID)] ~= nil and _info[tostring(playerID)]["active_ability"] ~= nil then
		return EntIndexToHScript(_info[tostring(playerID)]["active_ability"])
	end
	return nil
end

function CDOTA_PlayerResource:ReadSettings(playerID, setting, default)
	if _info[tostring(playerID)] ~= nil and _info[tostring(playerID)]["settings"] ~= nil and _info[tostring(playerID)]["settings"][setting["text"]] ~= nil then
		return _info[tostring(playerID)]["settings"][setting["text"]]
	else
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "read_settings", setting)
		return default
	end
	return nil
end

Players:Init()