local initialized = false
local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8

local function UpdateTime(block, elapsedTime)
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
    local scenarioType = select(10, C_Scenario.GetInfo())
    if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
        local name, unit = tooltip:GetUnit()
        if unit and not UnitIsPlayer(unit) and UnitCanAttack("player", unit) then
            local guid = unit and UnitGUID(unit)
            if guid then
                local value, total
                local type, zero, serverId, instanceId, zoneUid, npcId, spawnUid = strsplit("-", guid)
                local npcId = tonumber(npcId)
                local npcProgressCache = progressCache[npcId]
                if npcProgressCache then
                    value = npcProgressCache[0]
                    total = npcProgressCache[1]
                elseif MDT then
                    if isTeemingWeek == nill then
                        isTeemingWeek = false
                        local _, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
                        for _, affixId in ipairs(affixes) do
                            if affixId == 5 then
                                isTeemingWeek = true
                            end
                        end
                    end

                    local count, max, maxTeeming, teemingCount = MDT:GetEnemyForces(npcId)

                    if isTeemingWeek then
                        value = count
                        total = max
                    else
                        value = teemingCount
                        total = maxTeeming
                    end

                    npcProgressCache = {}
                    npcProgressCache[0] = value
                    npcProgressCache[1] = total
                    progressCache[npcId] = npcProgressCache
                else
                    print("MythicDungeonTools addon not found!")
                end

                if value and total then
                    local forcesMatcher = " - Enemy Forces: (%d+%%).*"

                    for i=2, tooltip:NumLines() do
                        local tiptext = _G["GameTooltipTextLeft"..i]
                        local linetext = tiptext and tiptext:GetText()

                        if linetext then
                            for match in linetext:gmatch(forcesMatcher) do
                                tiptext:SetText(format(" - Enemy Forces: %s | +%.2f%%", match, (value/total*100)))
                                tooltip:Show()
                            end
                        end
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


local previousLineId = -1

local function ChatKeystoneFilter(_, event, msg, player, _, _, _, _, _, _, _, _, lineId, guid)
    if lineId ~= previousLineId then
        previousLineId = lineId

        if msg and strlower(msg) == '!keys' then
            local channel
            if event == "CHAT_MSG_GUILD" then
                channel = "GUILD"
            elseif event == "CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_PARTY" then
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
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatKeystoneFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", ChatKeystoneFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", ChatKeystoneFilter)

local myFrame = CreateFrame("Frame")
myFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

myFrame:SetScript("OnEvent", function(self, event, ...)
    if event == 'PLAYER_ENTERING_WORLD' and not initialized then
        initialized = true
        ChallengesKeystoneFrame:HookScript("OnShow", SlotKeystone)
    end
end)