function OpenHeroSpells(heroname) {
	if (heroname == undefined) {
		return;
	}
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
	let localplayer = Entities.GetLocalPlayer();
	for (let i=0; i<Object.keys(spells).length; i++) {
		let spell = Object.values(spells)[i];
		if (spell != "" && spell != "generic_hidden") {
			let spellpanel = $.CreatePanel("DOTAAbilityImage", $("#SpellsSpellSelection"), `AbilityPanel${spell}`, {class:"SpellsSpellIcon", hittest:"true", onactivate:`SelectSpell('${spell}')`, onmouseover:`ShowAbilityTooltip('${spell}')`, onmouseout:`HideAbilityTooltip('${spell}')`, abilityname:spell});
			spellpanel.SetHasClass("AlreadyHas", Entities.GetAbilityByName(localplayer, spell) !== -1)
		}
	}
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

function ShowAbilityTooltip(spell) {
	$.DispatchEvent("DOTAShowAbilityTooltip", $(`#AbilityPanel${spell}`), spell);
}

function HideAbilityTooltip(spell) {
	$.DispatchEvent("DOTAHideAbilityTooltip", $(`#AbilityPanel${spell}`));
}

function InteractSpell(action) {
	for (let i=0; i<$("#SpellsSpellSelection").GetChildCount(); i++) {
		let spellpanel = $("#SpellsSpellSelection").GetChild(i);
		if (spellpanel.BHasClass("Selected")) {
			GameEvents.SendEventToServer(`spellshop_spell_${action}`, {spell: spellpanel.abilityname});
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
	for (let i=0; i<$("#SpellsSpellSelection").GetChildCount(); i++) {
		let spellpanel = $("#SpellsSpellSelection").GetChild(i);
		spellpanel.SetHasClass("AlreadyHas", Entities.GetAbilityByName(localplayer, spellpanel.abilityname) !== -1);
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
}

function GetAbilityOwner(abilityname) {
	let spells = CustomNetTables.GetAllTableValues("spells_info");
	for (info of spells) {
		if (info["key"] != "heroes") {
			if (Object.values(info["value"]).includes(abilityname)) {
				return info["key"];
			}
		}
	}
}

Init();
GameEvents.SubscribeEvent("spellpoints_update", UpdateSpells, "spellshop_spellpoints_update");