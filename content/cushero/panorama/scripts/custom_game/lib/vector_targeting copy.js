const CONSUME_EVENT = true;
const CONTINUE_PROCESSING_EVENT = false;

var vectorTargetParticle;
var vectorTargetUnit;
var vectorStartPosition;
var vectorStartEntity;
var vectorRange = 800;
var useDual = false;
var currentlyActiveVectorTargetAbility;
var allTrees;

const defaultAbilities = ["pangolier_swashbuckle", "clinkz_burning_army", "dark_seer_wall_of_replica", "void_spirit_aether_remnant", "broodmother_sticky_snare"];
const ignoreAbilites = ["tusk_walrus_kick", "marci_companion_run"]

GameUI.SetMouseCallback(function(eventName, arg, arg2, arg3)
{
	if(GameUI.GetClickBehaviors() == 3 && currentlyActiveVectorTargetAbility != undefined){
		const netTable = CustomNetTables.GetTableValue( "vector_targeting", currentlyActiveVectorTargetAbility )
		OnVectorTargetingStart(netTable.startWidth, netTable.endWidth, netTable.castLength, netTable.dual, netTable.ignoreArrow);
		currentlyActiveVectorTargetAbility = undefined;
	}
	return CONTINUE_PROCESSING_EVENT;
});

//Listen for class changes
$.RegisterForUnhandledEvent("StyleClassesChanged", CheckAbilityVectorTargeting );
function CheckAbilityVectorTargeting(panel){
	if(panel == null){return;}

	//Check if the panel is an ability or item panel
	const abilityIndex = GetAbilityFromPanel(panel)
	if (abilityIndex >= 0) {

		//Check if the ability/item is vector targeted
		const netTable = CustomNetTables.GetTableValue("vector_targeting", abilityIndex);
		if (netTable == undefined) {
			let behavior = Abilities.GetBehavior(abilityIndex);
			if ((behavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) !== 0) {
				GameEvents.SendEventToServer("check_ability", {"abilityIndex" : abilityIndex} );
			}
			return;
		}

		//Check if the ability/item gets activated or is finished
		if (panel.BHasClass("is_active")) {
			currentlyActiveVectorTargetAbility = abilityIndex;
			if(GameUI.GetClickBehaviors() == 9 ){
				OnVectorTargetingStart(netTable.startWidth, netTable.endWidth, netTable.castLength, netTable.dual, netTable.ignoreArrow);
			}
		} else {
			OnVectorTargetingEnd();
		}
	}
}

//Find the ability/item entindex from the panorama panel
function GetAbilityFromPanel(panel) {
	if (panel.paneltype == "DOTAAbilityPanel") {

		// Be sure that it is a default ability Button
		const parent = panel.GetParent();
		if (parent != undefined && (parent.id == "abilities" || parent.id == "inventory_list")) {
			const abilityImage = panel.FindChildTraverse("AbilityImage")
			let abilityIndex = abilityImage.contextEntityIndex;
			let abilityName = abilityImage.abilityname

			//Will be undefined for items
			if (abilityName) {
				return abilityIndex;
			}

			//Return item entindex instead
			const itemImage = panel.FindChildTraverse("ItemImage")
			abilityIndex = itemImage.contextEntityIndex;
			return abilityIndex;
		}
	}
	return -1;
}

