function UpdateLimit(data) {
	data = data ?? CustomNetTables.GetTableValue("options", "options") ?? {};
	const kill_limit = data["kill_limit"] ?? 100;
	$("#KillLimit").text = `${kill_limit != 0 ? kill_limit : "∞"}`;
}

function Init() {
	UpdateLimit();
}

function OnOptionsUpdate(table, key, data) {
	switch (key) {
		case "options":
			UpdateLimit(data);
			break;

		default:
			break;
	};
};

CustomNetTables.SubscribeNetTableListener("options", OnOptionsUpdate);

Init();
