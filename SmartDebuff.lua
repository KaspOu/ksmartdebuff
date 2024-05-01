-------------------------------------------------------------------------------
-- SmartDebuff
-- Developed by Kallye (EU-Elune)  (cloned from Aeldra)
--
-- Supports you to cast debuff spells on friendly units
-------------------------------------------------------------------------------

--@do-not-package@
--[[
https://wowpedia.fandom.com/wiki/World_of_Warcraft_API

Sort actif pour le joueur ou le pet :
  not not FindSpellBookSlotBySpellID(spellID)
  not not GetSpellInfo(spellName)  > uniqt avec le nom (sinon renvoie l'info de toute façon)

Sort actif uniquement pour le joueur :
  IsPlayerSpell(spellID)


C_Spell.DoesSpellExist(spellID) :
ou   DoesSpellExist(spellID)    :  pour tous les sorts du jeu


## Problèmes ##

  IsSpellKnown(spellID, isPet) :
    ne fonctionne pas si Spell override (Dispel avec talent...)
    Purifier 527, avec le talent, se surcharge en 440006, et IsSpellKnown(527) renvoie false..

  >>> IsSpellKnownOrOverridesKnown(spellID, isPet) ?

  IsUsableSpell(spellName) :
    false avec un talent inactif (true si actif)
    mais true avec un pet inactif ?

  C_SpellBook.IsSpellDisabled(spellID) : Ne fonctionne pas (renvoie toujours false?)

  GetMacroInfo:
    toujours utiliser l'ID (souci si le nom de macro est "111")
    y compris pour l'action sur un bouton type macro

]]--
--@end-do-not-package@

local OG = nil;
local O = nil;
local _;

local maxRaid = 40;
local maxPets = 40;
local maxScrollBtn = 34;
local maxColumns = 14;
local maxSpellIcons = 10;

local isLoaded = false;
local isPlayer = false;
local isInit = false;
local isTTreeLoaded = false;
local shouldCallSetUnits = false;
local shouldCallSetPets = false;
local shouldCallSetPlayerPet = false;
local shouldCallSetSpells = false;
local shouldCallSetTalents = false;
local shouldCallSetMacros = false;
local shouldCallSetButtons = false;
local shouldCallRefreshUI = false;
local isSoundPlayed = false;
local isSpellActive = true;
local isLeader = false;
local isRoleSet = false;

local tTicker = 0;
local tDebuff = 0;
local tSound = 0;

SDB_cachePlayerClass = nil;
local sAggroList = nil;
local iGroupSetup = -1;

local cGroups  = { };
local cClasses = { };
local cUnits   = { };
local cPets    = { };

local cSpells = { };
local cSpellName = { };
local cSpellList = nil;
local cSpellDefault = { };
--- string Global: Cache name of spell used for range check
SDB_cacheRangeCheckSpell = nil;
--- table<number, string> Computed cached restricted list of talents id / name (format: {[spellID] = spellName, ..})
local SDB_cacheConfigSpellNames = nil;
--- table<number, boolean> Computed cached list of spec talents status (format: {[spellID] = true|false, ..})
local SDB_cachePlayerTalentsList = {};

local cScrollButtons = nil;
local cRaidicons = {};

local canDebuff = false;
local hasDebuff = false;

local iTotMana = 0;
local iTotHP = 0;
local iTotAFK = 0;
local iTotOFF = 0;
local iTotDead = 0;
local iTotPlayers = 0;
local iTotManaUser = 0;
local iTmp;
local iVehicles = 0;
local iTest = 0;
local iTotRcRdy = 0;
local iTotRcNRdy = 0;
local iTotRcWait = 0;

local cOrderClass = CLASS_SORT_ORDER;
local cOrderGrp   = {1, 2, 3, 4, 5, 6, 7, 8};

local imgSDB        = "Interface\\Icons\\Spell_Holy_LayOnHands";
--local imgIconOn     = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonEnabled";
--local imgIconOff    = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonDisabled";
local imgActionSlot = "Interface/Buttons/UI-Quickslot2";
local imgTarget     = nil;
local imgMenu       = nil;
local imgMissing    = nil;

local DebugChatFrame = DEFAULT_CHAT_FRAME;

local Icons = {
  ["DRUID"]       = "Interface\\AddOns\\SmartDebuff\\Icons\\Druid",
  ["HUNTER"]      = "Interface\\AddOns\\SmartDebuff\\Icons\\Hunter",
  ["MAGE"]        = "Interface\\AddOns\\SmartDebuff\\Icons\\Mage",
  ["PALADIN"]     = "Interface\\AddOns\\SmartDebuff\\Icons\\Paladin",
  ["PRIEST"]      = "Interface\\AddOns\\SmartDebuff\\Icons\\Priest",
  ["ROGUE"]       = "Interface\\AddOns\\SmartDebuff\\Icons\\Rogue",
  ["SHAMAN"]      = "Interface\\AddOns\\SmartDebuff\\Icons\\Shaman",
  ["WARLOCK"]     = "Interface\\AddOns\\SmartDebuff\\Icons\\Warlock",
  ["WARRIOR"]     = "Interface\\AddOns\\SmartDebuff\\Icons\\Warrior",
  ["DEATHKNIGHT"] = "Interface\\AddOns\\SmartDebuff\\Icons\\Deathknight",
  ["MONK"]        = "Interface\\AddOns\\SmartDebuff\\Icons\\Monk",
  ["DEMONHUNTER"] = "Interface\\AddOns\\SmartDebuff\\Icons\\Demonhunter",
  ["EVOKER"] 	  = "Interface\\AddOns\\SmartDebuff\\Icons\\Evoker",
  --["PET"]         = "Interface\\AddOns\\SmartDebuff\\Icons\\HunterPet",
  ["PET"]         = "Interface\\Icons\\spell_nature_spiritwolf", --spell_nature_spiritwolf --Ability_Tracking
  ["ROLE"]        = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
  ["CLASSES"]     = "Interface\\WorldStateFrame\\Icons-Classes",
};

local IconCoords = {
  ["WARRIOR"] = { 0.00, 0.25, 0.00, 0.25 },
  ["MAGE"] = { 0.25, 0.50, 0.00, 0.25 },
  ["ROGUE"] = { 0.50, 0.75, 0.00, 0.25 },
  ["DRUID"] = { 0.75, 1.00, 0.00, 0.25 },
  ["HUNTER"] = { 0.00, 0.25, 0.25, 0.50 },
  ["SHAMAN"] = { 0.25, 0.50, 0.25, 0.50 },
  ["PRIEST"] = { 0.50, 0.75, 0.25, 0.50 },
  ["WARLOCK"] = { 0.75, 1.00, 0.25, 0.50 },
  ["PALADIN"] = { 0.00, 0.25, 0.50, 0.75 },
  ["DEATHKNIGHT"] = { 0.25, 0.50, 0.50, 0.75 },
  ["MONK"] = { 0.50, 0.75, 0.50, 0.75 },
  ["DEMONHUNTER"] = { 0.75, 1.00, 0.50, 0.75 },
  ["EVOKER"] = { 0.00, 0.25, 0.75, 1.00 },
  ["PET"] = { 0.08, 0.92, 0.08, 0.92},
  ["TANK"] = { 0.0, 19/64, 22/64, 41/64 },
  ["HEALER"] = { 20/64, 39/64, 1/64, 20/64 },
  ["DAMAGER"] = { 20/64, 39/64, 22/64, 41/64 },
  ["NONE"] = { 20/64, 39/64, 22/64, 41/64 },
};

local AnchorPos = {"TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "CENTER"};

-- Popup
StaticPopupDialogs["SMARTDEBUFF_RESET_KEYS"] = {
  text = SMARTDEBUFF_OFT_RESET_KEYS,
  button1 = YES,
  button2 = NO,
  OnAccept = function() SMARTDEBUFF_SetDefaultKeys(true) end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
}


-- Rounds a number to the given number of decimal places.
local r_mult;
local function Round(num, idp)
  r_mult = 10^(idp or 0);
  return math.floor(num * r_mult + 0.5) / r_mult;
end

-- Returns a chat color code string
local function BCC(r, g, b)
  return string.format("|cff%02x%02x%02x", (r*255), (g*255), (b*255));
end

local BL  = BCC(0.1, 0.1, 1.0);
local BLD = BCC(0.0, 0.0, 0.7);
local BLL = BCC(0.5, 0.8, 1.0);
local GR  = BCC(0.1, 1.0, 0.1);
local GRD = BCC(0.0, 0.7, 0.0);
local GRL = BCC(0.25, 0.75, 0.25);
local RD  = BCC(1.0, 0.1, 0.1);
local RDD = BCC(0.7, 0.0, 0.0);
local RDL = BCC(1.0, 0.3, 0.3);
local YL  = BCC(1.0, 1.0, 0.0);
local YLD = BCC(0.7, 0.7, 0.0);
local YLL = BCC(1.0, 1.0, 0.5);
local OR  = BCC(1.0, 0.5, 0.25);
local ORD = BCC(0.7, 0.5, 0.0);
local ORL = BCC(1.0, 0.6, 0.3);
local WH  = BCC(1.0, 1.0, 1.0);
local CY  = BCC(0.5, 1.0, 1.0);
local GY  = BCC(0.5, 0.5, 0.5);
local GYD = BCC(0.35, 0.35, 0.35);
local GYL = BCC(0.65, 0.65, 0.65);

-- Global update: Sounds
if SMARTDEBUFF_DISABLED_SOUNDS then
  for key=1, #SMARTDEBUFF_SOUNDS do
    if string.find(SMARTDEBUFF_DISABLED_SOUNDS, "\n"..SMARTDEBUFF_SOUNDS[key][1].."\n") then
      SMARTDEBUFF_SOUNDS[key][1] = RD..SMARTDEBUFF_SOUNDS[key][1].."|r"
    end
  end
end


local vertexColors = {
  Enabled = { 1, 1, 1, 1},
  Disabled = {.5, .5, .5, 1},
  NotFound = {.6, .6, .6, 1},
};

-- Reorders values in the table
local function TableReorder(t, i, n)
  if (t and t[i]) then
    local s = t[i];
    table.remove(t, i);
    if (i + n < 1) then
      table.insert(t, 1, s);
    elseif (i + n > #t) then
      table.insert(t, s);
    else
      table.insert(t, i + n, s);
    end
  end
end

-- Returns "" instead of nil
local function ChkS(text)
  return text or "";
end

-- Set texture on the key binding options frame
local function SetATexture(btn, texture)
  if (not texture) then
    btn:SetNormalTexture(imgActionSlot);
  else
    btn:SetNormalTexture(texture);
  end
  if (not texture or texture == imgActionSlot) then
    btn:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8);
  else
    btn:GetNormalTexture():SetTexCoord(0, 1, 0, 1);
  end
end

-- Get spell cooldown
local function GetSpellCD(spell)
  if (not spell) then return -1 end
  local start, duration, enabled = GetSpellCooldown(spell);
  if (start and start > 0 and duration > 1.5 and enabled > 0) then
    return (start + duration) - GetTime();
  end
  return -1;
end

-- Get normal/target mode by button index
local function GetActionMode(iAction)
  local m, i = 1, iAction;
  if (i > 12) then
    m = 2;
    i = i - 12;
  end
  return m, i;
end

--- Get action info on an specific button
--- @param mode number Column to get
--- @param i number Row index of the button
--- @param extractDataOnly? boolean true if you want raw data
--- @return string type
--- @return string name
--- @return string rank
--- @return number spellID
--- @return string link
local function GetActionKeyInfo(mode, i, extractDataOnly)
  local aType, aName, aRank, aId, aLink = nil, nil, nil, nil, nil;
  if (O.Keys[mode] and SMARTDEBUFF_ORDER_KEYS[i] and O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]]) then
    aType = O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][1];
    if (aType) then
      aName = O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][2];
      if (aName) then
        aRank = O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][3];
        aId   = O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][4];
        aLink = O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][5];
        if (extractDataOnly) then
          return aType, aName, aRank, aId, aLink;
        end

        SMARTDEBUFF_AddMsgD("ActionKeyInfo"..i.." "..aType.." = "..ChkS(aId)..",  Name = "..ChkS(aName) ); -- ..", Link = "..ChkS(aLink));

        if (aType == "spell" or aType == "petaction") then
          -- local aId = select(7, GetSpellInfo(aName)) or aId; -- peut etre nécessaire un jour où ils auront des sorts et talents nommés à l'identique
          -- O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][4] = aId;
          -- SMARTDEBUFF_AddMsgD("ActionKeyInfo spell = "..ChkS(aId)..",  Name = "..ChkS(aName)..", Type = "..ChkS(aType)..", Link = "..ChkS(aLink));
          if (not aLink) then
            O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][5] = GetSpellLink(aName);
          end
        elseif (aType == "item") then
          -- Item, refresh missing link (once cached)
          if (not aLink) then
            _, aLink = C_Item.GetItemInfo(aId);
            O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][5] = aLink;
          end
        elseif (aType == "macro") then
          -- Macros: rewrite Name, Index, and Icon(aLink) on every check
          local aId = SDB_GetMacroIndex(aName, aId, aLink);
          if (aId > 0) then
            -- Macro found
            aName, aLink = GetMacroInfo(aId);
            O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][2] = aName;
            O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][4] = aId;
            O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][5] = aLink;
          else
            -- Deleted macro
            O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]] = { };
          end
        elseif (aType == "action") then
          -- aId = SDB_FindSpellID(aName, aRank, BOOKTYPE_PET);
          -- O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][4] = aId;
          -- SMARTDEBUFF_AddMsgD("ActionKeyInfo action = "..ChkS(aId)..", Name = "..ChkS(aName)..", Link = "..ChkS(aLink));
          -- if (not aLink) then
          --   O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][5] = GetSpellLink(aName);
          -- end
        end
      else
        aType = nil;
        O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]] = { };
      end
    end
  end
  return aType, aName, aRank, aId, aLink;
end

-- Set action in info on a specific button
local function SetActionInfo(mode, i, aType, aName, aRank, aId, aLink)
  if (aType) then
    if (O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]]) then
      O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]] = { };
    end
    O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][1] = aType;
    O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][2] = aName;
    O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][3] = aRank;
    O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][4] = aId;
    O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]][5] = aLink;
    --SMARTDEBUFF_AddMsgD("Set Id = "..ChkS(aId)..", Name = "..aName);
  else
    O.Keys[mode][SMARTDEBUFF_ORDER_KEYS[i]] = { };
  end
end

local function LUnitExists(unit)
  if (UnitExists(unit) or iTest > 0) then
    return true;
  end
  return false;
end

local function HideF(f)
  if (f == nil) then return; end
  if (f:IsVisible()) then f:Hide(); end
end

local function ShowF(f)
  if (f == nil) then return; end
  if (not f:IsVisible()) then f:Show(); end
end


-- SMARTDEBUFF_OnLoad
function SMARTDEBUFF_OnLoad(self)
  self:RegisterEvent("ADDON_LOADED");
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  --self:RegisterEvent("WORLD_MAP_UPDATE");
  self:RegisterEvent("UNIT_NAME_UPDATE");

  self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
  self:RegisterEvent("GROUP_ROSTER_UPDATE");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
  self:RegisterEvent("PLAYER_REGEN_DISABLED");

  self:RegisterEvent("UNIT_ENTERED_VEHICLE");
  self:RegisterEvent("UNIT_EXITED_VEHICLE");
  self:RegisterEvent("UNIT_PET");

  self:RegisterEvent("SPELLS_CHANGED");
  self:RegisterEvent("UPDATE_MACROS");
  self:RegisterEvent("BAG_UPDATE");  
  self:RegisterEvent("TRAIT_CONFIG_UPDATED"); -- ! Changement d'un talent / de config sauvée
  self:RegisterEvent("PLAYER_TALENT_UPDATE"); -- ! Changement de spécialisation -- Ne marche pas avec le pretre sacré?
  self:RegisterEvent("CHARACTER_POINTS_CHANGED"); -- Classic version of PLAYER_TALENT_UPDATE

  --One of them allows SmartDebuff to be closed with the Escape key
  tinsert(UISpecialFrames, "SmartDebuffOF");
  UIPanelWindows["SmartDebuffOF"] = nil;

  SlashCmdList["SMARTDEBUFF"] = SMARTDEBUFF_command;
  SLASH_SMARTDEBUFF1 = "/sdb";
  SLASH_SMARTDEBUFF2 = "/smartdebuff";

  SlashCmdList["SMARTDEBUFFOPTIONS"] = SMARTDEBUFF_ToggleOF;
  SLASH_SMARTDEBUFFOPTIONS1 = "/sdbo";
  SLASH_SMARTDEBUFFOPTIONS2 = "/sdbm";

  SlashCmdList["SmartReloadUI"] = function(msg) ReloadUI(); end;
  SLASH_SmartReloadUI1 = "/rui";

	self:SetScript("OnEvent",
    function(self, event, ...)
      SMARTDEBUFF_OnEvent(self, event, ...);
    end
	);

  --DEFAULT_CHAT_FRAME:AddMessage("SDB OnLoad");
end
-- END SMARTDEBUFF_OnLoad


-- SMARTDEBUFF_OnEvent
function SMARTDEBUFF_OnEvent(self, event, ...)
  local arg1 = select(1, ...);
  --DebugChatFrame:AddMessage(event);
  -- or event == "WORLD_MAP_UPDATE"
  if ((event == "UNIT_NAME_UPDATE" and arg1 == "player") or event == "PLAYER_ENTERING_WORLD") then
    isPlayer = true;
    --self:UnRegisterEvent("PLAYER_ENTERING_WORLD");
  elseif(event == "ADDON_LOADED" and arg1 == SMARTDEBUFF_TITLE) then
    isLoaded = true;
    self:UnregisterEvent("ADDON_LOADED");
  end

  if (isLoaded and isPlayer and isTTreeLoaded and not isInit) then
    SMARTDEBUFF_Options_Init();
  end

  if (not isInit or O == nil) then
    return;
  end;

  if (event == "GROUP_ROSTER_UPDATE" or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "PLAYER_ROLES_ASSIGNED") then
    shouldCallSetUnits = true;
    shouldCallSetButtons = true;

  elseif (event == "UNIT_PET") then
    shouldCallSetPlayerPet = true;
    shouldCallSetButtons = true;

  elseif (event == "UNIT_NAME_UPDATE" and string.find(arg1, "pet")) then
    shouldCallSetPets = true;
    shouldCallSetButtons = true;

  elseif (event == "PLAYER_REGEN_DISABLED") then
    SMARTDEBUFF_SetMoving(false);
    SMARTDEBUFF_SetAutoHide(true);
    SMARTDEBUFF_CheckSFButtons(true);
    SMARTDEBUFF_Ticker(true);
    SMARTDEBUFF_CheckIF();

  elseif (event == "PLAYER_REGEN_ENABLED") then
    SMARTDEBUFF_SetAutoHide(false);
    SMARTDEBUFF_CheckSFButtons();
    SMARTDEBUFF_Ticker(true);
    SMARTDEBUFF_CheckIF();

  elseif (event == "BAG_UPDATE") then
    SMARTDEBUFF_AddMsgD(OR.."Event: "..event);
    shouldCallRefreshUI = true;

  elseif (event == "UPDATE_MACROS") then
    SMARTDEBUFF_AddMsgD(OR.."Event: "..event);
    shouldCallSetMacros = true;
    shouldCallSetButtons = true;
    shouldCallRefreshUI = true;

  elseif (event == "SPELLS_CHANGED") then
    SMARTDEBUFF_AddMsgD(OR.."Event: "..event);
    shouldCallSetSpells = true;
    shouldCallSetButtons = true;
    shouldCallRefreshUI = true;
    SMARTDEBUFF_Ticker(false);

  elseif (event == "TRAIT_CONFIG_UPDATED" or event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED") then
    -- Talent changed
    SMARTDEBUFF_AddMsgD(RD.."Event: "..event);
    shouldCallSetTalents = true;
    shouldCallSetSpells = true;
    shouldCallSetButtons = true;
    shouldCallRefreshUI = true;
    SMARTDEBUFF_Ticker(false);
  end

end
-- END SMARTDEBUFF_OnEvent

local ou_time = 0;
function SMARTDEBUFF_OnUpdate(self, elapsed)
  if (isInit) then
    SMARTDEBUFF_Ticker(false);
    SMARTDEBUFF_CheckDebuffs(false);
  else
    ou_time = ou_time + elapsed;
    if (not isTTreeLoaded and ou_time > 0.5) then
      if (C_ClassTalents) then
        -- C_ClassTalents, Since DragonFlight (10)
        if (C_ClassTalents.CanCreateNewConfig()) then
          SMARTDEBUFF_AddMsgD("Talent tree ready ("..ou_time.."sec) -> Init SDB");
          isTTreeLoaded = true;
          SMARTDEBUFF_OnEvent(self, "ONUPDATE");
        end
      else
        -- Classic
        local tName = GetTalentInfo(1, 1); -- Since 6.0 : _, tName = GetTalentInfo(1, 1, 1);  // GetTalentInfoByID?
        if (tName) then
          SMARTDEBUFF_AddMsgD("Talent tree ready ("..ou_time.."sec) -> Init SDB");
          isTTreeLoaded = true;
          SMARTDEBUFF_OnEvent(self, "ONUPDATE");
        end
      end
      ou_time = 0;
    end
  end
end

function SMARTDEBUFF_Ticker(force)
  if (force or GetTime() > tTicker + 1) then
    tTicker = GetTime();

    if ((shouldCallSetPlayerPet or shouldCallSetPets) and not shouldCallSetUnits) then
      if (canDebuff and SMARTDEBUFF_IsVisible()) then
        if (InCombatLockdown()) then
          shouldCallSetUnits = true;
        else
          SMARTDEBUFF_AddMsgD("Unit pet changed");
          if (shouldCallSetPlayerPet) then
            SMARTDEBUFF_CheckWarlockPet();
            shouldCallSetUnits = true;
          else
            SMARTDEBUFF_SetPetButtons(true);
          end
        end
      end
      shouldCallSetPlayerPet = false;
      shouldCallSetPets = false;
    end

    if (shouldCallSetUnits and not InCombatLockdown()) then
      shouldCallSetUnits = false;
      SMARTDEBUFF_SetUnits();
    end

    if (shouldCallSetMacros and not InCombatLockdown()) then
      shouldCallSetMacros = false;
      SMARTDEBUFF_RebuildMacrosInfo();
    end

    if (shouldCallSetTalents and not InCombatLockdown()) then
      shouldCallSetTalents = false;
      SDB_cachePlayerTalentsList = SDB_GetTalentsList();
    end

    if (shouldCallSetSpells and not InCombatLockdown()) then
      shouldCallSetSpells = false;
      SMARTDEBUFF_SetSpells();
      SMARTDEBUFF_CheckForSpellUpgrade();
    end

    if (shouldCallSetButtons) then
      shouldCallSetButtons = false;
      SMARTDEBUFF_SetButtons();
    end

    if (shouldCallRefreshUI) then
      shouldCallRefreshUI = false;
      SMARTDEBUFF_RefreshAOFKeys();
    end

  end
end

function SMARTDEBUFF_IsVisible()
  if (SmartDebuffSF:IsVisible() or O.AutoHide) then
    return true;
  end
  return false;
end



--- @param msg string Message to display
--- @param force? boolean if true, will ignore setting disabled and force display
function SMARTDEBUFF_AddMsg(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or O.ShowMsgNormal)) then
    DEFAULT_CHAT_FRAME:AddMessage(YLL .. msg .. "|r");
  end
end

--- @param msg string Message to display
--- @param force? boolean if true, will ignore setting disabled and force display
function SMARTDEBUFF_AddMsgErr(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or O.ShowMsgError)) then
    DEFAULT_CHAT_FRAME:AddMessage(RDL .. SMARTDEBUFF_TITLE .. ": " .. msg .. "|r");
  end
end

--- @param msg string Message to display
--- @param force? boolean if true, will ignore setting disabled and force display
function SMARTDEBUFF_AddMsgWarn(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or O.ShowMsgWarning)) then
    DEFAULT_CHAT_FRAME:AddMessage(CY .. msg .. "|r");
  end
end

--- @param msg string Message to display
--- @param r? number red component (from 0 to 1)
--- @param g? number green component (from 0 to 1)
--- @param b? number blue component (from 0 to 1)
function SMARTDEBUFF_AddMsgD(msg, r, g, b)
  if (DEFAULT_CHAT_FRAME and O and O.Debug) then
    if (r == nil) then r = 0.5; end
    if (g == nil) then g = 0.8; end
    if (b == nil) then b = 1; end
    DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
  end
end

function SMARTDEBUFF_CheckWarlockPet()
  if (SDB_cachePlayerClass == "WARLOCK") then
    isSpellActive = false;
    if (UnitExists("pet")) then
      local ucf = UnitCreatureFamily("pet");
      if (ucf == SMARTDEBUFF_IMP) then
        isSpellActive = true;
        SMARTDEBUFF_AddMsgD("Warlock debuff pet found: " .. SMARTDEBUFF_IMP);
      end
      SMARTDEBUFF_RefreshAOFKeys();
    end
  end
end


