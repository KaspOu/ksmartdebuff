-------------------------------------------------------------------------------
-- Spanish localization
-------------------------------------------------------------------------------

if (GetLocale() == "esES") then


--@do-not-package@
-- Debuff types, in english in game!
--[[
SMARTDEBUFF_DISEASE = "Enfermedad";
SMARTDEBUFF_MAGIC   = "Magia";
SMARTDEBUFF_POISON  = "Veneno";
SMARTDEBUFF_CURSE   = "Maldici\195\179n";
SMARTDEBUFF_CHARMED = "Control mental";
SMARTDEBUFF_HEAL    = "Sanar";
]]--
--@end-do-not-package@

-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoide";
SMARTDEBUFF_DEMON     = "Demonio";
SMARTDEBUFF_BEAST     = "Bestia";
SMARTDEBUFF_ELEMENTAL = "Elemental";
SMARTDEBUFF_IMP       = "Diablillo";
SMARTDEBUFF_FELHUNTER = "Man\195\161fago";
SMARTDEBUFF_DOOMGUARD = "Guardia apocal\195\173ptico";

-- Classes
SMARTDEBUFF_CLASSES = { ["HPET"] = "Mascota de cazador", ["WPET"] = "Mascota de Brujo", ["DPET"] = "Mascota de Caballero de la Muerte"};
for _, class in ipairs(CLASS_SORT_ORDER) do SMARTDEBUFF_CLASSES[class] = LOCALIZED_CLASS_NAMES_MALE[class] end;

-- Bindings
BINDING_NAME_SMARTDEBUFF =  SMARTDEBUFF_TITLE.." Opciones";

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
SMARTDEBUFF_MSG_LOADED         = "cargado";
SMARTDEBUFF_MSG_SDB            = "Marco de opciones de SmartDebuff";

-- Frame text
SMARTDEBUFF_FT_MODES           = "Keys/Modes";
SMARTDEBUFF_FT_MODENORMAL      = "Norm";
SMARTDEBUFF_FT_MODETARGET      = "Trgt";


-- Options frame text
SMARTDEBUFF_OFT                = "Mostrar/ocultar Marco de opciones de SmartDebuff";
SMARTDEBUFF_OFT_HUNTERPETS     = "Mascotas de cazador";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Mascotas de brujo";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "Mascotas de Caballero de la Muerte";
SMARTDEBUFF_OFT_HP             = "HP"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_MANA           = "Mana"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_HPTEXT         = "%";
SMARTDEBUFF_OFT_INVERT         = "Invertir";
SMARTDEBUFF_OFT_CLASSVIEW      = "Ver clases";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Colores de clases";
SMARTDEBUFF_OFT_SHOWLR         = "L / R / M";
SMARTDEBUFF_OFT_HEADERS        = "Encabezados";
SMARTDEBUFF_OFT_GROUPNR        = "Nº de grupo";
SMARTDEBUFF_OFT_SOUND          = "Sonido";
SMARTDEBUFF_OFT_TOOLTIP        = "Ayuda visual";
SMARTDEBUFF_OFT_TARGETMODE     = "Modo objetivo";
SMARTDEBUFF_OFT_HEALRANGE      = "Rango de cura";
SMARTDEBUFF_OFT_SHOWAGGRO      = "Aggro";
SMARTDEBUFF_OFT_VERTICAL       = "Orden vertical";
SMARTDEBUFF_OFT_VERTICALUP     = "Vertical arriba";
SMARTDEBUFF_OFT_HEADERROW      = "Encabezado de fila, con botones";
SMARTDEBUFF_OFT_BACKDROP       = "Mostrar fondo";
SMARTDEBUFF_OFT_SHOWGRADIENT   = "Gradient"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_INFOFRAME      = "Mostrar marco de sumario";
SMARTDEBUFF_OFT_AUTOHIDE       = "Auto hide"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_COLUMNS        = "Columnas";
SMARTDEBUFF_OFT_INTERVAL       = "Intervalo";
SMARTDEBUFF_OFT_FONTSIZE       = "Tama\195\177o de fuente";
SMARTDEBUFF_OFT_WIDTH          = "Ancho";
SMARTDEBUFF_OFT_HEIGHT         = "Alto";
SMARTDEBUFF_OFT_BARHEIGHT      = "Barra alto";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "Opacidad en rango";
SMARTDEBUFF_OFT_OPACITYOOR     = "Opacidad fuera de rango";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Opacidad al quitar debuff";
SMARTDEBUFF_OFT_NOTREMOVABLE   = "Debuff Guard"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_VEHICLE        = "Veh\195\173culo";
SMARTDEBUFF_OFT_SHOWRAIDICON   = "Banda signo";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Sort by class order";
SMARTDEBUFF_NRDT_TITLE         = "Unremovable Debuffs";
SMARTDEBUFF_S_TITLE            = "Debuff alarma tono";


