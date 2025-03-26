var currentlyActiveVectorTargetAbility = undefined;
var vectorTargetParticle = undefined;
var vectorStartPosition = undefined;

GameUI.SetMouseCallback(function(eventName, arg, arg2, arg3) {
	if (GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_CAST && currentlyActiveVectorTargetAbility != undefined) {
		vectorStartPosition = Vector.fromArray(GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()));
		GameEvents.SendEventToServer("vector_target_start", {ability: currentlyActiveVectorTargetAbility});
	}
	return false;
});

function GetTargetForAbility(ability) {
	const cursor = GameUI.GetCursorPosition();
	const worldPosition = Vector.fromArray(GameUI.GetScreenWorldPosition(cursor));
	const behavior = Abilities.GetBehavior(ability);
	const targetType = Abilities.GetAbilityTargetType(ability);
	const isTargetBehavior = (behavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) !== 0 || (behavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET) !== 0;
	const isTreeBehavior = (targetType & DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_TREE) !== 0;
	const isBasicBehavior = (targetType & DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC) !== 0;
	const isHeroBehavior = (targetType & DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO) !== 0;
	const isPointBehavior = (behavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT) !== 0 || (behavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT) !== 0;
	if (isPointBehavior) {
		return worldPosition;
	} else if (isTargetBehavior) {
		let ents = isBasicBehavior || isHeroBehavior ? GameUI.FindScreenEntities(cursor) : [];
		if (isTreeBehavior) {
			ents = ents.concat(Entities.GetAllEntitiesByClassname("ent_dota_tree").concat(Entities.GetAllEntitiesByClassname("dota_temp_tree")));
		}
		ents.sort((ent1, ent2) => (worldPosition.distanceTo(Vector.fromArray(Entities.GetAbsOrigin(ent1["entityIndex"] || ent1)))-worldPosition.distanceTo(Vector.fromArray(Entities.GetAbsOrigin(ent2["entityIndex"] || ent2)))));
		if (ents.length >= 1) {
			return ents[0];
		};
	};
	return undefined;
};