-- Creates an array of units
function SMARTDEBUFF_SetUnits()
  if (not isInit or InCombatLockdown()) then
    shouldCallSetUnits = true;
    return;
  end

  local i = 0;
  local n = 0;
  local j = 0;
  local s = nil;
  local psg = 0;
  local b = false;

  -- player
  -- pet
  -- party1-4
  -- partypet1-4
  -- raid1-40
  -- raidpet1-40

  if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
    isLeader = true;
  else
    isLeader = false;
  end

  iGroupSetup = -1;
  if (IsInRaid() or iTest > 0) then
    iGroupSetup = 3;
  elseif (GetNumSubgroupMembers() ~= 0) then
    iGroupSetup = 2;
  else
    iGroupSetup = 1;
  end

  cGroups  = { };
  cClasses = { };
  cPets    = { };
  cUnits   = { };

  isRoleSet = true;

  -- Raid Setup
  if (iGroupSetup == 3) then
    local name, rank, subgroup, level, class, classeng, zone, online, isDead;

    for n = 1, maxRaid, 1 do
      name, rank, subgroup, level, class, classeng, zone, online, isDead = GetRaidRosterInfo(n);
      if (name or (iTest > 0 and n <= iTest)) then

        if (iTest > 0) then
          SMARTDEBUFF_AddUnit("raid", n, math.ceil(n / 5), cOrderClass[math.fmod(n - 1, #cOrderClass) + 1]);
        else
          SMARTDEBUFF_AddUnit("raid", n, subgroup, classeng);
        end

        --SmartBuff_AddToUnitList(1, sRUnit, subgroup);
        --SmartBuff_AddToUnitList(2, sRUnit, subgroup);
      end

    end --end for
    SMARTDEBUFF_AddMsgD("Raid Unit-Setup finished");

  -- Party Setup
  elseif (iGroupSetup == 2) then
    SMARTDEBUFF_AddUnit("player", 0, 1, SDB_cachePlayerClass);
    for j = 1, 4, 1 do
      SMARTDEBUFF_AddUnit("party", j, 1);
      --SmartBuff_AddToUnitList(1, "party"..j, 1);
      --SmartBuff_AddToUnitList(2, "party"..j, 1);
    end
    SMARTDEBUFF_AddMsgD("Party Unit-Setup finished");

  -- Solo Setup
  else
    SMARTDEBUFF_AddUnit("player", 0, 1, SDB_cachePlayerClass);
    SMARTDEBUFF_AddMsgD("Solo Unit-Setup finished");
  end

  SMARTDEBUFF_CheckWarlockPet();
  SMARTDEBUFF_SetButtons();
  SMARTDEBUFF_CheckIF();
end

function SMARTDEBUFF_AddUnit(unit, i, sg, uc)
  local u = unit;
  local up = "pet";
  local uiv = false;

  if (unit ~= "player") then
    u = unit..i;
    up = unit.."pet"..i;
  end

  if (LUnitExists(u)) then
    if (isRoleSet and UnitGroupRolesAssigned(u) == "NONE") then
      isRoleSet = false;
    end

    if (uc == nil) then
      _, uc = UnitClass(u);
    end
    if (UnitInVehicle(u) or UnitHasVehicleUI(u) or iTest > 0) then
      uiv = true;
    else
      uiv = false;
    end

    if (not cUnits[u]) then
      cUnits[u] = { };
    end

    cUnits[u].Subgroup = sg;
    cUnits[u].Class = uc;

    if (not cGroups[sg]) then
      cGroups[sg] = { };
    end
    if (not cGroups[sg][i]) then
      cGroups[sg][i] = { };
    end
    cGroups[sg][i].Unit = u;
    cGroups[sg][i].Subgroup = sg;
    cGroups[sg][i].UnitVehicle = up;
    cGroups[sg][i].InVehicle = uiv;
    --SMARTDEBUFF_AddMsgD("Unit to subgroup added: " .. UnitName(u) .. ", " .. u .. ", " .. sg .. ", " .. tostring(uiv));
    --SMARTDEBUFF_AddMsgD("Unit to subgroup added: "..u..", "..sg..", "..tostring(uiv));

    if (uc) then
      if (not cClasses[uc]) then
        cClasses[uc] = { };
      end
      if (not cClasses[uc][i]) then
        cClasses[uc][i] = { };
      end
      cClasses[uc][i].Unit = u;
      cClasses[uc][i].Subgroup = sg;
      cClasses[uc][i].UnitVehicle = up;
      cClasses[uc][i].InVehicle = uiv;
      --SMARTDEBUFF_AddMsgD("Unit to class added: " .. UnitName(u) .. ", " .. u .. ", " .. sg);
      --SMARTDEBUFF_AddMsgD("Unit to class added: "..u..", "..sg);

      if (uc == "HUNTER" or uc == "WARLOCK" or uc == "DEATHKNIGHT" or uc == "MAGE") then
        if (not cPets[i]) then
          cPets[i] = { };
        end
        cPets[i].Unit = up;
        cPets[i].Subgroup = sg;
        cPets[i].Owner = u;
        cPets[i].OwnerClass = uc;
        cPets[i].OwnerInVehicle = uiv;
        if (UnitName(up)) then
          SMARTDEBUFF_AddMsgD("Pet added: " .. UnitName(up) .. ", " .. up .. ", " .. sg);
        end
      end
    end

  end
end

-- END SMARTDEBUFF_SetUnits


-- Helper functions ---------------------------------------------------------------------------------------
function SMARTDEBUFF_toggleBool(b, msg)
  if (not b or b == nil) then
    b = true;
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. GR .. "On");
  else
    b = false
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. RD .."Off");
  end
  return b;
end

function SMARTDEBUFF_BoolState(b, msg)
  if (b) then
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. GR .. "On");
  else
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. RD .."Off");
  end
end

function SMARTDEBUFF_Split(msg, char)
  local arr = { };
  while (string.find(msg, char)) do
    local iStart, iEnd = string.find(msg, char);
    tinsert(arr, strsub(msg, 1, iStart - 1));
    msg = strsub(msg, iEnd + 1, strlen(msg));
  end
  if (strlen(msg) > 0) then
    tinsert(arr, msg);
  end
  return arr;
end

function SmartDebuffOFSlider_OnLoad(self, low, high, step)
  --[[
  if (self:GetOrientation() ~= "VERTICAL") then
    _G[self:GetName().."Low"]:SetText(low);
  else
    _G[self:GetName().."Low"]:SetText("");
  end
  _G[self:GetName().."High"]:SetText(high);
  ]]--
  _G[self:GetName().."Low"]:SetText("");
  _G[self:GetName().."High"]:SetText("");
  self:SetMinMaxValues(low, high);
  self:SetValueStep(step);
  self:SetStepsPerPage(step);
  if (BackdropTemplateMixin) then  BackdropTemplateMixin.OnBackdropLoaded(self); end

  if (step < 1) then return; end

  self.GetValueBase = self.GetValue;
  self.GetValue = function()
    local n = self:GetValueBase();
    if (n) then
      local r = Round(n);
      if (r ~= n) then
        self:SetValue(n);
      end
      return r;
    end
    return low;
  end;
end

function SMARTDEBUFF_HideAllButThis(self)
  local elements = {SmartDebuffAOFKeys, SmartDebuffClassOrder, SmartDebuffNRDebuffs, SmartDebuffSpellGuard, SmartDebuffSounds, SmartDebuffColors}

  for _, element in ipairs(elements) do
    if self ~= element and element:IsVisible() then
      element:Hide()
    end
  end
end

-- IsFeignDeath(unit)
local ifd_name, ifd_icon, ifd_i;
function SMARTDEBUFF_IsFeignDeath(unit)
  --return UnitIsFeignDeath(unit); -- works only for members in own group
  ifd_i = 0;
  while (true) do
    ifd_i = ifd_i + 1;
    ifd_name, ifd_icon = UnitBuff(unit, ifd_i);
    -- SMARTDEBUFF_AddMsgD("Check for FeignDeath Icon");
    if (ifd_icon) then
      if (ifd_icon == 132293) then
        return true;
      end
    else
      break;
    end
  end
  return false;
end
-- END SMARTDEBUFF_IsFeignDeath

function SDB_GetSpellInfo(spellnameOrId)
  if (C_SpellBook.GetSpellInfo and type(spellnameOrId) == "number") then
    return C_SpellBook.GetSpellInfo(spellnameOrId)
  else
    local spellName, _, iconID, _, _, _, spellID = GetSpellInfo(spellnameOrId);
    if (spellName) then
      return {
            name = spellName,
            spellID = spellID,
            iconID = iconID,
          };
    else
      return nil;
    end
  end
end


--@do-not-package@
--[[
-- Search Spell in spellbook : returns spellId, bookIndex, book
--- @param spellNameOrID string|number
--- @param rank string
--- @param book string
--- @return number spellID
--- @return number bookIndex
--- @return string book
function SDB_FindSpellInBook(spellNameOrID, rank, book)
  if (type(spellNameOrID) == "number") then
    id, index, book = spellNameOrID, FindSpellBookSlotBySpellID(spellNameOrID), book;
    if not id then
      id, index, book = spellNameOrID, FindSpellBookSlotBySpellID(spellNameOrID, true), book;
    end
    return id, index, book;
    -- spellNameOrID = SDB_GetSpellInfo(spellNameOrID).name;
  end
  if (not spellNameOrID) then
    return nil;
  end

  if (not book) then
    book = BOOKTYPE_SPELL;
  end

  local i = 0;
  local nSpells = 0;
  local id, index = nil, nil;
  local spellN, isPassive, isKnown, skillType;

  for i = 1, GetNumSpellTabs() do
    local name, _, _, n = GetSpellTabInfo(i);
    nSpells = nSpells + n;
  end

  -- Inverted: find better rank
  i = nSpells - 1;
  while (i >= nSpells) do
    i = i - 1;
    spellN = GetSpellBookItemName(i, book);
    -- print(spellN, i, book)
    if (spellN == spellNameOrID) then
      _, id = GetSpellBookItemInfo(i, book);
      index = i;
      break;
    end
  end

  if (index) then
    return id, index, book;
  end
  return nil;
end

-- Search Spell ID in spellbook - necessary for pets
function SDB_FindSpellID(spellname, rank, book)
  local spellId, bookIndex, book = SDB_FindSpellInBook(spellname, rank, book);
  local skillType;
  if (bookIndex) then
    if (IsPassiveSpell(bookIndex, book)) then return nil; end

    skillType, spellId = GetSpellBookItemInfo(bookIndex, book);
    if (skillType == nil or spellId == nil) then return nil; end
    if (skillType == "FUTURESPELL" or not IsSpellKnown(spellId)) then return nil; end
  end

  return spellId;
end
-- END SDB_FindSpellID
]]--
--@end-do-not-package@

-- Return if spell is passive, by ID
--- @param spellID number
--- @param book string
--- @return boolean|nil isPassiveSpell true if spell is passive, or false, nil if not found
function SDB_IsPassiveSpell(spellID, book)
  if (C_SpellBook.GetSpellInfo) then
    -- IsPassiveSpell takes spellID, Since DragonFlight (10)
    return IsPassiveSpell(spellID)
  else
    -- Classic (was using bookIndex)
    return IsPassiveSpell(FindSpellBookSlotBySpellID(spellID, book == BOOKTYPE_PET), book);
  end
end


function SMARTDEBUFF_SetSpells()
  canDebuff = true;
  local sName, sSpellInfo = nil, nil;
  cSpellName = { }; -- SpellGuard
  cSpellList = { };
  cSpellDefault = { };
  cSpellDefault["L"] = { };
  cSpellDefault["M"] = { };
  cSpellDefault["R"] = { };
  cSpellDefault["AL"] = { };
  cSpellDefault["AM"] = { };
  cSpellDefault["AR"] = { };
  SDB_cacheRangeCheckSpell = nil; -- reset: range detection requires readable spell/talent

  SMARTDEBUFF_AddMsgD("--- Smart Debuff Set spells --- "..SDB_cachePlayerClass);
  -- Add Dispels abilities to L
  if (SDB_cachePlayerClass and SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass] and #SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass] > 0) then
      sName = nil;
      SMARTDEBUFF_AddMsgD("Checking for class dispels...");
      -- 1. Check for useable dispel, and enhancement
      for _, val in ipairs(SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass]) do
        sSpellInfo = SDB_GetSpellInfo(val.Spell_ID);
        if (sSpellInfo) then
          -- Cache range detection dispel if possible (use base spell to ensure detection)
          if not SDB_cacheRangeCheckSpell and SDB_IsBaseSpellInRange(sSpellInfo.name, "player") == 1 then
            SDB_cacheRangeCheckSpell = SDB_GetBaseSpellInfo(sSpellInfo.spellID);
            SMARTDEBUFF_AddMsgD("Range detection will use: "..SDB_cacheRangeCheckSpell);
          end

          -- Dispel found and available for current spec
          if FindSpellBookSlotBySpellID(val.Spell_ID) then
            sName = sSpellInfo.name;
            cSpellList[sName] = val.Spell_List;
            SMARTDEBUFF_AddMsgD("Dispel found: " .. sName.." - "..strjoin(" ",unpack(cSpellList[sName])));
            if (val.Improved_Talent and SDB_IsSpellTalented(val.Improved_Talent)) then
              cSpellList[sName] = val.Improved_Spell_List;
              SMARTDEBUFF_AddMsgD("Dispel improved! - : "..strjoin(" ",unpack(cSpellList[sName])));
            end
            cSpellDefault["L"] = {_, val.Spell_Type or "spell", sName, val.Spell_ID};
          end
        end
      end
      -- 2. No usable dispel found:
      if sName == nil then
        -- 2a. select first (inactive) talent for current spec
        for _, val in ipairs(SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass]) do
          if SDB_IsSpellTalentExists(val.Spell_ID) then
            sSpellInfo = SDB_GetSpellInfo(val.Spell_ID);
            sName = sSpellInfo.name;
            cSpellDefault["L"] = {_, val.Spell_Type or "spell", sSpellInfo.name, sSpellInfo.spellID};
            cSpellList[sSpellInfo.name] = {};
            SMARTDEBUFF_AddMsgD("No dispel found, but talent found: " .. sSpellInfo.name);
            break;
          end
        end
        -- 3. Fallback: first class dispel in the list (avoid OnlyIfUsable if possible)
        if sName == nil then
          local val = SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass][1];
          for _, searchForUsableVal in ipairs(SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass]) do
            if not searchForUsableVal.OnlyIfUsable then
              val = searchForUsableVal;
              break;
            end
          end
          sSpellInfo = SDB_GetSpellInfo(val.Spell_ID);
          if (sSpellInfo) then
            cSpellDefault["L"] = {_, val.Spell_Type or "spell", sSpellInfo.name, sSpellInfo.spellID};
            cSpellList[sSpellInfo.name] = {};
            SMARTDEBUFF_AddMsgD("No dispel found, forced to: " .. sSpellInfo.name);
          end
        end
      end
  end

  -- Then Add other skills to other buttons
  --  If multiple lines for same button, first spell will only be overloaded if the following spell exists
  if (SDB_cachePlayerClass and SMARTDEBUFF_CLASS_SKILLS_LIST_ID[SDB_cachePlayerClass]) then
    SMARTDEBUFF_AddMsgD("Checking for other class spells...");
    for _, val in ipairs(SMARTDEBUFF_CLASS_SKILLS_LIST_ID[SDB_cachePlayerClass]) do
      sSpellInfo = SDB_GetSpellInfo(val.Spell_ID);

      if (sSpellInfo) then
        local hasSpell = not not FindSpellBookSlotBySpellID(val.Spell_ID);
        if (not cSpellDefault[val.Button] or #cSpellDefault[val.Button] == 0 or hasSpell) then
          cSpellList[sSpellInfo.name] = hasSpell and val.Types or {};
          SMARTDEBUFF_AddMsgD("Class spell added [" ..val.Button.. "]: ".. sSpellInfo.name.." - "..strjoin(" ",unpack(cSpellList[sSpellInfo.name])));
          cSpellDefault[val.Button] = {_, val.Spell_Type or "spell", sSpellInfo.name, sSpellInfo.spellID};
        end

        -- Cache range detection spell if not already done
        if not SDB_cacheRangeCheckSpell and SDB_IsBaseSpellInRange(sSpellInfo.name, "player") == 1 then
          SDB_cacheRangeCheckSpell = SDB_GetBaseSpellInfo(sSpellInfo.spellID);
          SMARTDEBUFF_AddMsgD("Range detection fallback: "..SDB_cacheRangeCheckSpell);
        end
      elseif (val.Spell_Type == "item") then
        -- special: item (Warlock stone)
        local itemName = GetItemInfo(val.Spell_ID);
        SMARTDEBUFF_AddMsgD("Item added [" ..val.Button.. "]: ".. ChkS(itemName) .." - "..val.Spell_ID);
        cSpellDefault[val.Button] = {_, val.Spell_Type, itemName, val.Spell_ID};
      elseif ((val.Spell_Type or "spell") ~= "spell") then
        -- special: other (?for further use?)
        SMARTDEBUFF_AddMsgD("Other added [" ..val.Button.. "]: ".. val.Spell_ID .." - "..val.Spell_ID);
        cSpellDefault[val.Button] = {_, val.Spell_Type, val.Spell_ID, val.Spell_ID};
      end
    end
  end
  SMARTDEBUFF_AddMsgD("--- END Set spells --- ");
end

--- @param spellID number Id of the spell or talent to check
--- @return boolean isSpellTalented returns true if talent is available and talented
function SDB_IsSpellTalented(spellID)
  return not not SDB_cachePlayerTalentsList[spellID];
end

--- @param spellID number Id of the spell or talent to check
--- @return boolean isSpellTalentExists returns true if talent is available in current spec (even if not talented)
function SDB_IsSpellTalentExists(spellID)
  return SDB_cachePlayerTalentsList[spellID] ~= nil;
end

--- Get the list of spells/talents id/name to check for dispel
--- @return table<number, string>|nil spellsIdNames table containing list of spells/talents id/name to check for dispel { [spellId]: spellName,.. }, or nil if none found
function SDB_GetConfigSpellNames()
  local list = {};
  if (not SDB_cachePlayerClass) then
    return nil;
  end
  SMARTDEBUFF_AddMsgD("Caching talents/spells id/name filter...");
  if (SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass]) then
    for _, val in ipairs(SMARTDEBUFF_CLASS_DISPELS_LIST_ID[SDB_cachePlayerClass]) do
      list[val.Spell_ID] = GetSpellInfo(val.Spell_ID);
      SMARTDEBUFF_AddMsgD(" - Spell added to filter: "..val.Spell_ID.. ": "..list[val.Spell_ID]);
      if (val.Improved_Talent ~= nil) then
        list[val.Improved_Talent] = GetSpellInfo(val.Improved_Talent);
        SMARTDEBUFF_AddMsgD(" - Talent added to filter: "..val.Improved_Talent.. ": "..list[val.Improved_Talent]);
      end
    end
  end
  if (SMARTDEBUFF_CLASS_SKILLS_LIST_ID[SDB_cachePlayerClass]) then
    for _, val in ipairs(SMARTDEBUFF_CLASS_SKILLS_LIST_ID[SDB_cachePlayerClass]) do
      list[val.Spell_ID] = GetSpellInfo(val.Spell_ID);
      SMARTDEBUFF_AddMsgD(" - Spell added to filter: "..val.Spell_ID.. ": "..ChkS(list[val.Spell_ID]));
    end
  end
  return list;
end

--- Fallback used by SDB_GetTalentsList, uses **GetTalentInfo** *(with no spell ID...)*
--- ! No spellID in API: I will detect at least configured talents/spells, found in SDB_cacheConfigSpellNames
local function SDB_GetTalentsList_Fallback_Vanilla()
  local list = {};
  local testTalentInfo = GetTalentInfo(1,1);
    if (not testTalentInfo) then isTTreeLoaded = false; return {}; end
    SDB_cacheConfigSpellNames = SDB_cacheConfigSpellNames or SDB_GetConfigSpellNames();
    if (not SDB_cacheConfigSpellNames) then return {}; end

    local numTabs = GetNumTalentTabs();
    for t = 1, numTabs do
      local numTalents = GetNumTalents(t);
      for i = 1, numTalents do
        local tName, _, _, _, tPoints = GetTalentInfo(t, i);
        for talId, talName in pairs(SDB_cacheConfigSpellNames) do
          if (tName == talName) then
            list[talId] = (tPoints > 0) or false;
          end
        end
      end
    end
    return list;
end

--- Fallback used by SDB_GetTalentsList, uses **GetTalentInfoBySpecialization** *(since WoD, until DF)*
local function SDB_GetTalentsList_Fallback_WoD()
  local list = {}
  for specIndex = 1, GetNumSpecializations() do
    -- local specId = GetSpecializationInfo(specIndex)
    for tier = 1, MAX_TALENT_TIERS do
        for column = 1, NUM_TALENT_COLUMNS do
            -- local talentID, name, texture, selected, available, spellID, unknown, row, column, known, grantedByAura = GetTalentInfoBySpecialization(specIndex, tier, column)
            local _, _, _, _, _, spellID, _, _, _, known, _ = GetTalentInfoBySpecialization(specIndex, tier, column)
            list[spellID] = known;
        end
    end
  end
  return list;
end

--- @return table<number, boolean> talentsList List of current talents ID (all Wow versions), with activation state { [spellID]: true|false, .. }
function SDB_GetTalentsList()
  local list = {}

  if (not isTTreeLoaded) then
    return {};
  end

  -- C_ClassTalents, Since DragonFlight (10)
  if not C_ClassTalents then
    -- Classic
    if (GetTalentInfoBySpecialization) then
      return SDB_GetTalentsList_Fallback_WoD();
    else
      return SDB_GetTalentsList_Fallback_Vanilla();
    end
  end

  -- Retail
  local configID = C_ClassTalents.GetActiveConfigID()
  if configID == nil then isTTreeLoaded = false; return {}; end

  local configInfo = C_Traits.GetConfigInfo(configID)
  if configInfo == nil then isTTreeLoaded = false; return {}; end

  for _, treeID in ipairs(configInfo.treeIDs) do -- in the context of talent trees, there is only 1 treeID
      local nodes = C_Traits.GetTreeNodes(treeID)
      for i, nodeID in ipairs(nodes) do
          local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
          local activeSpellsID = {};
          for _, entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
            local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
            if entryInfo and entryInfo.definitionID then
                local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                activeSpellsID[definitionInfo.spellID] = true;
            end
          end
          for _, entryID in ipairs(nodeInfo.entryIDs) do -- each node can have multiple entries (e.g. choice nodes have 2)
              local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
              if entryInfo and entryInfo.definitionID then
                  local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                  if definitionInfo.spellID then
                      --table.insert(list, definitionInfo.spellID)
                      list[definitionInfo.spellID] = activeSpellsID[definitionInfo.spellID] or false;
                  end
              end
          end
      end
  end
  return list
end

--- GetSpellInfo of spell or baseSpell if found
--- @param spellNameOrId number|string Id or name of the spell to check
--- @return string? name 
--- @return string? rank 
--- @return number? icon
--- @return number? castTime
--- @return number? minRange 
--- @return number? maxRange 
--- @return number? spellID 
--- @return number? originalIcon 
function SDB_GetBaseSpellInfo(spellNameOrId)
  local spellId = type(spellNameOrId) == "number" and spellNameOrId or select(7,GetSpellInfo(spellNameOrId));
  if not spellId then
    return nil
  end;
  local baseSpellId = FindBaseSpellByID(spellId);
  return GetSpellInfo(baseSpellId);
end

--- @return boolean|nil isBaseSpellInRange returns if base spell in range, or nil if no spell found
function SDB_IsBaseSpellInRange(spellNameOrId, unit)
  local spellName, _, _, _, _, _, spellId = GetSpellInfo(spellNameOrId);
  if not spellId then
    return nil
  end;
  local baseSpellId = FindBaseSpellByID(spellId);
  if (spellId == baseSpellId) then
    return IsSpellInRange(spellName, unit);
  else
    return IsSpellInRange(GetSpellInfo(baseSpellId), unit);
  end
end

