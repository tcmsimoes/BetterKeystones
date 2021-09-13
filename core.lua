local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8


local function UpdateTime(block, elapsedTime)
  block.BarPlus3 = block:CreateTexture(nil, "OVERLAY")
  block.BarPlus3:SetPoint("TOPLEFT", block.StatusBar, "TOPLEFT", block.StatusBar:GetWidth() * (1 - TIME_FOR_3) - 4, 0)
  block.BarPlus3:SetSize(8, 10)
  block.BarPlus3:SetTexture("Interface\\Addons\\BetterKeystones\\bar")
  block.BarPlus3:SetTexCoord(0, 0.5, 0, 1)

  block.BarPlus2 = block:CreateTexture(nil, "OVERLAY")
  block.BarPlus2:SetPoint("TOPLEFT", block.StatusBar, "TOPLEFT", block.StatusBar:GetWidth() * (1 - TIME_FOR_2) - 4, 0)
  block.BarPlus2:SetSize(8, 10)
  block.BarPlus2:SetTexture("Interface\\Addons\\BetterKeystones\\bar")
  block.BarPlus2:SetTexCoord(0.5, 1, 0, 1)
end
hooksecurefunc("Scenario_ChallengeMode_UpdateTime", UpdateTime)

local function OnTooltipSetUnit(tooltip)
	local scenarioType = select(10, C_Scenario.GetInfo())
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
    local numCriteria = select(3, C_Scenario.GetStepInfo())
    local total
    local progressName
    for criteriaIndex = 1, numCriteria do
      local criteriaString, _, _, quantity, totalQuantity, _, _, quantityString, _, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)
      if isWeightedProgress then
        progressName = criteriaString
        total = totalQuantity
      end
    end

    local value, valueCount
    if info then
      for amount, count in pairs(info) do
        if not valueCount or count > valueCount or (count == valueCount and amount < value) then
          value = amount
          valueCount = count
        end
      end
    end

    if value and total then
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
GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

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