function OnVectorTargetingStart(event) {
	if (vectorTargetParticle) {
		Particles.DestroyParticleEffect(vectorTargetParticle, true)
		vectorTargetParticle = undefined;
		vectorTargetUnit = undefined;
	};
	const mainSelected = Players.GetLocalPlayerPortraitUnit();
	vectorTargetUnit = mainSelected;
	if (currentlyActiveVectorTargetAbility == undefined) {
		return OnVectorTargetingEnd();
	};
	const target = GetTargetForAbility(currentlyActiveVectorTargetAbility);
	if (target == undefined) {
		return OnVectorTargetingEnd();
	};
	const [unit, position] = [!target.isVector ? target : undefined, target.isVector ? target : Vector.fromArray(Entities.GetAbsOrigin(target))]
	const useDual = event["bDual"] == 1;
	const startWidth = event["fStartWidth"] || 125;
	const endWidth = event["fEndWidth"] || startWidth;
	const ignoreArrowWidth = event["bIgnoreArrow"];
	const vectorRange = useDual ? (event["fCastLength"] || 800)/2 : event["fCastLength"] || 800;
	vectorTargetParticle = Particles.CreateParticle(!useDual ? "particles/ui_mouseactions/custom_range_finder_cone.vpcf" : "particles/ui_mouseactions/custom_range_finder_cone_dual.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, mainSelected);
	vectorTargetUnit = mainSelected;
	const particle_position = position.copy()
	particle_position.z += 100
	Particles.SetParticleControl(vectorTargetParticle, 1, particle_position.toArray());
	Particles.SetParticleControl(vectorTargetParticle, 3, [endWidth, startWidth, ignoreArrowWidth]);
	Particles.SetParticleControl(vectorTargetParticle, 4, [0, 255, 0]);
	const unitPosition = Vector.fromArray(Entities.GetAbsOrigin(mainSelected));
	const direction = vectorStartPosition.minus(unitPosition).normalize();
	direction.z = 0;
	const newPosition = vectorStartPosition.add(direction.scale(vectorRange));
	if (!useDual) {
		Particles.SetParticleControl(vectorTargetParticle, 2, newPosition.toArray());
	} else {
		Particles.SetParticleControl(vectorTargetParticle, 7, newPosition.toArray());
		const secondPosition = vectorStartPosition.add(direction.scale(vectorRange*(-1)));
		Particles.SetParticleControl(vectorTargetParticle, 8, secondPosition.toArray());
	}
	ShowVectorTargetingParticle(target, useDual, vectorRange);
}

function OnVectorTargetingEnd() {
	if (vectorTargetParticle) {
		Particles.DestroyParticleEffect(vectorTargetParticle, true)
		vectorTargetParticle = undefined;
		currentlyActiveVectorTargetAbility = undefined;
		vectorStartPosition = undefined;
	};
};

function ShowVectorTargetingParticle(target, useDual, vectorRange) {
	if (vectorTargetParticle != undefined) {
		const mainSelected = Players.GetLocalPlayerPortraitUnit();
		let worldPosition = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
		if (worldPosition == null) {
			$.Schedule(1/60, ShowVectorTargetingParticle.bind(this, target, useDual, vectorRange));
			return;
		};
		const [unit, position] = [!target.isVector ? target : undefined, target.isVector ? target : Vector.fromArray(Entities.GetAbsOrigin(target))]
		worldPosition = Vector.fromArray(worldPosition);
		if (worldPosition.equals(position)) {
			const pos = Vector.fromArray(Entities.GetAbsOrigin(mainSelected));
			worldPosition = pos.add(position.minus(pos).normalize().scale(pos.distanceTo(position)+vectorRange));
		};
		const direction = worldPosition.minus(position).normalize();
		direction.z = 0;
		const newPosition = position.add(direction.scale(vectorRange));
		const particle_position = position.copy();
		particle_position.z += 100;
		Particles.SetParticleControl(vectorTargetParticle, 1, particle_position.toArray());
		if (!useDual) {
			Particles.SetParticleControl(vectorTargetParticle, 2, newPosition.toArray());
		} else {
			Particles.SetParticleControl(vectorTargetParticle, 7, newPosition.toArray());
			const secondPosition = position.add(direction.scale(vectorRange*(-1)));
			Particles.SetParticleControl(vectorTargetParticle, 8, secondPosition.toArray());
		};
		if (mainSelected != vectorTargetUnit && vectorTargetUnit != undefined) {
			GameUI.SelectUnit(vectorTargetUnit, false);
		};
		$.Schedule(1/60, ShowVectorTargetingParticle.bind(this, target, useDual, vectorRange));
	};
};

GameEvents.SubscribeEvent("vector_target_start", OnVectorTargetingStart);

$.RegisterForUnhandledEvent("StyleClassesChanged", function CheckAbilityVectorTargeting(panel) {
	if(panel == null) {return;};
	if (panel.paneltype == "DOTAAbilityPanel") {
		const parent = panel.GetParent();
		if (parent != undefined && (parent.id == "abilities" || parent.id == "inventory_list" || parent.id == "inventory_list2")) {
			const abilityImage = panel.FindChildTraverse("AbilityImage");
			const itemImage = panel.FindChildTraverse("ItemImage");
			const abilityIndex = abilityImage.abilityname ? abilityImage.contextEntityIndex : itemImage ? itemImage.contextEntityIndex : -1;
			if (abilityIndex >= 0) {
				if (panel.BHasClass("is_active") && (Abilities.GetBehavior(abilityIndex) & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) !== 0) {
					currentlyActiveVectorTargetAbility = abilityIndex;
					if (GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_VECTOR_CAST) {
						vectorStartPosition = Vector.fromArray(GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()));
						GameEvents.SendEventToServer("vector_target_start", {ability: abilityIndex});
					};
				} else {
					OnVectorTargetingEnd();
				};
			};
		};
	};
});