-------------------------------------------------------------------------------
-- English localization (Default)
-------------------------------------------------------------------------------

SMARTDEBUFF_UPGRADED = "SmartDebuff upgraded to "..SMARTDEBUFF_VERSION;
-- Whats new info
SMARTDEBUFF_WHATSNEW = [[|cffffffffWhats new:|r

- The War Within ready

- Spells list version displayed
]];

--@do-not-package@
-- Debuff types, in english in game! => global
--[[
SMARTDEBUFF_DISEASE = "Disease";
SMARTDEBUFF_MAGIC   = "Magic";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Curse";
SMARTDEBUFF_CHARMED = "Mind Control";
SMARTDEBUFF_BLEEDING   = "Bleeding";
SMARTDEBUFF_HEAL    = "Heal";
]]--
--@end-do-not-package@


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoid";
SMARTDEBUFF_DEMON     = "Demon";
SMARTDEBUFF_BEAST     = "Beast";
SMARTDEBUFF_ELEMENTAL = "Elemental";
SMARTDEBUFF_IMP       = "Imp";
SMARTDEBUFF_FELHUNTER = "Felhunter";
SMARTDEBUFF_DOOMGUARD = "Doomguard";

-- Classes
SMARTDEBUFF_CLASSES = { ["HPET"] = "Hunter Pet", ["WPET"] = "Warlock Pet", ["DPET"] = "Death Knight pet"};
for _, class in ipairs(CLASS_SORT_ORDER) do SMARTDEBUFF_CLASSES[class] = LOCALIZED_CLASS_NAMES_MALE[class] end;

-- Bindings
BINDING_NAME_SMARTDEBUFF =  SMARTDEBUFF_TITLE.." Options";

SMARTDEBUFF_KEY_L = "L";
SMARTDEBUFF_KEY_M = "M";
SMARTDEBUFF_KEY_R = "R";
SMARTDEBUFF_KEYS = {["L"]  = "Left",
                    ["R"]  = "Right",
                    ["M"]  = "Middle",
                    ["SL"] = "Shift left",
                    ["SR"] = "Shift right",
                    ["SM"] = "Shift middle",
                    ["AL"] = "Alt left",
                    ["AR"] = "Alt right",
                    ["AM"] = "Alt middle",
                    ["CL"] = "Ctrl left",
                    ["CR"] = "Ctrl right",
                    ["CM"] = "Ctrl middle"
                    };


-- Messages
SMARTDEBUFF_MSG_LOADED         = "loaded";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff options frame";

-- Frame text
SMARTDEBUFF_FT_MODES           = "Keys/Modes";
SMARTDEBUFF_FT_MODENORMAL      = "Norm";
SMARTDEBUFF_FT_MODETARGET      = "Trgt";


-- Options frame text
SMARTDEBUFF_OFT                = "Show/Hide SmartDebuff options frame";
SMARTDEBUFF_OFT_HUNTERPETS     = "Hunter pets";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Warlock pets";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "Death Knight pets";
SMARTDEBUFF_OFT_HP             = "HP";
SMARTDEBUFF_OFT_MANA           = "Mana";
SMARTDEBUFF_OFT_HPTEXT         = "%";
SMARTDEBUFF_OFT_INVERT         = "Invert";
SMARTDEBUFF_OFT_CLASSVIEW      = "Class view";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Class colors";
SMARTDEBUFF_OFT_SHOWLR         = "L / R / M";
SMARTDEBUFF_OFT_HEADERS        = "Headers";
SMARTDEBUFF_OFT_GROUPNR        = "Group Nr.";
SMARTDEBUFF_OFT_SOUND          = "Sound";
SMARTDEBUFF_OFT_TOOLTIP        = "Tooltip";
SMARTDEBUFF_OFT_TARGETMODE     = "Target mode";
SMARTDEBUFF_OFT_HEALRANGE      = "Heal range";
SMARTDEBUFF_OFT_SHOWAGGRO      = "Aggro";
SMARTDEBUFF_OFT_VERTICAL       = "Vertical arranged";
SMARTDEBUFF_OFT_VERTICALUP     = "Vertical up";
SMARTDEBUFF_OFT_HEADERROW      = "Title bar";
SMARTDEBUFF_OFT_BACKDROP       = "Background";
SMARTDEBUFF_OFT_SHOWGRADIENT   = "Gradient";
SMARTDEBUFF_OFT_INFOFRAME      = "Summary frame";
SMARTDEBUFF_OFT_AUTOHIDE       = "Auto hide";
SMARTDEBUFF_OFT_COLUMNS        = "Columns";
SMARTDEBUFF_OFT_INTERVAL       = "Interval";
SMARTDEBUFF_OFT_FONTSIZE       = "Font size";
SMARTDEBUFF_OFT_WIDTH          = "Width";
SMARTDEBUFF_OFT_HEIGHT         = "Height";
SMARTDEBUFF_OFT_BARHEIGHT      = "Bar height";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "Opacity in range";
SMARTDEBUFF_OFT_OPACITYOOR     = "Opacity out of range";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Opacity debuff";
SMARTDEBUFF_OFT_NOTREMOVABLE   = "Debuff Guard";
SMARTDEBUFF_OFT_VEHICLE        = "Vehicles";
SMARTDEBUFF_OFT_SHOWRAIDICON   = "Raid icons";
SMARTDEBUFF_OFT_SHOWSPELLICON  = "Spell icon";
SMARTDEBUFF_OFT_INFOROW        = "Info bar";
SMARTDEBUFF_OFT_GLOBALSAVE     = "Save";
SMARTDEBUFF_OFT_GLOBALLOAD     = "Load";
SMARTDEBUFF_OFT_RESET          = "Reset";
SMARTDEBUFF_OFT_ROLE           = "Role";
SMARTDEBUFF_OFT_ADVANCHORS     = "Anchor Setup";
SMARTDEBUFF_OFT_ICONSIZE       = "Icon size";
SMARTDEBUFF_OFT_COLORSETUP     = "Color Setup";
SMARTDEBUFF_OFT_SPACEX         = "Space X";
SMARTDEBUFF_OFT_SPACEY         = "Space Y";
SMARTDEBUFF_OFT_TESTMODE       = "Test Mode";
SMARTDEBUFF_OFT_STOPCAST       = "Stop Casting";
SMARTDEBUFF_OFT_IGNOREDEBUFF   = "Ignore Debuffs";
SMARTDEBUFF_OFT_CHATNOTIF        = "Chat notification";
SMARTDEBUFF_OFT_RESET_KEYS     = "Reset the SmartDebuff spell bindings to default?\n\nThis action is necessary if you have the feeling that not all debuffs are correctly detected.";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Sort by class order";
SMARTDEBUFF_NRDT_TITLE         = "Unremovable Debuffs";
SMARTDEBUFF_SG_TITLE           = "Spell Guard";
SMARTDEBUFF_S_TITLE            = "Debuff Alert Sound";


