-------------------------------------------------------------------------------
-- French localization
-------------------------------------------------------------------------------

if (GetLocale() == "frFR") then

SMARTDEBUFF_UPGRADED = "SmartDebuff mis \195\160 jour : "..SMARTDEBUFF_VERSION;

SMARTDEBUFF_WHATSNEW = "|cffffffffNouveaut\195\169s:|r\n\n"
  .."- Mis \195\160 jour pour DragonFlight !\n\n"
  .."- L'\195\137vocateur est g\195\169r\195\169\n\n"
  .."- Bug majeurs corrig\195\169s\n\n"
  ;

-- Debuff types, in english in game!
--[[
SMARTDEBUFF_DISEASE = "Maladie";
SMARTDEBUFF_MAGIC   = "Magie";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Mal\195\169diction";
SMARTDEBUFF_CHARMED = "Contr\195\180le mentale";
]]--


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humano\195\175de";
SMARTDEBUFF_DEMON     = "D\195\169mon";
SMARTDEBUFF_BEAST     = "B\195\170te";
SMARTDEBUFF_ELEMENTAL = "\195\137l\195\169mentaire";
SMARTDEBUFF_IMP       = "Diablotin";
SMARTDEBUFF_FELHUNTER = "Chasseur corrompu";
SMARTDEBUFF_DOOMGUARD = "Garde funeste";

-- Classes
SMARTDEBUFF_CLASSES = {["HPET"] = "Familier Chasseur", ["WPET"] = "Familier D\195\169moniste", ["DPET"] = "Familier Chasseur de d\195\169mons"};
for _, class in ipairs(CLASS_SORT_ORDER) do SMARTDEBUFF_CLASSES[class] = LOCALIZED_CLASS_NAMES_MALE[class] end;


-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Menu d\'Options";

SMARTDEBUFF_KEYS = {["L"]  = "Gauche (L)",
                    ["R"]  = "Droite (R)",
                    ["M"]  = "Milieu (M)",
                    ["SL"] = "Maj gauche",
                    ["SR"] = "Maj droite",
                    ["SM"] = "Maj milieu",
                    ["AL"] = "Alt gauche",
                    ["AR"] = "Alt droite",
                    ["AM"] = "Alt milieu",
                    ["CL"] = "Ctrl gauche",
                    ["CR"] = "Ctrl droite",
                    ["CM"] = "Ctrl milieu"
                    };


-- Messages
SMARTDEBUFF_MSG_LOADED         = "charg\195\169";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff menu d\'Options";

-- Frame text
SMARTDEBUFF_FT_MODES           = "Touches/Modes";
SMARTDEBUFF_FT_MODENORMAL      = "Norm";
SMARTDEBUFF_FT_MODETARGET      = "Trgt";


-- Options frame text
SMARTDEBUFF_OFT                = "Show/Hide SmartDebuff options frame";
SMARTDEBUFF_OFT_HUNTERPETS     = "Familiers Chasseur";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Familiers D\195\169moniste";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "Familiers Chevalier de la mort";
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
SMARTDEBUFF_OFT_SHOWRAIDICON   = "Raid icons"; -- NOT TRANSLATED

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Sort by class order";
SMARTDEBUFF_NRDT_TITLE         = "Unremovable Debuffs";
SMARTDEBUFF_S_TITLE            = "Debuff Alert Sound";


-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-Left drag: Move frame\n|cff20d2ff- S button -|r\nLeft click: Show by classes\nShift-Left click: Class colors\nAlt-Left click: Highlight L/R\nRight click: Background"; -- NOT TRANSLATED
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
SMARTDEBUFF_TT_DROPINFO        = "Drop a spell/item/macro\nof your book/inventory.\n|cff00ff00Left click set target function.";
SMARTDEBUFF_TT_DROPSPELL       = "Spell click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_DROPITEM        = "Item click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_DROPMACRO       = "Macro click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_TARGET          = "Target";
SMARTDEBUFF_TT_TARGETINFO      = "Selects the specified unit\nas the current target.";
SMARTDEBUFF_TT_DROPTARGET      = "Unit click:\nRemove";
SMARTDEBUFF_TT_DROPACTION      = "Pet action:\nRemove not possible!";

--Tooltips added by Semi#1287
SMARTDEBUFF_TT_OPTIONS		   		= "Left click: Open options\n|cff20d2ff- O button -|r";
SMARTDEBUFF_OFT_NOTREMOVABLE_LIST 	= "Debuff Guard List";
SMARTDEBUFF_TT_NOTREMOVABLE_LIST 	= "Click to Edit List";
SMARTDEBUFF_OFT_SKILLS 				= "Skill Menu";
SMARTDEBUFF_TT_SKILLS				= "Click to Edit Skill Quick Slots";
SMARTDEBUFF_OFT_SHOWDEBUFFGUARD 	= "Spell Guard List";
SMARTDEBUFF_TT_SHOWDEBUFFGUARD 		= "Click to Edit\nList of Spells to Track";
SMARTDEBUFF_TT_SOUNDLIST 			= "Click to Select Sound";

-- Tooltip support
SMARTDEBUFF_FUBAR_TT           = "\nLeft Click: Menu d\'options\nShift-Left Click: ON/OFF"; -- NOT TRANSLATED
SMARTDEBUFF_BROKER_TT          = "\nLeft Click: Menu d\'options\nRight Click: ON/OFF"; -- NOT TRANSLATED

end