// Start the vector targeting
function OnVectorTargetingStart(fStartWidth, fEndWidth, fCastLength, bDual, bIgnoreArrow)
{
	if (vectorTargetParticle) {
		Particles.DestroyParticleEffect(vectorTargetParticle, true)
		vectorTargetParticle = undefined;
		vectorTargetUnit = undefined;
	}

	const iPlayerID = Players.GetLocalPlayer();
	const selectedEntities = Players.GetSelectedEntities( iPlayerID );
	const mainSelected = Players.GetLocalPlayerPortraitUnit();
	const mainSelectedName = Entities.GetUnitName(mainSelected);
	vectorTargetUnit = mainSelected;
	const cursor = GameUI.GetCursorPosition();
	let worldPosition = GameUI.GetScreenWorldPosition(cursor);
	const isTargetBehavior = Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, Abilities.GetBehavior(currentlyActiveVectorTargetAbility)) || Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET, Abilities.GetBehavior(currentlyActiveVectorTargetAbility));
	const isTreeBehavior = Abilities.IsTargetType(DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_TREE, Abilities.GetAbilityTargetType(currentlyActiveVectorTargetAbility));
	const isBasicBehavior = Abilities.IsTargetType(DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC, Abilities.GetAbilityTargetType(currentlyActiveVectorTargetAbility));
	const isPointBehavior = Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT, Abilities.GetBehavior(currentlyActiveVectorTargetAbility)) || Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT, Abilities.GetBehavior(currentlyActiveVectorTargetAbility));

	if (isTargetBehavior) {
		let ent = undefined;
		if (isBasicBehavior) {
			ent = GameUI.FindScreenEntities(cursor)[0];
		};
		let distance_tree = undefined;
		let tree = undefined;
		if (isTreeBehavior) {
			allTrees = Entities.GetAllEntitiesByClassname("ent_dota_tree").concat(Entities.GetAllEntitiesByClassname("dota_temp_tree"));
			for (let i=0; i<allTrees.length; i++) {
				const temp_tree = allTrees[i];
				const distance = Vector_distance(Entities.GetAbsOrigin(temp_tree), worldPosition);
				if (distance < 128 && (tree == undefined || distance_tree > distance)) {
					tree = temp_tree;
					distance_tree = distance;
				};
			};
		};
		if (ent != undefined || tree != undefined) {
			const ent_position = ent != undefined ? Entities.GetAbsOrigin(ent["entityIndex"]) : undefined;
			const tree_position = tree != undefined ? Entities.GetAbsOrigin(tree) : undefined;
			const distance_ent = ent != undefined ? Vector_distance(ent_position, worldPosition) : undefined;
			worldPosition = ent_position == undefined ? tree_position : tree_position == undefined ? ent_position : distance_ent < distance_tree ? ent_position : tree_position;
			vectorStartEntity = ent == undefined ? tree : tree == undefined ? ent["entityIndex"] : distance_ent < distance_tree ? ent["entityIndex"] : tree;
		} else if (!isPointBehavior) {
			OnVectorTargetingEnd();
			return CONTINUE_PROCESSING_EVENT;
		};
	};

	// particle variables
	let startWidth = fStartWidth || 125;
	let endWidth = fEndWidth || startWidth;
	vectorRange = fCastLength || 800;
	let ignoreArrowWidth = bIgnoreArrow;
	useDual = bDual == 1;

	// redo dota's default particles
	const abilityName = Abilities.GetAbilityName(currentlyActiveVectorTargetAbility);
	if (ignoreAbilites.includes(abilityName)) return;
	if (defaultAbilities.includes(abilityName)) {
		if (abilityName == "void_spirit_aether_remnant") {
			startWidth = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "start_radius");
			endWidth = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "end_radius");
			vectorRange = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "remnant_watch_distance");
			ignoreArrowWidth = 1;
		} else if (abilityName == "dark_seer_wall_of_replica") {
			vectorRange = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "width");
			let multiplier = 1
			if (Entities.HasScepter(mainSelected)) {
				multiplier = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "scepter_length_multiplier");
			}
			vectorRange = vectorRange * multiplier
			useDual = true;
		} else if (abilityName == "broodmother_sticky_snare") {
			useDual = true;
		} else {
			vectorRange = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "range");
		}
	}

	if (useDual) {
		vectorRange = vectorRange / 2;
	}

	let particleName = "particles/ui_mouseactions/custom_range_finder_cone.vpcf";
	if (useDual) {
		particleName = "particles/ui_mouseactions/custom_range_finder_cone_dual.vpcf"
	}

	$.Msg(useDual)
	//Initialize the particle
	vectorTargetParticle = Particles.CreateParticle(particleName, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, mainSelected);
	vectorTargetUnit = mainSelected
	Particles.SetParticleControl(vectorTargetParticle, 1, Vector_raiseZ(worldPosition, 100));
	Particles.SetParticleControl(vectorTargetParticle, 3, [endWidth, startWidth, ignoreArrowWidth]);
	Particles.SetParticleControl(vectorTargetParticle, 4, [0, 255, 0]);

	//Calculate initial particle CPs
	vectorStartPosition = worldPosition;
	const unitPosition = Entities.GetAbsOrigin(mainSelected);
	const direction = Vector_normalize(Vector_sub(vectorStartPosition, unitPosition));
	const newPosition = Vector_add(vectorStartPosition, Vector_mult(direction, vectorRange));
	if (!useDual) {
		Particles.SetParticleControl(vectorTargetParticle, 2, newPosition);
	} else {
		Particles.SetParticleControl(vectorTargetParticle, 7, newPosition);
		const secondPosition = Vector_add(vectorStartPosition, Vector_mult(Vector_negate(direction), vectorRange));
		Particles.SetParticleControl(vectorTargetParticle, 8, secondPosition);
	}


	//Start position updates
	ShowVectorTargetingParticle();
	return CONTINUE_PROCESSING_EVENT;
}