-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-Left drag: Move frame\n|cff20d2ff- S button -|r\nLeft click: Show by classes\nShift-Left click: Class colors\nAlt-Left click: Highlight L/R\nRight click: Background";
SMARTDEBUFF_TT_TARGETMODE      = "In target mode |cff20d2ffLeft click|r selects the unit and |cff20d2ffRight click|r casts the fastest heal spell. Use |cff20d2ffAlt-Left/Right click|r to debuff.";
SMARTDEBUFF_TT_NOTREMOVABLE    = "Displays critical debuffs\nwhich are not removable.";
SMARTDEBUFF_TT_HP              = "Displays actual health\npoints of the unit.";
SMARTDEBUFF_TT_MANA            = "Displays actual mana\npool of the unit.";
SMARTDEBUFF_TT_HPTEXT          = "Displays actual hp/mana\npool as percentage of\nthe unit as text.";
SMARTDEBUFF_TT_INVERT          = "Displays health points\nand mana pool inverted.";
SMARTDEBUFF_TT_CLASSVIEW       = "Displays the unit buttons\norder by class.";
SMARTDEBUFF_TT_CLASSCOLOR      = "Displays the unit buttons in\ntheir corresponding class colors.";
SMARTDEBUFF_TT_SHOWLR          = "Displays the corresponding\nmouse button (L/R/M), if\na unit has a debuff.";
SMARTDEBUFF_TT_HEADERS         = "Displays the class name\nas header row.";
SMARTDEBUFF_TT_GROUPNR         = "Displays the group number\nin front of the unit name.";
SMARTDEBUFF_TT_SOUND           = "Plays a sound, if a\nunit gets a debuff.";
SMARTDEBUFF_TT_TOOLTIP         = "Displays the tooltip,\nonly out of combat.";
SMARTDEBUFF_TT_HEALRANGE       = "Displays a red boarder,\nif your spell is out of range.";
SMARTDEBUFF_TT_SHOWAGGRO       = "Displays which\nunit has aggro.";
SMARTDEBUFF_TT_VERTICAL        = "Displays the units\nvertical arranged.";
SMARTDEBUFF_TT_VERTICALUP      = "Displays the units\nfrom bottom to top.";
SMARTDEBUFF_TT_HEADERROW       = "Displays header row,\nincluding menu buttons.";
SMARTDEBUFF_TT_BACKDROP        = "Displays a black\nbackground frame.";
SMARTDEBUFF_TT_SHOWGRADIENT    = "Displays the unit buttons\nwith color gradient.";
SMARTDEBUFF_TT_INFOFRAME       = "Displays the summary frame,\nonly in group or raid setup.";
SMARTDEBUFF_TT_AUTOHIDE        = "Hides the unit buttons automatically,\nif you are out of combat and\nno one has a debuff.";
SMARTDEBUFF_TT_VEHICLE         = "Displays in addition the vehicle of\na unit  as own button.";
SMARTDEBUFF_TT_SHOWRAIDICON    = "Displays the raid icon\nof the unit.";
SMARTDEBUFF_TT_SHOWSPELLICON   = "Displays the HoT icon\non the unit.";
SMARTDEBUFF_TT_INFOROW         = "Displays an info bar in short style #\nPlayers/Dead/AFK/Offline\nHP/Mana\nReady check state\n(only in a raid)";
SMARTDEBUFF_TT_GLOBALSAVE      = "settings to global template.";
SMARTDEBUFF_TT_GLOBALLOAD      = "settings from global template.";
SMARTDEBUFF_TT_ROLE            = "Displays the unit buttons\norder by role.";
SMARTDEBUFF_TT_ADVANCHORS      = "Displays and uses the advanced\nanchoring setup for the debuff\nframe.";
SMARTDEBUFF_TT_STOPCAST        = "Stops immediately the current\ncasting or channeling,\nto cast the defined spell.\n(Debuff spells only)";
SMARTDEBUFF_TT_IGNOREDEBUFF    = "Ignores the debuff on the unit\nif your debuff spell is on cooldown";
SMARTDEBUFF_TT_CHATNOTIF         = "Displays chat messages on load";

