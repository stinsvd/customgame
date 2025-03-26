Math.randomInt = function(min, max) {
	return Math.floor(Math.random() * (Math.floor(max) - Math.ceil(min) + 1)) + Math.ceil(min);
}

Math.roundFloat = function(num, to, isnum) {
	let res = Number(num.toFixed(to));
	if (isnum == false && Number(num.toFixed(to)) == Math.round(num)) {
		res = `${res}.`
		for (let i=0; i<to; i++) {
			res = `${res}0`
		}
	}
	return res;
}

Math.truncFloat = function(num, digits, isnum) {
	let numS = num.toString();
	let dot = numS.indexOf(".");
	if (dot === -1) {
		numS += ".0";
		dot = numS.indexOf(".");
	}
	let int = numS.split(".")[0];
	let float = numS.split(".")[1];
	if (float.length > digits) {
		numS = numS.substring(0, int.length+1+digits);
	} else if (float.length < digits) {
		for (i=0; i<Math.max(Math.min(digits-float.length, 500), 1); i++) {
			numS += "0";
		}
	}
	return isnum == false ? numS : parseFloat(numS);
}

GameUI.GetDotaHud = function() {
	let temp_pan = $.GetContextPanel();
	try {
		while (temp_pan.GetParent() != null) {
			temp_pan = temp_pan.GetParent();
		}
		return temp_pan;
	} catch (err) {
		return temp_pan;
	}
}

function Capitalize(string) {
	return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
}

function CapitalizeEvery(string) {
	const words = string.split(" ");
	let result = "";
	for (let i=0; i<words.length; i++) {
		result = result == "" ? Capitalize(words[i]) : `${result} ${Capitalize(words[i])}`;
	}
	return result;
}

String.prototype.replaceAll = function(search, replacement) {
	return this.split(search).join(replacement);
}

Object.prototype.swap = function(obj){
	let ret = {};
	for(let i=0; i<Object.keys(obj).length; i++){
		let key = Object.keys(obj)[i];
		let value = obj[key];
		if (Array.isArray(value)) {
			for (let j=0; j<value.length; j++) {
				ret[value[j]] = key;
			}
		} else if (typeof(value) == "object") {
			for (let j=0; j<Object.keys(value).length; j++) {
				ret[value[j]] = key;
			}
		} else {
			ret[value] = key;
		}
	}
	return ret;
}

GameEvents.SendEventToServer = function(event, data) {
	try {
		const customhud = GameUI.GetDotaHud().FindChildTraverse("CustomUIRoot");
		let temp_hud = customhud.FindChildTraverse("temp_hud");
		if (temp_hud != null) {temp_hud.DeleteAsync(0);}
		temp_hud = $.CreatePanel("Panel", customhud, "temp_hud", {hittest:"false", onload:`GameEvents.SendCustomGameEventToServer("${event}", ${JSON.stringify(data)});`});
		temp_hud.DeleteAsync(0);
	} catch (err) {}
}

GameEvents.SendEventLocal = function(event, data) {
	try {
		const customhud = GameUI.GetDotaHud().FindChildTraverse("CustomUIRoot");
		let temp_hud = customhud.FindChildTraverse("temp_hud");
		if (temp_hud != null) {temp_hud.DeleteAsync(0);}
		temp_hud = $.CreatePanel("Panel", customhud, "temp_hud", {hittest:"false", onload:`GameEvents.SendEventClientSide("${event}", ${JSON.stringify(data)});`});
		temp_hud.DeleteAsync(0);
	} catch (err) {}
}

Abilities.IsBehavior = function(find, behavior) {
	return parseInt(find & behavior) == parseInt(find);
}

Abilities.IsTargetType = function(find, type) {
	return parseInt(find & type) == parseInt(find);
}

Abilities.IsTargetFlag = function(find, flag) {
	return parseInt(find & flag) == parseInt(find);
}

Abilities.GetKVBehavior = function(behavior) {
	let a = behavior.split("|");
	let res = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NONE;
	for (let i=0; i<a.length; i++) {
		try {
			res += eval(`DOTA_ABILITY_BEHAVIOR.${a[i].replaceAll(" ", "")}`);
		} catch (error) {}
	}
	return res;
}

Players.GetPlayerColorHex = function (playerID) {
	let color = Players.GetPlayerColor(playerID).toString(16);
	color = color.substring(6, 8) + color.substring(4, 6) + color.substring(2, 4);
	return `#${color}`;
}