-- Init the SmartDebuff variables ---------------------------------------------------------------------------------------
function SMARTDEBUFF_Options_Init()
  if (isInit or InCombatLockdown()) then return; end

  SMARTDEBUFF_AddMsgD("--- Smart Debuff Options Init --- ");

  local b = false;
  local s, t;
  _, SDB_cachePlayerClass = UnitClass("player");

  -- Cache SpellID List for current spec
  SDB_cachePlayerTalentsList = SDB_GetTalentsList();

  SMARTDEBUFF_SetSpells();

  if (not SMARTDEBUFF_Options) then SMARTDEBUFF_Options = { }; end
  O = SMARTDEBUFF_Options;
  if (O.SFPosX == nil) then O.SFPosX = 400; end
  if (O.SFPosY == nil) then O.SFPosY = -300; end
  if (O.SFPosP == nil) then O.SFPosP = "TOPLEFT"; end
  if (O.SFPosRP == nil) then O.SFPosRP = "TOPLEFT"; end

  if (O.OrderClass == nil) then SMARTDEBUFF_SetDefaultClassOrder(); end
  for _, s in ipairs(cOrderClass) do
    b = false;
    for _, t in ipairs(O.OrderClass) do
      if (s == t) then
        b = true;
      end
    end
    if (not b) then
      table.insert(O.OrderClass, s);
    end
  end

  if (O.OrderGrp == nil) then  O.OrderGrp = cOrderGrp; end

  if (O.Toggle == nil) then  O.Toggle = true; end
  if (O.ShowSF == nil) then O.ShowSF = true; end
  if (O.ShowIF == nil) then O.ShowIF = true; end
  if (O.ShowPets == nil) then O.ShowPets = not SMARTDEBUFF_IS_RETAIL; end
  if (O.ShowPetsWL == nil) then O.ShowPetsWL = O.ShowPets; end
  if (O.ShowPetsDK == nil) then O.ShowPetsDK = O.ShowPets; end

  if (O.ShowClassColors == nil) then O.ShowClassColors = true; end
  if (O.SortedByClass == nil) then O.SortedByClass = true; end
  if (O.SortedByRole == nil) then O.SortedByRole = false; end
  if (O.ShowLR == nil) then O.ShowLR = true; end

  if (O.DebuffGrp == nil) then O.DebuffGrp = {true, true, true, true, true, true, true, true}; end
  if (O.DebuffClasses == nil) then O.DebuffClasses = {}; end
  for _, class in ipairs(CLASS_SORT_ORDER) do
    if (O.DebuffClasses[class] == nil) then O.DebuffClasses[class] = true; end;
  end;

  if (O.ANormal == nil) then O.ANormal = 0.8; end
  if (O.ANormalOOR == nil) then O.ANormalOOR = 0.4; end
  if (O.ADebuff == nil) then O.ADebuff = 1.0; end

  if (O.ColNormal == nil) then O.ColNormal = { r = 0.39, g = 0.42, b = 0.64 }; end
  if (O.ColDebuffL == nil) then O.ColDebuffL = { r = 0.0, g = 0.0, b = 1.0 }; end
  if (O.ColDebuffR == nil) then O.ColDebuffR = { r = 1.0, g = 0.0, b = 0.0 }; end
  if (O.ColDebuffM == nil) then O.ColDebuffM = { r = 0.0, g = 0.7, b = 0.0 }; end
  if (O.ColDebuffNR == nil) then O.ColDebuffNR = { r = 0.86, g = 0.3, b = 1.0 }; end
  if (O.ColBack == nil) then O.ColBack = { r = 0.0, g = 0.0, b = 0.0, a = 0.5 }; end

  if (O.ShowHP == nil) then O.ShowHP = true; end
  if (O.ShowMana == nil) then O.ShowMana = true; end
  if (O.ShowHPText == nil) then O.ShowHPText = true; end
  if (O.Invert == nil) then O.Invert = true; end
  if (O.ShowHeaders == nil) then O.ShowHeaders = true; end
  if (O.ShowGrpNr == nil) then O.ShowGrpNr = false; end
  if (O.ShowHeaderRow == nil) then O.ShowHeaderRow = true; end
  if (O.ShowInfoRow == nil) then O.ShowInfoRow = true; end
  if (O.Vertical == nil) then O.Vertical = true; end
  if (O.VerticalUp == nil) then O.VerticalUp = false; end
  if (O.Columns == nil) then O.Columns = 12; end
  if (O.BarH == nil) then O.BarH = 4; end

  if (O.BtnW == nil) then O.BtnW = 28; end
  if (O.BtnH == nil) then O.BtnH = 20; end
  if (O.Fontsize == nil) then O.Fontsize = 9; end
  if (O.BtnSpX == nil) then O.BtnSpX = 4; end
  if (O.BtnSpY == nil) then O.BtnSpY = 2; end

  if (O.ShowTooltip == nil) then O.ShowTooltip = true; end
  if (O.UseSound == nil) then O.UseSound = false; end
  if (O.TargetMode == nil) then O.TargetMode = false; end
  if (O.ShowHealRange == nil) then O.ShowHealRange = true; end
  if (O.ShowAggro == nil) then O.ShowAggro = true; end
  if (O.ShowSpellIcon == nil) then O.ShowSpellIcon = true; end
  if (O.ShowRaidIcon == nil) then O.ShowRaidIcon = true; end
  if (O.RaidIconSize == nil) then O.RaidIconSize = 12; end
  if (O.ShowNotRemov == nil) then O.ShowNotRemov = false; end
  if (O.CheckInterval == nil) then O.CheckInterval = 0.1; end
  if (O.ShowBackdrop == nil) then O.ShowBackdrop = true; end
  if (O.ShowGradient == nil) then O.ShowGradient = true; end
  if (O.AutoHide == nil) then O.AutoHide = false; end
  if (O.ShowVehicles == nil) then O.ShowVehicles = true; end
  if (O.AdvAnchors == nil) then O.AdvAnchors = false; end
  if (O.StopCast == nil) then O.StopCast = false; end
  if (O.IgnoreDebuff == nil) then O.IgnoreDebuff = true; end
  if (O.ChatNotif == nil) then O.ChatNotif = true; end
  --O.AutoHide = false;

  if (O.ShowMsgNormal == nil) then O.ShowMsgNormal = true; end
  if (O.ShowMsgError == nil) then O.ShowMsgError = true; end
  if (O.ShowMsgWarning == nil) then O.ShowMsgWarning = true; end

  if (O.Debug == nil) then O.Debug = false;  end

  if (O.Keys == nil or O.Keys[1]["M"] == "-") then
    SMARTDEBUFF_SetDefaultKeys(true);
  end

  if (O.NotRemovableDebuffs == nil) then
    SMARTDEBUFF_SetDefaultNotRemovableDebuffs();
  end

  if (O.SpellGuard == nil) then
    SMARTDEBUFF_SetDefaultSpellGuard();
  end

  if (O.Sound == nil) then
    SMARTDEBUFF_SetDefaultSound();
  end

  -- Compatibility: reset previous computed tables
  if (O.CurrentSpells ~= nil) then
    for i, s in pairs(O.CurrentSpells) do
      if (type(O.CurrentSpells[i]) == "string" or #s ~= 2) then
        O.CurrentSpells = nil;
        SMARTDEBUFF_AddMsgD(RD.."Reset table SMARTDEBUFF_Options.CurrentSpells");
        break;
      end
    end
  end

  -- Cosmos support
  if(EarthFeature_AddButton) then
    EarthFeature_AddButton(
      { id = SMARTDEBUFF_TITLE;
        name = SMARTDEBUFF_TITLE;
        subtext = SMARTDEBUFF_SUBTITLE;
        tooltip = "";
        icon = imgSDB;
        callback = SMARTDEBUFF_ToggleSF;
        test = nil;
      } );
  elseif (Cosmos_RegisterButton) then
    Cosmos_RegisterButton(SMARTDEBUFF_TITLE, SMARTDEBUFF_TITLE, SMARTDEBUFF_SUBTITLE, imgSDB, SMARTDEBUFF_ToggleSF);
  end

  -- CTMod support
  if(CT_RegisterMod) then
    CT_RegisterMod(
      SMARTDEBUFF_TITLE,
      SMARTDEBUFF_SUBTITLE,
      5,
      imgSDB,
      SMARTDEBUFF_DESC,
      "switch",
      "",
      SMARTDEBUFF_ToggleSF);
  end

  if (canDebuff) then
    SMARTDEBUFF_CreateButtons();
  end

  local sspellinfo = nil;
  SMARTDEBUFF_DEBUFFSKIP_NAME = { };
  -- Get localized spellnames from id list
  for key, val in ipairs(SMARTDEBUFF_DEBUFFSKIP_ID) do
    if (val and type(val) == "number") then
      sspellinfo = SDB_GetSpellInfo(val);
      if (sspellinfo) then
        SMARTDEBUFF_DEBUFFSKIP_NAME[key] = sspellinfo.name;
        --SMARTDEBUFF_AddMsgD("Debuff localized: "..key..". ".. sspellinfo.name);
      end
    end
  end

  -- Populate global ignore list
  SMARTDEBUFF_DEBUFFSKIPLIST = { };
  for _, val in ipairs(SMARTDEBUFF_DEBUFFSKIPLIST_ID) do
    if (val and type(val) == "number" and SMARTDEBUFF_DEBUFFSKIP_NAME[val]) then
      local sname = SMARTDEBUFF_DEBUFFSKIP_NAME[val];
      SMARTDEBUFF_DEBUFFSKIPLIST[sname] = true;
      --SMARTDEBUFF_AddMsgD("Global skip debuff added: "..sname);
    end
  end

  -- Populate class ignore list
  SMARTDEBUFF_DEBUFFCLASSSKIPLIST = { };
  for _, class in ipairs(cOrderClass) do
    if (class and not SMARTDEBUFF_DEBUFFCLASSSKIPLIST[class]) then
      SMARTDEBUFF_DEBUFFCLASSSKIPLIST[class] = { };
      --SMARTDEBUFF_AddMsgD("Skip debuff class added: "..class);
      for _, val in ipairs(SMARTDEBUFF_DEBUFFCLASSSKIPLIST_ID[class]) do
        if (val and type(val) == "number" and SMARTDEBUFF_DEBUFFSKIP_NAME[val]) then
          local sname = SMARTDEBUFF_DEBUFFSKIP_NAME[val];
          SMARTDEBUFF_DEBUFFCLASSSKIPLIST[class][sname] = true;
          --SMARTDEBUFF_AddMsgD("Skip debuff added: "..sname);
        end
      end
    end
  end

  imgTarget = SMARTDEBUFF_HUNTERSMARK_ICONID;
  imgMenu = "Interface\\ICONS\\Trade_Engineering";
  imgMissing = "Interface\\ICONS\\inv_misc_questionmark";

  -- Init icon textures
	for i = 1, 8, 1 do
    cRaidicons[i] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..i;
  end
  cRaidicons[9] = "Interface\\RAIDFRAME\\ReadyCheck-Ready";
  cRaidicons[10] = "Interface\\RAIDFRAME\\ReadyCheck-NotReady";
  cRaidicons[11] = "Interface\\RAIDFRAME\\ReadyCheck-Waiting";

  if (O.ChatNotif) then
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_VERS_TITLE .. " " .. SMARTDEBUFF_MSG_LOADED, true);
    SMARTDEBUFF_AddMsg("/sdb - " .. SMARTDEBUFF_MSG_SDB, true);
  end
  isInit = true;

  if (O.VersionNr ~= SMARTDEBUFF_VERSIONNR) then
    -- / 1000 = major patchs, / 10000 = extensions
    if (O.VersionNr ~= nil and 
      (
        math.floor(O.VersionNr / 10000) < math.floor(SMARTDEBUFF_VERSIONNR / 10000)
        or O.VersionNr < SMARTDEBUFF_BREAKINGVERSION
      )
    ) then
      -- Reset Popup only on extensions patchs, (10xxxxx)
      -- or after last breaking version
      StaticPopup_Show("SMARTDEBUFF_RESET_KEYS");
    end
    O.VersionNr = SMARTDEBUFF_VERSIONNR;
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_UPGRADED);
  end

  if (SMARTDEBUFF_OptionsGlobal == nil) then SMARTDEBUFF_OptionsGlobal = { }; end
  OG = SMARTDEBUFF_OptionsGlobal;
  if (OG.FirstStart == nil) then OG.FirstStart = "V0";  end
  if (OG.FirstStart ~= SMARTDEBUFF_VERSION) then
    -- Show what's new On each new version, on first connection with this account (shared between chars)
    OG.FirstStart = SMARTDEBUFF_VERSION;
    SMARTDEBUFF_ShowWhatsNew()
  end

  SMARTDEBUFF_CheckWarlockPet();
  SMARTDEBUFF_CheckSF();
  SMARTDEBUFF_CheckForSpellUpgrade();
  --SMARTDEBUFF_SetButtons();
  SMARTDEBUFF_CheckAutoHide();
end
-- END SMARTDEBUFF_Options_Init


function SMARTDEBUFF_SetDefaultColors()
  O.ColNormal  = { r = 0.39, g = 0.42, b = 0.64 };
  O.ColDebuffL = { r = 0.0, g = 0.0, b = 1.0 };
  O.ColDebuffR = { r = 1.0, g = 0.0, b = 0.0 };
  O.ColDebuffM = { r = 0.0, g = 0.7, b = 0.0 };
  O.ColDebuffNR = { r = 0.86, g = 0.3, b = 1.0 };
  O.ColBack    = { r = 0.0, g = 0.0, b = 0.0, a = 0.5 };
end

function SMARTDEBUFF_SetDefaultNotRemovableDebuffs()
  O.NotRemovableDebuffs = { };
  local spellinfo;
  for _, v in ipairs(SMARTDEBUFF_NOTREMOVABLE_ID) do
    if (v) then
      spellinfo = SDB_GetSpellInfo(v);
      if (spellinfo) then
        table.insert(O.NotRemovableDebuffs, spellinfo.name);
      end
    end
  end
end

function SMARTDEBUFF_SetDefaultSpellGuard()
  O.SpellGuard = { };
  for _, v in ipairs(cSpellName) do
    if (v) then
      table.insert(O.SpellGuard, v);
    end
  end
end

function SMARTDEBUFF_SetDefaultClassOrder()
  O.OrderClass = { };
  for _, v in ipairs(cOrderClass) do
    if (v) then
      table.insert(O.OrderClass, v);
    end
  end
end

function SMARTDEBUFF_SetDefaultSound()
  O.Sound = SMARTDEBUFF_SOUNDS_DEFAULT;
end

function SMARTDEBUFF_SetDefaultKeys(bReload)

  O.Keys = { };
  -- [] = { Type, Name, Rank, ID, Link }
  -- normal mode
  O.Keys[1]    = {["L"]  = {cSpellDefault["L"][2], cSpellDefault["L"][3], "", cSpellDefault["L"][4]},
                  ["R"]  = {cSpellDefault["R"][2], cSpellDefault["R"][3], "", cSpellDefault["R"][4]},
                  ["M"]  = {cSpellDefault["M"][2], cSpellDefault["M"][3], "", cSpellDefault["M"][4]},
                  ["SL"] = {"target", "target"},
                  ["SR"] = { },
                  ["SM"] = { },
                  ["AL"] = {cSpellDefault["AL"][2], cSpellDefault["AL"][3], "", cSpellDefault["AL"][4]},
                  ["AR"] = {cSpellDefault["AR"][2], cSpellDefault["AR"][3], "", cSpellDefault["AR"][4]},
                  ["AM"] = {cSpellDefault["AM"][2], cSpellDefault["AM"][3], "", cSpellDefault["AM"][4]},
                  ["CL"] = {"menu", "menu"},
                  ["CR"] = { },
                  ["CM"] = { }
                  };
  -- target mode
  O.Keys[2]    = {["L"]  = {"target", "target"},
                  ["R"]  = {cSpellDefault["AL"][2], cSpellDefault["AL"][3], "", cSpellDefault["AL"][4]},
                  ["M"]  = {cSpellDefault["AM"][2], cSpellDefault["AM"][3], "", cSpellDefault["AM"][4]},
                  ["SL"] = {cSpellDefault["AR"][2], cSpellDefault["AR"][3], "", cSpellDefault["AR"][4]},
                  ["SR"] = { },
                  ["SM"] = { },
                  ["AL"] = {cSpellDefault["L"][2], cSpellDefault["L"][3], "", cSpellDefault["L"][4]},
                  ["AR"] = {cSpellDefault["R"][2], cSpellDefault["R"][3], "", cSpellDefault["R"][4]},
                  ["AM"] = {cSpellDefault["M"][2], cSpellDefault["M"][3], "", cSpellDefault["M"][4]},
                  ["CL"] = {"menu", "menu"},
                  ["CR"] = { },
                  ["CM"] = { }
                  };

  local i, j;
  if (bReload) then
    for iAction = 1, 24, 1 do
      local mode, i = GetActionMode(iAction);
      GetActionKeyInfo(mode, i);
    end
    SMARTDEBUFF_RefreshAOFKeys();
    -- What's new: delay to avoid errors with early display on initial install
    C_Timer.After(0,SMARTDEBUFF_ShowWhatsNew);
  end

  SMARTDEBUFF_SetButtons();
end

function SMARTDEBUFF_RebuildMacrosInfo()
  for iAction = 1, 24, 1 do
    local mode, i = GetActionMode(iAction);
    GetActionKeyInfo(mode, i);
  end
end

local function SDB_Hook_EditMacro(index, name, icon)
  if (not index or not name) then
    return;
  end;
  for iAction = 1, 24, 1 do
    local mode, i = GetActionMode(iAction);
    local aType, aName, aRank, aId, aLink = GetActionKeyInfo(mode, i, true);
    if (aType == "macro" and aId == index) then
      -- update name & icon
      aName = name;
      aLink = icon or aLink;
      SetActionInfo(mode, i, aType, aName, aRank, aId, aLink);
      SMARTDEBUFF_AddMsgD(mode.."-"..i.."-Update macro #"..index..", new name: "..aName);
      shouldCallSetMacros = true;
    end
  end
end
hooksecurefunc("EditMacro", SDB_Hook_EditMacro);

local function SDB_Hook_DeleteMacro(indexOrName)
  if (type(indexOrName) == "number") then
    for iAction = 1, 24, 1 do
      local mode, i = GetActionMode(iAction);
      local aType, aName, aRank, aId, aLink = GetActionKeyInfo(mode, i, true);
      if (aType == "macro" and aId == indexOrName) then
        SetActionInfo(mode, i);
      end
    end
  end
end
hooksecurefunc("DeleteMacro", SDB_Hook_DeleteMacro);

--- Find Macro, by Name > Index & Icon > Icon > Index
--- @return number MacroIndex Found macro index
function SDB_GetMacroIndex(Name, Id, Icon)
  Name = Name or "";
  local newIndex = GetMacroIndexByName(Name);
  if newIndex > 0 then
    return newIndex;
  end

  if Icon then
    if Id and select(2, GetMacroInfo(Id)) == Icon then
      -- Then By Index & Icon pair
      SMARTDEBUFF_AddMsgD(Name.." Macro name has changed, at same index #"..Id)
      return Id;
    else
      -- Then Find By Icon (restrict search on same page)
      local pageFirstMacroId, pageNumMacros = 1, GetNumMacros();
      if (Id and Id > MAX_CHARACTER_MACROS) then
        pageFirstMacroId = MAX_CHARACTER_MACROS+1;
        _, pageNumMacros = GetNumMacros();
      end
      for i = pageFirstMacroId, pageFirstMacroId+pageNumMacros do
          local _, findMacroIcon = GetMacroInfo(i);
          if findMacroIcon == Icon then
              SMARTDEBUFF_AddMsgD(Name.." Macro name & index have changed, new index #"..i);
              return i;
          end
      end
    end
  end
  -- fallback, keep Index (or 0 if no macro at this index)
  newIndex = GetMacroIndexByName(GetMacroInfo(Id) or "");
  SMARTDEBUFF_AddMsgD(Name.." Macro name & icon have changed, or macro has been removed, keep index #"..newIndex);
  return newIndex;
end

--- Check if a default spell was changed (different name, or same name different id)
function SMARTDEBUFF_CheckForSpellUpgrade()
  if (not O.CurrentSpells) then
    -- Init: Cache cSpellDefault keys / spellNames inside CurrentSpells ( { ["L"] => { "Remove Corruption", 1 } }, )
    O.CurrentSpells = { };
    for i, s in pairs(cSpellDefault) do
      if (s and s[2] == "spell" and s[3]) then
        O.CurrentSpells[i] = { s[3], s[4] };
      end
    end
  else
    -- Compare current spellNames for each key, with previously saved, and upgrade/save them
    for i, s in pairs(cSpellDefault) do
      -- different name, or same name/different id
      if (s and s[2] == "spell" and s[3]) then
        if (not O.CurrentSpells[i] or not O.CurrentSpells[i][1]) then
          -- No comparison: cache it
          O.CurrentSpells[i] = { s[3], s[4] };
        elseif (s[3] ~= O.CurrentSpells[i][1] or (s[4] and s[4] ~= O.CurrentSpells[i][2])) then
          -- Spell changed: upgrade and cache it
          SMARTDEBUFF_AddMsgD(GR.."Spell upgrade found: "..O.CurrentSpells[i][1].." #"..ChkS(O.CurrentSpells[i][2]).." -> "..s[3].." #"..s[4]);
          SMARTDEBUFF_UpgradeSpell(O.CurrentSpells[i][1], O.CurrentSpells[i][2], s[3], s[4]);
          O.CurrentSpells[i] = { s[3], s[4] };
        end
      end
    end
  end
end

--- Upgrades a debuff spell to the next better one and replaces it in all the key options
function SMARTDEBUFF_UpgradeSpell(oldSpellName, oldSpellID, newSpellName, newSpellID)
  local v;
  local newSpellLink = GetSpellLink(newSpellName)
  for mode = 1, 2, 1 do
    for _, k in ipairs(SMARTDEBUFF_ORDER_KEYS) do
      -- { spellType, spellName, spellRank, spellID, spellLink }
      v = O.Keys[mode][k];
      if (v and v[1] and (v[1] == "spell" or v[1] == "petaction") and v[2]) then
        if (v[2] == oldSpellName or (v[4] and v[4] == oldSpellID)) then
          -- O.Keys[mode][k][1] = newType;
          O.Keys[mode][k][2] = newSpellName;
          -- O.Keys[mode][k][3] = newSpellRank;
          O.Keys[mode][k][4] = newSpellID;
          O.Keys[mode][k][5] = newSpellLink;
        elseif (v[2] == newSpellName) then
          -- In case of: Update ID for spells with same name (bonus: compatibility with previous version)
          O.Keys[mode][k][4] = newSpellID;
          O.Keys[mode][k][5] = newSpellLink;
        end
      end
    end
  end
end


-- Links the debuff spells to the assign keys, to make sure the display highlights up correctly
function SMARTDEBUFF_LinkSpellsToKeys()
  cSpells = { };
  local idx = 0;
  local v;
  local mode = 1;
  if (O.TargetMode) then
    mode = 2;
  end
  for _, k in ipairs(SMARTDEBUFF_ORDER_KEYS) do
    v = O.Keys[mode][k];
    if (v and v[1] and ((v[1] == "spell" or v[1] == "petaction") or (v[1] == "action" and v[4])) and v[2]) then
      idx = 0;
      if     (k == "L" or k == "SL" or k == "AL" or k == "CL") then
        idx = 1;
      elseif (k == "R" or k == "SR" or k == "AR" or k == "CR") then
        idx = 2;
      elseif (k == "M" or k == "SM" or k == "AL" or k == "CM") then
        idx = 3;
      end
      if (cSpellList[v[2]]) then
        for i, s in ipairs(cSpellList[v[2]]) do
          if (s and not cSpells[s]) then
            cSpells[s] = {v[2], idx};
            SMARTDEBUFF_AddMsgD(GRD.."Spell linked: "..v[2].." ("..s..") -> "..k);
          end
        end
      end
    end
  end
end


-- SmartDebuff commandline menu ---------------------------------------------------------------------------------------
local function NumCheck(n, min, max, def)
  local i = tonumber(n);
  if (i == nil or i < min or i > max) then
    i = def;
  end
  return i;
end

function SMARTDEBUFF_command(msgIn)
  if (not isInit) then
    SMARTDEBUFF_AddMsgWarn(SMARTDEBUFF_VERS_TITLE.." not initialized correctly!", true);
    if (not isTTreeLoaded) then
      SMARTDEBUFF_AddMsgWarn("Talent tree not loaded, have you finished the quests in the starting zone?", true);
    end
    -- print("isLoaded:", isLoaded, ", isPlayer:", isPlayer, ", isTTreeLoaded:", isTTreeLoaded, ", isInit:", isInit);
    return;
  end

  local msgs = SMARTDEBUFF_Split(msgIn, " ");
  local msg = msgs[1];

  if(msg == "help" or msg == "?") then
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_VERS_TITLE, true);
    SMARTDEBUFF_AddMsg("Syntax: /sdb [command] or /smartdebuff [command]", true);
    SMARTDEBUFF_AddMsg("o      -  " .. SMARTDEBUFF_MSG_SDB, true);
    SMARTDEBUFF_AddMsg("ris #  -  " .. "Raid icon size # = 4-64", true);
    SMARTDEBUFF_AddMsg("bsx # -  " .. "Button space X # = 0-16", true);
    SMARTDEBUFF_AddMsg("bsy # -  " .. "Button space Y # = 0-16", true);
    SMARTDEBUFF_AddMsg("tm #  -  " .. "Test mode # = number of buttons", true);
    SMARTDEBUFF_AddMsg("new  -  " .. "Show What's new window", true);
    SMARTDEBUFF_AddMsg("reset  -  " .. "Reset "..SMARTDEBUFF_OFT_SKILLS, true);
    SMARTDEBUFF_AddMsg("rafp  -  " .. "Reset all frames positions", true);
    if O.Debug then
      SMARTDEBUFF_AddMsg("rvl    -  " .. "Reset version locally", true);
      SMARTDEBUFF_AddMsg("rv    -  " .. "Reset version - all chars", true);
      SMARTDEBUFF_AddMsg("rl    -  " .. "Reset local options", true);
      SMARTDEBUFF_AddMsg("rglobal -  " .. "Reset global options", true);
    end
  elseif (msg == "options" or msg == "o") then
    SMARTDEBUFF_ToggleOF();
  elseif (msg == "new") then
    SMARTDEBUFF_ShowWhatsNew();
  elseif (msg == "rafp") then
    SmartDebuffSF:ClearAllPoints();
    O.SFPosX = 400;
    O.SFPosY = -300;
    O.SFPosP = "TOPLEFT";
    O.SFPosRP = "TOPLEFT";
    SmartDebuffSF:SetPoint("TOPLEFT", UIParent, "TOPLEFT", O.SFPosX, O.SFPosY);
    SmartDebuffIF:ClearAllPoints();
    SmartDebuffIF:SetPoint("CENTER", UIParent, "CENTER");
    SmartDebuffOF:ClearAllPoints();
    SmartDebuffOF:SetPoint("CENTER", UIParent, "CENTER");
    SMARTDEBUFF_SetAnchorPos();
  elseif (msg == "ris") then
    O.RaidIconSize = 8;
    if (msgs[2] ~= nil) then
      O.RaidIconSize = NumCheck(msgs[2], 4, 64, 8);
      SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE.." Raid icon size = "..O.RaidIconSize, true);
    end
  elseif (msg == "bsx") then
    if (msgs[2] ~= nil) then
      O.BtnSpX = NumCheck(msgs[2], 0, 16, 4);
      SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE.." Button space X = "..O.BtnSpX, true);
      SMARTDEBUFF_SetButtons();
    end
  elseif (msg == "bsy") then
    if (msgs[2] ~= nil) then
      O.BtnSpY = NumCheck(msgs[2], 0, 16, 2);
      SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE.." Button space Y = "..O.BtnSpY, true);
      SMARTDEBUFF_SetButtons();
    end
  elseif (msg == "debug") then
    O.Debug = SMARTDEBUFF_toggleBool(O.Debug, "Debug active = ");
    if (O.Debug) then SMARTDEBUFF_AddMsg("Hover buttons with modifier for actions debug"); end
  elseif (msg == "reset") then
    SMARTDEBUFF_SetDefaultKeys(true);
  elseif (msg == "rvl") then
    O.VersionNr = "0";
    ReloadUI();
  elseif (msg == "rv") then
    O.VersionNr = 0;
    OG.FirstStart = "V0";
    ReloadUI();
  elseif (msg == "rl") then
    SMARTDEBUFF_Options = nil;
    ReloadUI();
  elseif (msg == "rglobal") then
    SMARTDEBUFF_Options = nil;
    SMARTDEBUFF_OptionsGlobal = nil;
    ReloadUI();
  elseif (msg == "tm") then
    if (msgs[2] ~= nil) then
      iTest = tonumber(msgs[2]);
      if (iTest == nil or iTest < 1) then
        iTest = 0;
      elseif (iTest > maxRaid) then
        iTest = maxRaid;
      end
    else
      iTest = 0;
    end
    SMARTDEBUFF_SetUnits();
    if (iTest > 0) then
      SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE.." test mode = "..iTest, true);
    else
      SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE.." test mode off", true);
    end
  else
    SMARTDEBUFF_ToggleSF();
  end
