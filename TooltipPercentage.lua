local progressCache = {}

local function OnTooltipSetUnit(tooltip, tooltipData)
    local guid = tooltipData.guid
    local unit = UnitTokenFromGUID(guid)

    if guid and unit then
        local scenarioType = select(10, C_Scenario.GetInfo())
        if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
            local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)
            npc_id = tonumber(npc_id)
            local info = progressCache[npc_id]
            if info then
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
                    local text = format( format(forcesFormat, "+%.2f%% - +%d"), value/total*100, value)

                    if text then
                        local matcher = format(forcesFormat, "%d+%%")
                        for i=2, tooltip:NumLines() do
                            local tooltipText = _G["GameTooltipTextLeft"..i]
                            local lineText = tooltipText and tooltipText:GetText()

                            if lineText and lineText:match(matcher) then
                                tooltipText:SetText(text)
                                tooltip:Show()
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)