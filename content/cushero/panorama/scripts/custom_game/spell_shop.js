let chosenHero
function OpenHeroSpells(heroname) {
	if (heroname == undefined) {
		return;
	}
	chosenHero = heroname
	for (let i=0; i<$(`#SpellsHeroSelection`).GetChildCount(); i++) {
		let attributepanel = $(`#SpellsHeroSelection`).GetChild(i);
		for (let j=0; j<attributepanel.GetChildCount(); j++) {
			let heropanel = attributepanel.GetChild(j);
			if (heroname.indexOf(heropanel.heroname) !== -1 && heropanel.BHasClass("Selected")) {
				return;
			}
		}
	}
	$("#SpellsSpellSelection").RemoveAndDeleteChildren();
	let spells = CustomNetTables.GetTableValue("spells_info", heroname);
	if (spells && Object.keys(spells).length > 0) {
		let localplayer = Entities.GetLocalPlayer();
		for (let i = 0; i < Object.keys(spells).length; i++) {
			let spell = Object.values(spells)[i];
			if (spell != "") {
				let spellName = spell["name"]
				if (spellName != "generic_hidden") {
					let panel = $.CreatePanel("Panel", $("#SpellsSpellSelection"), `AbilityContainer${spellName}`, {class:"SpellsSpellContainer SpellsSpellIcon", hittest:"true"});
					panel.abilityname = spellName
					panel.SetHasClass("Banned", (spell["banned"] == 1) || false);
					let spellpanel = $.CreatePanel("DOTAAbilityImage", panel, `AbilityPanel${spellName}`, {class:"SpellsSpellIcon", hittest:"true", onmouseover:`ShowAbilityTooltip('${spellName}')`, onmouseout:`HideAbilityTooltip('${spellName}')`, abilityname:spellName});
					spellpanel.SetHasClass("AlreadyHas", Entities.GetAbilityByName(localplayer, spellName) !== -1)
					spellpanel.SetPanelEvent("onactivate", function() {
						if (!panel.BHasClass("Banned")) {
							SelectSpell(spellName)
						}
					});
				//	panel.SetHasClass("AghsStatusScepter", spell["scepter"] == 1);
					if (spell["scepter"] == 1) {
						let aghsscepter = $.CreatePanel("Panel", panel, "", {class:"AghsStatusScepter", hittest:"false"});
					}
				//	panel.SetHasClass("AghsStatusShard", spell["shard"] == 1);
					if (spell["shard"] == 1) {
						let aghsshard = $.CreatePanel("Panel", panel, "", {class:"AghsStatusShard", hittest:"false"});
					}
				}
			}
		}
	}
	UpdateBans()
	for (let i=0; i<$(`#SpellsHeroSelection`).GetChildCount(); i++) {
		let attributepanel = $(`#SpellsHeroSelection`).GetChild(i);
		for (let j=0; j<attributepanel.GetChildCount(); j++) {
			let heropanel = attributepanel.GetChild(j);
			heropanel.SetHasClass("Selected", heroname.indexOf(heropanel.heroname) !== -1);
		}
	}
	for (let i=0; i<$(`#SpellsHeroSelection`).GetChildCount(); i++) {
		let attributepanel = $(`#SpellsHeroSelection`).GetChild(i);
		for (let j=0; j<attributepanel.GetChildCount(); j++) {
			let heropanel = attributepanel.GetChild(j);
			heropanel.SetHasClass("Selected", heroname.indexOf(heropanel.heroname) !== -1);
		}
	}
}

let banLength = 0
function UpdateBans() {
	let bans = CustomNetTables.GetTableValue("spells_info", "banned") || {};
	if (bans && Object.keys(bans["abilities"]).length > 0) {
		if (banLength != Object.keys(bans["abilities"]).length) {
			banLength = Object.keys(bans["abilities"]).length
			$("#SpellShopBanned").RemoveAndDeleteChildren();
			for (let i = 1; i <= Object.keys(bans["abilities"]).length; i++) {
				let spellName = bans["abilities"][i];
				let abba = $.CreatePanel("DOTAAbilityImage", $("#SpellShopBanned"), `Banned${spellName}`, {class:"SpellsSpellIcon", hittest:"true", abilityname:spellName});
				abba.SetPanelEvent("onmouseover", function() {
					$.DispatchEvent("DOTAShowAbilityTooltip", abba, spellName);
				});
				abba.SetPanelEvent("onmouseout", function() {
					$.DispatchEvent("DOTAHideAbilityTooltip", abba);
				});
			}
		}
	}
}

