-------------------------------------------------------------------------------
-- Broker: SmartDebuff
-- Created by Aeldra (EU-Proudmoore)
--
-- Data Broker support
-------------------------------------------------------------------------------

if (not SMARTDEBUFF_TITLE) then return end

local F = CreateFrame("Frame", "Broker_SmartDebuff");

function SMARTDEBUFF_BROKER_UpdateIcon()
  if (not F.LS) then return end
  if (SMARTDEBUFF_Options and SMARTDEBUFF_Options.ShowSF) then
    F.LS.icon = "Interface\\AddOns\\SmartDebuff\\Icons\\IconEnabled";
  else
    F.LS.icon = "Interface\\AddOns\\SmartDebuff\\Icons\\IconDisabled";
  end
end

F.LS = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("SmartDebuff", {
	type = "launcher",
	label = SMARTDEBUFF_TITLE,
	OnClick = function(_, msg)
    if (msg == "RightButton") then
      SMARTDEBUFF_ToggleSF();      
    elseif (msg == "LeftButton") then
      SMARTDEBUFF_ToggleOF();
    end
	end,
	icon = "Interface\\AddOns\\SmartDebuff\\Icons\\IconDisabled",
	OnTooltipShow = function(tooltip)
		if (not tooltip or not tooltip.AddLine) then return end
		tooltip:AddLine("|cffffffff"..SMARTDEBUFF_TITLE.."|r");
		tooltip:AddLine(SMARTDEBUFF_BROKER_TT);
	end,
});

F:Hide();
--print("Borker - SmartDebuff loaded");
