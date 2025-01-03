local _, ns = ...

-- Since The War Within (11)
ns.PickupSpell = C_Spell.PickupSpell or PickupSpell;
ns.GetSpellLink = C_Spell.GetSpellLink or GetSpellLink;

ns.IsSpellInRange = C_Spell.IsSpellInRange or function (spellnameOrId)
  return IsSpellInRange(spellnameOrId) == 1
end

ns.GetSpellCooldown = C_Spell.GetSpellCooldown or function (spellnameOrId)
  local start, duration, enabled, modRate = GetSpellCooldown(spellnameOrId);
  if (start) then
    return {
      startTime = start,
      duration = duration,
      isEnabled = enabled > 0,
      modRate = modRate,
    };
  else
    return nil;
  end
end;

ns.GetSpellInfo = C_Spell.GetSpellInfo or function (spellnameOrId)
  local spellName, _, iconID, castTime, minRange, maxRange, spellID, originalIconID = GetSpellInfo(spellnameOrId);
  if (spellName) then
    return {
          name = spellName,
          spellID = spellID,
          iconID = iconID,
          castTime = castTime,
          minRange = minRange,
          maxRange = maxRange,
          originalIconID = originalIconID,
        };
  else
    return nil;
  end
end

ns.GetSpellName = C_Spell.GetSpellName or function (spellnameOrId)
  local spellName = GetSpellInfo(spellnameOrId);
  return spellName
end

ns.GetSpellTexture = C_Spell.GetSpellTexture or function (spellnameOrId)
  local _, _, iconID = GetSpellInfo(spellnameOrId);
  return iconID
end

-- Check for older API before newest

ns.PickupSpellBookItem = PickupSpellBookItem or function (spellId, bookType)
  local spellBank = Enum.SpellBookSpellBank.Player;
  if bookType == "pet" then
    spellBank = Enum.SpellBookSpellBank.Pet
  elseif tonumber(bookType) then
    spellBank = tonumber(bookType)
  end
  local index = FindSpellBookSlotBySpellID(spellId, spellBank)
  return C_SpellBook.PickupSpellBookItem(index, spellBank)
end

ns.UnitAura = UnitAura or function(unitToken, index, filter)
  local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter);
  if not auraData then
    return nil;
  end
  return AuraUtil.UnpackAuraData(auraData);
end

ns.UnitBuff = UnitBuff or function(unitToken, index, filter)
  local auraData = C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter);
  if not auraData then
    return nil;
  end
  return AuraUtil.UnpackAuraData(auraData);
end