function ToggleOpen(force) {
	if (force != undefined) {
		$("#SpellShopBackground").SetHasClass("ToggleOpen", force);
	} else {
		$("#SpellShopBackground").ToggleClass("ToggleOpen");
	}
	OpenHeroSpells(chosenHero)
}

function ShowAbilityTooltip(spell) {
	$.DispatchEvent("DOTAShowAbilityTooltip", $(`#AbilityContainer${spell}`), spell);
}

function HideAbilityTooltip(spell) {
	$.DispatchEvent("DOTAHideAbilityTooltip", $(`#AbilityContainer${spell}`));
}

function InteractSpell(action) {
	for (let i=0; i<$("#SpellsSpellSelection").GetChildCount(); i++) {
		let spellpanel = $("#SpellsSpellSelection").GetChild(i);
		if (spellpanel.BHasClass("Selected")) {
			if (action == "ban") spellpanel.SetHasClass("Selected", false)
			GameEvents.SendEventToServer(`spellshop_spell_${action}`, {PlayerID: Entities.GetLocalPlayer(), spell: spellpanel.abilityname});
			return;
		}
	}
}

function SelectSpell(spellname) {
	for (let i=0; i<$("#SpellsSpellSelection").GetChildCount(); i++) {
		let spellpanel = $("#SpellsSpellSelection").GetChild(i);
		spellpanel.SetHasClass("Selected", spellpanel.abilityname == spellname)
	}
}

function UpdateSpells() {
	let localplayer = Entities.GetLocalPlayer();
	$("#SpellShopOpen").GetChild(0).text = `Spell Shop (${Entities.GetAbilityPoints(Entities.GetLocalPlayer())})`;
	let bans = CustomNetTables.GetTableValue("spells_info", "banned") || {};
	let localBans = bans["banAttempts"][Players.GetLocalPlayer()];
	UpdateBans()
	$("#BanSpell").visible = (localBans > 0);
	$("#BanSpell").GetChild(0).text = `Ban (${localBans})`;
	for (let i=0; i<$("#SpellsSpellSelection").GetChildCount(); i++) {
		let panel = $("#SpellsSpellSelection").GetChild(i);
		let spellpanel = panel.GetChild(0);
		spellpanel.SetHasClass("AlreadyHas", Entities.GetAbilityByName(localplayer, spellpanel.abilityname) !== -1);
		panel.SetHasClass("Banned", Object.values(bans["abilities"]).some(ban => spellpanel.abilityname == ban));
	}
	for (let i = 0; i <= 31; i++) {
		let ability = Entities.GetAbility(localplayer, i);
		let apanel = $("#SpellShopSwapAbilities").FindChildTraverse(`${i}`);
		if (apanel == null) {
			apanel = $.CreatePanel("DOTAAbilityImage", $("#SpellShopSwapAbilities"), `${i}`, {draggable: "true"});
			$.RegisterEventHandler("DragDrop", apanel, (panel, draggedpanel) => {
				if (panel.GetParent().id == "SpellShopSwapAbilities") {
					GameEvents.SendEventToServer("swap_abilities", {slot1: parseInt(panel.id), slot2: parseInt(draggedpanel.id)});
					$.Schedule(0.1, UpdateSpells);
				}
				draggedpanel.DeleteAsync(0);
			});
			$.RegisterEventHandler("DragStart", apanel, (panel, callback) => {
				callback.displayPanel = $.CreatePanel("DOTAAbilityImage", apanel, `${i}`, {hittest: "false", abilityname: apanel.abilityname, style: `width: 48px; height: 48px; border-radius: 50%;`});
			});
			$.RegisterEventHandler("DragEnd", apanel, (panel, draggedpanel) => {
				draggedpanel.DeleteAsync(0);
			});
		}
		if (ability === -1) {
			apanel.visible = false;
			continue;
		}
		if (Abilities.IsHidden(ability) || (Abilities.GetAbilityType(ability) & ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES) == ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES) {
			apanel.visible = false;
			continue;
		}
		apanel.abilityname = Abilities.GetAbilityName(ability);
		apanel.visible = true;
		apanel.SetPanelEvent("onactivate", () => {
			let heroname = GetAbilityOwner(apanel.abilityname);
			if (heroname != undefined) {
				OpenHeroSpells(heroname);
				SelectSpell(apanel.abilityname);
			}
		});
		apanel.SetPanelEvent("onmouseover", () => {
			$.DispatchEvent("DOTAShowAbilityTooltip", apanel, apanel.abilityname);
		});
		apanel.SetPanelEvent("onmouseout", () => {
			$.DispatchEvent("DOTAHideAbilityTooltip", apanel);
		});
	}
}

