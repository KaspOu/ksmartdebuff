-------------------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------------------

SMARTDEBUFF_VERSION       = "v"..C_AddOns.GetAddOnMetadata("SmartDebuff", "Version"); -- "v10.0.202"
SMARTDEBUFF_VERSIONNR     = tonumber(gsub(SMARTDEBUFF_VERSION, "%D", ""), 10); -- "100202"
SMARTDEBUFF_TITLE         = "SmartDebuff";
SMARTDEBUFF_SUBTITLE      = "Debuff support";
SMARTDEBUFF_DESC          = "Supports you to cast debuff spells on friendly units";
SMARTDEBUFF_VERS_TITLE    = SMARTDEBUFF_TITLE .. " " .. SMARTDEBUFF_VERSION;
SMARTDEBUFF_OPTIONS_TITLE = SMARTDEBUFF_VERS_TITLE .. " Options";

BINDING_HEADER_SMARTDEBUFF = "SmartDebuff";
SMARTDEBUFF_BOOK_TYPE_SPELL = "spell";


wowversion, wowbuild, wowdate, wowtocversion = GetBuildInfo()
SMARTDEBUFF_BACKDROP_OPTIONS = {
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true,
  tileSize = 8,
  edge = true,
  edgeSize = 8,
  insets = {left = 2, right = 2, top = 2, bottom = 2},
};
SMARTDEBUFF_BACKDROP_TOOLTIP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true,
  tileSize = 4,
  edge = true,
  edgeSize = 4,
  insets = {left = 1, right = 1, top = 1, bottom = 1},
};

SMARTDEBUFF_TTC_R = 1.0;
SMARTDEBUFF_TTC_G = 0.82;
SMARTDEBUFF_TTC_B = 0.0;
SMARTDEBUFF_TTC_A = 1.0;

SMARTDEBUFF_OF_HEIGHT = 500;
SMARTDEBUFF_OF_WIDTH = 500;

-- Debuff types
SMARTDEBUFF_DISEASE = "Disease";
SMARTDEBUFF_MAGIC   = "Magic";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Curse";
SMARTDEBUFF_CHARMED = "Mind Control";
SMARTDEBUFF_BLEEDING   = "Bleeding"; -- Not a really debuff type

SMARTDEBUFF_HEAL    = "Heal";
SMARTDEBUFF_UTIL    = "Utility";
SMARTDEBUFF_MISDIRECT = "Threat redirect";

SMARTDEBUFF_WARLOCK_CMD_DEMON = 119898;

--@do-not-package@
--[[
List dispels: https://warcraft.wiki.gg/wiki/Magic_(dispel_type)
ALL Dispels : https://www.wowhead.com/spells?filter=109;38;0
Class Dispels only: https://www.wowhead.com/spells/specialization?filter=109;38;0
Talents dispels: https://www.wowhead.com/spells/talents?filter=109;38;0
https://wago.tools/db2/SpellDispelType

Format: [ClassName] = { [1] = { Spell_ID, Spell_List, Spell_CheckIsUsable?, Improved_Talent?, Improved_Spell_List?, } }
]]--
--@end-do-not-package@


