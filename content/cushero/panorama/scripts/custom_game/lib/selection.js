let skip = false;

function GetSelectedEntities(clear) {
	let ents = Players.GetSelectedEntities(Players.GetLocalPlayer());
	const query = Players.GetQueryUnit(Players.GetLocalPlayer())
	if (Entities.IsValidEntity(query) && !ents.includes(query) && clear != true) {
		ents.push(query);
	};
	return ents;
};

function SendSelectedEntities() {
	GameEvents.SendEventToServer("selection_update", {entities: GetSelectedEntities(true)});
};

function GetSelectionOverride(entityIndex) {
	let table = CustomNetTables.GetTableValue("selection", entityIndex);
	return table ? table.entity : -1;
};

function Selection_New(event) {
	const entities = event["entities"];
	for (let i=0; i<entities.length; i++) {
		if (i == 0) {
			GameUI.SelectUnit(entities[i], false);
		} else {
			GameUI.SelectUnit(entities[i], true);
		};
	};
	$.Schedule(0.03, SendSelectedEntities);
};

function Selection_Add(event) {
	const entities = event["entities"];
	for (let i=0; i<entities.length; i++) {
		GameUI.SelectUnit(entities[i], true);
	};
	$.Schedule(0.03, SendSelectedEntities);
};

function Selection_Remove(event) {
	const remove_entities = event["entities"]
	let selected_entities = GetSelectedEntities();
	for (let i=0; i<remove_entities.length; i++) {
		let index = selected_entities.indexOf(remove_entities[i])
		if (index > -1) {
			selected_entities.splice(index, 1);
		};
	};
	if (selected_entities.length == 0) {
		Selection_Reset();
		return;
	};
	for (let i=0; i<selected_entities.length; i++) {
		GameUI.SelectUnit(selected_entities[i], i > 0);
	};
	$.Schedule(0.03, SendSelectedEntities);
};

function Selection_Reset(event) {
	GameUI.SelectUnit(Entities.GetLocalPlayer(), false);
	$.Schedule(0.03, SendSelectedEntities);
};

function OnUpdateSelectedUnit() {
	if (skip) {
		skip = false;
		return;
	};
	SelectionFilter(GetSelectedEntities());
	$.Schedule(0.03, SendSelectedEntities);
}

function OnUpdateQueryUnit() {
	if (skip) {
		skip = false;
		return;
	};
	SelectionFilter(GetSelectedEntities());
	$.Schedule(0.03, SendSelectedEntities);
};

function SelectionFilter(entityList) {
	for (let i=0; i<entityList.length; i++) {
		const overrideEntityIndex = GetSelectionOverride(entityList[i]);
		if (overrideEntityIndex != -1) {
			GameUI.SelectUnit(overrideEntityIndex, false);
		};
	};
};

GameEvents.SubscribeEvent("selection_new", Selection_New, "selection_new");
GameEvents.SubscribeEvent("selection_add", Selection_Add, "selection_add");
GameEvents.SubscribeEvent("selection_remove", Selection_Remove, "selection_remove");
GameEvents.SubscribeEvent("selection_reset", Selection_Reset, "selection_reset");
GameEvents.Subscribe("dota_player_update_selected_unit", OnUpdateSelectedUnit);
GameEvents.Subscribe("dota_player_update_query_unit", OnUpdateQueryUnit);