function Loop() {
	try {
		UpdateSpells();
	} catch (err) {
		$.Msg(err);
	}
	$.Schedule(0.5, Loop);
}

let attributes_list = ["STRENGTH", "AGILITY", "INTELLECT", "ALL"];
function Init() {
	$(`#SpellsHeroSelection`).RemoveAndDeleteChildren();
	let heroes = CustomNetTables.GetTableValue("spells_info", "heroes");
	let heroes_sorted = [];
	let attributes = [];
	for (let i=0; i<Object.keys(heroes).length; i++) {
		let hero = Object.keys(heroes)[i];
		let info = Object.values(heroes)[i];
		heroes_sorted.push([hero, info]);
		let attribute = info["attribute"].substring(15);
		if (!attributes.includes(attribute)) {
			attributes.push(attribute);
		}
	}
	heroes_sorted.sort(function (a, b) {
		let _a = $.Localize(`#${a[0]}`).toLowerCase().replaceAll(" ", "");
		let _b = $.Localize(`#${b[0]}`).toLowerCase().replaceAll(" ", "");
		if (_a > _b) {return 1;} else if (_a < _b) {return -1;}
		return 0;
	});
	attributes.sort(function (a, b) {
		return attributes_list.indexOf(a) - attributes_list.indexOf(b);
	});
	for (let i=0; i<attributes.length; i++) {
		$.CreatePanel("Panel", $(`#SpellsHeroSelection`), `SpellsHeroSelection${attributes[i]}`, {class:"SpellsHeroSelection", hittest:"false"});
	}
	for (let i=0; i<heroes_sorted.length; i++) {
		let hero = heroes_sorted[i][0];
		let attribute = heroes_sorted[i][1]["attribute"].substring(15);
		$.CreatePanel("DOTAHeroImage", $(`#SpellsHeroSelection${attribute}`), `HeroPanel${hero}`, {class:"SpellsHeroIcon", hittest:"true", onactivate:`OpenHeroSpells('${hero}')`, heroname:hero, heroimagestyle:"portrait", scaling:"cover"})
	}
	Loop();

	if (heroes_sorted.length > 0) {
		chosenHero = heroes_sorted[Math.floor(Math.random() * heroes_sorted.length)][0];
		OpenHeroSpells(chosenHero)
	}
	$.RegisterForUnhandledEvent("Cancelled", () => {
		ToggleOpen(true)
	})
}

function GetAbilityOwner(abilityname) {
	let spells = CustomNetTables.GetAllTableValues("spells_info");
	for (info of spells) {
		if (info["key"].startsWith("npc_dota_hero_")) {
			for (let i = 1; i <= Object.keys(info["value"]).length; i++) {
				if (info["value"][i]["name"] == abilityname) {
					return info["key"];
				}
			}
		}
	}
}

Init();
GameEvents.Subscribe("spellshop_spellpoints_update", UpdateSpells)