-- Debuff spell IDs (for L button)
SMARTDEBUFF_CLASS_DISPELS_LIST_ID = {
  ["DRUID"]  = {
    { -- Nature's Cure
      Spell_ID = 88423,
      Spell_List = {SMARTDEBUFF_MAGIC},
      Improved_Talent = 392378,
      Improved_Spell_List = {SMARTDEBUFF_MAGIC, SMARTDEBUFF_CURSE, SMARTDEBUFF_POISON},
    },
    { -- Remove Corruption
      Spell_ID = 2782,
      Spell_List = {SMARTDEBUFF_CURSE, SMARTDEBUFF_POISON},
    },
  },

  ["EVOKER"] = {
    { -- Naturalize
      Spell_ID = 360823,
      Spell_List = {SMARTDEBUFF_MAGIC, SMARTDEBUFF_POISON},
    },
    { -- Expunge
      Spell_ID = 365585,
      Spell_List = {SMARTDEBUFF_POISON},
    },
    -- Cauterizing Flame set on R
  },


  ["MONK"] = {
    { -- Detox
      Spell_ID = 115450,
      Spell_List = {SMARTDEBUFF_MAGIC},
      Improved_Talent = 388874,
      Improved_Spell_List = {SMARTDEBUFF_MAGIC, SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON},
    },
    { -- Detox (again)
      Spell_ID = 218164,
      Spell_List = {SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON},
    },
  },

  ["PALADIN"] = {
    { -- Cleanse
      Spell_ID = 4987, -- & 413393 ?
      Spell_List = {SMARTDEBUFF_MAGIC},
      Improved_Talent = 393024,
      Improved_Spell_List = {SMARTDEBUFF_MAGIC, SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON},
    },
    { -- Cleanse Toxins
      Spell_ID = 213644,
      Spell_List = {SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON},
    },
  },

  ["PRIEST"] = {
    { -- Purify
      Spell_ID = 527,
      Spell_List = {SMARTDEBUFF_MAGIC},
      Improved_Talent = 390632,
      Improved_Spell_List = {SMARTDEBUFF_MAGIC, SMARTDEBUFF_DISEASE},
    },
    { -- Purify Disease (!: GetSpellInfo Missdetected for Sacred)
      Spell_ID = 213634,
      Spell_List = {SMARTDEBUFF_DISEASE},
    },
    -- Dispel Magic only enemies
  },

  ["SHAMAN"] = {
    { -- Purify Spirit
      Spell_ID = 77130,
      Spell_List = {SMARTDEBUFF_MAGIC},
      Improved_Talent = 383016,
      Improved_Spell_List = {SMARTDEBUFF_MAGIC, SMARTDEBUFF_CURSE},
    },
    { -- Cleanse Spirit
      Spell_ID = 51886, -- & 234893 ?
      Spell_List = {SMARTDEBUFF_CURSE},
    },
  },

  ["MAGE"] = {
    { -- Remove Curse
      Spell_ID = 475,
      Spell_List = {SMARTDEBUFF_CURSE},
    },
  },

  ["WARLOCK"] = {
    { -- Singe Magic, pet (imp)
      Spell_ID = 89808,
      Spell_List = {SMARTDEBUFF_MAGIC},
      Spell_Type = "petaction",
    },
  },

  -- ["DEMONHUNTER"] = {
  --   -- Consume Magic only enemies
  -- },
}