end
-- END SMARTDEBUFF_command


-- SmartDebuff frame functions ---------------------------------------------------------------------------------------

function SMARTDEBUFF_ToggleSF()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end

  O.ShowSF = not O.ShowSF;
  SMARTDEBUFF_CheckSF();

  if ((C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("SmartBuff") or IsAddOnLoaded("SmartBuff")) and SMARTDEBUFF_IsVisible()) then
    if (SmartBuffOptionsFrame_cbSmartDebuff) then
      SmartBuffOptionsFrame_cbSmartDebuff:SetChecked(O.ShowSF);
    end
  end
end

function SMARTDEBUFF_CheckSF()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end

  if (not O.ShowSF) then
    HideF(SmartDebuffSF);
  else
    ShowF(SmartDebuffSF);
    SMARTDEBUFF_CheckSFBackdrop();
    SMARTDEBUFF_CheckSFButtons();
    SMARTDEBUFF_SetUnits();
  end
  SMARTDEBUFF_CheckIF();
end

function SMARTDEBUFF_CheckSFButtons(hide)
  if (SMARTDEBUFF_IsVisible()) then
    if (canDebuff and O.ShowHeaderRow and not InCombatLockdown() and not hide) then
      SmartDebuffSF_Title:SetText("martDebuff");
      SmartDebuffSF_btnClose:Show();
      SmartDebuffSF_btnStyle:Show();
      SmartDebuffSF_btnOptions:Show();
    else
      if (O.ShowHeaderRow) then
        SmartDebuffSF_Title:SetText("SmartDebuff");
      else
        SmartDebuffSF_Title:SetText("");
      end
      SmartDebuffSF_btnClose:Hide();
      SmartDebuffSF_btnStyle:Hide();
      SmartDebuffSF_btnOptions:Hide();
      if (hide) then
        HideF(SmartDebuffOF);
      end
    end

    if (O.VerticalUp) then
      SmartDebuffSF_btnStyle:ClearAllPoints();
      SmartDebuffSF_btnStyle:SetPoint("BOTTOMLEFT", SmartDebuffSF, "BOTTOMLEFT", 2, 1);
      SmartDebuffSF_btnClose:ClearAllPoints();
      --Semi #1287
      SmartDebuffSF_btnClose:SetPoint("BOTTOMRIGHT", SmartDebuffSF, "BOTTOMRIGHT", 0, 1);
      SmartDebuffSF_btnOptions:ClearAllPoints();
      SmartDebuffSF_btnOptions:SetPoint("BOTTOMRIGHT", SmartDebuffSF_btnClose, "BOTTOMLEFT", -5, 0);
    else
      SmartDebuffSF_btnStyle:ClearAllPoints();
      SmartDebuffSF_btnStyle:SetPoint("TOPLEFT", SmartDebuffSF, "TOPLEFT", 2, -1);
      SmartDebuffSF_btnClose:ClearAllPoints();
      --Semi #1287
      SmartDebuffSF_btnClose:SetPoint("TOPRIGHT", SmartDebuffSF, "TOPRIGHT", 0, -2);
      SmartDebuffSF_btnOptions:ClearAllPoints();
      SmartDebuffSF_btnOptions:SetPoint("TOPRIGHT", SmartDebuffSF_btnClose, "TOPLEFT", -5, 1);
    end

  end
end

function SMARTDEBUFF_ToggleIF()
  if (not isInit) then return; end
  O.ShowIF = not O.ShowIF;
  SMARTDEBUFF_CheckIF();
end

function SMARTDEBUFF_CheckIF()
  if (not isInit) then return; end
  if (not O.ShowIF or not SMARTDEBUFF_IsVisible() or iGroupSetup <= 1) then
    HideF(SmartDebuffIF);
  else
    ShowF(SmartDebuffIF);
  end
end

function SMARTDEBUFF_ToggleSFBackdrop()
  if (SmartDebuffSF) then
    O.ShowBackdrop = not O.ShowBackdrop;
    if (SmartDebuffOF:IsVisible()) then
      SmartDebuffOF_cbShowBackdrop:SetChecked(O.ShowBackdrop);
    end
    SMARTDEBUFF_CheckSFBackdrop();
  end
end

function SMARTDEBUFF_CheckSFBackdrop()
  local f = SmartDebuffSF;
  if (f) then
    --f:SetAlpha(O.ColBack.a);
    if (O.ShowBackdrop) then
      --"Interface\\Tooltips\\UI-Tooltip-Background"
      f:SetBackdrop( {
        bgFile = "Interface\\AddOns\\SmartDebuff\\Icons\\white16x16", edgeFile = nil, tile = false, tileSize = 0, edgeSize = 2,
        insets = { left = 0, right = 0, top = 0, bottom = 0 } });
      f:SetBackdropColor(O.ColBack.r, O.ColBack.g, O.ColBack.b, O.ColBack.a);
    else
      f:SetBackdrop(nil);
      f:SetBackdropColor(0,0,0,0);
    end
    --SmartDebuffSF:EnableMouse(O.ShowBackdrop);
    f:EnableMouse(true);
  end
end

function SMARTDEBUFF_TestModeToggle()
  if (iTest == nil or iTest < 1) then
    iTest = 25;
  else
    iTest = 0;
  end
  SMARTDEBUFF_SetUnits();
end


function SMARTDEBUFF_CreateButtons()
  local frame = _G["SmartDebuffSF"];

  if (frame) then
    local i = 1;

    for k, v in pairs(AnchorPos) do
      local rb = CreateFrame("CheckButton", "SmartDebuff_rbAnchor"..v, frame);
      rb:SetCheckedTexture("Interface\\Common\\UI-DropDownRadioChecks");
      local tx = rb:GetCheckedTexture();
      tx:SetTexCoord(0.0, 0.5, 0.5, 1.0);
      tx:SetBlendMode("BLEND");
      rb:SetNormalTexture("Interface\\Common\\UI-DropDownRadioChecks");
      tx = rb:GetNormalTexture();
      tx:SetTexCoord(0.5, 1.0, 0.51, 1.0);
      tx:SetBlendMode("BLEND");
      rb:SetHighlightTexture("Interface\\Common\\UI-DropDownRadioChecks");
      tx = rb:GetHighlightTexture();
      tx:SetTexCoord(0.5, 1.0, 0.51, 1.0);
      tx:SetBlendMode("ADD");
      rb:ClearAllPoints();
      rb:SetPoint("CENTER", frame, v, 0, 0);
      rb:SetSize(16, 16);
      rb:SetFrameStrata("HIGH");
      rb:Hide();
      rb:SetScript("OnClick", SMARTDEBUFF_SetAnchorPos);
    end

    local lbl = CreateFrame("EditBox", "SmartDebuff_lblInfoRow", frame);
    lbl:SetWidth(240);
    lbl:SetHeight(12);
    lbl:SetMultiLine(false);
    lbl:SetMaxLetters(80);
    lbl:SetFontObject("SmartDebuff_GameFontNormalMicro");
    lbl:SetJustifyH("LEFT");
    lbl:SetJustifyV("MIDDLE");
    lbl:EnableMouse(false);
    lbl:EnableKeyboard(false);
    lbl:SetAutoFocus(false);
    --lbl:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, -2);
    --lbl:SetText("Info");

    for i = 1, maxColumns, 1 do
      lbl = CreateFrame("EditBox", "SmartDebuffTxt"..i, frame);
      lbl:SetMultiLine(true);
      lbl:SetMaxLetters(16);
      --TOCHECK
      lbl:SetFontObject("SmartDebuff_GameFontNormalMicro");
      lbl:SetFont(STANDARD_TEXT_FONT, 8, "");
      lbl:SetJustifyH("CENTER");
      lbl:SetJustifyV("BOTTOM");
      --lbl:SetNonSpaceWrap(1);
      lbl:EnableMouse(false);
      lbl:EnableKeyboard(false);
      lbl:SetAutoFocus(false);
      -- create icon texture
      lbl.icon = lbl:CreateTexture(nil, "OVERLAY");
      lbl.icon:SetTexture(nil);
      lbl.icon:SetBlendMode("BLEND");
      lbl.icon:ClearAllPoints();
    end

    for i = 1, maxRaid, 1 do

      local button = CreateFrame("Button", "SmartDebuffBtn"..i, frame, "SecureActionButtonTemplate");
      button:SetWidth(1);
      button:SetHeight(1);
      button:ClearAllPoints();

      button.dropdown = CreateFrame("Frame", "SmartDebuffBtn"..i.."DropDown", button, "UIDropDownMenuTemplate");

      if (BackdropTemplateMixin) then Mixin(button, BackdropTemplateMixin) end
      button:SetBackdrop( {
        bgFile = nil, edgeFile = "Interface\\AddOns\\SmartDebuff\\Icons\\white16x16", tile = false, tileSize = 0, edgeSize = 2,
        insets = { left = 0, right = 0, top = 0, bottom = 0 } });
      --button:SetBackdropColor(0,0,0,0);


      -- create bg texture
      button.texture = button:CreateTexture(nil, "BACKGROUND");
      button.texture:SetColorTexture(0, 0, 0);
      button.texture:SetAllPoints(button);
      button.texture:SetBlendMode("DISABLE");

      button.text = button:CreateFontString(nil, nil, "SmartDebuff_Font");
      button.text:SetJustifyH("CENTER");
      button.text:SetAllPoints(button);
      button:SetFontString(button.text);

      -- create hp texture
      button.hp = button:CreateTexture(nil, "BORDER");
      button.hp:SetColorTexture(0, 1, 0);
      button.hp:SetBlendMode("DISABLE");
      button.hp:ClearAllPoints();

      -- create hp text
      button.hptext = button:CreateFontString(nil, nil, "SmartDebuff_FontHP");
      button.hptext:SetJustifyH("LEFT");
      button.hptext:SetJustifyV("MIDDLE");
      button.hptext:ClearAllPoints();

      -- create mana texture
      button.mana = button:CreateTexture(nil, "BORDER");
      button.mana:SetColorTexture(0, 0, 1);
      button.mana:SetBlendMode("DISABLE");
      button.mana:ClearAllPoints();

      -- create mana text
      button.manatext = button:CreateFontString(nil, nil, "SmartDebuff_FontHP");
      button.manatext:SetJustifyH("LEFT");
      button.manatext:SetJustifyV("MIDDLE");
      button.manatext:ClearAllPoints();

      -- create aggro texture
      button.aggro = button:CreateTexture(nil, "BORDER");
      button.aggro:SetColorTexture(1, 1, 0);
      button.aggro:SetBlendMode("DISABLE");
      button.aggro:ClearAllPoints();

      -- create raid icon texture
      button.raidicon = button:CreateTexture(nil, "ARTWORK");
      button.raidicon:SetTexture(nil);
      button.raidicon:SetBlendMode("BLEND");
      button.raidicon:ClearAllPoints();

      -- create spell icon texture
      button.spellicon = { };
      for j = 1, maxSpellIcons, 1 do
        button.spellicon[j] = button:CreateTexture(nil, "OVERLAY");
        button.spellicon[j]:SetTexture(nil);
        button.spellicon[j]:SetBlendMode("BLEND");
        button.spellicon[j]:ClearAllPoints();
      end

      button:EnableMouse(true);
      --button:EnableMouseWheel(true);
      button:RegisterForClicks("AnyDown");
      button:SetScript("OnEnter", SMARTDEBUFF_ButtonTooltipOnEnter);
      button:SetScript("OnLeave", SMARTDEBUFF_ButtonTooltipOnLeave);

      button:SetAttribute("unit", nil);
      button:SetAttribute("type1", "spell");
      button:SetAttribute("type2", "spell");
      button:SetAttribute("type3", "target");
      button:SetAttribute("spell1", nil);
      button:SetAttribute("spell2", nil);
    end

    for i = 1, maxPets, 1 do
      local button = CreateFrame("Button", "SmartDebuffPetBtn"..i, frame, "SecureActionButtonTemplate");
      button:SetWidth(1);
      button:SetHeight(1);
      button:ClearAllPoints();

      button.dropdown = CreateFrame("Frame", "SmartDebuffPetBtn"..i.."DropDown", button, "UIDropDownMenuTemplate");

      if (BackdropTemplateMixin) then Mixin(button, BackdropTemplateMixin) end
      button:SetBackdrop( {
        bgFile = nil, edgeFile = "Interface\\AddOns\\SmartDebuff\\Icons\\white16x16", tile = false, tileSize = 0, edgeSize = 2,
        insets = { left = 0, right = 0, top = 0, bottom = 0 } });

      -- create bg texture
      button.texture = button:CreateTexture(nil, "BACKGROUND");
      button.texture:SetColorTexture(0, 0, 0);
      button.texture:SetAllPoints(button);
      button.texture:SetBlendMode("DISABLE");

      button.text = button:CreateFontString(nil, nil, "SmartDebuff_Font");
      button.text:SetJustifyH("CENTER");
      button.text:SetAllPoints(button);
      button:SetFontString(button.text);

      -- create hp texture
      button.hp = button:CreateTexture(nil, "BORDER");
      button.hp:SetColorTexture(0, 1, 0);
      button.hp:SetBlendMode("DISABLE");
      button.hp:ClearAllPoints();

      -- create hp text
      button.hptext = button:CreateFontString(nil, nil, "SmartDebuff_FontHP");
      button.hptext:SetJustifyH("CENTER");
      button.hptext:ClearAllPoints();

      -- create mana texture
      button.mana = button:CreateTexture(nil, "BORDER");
      button.mana:SetColorTexture(0, 0, 1);
      button.mana:SetBlendMode("DISABLE");
      button.mana:ClearAllPoints();

      -- create mana text
      button.manatext = button:CreateFontString(nil, nil, "SmartDebuff_FontHP");
      button.manatext:SetJustifyH("CENTER");
      button.manatext:ClearAllPoints();

      -- create aggro texture
      button.aggro = button:CreateTexture(nil, "BORDER");
      button.aggro:SetColorTexture(1, 1, 0);
      button.aggro:SetBlendMode("DISABLE");
      button.aggro:ClearAllPoints();

      -- create raid icon texture
      button.raidicon = button:CreateTexture(nil, "ARTWORK");
      button.raidicon:SetTexture(nil);
      button.raidicon:SetBlendMode("BLEND");
      button.raidicon:ClearAllPoints();

      -- create spell icon texture
      button.spellicon = { };
      for j = 1, maxSpellIcons, 1 do
        button.spellicon[j] = button:CreateTexture(nil, "OVERLAY");
        button.spellicon[j]:SetTexture(nil);
        button.spellicon[j]:SetBlendMode("BLEND");
        button.spellicon[j]:ClearAllPoints();
      end

      button:EnableMouse(true);
      button:RegisterForClicks("AnyDown");
      button:SetScript("OnEnter", SMARTDEBUFF_ButtonTooltipOnEnter);
      button:SetScript("OnLeave", SMARTDEBUFF_ButtonTooltipOnLeave);

      button:SetAttribute("unit", nil);
      button:SetAttribute("type1", "spell");
      button:SetAttribute("type2", "spell");
      button:SetAttribute("type3", "target");
      button:SetAttribute("spell1", nil);
      button:SetAttribute("spell2", nil);
    end
  end

  local offX = 4;
  local offY = 24;
  local lblW = 96;
  frame = _G["SmartDebuffAOFKeys"];
  if (frame) then
    local lbl = CreateFrame("EditBox", "SmartDebuff_lblColumnTitle", frame);
    lbl:SetWidth(lblW);
    lbl:SetHeight(16);
    lbl:SetMultiLine(false);
    lbl:SetMaxLetters(30);
    lbl:SetFontObject("GameFontHighlightSmall");
    lbl:SetJustifyH("LEFT");
    lbl:SetJustifyV("MIDDLE");
    lbl:EnableMouse(false);
    lbl:EnableKeyboard(false);
    lbl:SetAutoFocus(false);
    lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", offX, -2);
    lbl:SetText(SMARTDEBUFF_FT_MODES);

    for i = 1, 24, 1 do
      if (i == 1 or i == 13) then
        lbl = CreateFrame("EditBox", "SmartDebuff_lblColumn"..i, frame);
        lbl:SetWidth(32);
        lbl:SetHeight(16);
        lbl:SetMultiLine(true);
        lbl:SetMaxLetters(30);
        lbl:SetFontObject("GameFontHighlightSmall");
        lbl:SetJustifyH("CENTER");
        lbl:SetJustifyV("MIDDLE");
        lbl:EnableMouse(false);
        lbl:EnableKeyboard(false);
        lbl:SetAutoFocus(false);
        lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", offX + lblW, -4);
        if (i == 1) then
          lbl:SetText(SMARTDEBUFF_FT_MODENORMAL);
        else
          lbl:SetText(SMARTDEBUFF_FT_MODETARGET);
        end
      end

      if (i <= 12) then
        lbl = CreateFrame("EditBox", "SmartDebuff_lblAction"..i, frame);
        lbl:SetWidth(lblW);
        lbl:SetHeight(32);
        lbl:SetMultiLine(false);
        lbl:SetMaxLetters(30);
        lbl:SetFontObject("GameFontNormalSmall");
        lbl:SetJustifyH("LEFT");
        lbl:SetJustifyV("MIDDLE");
        lbl:EnableMouse(false);
        lbl:EnableKeyboard(false);
        lbl:SetAutoFocus(false);
        lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", offX, -offY);
        if (SMARTDEBUFF_ORDER_KEYS[i]) then
          lbl:SetText(SMARTDEBUFF_KEYS[SMARTDEBUFF_ORDER_KEYS[i]]);
        end
      end

      --SMARTDEBUFF_AddMsgD("Texture = "..ChkS(imgActionSlot));
      local button = CreateFrame("Button", "SmartDebuff_btnAction"..i, frame);
      button:SetWidth(32);
      button:SetHeight(32);
      SetATexture(button, imgActionSlot);
      button:ClearAllPoints();
      button:SetPoint("TOPLEFT", frame, "TOPLEFT", offX + lblW, -offY);
      button:SetID(i);
      button:SetScript("OnMouseDown", SMARTDEBUFF_OnActionDown);
      --button:SetScript("OnMouseUp", SMARTDEBUFF_OnActionUp);
      button:SetScript("OnReceiveDrag", SMARTDEBUFF_OnReceiveDrag);
      button:SetScript("OnEnter", SMARTDEBUFF_BtnActionOnEnter);
      button:SetScript("OnLeave", SMARTDEBUFF_BtnActionOnLeave);

      offY = offY + 36;
      if (i == 12) then
        offX = offX + 36;
        offY = 24;
      end
    end
  end

end

function SMARTDEBUFF_SetButtons()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end

  local i, j;
  -- reset all buttons
  for i = 1, maxRaid, 1 do
    SMARTDEBUFF_SetButton(nil, i);
    SMARTDEBUFF_SetButton(nil, i, 1);
  end

  i = 1;
  iVehicles = 0;
  local cl, data, unit, uc;
  if (O.SortedByClass) then
    for j, cl in ipairs(O.OrderClass) do
      if (cl and cClasses[cl] and O.DebuffClasses[cl]) then
        for _, data in pairs(cClasses[cl]) do
          if (data and LUnitExists(data.Unit) and O.DebuffGrp[data.Subgroup]) then
            if (O.ShowVehicles and data.InVehicle) then
              iVehicles = iVehicles + 1;
              SMARTDEBUFF_SetButton(data.UnitVehicle, iVehicles, 1);
            end
            SMARTDEBUFF_SetButton(data.Unit, i);
            i = i + 1;
          end
        end
      end
    end
  else
    --for cl = 1, 8, 1 do
    for j, cl in ipairs(O.OrderGrp) do
      if (cl and cGroups[cl] and O.DebuffGrp[cl]) then
        for _, data in pairs(cGroups[cl]) do
          if (data and LUnitExists(data.Unit)) then
            if (iTest > 0) then
              uc = cUnits[data.Unit].Class;
            else
              _, uc = UnitClass(data.Unit);
            end
            if (uc and O.DebuffClasses[uc]) then
              if (O.ShowVehicles and data.InVehicle) then
                iVehicles = iVehicles + 1;
                SMARTDEBUFF_SetButton(data.UnitVehicle, iVehicles, 1);
              end
              SMARTDEBUFF_SetButton(data.Unit, i);
              i = i + 1;
            end
          end
        end
      end
      if (math.fmod(i - 1, 5) ~= 0) then
        i = i + (5 - math.fmod(i - 1, 5));
      end
    end
  end
  --SMARTDEBUFF_AddMsgD("Debuff buttons set");

  SMARTDEBUFF_SetPetButtons(false);
  SMARTDEBUFF_SetStyle();
end

function SMARTDEBUFF_SetPetButtons(b)
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end

  local i;
  -- reset buttons
  if (b) then
    for i = (iVehicles + 1), maxPets, 1 do
      SMARTDEBUFF_SetButton(nil, i, 1);
    end
  end

  local data;
  if (O.ShowPets or O.ShowPetsWL or O.ShowPetsDK) then
    i = iVehicles + 1;
    for _, data in pairs(cPets) do
      if (data and UnitExists(data.Unit) and i <= maxPets) then
        --SMARTDEBUFF_AddMsgD("Set Pet: " .. unit .. ", " .. UnitName(unit) .. ", " .. uc);
        if (data.OwnerClass and not data.OwnerInVehicle
          and ((data.OwnerClass == "HUNTER" and O.ShowPets) or ((data.OwnerClass == "WARLOCK" or data.OwnerClass == "MAGE") and O.ShowPetsWL) or (data.OwnerClass == "DEATHKNIGHT" and O.ShowPetsDK))
          and (iGroupSetup ~= 3 or (iGroupSetup == 3 and O.DebuffGrp[data.Subgroup]))) then
          --SMARTDEBUFF_AddMsgD("Set Pet: " .. unit .. ", " .. UnitName(unit));
          SMARTDEBUFF_SetButton(data.Unit, i, 1);
          i = i + 1;
        end
      end
    end
  end
  --SMARTDEBUFF_AddMsgD("Debuff pet buttons set");

  SMARTDEBUFF_LinkSpellsToKeys();
  if (b) then
    SMARTDEBUFF_SetStyle();
  end
end


local function DebugButtonAttributes(self)
  -- ex: type1: spell, spell1: Detox
  if not IsModifierKeyDown() then
    return
  end;
  SMARTDEBUFF_AddMsgD("Hover button: "..self:GetName());
  for preKey, pre in pairs({[""] = "", ["S"] = "shift-", ["A"] = "alt-", ["C"] = "ctrl-"}) do
    for suf = 1, 3, 1 do
      for _, attr in ipairs({"type", "spell", "macro", "macrotext", "_menu", "item", "action", "index", "pet", "petaction"}) do
        local getAttr = self:GetAttribute(pre, attr, suf);
        local getType = self:GetAttribute(pre, "type", suf);
        local key = preKey..({"L", "R", "M"})[suf];

        if (getAttr and getType) then
          if (attr ~= "type" or getAttr == "target") then
            if (type(getAttr) ~= "string" and type(getAttr) ~= "number") then getAttr = type(getAttr) end;
            SMARTDEBUFF_AddMsgD("@"..self:GetAttribute("unit").." "..getType.." ["..pre..attr..suf.."] ("..key..") = "..getAttr);
          end
        end
      end
    end
  end
end