--SMARTDEBUFF_TT_COLUMNS         = "Columns";
--SMARTDEBUFF_TT_INTERVAL        = "Interval";
--SMARTDEBUFF_TT_FONTSIZE        = "Font size";
--SMARTDEBUFF_TT_WIDTH           = "Width";
--SMARTDEBUFF_TT_HEIGHT          = "Height";
--SMARTDEBUFF_TT_BARHEIGHT       = "Bar height";
--SMARTDEBUFF_TT_OPACITYNORMAL   = "Opacity in range";
--SMARTDEBUFF_TT_OPACITYOOR      = "Opacity out of range";
--SMARTDEBUFF_TT_OPACITYDEBUFF   = "Opacity debuff";

-- Tooltip text key bindings
SMARTDEBUFF_TT_DROP            = "Drop";
SMARTDEBUFF_TT_DROPINFO        = "Drop a spell/item/macro\nof your book/inventory.\n|cff00ff00Left click set target function.\nShift-Left set menu function";
SMARTDEBUFF_TT_SPELLACTIONS    = "Spell click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_ITEMACTIONS     = "Item click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_MACROACTIONS    = "Macro click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_TARGET          = "Target";
SMARTDEBUFF_TT_TARGETINFO      = "Selects the specified unit\nas the current target.";
SMARTDEBUFF_TT_PETACTION       = "Pet spell";
SMARTDEBUFF_TT_NOTFOUND        = "Error: Spell not found";
SMARTDEBUFF_TT_MISSINGINFO     = "Check your Specialization / Talent / Pet.";
SMARTDEBUFF_TT_NOTMOVABLE      = "Impossible to move with your specialization";
SMARTDEBUFF_TT_TARGETACTIONS   = "Mouse click:\nRight to remove";
SMARTDEBUFF_TT_PETACTIONS      = "Pet action:\nRemove not possible!";
SMARTDEBUFF_TT_MENU            = "Menu";
SMARTDEBUFF_TT_MENUINFO        = "Opens the unit options menu.";
SMARTDEBUFF_TT_PICKMENU        = "Mouse click:\nRight to remove";
SMARTDEBUFF_TT_DROPABBLE       = "Mouse click:\nLeft to drop\nRight to release";
SMARTDEBUFF_TT_DROPREPLACE     = "Mouse click:\nLeft to replace\nRight to release";
SMARTDEBUFF_TT_DROPEXCHANGE    = "Mouse click:\nLeft to exchange\nRight to release";
SMARTDEBUFF_TT_CANTDROP        = "Mouse click:\nRight to release";

--Tooltips added by Semi#1287
SMARTDEBUFF_TT_OPTIONS		   		= "|cff20d2ff- O button -|r\nLeft click: Open options";
SMARTDEBUFF_OFT_CLASSSORT       = "Sorted list of classes";
SMARTDEBUFF_TT_CLASSSORT        = "Click to modify the class order";
SMARTDEBUFF_OFT_NOTREMOVABLE_LIST 	= "Debuff Guard List";
SMARTDEBUFF_TT_NOTREMOVABLE_LIST 	= "Click to Edit List";
SMARTDEBUFF_OFT_SKILLS 				= "Mouse keys";
SMARTDEBUFF_TT_SKILLS				= "Click to edit mouse shortcuts\n(L/R/M clicks with Alt/Shift/Ctrl)";
SMARTDEBUFF_TT_RESET_SKILLS = "Reset mouse shortcuts for your class";
SMARTDEBUFF_OFT_SHOWDEBUFFGUARD 	= "Spell Guard List";
SMARTDEBUFF_TT_SHOWDEBUFFGUARD 		= "Click to Edit\nList of Spells to Track";
SMARTDEBUFF_TT_SOUNDLIST 			= "Click to select Sound";

-- Tooltip support
SMARTDEBUFF_FUBAR_TT           = "\nLeft Click: Open options\nShift-Left Click: On/Off";
SMARTDEBUFF_BROKER_TT          = "Left Click: Open options\nRight Click: On/Off";

SMARTDEBUFF_ERR_RELOADREQUIRED  = "A reload may be required to make clicks work ( write /reload )";

