function OnDuelUpdate(table, key, data) {
	switch (key) {
		case "timer":
			OnTimerUpdate(data);
			break;

		default:
			break;
	};
};

function OnTimerUpdate(data) {
	$("#DuelTimer").text = $.Localize(`#customheroarena_dueltimer_${data['state']}`);
	$("#DuelTimerValue").text = `${Math.floor(data["time"] / 60)}:${Math.floor(data["time"] % 60) < 10 ? "0" + Math.floor(data["time"] % 60).toString() : Math.floor(data["time"] % 60)}`;
	$("#DuelRewardValue").SetDialogVariableInt("gold", data["reward"]["gold"]);
	$("#DuelRewardValue").SetDialogVariableInt("xp", data["reward"]["xp"]);
	$("#DuelRewardValue").text = $.Localize("#customheroarena_dueltimer_reward_value", $("#DuelRewardValue"))
	if (data["time"] <= 10 && Math.floor(data["time"]) < $("#DuelTimerValue").GetAttributeInt("time", 0)) {
		Game.EmitSound("BUTTON_CLICK_MINOR");
	};
	$("#DuelTimerValue").SetHasClass("red", data["time"] <= 10);
	$("#DuelHudPanel").SetHasClass("visible", data["time"] <= 10 || data["state"] == "running");
	$("#DuelTimerValue").SetAttributeInt("time", data["time"]);
};

CustomNetTables.SubscribeNetTableListener("duel", OnDuelUpdate);

OnTimerUpdate(CustomNetTables.GetTableValue("duel", "timer"));