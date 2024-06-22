--@do-not-package@
--[[
List dispels: https://warcraft.wiki.gg/wiki/Magic_(dispel_type)
Class Dispels : https://www.wowhead.com/classic/spells/abilities/druid?filter=109;38;0
Talents dispels: https://www.wowhead.com/classic/spells/talents?filter=109;38;0
https://wago.tools/db2/SpellDispelType

Tests your spells:
https://www.wowhead.com/spell=526
https://www.wowhead.com/classic/spell=51886

SMARTDEBUFF_CLASS_DISPELS_LIST_ID
  Format: [ClassName] = { { Spell_ID, Spell_List, OnlyIfUsable?, Improved_Talent?, Improved_Spell_List?, } }
  Priority: first active spell > first inactive talent > first item

SMARTDEBUFF_CLASS_SKILLS_LIST_ID
  Format: [ClassName] = { Spell_ID, Button, Types }
  You can declare multiple lines with the same Button,
  first spell will only be overloaded if the following spell is active
  Priority: last active > first item

SMARTDEBUFF_OVERRIDE_PICKUP_LIST_ID
Format: [pickupType] = { [pickupID] = {overridenPickupType, overridenPickupID }, }
]]--
--@end-do-not-package@

SMARTDEBUFF_SPELLS_VERSION = "Vanilla";
SMARTDEBUFF_MACROTEXT = true;

-- Debuff spell IDs (for L button)
SMARTDEBUFF_CLASS_DISPELS_LIST_ID = {
  ["DRUID"]  = {
    { -- Remove Corruption (1+)
      Spell_ID = 2782,
      Spell_List = {SMARTDEBUFF_CURSE},
    },
  },

  ["PALADIN"] = {
    { -- Cleanse (1+)
      Spell_ID = 4987,
      Spell_List = {SMARTDEBUFF_MAGIC, SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON},
    },
    { -- Purify (1-3)
      Spell_ID = 1152,
      Spell_List = {SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON},
    },
  },

  ["PRIEST"] = {
    { -- Dispel Magic, will be named Purify (1-4)
      Spell_ID = 527,
      Spell_List = {SMARTDEBUFF_MAGIC},
    },
    -- { -- Cure Disease, will be changed to Dispel Magic (1-4)
    --   Spell_ID = 528,
    --   Spell_List = {SMARTDEBUFF_DISEASE},
    -- },
  },

  ["SHAMAN"] = {
    { -- Cure Poison, will be changed to Cure Toxins wotk (1-2)
      Spell_ID = 526,
      Spell_List = {SMARTDEBUFF_POISON},
    },
    -- { -- Cure Disease (1-2)
    --   Spell_ID = 2870,
    --   Spell_List = {SMARTDEBUFF_DISEASE},
    -- },
  },

  ["MAGE"] = {
    { -- Remove Greater Curse (SoD)
      Spell_ID = 412113,
      Spell_List = {SMARTDEBUFF_CURSE, SMARTDEBUFF_MAGIC},
      OnlyIfUsable = true,
    },
    { -- Remove Curse
      Spell_ID = 475,
      Spell_List = {SMARTDEBUFF_CURSE},
    },
  },
}
-- Possible buttons : R, M, AL
SMARTDEBUFF_CLASS_SKILLS_LIST_ID = {
  ["DRUID"]  = {
    { Spell_ID = 8946,   Button = "R", Types = {SMARTDEBUFF_POISON} }, -- Cure Poison (1-3)
    { Spell_ID = 2893,   Button = "R", Types = {SMARTDEBUFF_POISON} }, -- Abolish Poison (1-3)
    { Spell_ID = 774,   Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Rejuvenation (1+)
  },
  ["PALADIN"]  = {
    { Spell_ID = 20066, Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Repentance (1+)
    { Spell_ID = 1022,  Button = "M", Types = {SMARTDEBUFF_UTIL} }, --  Blessing of protection (1+)
    { Spell_ID = 19750, Button = "AL", Types = {SMARTDEBUFF_HEAL} }, --  Flash of light (1+)
  },
  ["PRIEST"]  = {
    { Spell_ID = 528,   Button = "R", Types = {SMARTDEBUFF_DISEASE} }, -- Cure Disease, will be changed to Dispel Magic (1-4)
    { Spell_ID = 552,   Button = "R", Types = {SMARTDEBUFF_DISEASE} }, -- Abolish Disease (1-3)
    { Spell_ID = 17,    Button = "M", Types = {SMARTDEBUFF_UTIL} }, -- Power word shield (1+)
    { Spell_ID = 2061,   Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Flash heal (1+)
    { Spell_ID = 139,   Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Renew (1+)
    -- 23859 - NPC Dispel Magic
    -- 28133 - NPC Cure Disease
  },
  ["SHAMAN"]  = {
    { Spell_ID = 2870,   Button = "R", Types = {SMARTDEBUFF_DISEASE} }, -- Cure Disease (1-2)
    { Spell_ID = 974,   Button = "M", Types = {SMARTDEBUFF_UTIL} }, -- Earth shield (1+)
    { Spell_ID = 331,  Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Healing wave (1-4)
    { Spell_ID = 8004,  Button = "AL", Types = {SMARTDEBUFF_HEAL} }, -- Healing surge (1+)
  },
  
  ["MAGE"]  = {
    { Spell_ID = 118,   Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Polymorph (1+)
  }, 
  ["ROGUE"]  = {
    { Spell_ID = 2094,  Button = "R", Types = {SMARTDEBUFF_CHARMED} }, -- Blind (1+)
  },
  ["WARLOCK"]  = {
    { Spell_ID = 20707,  Button = "R", Types = {SMARTDEBUFF_UTIL} }, -- Soulstone (1+)
    -- 19476 - NPC Dispel Magic
  },
  ["WARRIOR"]  = {
    { Spell_ID = 3411,  Button = "R", Types = {SMARTDEBUFF_UTIL} }, -- Intervene (1+)
  },
}

SMARTDEBUFF_OVERRIDE_PICKUP_LIST_ID = {}

SMARTDEBUFF_DISABLED_SOUNDS = "\
Bell Karazhan\
Cartoon FX\
Cheer\
Diiing\
Explosion\
Fel Nova\
Fel Portal\
Follower Level Up\
Humm\
Lightning\
Lightning 2\
Lightning 3\
Pet Level Up\
Rubber Ducky\
Shing\
Short Circuit\
Simon Chime\
Simon Tick\
War Drums\
Wham\
";

SMARTDEBUFF_SOUNDS_DEFAULT = 566027; -- Bell Tribal