function SMARTDEBUFF_SetButton(unit, idx, pet)
  if (not canDebuff or InCombatLockdown()) then return; end

  local btn;
  if (pet) then
    btn = _G["SmartDebuffPetBtn"..idx];
  else
    btn = _G["SmartDebuffBtn"..idx];
  end

  if (not btn) then return; end
  btn:SetAttribute("unit", unit);

  if (O and O.Debug) then
    btn:SetScript("OnEnter", DebugButtonAttributes);
  end


  local pre = "";
  local suf = "";
  local mode = 1;
  if (O.TargetMode) then
    mode = 2;
  end
  --"L", "R", "M", "SL", "SR", "SM", "AL", "AR", "AM", "CL", "CR", "CM"
  for k, v in pairs(O.Keys[mode]) do
    if (k == "L") then
      pre = "";       suf = "1";
    elseif (k == "R") then
      pre = "";       suf = "2";
    elseif (k == "M") then
      pre = "";       suf = "3";
    elseif (k == "SL") then
      pre = "shift-"; suf = "1";
    elseif (k == "SR") then
      pre = "shift-"; suf = "2";
    elseif (k == "SM") then
      pre = "shift-"; suf = "3";
    elseif (k == "AL") then
      pre = "alt-";   suf = "1";
    elseif (k == "AR") then
      pre = "alt-";   suf = "2";
    elseif (k == "AM") then
      pre = "alt-";   suf = "3";
    elseif (k == "CL") then
      pre = "ctrl-";  suf = "1";
    elseif (k == "CR") then
      pre = "ctrl-";  suf = "2";
    elseif (k == "CM") then
      pre = "ctrl-";  suf = "3";
    end
    if (v and v[1]) then
      if (unit) then
        btn:SetAttribute(pre.."type"..suf, v[1]);
        --SMARTDEBUFF_AddMsgD(idx.." set: "..pre.."type"..suf..":"..v[1]);
        if ((v[1] == "spell" or v[1] == "item") and v[2]) then
          if (O.StopCast and (v[1] == "spell") and cSpellList[v[2]]) then
            local s = format("/stopcasting\n/cast [@%s] %s", unit, v[2]);
            btn:SetAttribute(pre.."type"..suf, "macro");
            btn:SetAttribute(pre.."macrotext"..suf, s);
            --SMARTDEBUFF_AddMsgD("Macro text: "..s);
          else
            btn:SetAttribute(pre..v[1]..suf, v[2]);
          end
          --SMARTDEBUFF_AddMsgD(idx.." set: "..pre..v[1]..suf..":"..v[2]);
        elseif ((v[1] == "action" or v[1] == "petaction") and v[2]) then
          -- Pet action bar (no stopcast, pet will cast ;) )
          btn:SetAttribute(pre.."type"..suf, "spell");
          btn:SetAttribute(pre.."spell"..suf, v[2]);
          -- SMARTDEBUFF_AddMsgD(idx.." set: "..pre..v[1]..suf..":"..v[2]);
        elseif ((v[1] == "macro") and v[2]) then
          btn:SetAttribute(pre..v[1]..suf, GetMacroIndexByName(v[2]) or v[2]);
        elseif ((v[1] == "target") and v[2]) then
          -- Do nothing
        elseif ((v[1] == "menu") and v[2]) then
          local showmenu;
          local btnName = btn:GetName();
          --SMARTDEBUFF_AddMsgD(btnName..", "..unit);
          showmenu = function()
            if (not InCombatLockdown()) then
              local dd = _G[btnName.."DropDown"];
              if (dd.initialize ~= SMARTDEBUFF_ButtonDropDown_Initialize) then
                CloseDropDownMenus();
                UIDropDownMenu_Initialize(dd, SMARTDEBUFF_ButtonDropDown_Initialize, "MENU");
              end
              ToggleDropDownMenu(1, nil, dd, btnName, btn:GetWidth()-2, 2);
            end
          end
          --SecureUnitButton_OnLoad(btn, unit, showmenu);
          btn:SetAttribute(pre.."type"..suf, "menu");
          btn:SetAttribute(pre.."_menu"..suf, showmenu);
        else
          btn:SetAttribute(pre.."type"..suf, nil);
          btn:SetAttribute(pre..v[1]..suf, nil);
        end
      else
        btn:SetAttribute(pre.."type"..suf, nil);
        btn:SetAttribute(pre..v[1]..suf, nil);
        local dd = _G[btn:GetName().."DropDown"];
        if (dd ~= nil) then dd.initialize = nil; end
      end
    else
      btn:SetAttribute(pre.."type"..suf, nil);
    end
  end

  --[[
    if (SDB_cachePlayerClass == "WARLOCK") then
      btn:SetAttribute("alt-type1", "pet");
      btn:SetAttribute("alt-action1", spell1);
    end
  ]]--

  if (unit) then
    btn:SetAlpha(0.5);
    if (not btn:IsVisible()) then btn:Show(); end
  else
    btn:SetAlpha(0.1);
    if (btn:IsVisible()) then btn:Hide(); end
  end
end

function SMARTDEBUFF_ButtonDropDown_Initialize(self)
	local menu;
	local name;
	local id = nil;
	local btn = self:GetParent();
	local unit = SecureButton_GetModifiedAttribute(btn, "unit", SecureButton_GetEffectiveButton(btn), "");

  if (unit == nil) then return; end

	--SMARTDEBUFF_AddMsgD("Dropdown: "..tostring(unit));
	if (UnitIsUnit(unit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(unit, "vehicle")) then
		-- NOTE: vehicle check must come before pet check for accuracy's sake because
		-- a vehicle may also be considered your pet
		menu = "VEHICLE";
	elseif (UnitIsUnit(unit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(unit)) then
		id = UnitInRaid(unit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id);
		elseif (UnitInParty(unit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(self, menu, unit, name, id);
	end
end

local sbs_btn, sbs_un, sbs_uc, sbs_st, sbs_fontH, sbs_pre, sbs_ln, sbs_wd, sbs_io, sbs_uv, sbs_iv, sbs_rc, sbs_cd;
local sbs_col = { r = 0.39, g = 0.42, b = 0.64 };
function SMARTDEBUFF_SetButtonState(unit, idx, nr, ir, ti, pet, spellcd)
  sbs_btn = nil;
  sbs_un = "";
  sbs_uc = "";
  sbs_st = "";
  sbs_uv = unit;
  sbs_iv = false;

  if (pet) then
    sbs_btn = _G["SmartDebuffPetBtn"..idx];
  else
    sbs_btn = _G["SmartDebuffBtn"..idx];
  end

  if (not sbs_btn) then return; end

  sbs_col.r = O.ColNormal.r; sbs_col.g = O.ColNormal.g; sbs_col.b = O.ColNormal.b;
  if (unit and LUnitExists(unit)) then
    if (not pet) then
      if (UnitInVehicle(unit) or UnitHasVehicleUI(unit)) then
        sbs_iv = true;
      end

      if (isLeader and not InCombatLockdown()) then
        sbs_rc = GetReadyCheckStatus(unit);
        if (sbs_rc ~= nil) then
          if (sbs_rc == "ready") then
            iTotRcRdy = iTotRcRdy + 1;
          elseif (sbs_rc == "notready") then
            iTotRcNRdy = iTotRcNRdy + 1;
          elseif (sbs_rc == "waiting") then
            iTotRcWait = iTotRcWait + 1;
          end
        end
      end

      sbs_un = UnitName(unit);
      if (iTest > 0) then
        sbs_uc = cUnits[unit].Class;
      else
        _, sbs_uc = UnitClass(unit);
      end
      if (O.ShowClassColors and sbs_uc and RAID_CLASS_COLORS[sbs_uc]) then
        sbs_col.r = 0.8 * RAID_CLASS_COLORS[sbs_uc].r;
        sbs_col.g = 0.8 * RAID_CLASS_COLORS[sbs_uc].g;
        sbs_col.b = 0.8 * RAID_CLASS_COLORS[sbs_uc].b;
      end
    else
      sbs_uv = string.gsub(unit, "pet", "");
      if (sbs_uv == "") then
        sbs_uv = "player";
      end
      if (UnitInVehicle(sbs_uv) or UnitHasVehicleUI(sbs_uv)) then
        sbs_un = "*"..UnitName(sbs_uv);
      else
        sbs_un = UnitName(unit);
      end

      if (pet and O.ShowClassColors) then
        sbs_col.r = 0.39; sbs_col.g = 0.42; sbs_col.b = 0.64;
      end
    end
  end

  if (not sbs_col.r or not sbs_col.g or not sbs_col.b) then
    sbs_col.r = O.ColNormal.r;
    sbs_col.g = O.ColNormal.g;
    sbs_col.b = O.ColNormal.b;
  end

  if (not sbs_iv and cSpellDefault["AL"] and cSpellDefault["AL"][3] ~= nil and O.ShowHealRange and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit)) then

    if (SDB_IsBaseSpellInRange(cSpellDefault["AL"][3], unit) == 1) then
      sbs_btn:SetBackdropBorderColor(0, 0, 0, 0);
    else
      if (nr > 0) then
        sbs_btn:SetBackdropBorderColor(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      else
        sbs_btn:SetBackdropBorderColor(1, 0, 0, 1);
      end
    end
  else
    sbs_btn:SetBackdropBorderColor(0, 0, 0, 0);
  end

  --SMARTDEBUFF_AddMsgD(un);
  -- GameFontHighlightSmall
  -- GameFontHighlightLarge
  -- SmartDebuff_GameFontHighlightMini

  sbs_fontH = O.Fontsize;

  if (unit and UnitExists(unit)) then
    sbs_pre = nil;
    sbs_ln = 5.5;
    sbs_wd = 0;

    if (iGroupSetup == 3 and O.ShowGrpNr and not pet) then
      sbs_un = cUnits[unit].Subgroup .. ":" .. sbs_un;
    end

    if (UnitIsAFK(unit)) then
      sbs_pre = "AFK";
      sbs_col.r = 0.2; sbs_col.g = 0.1; sbs_col.b = 0;
      iTotAFK = iTotAFK + 1;
    end

    sbs_io = false;
    if (not UnitIsConnected(unit) or SMARTDEBUFF_IsOffline(unit)) then
      sbs_io = true;
    end

    if (UnitIsDeadOrGhost(unit) or sbs_io) then
      if (sbs_io) then
        ir = 1;
        if (not pet) then
          sbs_pre = "OFF";
          iTotOFF = iTotOFF + 1;
        else
          sbs_pre = "REL";
        end
        sbs_col.r = 0; sbs_col.g = 0; sbs_col.b = 0;
      else
        if (sbs_uc and sbs_uc == "HUNTER" and SMARTDEBUFF_IsFeignDeath(unit)) then
          sbs_pre = "-FD-";
          sbs_col.r = 0.15; sbs_col.g = 0.05; sbs_col.b = 0;
        else
          if (UnitIsGhost(unit)) then
            sbs_pre = "GHO";
          else
            sbs_pre = "DEAD";
          end
          ir = 1;
          sbs_col.r = 0; sbs_col.g = 0; sbs_col.b = 0;
          iTotDead = iTotDead + 1;
        end
      end
    end
    if (sbs_pre) then
      sbs_ln = 5;
      sbs_wd = math.floor(sbs_btn:GetWidth() / sbs_ln - 1);
      if (string.len(sbs_pre) > sbs_wd) then
        sbs_pre = string.sub(sbs_pre, 1, sbs_wd);
      end
    end

    sbs_wd = math.floor(sbs_btn:GetWidth() / sbs_ln - 1);
    if (string.len(sbs_un) > sbs_wd) then
      --sbs_un = string.sub(sbs_un, 1, sbs_wd);
      sbs_un = sbs_un:utf8sub(1, sbs_wd);
    end

    if (sbs_pre) then
      sbs_un = sbs_pre .. "\n" .. sbs_un;
      sbs_fontH = sbs_fontH - 1;
    end
    sbs_st = sbs_un;
  else
    sbs_st = "?";
  end

  if (spellcd and spellcd > 0 and nr >= 1 and nr <= 3) then
    sbs_cd = string.format("%.0f", math.floor(spellcd + 0.5));
  else
    sbs_cd = "";
  end

  if (ti and ti > 0) then
    if (ti > 60) then
      --sbs_st = string.format("%.0fm", Round(ti/60, 0));
      sbs_st = string.format("%.0fm", math.floor((ti/60) + 0.5));
      --sbs_fontH = O.BtnH - 8;
    else
      --sbs_st = string.format("%.0f", Round(ti, 0));
      sbs_st = string.format("%.0f", math.floor(ti + 0.5));
      --sbs_fontH = O.BtnH - 6;
    end
    sbs_st = sbs_un.."\n"..sbs_st;
    if (sbs_cd ~= "") then
      sbs_st = sbs_st.." | "..sbs_cd;
    end
  end

  if (nr == 0) then
    sbs_btn.texture:SetColorTexture(sbs_col.r, sbs_col.g, sbs_col.b, 0.6);
    if (not sbs_pre and O.ShowGradient) then
      sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r / 4, sbs_col.g / 4, sbs_col.b / 4, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) );
    else
      sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) )
    end
    if (ir == 1) then
      sbs_btn:SetAlpha(O.ANormal);
    else
      sbs_btn:SetAlpha(O.ANormalOOR);
    end
  elseif (nr == 1) then
    SMARTDEBUFF_AddMsgD("L Dispel detected "..ir)
    sbs_col.r = O.ColDebuffL.r;
    sbs_col.g = O.ColDebuffL.g;
    sbs_col.b = O.ColDebuffL.b;
    if (ir == 1) then
      sbs_btn.texture:SetColorTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      if (O.ShowLR) then
        sbs_st = SMARTDEBUFF_KEY_L;
      end
    else
      sbs_btn.texture:SetColorTexture(sbs_col.r / 2, sbs_col.g / 2, sbs_col.b / 2, 1);
      if (O.ShowLR) then
        sbs_st = "-";
      end
    end
    sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) )
    sbs_btn:SetAlpha(O.ADebuff);
    if (O.ShowLR) then
      sbs_fontH = O.BtnH - 2;
    end
  elseif (nr == 2) then
    SMARTDEBUFF_AddMsgD("R Dispel detected "..ir)
    sbs_col.r = O.ColDebuffR.r;
    sbs_col.g = O.ColDebuffR.g;
    sbs_col.b = O.ColDebuffR.b;
    if (ir == 1) then
      sbs_btn.texture:SetColorTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      if (O.ShowLR) then
        sbs_st = SMARTDEBUFF_KEY_R;
      end
    else
      sbs_btn.texture:SetColorTexture(sbs_col.r / 2, sbs_col.g / 2, sbs_col.b / 2, 1);
      if (O.ShowLR) then
        sbs_st = "-";
      end
    end
    sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) )
    sbs_btn:SetAlpha(O.ADebuff);
    if (O.ShowLR) then
      sbs_fontH = O.BtnH - 2;
    end
  elseif (nr == 3) then
    SMARTDEBUFF_AddMsgD("M Dispel detected "..ir)
    sbs_col.r = O.ColDebuffM.r;
    sbs_col.g = O.ColDebuffM.g;
    sbs_col.b = O.ColDebuffM.b;
    if (ir == 1) then
      sbs_btn.texture:SetColorTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      if (O.ShowLR) then
        sbs_st = SMARTDEBUFF_KEY_M;
      end
    else
      sbs_btn.texture:SetColorTexture(sbs_col.r / 2, sbs_col.g / 2, sbs_col.b / 2, 1);
      if (O.ShowLR) then
        sbs_st = "-";
      end
    end
    sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) )
    sbs_btn:SetAlpha(O.ADebuff);
    if (O.ShowLR) then
      sbs_fontH = O.BtnH - 2;
    end
  elseif (nr == 10 and not UnitIsDeadOrGhost(unit)) then
    sbs_col.r = O.ColDebuffNR.r;
    sbs_col.g = O.ColDebuffNR.g;
    sbs_col.b = O.ColDebuffNR.b;
    sbs_btn.texture:SetColorTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
    sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) )
    sbs_btn:SetAlpha(O.ADebuff);
  else
    sbs_btn.texture:SetColorTexture(sbs_col.r, sbs_col.g, sbs_col.b, 0.9);
    if (not sbs_pre and O.ShowGradient) then
      sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r / 3, sbs_col.g / 3, sbs_col.b / 3, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) )
    else
      sbs_btn.texture:SetGradient("HORIZONTAL", CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1), CreateColor(sbs_col.r, sbs_col.g, sbs_col.b, 1) )
    end

    sbs_btn:SetAlpha(O.ANormalOOR);

    if (nr == -99) then
      -- unit does not longer exists
      if (iTest > 0) then
        sbs_btn:SetAlpha(O.ANormal);
      else
        sbs_btn:SetAlpha(0.1);
      end
    elseif (sbs_iv) then
      -- unit is in a vehicle
      sbs_btn:SetAlpha(O.ANormalOOR / 2);
    elseif (ir == 1 or UnitInRange(unit)) then
      -- unit is in range
      sbs_btn:SetAlpha(O.ANormal);
    else
      -- unit is oor
      sbs_btn:SetAlpha(O.ANormalOOR);
    end
  end

  sbs_btn.text:SetFont(STANDARD_TEXT_FONT, sbs_fontH, "");
  sbs_btn.text:SetText(sbs_st);
  sbs_btn.texture:SetAllPoints(sbs_btn);

  SmartDebuff_SetButtonBars(sbs_btn, unit, sbs_uc);
end

