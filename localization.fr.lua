-------------------------------------------------------------------------------
-- French localization
-------------------------------------------------------------------------------

if (GetLocale() == "frFR") then

SMARTDEBUFF_UPGRADED = "SmartDebuff mis \195\160 jour : "..SMARTDEBUFF_VERSION;

SMARTDEBUFF_WHATSNEW = "|cffffffffNouveaut\195\169s :|r\n\n"
  .."- Versions |cffff1111Wow Classic|r & |cff87CEEBWrath|r !\n\n\n"
  .."- D\195\169tection des sorts r\195\169\195\169crite :\n|cffff1111 Reset des touches recommand\195\169 !|r\n\n"
  .."- Visibilit\195\169 des sorts revue.\n\n"
  .."- Les sorts inactifs sont bien d\195\169pla\195\167ables.\n\n"
  .."- Sorts par d\195\169faut revus pour toutes les classes\n\n"
  ;

--@do-not-package@
-- Debuff types, in english in game!
--[[
SMARTDEBUFF_DISEASE = "Maladie";
SMARTDEBUFF_MAGIC   = "Magie";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Mal\195\169diction";
SMARTDEBUFF_CHARMED = "Contr\195\180le mental";
]]--
--@end-do-not-package@


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

SMARTDEBUFF_KEY_L = "G";
SMARTDEBUFF_KEY_M = "M";
SMARTDEBUFF_KEY_R = "D";
SMARTDEBUFF_KEYS = {["L"]  = "Gauche (G)",
                    ["R"]  = "Droite (D)",
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
SMARTDEBUFF_FT_MODETARGET      = "Cible";


-- Options frame text
SMARTDEBUFF_OFT                = "Affiche/Masque les options SmartDebuff";
SMARTDEBUFF_OFT_HUNTERPETS     = "Familier de Chasseur";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Familier de D\195\169moniste";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "Familier de Chevalier de la mort";
SMARTDEBUFF_OFT_HP             = "Vie";
SMARTDEBUFF_OFT_MANA           = "Mana";
SMARTDEBUFF_OFT_HPTEXT         = "%";
SMARTDEBUFF_OFT_INVERT         = "Inverser";
SMARTDEBUFF_OFT_CLASSVIEW      = "Vue de classe";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Couleurs de classe";
SMARTDEBUFF_OFT_SHOWLR         = "G / D / M";
SMARTDEBUFF_OFT_HEADERS        = "En-t\195\170tes";
SMARTDEBUFF_OFT_GROUPNR        = "Groupe num\195\169ro";
SMARTDEBUFF_OFT_SOUND          = "Son";
SMARTDEBUFF_OFT_TOOLTIP        = "Infobulle";
SMARTDEBUFF_OFT_TARGETMODE     = "Mode cible";
SMARTDEBUFF_OFT_HEALRANGE      = "Port\195\169e de soin";
SMARTDEBUFF_OFT_SHOWAGGRO      = "Aggro";
SMARTDEBUFF_OFT_VERTICAL       = "Arrang\195\169 verticalement";
SMARTDEBUFF_OFT_VERTICALUP     = "Vertical vers le haut";
SMARTDEBUFF_OFT_HEADERROW      = "Barre de titre";
SMARTDEBUFF_OFT_BACKDROP       = "Fond";
SMARTDEBUFF_OFT_SHOWGRADIENT   = "D\195\169grad\195\169";
SMARTDEBUFF_OFT_INFOFRAME      = "Cadre de r\195\169sum\195\169";
SMARTDEBUFF_OFT_AUTOHIDE       = "Masquer auto.";
SMARTDEBUFF_OFT_COLUMNS        = "Colonnes";
SMARTDEBUFF_OFT_INTERVAL       = "Intervalle";
SMARTDEBUFF_OFT_FONTSIZE       = "Taille de police";
SMARTDEBUFF_OFT_WIDTH          = "Largeur";
SMARTDEBUFF_OFT_HEIGHT         = "Hauteur";
SMARTDEBUFF_OFT_BARHEIGHT      = "Hauteur de barre";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "Opacit\195\169 \195\160 port\195\169e";
SMARTDEBUFF_OFT_OPACITYOOR     = "Opacit\195\169 hors de port\195\169e";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Opacit\195\169 d\195\169buff";
SMARTDEBUFF_OFT_NOTREMOVABLE   = "Garde de d\195\169buffs";
SMARTDEBUFF_OFT_VEHICLE        = "V\195\169hicules";
SMARTDEBUFF_OFT_SHOWRAIDICON   = "Ic\195\180nes de raid (r\195\180le)";
SMARTDEBUFF_OFT_SHOWSPELLICON  = "Ic\195\180ne de sort";
SMARTDEBUFF_OFT_INFOROW        = "Barre d'info";
SMARTDEBUFF_OFT_GLOBALSAVE     = "Sauver";
SMARTDEBUFF_OFT_GLOBALLOAD     = "Charger";
SMARTDEBUFF_OFT_ROLE           = "R\195\180le";
SMARTDEBUFF_OFT_ADVANCHORS     = "Configurer les ancres";
SMARTDEBUFF_OFT_ICONSIZE       = "Taille des ic\195\180nes";
SMARTDEBUFF_OFT_COLORSETUP     = "Configurer les couleurs";
SMARTDEBUFF_OFT_SPACEX         = "Espacement X";
SMARTDEBUFF_OFT_SPACEY         = "Espacement Y";
SMARTDEBUFF_OFT_TESTMODE       = "Mode test";
SMARTDEBUFF_OFT_STOPCAST       = "Interrompre le sort";
SMARTDEBUFF_OFT_IGNOREDEBUFF   = "Ignorer les d\195\169buffs";
SMARTDEBUFF_OFT_CHATNOTIF      = "Notification de chat";
SMARTDEBUFF_OFT_RESET_KEYS     = "R\195\169initialiser les sorts SmartDebuff par d\195\169faut ?\n\nCette action est n\195\169cessaire si vous avez l'impression que tous les d\195\169buffs ne sont pas correctement d\195\169tect\195\169s.";
SMARTDEBUFF_AOFT_SORTBYCLASS   = "Trier par ordre de classe";
SMARTDEBUFF_NRDT_TITLE         = "D\195\169buffs inamovibles";
SMARTDEBUFF_SG_TITLE           = "Garde de sort";
SMARTDEBUFF_S_TITLE            = "Son d'alerte de d\195\169buff";


-- Tooltip text
SMARTDEBUFF_TT                 = "Glisser le titre avec Maj-Clic gauche : D\195\169place le cadre\n|cff20d2ff- Bouton S -|r\nClic gauche : Afficher par classes\nMaj-Clic gauche : Couleurs de classe\nAlt-Clic gauche : Mise en avant L/R\nClic droit : Arri\195\168re-plan";
SMARTDEBUFF_TT_TARGETMODE      = "En mode cible |cff20d2ffClic gauche|r s\195\169lectionne l'unit\195\169 et |cff20d2ffClic droit|r lance le sort de soin le plus rapide. Utilisez |cff20d2ffAlt-Clic gauche/droit|r pour d\195\169buff.";
SMARTDEBUFF_TT_NOTREMOVABLE    = "Affiche les d\195\169buffs critiques\nqui ne sont pas amovibles.";
SMARTDEBUFF_TT_HP              = "Affiche les points de vie\nr\195\169els de l'unit\195\169.";
SMARTDEBUFF_TT_MANA            = "Affiche le pool de mana\nr\195\169el de l'unit\195\169.";
SMARTDEBUFF_TT_HPTEXT          = "Affiche le pool de vie/mana\nr\195\169el en pourcentage de\nl'unit\195\169 en texte.";
SMARTDEBUFF_TT_INVERT          = "Affiche les points de vie\net le pool de mana invers\195\169s.";
SMARTDEBUFF_TT_CLASSVIEW       = "Affiche les boutons d'unit\195\169\nordonn\195\169s par classe.";
SMARTDEBUFF_TT_CLASSCOLOR      = "Affiche les boutons d'unit\195\169 dans\nleurs couleurs de classe correspondantes.";
SMARTDEBUFF_TT_SHOWLR          = "Affiche le bouton de souris correspondant (G/D/M),\nsi une unit\195\169 a un d\195\169buff.";
SMARTDEBUFF_TT_HEADERS         = "Affiche le nom de la classe\ncomme ligne d'en-t\195\170te.";
SMARTDEBUFF_TT_GROUPNR         = "Affiche le num\195\169ro de groupe\ndevant le nom de l'unit\195\169.";
SMARTDEBUFF_TT_SOUND           = "Joue un son, si une\nunit\195\169 re\195\167oit un d\195\169buff.";
SMARTDEBUFF_TT_TOOLTIP         = "Affiche l'infobulle,\nseulement hors de combat.";
SMARTDEBUFF_TT_HEALRANGE       = "Affiche une bordure rouge,\nsi votre sort est hors de port\195\169e.";
SMARTDEBUFF_TT_SHOWAGGRO       = "Affiche quelle\nunit\195\169 a l'aggro.";
SMARTDEBUFF_TT_VERTICAL        = "Affiche les unit\195\169s\narrang\195\169es verticalement.";
SMARTDEBUFF_TT_VERTICALUP      = "Affiche les unit\195\169s\ndu bas vers le haut.";
SMARTDEBUFF_TT_HEADERROW       = "Affiche la ligne d'en-t\195\170te,\ny compris les boutons de menu.";
SMARTDEBUFF_TT_BACKDROP        = "Affiche un cadre\nd'arri\195\168re-plan noir.";
SMARTDEBUFF_TT_SHOWGRADIENT    = "Affiche les boutons d'unit\195\169\navec un gradient de couleur.";
SMARTDEBUFF_TT_INFOFRAME       = "Affiche le cadre r\195\169capitulatif,\nseulement dans la configuration de groupe ou de raid.";
SMARTDEBUFF_TT_AUTOHIDE        = "Cache automatiquement les boutons\nd'unit\195\169, si vous \195\170tes hors de combat\net que personne n'a de d\195\169buff.";
SMARTDEBUFF_TT_VEHICLE         = "Affiche en plus le v\195\169hicule\nd'nune unit\195\169 en tant que bouton propre.";
SMARTDEBUFF_TT_SHOWRAIDICON    = "Affiche l'ic\195\180ne de raid\nde l'unit\195\169.";
SMARTDEBUFF_TT_SHOWSPELLICON   = "Affiche l'ic\195\180ne HoT\nsur l'unit\195\169.";
SMARTDEBUFF_TT_INFOROW         = "Affiche une barre d'info en style court (uniquement en raid) #\nJoueurs/Morts/AFK/Hors ligne\nVie/Mana\nPr\195\170t";
SMARTDEBUFF_TT_GLOBALSAVE      = "param\195\168tres enregistr\195\169s dans la sauvegarde globale.";
SMARTDEBUFF_TT_GLOBALLOAD      = "param\195\168tres charg\195\169s depuis la sauvegarde globale.";
SMARTDEBUFF_TT_ROLE            = "Affiche les boutons d'unit\195\169\npar ordre de r\195\180le.";
SMARTDEBUFF_TT_ADVANCHORS      = "Affiche et utilise la configuration\navanc\195\169e d'ancrage pour le\ncadre de d\195\169buff.";
SMARTDEBUFF_TT_STOPCAST        = "Interrompt imm\195\169diatement le\nlancement ou la canalisation courante,\npour lancer le sort d\195\169fini.\n(Sorts de d\195\169buff uniquement)";
SMARTDEBUFF_TT_IGNOREDEBUFF    = "Ignore le d\195\169buff sur l'unit\195\169\nsi votre sort de d\195\169buff est en temps de recharge";
SMARTDEBUFF_TT_CHATNOTIF       = "Affiche des messages de chat au chargement";

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
SMARTDEBUFF_TT_DROP            = "L\195\162cher";
SMARTDEBUFF_TT_DROPINFO        = "L\195\162cher un sort/objet/macro\n de votre livre/inventaire.\n|cff00ff00Clic gauche pour d\195\169finir la fonction cible.\nMaj-Gauche pour d\195\169finir la fonction menu";
SMARTDEBUFF_TT_SPELLACTIONS    = "Clic sur le sort :\nGauche pour prendre\nMaj-Gauche pour cloner\nDroit pour supprimer";
SMARTDEBUFF_TT_ITEMACTIONS     = "Clic sur l'objet :\nGauche pour prendre\nMaj-Gauche pour cloner\nDroit pour supprimer";
SMARTDEBUFF_TT_MACROACTIONS    = "Clic sur la macro :\nGauche pour prendre\nMaj-Gauche pour cloner\nDroit pour supprimer";
SMARTDEBUFF_TT_TARGET          = "Cible";
SMARTDEBUFF_TT_TARGETINFO      = "S\195\169lectionne l'unit\195\169 sp\195\169cifi\195\169e\ncomme cible actuelle.";
SMARTDEBUFF_TT_PETACTION       = "Sort de familier";
SMARTDEBUFF_TT_NOTFOUND        = "Erreur : Sort introuvable";
SMARTDEBUFF_TT_MISSINGINFO     = "V\195\169rifiez votre Sp\195\169cialisation / Talent / Familier.";
SMARTDEBUFF_TT_NOTMOVABLE      = "Impossible \195\160 d\195\169placer avec votre Sp\195\169cialisation";
SMARTDEBUFF_TT_TARGETACTIONS   = "Clic de la souris :\nDroit pour supprimer";
SMARTDEBUFF_TT_PETACTIONS      = "Action du familier :\nSuppression impossible!";
SMARTDEBUFF_TT_MENU            = "Menu";
SMARTDEBUFF_TT_MENUINFO        = "Ouvre le menu des options de l'unit\195\169.";
SMARTDEBUFF_TT_PICKMENU        = "Clic de la souris :\nDroit pour supprimer";
SMARTDEBUFF_TT_DROPABBLE       = "Clic de la souris :\nGauche pour d\195\169poser\nDroit pour rel\195\162cher";
SMARTDEBUFF_TT_DROPREPLACE     = "Clic de la souris :\nGauche pour remplacer\nDroit pour rel\195\162cher";
SMARTDEBUFF_TT_DROPEXCHANGE    = "Clic de la souris :\nGauche pour \195\169changer\nDroit pour rel\195\162cher";
SMARTDEBUFF_TT_CANTDROP        = "Clic de la souris :\nDroit pour rel\195\162cher";

--Tooltips added by Semi#1287
SMARTDEBUFF_TT_OPTIONS          = "|cff20d2ff- Bouton O -|r\nClic gauche : Ouvrir les options";
SMARTDEBUFF_OFT_CLASSSORT       = "Liste tri\195\169e des classes";
SMARTDEBUFF_TT_CLASSSORT 	      = "Cliquez pour modifier l'ordre des classes";
SMARTDEBUFF_OFT_NOTREMOVABLE_LIST = "Liste de protection contre les d\195\169buffs";
SMARTDEBUFF_TT_NOTREMOVABLE_LIST 	= "Cliquez pour modifier la liste";
SMARTDEBUFF_OFT_SKILLS          = "Touches de la souris";
SMARTDEBUFF_TT_SKILLS           = "Cliquez pour modifier les raccourcis\n(Clic G/D/M, avec Alt/Maj/Ctrl)";
SMARTDEBUFF_TT_RESET_SKILLS     = "R\195\169initialise les raccourcis pour votre classe";
SMARTDEBUFF_OFT_SHOWDEBUFFGUARD	= "Liste de protection contre les sorts";
SMARTDEBUFF_TT_SHOWDEBUFFGUARD  = "Cliquez pour modifier\nla liste des sorts \195\160 suivre";
SMARTDEBUFF_TT_SOUNDLIST        = "Cliquez pour s\195\169lectionner le son";

-- Tooltip support
SMARTDEBUFF_FUBAR_TT           = "\nClic gauche : Ouvrir les options\nMaj-Clic gauche : On/Off";
SMARTDEBUFF_BROKER_TT          = "Clic gauche : Ouvrir les options\nClic droit : On/Off";


end

--@do-not-package@
-- https://code.google.com/archive/p/mangadmin/wikis/SpecialCharacters.wiki
-- https://wowwiki.fandom.com/wiki/Localizing_an_addon
--@end-do-not-package@