Entities.GetInventory = function(ent, start, stop) {
	start = start ?? INVENTORY_SLOTS["SLOT_1"];
	stop = stop ?? INVENTORY_SLOTS["SLOT_6"];
	let inventory = [];
	for (i=start; i<=stop; i++) {
		let temp_item = Entities.GetItemInSlot(ent, i);
		if (temp_item !== -1) {
			inventory.push(temp_item);
		}
	}
	return inventory;
}

Entities.GetLocalPlayer = function() {
	return Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
}

Game.CalculateDistance = function(a, b) {
	return Math.abs(Math.sqrt((a[0]-b[0])*(a[0]-b[0]) + (a[1]-b[1])*(a[1]-b[1]) + (a[2]-b[2])*(a[2]-b[2])));
}

GameEvents.SubscribeEvent = function(eventName, func, unique) {
	GameUI.CustomUIConfig()["events"] = GameUI.CustomUIConfig()["events"] ?? {}
	if (GameUI.CustomUIConfig()["events"][unique] != undefined) {
		GameEvents.Unsubscribe(GameUI.CustomUIConfig()["events"][unique]);
	}
	GameUI.CustomUIConfig()["events"][unique] = GameEvents.Subscribe(eventName, function(event) {
		if (event["encrypted_key"] != undefined && event["encrypted_key"] != "" && event["encrypted_key"] == GameUI.CustomUIConfig()["encryption_keys"][event["encrypted_type"]]) {
			GameUI.CustomUIConfig()["encryption_keys"][event["encrypted_type"]] = "";
			func(event);
		}
	});
}

GameUI.SmoothClose = function(panel) {
	panel.SetHasClass("SmoothClose", true);
	$.Schedule(0.25, function(panel){
		panel.visible = false;
		panel.SetHasClass("SmoothClose", false);
	}.bind(null, panel));
}

GameUI.SmoothOpen = function(panel) {
	panel.SetHasClass("SmoothOpen", true);
	panel.visible = true;
	$.Schedule(0.25, function(panel){
		panel.SetHasClass("SmoothOpen", false);
	}.bind(null, panel));
}

GameUI.SmoothToggle = function(panel) {
	if (!panel.visible) {
		GameUI.SmoothOpen(panel);
	} else {
		GameUI.SmoothClose(panel);
	}
}

Entities.IsTree = function(ent) {
	return ent > 10000;
}

function ReadSettingsOption(tab, text, option, update) {
	if (GameUI.CustomUIConfig()["settings"] == undefined) {
		GameUI.CustomUIConfig()["settings"] = {};
	}
	if (GameUI.CustomUIConfig()["settings"][`${tab}|${text}|${option}`] != undefined && update != true) {
		return GameUI.CustomUIConfig()["settings"][`${tab}|${text}|${option}`];
	}
	let should_delete = false;
	const dotahud = GameUI.GetDotaHud();
	let settings = dotahud.FindChildTraverse("SettingsNavBar");
	if (settings == null) {
		should_delete = true;
		$.DispatchEvent("DOTAShowSettingsPopup");
		settings = dotahud.FindChildTraverse("SettingsNavBar");
	}
	const options = settings.GetParent().FindChildTraverse(tab);
	options.BLoadLayoutSnippet(tab);
	const option_options = options.FindChildrenWithClassTraverse(option);
	for (let i=0; i<option_options.length; i++) {
		const opt = option_options[i];
		for (let j=0; j<opt.GetChildCount(); j++) {
			const opt_child = opt.GetChild(j);
			if (opt_child.paneltype == "Label" && opt_child.text == (text.startsWith("#") ? $.Localize(text) : text)) {
				if (option == "CheckBox") {
					GameUI.CustomUIConfig()["settings"][`${tab}|${text}|${option}`] = opt.checked;
				} else if (option == "BindingRow") {
					GameUI.CustomUIConfig()["settings"][`${tab}|${text}|${option}`] = opt.FindChildTraverse("BindingLabelContainer").FindChildTraverse("value").text;
				} else if (option == "SettingsSliderLabels") {
					const slider = opt.GetParent().FindChildTraverse("Slider");
					GameUI.CustomUIConfig()["settings"][`${tab}|${text}|${option}`] = {"value": slider.value, "min": slider.min, "max": slider.max};
				}
				break;
			}
		}
	}
	if (should_delete) {
		settings.GetParent().DeleteAsync(0);
	}
	return GameUI.CustomUIConfig()["settings"][`${tab}|${text}|${option}`];
}