-- Constants
_G.DOTA_TEAM_SPECTATOR = 1
_G.TEAMS = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}
_G.TEAMS_SPECTATOR = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS, DOTA_TEAM_SPECTATOR}
_G.INVENTORY_SLOTS = {DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_2, DOTA_ITEM_SLOT_3, DOTA_ITEM_SLOT_4, DOTA_ITEM_SLOT_5, DOTA_ITEM_SLOT_6, DOTA_ITEM_TP_SCROLL, DOTA_ITEM_NEUTRAL_ACTIVE_SLOT}
_G.BACKPACK_SLOTS = {DOTA_ITEM_SLOT_7, DOTA_ITEM_SLOT_8, DOTA_ITEM_SLOT_9}
_G.STASH_SLOTS = {DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_2, DOTA_STASH_SLOT_3, DOTA_STASH_SLOT_4, DOTA_STASH_SLOT_5, DOTA_STASH_SLOT_6}

-- Mechanics
_G.BASH_COOLDOWN_MULTIPLIER = 1.5
_G.MAX_MAGICAL_RESISTANCE_PER_INTELLIGENCE = 60

-- Spellshop
_G.MAX_ABILITY_COUNT = 12

-- Networth and experience
_G.GOLD_PER_TICK = 1
_G.GOLD_TICK_TIME = 0.6
_G.XP_TABLE = {
    0, -- 1
    200, -- 2
    500, -- 3
    900, -- 4
    1400, -- 5
    2000, -- 6
    2600, -- 7
    3200, -- 8
    4400, -- 9
    5400, -- 10
    6000, -- 11
    8200, -- 12
    9000, -- 13
    10400, -- 14
    11900, -- 15
    13500, -- 16
    15200, -- 17
    17000, -- 18
    18900, -- 19
    20900, -- 20
    23000, -- 21
    25200, -- 22
    27500, -- 23
    29900, -- 24
    32400, -- 25
    35000, -- 26
    37700, -- 27
    40500, -- 28
    43400, -- 29
    46400, -- 30
    49500, -- 31
    52700, -- 32
    56000, -- 33
    59400, -- 34
    62900, -- 35
    66500, -- 36
    70200, -- 37
    74000, -- 38
    77900, -- 39
    81900, -- 40
    86000, -- 41
    90200, -- 42
    94500, -- 43
    98900, -- 44
    103400, -- 45
    108000, -- 46
    112700, -- 47
    117500, -- 48
    122400, -- 49
    127400, -- 50
    132500, -- 51
    137700, -- 52
    143000, -- 53
    148400, -- 54
    153900, -- 55
    159500, -- 56
    165200, -- 57
    171000, -- 58
    176900, -- 59
    182900, -- 60
    189000, -- 61
    195200, -- 62
    201500, -- 63
    207900, -- 64
    214400, -- 65
    221000, -- 66
    227700, -- 67
    234500, -- 68
    241400, -- 69
    248400, -- 70
    255500, -- 71
    262700, -- 72
    270000, -- 73
    277400, -- 74
    284900, -- 75
    292500, -- 76
    300200, -- 77
    308000, -- 78
    315900, -- 79
    323900, -- 80
    332000, -- 81
    340200, -- 82
    348500, -- 83
    356900, -- 84
    365400, -- 85
    374000, -- 86
    382700, -- 87
    391500, -- 88
    400400, -- 89
    409400, -- 90
    418500, -- 91
    427700, -- 92
    437000, -- 93
    446400, -- 94
    455900, -- 95
    465500, -- 96
    475200, -- 97
    485000, -- 98
    494900, -- 99
    504900, -- 100
}

-- Duel
_G.DUEL_FIRST_START = IsDedicatedServer() and 5*60 or 15
_G.DUEL_COOLDOWN = IsDedicatedServer() and 3.5*60 or 2*60
-- _G.DUEL_COOLDOWN = IsDedicatedServer() and 3.5*60 or 15
_G.DUEL_DURATION = IsDedicatedServer() and 75 or 30
_G.DUEL_REWARD_GOLD = 100
_G.DUEL_REWARD_XP = 100
_G.DUEL_REWARD_GOLD_PM = 50
_G.DUEL_REWARD_XP_PM = 25
_G.DUEL_REMOVE_MODIFIERS = {
    "modifier_fountain_invulnerability",
    "modifier_skeleton_king_reincarnation_scepter_active",
    "modifier_life_stealer_infest",
    "modifier_life_stealer_infest_effect",
    "modifier_life_stealer_infest_enemy_hero",
    "modifier_life_stealer_infest_creep",
    "modifier_pudge_swallow",
    "modifier_pudge_swallow_hide",
    "modifier_pudge_swallow_effect",
}

-- Runes
_G.BOUNTY_RUNE_SPAWN_INIT = FrameTime()
_G.POWERUP_RUNE_SPAWN_INIT = FrameTime()
_G.XP_RUNE_SPAWN_INIT = 7*60
_G.BOUNTY_RUNE_SPAWN_INTERVAL = 2*60
_G.POWERUP_RUNE_SPAWN_INTERVAL = 2*60
_G.XP_RUNE_SPAWN_INTERVAL = 3*60

-- Other
_G.SOUNDS_COOLDOWN = SOUNDS_COOLDOWN or {}

-- Neutral camps
_G.NEUTRAL_CAMPS_RESPAWN = 30
_G.MAX_CAMPS_UNITS = 3
_G.MAX_NEUTRAL_LVL = 100
_G.GET_NEUTRAL_LVL = function()
	local min = GameRules:GetDOTATime(false, false)/60
	local lvl = min-(min%3)
	return math.min(MAX_NEUTRAL_LVL, math.floor(math.max(1, math.floor(lvl))))
end

-- Bosses
_G.BOSS_RESPAWN = 6*60
_G.BOSS_LOOT_PRESET_PSEUDORANDOM_ID = 7777778
_G.BOSS_LOOT_PSEUDORANDOM_ID = 7777779

-- AI
_G.AI_UPDATE = 0.5
_G.AI_SPELLS = {
    ["never_use"] = {},
    ["heal"] = {},
    ["only_enemy"] = {},
    ["buffs"] = {},
}

-- OPTIONS
_G.OPTIONS = {
	["kill_limit"] = {
		values = {
			"50", "75", "100", "150", "200", "0",
		},
		host_only = true,
		validating = function(value) return tonumber(value) end,
		state = DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP,
		default = 100,
	},
	["free_sell"] = {
		values = {
			"0", "1",
		},
		host_only = true,
		validating = function(value) return tonumber(value) end,
		state = DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP,
		default = 0,
	},
}