SMARTDEBUFF_BTN_DEFAULT_SKILLID = {
  ["R"]   = 2,  -- 2, 8
  ["M"]   = 3,  -- 3, 9
  ["AL"]  = 7, -- 7, 2
}
-- Possible buttons : M,R,AL 
SMARTDEBUFF_CLASS_SKILLS_LIST_ID = {
  ["DRUID"]  = {
    { Spell_ID = 102401, Button = "R", Types = {SMARTDEBUFF_UTIL} }, -- Wild charge
    { Spell_ID = 102693, Button = "M", Types = {SMARTDEBUFF_HEAL} }, -- Grove Guardians
    { Spell_ID = 774,   Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Rejuvenation
  },
  ["EVOKER"]  = {
    { Spell_ID = 374251, Button = "R", Types = {SMARTDEBUFF_CURSE, SMARTDEBUFF_POISON, SMARTDEBUFF_DISEASE} }, -- Cauterizing flame
    { Spell_ID = 360995, Button = "M", Types = {SMARTDEBUFF_UTIL} }, -- Verdant embrace
    { Spell_ID = 367364, Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Reversion
  },
  ["MONK"]  = {
    { Spell_ID = 115078, Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Paralysis 
    { Spell_ID = 119611, Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Renewing Mist
  },
  ["PALADIN"]  = {
    { Spell_ID = 20066, Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Repentance
    { Spell_ID = 1022,  Button = "M", Types = {SMARTDEBUFF_UTIL} }, --  Blessing of protection
    { Spell_ID = 19750, Button = "AL", Types = {SMARTDEBUFF_HEAL} }, --  Flash light
  },
  ["PRIEST"]  = {
    { Spell_ID = 73325, Button = "R", Types = {SMARTDEBUFF_UTIL} }, -- Leap of Faith
    { Spell_ID = 2061,  Button = "M", Types = {SMARTDEBUFF_HEAL} }, -- Flash heal
    { Spell_ID = 139,   Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Renew
    -- 64044 -- Psychic horror?
  },
  ["SHAMAN"]  = {
    { Spell_ID = 51514, Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Hex
    { Spell_ID = 974,   Button = "M", Types = {SMARTDEBUFF_UTIL} }, -- Earth shield
    { Spell_ID = 8004,  Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Healing surge
  },
  
  ["DEATHKNIGHT"]  = {
    { Spell_ID = 52375, Button = "R", Types = {SMARTDEBUFF_HEAL} }, -- Death Coil
  },
  ["DEMONHUNTER"]  = {
    { Spell_ID = 217832, Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Imprison
  },
  ["HUNTER"]  = {
    { Spell_ID = 34477, Button = "M", Types = {SMARTDEBUFF_MISDIRECT} }, -- Misdirection
  }, 
  ["MAGE"]  = {
    { Spell_ID = 118,   Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Polymorph
  }, 
  ["ROGUE"]  = {
    { Spell_ID = 2094,  Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Blind
    { Spell_ID = 57934, Button = "M", Types = {SMARTDEBUFF_MISDIRECT} }, -- Tricks of the Trade
  },  
  ["WARRIOR"]  = {
    { Spell_ID = 3411,  Button = "R", Types = {SMARTDEBUFF_UTIL} }, -- Intervene
  },
}


-- Effects ignore list
SMARTDEBUFF_DEBUFFSKIP_NAME = { };
SMARTDEBUFF_DEBUFFSKIP_ID = {
  [ 1] = 15822, --Dreamless Sleep
	[ 2] = 24360, --Greater Dreamless Sleep
	[ 3] = 28504, --Major Dreamless Sleep
	[ 4] = 2096,  --Mind Vision
	[ 5] = 28169, --Mutating Injection
  [ 6] = 710,   --Banish
  [ 7] = 4511,  --Phase Shift
  [ 8] = 30451, --Arcane Blast
  [ 9] = 30108, --Unstable Affliction
  [10] = 13810, --Frost Trap Aura
  [11] = 30108, --Unstable Affliction
  [12] = 19372, --Ancient Hysteria
  [13] = 19659, --Ignite Mana
  [14] = 16567, --Tainted Mind
  [15] = 28732, --Widow's Embrace
  [16] = 24306, --Delusions of Jin'do
  [17] = 15487, --Silence
  [18] = 1714,  --Curse of Tongues
  [19] = 29904, --Sonic Burst
  [20] = 19496, --Magma Shackles
  [21] = 33787, --Cripple
  [22] = 26072, --Dust Cloud
  [23] = 30633, --Thunderclap
};

-- Global ignore list
SMARTDEBUFF_DEBUFFSKIPLIST = { };
SMARTDEBUFF_DEBUFFSKIPLIST_ID = {1,2,3,4,5,6,7,8,9,10};

-- Class ignore list
SMARTDEBUFF_DEBUFFCLASSSKIPLIST = { };
SMARTDEBUFF_DEBUFFCLASSSKIPLIST_ID = {
	["WARRIOR"] = {12,13,14,15,16};
	["ROGUE"]   = {12,13,14,15,16,17,18,19};
	["HUNTER"]  = {16,20};
	["MAGE"]    = {16,20,21,22,23};
	["WARLOCK"] = {16,21,22,23};
	["DRUID"]   = {16,22,23};
	["PRIEST"]  = {16,21,22,23};
	["PALADIN"] = {16,22};
	["SHAMAN"]  = {16,22};
	["DEATHKNIGHT"] = {16,22};
	["MONK"] = {16,22};
	["DEMONHUNTER"] = {16,22};
	["EVOKER"] = {16,22};
};

--[[
Prowl 5215
Stealth 1784
Shadowmeld 20580
Invisibility 66
Lesser Invisibility 7870
]]--


SMARTDEBUFF_NOTREMOVABLE_ID = {
  39837, --Impaling Spine (Naj'entus)
  40239, --Incinerate (Teron)
  --40243, --Crushing Shadows (Teron)
  42005, --Bloodboil (Gurtogg)
  40604, --Fel Rage (Gurtogg)
  41001, --Fatal Attraction (Mother Shahraz)
  40860, --Vile Beam (Mother Shahraz)
  41485, --Deadly Poison (Veras Darkshadow, Illidari Council)
  40932, --Agonizing Flames (Illidan)
  41917, --Parasitic Shadowfiend (Illidan)
  40585, --Dark Barrage (Illidan)
  31249, --Icebolt (Winterchill)
  31340, --Rain of Fire (Azgalor)
  31944, --Doomfire (Archimonde)
  45141, --Burn (Brutallus)
  46008, --Negative Energy (Muru)
  38235, --Water Tomb (Hydross)
  38049, --Watery Grave (Morogrim)
};

-- https://wowpedia.fandom.com/wiki/API_PlaySoundFile
SMARTDEBUFF_SOUNDS = {
  {"Alarm Clock 1", 567436, "AlarmClockWarning1.ogg"},
  {"Alarm Clock 2", 567399, "AlarmClockWarning2.ogg"},
  {"Alarm Clock 3", 567458, "AlarmClockWarning3.ogg"},
  {"Anti Holy", 568986, "AntiHoly.ogg"},
  {"Auction House", 567482, "AuctionWindowOpen.ogg"},
  {"Bell Alliance", 566564, "BellTollAlliance.ogg"},
  {"Bell Horde", 565853, "BellTollHorde.ogg"},
  {"Bell Karazhan", 566254, "KharazahnBellToll.ogg"},
  {"Bell Night Elf", 566558, "BellTollNightElf.ogg"},
  {"Bell Tribal", 566027, "BellTollTribal.ogg"},
  {"Cartoon FX", 566543, "Goblin_Lottery_Open03.ogg"},
  {"Cheer", 567283, "OgreEventCheerUnique.ogg"},
  {"Diiing", 554922, "vo_zg2_mandokir_levelup_event_01.ogg"},
  {"Explosion", 566982, "Hellfire_Raid_FX_Explosion05.ogg"},
  {"Fel Nova", 568582, "SeepingGaseous_Fel_Nova.ogg"},
  {"Fel Portal", 569215, "Sunwell_Fel_PortalStand.ogg"},
  {"Follower Level Up", 1068310, "ui_garrison_commandtable_follower_levelup1.ogg"},
  {"Friend Join", 567518, "FriendJoin.ogg"},
  {"Gong Troll", 565564, "G_GongTroll01.ogg"},
  {"Humm", 569518, "SimonGame_Visual_GameStart.ogg"},
  {"Level Up", 567431, "levelup.ogg"},
  {"Lightning", 2182425, "fx_weather_80_lightningstorm_periodic_01.ogg"},
  {"Lightning 2", 2182424, "fx_weather_80_lightningstorm_periodic_02.ogg"},
  {"Lightning 3", 2182423, "fx_weather_80_lightningstorm_periodic_03.ogg"},
  {"Loot Chime", 567435, "igLootCreature.ogg"},
  {"Magic Click", 567455, "MagicClick.ogg"},
  {"Mellow Bells", 568154, "ShaysBell.ogg"},
  {"Murloc", 556000, "mMurlocAggroOld.ogg"},
  {"Pet Level Up", 642841, "ui_pet_levelup_01.ogg"},
  {"Ready Check", 567478, "levelup2.ogg"},
  {"Reputation Level Up", 568016, "reputationlevelup.ogg"},
  {"Rubber Ducky", 566121, "Goblin_Lottery_Open01.ogg"},
  {"Shing", 566240, "PortcullisActive_Closed.ogg"},
  {"Short Circuit", 568975, "SimonGame_Visual_BadPress.ogg"},
  {"Simon Chime", 566076, "SimonGame_LargeBlueTree.ogg"},
  {"Simon Tick", 568232, "simongame_visual_gametick.ogg"},
  {"War Drums", 567275, "Event_wardrum_ogre.ogg"},
  {"Wham", 566946, "PVP_Lordaeron_Door_Open.ogg"},
  {"Whisper Ping", 567421, "iTellMessage.ogg"}
};