local sbb_w, sbb_h, sbb_upt, sbb_cur, sbb_nmax, sbb_n, sbb_dg, sbb_s, sbb_exp, sbb_gr, sbb_ach, sbb_x, sbb_xo, sbb_y;
local sbb_col = { r = 0, g = 1, b = 0 };
function SmartDebuff_SetButtonBars(btn, unit, unitclass)
  if (unit) then -- and btn:IsVisible()
    if (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)) then
      sbb_dg = true;
    else
      sbb_dg = false;
    end
    if (O.BarH > (btn:GetHeight() / 2)) then sbb_h = btn:GetHeight() / 2; else sbb_h = O.BarH; end
    --sbb_h = btn:GetHeight() / 4 - 1;
    sbb_w = btn:GetWidth();
    sbb_upt = UnitPowerType(unit);
    sbb_cur = UnitHealth(unit);
    sbb_nmax = UnitHealthMax(unit);
    sbb_n = math.floor(sbb_w * (sbb_cur / sbb_nmax));
    if (O.ShowHPText) then
      sbb_col.r = 0; sbb_col.g = 0.9; sbb_col.b = 0;
    else
      sbb_col.r = 0; sbb_col.g = 1.0; sbb_col.b = 0;
    end

    if UnitIsPlayer(unit) then
      iTotPlayers = iTotPlayers + 1;
      iTotHP = iTotHP + (sbb_cur * 100 / sbb_nmax);
    end

    if (O.Invert) then sbb_n = sbb_w - sbb_n; end
    if (sbb_nmax == 1 or sbb_n < 1 or sbb_n > sbb_w or sbb_dg or not O.ShowHP) then sbb_n = 0; end
    btn.hp:SetColorTexture(sbb_col.r, sbb_col.g, sbb_col.b, 1);
    if (O.ShowGradient) then
      btn.hp:SetGradient("HORIZONTAL", CreateColor(sbb_col.r / 2, sbb_col.g / 2, sbb_col.b / 2, 1), CreateColor(sbb_col.r, sbb_col.g, sbb_col.b, 1) )
    else
      btn.hp:SetGradient("HORIZONTAL", CreateColor(sbb_col.r, sbb_col.g, sbb_col.b, 1), CreateColor(sbb_col.r, sbb_col.g, sbb_col.b, 1) )
    end
    btn.hp:ClearAllPoints();
    btn.hp:SetPoint("TOPLEFT", btn , "TOPLEFT", 0, 0);
    btn.hp:SetPoint("TOPRIGHT", btn , "TOPLEFT", sbb_n, 0);
    btn.hp:SetPoint("BOTTOMLEFT", btn , "TOPLEFT", 0, -sbb_h);
    btn.hp:SetPoint("BOTTOMRIGHT", btn , "TOPLEFT", sbb_n, -sbb_h);

    sbb_n = math.ceil(sbb_cur / sbb_nmax * 100);
    if (not sbb_dg and sbb_n < 100 and O.ShowHPText) then
      btn.hptext:ClearAllPoints();
      btn.hptext:SetPoint("TOPLEFT", btn , "TOPLEFT", 1, 1);
      btn.hptext:SetPoint("TOPRIGHT", btn , "TOPLEFT", sbb_w, 1);
      btn.hptext:SetPoint("BOTTOMLEFT", btn , "TOPLEFT", 1, -sbb_h);
      btn.hptext:SetPoint("BOTTOMRIGHT", btn , "TOPLEFT", sbb_w, -sbb_h);
      btn.hptext:SetFont(STANDARD_TEXT_FONT, sbb_h+1, "");
      btn.hptext:SetText(sbb_n.."%");
    else
      btn.hptext:SetText("");
    end

    -- sbb_cur = UnitMana(unit);
    -- sbb_nmax = UnitManaMax(unit);
    sbb_cur = UnitPower(unit,0);
    sbb_nmax = UnitPowerMax(unit,0);
    sbb_n = math.floor(sbb_w * (sbb_cur / sbb_nmax));
    if (O.Invert) then sbb_n = sbb_w - sbb_n; end
    if (sbb_nmax == 1 or sbb_n < 1 or sbb_n > sbb_w or sbb_upt ~= 0 or sbb_dg or not O.ShowMana) then sbb_n = 0; end
    --if (n == max) then n = w; end;
    if (sbb_upt == 3) then
      -- 3 for Energy
      sbb_col.r = 1; sbb_col.g = 1; sbb_col.b = 0;
    elseif (sbb_upt == 2) then
      -- 2 for Focus (hunter pets)
      sbb_col.r = 1; sbb_col.g = 0.5; sbb_col.b = 0.25;
    elseif (sbb_upt == 1) then
      -- 1 for Rage
      sbb_col.r = 1; sbb_col.g = 0; sbb_col.b = 0;
    elseif (sbb_upt == 0) then
      -- 0 for Mana
      if (O.ShowClassColors and unitclass == "SHAMAN") then
        sbb_col.r = 0.5; sbb_col.g = 0.5; sbb_col.b = 1;
      else
        sbb_col.r = 0.2; sbb_col.g = 0.2; sbb_col.b = 1;
      end
      if UnitIsPlayer(unit) then
        iTotManaUser = iTotManaUser + 1;
        iTotMana = iTotMana + (sbb_cur * 100 / sbb_nmax);
      end
    else
      sbb_col.r = 0; sbb_col.g = 0; sbb_col.b = 0;
    end

    btn.mana:SetColorTexture(sbb_col.r, sbb_col.g, sbb_col.b, 1);

    btn.mana:ClearAllPoints();
    btn.mana:SetPoint("TOPLEFT", btn , "BOTTOMLEFT", 0, sbb_h);
    btn.mana:SetPoint("TOPRIGHT", btn , "BOTTOMLEFT", sbb_n, sbb_h);
    btn.mana:SetPoint("BOTTOMLEFT", btn , "BOTTOMLEFT", 0, 0);
    btn.mana:SetPoint("BOTTOMRIGHT", btn , "BOTTOMLEFT", sbb_n, 0);
    if (O.ShowGradient) then
      btn.mana:SetGradient("HORIZONTAL", CreateColor(sbb_col.r / 2, sbb_col.g / 2, sbb_col.b / 2, 1), CreateColor(sbb_col.r, sbb_col.g, sbb_col.b, 1) )
    else
      btn.mana:SetGradient("HORIZONTAL", CreateColor(sbb_col.r, sbb_col.g, sbb_col.b, 1), CreateColor(sbb_col.r, sbb_col.g, sbb_col.b, 1) )
    end

    sbb_n = math.ceil(sbb_cur / sbb_nmax * 100)
    if (not sbb_dg and sbb_upt == 0 and sbb_n < 100 and O.ShowHPText) then
      btn.manatext:ClearAllPoints();
      btn.manatext:SetPoint("TOPLEFT", btn , "BOTTOMLEFT", 1, sbb_h);
      btn.manatext:SetPoint("TOPRIGHT", btn , "BOTTOMLEFT", sbb_w, sbb_h);
      btn.manatext:SetPoint("BOTTOMLEFT", btn , "BOTTOMLEFT", 1, 0);
      btn.manatext:SetPoint("BOTTOMRIGHT", btn , "BOTTOMLEFT", sbb_w, 0);
      btn.manatext:SetFont(STANDARD_TEXT_FONT, sbb_h+1, "");
      btn.manatext:SetText(sbb_n.."%");
    else
      btn.manatext:SetText("");
    end

    --if (O.ShowAggro and sAggroList ~= nil and UnitIsPlayer(unit) and string.find(sAggroList, ":"..UnitName(unit)..":")) then
    if (O.ShowAggro) then
      sbb_n = UnitThreatSituation(unit);
      if (sbb_n and sbb_n >= 2) then
        btn.aggro:SetColorTexture(1, 1, 0, 1);
        btn.aggro:SetGradient("VERTICAL", CreateColor(1, 1, 1, 1), CreateColor(1, 0.2, 0.2, 1));
        btn.aggro:ClearAllPoints();
        btn.aggro:SetPoint("TOPLEFT", btn , "TOPLEFT", 0, -sbb_h);
        btn.aggro:SetPoint("TOPRIGHT", btn , "TOPLEFT", 3, -sbb_h);
        btn.aggro:SetPoint("BOTTOMLEFT", btn , "TOPLEFT", 0, -(btn:GetHeight() - sbb_h));
        btn.aggro:SetPoint("BOTTOMRIGHT", btn , "TOPLEFT", 3, -(btn:GetHeight() - sbb_h));
        btn.aggro:Show();
      else
        btn.aggro:Hide();
      end
    else
      btn.aggro:Hide();
    end

    if (O.ShowRaidIcon and (not sbb_dg or iTest > 0)) then
      sbb_n = 0;
      sbb_gr = "NONE";

      if (iGroupSetup == 2) then
        sbb_gr = UnitGroupRolesAssigned(unit);
      end

      if (isLeader and not InCombatLockdown()) then
        sbb_s = GetReadyCheckStatus(unit);
        if (sbb_s ~= nil) then
          if (sbb_s == "ready") then
            sbb_n = 9;
          elseif (sbb_s == "notready") then
            sbb_n = 10;
          elseif (sbb_s == "waiting") then
            sbb_n = 11;
          end
        end
      end

      if (sbb_n == 0) then
        sbb_n = GetRaidTargetIndex(unit);
        if (iTest > 0) then
          if (Round(math.random(1,5)) == 1) then
            sbb_n = nil;
          else
            sbb_n = Round(math.random(0,11));
          end
        end
      end

      if ((sbb_n ~= nil and sbb_n >= 1) or (sbb_gr ~= "NONE" and not O.SortedByRole)) then
        if (sbb_n ~= nil) then
          btn.raidicon:SetTexture(cRaidicons[sbb_n]);
          btn.raidicon:SetTexCoord(0, 1, 0, 1);
        else
          sbb_s = IconCoords[sbb_gr];
          --btn.raidicon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
          btn.raidicon:SetTexture(Icons["ROLE"]);
          btn.raidicon:SetTexCoord(sbb_s[1], sbb_s[2], sbb_s[3], sbb_s[4]);
          --[[
          if (sbb_gr == "TANK") then
            btn.raidicon:SetTexCoord(0, 19/64, 22/64, 41/64);
          elseif (sbb_gr == "HEALER") then
            btn.raidicon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
          else -- "DAMAGER"
            btn.raidicon:SetTexCoord(20/64, 39/64, 22/64, 41/64);
          end
          ]]--
          if (sbb_gr == "DAMAGER") then
            btn.raidicon:Hide();
            return;
          end
        end
        --sbb_n = btn:GetHeight() / 3;
        sbb_n = O.RaidIconSize;
        btn.raidicon:ClearAllPoints();
        btn.raidicon:SetPoint("BOTTOMRIGHT", btn , "BOTTOMRIGHT", O.BtnSpX, -O.BtnSpY);
        btn.raidicon:SetWidth(sbb_n);
        btn.raidicon:SetHeight(sbb_n);
        btn.raidicon:Show();
      else
        btn.raidicon:Hide();
      end
    else
      btn.raidicon:Hide();
    end
    --Semi #1287 - Edited Code for Spell Guard to show  -begin
    if (O.ShowSpellIcon) then
      for loop2 = 1, math.min(#O.SpellGuard, maxSpellIcons), 1 do
        local name, texture, count, debuffType, duration, expirationTime, source, _, _, spellID = AuraUtil.FindAuraByName(O.SpellGuard[loop2], unit);
        if name == nil then
          name, texture, count, debuffType, duration, expirationTime, source, _, _, spellID = AuraUtil.FindAuraByName(O.SpellGuard[loop2], unit, "HARMFUL");
        end
        if name == nil then
          name, texture, count, debuffType, duration, expirationTime, source, _, _, spellID = AuraUtil.FindAuraByName(O.SpellGuard[loop2], unit, "NOT_CANCELABLE");
        end
        if name == nil then
          name, texture, count, debuffType, duration, expirationTime, source, _, _, spellID = AuraUtil.FindAuraByName(O.SpellGuard[loop2], unit, "CANCELABLE");
        end
        if name == nil then
          name, texture, count, debuffType, duration, expirationTime, source, _, _, spellID = AuraUtil.FindAuraByName(O.SpellGuard[loop2], unit, "RAID");
        end
        if name == nil then
          name, texture, count, debuffType, duration, expirationTime, source, _, _, spellID = AuraUtil.FindAuraByName(O.SpellGuard[loop2], unit, "PLAYER");
        end
        if name ~= nil then
            sbb_s = texture;
            sbb_exp = tonumber(expirationTime) or 0;
            if sbb_exp > 0 then
              sbb_exp = (sbb_exp - GetTime()) / 10 + 0.1;
              if (sbb_exp > 0.9) then
                sbb_exp = 0.9;
              end
            else -- Happened.. while leaving instance?
              sbb_exp = 0;
            end
            btn.spellicon[loop2]:SetTexture(sbb_s);
            sbb_n = btn:GetHeight() / 3;
            --sbb_n = O.RaidIconSize;

            sbb_ach = "TOPLEFT";
            sbb_y = 2;
            if (loop2 % 2 == 0) then
              sbb_ach = "BOTTOMLEFT";
              sbb_y = -2+sbb_n;
            end

            if (loop2 <= 2) then
              sbb_x = sbb_w/2;
            else
              sbb_xo = math.ceil(loop2/2);
              if (sbb_xo % 2 == 0) then
                sbb_x = sbb_w/2 - sbb_xo*sbb_n/2;
              else
                sbb_x = sbb_w/2 + sbb_xo*sbb_n/2 - sbb_n/2;
              end
            end
            sbb_xo = sbb_n/2;
            btn.spellicon[loop2]:ClearAllPoints();
            btn.spellicon[loop2]:SetPoint("TOPLEFT", btn , sbb_ach, sbb_x - sbb_xo, sbb_y);
            btn.spellicon[loop2]:SetPoint("TOPRIGHT", btn , sbb_ach, sbb_x + sbb_xo, sbb_y);
            btn.spellicon[loop2]:SetPoint("BOTTOMLEFT", btn , sbb_ach, sbb_x - sbb_xo, sbb_y-sbb_n);
            btn.spellicon[loop2]:SetPoint("BOTTOMRIGHT", btn , sbb_ach, sbb_x + sbb_xo, sbb_y-sbb_n);
            btn.spellicon[loop2]:SetAlpha(sbb_exp);
            btn.spellicon[loop2]:Show();
        else
            btn.spellicon[loop2]:Hide();
        end
      end
    else
      if (btn.spellicon[1]:IsVisible()) then
        for loop2 = 1, maxSpellIcons, 1 do
          btn.spellicon[loop2]:Hide();
        end
      end
    end
    --Semi #1287 - Edited code for spell guard to show -end
  end
end

local shl_wd;
function SMARTDEBUFF_SetHeaderLabels(text, n, btn, icon)
  --SMARTDEBUFF_AddMsgD(n.." "..text);
  local lbl = _G["SmartDebuffTxt"..n];
  if (btn and btn:IsVisible() and O.ShowHeaders) then
    if (icon ~= nil and IconCoords[text] ~= nil) then
      local ic = IconCoords[text];
      lbl:SetText("");
      lbl:Show();
      --SMARTDEBUFF_AddMsgD(Icons[icon]);
      lbl.icon:SetTexture(Icons[icon]);
      lbl.icon:SetTexCoord(ic[1], ic[2], ic[3], ic[4]);
      lbl.icon:ClearAllPoints();
      if (O.VerticalUp) then
        lbl.icon:SetPoint("TOP", btn, "BOTTOM", 0, 0);
      else
        lbl.icon:SetPoint("BOTTOM", btn, "TOP", 0, 0);
      end
      lbl.icon:SetWidth(12);
      lbl.icon:SetHeight(12);
      lbl.icon:Show();
    else
      lbl.icon:Hide();
      if (not text) then text = ""; end
      shl_wd = math.floor(btn:GetWidth() / 4 - 2);
      if (string.len(text) > shl_wd) then
        text = string.sub(text, 1, shl_wd);
      end
      if (text ~= nil) then
        lbl:SetText(text);
      else
        lbl:SetText("");
      end
      lbl:ClearAllPoints();
      if (O.VerticalUp) then
        lbl:SetPoint("TOP", btn, "BOTTOM", 0, -1);
      else
        lbl:SetPoint("BOTTOM", btn, "TOP", 0, 1);
      end
      lbl:SetWidth(btn:GetWidth());
      lbl:SetHeight(12);
      if (not lbl:IsVisible()) then
        lbl:Show();
      end
    end
  else
    lbl:SetText("");
    if (lbl:IsVisible()) then
      lbl:Hide();
    end
  end
end

function SMARTDEBUFF_SetStyle()
  if (not canDebuff) then return; end

  local frmH, frmW, btnH, btnW;
  local nMax = 0;
  local frame = _G["SmartDebuffSF"];
  local vu = 1;
  local anchor = "TOPLEFT";

  --if (not frame:IsVisible()) then return; end;
  if (not SMARTDEBUFF_IsVisible()) then return; end;

  if (O.VerticalUp) then
    vu = -1;
    anchor = "BOTTOMLEFT";
  end

  for i = 1, maxColumns, 1 do
    SMARTDEBUFF_SetHeaderLabels("", i, nil, nil);
  end

  if (iGroupSetup == 3) then
    nMax = maxRaid;
  elseif (iGroupSetup == 2) then
    nMax = 5;
  elseif (iGroupSetup == 1) then
    nMax = 1;
  else
    return;
  end

  btnW = O.BtnW;
  btnH = O.BtnH;

  local i = 0;
  local j = 0;
  local btn, lbl;
  local sp = 0;
  local ln = 0;
  local offX = 0;
  local offY = 0;
  local grp = 0;
  local sbtn, unit, uc, luc;
  local b = true;
  local hx = 4;
  local hox = 0;
  local tX = 0;
  local tY = 0;
  local maxR = 5;
  local lmaxR = 0;
  local ur = "";
  local nT = 0;
  local nH = 0;
  local nD = 0;
  local ugrp = 0;

  if (O.ShowHeaderRow) then
    hx = 16;
  end
  if (O.ShowInfoRow and iGroupSetup >= 3) then
    hx = hx + 9;
    SmartDebuff_lblInfoRow:ClearAllPoints();
    if (O.VerticalUp) then
      SmartDebuff_lblInfoRow:SetPoint(anchor, frame, anchor, 1, hx - 13);
    else
      SmartDebuff_lblInfoRow:SetPoint(anchor, frame, anchor, 1, -hx + 13);
    end
    SmartDebuff_lblInfoRow:Show();
  else
    SmartDebuff_lblInfoRow:Hide();
  end
  if (O.ShowHeaders) then
    hox = 7;
  end

  tY = 0;
  for j = 0, (nMax - 1), 1 do
    btn = _G["SmartDebuffBtn"..(j + 1)];
    btn:SetWidth(btnW);
    btn:SetHeight(btnH);
    sbtn = SecureButton_GetEffectiveButton(btn);
    unit = SecureButton_GetModifiedAttribute(btn, "unit", sbtn, "");

    if (unit and not _G.InCombatLockdown()) then
      if (O.SortedByRole and (isRoleSet or iTest > 0)) then
        if (btn:IsVisible()) then
          if (iTest > 0) then
            ur = "DAMAGER";
            if (math.fmod(j+1,3) == 0) then ur = "HEALER"; end
            if (math.fmod(j+1,10) == 0) then ur = "TANK"; end
          else
            ur = UnitGroupRolesAssigned(unit);
          end

          if (ur == "TANK") then
            i = nT;
            nT = nT + 1;
            ugrp = 1;
          elseif (ur == "HEALER") then
            i = nH;
            nH = nH + 1;
            ugrp = 2;
          else
            i = math.fmod(nD, 10);
            nD = nD + 1;
            ugrp = 2 + math.ceil(nD/10);
          end
          if (i + 1 > maxR) then maxR = i + 1; end
          sp = (ugrp - 1) * (btnW + O.BtnSpX);

          if ((grp - 1) > 0 and math.fmod((grp - 1), O.Columns) == 0) then
            ln = offY + 4 + hox;
            sp = 0;
          end
          btn:ClearAllPoints();
          btn:SetPoint(anchor, frame, anchor, 4 + sp, (-hx - hox - i * (btnH + O.BtnSpY) - ln) * vu);
          if (i == 0) then
            grp = grp + 1;
            --SMARTDEBUFF_AddMsgD("Set label = "..ur..", "..ugrp);
            SMARTDEBUFF_SetHeaderLabels(ur, ugrp, btn, "ROLE");
          end
        end

      elseif (O.SortedByClass) then
        if (j == 0) then ln = hx+hox; end
        if (btn:IsVisible()) then
          if (iTest > 0) then
            uc = cUnits[unit].Class;
          else
            _, uc = UnitClass(unit);
          end

          if (j == 0) then luc = uc; end

          if (j > 0 and luc ~= uc) then
            if (lmaxR > maxR) then
              maxR = lmaxR;
            end
            lmaxR = 0;
            luc = uc;
            i = 0;
            sp = sp + btnW + O.BtnSpX;
            b = true;
          end
          if (b and grp > 0 and math.fmod(grp, O.Columns) == 0) then
            ln = offY+hox;
            sp = 0;
          end
          lmaxR = lmaxR + 1;
          btn:ClearAllPoints();
          btn:SetPoint(anchor, frame, anchor, 4 + sp, (- i * (btnH + O.BtnSpY) - ln) * vu);
          if (b) then
            grp = grp + 1;
            SMARTDEBUFF_SetHeaderLabels(SMARTDEBUFF_CLASSES[uc], grp, btn);
            --SMARTDEBUFF_SetHeaderLabels(uc, grp, btn, "CLASSES");
            b = false;
          end
        end

      elseif (O.Vertical) then
        if (j > 0 and math.fmod(j, 5) == 0) then
          i = 0;
          sp = sp + btnW + O.BtnSpX;
          b = true;
        end
        if (j > 0 and math.fmod(j, (O.Columns * 5)) == 0) then
          sp = 0;
          ln = ln + 5 * (btnH + O.BtnSpY) + hox;
        end
        btn:ClearAllPoints();
        btn:SetPoint(anchor, frame, anchor, 4 + sp, (-hx - hox - i * (btnH + O.BtnSpY) - ln) * vu);
        if (b) then
          grp = grp + 1;
          SMARTDEBUFF_SetHeaderLabels("G"..cUnits[unit].Subgroup, grp, btn, nil);
          b = false;
        end
      else
        if (j > 0 and math.fmod(j, 5) == 0) then
          sp = sp + O.BtnSpX;
          b = true;
        end
        if (j > 0 and math.fmod(j, (O.Columns * 5)) == 0) then
          ln = ln + 1;
          sp = 0;
          i = 0;
        end
        btn:ClearAllPoints();
        btn:SetPoint(anchor, frame, anchor, 4 + i * (btnW + O.BtnSpX) + sp, (-hx - hox - ln * (btnH + O.BtnSpY + hox)) * vu);
        if (b) then
          grp = grp + 1;
          SMARTDEBUFF_SetHeaderLabels("G"..cUnits[unit].Subgroup, grp, btn, nil);
          b = false;
        end
      end

      if (btn:IsVisible()) then
        tX = btn:GetLeft() - frame:GetLeft() + btnW + 8;
        if (O.VerticalUp) then
          tY = frame:GetBottom() - btn:GetTop() - 4;
        else
          tY = frame:GetTop() - btn:GetBottom() + 4;
        end
        if (tX > offX) then
          offX = tX;
        end
        if (math.abs(tY) > math.abs(offY)) then
          offY = math.abs(tY);
        end
        --SMARTDEBUFF_AddMsgD("Get button values");
      end
    end
    i = i + 1;
  end

  i = 0;
  j = 0;
  sp = 0;
  ln = 0;
  b = true;
  local offPX = offX;
  local offPY = -offY-hox;
  if (O.SortedByClass or O.Vertical or O.SortedByRole) then offPY = -offY+hx; end
  for j = 0, (maxPets - 1), 1 do
    btn = _G["SmartDebuffPetBtn"..(j + 1)];
    btn:SetWidth(btnW);
    btn:SetHeight(btnH);

    if (O.SortedByClass or O.Vertical or O.SortedByRole) then
      if (j == 0) then ln = hx+hox; end
      if (math.ceil(iVehicles / 5) > math.floor(O.Columns / 2)) then
        offX = 4;
      else
        offPY = 0;
      end
      if (j > 0 and math.fmod(j, maxR) == 0) then
        i = 0;
        sp = sp + btnW + O.BtnSpX;
      end
      if (j > 0 and math.fmod(j, O.Columns * 5) == 0) then
        sp = 0;
        ln = ln + 5 * (btnH + O.BtnSpY);
      end
      btn:ClearAllPoints();
      btn:SetPoint(anchor, frame, anchor, offX + sp, offPY * vu + (-i * (btnH + O.BtnSpY) - ln) * vu);
    else
      if (j == 0) then ln = 0; end
      if (j > 0 and math.fmod(j, 5) == 0) then
        sp = sp + O.BtnSpX;
      end
      if (j > 0 and math.fmod(j, O.Columns * 5) == 0) then
        ln = ln + 1;
        sp = 0;
        i = 0;
      end
      btn:ClearAllPoints();
      --btn:SetPoint(anchor, frame, anchor, 4 + i * (btnW + O.BtnSpX) + sp, offPY + (-hx - hox - ln * (btnH + O.BtnSpY + hox)) * vu);
      btn:SetPoint(anchor, frame, anchor, 4 + i * (btnW + O.BtnSpX) + sp, offPY * vu + (-ln * (btnH + O.BtnSpY)) * vu);
    end
    if (b) then
      grp = grp + 1;
      SMARTDEBUFF_SetHeaderLabels("Pets", grp, btn);
      --SMARTDEBUFF_SetHeaderLabels("PET", grp, btn, "PET");
      b = false;
    end
    if (btn:IsVisible()) then
      tX = btn:GetLeft() - frame:GetLeft() + btnW + 8;
      if (O.VerticalUp) then
        tY = frame:GetBottom() - btn:GetTop() - 4;
      else
        tY = frame:GetTop() - btn:GetBottom() + 4;
      end
      if (tX > offPX) then
        offPX = tX;
      end
      if (math.abs(tY) > math.abs(offY)) then
        offY = math.abs(tY);
      end
    end
    i = i + 1;
  end

  frmW = offPX - 4;
  frmH = offY;
  if (frmW < 92 and O.ShowInfoRow and iGroupSetup >= 3) then frmW = 92; end
  if (frmW < 120 and O.ShowHeaderRow) then frmW = 120; end
  if (frmH < 20) then frmH = 20; end

  if (O.AdvAnchors) then
    frame:ClearAllPoints();
    frame:SetPoint(O.SFPosP, UIParent, O.SFPosRP, O.SFPosX, O.SFPosY);
  end
  frame:SetSize(frmW, frmH);

  --SMARTDEBUFF_AddMsgD("Debuff style set");
  SMARTDEBUFF_CheckDebuffs(true);
end


function SMARTDEBUFF_ToggleClassColors()
  O.ShowClassColors = SMARTDEBUFF_toggleBool(O.ShowClassColors, "Use class colors = ");
  if (SmartDebuffOF:IsVisible()) then
    SmartDebuffOF_cbClassColors:SetChecked(O.ShowClassColors);
  end
  SMARTDEBUFF_CheckDebuffs(true);
end

function SMARTDEBUFF_ToggleShowLR()
  O.ShowLR = SMARTDEBUFF_toggleBool(O.ShowLR, "Show L/R = ");
  if (SmartDebuffOF:IsVisible()) then
    SmartDebuffOF_cbShowLR:SetChecked(O.ShowLR);
  end
  SMARTDEBUFF_CheckDebuffs(true);
end

function SMARTDEBUFF_ToggleSortedByClass()
  O.SortedByClass = SMARTDEBUFF_toggleBool(O.SortedByClass, "Sorted by class = ");
  SMARTDEBUFF_SetButtons();
end


function SMARTDEBUFF_ButtonTooltipOnEnter(self)
  if (not self or not self:IsVisible() or InCombatLockdown() or not O.ShowTooltip) then return; end

  local sbtn = SecureButton_GetEffectiveButton(self);
  local unit = SecureButton_GetModifiedAttribute(self, "unit", sbtn, "");
  if (unit) then
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
    GameTooltip:SetUnit(unit);
    GameTooltip:Show();
  end
end

function SMARTDEBUFF_ButtonTooltipOnLeave()
  GameTooltip:Hide();
end

local gtl_text, gtl_obj;
function SMARTDEBUFF_GetTooltipLine(line)
  gtl_text = nil;
  gtl_obj = _G["SmartDebuffTooltipTextLeft" .. line];
  if (gtl_obj) then
    gtl_text = gtl_obj:GetText();
  end
  return gtl_text;
end

local io_text, io_nl, io_gname, io_i;
function SMARTDEBUFF_IsOffline(unit)
  if (unit and UnitIsPlayer(unit)) then
    SmartDebuffTooltip:ClearLines();
    SmartDebuffTooltip:SetUnit(unit);
    io_nl = SmartDebuffTooltip:NumLines();
    io_gname = GetGuildInfo(unit);
    for io_i = 1, io_nl, 1 do
      io_text = SMARTDEBUFF_GetTooltipLine(io_i);
      if (io_text) then
        --SMARTDEBUFF_AddMsgD("Tooltip: " .. io_text);
        if (io_text ~= UnitName(unit) and io_text ~= io_gname and string.find(string.lower(io_text), "offline")) then
          return true;
        end
      end
    end
  end
  return false;
end

-- END SmartDebuff frame functions


-- SmartDebuff functions ---------------------------------------------------------------------------------------
-- Main check function, called by update event
local cd_i, cd_unit, cd_btn, cd_sbtn, cd_spell;
function SMARTDEBUFF_CheckDebuffs(force)
  if (not isInit or not canDebuff or (not force and GetTime() < (tDebuff + O.CheckInterval))) then
    return;
  end
  tDebuff = GetTime();
  hasDebuff = false;

  if (SMARTDEBUFF_IsVisible() and cSpells) then
    --SMARTDEBUFF_AddMsgD(string.format("Debuff check (%.1f): %.2f", O.CheckInterval, tDebuff));

    iTotMana = 0;
    iTotHP = 0;
    iTotAFK = 0;
    iTotOFF = 0;
    iTotDead = 0;
    iTotPlayers = 0;
    iTotManaUser = 0;
    iTotRcRdy = -1;
    iTotRcNRdy = 0;
    iTotRcWait = 0;

    --[[
    sAggroList = ":";
    if (O.ShowAggro) then
      for cd_i = 1, maxRaid, 1 do
        cd_btn = _G["SmartDebuffBtn"..cd_i];
        cd_sbtn = SecureButton_GetEffectiveButton(cd_btn);
        if (cd_sbtn) then
          cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
          if (cd_unit and UnitExists(cd_unit)) then
            if (UnitName(cd_unit.."target") and not UnitIsPlayer(cd_unit.."target") and UnitName(cd_unit.."targettarget")) then
              if (not string.find(sAggroList, ":"..UnitName(cd_unit.."targettarget")..":")) then
                sAggroList = sAggroList..UnitName(cd_unit.."targettarget")..":";
              end
            end
            if (UnitName(cd_unit.."targettarget") == UnitName(cd_unit) and not UnitIsPlayer(cd_unit.."target")) then
              if (not string.find(sAggroList, ":"..UnitName(cd_unit)..":")) then
                sAggroList = sAggroList..UnitName(cd_unit)..":";
              end
            end
          end
        end
      end
    end
    ]]--

    for cd_i = 1, maxRaid, 1 do
      cd_btn = _G["SmartDebuffBtn"..cd_i];
      cd_sbtn = SecureButton_GetEffectiveButton(cd_btn);
      if (cd_sbtn and cd_btn:IsVisible()) then
        cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
        cd_spell = cSpellDefault["L"][3];
        if (cd_unit) then
          if (UnitExists(cd_unit)) then
            --SMARTDEBUFF_AddMsgD("Unit found: " .. unit .. ", " .. UnitName(unit) .. ", " .. i);
            SMARTDEBUFF_CheckUnitDebuffs(cd_spell, cd_unit, cd_i, isSpellActive);
          else
            SMARTDEBUFF_SetButtonState(cd_unit, cd_i, -99, 0, -1);
          end
        end
      end
    end

    --SmartDebuffIF_lblInfo:SetText(string.format("|cff20d2ff.:Info:.|r\nPlayers: |cffffffff%d|r\nHP: |cffffffff%.1f%%|r\nMana: |cffffffff%.1f%%|r\nDead: |cffffffff%d|r\nAFK: |cffffffff%d|r\nOffline: |cffffffff%d|r", iTotPlayers, iTotHP / iTotPlayers, iTotMana / iTotManaUser, iTotDead, iTotAFK, iTotOFF));
    if (iTotManaUser == 0) then iTotManaUser = 1; end
    iTmp = iTotPlayers;
    if (iTmp == 0) then iTmp = 1; end
    if (iTest > 0) then
      iTotHP = 100;
      iTotMana = 100;
      iTotRcRdy  = math.floor(iTest/3);
      iTotRcNRdy = math.floor(iTest/5);
      iTotRcWait = math.floor(iTest/2);
    end
    if (iTotRcRdy >= 0) then
      iTotRcRdy = iTotRcRdy + 1;
      if (O.ShowInfoRow) then
        SmartDebuff_lblInfoRow:SetText(string.format("%s%d|r/%s%d|r/%s%d|r/%s%d|r  %s%.0f|r/%s%.0f|r  %s%d|r/%s%d|r/%s%d|r", WH, iTotPlayers, RD, iTotDead, YL, iTotAFK, GYL, iTotOFF, GRL, iTotHP/iTmp, BLL, iTotMana/iTotManaUser, GR, iTotRcRdy, RD, iTotRcNRdy, YL, iTotRcWait));
      end
      if (O.ShowIF) then
        SmartDebuffIF:SetHeight(80);
        SmartDebuffIF_lblInfo:SetText("Players:\nHP %:\nMana %:\nDead:\nAFK:\nOffline:\nReady:");
        SmartDebuffIF_lblOut:SetText(string.format("%d\n%.1f\n%.1f\n%d\n%d\n%d\n%s%d|r/%s%d|r/%s%d|r", iTotPlayers, iTotHP/iTmp, iTotMana/iTotManaUser, iTotDead, iTotAFK, iTotOFF, GR, iTotRcRdy, RD, iTotRcNRdy, YL, iTotRcWait));
      end
    else
      if (O.ShowInfoRow) then
        SmartDebuff_lblInfoRow:SetText(string.format("%s%d|r/%s%d|r/%s%d|r/%s%d|r  %s%.0f|r/%s%.0f|r", WH, iTotPlayers, RD, iTotDead, YL, iTotAFK, GYL, iTotOFF, GRL, iTotHP/iTmp, BLL, iTotMana/iTotManaUser));
      end
      if (O.ShowIF) then
        SmartDebuffIF:SetHeight(70);
        SmartDebuffIF_lblInfo:SetText("Players:\nHP %:\nMana %:\nDead:\nAFK:\nOffline");
        SmartDebuffIF_lblOut:SetText(string.format("%d\n%.1f\n%.1f\n%d\n%d\n%d", iTotPlayers, iTotHP/iTmp, iTotMana/iTotManaUser, iTotDead, iTotAFK, iTotOFF));
      end
    end

    if (O.ShowPets or O.ShowPetsWL or O.ShowPetsDK) then
      for cd_i = 1, maxPets, 1  do
        cd_btn = _G["SmartDebuffPetBtn"..cd_i];
        cd_sbtn = SecureButton_GetEffectiveButton(cd_btn);
        if (cd_sbtn and cd_btn:IsVisible()) then
          cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
          cd_spell = cSpellDefault["L"][3];
          if (cd_unit) then
            if (UnitExists(cd_unit)) then
              --SMARTDEBUFF_AddMsgD("Pet found: " .. unit .. ", " .. UnitName(unit) .. ", " .. i);
              SMARTDEBUFF_CheckUnitDebuffs(cd_spell, cd_unit, cd_i, isSpellActive, 1);
            else
              SMARTDEBUFF_SetButtonState(cd_unit, cd_i, -99, 0, -1, 1);
            end
          end
        end
      end
    end

    --SMARTDEBUFF_AddMsgD("Debuffs checked");
  end

  SMARTDEBUFF_CheckAutoHide();
  if (not hasDebuff) then
    isSoundPlayed = false;
  end
end

-- Dectects debuffs on a single unit
local cud_name, cud_icon, cud_dtype, cud_uclass, cud_ir, cud_n, cud_dur, cud_tl, cud_nrd, cud_un, cud_tlnr, cud_cds;
function SMARTDEBUFF_CheckUnitDebuffs(spell, unit, idx, isActive, pet)
  cud_n = -1;
  cud_nrd = false;
  if ((spell or O.ShowNotRemov) and isActive) then
    if (spell == nil) then
      cud_ir = -1;
    elseif (
      (SDB_cacheRangeCheckSpell and IsSpellInRange(SDB_cacheRangeCheckSpell, unit) == 1)
      or SDB_IsBaseSpellInRange(spell, unit) == 1 -- type(spell) ~= "number" and IsSpellInRange
      or UnitInRange(unit)
    ) then
      cud_ir = 1;
    else
      cud_ir = 0;
    end
    -- SMARTDEBUFF_AddMsgD("Check unit: " .. unit .. ", " .. UnitName(unit) .. ", " .. idx.." spell: "..spell.." / In Range: "..SDB_cacheRangeCheckSpell.." : "..IsSpellInRange(SDB_cacheRangeCheckSpell, unit));

    cud_n = 1;
    while (true) do
      --name,rank,icon,count,type = UnitDebuff("unit", id or "name"[,"rank"])
      --cud_name, _, cud_icon, _, cud_dtype, cud_dur, cud_tl, _ = UnitAura(unit, cud_n, "HARMFUL");
      -- BlizzardInterfaceCode\Interface\AddOns\Blizzard_NamePlates\Blizzard_NamePlates.lua:505
      -- local name, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura(unit, i, filter);
      cud_name, cud_icon, _, cud_dtype, cud_dur, cud_tl, _ = UnitAura(unit, cud_n, "HARMFUL");
      if (not cud_icon) then
        break;
      end

      cud_tl = tonumber(cud_tl);
      if (cud_tl == nil) then cud_tl = -1; end
      if (not cud_tl) then cud_tl = -1; end
      cud_tl = cud_tl - GetTime();

      if (spell and cud_name and cud_dtype) then
        -- SMARTDEBUFF_AddMsgD("Debuff found: " .. cud_dtype.." on "..unit.." (" .. cud_name .. ")");
        _, cud_uclass = UnitClass(unit);

        if (cSpells[cud_dtype] and (not UnitCanAttack("player", unit) or UnitIsCharmed(unit)) and not SMARTDEBUFF_DEBUFFSKIPLIST[cud_name] and not (SMARTDEBUFF_DEBUFFCLASSSKIPLIST[cud_uclass] and SMARTDEBUFF_DEBUFFCLASSSKIPLIST[cud_uclass][cud_name])) then
          cud_cds = GetSpellCD(cSpells[cud_dtype][1]);
          if (not O.IgnoreDebuff or cud_cds <= 0) then
            hasDebuff = true;
            SMARTDEBUFF_SetButtonState(unit, idx, cSpells[cud_dtype][2], cud_ir, cud_tl, pet, cud_cds);
            SMARTDEBUFF_PlaySound();
            return;
          end
        end
      end

      -- Check if a player has an unremovable debuff
      if (not cud_nrd and O.ShowNotRemov and cud_name and not cud_dtype) then
        for _, v in ipairs(O.NotRemovableDebuffs) do
          if (v and cud_name and v == cud_name) then
            cud_nrd = true;
            cud_tlnr = cud_tl;
            break;
          end
        end
      end

      cud_n = cud_n + 1;
      --SMARTDEBUFF_AddMsgD("Check debuff");
    end

    -- check if a player is charmed, can be attacked and is polymorphable
    if (cSpells[SMARTDEBUFF_CHARMED] and UnitIsCharmed(unit) and UnitCanAttack("player", unit) and UnitCreatureType(unit) == SMARTDEBUFF_HUMANOID) then
      cud_cds = GetSpellCD(cSpells[SMARTDEBUFF_CHARMED][1]);
      if (not O.IgnoreDebuff or cud_cds <= 0) then
        hasDebuff = true;
        SMARTDEBUFF_SetButtonState(unit, idx, cSpells[SMARTDEBUFF_CHARMED][2], cud_ir, cud_tl, pet, cud_cds);
        SMARTDEBUFF_PlaySound();
        return;
      end
    end

    if (cud_nrd) then
      hasDebuff = true;
      SMARTDEBUFF_SetButtonState(unit, idx, 10, 1, cud_tlnr, pet);
      SMARTDEBUFF_PlaySound();
      return;
    end

    SMARTDEBUFF_SetButtonState(unit, idx, 0, cud_ir, -1, pet);
  else
    SMARTDEBUFF_SetButtonState(unit, idx, -1, 0, -1, pet);
  end

end

function SMARTDEBUFF_PlaySound()
  if (O.UseSound and not isSoundPlayed) then
    PlaySoundFile(SMARTDEBUFF_SOUNDS[O.Sound][2], "master");
    isSoundPlayed = true;
    --SMARTDEBUFF_AddMsgD("Play sound");
  end
end
-- END SmartDebuff functions


-- SmartDebuff option frame functions ---------------------------------------------------------------------------------------

function SMARTDEBUFF_SetGameTooltip(self, title, text, anchor)
  if (not anchor) then anchor = "ANCHOR_LEFT"; end
  GameTooltip:SetOwner(self, anchor);
  GameTooltip:SetText(WH..title);
  GameTooltip:AddLine(text, SMARTDEBUFF_TTC_R, SMARTDEBUFF_TTC_G, SMARTDEBUFF_TTC_B, 1);
  GameTooltip:AppendText("");
end

function SMARTDEBUFF_ToggleOF()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
  local frame = SmartDebuffOF;
  if (frame:IsVisible()) then

    HideF(frame);
  else
    ShowF(frame);
  end
end

function SMARTDEBUFF_OFToggleGrp(i)
  O.DebuffGrp[i] = not O.DebuffGrp[i];
  shouldCallSetUnits = true;
end

function SMARTDEBUFF_OFOnShow()
  SMARTDEBUFF_HideAllButThis();
  SMARTDEBUFF_CheckAutoHide();
  SMARTDEBUFF_CheckAnchorPos();
  if O.Debug then
    ShowF(SmartDebuffOF_btnReload);
  end
end

function SMARTDEBUFF_OFOnHide()
  iTest = 0;
  SMARTDEBUFF_LinkSpellsToKeys();
  SMARTDEBUFF_CheckAutoHide();
  HideF(SmartDebuffWNF);
  SMARTDEBUFF_CheckAnchorPos();
  if (ColorPickerFrame:IsVisible()) then
    HideUIPanel(ColorPickerFrame);
  end
  SMARTDEBUFF_SetUnits();
end


function SMARTDEBUFF_ToggleAnchors()
  O.AdvAnchors = not O.AdvAnchors;
  SMARTDEBUFF_SetAnchorPos();
end

function SMARTDEBUFF_CheckAnchorPos(self, button)
  if (not O) then return; end

  if (not self) then
    self = _G["SmartDebuff_rbAnchor"..O.SFPosP];
  end
  if (not self) then return; end

  local s = self:GetName();
  --SMARTDEBUFF_AddMsgD(s);
  s = string.sub(s, 21);
  if (not s) then s = "TOPLEFT"; end
  O.SFPosP = s;

  for _, v in pairs(AnchorPos) do
    local rb = _G["SmartDebuff_rbAnchor"..v];
    if (rb) then
      if (O.AdvAnchors and SmartDebuffOF:IsVisible() and not InCombatLockdown()) then
        rb:SetChecked(false);
        if (v == s) then
          rb:SetChecked(true);
        end
        rb:Show();
      else
        rb:Hide();
      end
    end
  end
  SMARTDEBUFF_SetStyle();
end

function SMARTDEBUFF_SetAnchorPos(self, button)
  if (not O) then return; end

  local f = SmartDebuffSF;
  local h = f:GetHeight();
  local x = f:GetLeft();
  local y = f:GetTop() - UIParent:GetHeight();
  local w = f:GetWidth();

  if (O.SFPosP == "TOPLEFT") then
    -- base
  elseif (O.SFPosP == "TOP") then
    x = x + w/2;
  elseif (O.SFPosP == "TOPRIGHT") then
    x = x + w;
  elseif (O.SFPosP == "LEFT") then
    y = y - h/2;
  elseif (O.SFPosP == "CENTER") then
    x = x + w/2;
    y = y - h/2;
  elseif (O.SFPosP == "RIGHT") then
    x = x + w;
    y = y - h/2;
  elseif (O.SFPosP == "BOTTOMLEFT") then
    y = y - h;
  elseif (O.SFPosP == "BOTTOM") then
    x = x + w/2;
    y = y - h;
  elseif (O.SFPosP == "BOTTOMRIGHT") then
    x = x + w;
    y = y - h;
  end

  O.SFPosX = x;
  O.SFPosY = y;
  O.SFPosRP = "TOPLEFT";

  --SMARTDEBUFF_AddMsgD(O.SFPosRP..", "..O.SFPosX..", "..O.SFPosY);
  SMARTDEBUFF_CheckAnchorPos(self, button);
end

function SMARTDEBUFF_SetAutoHide(b)
  if (O.AutoHide) then
    local i, btn;
    SmartDebuffSF:EnableMouse(b);
    for i = 1, maxRaid, 1 do
      btn = _G["SmartDebuffBtn"..i];
      if (btn) then btn:EnableMouse(b); end
    end
    for i = 1, maxPets, 1 do
      btn = _G["SmartDebuffPetBtn"..i];
      if (btn) then btn:EnableMouse(b); end
    end

    if (b) then
      SmartDebuffSF:SetAlpha(1);
    else
      SmartDebuffSF:SetAlpha(0.01);
      SMARTDEBUFF_SetMoving(false);
    end
  end
end

function SMARTDEBUFF_SetMoving(b)
  if (not O) then return end

  local f = SmartDebuffSF;
  if (b) then
    if (InCombatLockdown()) then
      SMARTDEBUFF_AddMsgWarn("SmartDebuff Frame can't be moved in combat");
      f.IsMoving = false;
      return;
    end
    f:StartMoving();
  else
    f:StopMovingOrSizing();
    if (f.IsMoving) then
      SMARTDEBUFF_SetAnchorPos();
    end
  end
  f.IsMoving = b;
end

function SMARTDEBUFF_CheckAutoHide()
  if (not isInit or not O or not O.ShowSF or InCombatLockdown()) then return; end
  if (O.AutoHide) then
    if ((hasDebuff or SmartDebuffOF:IsVisible())) then
      SMARTDEBUFF_SetAutoHide(true);
    else
      SMARTDEBUFF_SetAutoHide(false);
    end
  else
    SMARTDEBUFF_SetAutoHide(true);
  end
end

local function GlobalLoadSave(L, S)
  if (L.SFPosX == nil) then return; end
  S.SFPosP = L.SFPosP;
  S.SFPosRP = L.SFPosRP;
  S.SFPosX = L.SFPosX;
  S.SFPosY = L.SFPosY;
  S.OrderClass = L.OrderClass;
  S.OrderGrp = L.OrderGrp;
  S.Toggle = L.Toggle;
  S.ShowSF = L.ShowSF;
  S.ShowIF = L.ShowIF;
  S.AdvAnchors = L.AdvAnchors;
  S.ShowPets = L.ShowPets;
  S.ShowPetsWL = L.ShowPetsWL;
  S.ShowPetsDK = L.ShowPetsDK;
  S.ShowClassColors = L.ShowClassColors;
  S.SortedByClass = L.SortedByClass;
  S.SortedByRole = L.SortedByRole;
  S.ShowLR = L.ShowLR;
  S.DebuffGrp = L.DebuffGrp;
  S.DebuffClasses = L.DebuffClasses;
  S.ANormal = L.ANormal;
  S.ANormalOOR = L.ANormalOOR;
  S.ADebuff = L.ADebuff;
  S.ColNormal = L.ColNormal;
  if (L.ColBack) then S.ColBack = L.ColBack; end
  S.ColDebuffL = L.ColDebuffL;
  S.ColDebuffR = L.ColDebuffR;
  S.ColDebuffM = L.ColDebuffM;
  S.ColDebuffNR = L.ColDebuffNR;
  S.ShowHP = L.ShowHP;
  S.ShowMana = L.ShowMana;
  S.ShowHPText = L.ShowHPText;
  S.Invert = L.Invert;
  S.ShowHeaders = L.ShowHeaders;
  S.ShowGrpNr = L.ShowGrpNr;
  S.ShowHeaderRow = L.ShowHeaderRow;
  S.ShowInfoRow = L.ShowInfoRow;
  S.Vertical = L.Vertical;
  S.VerticalUp = L.VerticalUp;
  S.Columns = L.Columns;
  S.BarH = L.BarH;
  S.BtnW = L.BtnW;
  S.BtnH = L.BtnH;
  S.Fontsize = L.Fontsize;
  S.BtnSpX = L.BtnSpX;
  S.BtnSpY = L.BtnSpY;
  S.ShowTooltip = L.ShowTooltip;
  S.UseSound = L.UseSound;
  S.Sound = L.Sound or SMARTDEBUFF_SOUNDS_DEFAULT;
  S.TargetMode = L.TargetMode;
  S.ShowHealRange = L.ShowHealRange;
  S.ShowAggro = L.ShowAggro;
  S.ShowSpellIcon = L.ShowSpellIcon;
  S.ShowRaidIcon = L.ShowRaidIcon;
  S.RaidIconSize = L.RaidIconSize;
  S.ShowNotRemov = L.ShowNotRemov;
  S.CheckInterval = L.CheckInterval;
  S.ShowBackdrop = L.ShowBackdrop;
  S.ShowGradient = L.ShowGradient;
  S.AutoHide = L.AutoHide;
  S.StopCast = L.StopCast or false;
  S.IgnoreDebuff = L.IgnoreDebuff or true;
  S.ChatNotif = L.ChatNotif or true;
  S.ShowVehicles = L.ShowVehicles;
end

function SMARTDEBUFF_GlobalSave()
  if (O == nil) then return; end
  GlobalLoadSave(O, OG);
  SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE.." "..SMARTDEBUFF_TT_GLOBALSAVE, true);