_G._abilitiesShop = {
	npc_dota_hero_antimage = {
		["1"] = {
			name = "antimage_mana_break",
		},
		["2"] = {
			name = "antimage_blink",
		},
		["3"] = {
			name = "antimage_counterspell",
		},
		["4"] = {
			name = "antimage_mana_void",
		},
	},
	npc_dota_hero_axe = {
		["1"] = {
			name = "axe_berserkers_call",
		},
		["2"] = {
			name = "axe_battle_hunger",
		},
		["3"] = {
			name = "axe_counter_helix",
		},
		["4"] = {
			name = "axe_culling_blade",
		},
	},
	npc_dota_hero_ancient_apparition = {
		["1"] = {
			name = "ancient_apparition_cold_feet",
		},
		["2"] = {
			name = "ancient_apparition_ice_vortex",
		},
		["3"] = {
			name = "ancient_apparition_chilling_touch",
		},
		["4"] = {
			name = "ancient_apparition_ice_blast",
			sub = "ancient_apparition_ice_blast_release",
		},
	},
	npc_dota_hero_alchemist = {
		["1"] = {
			name = "alchemist_acid_spray",
		},
		["2"] = {
			name = "alchemist_unstable_concoction",
			sub = "alchemist_unstable_concoction_throw",
		},
		["3"] = {
			name = "alchemist_corrosive_weaponry",
		},
		["4"] = {
			name = "alchemist_berserk_potion",
			shard = true,
		},
		["5"] = {
			name = "alchemist_chemical_rage",
		},
	},
	npc_dota_hero_abaddon = {
		["1"] = {
			name = "abaddon_death_coil",
		},
		["2"] = {
			name = "abaddon_aphotic_shield",
		},
		["3"] = {
			name = "abaddon_frostmourne",
		},
		["4"] = {
			name = "abaddon_borrowed_time",
		},
	},
	npc_dota_hero_arc_warden = {
		["1"] = {
			name = "arc_warden_flux",
		},
		["2"] = {
			name = "arc_warden_magnetic_field",
		},
		["3"] = {
			name = "arc_warden_spark_wraith",
		},
	},
	npc_dota_hero_abyssal_underlord = {
		["1"] = {
			name = "abyssal_underlord_firestorm",
		},
		["2"] = {
			name = "abyssal_underlord_pit_of_malice",
		},
		["3"] = {
			name = "abyssal_underlord_atrophy_aura",
		},
		["4"] = {
			name = "abyssal_underlord_dark_portal",
		},
	},

	npc_dota_hero_bane = {
		["1"] = {
			name = "bane_enfeeble",
		},
		["2"] = {
			name = "bane_brain_sap",
		},
		["3"] = {
			name = "bane_nightmare",
			sub = "bane_nightmare_end",
		},
		["4"] = {
			name = "bane_fiends_grip",
		},
	},
	npc_dota_hero_bloodseeker = {
		["1"] = {
			name = "bloodseeker_bloodrage",
		},
		["2"] = {
			name = "bloodseeker_blood_bath",
		},
		["3"] = {
			name = "bloodseeker_thirst",
		},
		["4"] = {
			name = "bloodseeker_rupture",
		},
	},
	npc_dota_hero_beastmaster = {
		["1"] = {
			name = "beastmaster_wild_axes",
		},
		["2"] = {
			name = "beastmaster_call_of_the_wild_boar",
		},
		["3"] = {
			name = "beastmaster_call_of_the_wild_hawk",
		},
		["4"] = {
			name = "beastmaster_inner_beast",
		},
		["5"] = {
			name = "beastmaster_drums_of_slom",
			scepter = true,
		},
		["6"] = {
			name = "beastmaster_primal_roar",
		},
	},
	npc_dota_hero_broodmother = {
		["1"] = {
			name = "broodmother_insatiable_hunger",
		},
		["2"] = {
			name = "broodmother_spin_web",
		},
		["3"] = {
			name = "broodmother_incapacitating_bite",
		},
		["4"] = {
			name = "broodmother_sticky_snare",
			scepter = true,
		},
		["5"] = {
			name = "broodmother_spawn_spiderlings",
		},
	},
	npc_dota_hero_bounty_hunter = {
		["1"] = {
			name = "bounty_hunter_shuriken_toss",
		},
		["2"] = {
			name = "bounty_hunter_jinada",
		},
		["3"] = {
			name = "bounty_hunter_wind_walk",
		},
		["4"] = {
			name = "bounty_hunter_wind_walk_ally",
			shard = true,
		},
		["5"] = {
			name = "bounty_hunter_track",
		},
	},
	npc_dota_hero_batrider = {
		["1"] = {
			name = "batrider_sticky_napalm",
		},
		["2"] = {
			name = "batrider_flamebreak",
		},
		["3"] = {
			name = "batrider_firefly",
		},
		["4"] = {
			name = "batrider_flaming_lasso",
		},
	},
	npc_dota_hero_brewmaster = {
		["1"] = {
			name = "brewmaster_thunder_clap",
		},
		["2"] = {
			name = "brewmaster_cinder_brew",
		},
		["3"] = {
			name = "brewmaster_drunken_brawler",
		},
		["4"] = {
			name = "brewmaster_primal_companion",
			scepter = true,
		},
		["5"] = {
			name = "brewmaster_primal_split",
		},
	},
	npc_dota_hero_bristleback = {
		["1"] = {
			name = "bristleback_viscous_nasal_goo",
		},
		["2"] = {
			name = "bristleback_quill_spray",
		},
		["3"] = {
			name = "bristleback_bristleback",
		},
		["4"] = {
			name = "bristleback_hairball",
			shard = true,
		},
		["5"] = {
			name = "bristleback_warpath",
		},
	},

	npc_dota_hero_crystal_maiden = {
		["1"] = {
			name = "crystal_maiden_crystal_nova",
		},
		["2"] = {
			name = "crystal_maiden_frostbite",
		},
		["3"] = {
			name = "crystal_maiden_brilliance_aura",
		},
		["4"] = {
			name = "crystal_maiden_crystal_clone",
			shard = true,
		},
		["5"] = {
			name = "crystal_maiden_freezing_field",
			sub = "crystal_maiden_freezing_field_stop",
		},
	},
	npc_dota_hero_clinkz = {
		["1"] = {
			name = "clinkz_strafe",
		},
		["2"] = {
			name = "clinkz_tar_bomb",
		},
		["3"] = {
			name = "clinkz_death_pact",
		},
		["4"] = {
			name = "clinkz_burning_barrage",
			scepter = true,
		},
		["5"] = {
			name = "clinkz_burning_army",
			shard = true,
		},
		["6"] = {
			name = "clinkz_wind_walk",
		},
	},
	npc_dota_hero_chen = {
		["1"] = {
			name = "chen_penitence",
		},
		["2"] = {
			name = "chen_divine_favor",
		},
		["3"] = {
			name = "chen_hand_of_god",
		},
	},
	npc_dota_hero_chaos_knight = {
		["1"] = {
			name = "chaos_knight_chaos_bolt",
		},
		["2"] = {
			name = "chaos_knight_reality_rift",
		},
		["3"] = {
			name = "chaos_knight_chaos_strike",
		},
		["4"] = {
			name = "chaos_knight_phantasm",
		},
	},
	npc_dota_hero_centaur = {
		["1"] = {
			name = "centaur_hoof_stomp",
		},
		["2"] = {
			name = "centaur_double_edge",
		},
		["3"] = {
			name = "centaur_return",
		},
		["4"] = {
			name = "centaur_work_horse",
			sub = "centaur_mount",
		},
		["5"] = {
			name = "centaur_stampede",
		},
	},

	npc_dota_hero_drow_ranger = {
		["1"] = {
			name = "drow_ranger_frost_arrows",
		},
		["2"] = {
			name = "drow_ranger_wave_of_silence",
		},
		["3"] = {
			name = "drow_ranger_multishot",
		},
		["4"] = {
			name = "drow_ranger_glacier",
			shard = true,
		},
		["5"] = {
			name = "drow_ranger_marksmanship",
		},
	},
	npc_dota_hero_death_prophet = {
		["1"] = {
			name = "death_prophet_carrion_swarm",
		},
		["2"] = {
			name = "death_prophet_silence",
		},
		["3"] = {
			name = "death_prophet_spirit_siphon",
		},
		["4"] = {
			name = "death_prophet_exorcism",
		},
	},
	npc_dota_hero_dragon_knight = {
		["1"] = {
			name = "dragon_knight_breathe_fire",
		},
		["2"] = {
			name = "dragon_knight_dragon_tail",
		},
		["3"] = {
			name = "dragon_knight_dragon_blood",
		},
		["4"] = {
			name = "dragon_knight_fireball",
			shard = true,
		},
		["5"] = {
			name = "dragon_knight_elder_dragon_form",
		},
	},
	npc_dota_hero_dazzle = {
		["1"] = {
			name = "dazzle_poison_touch",
		},
		["2"] = {
			name = "dazzle_shallow_grave",
		},
		["3"] = {
			name = "dazzle_shadow_wave",
		},
		["4"] = {
			name = "dazzle_nothl_projection",
			sub = "dazzle_nothl_projection_end",
		},
	},
	npc_dota_hero_dark_seer = {
		["1"] = {
			name = "dark_seer_vacuum",
		},
		["2"] = {
			name = "dark_seer_ion_shell",
		},
		["3"] = {
			name = "dark_seer_surge",
		},
		["4"] = {
			name = "dark_seer_normal_punch",
			scepter = true,
		},
		["5"] = {
			name = "dark_seer_wall_of_replica",
		},
	},
	npc_dota_hero_doom_bringer = {
		["1"] = {
			name = "doom_bringer_devour",
		},
		["2"] = {
			name = "doom_bringer_scorched_earth",
		},
		["3"] = {
			name = "doom_bringer_infernal_blade",
		},
		["4"] = {
			name = "doom_bringer_doom",
		},
	},
	npc_dota_hero_disruptor = {
		["1"] = {
			name = "disruptor_thunder_strike",
		},
		["2"] = {
			name = "disruptor_glimpse",
		},
		["3"] = {
			name = "disruptor_kinetic_field",
		},
		["4"] = {
			name = "disruptor_kinetic_fence",
		},
		["5"] = {
			name = "disruptor_static_storm",
		},
	},
	npc_dota_hero_dark_willow = {
		["1"] = {
			name = "dark_willow_bramble_maze",
		},
		["2"] = {
		--	name = "dark_willow_shadow_realm",
			name = "dark_willow_shadow_realm_lua",
		},
		["3"] = {
			name = "dark_willow_cursed_crown",
		},
		["4"] = {
			name = "dark_willow_bedlam",
		},
		["5"] = {
			name = "dark_willow_terrorize",
		},
	},
	npc_dota_hero_dawnbreaker = {
		["1"] = {
			name = "dawnbreaker_fire_wreath",
		},
		["2"] = {
			name = "dawnbreaker_celestial_hammer",
			sub = "dawnbreaker_converge",
		},
		["3"] = {
			name = "dawnbreaker_luminosity",
		},
		["4"] = {
			name = "dawnbreaker_solar_guardian",
			sub = "dawnbreaker_land",
		},
	},

	npc_dota_hero_earthshaker = {
		["1"] = {
			name = "earthshaker_fissure",
		},
		["2"] = {
			name = "earthshaker_enchant_totem",
		},
		["3"] = {
			name = "earthshaker_aftershock",
		},
		["4"] = {
			name = "earthshaker_echo_slam",
		},
	},
	npc_dota_hero_enigma = {
		["1"] = {
			name = "enigma_malefice",
		},
		["2"] = {
			name = "enigma_demonic_conversion",
		},
		["3"] = {
			name = "enigma_midnight_pulse",
		},
		["4"] = {
			name = "enigma_black_hole",
		},
	},
	npc_dota_hero_enchantress = {
		["1"] = {
			name = "enchantress_impetus",
		},
		["2"] = {
			name = "enchantress_enchant",
		},
		["3"] = {
			name = "enchantress_natures_attendants",
		},
		["4"] = {
			name = "enchantress_bunny_hop",
			shard = true,
		},
		["5"] = {
			name = "enchantress_little_friends",
			scepter = true,
		},
		["6"] = {
			name = "enchantress_untouchable",
		},
	},
	npc_dota_hero_elder_titan = {
		["1"] = {
			name = "elder_titan_echo_stomp",
		},
		["2"] = {
			name = "elder_titan_ancestral_spirit",
			sub = "elder_titan_move_spirit",
			sub2 = "elder_titan_return_spirit",
		},
		["3"] = {
			name = "elder_titan_natural_order",
		},
		["4"] = {
			name = "elder_titan_earth_splitter",
		},
	},
	npc_dota_hero_ember_spirit = {
		["1"] = {
			name = "ember_spirit_searing_chains",
		},
		["2"] = {
			name = "ember_spirit_sleight_of_fist",
		},
		["3"] = {
			name = "ember_spirit_flame_guard",
		},
		["4"] = {
			name = "ember_spirit_fire_remnant",
			sub = "ember_spirit_activate_fire_remnant",
		},
	},
	npc_dota_hero_earth_spirit = {
		["1"] = {
			name = "earth_spirit_boulder_smash",
			sub = "earth_spirit_stone_caller",
		},
		["2"] = {
			name = "earth_spirit_rolling_boulder",
			sub = "earth_spirit_stone_caller",
		},
		["3"] = {
			name = "earth_spirit_geomagnetic_grip",
			sub = "earth_spirit_stone_caller",
		},
		["4"] = {
			name = "earth_spirit_petrify",
			scepter = true,
		},
		["5"] = {
			name = "earth_spirit_magnetize",
			sub = "earth_spirit_stone_caller",
		},
	},

	npc_dota_hero_faceless_void = {
		["1"] = {
			name = "faceless_void_time_walk",
			sub = "faceless_void_time_walk_reverse",
		},
		["2"] = {
			name = "faceless_void_time_dilation",
		},
		["3"] = {
			name = "faceless_void_time_lock",
		},
		["4"] = {
			name = "faceless_void_chronosphere",
		},
		["5"] = {
			name = "faceless_void_time_zone",
		},
	},
	npc_dota_hero_furion = {
		["1"] = {
			name = "furion_sprout",
		},
		["2"] = {
			name = "furion_teleportation",
		},
		["3"] = {
			name = "furion_force_of_nature",
		},
		["4"] = {
			name = "furion_curse_of_the_forest",
			shard = true,
		},
		["5"] = {
			name = "furion_wrath_of_nature",
		},
	},

	npc_dota_hero_gyrocopter = {
		["1"] = {
			name = "gyrocopter_rocket_barrage",
		},
		["2"] = {
			name = "gyrocopter_homing_missile",
		},
		["3"] = {
			name = "gyrocopter_flak_cannon",
		},
		["4"] = {
			name = "gyrocopter_call_down",
		},
	},
	npc_dota_hero_grimstroke = {
		["1"] = {
			name = "grimstroke_dark_artistry",
		},
		["2"] = {
			name = "grimstroke_ink_creature",
		},
		["3"] = {
			name = "grimstroke_spirit_walk",
			sub = "grimstroke_return",
		},
		["4"] = {
			name = "grimstroke_soul_chain",
		},
	},

	npc_dota_hero_huskar = {
		["1"] = {
			name = "huskar_inner_fire",
		},
		["2"] = {
			name = "huskar_burning_spear",
		},
		["3"] = {
			name = "huskar_berserkers_blood",
		},
		["4"] = {
			name = "huskar_life_break",
		},
	},
	npc_dota_hero_hoodwink = {
		["1"] = {
			name = "hoodwink_acorn_shot",
		},
		["2"] = {
			name = "hoodwink_bushwhack",
		},
		["3"] = {
			name = "hoodwink_scurry",
		},
		["4"] = {
			name = "hoodwink_decoy",
		},
		["5"] = {
			name = "hoodwink_hunters_boomerang",
		},
		["6"] = {
			name = "hoodwink_sharpshooter",
			sub = "hoodwink_sharpshooter_release",
		},
	},

	npc_dota_hero_invoker = {
		["1"] = {
			name = "invoker_chaos_meteor_ad",
		},
		["2"] = {
			name = "invoker_deafening_blast_ad",
		},
		["3"] = {
			name = "invoker_tornado_ad",
		},
		["4"] = {
			name = "invoker_emp_ad",
		},
		["5"] = {
			name = "invoker_alacrity_ad",
		},
		["6"] = {
			name = "invoker_cold_snap_ad",
		},
		["7"] = {
			name = "invoker_sun_strike_ad",
		},
		["8"] = {
			name = "invoker_forge_spirit_ad",
		},
		["9"] = {
			name = "invoker_ice_wall_ad",
		},
		["10"] = {
			name = "invoker_ghost_walk_ad",
		},
	},

	npc_dota_hero_juggernaut = {
		["1"] = {
			name = "juggernaut_blade_fury",
		},
		["2"] = {
			name = "juggernaut_healing_ward",
		},
		["3"] = {
			name = "juggernaut_blade_dance",
		},
		["4"] = {
			name = "juggernaut_omni_slash",
			sub = "juggernaut_swift_slash",
		},
	},
	npc_dota_hero_jakiro = {
		["1"] = {
			name = "jakiro_dual_breath",
		},
		["2"] = {
			name = "jakiro_ice_path",
		},
		["3"] = {
			name = "jakiro_liquid_fire",
		},
		["4"] = {
			name = "jakiro_liquid_ice",
		},
		["5"] = {
			name = "jakiro_macropyre",
		},
	},

	npc_dota_hero_kunkka = {
		["1"] = {
			name = "kunkka_torrent",
		},
		["2"] = {
			name = "kunkka_tidebringer",
		},
		["3"] = {
			name = "kunkka_x_marks_the_spot",
			sub = "kunkka_return",
		},
		["4"] = {
			name = "kunkka_tidal_wave",
			shard = true,
		},
		["5"] = {
			name = "kunkka_ghostship",
		},
	},
	npc_dota_hero_kez = {
		["1"] = {
			name = "kez_echo_slash",
		},
		["2"] = {
			name = "kez_falcon_rush_ad",
		},
		["3"] = {
			name = "kez_grappling_claw",
		},
		["4"] = {
			name = "kez_talon_toss_ad",
		},
		["5"] = {
			name = "kez_kazurai_katana",
		},
		["6"] = {
			name = "kez_shodo_sai_ad",
		},
		["7"] = {
			name = "kez_raptor_dance",
		},
		["8"] = {
			name = "kez_ravens_veil_ad",
		},
	},
	npc_dota_hero_keeper_of_the_light = {
		["1"] = {
			name = "keeper_of_the_light_illuminate",
			sub = "keeper_of_the_light_illuminate_end",
		},
		["2"] = {
			name = "keeper_of_the_light_blinding_light",
		},
		["3"] = {
			name = "keeper_of_the_light_chakra_magic",
		},
		["4"] = {
			name = "keeper_of_the_light_will_o_wisp",
			scepter = true,
		},
		["5"] = {
			name = "keeper_of_the_light_spirit_form",
		},
	},

	npc_dota_hero_lina = {
		["1"] = {
			name = "lina_dragon_slave",
		},
		["2"] = {
			name = "lina_light_strike_array",
		},
		["3"] = {
			name = "lina_fiery_soul",
		},
		["4"] = {
			name = "lina_flame_cloak",
			scepter = true,
		},
		["5"] = {
			name = "lina_laguna_blade",
		},
	},
	npc_dota_hero_lich = {
		["1"] = {
			name = "lich_frost_nova",
		},
		["2"] = {
			name = "lich_frost_shield",
		},
		["3"] = {
			name = "lich_sinister_gaze",
		},
		["4"] = {
			name = "lich_ice_spire",
			shard = true,
		},
		["5"] = {
			name = "lich_chain_frost",
		},
	},
	npc_dota_hero_lion = {
		["1"] = {
			name = "lion_impale",
		},
		["2"] = {
			name = "lion_voodoo",
		},
		["3"] = {
			name = "lion_mana_drain",
		},
		["4"] = {
			name = "lion_finger_of_death",
		},
	},
	npc_dota_hero_luna = {
		["1"] = {
			name = "luna_lucent_beam",
		},
		["2"] = {
			name = "luna_lunar_orbit",
		},
		["3"] = {
			name = "luna_moon_glaive",
		},
		["4"] = {
			name = "luna_eclipse",
		},
	},
	npc_dota_hero_leshrac = {
		["1"] = {
			name = "leshrac_split_earth",
		},
		["2"] = {
			name = "leshrac_diabolic_edict",
		},
		["3"] = {
			name = "leshrac_lightning_storm",
		},
		["4"] = {
			name = "leshrac_greater_lightning_storm",
			scepter = true,
		},
		["5"] = {
			name = "leshrac_pulse_nova",
		},
	},
	npc_dota_hero_life_stealer = {
		["1"] = {
			name = "life_stealer_rage",
		},
		["2"] = {
			name = "life_stealer_open_wounds",
		},
		["3"] = {
			name = "life_stealer_ghoul_frenzy",
		},
		["4"] = {
			name = "life_stealer_infest",
			sub = "life_stealer_consume",
		},
	},
	npc_dota_hero_lycan = {
		["1"] = {
			name = "lycan_summon_wolves",
		},
		["2"] = {
			name = "lycan_howl",
		},
		["3"] = {
			name = "lycan_feral_impulse",
		},
		["4"] = {
			name = "lycan_wolf_bite",
			scepter = true,
		},
		["5"] = {
			name = "lycan_shapeshift",
		},
	},
	npc_dota_hero_lone_druid = {
		["1"] = {
			name = "lone_druid_spirit_bear",
		},
		["2"] = {
			name = "lone_druid_spirit_link",
		},
		["3"] = {
			name = "lone_druid_savage_roar",
		},
		["4"] = {
			name = "lone_druid_true_form",
		},
	},
	npc_dota_hero_legion_commander = {
		["1"] = {
			name = "legion_commander_overwhelming_odds",
		},
		["2"] = {
			name = "legion_commander_press_the_attack",
		},
		["3"] = {
			name = "legion_commander_moment_of_courage",
		},
		["4"] = {
			name = "legion_commander_duel",
		},
	},

	npc_dota_hero_mirana = {
		["1"] = {
			name = "mirana_starfall",
		},
		["2"] = {
			name = "mirana_arrow",
		},
		["3"] = {
			name = "mirana_leap",
		},
		["4"] = {
			name = "mirana_invis",
		},
		["5"] = {
			name = "mirana_solar_flare",
		},
	},
	npc_dota_hero_morphling = {
		["1"] = {
			name = "morphling_waveform",
		},
		["2"] = {
			name = "morphling_adaptive_strike_agi",
		},
	},
	npc_dota_hero_meepo = {
		["1"] = {
			name = "meepo_earthbind",
		},
		["2"] = {
			name = "meepo_poof",
		},
		["3"] = {
			name = "meepo_ransack",
		},
		["4"] = {
			name = "meepo_petrify",
			shard = true,
		},
	},
	npc_dota_hero_medusa = {
		["1"] = {
			name = "medusa_split_shot",
		},
		["2"] = {
			name = "medusa_mystic_snake",
		},
		["3"] = {
			name = "medusa_gorgon_grasp",
		},
		["4"] = {
			name = "medusa_cold_blooded",
			shard = true,
		},
		["5"] = {
			name = "medusa_stone_gaze",
		},
	},
	npc_dota_hero_magnataur = {
		["1"] = {
			name = "magnataur_shockwave",
		},
		["2"] = {
			name = "magnataur_empower",
		},
		["3"] = {
			name = "magnataur_skewer",
		},
		["4"] = {
			name = "magnataur_horn_toss",
			scepter = true,
		},
		["5"] = {
			name = "magnataur_reverse_polarity",
		},
	},
	npc_dota_hero_monkey_king = {
		["1"] = {
			name = "monkey_king_boundless_strike",
		},
		["2"] = {
			name = "monkey_king_tree_dance",
			sub = "monkey_king_primal_spring_early",
		},
		["3"] = {
			name = "monkey_king_jingu_mastery",
		},
		["4"] = {
			name = "monkey_king_wukongs_command",
		},
	},
	npc_dota_hero_mars = {
		["1"] = {
			name = "mars_spear",
		},
		["2"] = {
			name = "mars_gods_rebuke",
		},
		["3"] = {
			name = "mars_bulwark",
		},
		["4"] = {
			name = "mars_arena_of_blood",
		},
	},
	npc_dota_hero_marci = {
		["1"] = {
			name = "marci_grapple",
		},
		["2"] = {
			name = "marci_companion_run",
		},
		["3"] = {
			name = "marci_bodyguard",
		},
		["4"] = {
			name = "marci_unleash",
		},
	},
	npc_dota_hero_muerta = {
		["1"] = {
			name = "muerta_dead_shot",
		},
		["2"] = {
			name = "muerta_the_calling",
		},
		["3"] = {
			name = "muerta_gunslinger",
		},
		["4"] = {
			name = "muerta_pierce_the_veil",
		},
	},

	npc_dota_hero_nevermore = {
		["1"] = {
			name = "nevermore_shadowraze2",
		},
		["2"] = {
			name = "nevermore_frenzy",
		},
		["3"] = {
			name = "nevermore_dark_lord",
		},
		["4"] = {
			name = "nevermore_requiem",
		},
	},
	npc_dota_hero_necrolyte = {
		["1"] = {
			name = "necrolyte_death_pulse",
		},
		["2"] = {
			name = "necrolyte_ghost_shroud",
		},
		["3"] = {
			name = "necrolyte_heartstopper_aura",
		},
		["4"] = {
			name = "necrolyte_death_seeker",
			shard = true,
		},
		["5"] = {
			name = "necrolyte_reapers_scythe",
		},
	},
	npc_dota_hero_night_stalker = {
		["1"] = {
			name = "night_stalker_void",
		},
		["2"] = {
			name = "night_stalker_crippling_fear",
		},
		["3"] = {
			name = "night_stalker_hunter_in_the_night",
		},
		["4"] = {
			name = "night_stalker_darkness",
		},
	},
	npc_dota_hero_nyx_assassin = {
		["1"] = {
			name = "nyx_assassin_impale",
		},
		["2"] = {
			name = "nyx_assassin_jolt",
		},
		["3"] = {
			name = "nyx_assassin_spiked_carapace",
		},
		["4"] = {
			name = "nyx_assassin_burrow",
			sub = "nyx_assassin_unburrow",
		},
		["5"] = {
			name = "nyx_assassin_vendetta",
		},
	},
	npc_dota_hero_naga_siren = {
		["1"] = {
			name = "naga_siren_mirror_image",
		},
		["2"] = {
			name = "naga_siren_ensnare",
			sub = "naga_siren_reel_in",
		},
		["3"] = {
			name = "naga_siren_rip_tide",
		},
		["4"] = {
			name = "naga_siren_deluge",
		},
		["5"] = {
			name = "naga_siren_song_of_the_siren",
			sub = "naga_siren_song_of_the_siren_cancel",
		},
	},

	npc_dota_hero_omniknight = {
		["1"] = {
			name = "omniknight_purification",
		},
		["2"] = {
			name = "omniknight_martyr",
		},
		["3"] = {
			name = "omniknight_hammer_of_purity",
		},
		["4"] = {
			name = "omniknight_guardian_angel",
		},
	},
	npc_dota_hero_obsidian_destroyer = {
		["1"] = {
			name = "obsidian_destroyer_arcane_orb",
		},
		["2"] = {
			name = "obsidian_destroyer_astral_imprisonment",
		},
		["3"] = {
		--	name = "obsidian_destroyer_equilibrium",
			name = "obsidian_destroyer_equilibrium_lua",
		},
		["4"] = {
			name = "obsidian_destroyer_sanity_eclipse",
		},
	},
	npc_dota_hero_ogre_magi = {
		["1"] = {
			name = "ogre_magi_fireblast",
			sub = "ogre_magi_unrefined_fireblast",
		},
		["2"] = {
			name = "ogre_magi_ignite",
		},
		["3"] = {
			name = "ogre_magi_bloodlust",
		},
		["4"] = {
			name = "ogre_magi_smash",
			shard = true,
		},
	},
	npc_dota_hero_oracle = {
		["1"] = {
			name = "oracle_fortunes_end",
		},
		["2"] = {
			name = "oracle_fates_edict",
		},
		["3"] = {
			name = "oracle_purifying_flames",
		},
		["4"] = {
			name = "oracle_rain_of_destiny",
			shard = true,
		},
		["5"] = {
			name = "oracle_false_promise",
		},
	},

	npc_dota_hero_phantom_lancer = {
		["1"] = {
			name = "phantom_lancer_spirit_lance",
		},
		["2"] = {
			name = "phantom_lancer_doppelwalk",
		},
		["3"] = {
			name = "phantom_lancer_phantom_edge",
		},
		["4"] = {
			name = "phantom_lancer_juxtapose",
		},
	},
	npc_dota_hero_puck = {
		["1"] = {
			name = "puck_illusory_orb",
			sub = "puck_ethereal_jaunt",
		},
		["2"] = {
			name = "puck_waning_rift",
		},
		["3"] = {
			name = "puck_phase_shift",
		},
		["4"] = {
			name = "puck_dream_coil",
		},
	},
	npc_dota_hero_pudge = {
		["1"] = {
			name = "pudge_meat_hook",
		},
		["2"] = {
			name = "pudge_rot",
		},
		["3"] = {
			name = "pudge_flesh_heap",
		},
		["4"] = {
			name = "pudge_dismember",
		},
	},
	npc_dota_hero_phantom_assassin = {
		["1"] = {
			name = "phantom_assassin_stifling_dagger",
		},
		["2"] = {
			name = "phantom_assassin_phantom_strike",
		},
		["3"] = {
			name = "phantom_assassin_blur",
		},
		["4"] = {
			name = "phantom_assassin_fan_of_knives",
			shard = true,
		},
		["5"] = {
			name = "phantom_assassin_coup_de_grace",
		},
	},
	npc_dota_hero_pugna = {
		["1"] = {
			name = "pugna_nether_blast",
		},
		["2"] = {
			name = "pugna_decrepify",
		},
		["3"] = {
			name = "pugna_nether_ward",
		},
		["4"] = {
			name = "pugna_life_drain",
		},
	},
	npc_dota_hero_phoenix = {
		["1"] = {
			name = "phoenix_icarus_dive",
			sub = "phoenix_icarus_dive_stop",
		},
		["2"] = {
			name = "phoenix_fire_spirits",
			sub = "phoenix_launch_fire_spirit",
		},
		["3"] = {
			name = "phoenix_sun_ray",
			sub = "phoenix_sun_ray_toggle_move",
		},
		["4"] = {
			name = "phoenix_supernova",
		},
	},
	npc_dota_hero_pangolier = {
		["1"] = {
			name = "pangolier_swashbuckle",
		},
		["2"] = {
			name = "pangolier_shield_crash",
		},
		["3"] = {
			name = "pangolier_lucky_shot",
		},
		["4"] = {
			name = "pangolier_rollup",
			sub = "pangolier_rollup_stop",
			shard = true,
		},
		["5"] = {
			name = "pangolier_gyroshell",
			sub = "pangolier_gyroshell_stop",
		},
	},
	npc_dota_hero_primal_beast = {
		["1"] = {
			name = "primal_beast_onslaught",
			sub = "primal_beast_onslaught_release",
		},
		["2"] = {
			name = "primal_beast_trample",
		},
		["3"] = {
			name = "primal_beast_uproar",
		},
		["4"] = {
			name = "primal_beast_rock_throw",
			shard = true,
		},
		["5"] = {
			name = "primal_beast_pulverize",
		},
	},

	npc_dota_hero_queenofpain = {
		["1"] = {
			name = "queenofpain_shadow_strike",
		},
		["2"] = {
			name = "queenofpain_blink",
		},
		["3"] = {
			name = "queenofpain_scream_of_pain",
		},
		["4"] = {
			name = "queenofpain_sonic_wave",
		},
	},

	npc_dota_hero_razor = {
		["1"] = {
			name = "razor_plasma_field",
		},
		["2"] = {
			name = "razor_static_link",
		},
		["3"] = {
			name = "razor_storm_surge",
		},
		["4"] = {
			name = "razor_eye_of_the_storm",
		},
	},
	npc_dota_hero_riki = {
		["1"] = {
			name = "riki_smoke_screen",
		},
		["2"] = {
			name = "riki_blink_strike",
		},
		["3"] = {
			name = "riki_tricks_of_the_trade",
		},
		["4"] = {
			name = "riki_backstab",
		},
	},
	npc_dota_hero_rattletrap = {
		["1"] = {
			name = "rattletrap_battery_assault",
		},
		["2"] = {
			name = "rattletrap_power_cogs",
		},
		["3"] = {
			name = "rattletrap_rocket_flare",
		},
		["4"] = {
			name = "rattletrap_overclocking",
			scepter = true,
		},
		["5"] = {
			name = "rattletrap_jetpack",
			shard = true,
		},
		["6"] = {
			name = "rattletrap_hookshot",
		},
	},
	npc_dota_hero_rubick = {
		["1"] = {
			name = "rubick_telekinesis",
			sub = "rubick_telekinesis_land",
		},
		["2"] = {
			name = "rubick_fade_bolt",
		},
		["3"] = {
			name = "rubick_arcane_supremacy",
		},
	},
	npc_dota_hero_ringmaster = {
		["1"] = {
			name = "ringmaster_tame_the_beasts",
		},
		["2"] = {
			name = "ringmaster_the_box",
		},
		["3"] = {
			name = "ringmaster_impalement",
		},
		["4"] = {
			name = "ringmaster_wheel",
		},
	},

	npc_dota_hero_sand_king = {
		["1"] = {
			name = "sandking_burrowstrike",
		},
		["2"] = {
			name = "sandking_sand_storm",
		},
		["3"] = {
			name = "sandking_scorpion_strike",
		},
		["4"] = {
			name = "sandking_epicenter",
		},
	},
	npc_dota_hero_storm_spirit = {
		["1"] = {
			name = "storm_spirit_static_remnant",
		},
		["2"] = {
			name = "storm_spirit_electric_vortex",
		},
		["3"] = {
			name = "storm_spirit_overload",
		},
		["4"] = {
			name = "storm_spirit_ball_lightning",
		},
	},
	npc_dota_hero_sven = {
		["1"] = {
			name = "sven_storm_bolt",
		},
		["2"] = {
			name = "sven_great_cleave",
		},
		["3"] = {
			name = "sven_warcry",
		},
		["4"] = {
			name = "sven_gods_strength",
		},
	},
	npc_dota_hero_shadow_shaman = {
		["1"] = {
			name = "shadow_shaman_ether_shock",
		},
		["2"] = {
			name = "shadow_shaman_voodoo",
		},
		["3"] = {
			name = "shadow_shaman_shackles",
		},
		["4"] = {
			name = "shadow_shaman_mass_serpent_ward",
		},
	},
	npc_dota_hero_slardar = {
		["1"] = {
			name = "slardar_sprint",
		},
		["2"] = {
			name = "slardar_slithereen_crush",
		},
		["3"] = {
			name = "slardar_bash",
		},
		["4"] = {
			name = "slardar_amplify_damage",
		},
	},
	npc_dota_hero_sniper = {
		["1"] = {
			name = "sniper_shrapnel",
		},
		["2"] = {
			name = "sniper_headshot",
		},
		["3"] = {
			name = "sniper_take_aim",
		},
		["4"] = {
			name = "sniper_concussive_grenade",
			shard = true,
		},
		["5"] = {
			name = "sniper_assassinate",
		},
	},
	npc_dota_hero_skeleton_king = {
		["1"] = {
			name = "skeleton_king_hellfire_blast",
		},
		["2"] = {
			name = "skeleton_king_bone_guard",
		},
		["3"] = {
			name = "skeleton_king_spectral_blade",
		},
		["4"] = {
			name = "skeleton_king_mortal_strike",
		},
		["5"] = {
			name = "skeleton_king_reincarnation",
		},
	},
	npc_dota_hero_spectre = {
		["1"] = {
			name = "spectre_spectral_dagger",
		},
		["2"] = {
			name = "spectre_desolate",
		},
		["3"] = {
			name = "spectre_dispersion",
		},
		["4"] = {
			name = "spectre_haunt_single",
			sub = "spectre_reality",
		},
	},
	npc_dota_hero_spirit_breaker = {
		["1"] = {
			name = "spirit_breaker_charge_of_darkness",
		},
		["2"] = {
			name = "spirit_breaker_bulldoze",
		},
		["3"] = {
			name = "spirit_breaker_greater_bash",
		},
		["4"] = {
			name = "spirit_breaker_planar_pocket",
			scepter = true,
		},
		["5"] = {
			name = "spirit_breaker_nether_strike",
		},
	},
	npc_dota_hero_silencer = {
		["1"] = {
			name = "silencer_curse_of_the_silent",
		},
		["2"] = {
			name = "silencer_glaives_of_wisdom",
		},
		["3"] = {
			name = "silencer_last_word",
		},
		["4"] = {
			name = "silencer_global_silence",
		},
	},
	npc_dota_hero_shadow_demon = {
		["1"] = {
			name = "shadow_demon_disruption",
		},
		["2"] = {
			name = "shadow_demon_disseminate",
		},
		["3"] = {
			name = "shadow_demon_shadow_poison",
			sub = "shadow_demon_shadow_poison_release",
		},
		["4"] = {
			name = "shadow_demon_demonic_cleanse",
			shard = true,
		},
		["5"] = {
			name = "shadow_demon_demonic_purge",
		},
	},
	npc_dota_hero_slark = {
		["1"] = {
			name = "slark_dark_pact",
		},
		["2"] = {
			name = "slark_pounce",
		},
		["3"] = {
			name = "slark_essence_shift",
		},
		["4"] = {
			name = "slark_depth_shroud",
			shard = true,
		},
		["5"] = {
			name = "slark_shadow_dance",
		},
	},
	npc_dota_hero_shredder = {
		["1"] = {
			name = "shredder_whirling_death",
		},
		["2"] = {
			name = "shredder_timber_chain",
		},
		["3"] = {
			name = "shredder_reactive_armor",
		},
		["4"] = {
			name = "shredder_flamethrower",
			shard = true,
		},
		["5"] = {
			name = "shredder_chakram",
			sub = "shredder_return_chakram",
		},
		["6"] = {
			name = "shredder_return_chakram_2",
		},
	},
	npc_dota_hero_skywrath_mage = {
		["1"] = {
			name = "skywrath_mage_arcane_bolt",
		},
		["2"] = {
			name = "skywrath_mage_concussive_shot",
		},
		["3"] = {
			name = "skywrath_mage_ancient_seal",
		},
		["4"] = {
			name = "skywrath_mage_mystic_flare",
		},
	},
	npc_dota_hero_snapfire = {
		["1"] = {
			name = "snapfire_scatterblast",
		},
		["2"] = {
			name = "snapfire_firesnap_cookie",
		},
		["3"] = {
			name = "snapfire_lil_shredder",
		},
		["4"] = {
			name = "snapfire_gobble_up",
			sub = "snapfire_spit_creep",
			scepter = true,
		},
		["5"] = {
			name = "snapfire_mortimer_kisses",
		},
	},

	npc_dota_hero_tiny = {
		["1"] = {
			name = "tiny_avalanche",
		},
		["2"] = {
			name = "tiny_toss",
		},
		["3"] = {
			name = "tiny_tree_grab",
			sub = "tiny_toss_tree",
		},
		["4"] = {
			name = "tiny_tree_channel",
			scepter = true,
		},
		["5"] = {
			name = "tiny_grow",
		},
	},
	npc_dota_hero_tidehunter = {
		["1"] = {
			name = "tidehunter_gush",
		},
		["2"] = {
			name = "tidehunter_kraken_shell",
		},
		["3"] = {
			name = "tidehunter_anchor_smash",
		},
		["4"] = {
			name = "tidehunter_dead_in_the_water",
			shard = true,
		},
		["5"] = {
			name = "tidehunter_ravage",
		},
	},
	npc_dota_hero_tinker = {
		["1"] = {
			name = "tinker_laser",
		},
		["2"] = {
			name = "tinker_march_of_the_machines",
		},
		["3"] = {
			name = "tinker_defense_matrix",
		},
		["4"] = {
			name = "tinker_warp_grenade",
			shard = true,
		},
		["5"] = {
			name = "tinker_rearm",
			sub = "tinker_keen_teleport",
		},
	},
	npc_dota_hero_templar_assassin = {
		["1"] = {
			name = "templar_assassin_refraction",
		},
		["2"] = {
			name = "templar_assassin_meld",
		},
		["3"] = {
			name = "templar_assassin_psi_blades",
		},
		["4"] = {
			name = "templar_assassin_psionic_trap",
			sub = "templar_assassin_trap",
		},
		["5"] = {
			name = "templar_assassin_trap_teleport",
			scepter = true,
		},
	},
	npc_dota_hero_treant = {
		["1"] = {
			name = "treant_natures_grasp",
		},
		["2"] = {
			name = "treant_leech_seed",
		},
		["3"] = {
			name = "treant_living_armor",
		},
		["4"] = {
			name = "treant_eyes_in_the_forest",
			scepter = true,
		},
		["5"] = {
			name = "treant_natures_guise",
			shard = true,
		},
		["6"] = {
			name = "treant_overgrowth",
		},
	},
	npc_dota_hero_troll_warlord = {
		["1"] = {
			name = "troll_warlord_whirling_axes_ranged",
		},
		["2"] = {
			name = "troll_warlord_whirling_axes_melee",
		},
		["3"] = {
			name = "troll_warlord_fervor",
		},
		["4"] = {
			name = "troll_warlord_berserkers_rage",
		},
		["5"] = {
			name = "troll_warlord_battle_trance",
		},
	},
	npc_dota_hero_tusk = {
		["1"] = {
			name = "tusk_ice_shards",
		},
		["2"] = {
			name = "tusk_snowball",
			sub = "tusk_launch_snowball",
		},
		["3"] = {
			name = "tusk_tag_team",
		},
		["4"] = {
			name = "tusk_drinking_buddies",
		},
		["5"] = {
			name = "tusk_walrus_punch",
		},
	},
	npc_dota_hero_terrorblade = {
		["1"] = {
			name = "terrorblade_conjure_image",
		},
		["2"] = {
			name = "terrorblade_metamorphosis",
		},
		["3"] = {
			name = "terrorblade_demon_zeal",
			shard = true,
		},
		["4"] = {
			name = "terrorblade_terror_wave",
			scepter = true,
		},
		["5"] = {
			name = "terrorblade_sunder",
		},
	},
	npc_dota_hero_techies = {
		["1"] = {
			name = "techies_sticky_bomb",
		},
		["2"] = {
			name = "techies_reactive_tazer",
		},
		["3"] = {
			name = "techies_suicide",
		},
		["4"] = {
			name = "techies_minefield_sign",
		},
		["5"] = {
			name = "techies_land_mines",
		},
	},

	npc_dota_hero_ursa = {
		["1"] = {
			name = "ursa_earthshock",
		},
		["2"] = {
			name = "ursa_overpower",
		},
		["3"] = {
			name = "ursa_fury_swipes",
		},
		["4"] = {
			name = "ursa_enrage",
		},
	},
	npc_dota_hero_undying = {
		["1"] = {
			name = "undying_decay",
		},
		["2"] = {
			name = "undying_soul_rip",
		},
		["3"] = {
			name = "undying_tombstone",
		},
		["4"] = {
			name = "undying_flesh_golem",
		},
	},

	npc_dota_hero_vengefulspirit = {
		["1"] = {
			name = "vengefulspirit_magic_missile",
		},
		["2"] = {
			name = "vengefulspirit_wave_of_terror",
		},
		["3"] = {
			name = "vengefulspirit_command_aura",
		},
		["4"] = {
			name = "vengefulspirit_nether_swap",
		},
	},
	npc_dota_hero_venomancer = {
		["1"] = {
			name = "venomancer_venomous_gale",
		},
		["2"] = {
			name = "venomancer_poison_sting",
		},
		["3"] = {
			name = "venomancer_plague_ward",
		},
		["4"] = {
			name = "venomancer_noxious_plague",
		},
	},
	npc_dota_hero_viper = {
		["1"] = {
			name = "viper_poison_attack",
		},
		["2"] = {
			name = "viper_nethertoxin",
		},
		["3"] = {
			name = "viper_corrosive_skin",
		},
		["4"] = {
			name = "viper_nose_dive",
			scepter = true,
		},
		["5"] = {
			name = "viper_viper_strike",
		},
	},
	npc_dota_hero_visage = {
		["1"] = {
			name = "visage_grave_chill",
		},
		["2"] = {
			name = "visage_soul_assumption",
		},
		["3"] = {
			name = "visage_gravekeepers_cloak",
		},
		["4"] = {
			name = "visage_silent_as_the_grave",
			scepter = true,
		},
		["5"] = {
			name = "visage_summon_familiars",
		},
	},
	npc_dota_hero_void_spirit = {
		["1"] = {
			name = "void_spirit_aether_remnant",
		},
		["2"] = {
			name = "void_spirit_dissimilate",
		},
		["3"] = {
			name = "void_spirit_resonant_pulse",
		},
		["4"] = {
			name = "void_spirit_astral_step",
		},
	},

	npc_dota_hero_windrunner = {
		["1"] = {
			name = "windrunner_shackleshot",
		},
		["2"] = {
			name = "windrunner_powershot",
		},
		["3"] = {
			name = "windrunner_windrun",
		},
		["4"] = {
			name = "windrunner_gale_force",
			shard = true,
		},
		["5"] = {
			name = "windrunner_focusfire",
			sub = "windrunner_focusfire_cancel",
		},
	},
	npc_dota_hero_witch_doctor = {
		["1"] = {
			name = "witch_doctor_paralyzing_cask",
		},
		["2"] = {
			name = "witch_doctor_voodoo_restoration",
		},
		["3"] = {
			name = "witch_doctor_maledict",
		},
		["4"] = {
			name = "witch_doctor_death_ward",
			sub = "witch_doctor_voodoo_switcheroo",
		},
	},
	npc_dota_hero_warlock = {
		["1"] = {
			name = "warlock_fatal_bonds",
		},
		["2"] = {
			name = "warlock_shadow_word",
		},
		["3"] = {
			name = "warlock_upheaval",
		},
		["4"] = {
			name = "warlock_rain_of_chaos",
		},
	},
	npc_dota_hero_weaver = {
		["1"] = {
			name = "weaver_the_swarm",
		},
		["2"] = {
			name = "weaver_shukuchi",
		},
		["3"] = {
			name = "weaver_geminate_attack",
		},
		["4"] = {
			name = "weaver_time_lapse",
		},
	},
	npc_dota_hero_wisp = {
		["1"] = {
			name = "wisp_tether",
			sub = "wisp_tether_break",
		},
		["2"] = {
			name = "wisp_spirits",
			sub = "wisp_spirits_in",
			sub2 = "wisp_spirits_out",
		},
		["3"] = {
			name = "wisp_overcharge",
		},
		["4"] = {
			name = "wisp_relocate",
		},
	},
	npc_dota_hero_winter_wyvern = {
		["1"] = {
			name = "winter_wyvern_arctic_burn",
		},
		["2"] = {
			name = "winter_wyvern_splinter_blast",
		},
		["3"] = {
			name = "winter_wyvern_cold_embrace",
		},
		["4"] = {
			name = "winter_wyvern_winters_curse",
		},
	},

	npc_dota_hero_zuus = {
		["1"] = {
			name = "zuus_arc_lightning",
		},
		["2"] = {
			name = "zuus_lightning_bolt",
		},
		["3"] = {
			name = "zuus_heavenly_jump",
		},
		["4"] = {
			name = "zuus_cloud",
			scepter = true,
		},
		["5"] = {
			name = "zuus_lightning_hands",
			shard = true,
		},
		["6"] = {
			name = "zuus_thundergods_wrath",
		},
	},
}
