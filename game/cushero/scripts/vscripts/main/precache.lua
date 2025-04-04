PrecacheModule = PrecacheModule or class({})

local precache_data = {
	"particles/neutral_fx/generic_creep_sleep.vpcf",
	"particles/ui_mouseactions/custom_range_finder_cone.vpcf",
	"particles/ui_mouseactions/custom_range_finder_cone_dual.vpcf",
	"particles/ui_mouseactions/range_finder_cone.vpcf",
	"particles/units/heroes/hero_rattletrap/clock_overclock_buff_recharge.vpcf",
	"particles/fireblend_explosion.vpcf",
	"particles/void_stick/void_stick_pull.vpcf",
	"particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf",
	"particles/units/heroes/hero_disruptor/disruptor_glimpse_travel.vpcf",
	"particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf",
	"particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf",
	"particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf",
	"particles/status_fx/status_effect_stickynapalm.vpcf",
	"particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf",
	"particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf",

	"soundevents/game_sounds_heroes/game_sounds_bane.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts",

	"models/heroes/brewmaster/brewmaster_firespirit.vmdl",
	"models/heroes/brewmaster/brewmaster_windspirit.vmdl",
	"models/heroes/brewmaster/brewmaster_earthspirit.vmdl",
	"models/heroes/brewmaster/brewmaster_voidspirit.vmdl",
	"models/heroes/nerubian_assassin/mound.vmdl",
	"models/heroes/dragon_knight/dragon_knight_dragon.vmdl",
	"models/heroes/muerta/muerta_ult.vmdl",
	"models/heroes/lycan/lycan_wolf.vmdl",
	"models/heroes/terrorblade/demon.vmdl",
	"models/heroes/undying/undying_flesh_golem.vmdl",
	"models/heroes/visage/visage_familiar.vmdl",
	"models/heroes/lone_druid/spirit_bear.vmdl",
}
local units_kv = LoadKeyValues("scripts/npc/npc_units_custom.txt")
local real_asset = {
	["soundevents"] = {file = "soundfile", folder = "none"},
	["particles"] = {file = "particle", folder = "particle_folder"},
	["models"] = {file = "model", folder = "model_folder"},
}

function PrecacheModule:Init(context)
	for _, resource in pairs(precache_data) do
		local asset = string.split(resource, "/")[1]
		if table.contains({"soundevents", "particles", "models"}, asset) then
			local temp_asset = (not string.find(resource, ".vmdl") and not string.find(resource, ".vpcf") and not string.find(resource, ".vsndevts")) and real_asset[asset]["folder"] or real_asset[asset]["file"]
			PrecacheResource(temp_asset, resource, context)
		end
	end
	for unitname, unitdata in pairs(units_kv) do
		PrecacheModel(unitdata["Model"], context)
		if unitdata["Model1"] then
			PrecacheModel(unitdata["Model1"], context)
		end
		PrecacheUnitByNameSync(unitname, context, nil)
	end
end