end

function SMARTDEBUFF_GlobalLoad()
  HideF(SmartDebuffOF);
  GlobalLoadSave(OG, O);
  ShowF(SmartDebuffOF);
  SMARTDEBUFF_CheckSFBackdrop();
  SMARTDEBUFF_SetButtons();
  SMARTDEBUFF_CheckSFButtons();
  SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE.." "..SMARTDEBUFF_TT_GLOBALLOAD, true);
end


-- Scroll frame functions ---------------------------------------------------------------------------------------

local ScrBtnHeight = 12;
local function SetPosScrollButtons(parent, cBtn)
  local btn;
  local name;
  for i = 1, #cBtn, 1 do
    btn = cBtn[i];
    btn:ClearAllPoints();
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2 - ScrBtnHeight*(i-1));
  end
end

local StartY, EndY;
local function CreateScrollButton(name, parent, cBtn, onClick, onDragStop)
	local button = CreateFrame("Button", name, parent);
	button:SetWidth(parent:GetWidth());
	button:SetHeight(ScrBtnHeight);
  button:RegisterForClicks("AnyDown");
	button:SetScript("OnClick", onClick);

  if (onDragStop ~= nil) then
    button:SetMovable(true);
    button:RegisterForDrag("LeftButton");
    button:SetScript("OnDragStart", function(self, b)
      StartY = self:GetTop();
      self:StartMoving();
      end
    );
    button:SetScript("OnDragStop", function(self, b)
      EndY = self:GetTop();
      local i = tonumber(self:GetID()) + FauxScrollFrame_GetOffset(parent);
      local n = math.floor((StartY - EndY) / ScrBtnHeight);
      --SMARTDEBUFF_AddMsgD(format("%.0f: %.0f->%.0f = %.0f", i, StartY, EndY, n));
      self:StopMovingOrSizing();
      SetPosScrollButtons(parent, cBtn);
      onDragStop(i, n);
      end
    );
  end

	local text = button:CreateFontString(nil, nil, "GameFontNormal");
	text:SetJustifyH("LEFT");
	text:SetAllPoints(button);
	button:SetFontString(text);
	button:SetHighlightFontObject("GameFontHighlight");

	local highlight = button:CreateTexture();
	highlight:SetAllPoints(button);
	highlight:SetTexture("Interface/QuestFrame/UI-QuestTitleHighlight");
	button:SetHighlightTexture(highlight);

	return button;
end


local function CreateScrollButtons(self, cBtn, sBtnName, onClick, onDragStop)
  local btn, i;
  for i = 1, maxScrollBtn, 1 do
    btn = CreateScrollButton(sBtnName..i, self, cBtn, onClick, onDragStop);
    btn:SetID(i);
    --[[
    btn:ClearAllPoints();
    if (i == 1) then
      btn:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2);
    else
      btn:SetPoint("TOPLEFT", sBtnName..i-1, "BOTTOMLEFT", 0, -2);
      btn:SetPoint("TOPRIGHT", sBtnName..i-1, "BOTTOMRIGHT", 0, -2);
    end
    ]]--
    cBtn[i] = btn;
  end
  SetPosScrollButtons(self, cBtn);
end


local function OnScroll(self, cData, sBtnName)
  local num = #cData;
  local n, numToDisplay;

  if (num <= maxScrollBtn) then
    numToDisplay = num-1;
  else
    numToDisplay = maxScrollBtn;
  end

  FauxScrollFrame_Update(self, num, numToDisplay, ScrBtnHeight);
  for i = 1, maxScrollBtn, 1 do
    n = i + FauxScrollFrame_GetOffset(self);
    local btn = _G[sBtnName..i];
    if (btn) then
      if (n <= num) then
        btn:SetNormalFontObject("GameFontNormalSmall");
        btn:SetHighlightFontObject("GameFontHighlightSmall");
        btn:SetText(cData[n]);
        btn:Show();
      else
        btn:Hide();
      end
    end
  end
end

function SMARTDEBUFF_AddTextToTable(self, tbl)
  if (self) then
    local text = self:GetText();
    if (text and string.len(text) > 1) then
      table.insert(tbl, text);
      self:SetText("");
    end
    self:ClearFocus();
  end
end


-- DebuffGuard scroll frame functions ---------------------------------------------------------------------------------------

local cScrBtnNRD = nil;
function SMARTDEBUFF_NRDOnScroll(self, arg1)
  if (not self) then
    self = SmartDebuffNRDebuffs_ScrollFrame;
  end

  local name = "SMARTDEBUFF_BtnScrollNRD";
  if (not cScrBtnNRD and self) then
    cScrBtnNRD = { };
    CreateScrollButtons(SmartDebuffNRDebuffs_ScrollFrame, cScrBtnNRD, name, SmartDebuff_NRDBtnOnClick, nil);
    --CreateScrollButtons(SmartDebuffNRDebuffs_ScrollFrame, cScrBtnNRD, name, SmartDebuff_NRDBtnOnClick, SmartDebuff_NRDBtnOnDragStop);
  end
  OnScroll(self, O.NotRemovableDebuffs, name);
end

function SmartDebuff_NRDBtnOnClick(self, button)
	--self:LockHighlight();
  if (button == "LeftButton") then
    SmartDebuffNRDebuffs_txtIn:SetText(self:GetText());
  else
    local n = self:GetID() + FauxScrollFrame_GetOffset(self:GetParent());
    --SMARTDEBUFF_AddMsgD("Remove: "..n);
    if (O.NotRemovableDebuffs[n]) then
      table.remove(O.NotRemovableDebuffs, n);
    end
    SMARTDEBUFF_NRDOnScroll();
  end
  SmartDebuffNRDebuffs_txtIn:ClearFocus();
end

function SmartDebuff_NRDBtnOnDragStop(i, n)
  TableReorder(O.NotRemovableDebuffs, i, n);
  SMARTDEBUFF_NRDOnScroll();
end

function SMARTDEBUFF_NRDebuffsOnShow(self)
  SMARTDEBUFF_HideAllButThis(self);
  SmartDebuffNRDebuffs_Title:SetText(SMARTDEBUFF_NRDT_TITLE);
end

function SMARTDEBUFF_ToggleNRDebuffs()
  if (SmartDebuffNRDebuffs:IsVisible()) then
    SmartDebuffNRDebuffs:Hide();
  else
    SmartDebuffNRDebuffs:Show();
  end
end

function SMARTDEBUFF_NRDebuffsOnHide()
end


-- SpellGuard scroll frame functions ---------------------------------------------------------------------------------------

local cScrBtnSG = nil;
function SMARTDEBUFF_SpellGuardOnScroll(self, arg1)
  if (not self) then
    self = SmartDebuffSpellGuard_ScrollFrame;
  end

  local name = "SMARTDEBUFF_BtnScrollSG";
  if (not cScrBtnSG and self) then
    cScrBtnSG = { };
    CreateScrollButtons(self, cScrBtnSG, name, SmartDebuff_SpellGuardBtnOnClick, SmartDebuff_SpellGuardBtnOnDragStop);
  end
  OnScroll(self, O.SpellGuard, name);
end

function SMARTDEBUFF_SpellGuardOnShow(self)
  SMARTDEBUFF_HideAllButThis(self);
  SmartDebuffSpellGuard_Title:SetText(SMARTDEBUFF_SG_TITLE);
end

function SMARTDEBUFF_SpellGuardToggle()
  if (SmartDebuffSpellGuard:IsVisible()) then
    SmartDebuffSpellGuard:Hide();
  else
    SmartDebuffSpellGuard:Show();
  end
end

function SMARTDEBUFF_SpellGuardOnHide(self)
end

function SmartDebuff_SpellGuardBtnOnClick(self, button)
	--self:LockHighlight();
  if (button == "LeftButton") then
    SmartDebuffSpellGuard_txtIn:SetText(self:GetText());
  else
    local n = self:GetID() + FauxScrollFrame_GetOffset(self:GetParent());
    --SMARTDEBUFF_AddMsgD("Remove: "..n);
    if (O.SpellGuard[n]) then
      table.remove(O.SpellGuard, n);
    end
    SMARTDEBUFF_SpellGuardOnScroll();
  end
  SmartDebuffSpellGuard_txtIn:ClearFocus();
end

function SmartDebuff_SpellGuardBtnOnDragStop(i, n)
  --SMARTDEBUFF_AddMsgD(format("i = %.0f, n = %.0f", i, n));
  TableReorder(O.SpellGuard, i, n);
  SMARTDEBUFF_SpellGuardOnScroll();
end


-- ClassOrder scroll frame functions ---------------------------------------------------------------------------------------

local cScrBtnCO = nil;
function SMARTDEBUFF_ClassOrderOnScroll(self, arg1)
  if (not self) then
    self = SmartDebuffClassOrder_ScrollFrame;
  end

  local name = "SMARTDEBUFF_BtnScrollCO";
  if (not cScrBtnCO and self) then
    cScrBtnCO = { };
    CreateScrollButtons(self, cScrBtnCO, name, SmartDebuff_ClassOrderBtnOnClick, SmartDebuff_ClassOrderBtnOnDragStop);
  end

  local t = { };
  for _, v in ipairs(O.OrderClass) do
    if (v) then
      table.insert(t, SMARTDEBUFF_CLASSES[v]);
    end
  end
  OnScroll(self, t, name);
end

function SMARTDEBUFF_ClassOrderOnShow(self)
  SMARTDEBUFF_HideAllButThis(self);
  SmartDebuffClassOrder_Title:SetText(SMARTDEBUFF_AOFT_SORTBYCLASS);
end

function SMARTDEBUFF_ClassOrderToggle()
  if (SmartDebuffClassOrder:IsVisible()) then
    SmartDebuffClassOrder:Hide();
  else
    SmartDebuffClassOrder:Show();
  end
end

function SMARTDEBUFF_ClassOrderOnHide(self)
end

function SmartDebuff_ClassOrderBtnOnClick(self, button)
end

function SmartDebuff_ClassOrderBtnOnDragStop(i, n)
  TableReorder(O.OrderClass, i, n);
  SMARTDEBUFF_ClassOrderOnScroll();
  SMARTDEBUFF_SetButtons();
end


-- Sound scroll frame functions ---------------------------------------------------------------------------------------

