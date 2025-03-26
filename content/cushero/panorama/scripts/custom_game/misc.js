GameUI.CustomUIConfig()["events"] = {}
GameUI.CustomUIConfig()["encryption_keys"] = {"all": "", "team": "", "player": ""}
CustomNetTables.SubscribeNetTableListener("encrypted", function(tableName, keyName, data) {
	try {
		const key = keyName.split("_");
		switch (key[0]) {
			case "player":
				if (parseInt(key[1]) == Players.GetLocalPlayer()) {
					GameUI.CustomUIConfig()["encryption_keys"][key[0]] = data["key"];
				}
				break;

			case "team":
				if (parseInt(key[1]) == Game.GetLocalPlayerInfo()["player_team_id"]) {
					GameUI.CustomUIConfig()["encryption_keys"][key[0]] = data["key"];
				}
				break;

			case "all":
				GameUI.CustomUIConfig()["encryption_keys"][key[0]] = data["key"];
				break;

			default:
				break;
		}
	} catch (err) {}
});

GameEvents.SubscribeEvent("CreateIngameErrorMessage", function(event) {
	GameEvents.SendEventLocal("dota_hud_error_message", {"splitscreenplayer": 0, "reason": event.reason || 80, "message": event.message});
}, "custom_error");

function HidePickScreen() {
	if (!Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP)) {
		GameUI.GetDotaHud().FindChildTraverse("PreGame").style.opacity = "0";
		$.Schedule(1.0, HidePickScreen);
	} else {
		GameUI.GetDotaHud().FindChildTraverse("PreGame").style.opacity = "1";
		const value = ReadSettingsOption("OptionsTabContent", "#dota_settings_teleportrequireshalt", "CheckBox", true);
		GameEvents.SendEventToServer("players_update_setting", {
			"setting": "#dota_settings_teleportrequireshalt",
			"value": value,
		});
	}
}
HidePickScreen();

const dotahud = GameUI.GetDotaHud();
dotahud.FindChildrenWithClassTraverse("AllNeutralItems")[0].style["overflow"] = "squish scroll";
dotahud.FindChildrenWithClassTraverse("ShopItemsCategory").forEach(pan => {
	pan.style["overflow"] = "squish scroll";
});
dotahud.FindChildTraverse("inventory_tpscroll_slot").SetDraggable(true);

let PlayingSounds = [];
GameEvents.SubscribeEvent("EmitSoundOnClient", function(event) {
	let sound = Game.EmitSound(event["sound"])
	if (PlayingSounds.findIndex(item => item["soundname"] == event["sound"]) !== -1) {
		PlayingSounds.push({soundname: event["sound"], sound: sound})
	}
}, "clientsound_emit");
GameEvents.SubscribeEvent("StopSoundOnClient", function(event) {
	Game.StopSound(PlayingSounds[PlayingSounds.findIndex(item => item["soundname"] == event["sound"])]["sound"]);
}, "clientsound_stop");

GameEvents.SubscribeEvent("Print", function(event) {
	if (event["printtype"] == "all") {
		let t = Object.assign({}, event);
		delete t["printtype"]
		$.Msg(t);
	} else {
		$.Msg(t["txt"]);
	}
}, "clientconsole_print");

GameEvents.SubscribeEvent("read_settings", function(event) {
	const value = ReadSettingsOption(event["tab"], event["text"], event["option"]);
	GameEvents.SendEventToServer("players_update_setting", {
		"setting": event["text"],
		"value": value["value"] != undefined ? value["value"] : value,
	});
}, "read_settings");

GameEvents.SubscribeEvent("reload_settings", function(event) {
	if (GameUI.CustomUIConfig()["settings"] != undefined) {
		for (let i=0; i<Object.keys(GameUI.CustomUIConfig()["settings"]).length; i++) {
			const [tab, text, option] = Object.keys(GameUI.CustomUIConfig()["settings"])[i].split("|");
			const value = ReadSettingsOption(tab, text, option, true);
			GameEvents.SendEventToServer("players_update_setting", {
				"setting": text,
				"value": value["value"] != undefined ? value["value"] : value,
			});
		}
	}
}, "reload_settings");

function Loop() {
	if (!Game.IsInToolsMode() || !Game.IsShopOpen()) {
		const cursor_pos = GameUI.GetCursorPosition();
		GameEvents.SendEventToServer("players_update", {
			"cursor_position": Game.ScreenXYToWorld(cursor_pos[0], cursor_pos[1]),
			"is_cursor_on_minimap": Minimap.IsOnMinimap(),
			"active_ability": Abilities.GetLocalPlayerActiveAbility(),
		});
	}
	$.Schedule(1/60, Loop);
}

Loop();