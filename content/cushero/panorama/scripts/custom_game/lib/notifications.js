function TopNotification(msg) {
	AddNotification(msg, $("#TopNotifications"));
};

function BottomNotification(msg) {
	AddNotification(msg, $("#BottomNotifications"));
};

function TopRemoveNotification(msg){
	RemoveNotification(msg, $("#TopNotifications"));
};

function BottomRemoveNotification(msg){
	RemoveNotification(msg, $("#BottomNotifications"));
};

function RemoveNotification(msg, panel){
	let count = msg.count;
	if (count > 0 && panel.GetChildCount() > 0) {
		let start = panel.GetChildCount() - count;
		if (start < 0);
		start = 0;
		for (i=start;i<panel.GetChildCount(); i++){
			let lastPanel = panel.GetChild(i);
			lastPanel.deleted = true;
			lastPanel.DeleteAsync(0);
		};
	};
};

function AddNotification(msg, panel) {
	let newNotification = true;
	let lastNotification = panel.GetChild(panel.GetChildCount() - 1);
	msg.continue = msg.continue || true;
	if (lastNotification != null && msg.continue) {
		newNotification = false;
	};
	if (newNotification) {
		lastNotification = $.CreatePanel("Panel", panel, "", {hittest: "false"});
		lastNotification.SetHasClass("NotificationLine", true);
	};
	let notification_type = "Label";
	if (msg.hero != null) {
		notification_type = "DOTAHeroImage";
	} else if (msg.image != null) {
		notification_type = "Image";
	} else if (msg.ability != null) {
		notification_type = "DOTAAbilityImage";
	} else if (msg.item != null) {
		notification_type = "DOTAItemImage";
	};
	let notification = $.CreatePanel(notification_type, lastNotification, "", {hittest: "false"});
	if (typeof(msg.duration) != "number"){
		msg.duration = 3;
	};
	if (newNotification){
		$.Schedule(msg.duration, function(){
			if (lastNotification.deleted) {return;};
			lastNotification.DeleteAsync(0);
		});
	};
	if (msg.hero != null) {
		notification.heroimagestyle = msg.imagestyle || "icon";;
		notification.heroname = msg.hero;
	} else if (msg.image != null) {
		notification.SetImage(msg.image);
	} else if (msg.ability != null) {
		notification.abilityname = msg.ability;
	} else if (msg.item != null) {
		notification.itemname = msg.item;
	} else {
		notification.html = true;
		let text = msg.text != null ? msg.text : "unknown text";
		notification.text = $.Localize(text);
		notification.AddClass("TitleText");
	};
	if (msg.class != null) {
		notification.AddClass(msg.class);
	} else {
		notification.AddClass("NotificationMessage");
	};
	if (msg.style != null) {
		for (let i=0; i<Object.keys(msg.style).length; i++) {
			notification.style[Object.keys(msg.style)[i]] = Object.values(msg.style)[i];
		};
	};
};

GameEvents.SubscribeEvent("top_notification", TopNotification, "notifications_top");
GameEvents.SubscribeEvent("bottom_notification", BottomNotification, "notifications_bot");
GameEvents.SubscribeEvent("top_remove_notification", TopRemoveNotification, "notifications_top_remove");
GameEvents.SubscribeEvent("bottom_remove_notification", BottomRemoveNotification, "notifications_bot_remove");