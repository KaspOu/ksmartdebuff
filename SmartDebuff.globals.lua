-------------------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------------------

SMARTDEBUFF_VERSION       = "v"..GetAddOnMetadata("SmartDebuff", "Version"); -- "v10.0.202"
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

-- Support spell IDs
SMARTDEBUFF_REJUVENATION_ID       = 774;
SMARTDEBUFF_RENEW_ID              = 139;
SMARTDEBUFF_FLASHHEAL_ID          = 2061;
SMARTDEBUFF_FLASHOFLIGHT_ID       = 19750;
SMARTDEBUFF_HEALINGSURGE_ID       = 8004;
SMARTDEBUFF_MISDIRECTION_ID       = 34477;
SMARTDEBUFF_POLYMORPH_ID          = 118;
SMARTDEBUFF_HEX_ID                = 51514;
SMARTDEBUFF_INTERVENE_ID          = 3411;
SMARTDEBUFF_DEATHCOIL_ID          = 52375;
SMARTDEBUFF_TRICKS_ID             = 57934;
SMARTDEBUFF_RENEWINGMIST_ID       = 119611;
SMARTDEBUFF_LEAPOFFAITH_ID        = 73325;
SMARTDEBUFF_REVERSION_ID          = 367364;
SMARTDEBUFF_VERDANTEMBRACE_ID     = 360995;
SMARTDEBUFF_EMERALDBLOSSOM_ID     = 355913;

-- Debuff spell IDs
SMARTDEBUFF_NATURESCURE_ID        = 88423; -- Druid
SMARTDEBUFF_REMOVECORRUPTION_ID   = 2782;  -- Druid
SMARTDEBUFF_PURIFY_ID             = 527;   -- Priest
SMARTDEBUFF_REMOVELESSERCURSE_ID  = 475;   -- Mage
SMARTDEBUFF_CLEANSE_ID            = 4987;  -- Paladin
SMARTDEBUFF_CLEANSESPIRIT_ID      = 51886; -- Shaman
SMARTDEBUFF_PURIFYSPIRIT_ID       = 77130; -- Shaman
SMARTDEBUFF_PURGE_ID              = 370;   -- Shaman
SMARTDEBUFF_DETOX_ID              = 115450;-- Monk
SMARTDEBUFF_EXPUNGE_ID            = 365585;-- Evoker
SMARTDEBUFF_NATURALIZE_ID         = 360823;-- Evoker
SMARTDEBUFF_CAUTERIZINGFLAME_ID   = 374251;-- Evoker

-- Misc spell IDs
SMARTDEBUFF_UNENDINGBREATH_ID     = 5697;
SMARTDEBUFF_PET_IMP_ID            = 89808; -- "Singe Magic"


-- Effects ignore list
SMARTDEBUFF_DEBUFFSKIP_NAME = { };
SMARTDEBUFF_DEBUFFSKIP_ID = {
   [1] = 15822, --Dreamless Sleep
	 [2] = 24360, --Greater Dreamless Sleep
	 [3] = 28504, --Major Dreamless Sleep
	 [4] = 2096,  --Mind Vision
	 [5] = 28169, --Mutating Injection
   [6] = 710,   --Banish
   [7] = 4511,  --Phase Shift
   [8] = 30451, --Arcane Blast
   [9] = 30108, --Unstable Affliction
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
