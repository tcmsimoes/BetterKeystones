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