-- Tooltip text
SMARTDEBUFF_TT                 = "May\195\186sculas-arrastrar izquierdo: Mover marco\n|cff20d2ff- S bot\195\179n -|r\nClick Izquierdo: Mostrar por clases\nMay\195\186scuals-Click Izquierdo: Colores de clase\nAlt-Click izquierdo: Destacar L/R\nClick derecho: Fondo";
SMARTDEBUFF_TT_TARGETMODE      = "En modo objetivo |cff20d2ffClick izquierdo|r selecciona la unidad y |cff20d2ffClick derecho|r lanza el hechizo m\195\161s r\195\161pido de curaci\195\179n.\nUsar |cff20d2ffAlt-Click derecho/izquierdo|r para debuff.";
SMARTDEBUFF_TT_NOTREMOVABLE    = "Muestra debuffs críticos\nque no son removibles.";
SMARTDEBUFF_TT_HP              = "Muestra los puntos de salud\nactuales de la unidad.";
SMARTDEBUFF_TT_MANA            = "Muestra la cantidad de mana\nactual de la unidad.";
SMARTDEBUFF_TT_HPTEXT          = "Muestra la cantidad de hp/mana\nactual como porcentaje de\nla unidad en texto.";
SMARTDEBUFF_TT_INVERT          = "Muestra los puntos de salud\ny el mana de forma invertida.";
SMARTDEBUFF_TT_CLASSVIEW       = "Muestra los botones de unidad\nordenados por clase.";
SMARTDEBUFF_TT_CLASSCOLOR      = "Muestra los botones de unidad en\nlos colores correspondientes a su clase.";
SMARTDEBUFF_TT_SHOWLR          = "Muestra el botón del mouse correspondiente\n(L/R/M), si una unidad tiene un debuff.";
SMARTDEBUFF_TT_HEADERS         = "Muestra el nombre de la clase\ncomo fila de encabezado.";
SMARTDEBUFF_TT_GROUPNR         = "Muestra el número de grupo\nfrente al nombre de la unidad.";
SMARTDEBUFF_TT_SOUND           = "Reproduce un sonido, si una\nunidad recibe un debuff.";
SMARTDEBUFF_TT_TOOLTIP         = "Muestra la descripción emergente,\nsolo fuera de combate.";
SMARTDEBUFF_TT_HEALRANGE       = "Muestra un borde rojo,\nsi tu hechizo está fuera de alcance.";
SMARTDEBUFF_TT_SHOWAGGRO       = "Muestra qué\nunidad tiene aggro.";
SMARTDEBUFF_TT_VERTICAL        = "Muestra las unidades\norganizadas verticalmente.";
SMARTDEBUFF_TT_VERTICALUP      = "Muestra las unidades\nde abajo hacia arriba.";
SMARTDEBUFF_TT_HEADERROW       = "Muestra la fila de encabezado,\nincluyendo los botones de menú.";
SMARTDEBUFF_TT_BACKDROP        = "Muestra un marco de\nfondo negro.";
SMARTDEBUFF_TT_SHOWGRADIENT    = "Muestra los botones de unidad\ncon gradiente de color.";
SMARTDEBUFF_TT_INFOFRAME       = "Muestra el marco de resumen,\nsolo en configuración de grupo o raid.";
SMARTDEBUFF_TT_AUTOHIDE        = "Oculta automáticamente los botones de unidad,\nsi estás fuera de combate y\nnadie tiene un debuff.";
SMARTDEBUFF_TT_VEHICLE         = "Muestra además el vehículo de\nla unidad como su propio botón.";
SMARTDEBUFF_TT_SHOWRAIDICON    = "Muestra el icono de raid\nde la unidad.";

--SMARTDEBUFF_TT_COLUMNS         = "Columns";
--SMARTDEBUFF_TT_INTERVAL        = "Interval";
--SMARTDEBUFF_TT_FONTSIZE        = "Font size";
--SMARTDEBUFF_TT_WIDTH           = "Width";
--SMARTDEBUFF_TT_HEIGHT          = "Height";
--SMARTDEBUFF_TT_BARHEIGHT       = "Bar height";
--SMARTDEBUFF_TT_OPACITYNORMAL   = "Opacity in range";
--SMARTDEBUFF_TT_OPACITYOOR      = "Opacity out of range";
--SMARTDEBUFF_TT_OPACITYDEBUFF   = "Opacity debuff";

-- -- Tooltip text key bindings
-- SMARTDEBUFF_TT_DROP            = "Drop";
-- SMARTDEBUFF_TT_DROPINFO        = "Drop a spell/item/macro\nof your book/inventory.\n|cff00ff00Left click set target function.";
-- SMARTDEBUFF_TT_SPELLACTIONS    = "Spell click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
-- SMARTDEBUFF_TT_ITEMACTIONS     = "Item click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
-- SMARTDEBUFF_TT_MACROACTIONS    = "Macro click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
-- SMARTDEBUFF_TT_TARGET          = "Target";
-- SMARTDEBUFF_TT_TARGETINFO      = "Selects the specified unit\nas the current target.";
-- SMARTDEBUFF_TT_TARGETACTIONS   = "Unit click:\nRemove";
-- SMARTDEBUFF_TT_PETACTIONS      = "Pet action:\nRemove not possible!";

-- --Tooltips added by Semi#1287
-- SMARTDEBUFF_TT_OPTIONS		   		= "Left click: Open options\n|cff20d2ff- O button -|r";
-- SMARTDEBUFF_OFT_NOTREMOVABLE_LIST 	= "Debuff Guard List";
-- SMARTDEBUFF_TT_NOTREMOVABLE_LIST 	= "Click to Edit List";
-- SMARTDEBUFF_OFT_SKILLS 				= "Skill Menu";
-- SMARTDEBUFF_TT_SKILLS				= "Click to Edit Skill Quick Slots";
-- SMARTDEBUFF_OFT_SHOWDEBUFFGUARD 	= "Spell Guard List";
-- SMARTDEBUFF_TT_SHOWDEBUFFGUARD 		= "Click to Edit\nList of Spells to Track";
-- SMARTDEBUFF_TT_SOUNDLIST 			= "Click to Select Sound";

-- Tooltip support
SMARTDEBUFF_FUBAR_TT           = "\nClick izquierdo: Abrir opciones\nMay\195\186sulas-Click izquierdo: On/Off";
SMARTDEBUFF_BROKER_TT          = "\nClick izquierdo: Abrir opciones\nClick derecho: On/Off";

end