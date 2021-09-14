local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8


local function UpdateTime(block, elapsedTime)
  if not block then
    return
  end

  if not block.BarPlus3 then
    block.BarPlus3 = block:CreateTexture(nil, "OVERLAY")
    block.BarPlus3:SetPoint("TOPLEFT", block.StatusBar, "TOPLEFT", block.StatusBar:GetWidth() * (1 - TIME_FOR_3) - 4, 0)
    block.BarPlus3:SetSize(8, 10)
    block.BarPlus3:SetTexture("Interface\\Addons\\BetterKeystones\\bar")
    block.BarPlus3:SetTexCoord(0, 0.5, 0, 1)
  end

  if not block.BarPlus2 then
    block.BarPlus2 = block:CreateTexture(nil, "OVERLAY")
    block.BarPlus2:SetPoint("TOPLEFT", block.StatusBar, "TOPLEFT", block.StatusBar:GetWidth() * (1 - TIME_FOR_2) - 4, 0)
    block.BarPlus2:SetSize(8, 10)
    block.BarPlus2:SetTexture("Interface\\Addons\\BetterKeystones\\bar")
    block.BarPlus2:SetTexCoord(0.5, 1, 0, 1)
  end
end
hooksecurefunc("Scenario_ChallengeMode_UpdateTime", UpdateTime)

local progressCache = {}
local isTeemingWeek

local function OnTooltipSetUnit(tooltip)
  if not tooltip then
    return
  end

  local scenarioType = select(10, C_Scenario.GetInfo())
  if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
    local name, unit = tooltip:GetUnit()
    local guid = unit and UnitGUID(unit)
    if guid then
      local value, total, progressName
      local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)
      local npcId = tonumber(npc_id)
      local npcProgressCache = progressCache[npcId]
      if npcProgressCache then
        value = npcProgressCache[0]
        total = npcProgressCache[1]
        progressName = npcProgressCache[2]
      elseif MDT then
        if isTeemingWeek == nill then
          local _, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
          isTeemingWeek = false
          for _, affixID in ipairs(affixes) do
              if affixID == 5 then
                isTeemingWeek = true
              end
          end
          print("HHH "..tostring(isTeemingWeek))
        end
        local count, max, maxTeeming, teemingCount = MDT:GetEnemyForces(npcId)
        print("XXX "..count.."|"..max.."|"..maxTeeming.."|"..teemingCount)

        npcProgressCache = {}
        npcProgressCache[0] = value
        npcProgressCache[1] = total
        npcProgressCache[2] = progressName
        progressCache[npcId] = npcProgressCache
      end

      if value and total and progressName then
        print("test 2")
        local forcesFormat = format(" - %s: %%s", progressName)
        local text = format( format(forcesFormat, "+%.2f%%"), value/total*100)

        if text then
          local matcher = format(forcesFormat, "%d+%%")
          for i = 2, tooltip:NumLines() do
            local tiptext = _G["GameTooltipTextLeft"..i]
            local linetext = tiptext and tiptext:GetText()

            if linetext and linetext:match(matcher) then
              tiptext:SetText(text)
              tooltip:Show()
            end
          end
        end
      end
    end
  end
end
--GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

local function SlotKeystone()
  for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
    local slots = GetContainerNumSlots(container)
    for slot = 1, slots do
      local _, _, _, _, _, _, slotLink, _, _, _ = GetContainerItemInfo(container, slot)
      if slotLink and slotLink:match("|Hkeystone:") then
        PickupContainerItem(container, slot)
        if CursorHasItem() then
          C_ChallengeMode.SlotKeystone()
        end
      end
    end
  end
end
ChallengesKeystoneFrame:HookScript("OnShow", SlotKeystone)

local function ChatKeystoneFilter(_, event, msg)
  if msg and strlower(msg) == '!keys' then
    local channel
    if event == CHAT_MSG_GUILD then
      channel = "GUILD"
    elseif event == CHAT_MSG_PARTY then
      channel = "PARTY"
    end

    if channel then
      for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = GetContainerNumSlots(container)
        for slot = 1, slots do
          local _, _, _, _, _, _, slotLink, _, _, _ = GetContainerItemInfo(container, slot)
          if slotLink and slotLink:match("|Hkeystone:") then
            SendChatMessage(slotLink, channel)
          end
        end
      end
    end
  end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", ChatKeystoneFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", ChatKeystoneFilter)