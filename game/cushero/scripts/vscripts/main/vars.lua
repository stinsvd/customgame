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
_G.MAX_ABILITY_COUNT = 8

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