local function OnTooltipSetUnit(tooltip, tooltipData)
    if not MDT then
        return
    end

    local guid = tooltipData.guid
    local unit = UnitTokenFromGUID(guid)
    if guid and unit then
        local scenarioType = select(10, C_Scenario.GetInfo())
        if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
            local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)

            local count, total, _, _ = MDT:GetEnemyForces(tonumber(npc_id))
            if count and total then
                local forcesText = " - Enemy Forces: %s"
                local text = format("(+%.2f%%)", count/total*100)

                if text then
                    local matcher = format(forcesText, "%d+%%")
                    for i=2, tooltip:NumLines() do
                        local tooltipText = _G["GameTooltipTextLeft"..i]
                        local lineText = tooltipText and tooltipText:GetText()

                        if lineText and lineText:match(matcher) then
                            tooltipText:SetText(lineText.." "..text)
                            tooltip:Show()
                            break
                        end
                    end
                end
            end
        end
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)