function Minimap() {
	try {
		return GameUI.GetDotaHud().FindChildTraverse("minimap_container").FindChildTraverse("minimap");
	} catch (e) {
		return null;
	};
};

Minimap.IsOnMinimap = function() {
	const minimap = Minimap() != null ? Minimap().GetParent() : null;
	if (minimap == null) {
		return false;
	};
	const screen = [Game.GetScreenWidth(), Game.GetScreenHeight()];
	const hud_flipped = Game.IsHUDFlipped();
	let actual_cursor_pos = GameUI.GetCursorPosition();
	actual_cursor_pos[0] = !hud_flipped ? actual_cursor_pos[0] : actual_cursor_pos[0] - (screen[0] - minimap.actuallayoutwidth);
	actual_cursor_pos[1] = screen[1] - actual_cursor_pos[1];
	return actual_cursor_pos[0] <= minimap.actuallayoutwidth && actual_cursor_pos[1] <= minimap.actuallayoutheight;
};

GameEvents.SubscribeEvent("MinimapPing", function(event) {
	GameUI.PingMinimapAtLocation(event["location"].slice(0, -1))
}, "MinimapPing");