const OPTIONS = {
	"kill_limit": {
		"panel": "KillLimit",
		"options": [
			["50", "50"],
			["75", "75"],
			["100", "100", true],
			["150", "150"],
			["200", "200"],
			["0", "  ∞  "],
		],
	},
	"free_sell": {
		"panel": "FreeSell",
		"options": [
			["0", "Off", true],
			["1", "On"],
		]
	},
};

function SelectOption(option, value, parent) {
	for (let i=0; i<parent.GetChildCount(); i++) {
		let child = parent.GetChild(i);
		child.checked = child.id == value;
	}
	GameEvents.SendCustomGameEventToServer("loading_screen_choose_option", {option: option, value: value});
}

function Init() {
	PostInit();

	for (const [id, info] of Object.entries(OPTIONS)) {
		const options_panel = $("#HostVotingPanel").FindChildTraverse(info["panel"]).FindChildTraverse("Options");
		options_panel.RemoveAndDeleteChildren();

		for (const limit_option of info["options"]) {
			const option = $.CreatePanel("ToggleButton", options_panel, limit_option[0], {hittest: "true", text: limit_option[1]});
			option.SetPanelEvent("onactivate", () => {
				SelectOption(id, limit_option[0], options_panel);
			});
		}

		for (const limit_option of info["options"]) {
			if (limit_option[2] == true) {
				SelectOption(id, limit_option[0], options_panel);
			}
		}
	}
}

function PostInit() {
	const player_info = Game.GetLocalPlayerInfo();
	if (player_info == null) {
		$.Schedule(0.2, PostInit);
		return;
	}
	$.GetContextPanel().SetHasClass("IsHost", player_info["player_has_host_privileges"] == true);
	$.GetContextPanel().AddClass("Loaded");
}

GameEvents.Subscribe("game_rules_state_change", () => {
	if (Game.GetState() >= DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP) {
		$.GetContextPanel().AddClass("AllLoaded");
	}
});

Init();