//End the particle effect
function OnVectorTargetingEnd()
{
	if (vectorTargetParticle) {
		Particles.DestroyParticleEffect(vectorTargetParticle, true)
		vectorTargetParticle = undefined;
		vectorTargetUnit = undefined;
		currentlyActiveVectorTargetAbility = undefined;
	}
}

//Updates the particle effect and detects when the ability is actually casted
function ShowVectorTargetingParticle()
{
	if (vectorTargetParticle !== undefined)
	{
		const mainSelected = Players.GetLocalPlayerPortraitUnit();
		const cursor = GameUI.GetCursorPosition();
		let worldPosition = GameUI.GetScreenWorldPosition(cursor);
		const isTargetBehavior = Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, Abilities.GetBehavior(currentlyActiveVectorTargetAbility)) || Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET, Abilities.GetBehavior(currentlyActiveVectorTargetAbility));
		const isTreeBehavior = Abilities.IsTargetType(DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_TREE, Abilities.GetAbilityTargetType(currentlyActiveVectorTargetAbility));
		const isBasicBehavior = Abilities.IsTargetType(DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC, Abilities.GetAbilityTargetType(currentlyActiveVectorTargetAbility));
		const isPointBehavior = Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT, Abilities.GetBehavior(currentlyActiveVectorTargetAbility)) || Abilities.IsBehavior(DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT, Abilities.GetBehavior(currentlyActiveVectorTargetAbility));
		const pos = isTargetBehavior ? Entities.GetAbsOrigin(vectorStartEntity) : vectorStartPosition;

		if (worldPosition == null)
		{
			$.Schedule(1 / 144, ShowVectorTargetingParticle);
			return;
		}
		const testVec = Vector_sub(worldPosition, pos);
		if (!(testVec[0] == 0 && testVec[1] == 0 && testVec[2] == 0))
		{
			let direction = Vector_normalize(Vector_sub(pos, worldPosition));
			direction = Vector_flatten(Vector_negate(direction));
			const newPosition = Vector_add(pos, Vector_mult(direction, vectorRange));
			Particles.SetParticleControl(vectorTargetParticle, 1, Vector_raiseZ(pos, 100));
			if (!useDual) {
				Particles.SetParticleControl(vectorTargetParticle, 2, newPosition);
			} else {
				Particles.SetParticleControl(vectorTargetParticle, 7, newPosition);
				const secondPosition = Vector_add(pos, Vector_mult(Vector_negate(direction), vectorRange));
				Particles.SetParticleControl(vectorTargetParticle, 8, secondPosition);
			}
		}
		if( mainSelected != vectorTargetUnit ){
			GameUI.SelectUnit(vectorTargetUnit, false )
		}
		$.Schedule(1 / 144, ShowVectorTargetingParticle);
	}
}

//Some Vector Functions here:
function Vector_normalize(vec)
{
	const val = 1 / Math.sqrt(Math.pow(vec[0], 2) + Math.pow(vec[1], 2) + Math.pow(vec[2], 2));
	return [vec[0] * val, vec[1] * val, vec[2] * val];
}

function Vector_mult(vec, mult)
{
	return [vec[0] * mult, vec[1] * mult, vec[2] * mult];
}

function Vector_add(vec1, vec2)
{
	return [vec1[0] + vec2[0], vec1[1] + vec2[1], vec1[2] + vec2[2]];
}

function Vector_sub(vec1, vec2)
{
	return [vec1[0] - vec2[0], vec1[1] - vec2[1], vec1[2] - vec2[2]];
}

function Vector_negate(vec)
{
	return [-vec[0], -vec[1], -vec[2]];
}

function Vector_flatten(vec)
{
	return [vec[0], vec[1], 0];
}

function Vector_raiseZ(vec, inc)
{
	return [vec[0], vec[1], vec[2] + inc];
}

function Vector_distance(vec1, vec2) {
	return Math.sqrt(Math.pow(vec2[0]-vec1[0], 2)+Math.pow(vec2[1]-vec1[1], 2));
}