local cScrBtnS = nil;
function SMARTDEBUFF_SoundsOnScroll(self, arg1)
  if (not self) then
    self = SmartDebuffSounds_ScrollFrame;
  end

  local name = "SMARTDEBUFF_BtnScrollS";
  if (not cScrBtnS and self) then
    cScrBtnS = { };
    CreateScrollButtons(self, cScrBtnS, name, SmartDebuff_SoundsBtnOnClick, nil);
  end

  local t = { };
  for i, v in ipairs(SMARTDEBUFF_SOUNDS) do
    if (v and v[1]) then
      local soundName = (i == O.Sound) and (GR.."> "..v[1].." <") or v[1];
      table.insert(t, soundName);
    end
  end
  OnScroll(self, t, name);
  SmartDebuffSounds_txtIn:SetText(GR..SMARTDEBUFF_SOUNDS[O.Sound][1]);
end

function SMARTDEBUFF_SoundsOnShow(self)
  SMARTDEBUFF_HideAllButThis(self);
  SmartDebuffSounds_Title:SetText(SMARTDEBUFF_S_TITLE);
end

function SMARTDEBUFF_SoundsToggle()
  if (SmartDebuffSounds:IsVisible()) then
    SmartDebuffSounds:Hide();
  else
    SmartDebuffSounds:Show();
  end
end

function SMARTDEBUFF_SoundsOnHide(self)
end

function SmartDebuff_SoundsBtnOnClick(self, button)
  local n = self:GetID() + FauxScrollFrame_GetOffset(self:GetParent());
  if (button == "LeftButton") then
    O.Sound = n;
    -- SmartDebuffSounds_txtIn:SetText(SMARTDEBUFF_SOUNDS[n][1]);
    SMARTDEBUFF_SoundsOnScroll(); -- set selection and highlight
  end
  if (SmartDebuffFrame.SoundHandle) then
    StopSound(SmartDebuffFrame.SoundHandle);
  end
  SmartDebuffFrame.SoundHandle = select(2, PlaySoundFile(SMARTDEBUFF_SOUNDS[n][2], "master"));
end


-- Color setup frame functions ---------------------------------------------------------------------------------------

function SMARTDEBUFF_ColorsOnShow(self)
  SMARTDEBUFF_HideAllButThis(self);
  SmartDebuffColors_Title:SetText(SMARTDEBUFF_OFT_COLORSETUP);
  SMARTDEBUFF_ColorsUpdate(true);
end

function SMARTDEBUFF_ColorsToggle()
  if (SmartDebuffColors:IsVisible()) then
    SmartDebuffColors:Hide();
  else
    SmartDebuffColors:Show();
  end
end

function SMARTDEBUFF_ColorsOnHide(self)
end

function SMARTDEBUFF_ColorsSetBackdrop()
  local c = O.ColBack;
  c.r, c.g, c.b = ColorPickerFrame:GetColorRGB();
  c.a = 1.0 - OpacitySliderFrame:GetValue();
  SmartDebuffColors_btnTestBG.texture:SetColorTexture(c.r, c.g, c.b, c.a);
  SMARTDEBUFF_CheckSFBackdrop();
end

function SMARTDEBUFF_ColorsCancelBackdrop(p)
  local c = O.ColBack;
	if (p.r) then
    c.r = p.r; c.g = p.g; c.b = p.b;
	end
	if (p.a) then
		c.a = p.a;
	end
	SmartDebuffColors_btnTestBG.texture:SetColorTexture(c.r, c.g, c.b, c.a);
	SMARTDEBUFF_CheckSFBackdrop();
end

function SMARTDEBUFF_ColorsBackdrop()
  local c = O.ColBack;
  ColorPickerFrame.previousValues = {r = c.r, g = c.g, b = c.b, a = c.a};
  ColorPickerFrame.func = SMARTDEBUFF_ColorsSetBackdrop;
  ColorPickerFrame.cancelFunc = SMARTDEBUFF_ColorsCancelBackdrop;
  ColorPickerFrame.opacityFunc = SMARTDEBUFF_ColorsSetBackdrop;
  ColorPickerFrame.hasOpacity = 1;
  ColorPickerFrame.opacity = 1-c.a;
  ColorPickerFrame:SetColorRGB(c.r, c.g, c.b)
  ShowUIPanel(ColorPickerFrame);
end

function SMARTDEBUFF_ColorsUpdate(b)
  local c = O.ColDebuffL;
  SmartDebuffColors_btnTestL.texture:SetColorTexture(c.r, c.g, c.b, 1.0);
  SmartDebuffColors_btnTestL:SetAlpha(O.ADebuff);
  if (b) then SmartDebuffColors_csDebuffL:SetColorRGB(c.r, c.g, c.b); end

  c = O.ColDebuffR;
  SmartDebuffColors_btnTestR.texture:SetColorTexture(c.r, c.g, c.b, 1.0);
  SmartDebuffColors_btnTestR:SetAlpha(O.ADebuff);
  if (b) then SmartDebuffColors_csDebuffR:SetColorRGB(c.r, c.g, c.b); end

  c = O.ColDebuffM;
  SmartDebuffColors_btnTestM.texture:SetColorTexture(c.r, c.g, c.b, 1.0);
  SmartDebuffColors_btnTestM:SetAlpha(O.ADebuff);
  if (b) then SmartDebuffColors_csDebuffM:SetColorRGB(c.r, c.g, c.b); end

  c = O.ColDebuffNR;
  SmartDebuffColors_btnTestNR.texture:SetColorTexture(c.r, c.g, c.b, 1.0);
  SmartDebuffColors_btnTestNR:SetAlpha(O.ADebuff);
  if (b) then SmartDebuffColors_csDebuffNR:SetColorRGB(c.r, c.g, c.b); end

  c = O.ColNormal;
  SmartDebuffColors_btnTestN.texture:SetColorTexture(c.r, c.g, c.b, 1.0);
  SmartDebuffColors_btnTestN:SetAlpha(O.ANormal);
  if (b) then SmartDebuffColors_csNormal:SetColorRGB(c.r, c.g, c.b); end

  c = O.ColBack;
  SmartDebuffColors_btnTestBG.texture:SetColorTexture(c.r, c.g, c.b, c.a);
  SMARTDEBUFF_CheckSFBackdrop();
end

-- SmartDebuff action binding option frame functions --------------------------------

-- -- Pickup hook to avoid the GetCursorInfo bug with pet spells
-- local lastSlot, lastBookType;
-- local function PickupSpellBookItemHook(slot, bookType)
--   lastSlot, lastBookType = slot, bookType;
-- end
-- hooksecurefunc("PickupSpellBookItem", PickupSpellBookItemHook);
-- -- End Pickup hook


function SMARTDEBUFF_ToggleAOFKeys()
  if (SmartDebuffAOFKeys:IsVisible()) then
    SmartDebuffAOFKeys:Hide();
  else
    SmartDebuffAOFKeys:Show();
  end
end

function SMARTDEBUFF_RefreshAOFKeys()
  if (SmartDebuffAOFKeys:IsVisible()) then
    SMARTDEBUFF_AddMsgD(RD.."-- Refresh Keys window --");
    SmartDebuffAOFKeys:Hide();
    SmartDebuffAOFKeys:Show();
  end
end

function SmartDebuffAOFKeys_OnShow(self)
  if (not self) then
    self = SmartDebuffAOFKeys;
  end
  SMARTDEBUFF_HideAllButThis(self);

  local aName, aType, aRank, aId, aLink, aTexture, aStackCount;
  local mode = 1;
  local i;
  local btn;
  for iAction = 1, 24, 1 do
    btn = _G["SmartDebuff_btnAction"..iAction];
    if not btn._label then
      btn._label = btn:CreateFontString(nil, "OVERLAY", "SmartDebuff_GameFontNormalMicro")
      btn._label:SetPoint("BOTTOMRIGHT", -4, 2);
    end
    btn._label:SetText("");

    mode, i = GetActionMode(iAction);
    aType, aName, aRank, aId, aLink = GetActionKeyInfo(mode, i);

    --SMARTDEBUFF_AddMsgD("Show: "..ChkS(aType)..", "..ChkS(aName)..", "..ChkS(aRank)..", "..ChkS(aId)..", "..ChkS(aLink));
    local isMovable = true;
    local isEnabled = true;
    if ((aType == "spell" or aType == "petaction") and aName) then
      if (aId) then
        local getSpellInfo = SDB_GetSpellInfo(aId);
        SetATexture(btn, getSpellInfo and getSpellInfo.iconID or imgMissing);
        isMovable = SMARTDEBUFF_IsSpellMovable(aType, aName, aRank, aId, aLink);
        isEnabled = isMovable and not not GetSpellInfo(aName);
      else
        isMovable = false;
        isEnabled = false;
        SetATexture(btn, imgMissing);
      end
    elseif (aType == "item") then
      aName, _, _, _, _, _, _, aStackCount, _, aTexture = GetItemInfo(aId or aName);
      SetATexture(btn, aTexture or imgMissing);
      local itemCount = GetItemCount(aName);
      btn._label:SetText((aStackCount ~= 1) and itemCount or "");
      isEnabled = itemCount > 0;
    elseif (aType == "macro") then
      _, aTexture = GetMacroInfo(GetMacroIndexByName(aName));
      SetATexture(btn, aTexture or imgMissing);
      btn._label:SetText(strsub(aName, 0, 4));
    elseif (aType == "target") then
      SetATexture(btn, imgTarget);
    elseif (aType == "menu") then
      SetATexture(btn, imgMenu);
    elseif (aType == "action" and aId) then
      SetATexture(btn, GetSpellTexture(aId, BOOKTYPE_PET) or imgMissing);
    else
      SetATexture(btn, imgActionSlot);
    end
    local vertexColor = isEnabled and vertexColors.Enabled or (isMovable and vertexColors.Disabled or vertexColors.NotFound);
    btn:GetNormalTexture():SetVertexColor(unpack(vertexColor));
    btn:GetNormalTexture():SetDesaturated(not isMovable);
  end
end

function SMARTDEBUFF_ShowWhatsNew()
  ShowF(SmartDebuffOF);
  ShowF(SmartDebuffAOFKeys);
  SmartDebuffWNF_lblText:SetText(SMARTDEBUFF_WHATSNEW);
  ShowF(SmartDebuffWNF);
  shouldCallSetSpells = true;
  shouldCallSetMacros = true;
end


function SMARTDEBUFF_OnActionUp(self, button)
  if (GetCursorInfo()) then
    SMARTDEBUFF_DropAction(self, button);
  end
end

function SMARTDEBUFF_OnActionDown(self, button)
  if (GetCursorInfo()) then
    SMARTDEBUFF_DropAction(self, button);
  else
    SMARTDEBUFF_PickAction(self, button);
  end
end

function SMARTDEBUFF_OnReceiveDrag(self)
  if (GetCursorInfo()) then
    SMARTDEBUFF_DropAction(self, "LeftButton");
  else
    SMARTDEBUFF_PickAction(self, "LeftButton");
  end
end


function SMARTDEBUFF_PickAction(self, button)
  local iAction = self:GetID();
  local mode = 1;
  local i;

  mode, i = GetActionMode(iAction);
  local aType, aName, aRank, aId, aLink = GetActionKeyInfo(mode, i);
  SMARTDEBUFF_AddMsgD("Pickup: "..ChkS(aType)..", "..ChkS(aName)..", "..ChkS(aRank)..", "..ChkS(aId));
  local resetVertexColor = false;
  local resetLabel = true;
  if (button == "RightButton") then
    -- Right click: remove
    resetVertexColor = true;
    SetActionInfo(mode, i, nil, nil, nil, nil, nil);
    SetATexture(self, imgActionSlot);
  else
    -- Left click
    if (not aType) then      
        -- Slot empty: create target or menu
        resetVertexColor = true;
        if (not IsModifierKeyDown()) then
          SetActionInfo(mode, i, "target", "target", nil, nil, nil);
          SetATexture(self, imgTarget);
        else
          SetActionInfo(mode, i, "menu", "menu", nil, nil, nil);
          SetATexture(self, imgMenu);
        end
    else
        -- Slot already exists: pickup spell
        aType, aId = SDB_GetPickupOverride(aType, aId);
        if (aType == "spell") then
          -- SMARTDEBUFF_AddMsgD("Pick: "..ChkS(aId).." - "..ChkS(aName.." - "..ChkS(aRank));
          if (aId and SMARTDEBUFF_IsSpellMovable(aType, aName, aRank, aId, aLink)) then
            PickupSpell(aId);
          else
            -- Do nothing (spell not found: can't move)
            return;
          end
        elseif (aType == "petaction") then
          if (aId and SMARTDEBUFF_IsSpellMovable(aType, aName, aRank, aId, aLink)) then
            PickupPetSpell(aId);
          else
            -- Do nothing (spell not found: can't move)
            return;
          end
        elseif (aType == "item") then
          PickupItem(aId);
          resetLabel = false;
        elseif (aType == "macro") then
          PickupMacro(aId);
          resetLabel = false;
        elseif (aType == "action") then
          PickupSpellBookItem(aId, BOOKTYPE_PET);
        elseif (aType == "menu" or aType == "target") then
          -- Do nothing with sdb actions
          return;
        end
        if (not GetCursorInfo()) then
          -- Unexpected error: Spell not pickable
          SMARTDEBUFF_AddMsgErr(ChkS(aName).." #"..ChkS(aId)..", "..SMARTDEBUFF_TT_NOTMOVABLE, true)
          return;
        end
        -- Pick correctly cloned, remove existing slot
        if (not IsModifierKeyDown()) then
          resetVertexColor = true;
          resetLabel = true;
          SetActionInfo(mode, i, nil, nil, nil, nil, nil);
          SetATexture(self, imgActionSlot);
        end
    end
  end
  if resetVertexColor then
    self:GetNormalTexture():SetVertexColor(unpack(vertexColors.Enabled));
    self:GetNormalTexture():SetDesaturated(false);
  end
  if resetLabel then
    self._label:SetText("");
  end
  SMARTDEBUFF_SetButtons();
  SMARTDEBUFF_BtnActionOnEnter(self); -- update tooltip
end


function SMARTDEBUFF_DropAction(self, button)
  --"item", itemID, itemLink
  --"spell", bookIndex, bookType, spellId, baseSpellId - Only works for player spells, so this always returns BOOKTYPE_SPELL!
  --"petaction", spellId, bookType
  --"macro", index
  --"money", amount
  --"merchant", index

  -- warning: baseSpellId is not safe for drag&drop, dispel can override an offspec base dispel

  local infoType, infoId, info2, spellId, baseSpellId = GetCursorInfo();
  local aSpellInfo, aName, aRank, aTexture, aStackCount;
  local iAction = self:GetID();
  local mode = 1;
  local i;
  local bDroped = false;

  if infoType == nil then
    return false;
  end

  SMARTDEBUFF_AddMsgD("Cursor: "..ChkS(infoType)..", "..ChkS(infoId)..", "..ChkS(info2)..", "..ChkS(spellId));
  -- SMARTDEBUFF_AddMsgD("Book: "..ChkS(lastSlot)..", "..ChkS(lastBookType));  -- PickupSpellBookItemHook

  if (infoType == "petaction") then
    spellId = infoId;
  end
  infoType, spellId = SDB_GetPickupOverride(infoType, spellId);

  mode, i = GetActionMode(iAction);
  if (button == "LeftButton" and infoType) then
    local aTypeOld, aNameOld, aRankOld, aIdOld, aLinkOld = GetActionKeyInfo(mode, i);

    aTypeOld, aIdOld = SDB_GetPickupOverride(aTypeOld, aIdOld);
    local isMovable = true;
    local isEnabled = true;
    local labelText = "";

    if (aTypeOld == "spell" or aTypeOld == "petaction") then
      if (aIdOld == nil or not SMARTDEBUFF_IsSpellMovable(aTypeOld, aNameOld, aRankOld, aIdOld, aLinkOld)) then
        -- Spell in slot is not movable, do not try to override it
        return
      end
    end

    if ((infoType == "spell" or infoType == "petaction" or infoType == "action") and not SDB_IsPassiveSpell(spellId, info2)) then
      local aSpellInfo = SDB_GetSpellInfo(spellId);
      if (aSpellInfo) then
        aName, aRank, aTexture = aSpellInfo.name,  "", aSpellInfo.iconID;
        SetActionInfo(mode, i, infoType, aName, aRank, spellId, GetSpellLink(aName));
        -- Spell can still be unpickable once dropped (if picked up before changing pet...)
        isMovable = SMARTDEBUFF_IsSpellMovable(infoType, aName, aRank, spellId, _);
        isEnabled = isMovable and not not GetSpellInfo(aName);
        bDroped = true;
      end
    elseif (infoType == "item") then
      --itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = C_Item.GetItemInfo(itemID)
      aName, _, _, _, _, _, _, aStackCount, _, aTexture = GetItemInfo(infoId);
      SetActionInfo(mode, i, infoType, aName, nil, infoId, info2);
      local itemCount = GetItemCount(aName);
      labelText = (aStackCount ~= 1) and itemCount or "";
      isEnabled = itemCount > 0;
      bDroped = true;
    elseif (infoType == "macro") then
      aName, aTexture = GetMacroInfo(infoId);
      if (aName == nil) then
        -- Error, macro deleted before drop?
        return
      end
      SetActionInfo(mode, i, infoType, aName, nil, infoId, aTexture);
      labelText = strsub(aName, 0, 4);
      bDroped = true;
    end

    if (bDroped) then
      SMARTDEBUFF_AddMsgD("Old:"..ChkS(aTypeOld)..", "..ChkS(aNameOld)..", "..ChkS(aIdOld)..", "..ChkS(aLinkOld));
      SMARTDEBUFF_AddMsgD("Dropped: "..self:GetID().." - "..infoType.." - "..aName.." - "..infoId);
      SetATexture(self, aTexture or imgMissing);
      local vertexColor = isEnabled and vertexColors.Enabled or (isMovable and vertexColors.Disabled or vertexColors.NotFound);
      self:GetNormalTexture():SetVertexColor(unpack(vertexColor));
      self:GetNormalTexture():SetDesaturated(not isMovable);
      self._label:SetText(labelText);
      ClearCursor();
      GameTooltip:Hide();
      SMARTDEBUFF_SetButtons();
      SMARTDEBUFF_BtnActionOnEnter(self); -- update tooltip
      if (aTypeOld) then
        if (aTypeOld == "spell") then
          PickupSpell(aIdOld);
        elseif (aTypeOld == "petaction") then
          PickupPetSpell(aIdOld);
        elseif (aTypeOld == "item") then
          PickupItem(aIdOld);
        elseif (aTypeOld == "macro") then
          PickupMacro(aIdOld);
        elseif (aTypeOld == "action") then
          PickupSpellBookItem(aIdOld, aLinkOld, BOOKTYPE_PET);
        elseif (aTypeOld == "menu") then
          -- Do nothing
          return;
        elseif (aTypeOld == "target") then
          -- Do nothing
          return;
        end
        if (not GetCursorInfo()) then
          -- Unexpected: Spell not pickable
          SMARTDEBUFF_AddMsgErr(ChkS(aNameOld).." #"..ChkS(aIdOld)..", "..SMARTDEBUFF_TT_NOTMOVABLE, true)
          return;
        end
      end
    end
  end
end

--- Returns override pickup info, or original values if not found
--- @param PickupType string
--- @param PickupID number
--- @return string overridenType Overriden or original type
--- @return number overridenID Overriden or original ID
function SDB_GetPickupOverride(PickupType, PickupID)
  if (SMARTDEBUFF_OVERRIDE_PICKUP_LIST_ID[PickupType] and SMARTDEBUFF_OVERRIDE_PICKUP_LIST_ID[PickupType][PickupID]) then
    local overridenType, overridenID = unpack(SMARTDEBUFF_OVERRIDE_PICKUP_LIST_ID[PickupType][PickupID]);
    SMARTDEBUFF_AddMsgD(RD.."PickupSpell override: "..PickupType.." "..PickupID.." -> "..overridenType.." "..overridenID);
    return overridenType, overridenID;
  end
  return PickupType, PickupID;
end


--- Checks if a spell is movable in the game. If the game is in retail mode, it uses the GetSpellInfo function to check the spell's movability.
--- If the game is not in retail mode, the function always returns true, assuming all spells are movable.
--- @param spellType "spell"|"petaction" The type of the spell to check
--- @param spellName string The name of the spell to check
--- @param spellRank string The rank of the spell to check
--- @param spellID number The ID of the spell to check
--- @param spellLink string The link of the spell to check
--- @return boolean isSpellMovable true if the spell is movable, else false. If not in retail mode, always returns true.
function SMARTDEBUFF_IsSpellMovable(spellType, spellName, spellRank, spellID, spellLink)
  -- Not movable if spec not enabled, since Dragonflight (10)
  if C_ClassTalents then
    return SDB_IsSpellTalentExists(spellID) or (not not FindSpellBookSlotBySpellID(spellID, spellType == "petaction"));
  end
  return true;
end

--- @param skipLines? number Lines to skip at the beginning
--- @param avoidLast? number Lines to skip at the end
function SMARTDEBUFF_GameTooltipDisable(skipLines, avoidLast)
  if GameTooltipTextLeft1 then
    skipLines = skipLines or 0;
    avoidLast = avoidLast or 0;
    for i = 1 + skipLines, GameTooltip:NumLines()-avoidLast, 1 do
      if _G["GameTooltipTextLeft"..i] then _G["GameTooltipTextLeft"..i]:SetAlpha(.5) end;
      if _G["GameTooltipTextRight"..i] then _G["GameTooltipTextRight"..i]:SetAlpha(.5) end;
    end
  else
    GameTooltip:SetAlpha(.8);
  end
end
---@param self button
function SMARTDEBUFF_BtnActionOnEnter(self, motion)
  local iAction = self:GetID();
  local mode = 1;
  local i;
  mode, i = GetActionMode(iAction);
  local aType, aName, aRank, aId, aLink = GetActionKeyInfo(mode, i);
  self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD",0)
  self:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress","ADD");
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
  local isReplacing = not not GetCursorInfo();
  local isMovable = true;
  local tooltipAlert = nil;
  local tooltipActions = "";
  local tooltipActionsReplace = SMARTDEBUFF_TT_DROPEXCHANGE;
  if (aType == "spell" or aType == "petaction") then
    if (aId) then
      local isPet = (aType == "petaction");
      isMovable = SMARTDEBUFF_IsSpellMovable(aType, aName, aRank, aId, aLink);
      local isEnabled = isMovable and not not GetSpellInfo(aName);

      GameTooltip:SetSpellByID(aId);
      GameTooltip:AddLine(isPet and ORL..SMARTDEBUFF_TT_PETACTION.."\n\n" or " ");
      if (not isMovable) then
        SMARTDEBUFF_GameTooltipDisable();
      end
      GameTooltip:AddLine(not isEnabled and ORL..SMARTDEBUFF_TT_MISSINGINFO.."\n\n" or "");
      tooltipActions = isMovable and SMARTDEBUFF_TT_SPELLACTIONS or SMARTDEBUFF_TT_TARGETACTIONS;
    else
      -- Spell missing
      SMARTDEBUFF_AddMsgD("SPELL missing: "..mode.." - "..i.." - "..ChkS(aName).." - "..ChkS(aLink));
      GameTooltip:SetText(GY..aName);
      GameTooltip:AddLine(SMARTDEBUFF_TT_NOTFOUND);
      tooltipActions = SMARTDEBUFF_TT_TARGETACTIONS;
      isMovable = false;
    end
    if (not isMovable) then
      self:ClearHighlightTexture();
      self:ClearPushedTexture();
      tooltipAlert = SMARTDEBUFF_TT_NOTMOVABLE;
      tooltipActionsReplace = SMARTDEBUFF_TT_CANTDROP;
    end
  elseif (aType == "item") then
    if (aLink) then
      GameTooltip:SetHyperlink(aLink);
    else
      GameTooltip:SetText(WH..aName);
    end
    GameTooltip:AddLine("\n"..USE_ITEM.."\n\n");
    tooltipActions = SMARTDEBUFF_TT_ITEMACTIONS;
  elseif (aType == "macro") then
    GameTooltip:SetText(WH..aName);
    GameTooltip:AddLine(BLL..(GetMacroBody(GetMacroIndexByName(aName)) or ""));
    GameTooltip:AddLine(MACRO.."\n\n");
    tooltipActions = SMARTDEBUFF_TT_MACROACTIONS;
  elseif (aType == "target") then
    GameTooltip:SetText(WH..SMARTDEBUFF_TT_TARGET);
    GameTooltip:AddLine(SMARTDEBUFF_TT_TARGETINFO);
    tooltipActions = SMARTDEBUFF_TT_TARGETACTIONS;
    tooltipActionsReplace = SMARTDEBUFF_TT_DROPREPLACE;
  elseif (aType == "menu") then
    GameTooltip:SetText(WH..SMARTDEBUFF_TT_MENU);
    GameTooltip:AddLine(SMARTDEBUFF_TT_MENUINFO);
    tooltipActions = SMARTDEBUFF_TT_PICKMENU;
    tooltipActionsReplace = SMARTDEBUFF_TT_DROPREPLACE;
  elseif (aType == "action" and aId ~= nil) then
    GameTooltip:SetSpellBookItem(aId, BOOKTYPE_PET);
    tooltipActions = SMARTDEBUFF_TT_SPELLACTIONS;
  else
    GameTooltip:SetText(WH..SMARTDEBUFF_TT_DROP);
    tooltipActions = SMARTDEBUFF_TT_DROPINFO;
    tooltipActionsReplace = SMARTDEBUFF_TT_DROPABBLE;
  end

  GameTooltip:AddLine(
    (tooltipAlert and RD..tooltipAlert.."|r\n" or "")
    ..GR..(isReplacing and tooltipActionsReplace or tooltipActions)
  );
  GameTooltip:AppendText("");
end


function SMARTDEBUFF_BtnActionOnLeave(self, motion)
  GameTooltip:Hide();
end
