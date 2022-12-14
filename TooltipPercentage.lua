local progressCache = {}

local function OnTooltipSetUnit(tooltip, tooltipData)
    if not MDT then
        return
    end

    local guid = tooltipData.guid
    local unit = UnitTokenFromGUID(guid)
    if unit and not UnitIsPlayer(unit) and UnitCanAttack("player", unit) then
        local count, max
        local type, zero, serverId, instanceId, zoneUid, npcId, spawnUid = strsplit("-", guid)
        local npcProgressCache = progressCache[npcId]
        if npcProgressCache then
            count = npcProgressCache[0]
            max = npcProgressCache[1]
        else
            local scenarioType = select(10, C_Scenario.GetInfo())
            if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
                count, max, _, _ = MDT:GetEnemyForces(npcId)

                if count and max then
                    npcProgressCache = {}
                    npcProgressCache[0] = count
                    npcProgressCache[1] = max
                    progressCache[npcId] = npcProgressCache
                end
            end
        end

        if count and max then
            local newText = format(" - Enemy Forces: %d/%d|+%.2f%%", count, max, (count / max * 100))
            local matched = false

            for i = 2, tooltip:NumLines() do
                local tooltipLine = _G["GameTooltooltipLineLeft"..i]
                local lineText = tooltipLine and tooltipLine:GetText()

                if lineText and lineText:match(" - Enemy Forces:.*") then
                    tooltipLine:SetText(newText)
                    matched = true
                    break
                end
            end

            if not matched then
                tooltip:AddLine(newText)
            end

            tooltip:Show()
        end
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)