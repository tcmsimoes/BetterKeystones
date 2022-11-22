C_LFGList.GetPlaystyleString = function(playstyle,activityInfo)
    if activityInfo and playstyle ~= (0 or nil) and C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID).showPlaystyleDropdown then
        local typeStr
        if activityInfo.isMythicPlusActivity then
            typeStr = "GROUP_FINDER_PVE_PLAYSTYLE"
        elseif activityInfo.isRatedPvpActivity then
            typeStr = "GROUP_FINDER_PVP_PLAYSTYLE"
        elseif activityInfo.isCurrentRaidActivity then
            typeStr = "GROUP_FINDER_PVE_RAID_PLAYSTYLE"
        elseif activityInfo.isMythicActivity then
            typeStr = "GROUP_FINDER_PVE_MYTHICZERO_PLAYSTYLE"
        end

        return typeStr and _G[typeStr .. tostring(playstyle)] or nil
    else
        return nil
    end
end



local function componentToHex(c)
    c = math.floor(c * 255)
    local hex = string.format("%x", c)
    if hex:len() == 1 then
        return "0"..hex
    end
    return hex
end

local function rgbToHex(r, g, b)
    return componentToHex(r)..componentToHex(g)..componentToHex(b)
end

local function getColorStr(hexColor)
    return "|cff"..hexColor.."+|r"
end

local function getRioScoreColorText(score)
    if not RaiderIO then return nil end

    local r, g, b = RaiderIO.GetScoreColor(score)
    local hex = rgbToHex(r, g, b)

    return getColorStr(hex)
end

local function getIndex(values, val)
    local index = {}

    for k,v in pairs(values) do
        index[v]= k
    end

    return index[val]
end

local function getRioScore(fullname)
    if not RaiderIO then return 0 end

    if not string.match(fullname, "-") then
        local realmName = string.gsub(GetRealmName(), " ", "")
        fullname = fullname.."-"..realmName
    end

    local FACTIONS = { Alliance = 1, Horde = 2, Neutral = 3 }
    local playerFactionID = FACTIONS[UnitFactionGroup("player")]
    local playerProfile = RaiderIO.GetProfile(fullname, playerFactionID)
    local currentScore = 0
    local previousScore = 0

    if playerProfile and playerProfile.mythicKeystoneProfile then
        currentScore = playerProfile.mythicKeystoneProfile.currentScore or 0
        previousScore = playerProfile.mythicKeystoneProfile.previousScore or 0
    end

    return currentScore
end

local function getRioScoreText(rioScore)
    if rioScore <= 0 then return "" end

    local colorText = getRioScoreColorText(rioScore)

    if not colorText then return "" end

    local rioText = colorText:gsub("+", rioScore)

    return "["..rioText.."] "
end


local function searchEntryUpdate(entry, ...)
    if not LFGListFrame.SearchPanel:IsShown() then return end

    local categoryID = LFGListFrame.SearchPanel.categoryID
    local resultID = entry.resultID
    local resultInfo = C_LFGList.GetSearchResultInfo(resultID)
    local leaderName = resultInfo.leaderName
    entry.rioScore = 0

    if leaderName then
        entry.rioScore = getRioScore(leaderName)
    end

    for i = 1, 5 do
        local texture = "tex"..i
        if entry.DataDisplay.Enumerate[texture] then
            entry.DataDisplay.Enumerate[texture]:Hide()
        end
    end

    if categoryID == 2 then
        local numMembers = resultInfo.numMembers
        local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID)
        local isApplication = entry.isApplication

        entry.DataDisplay:SetPoint("RIGHT", entry.DataDisplay:GetParent(), "RIGHT", 0, -5)

        local orderIndexes = {}

        for i=1, numMembers do
            local role, class = C_LFGList.GetSearchResultMemberInfo(resultID, i)
            local orderIndex = getIndex(LFG_LIST_GROUP_DATA_ROLE_ORDER, role)
            table.insert(orderIndexes, {orderIndex, class})
        end

        table.sort(orderIndexes, function(a,b)
            return a[1] < b[1]
        end)

        local xOffset = -88

        for i = 1, numMembers do
            local class = orderIndexes[i][2]
            local classColor = RAID_CLASS_COLORS[class]
            local r, g, b, a = classColor:GetRGBA()
            local texture = "tex"..i

            if not entry.DataDisplay.Enumerate[texture] then
                entry.DataDisplay.Enumerate[texture] = entry.DataDisplay.Enumerate:CreateTexture(nil, "ARTWORK")
                entry.DataDisplay.Enumerate[texture]:SetSize(10, 3)
                entry.DataDisplay.Enumerate[texture]:SetPoint("RIGHT", entry.DataDisplay.Enumerate, "RIGHT", xOffset, 15)
            end

            entry.DataDisplay.Enumerate[texture]:Show()
            entry.DataDisplay.Enumerate[texture]:SetColorTexture(r, g, b, 0.75)

            xOffset = xOffset + 18
        end
    end

    local name = entry.Name:GetText() or ""
    local rioText = getRioScoreText(entry.rioScore)

    entry.Name:SetText(rioText..name)
end

local function HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
    local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID)
    local playerRole = GetSpecializationRole(GetSpecialization())
    local roleRemainingKeyLookup = {
        ["TANK"] = "TANK_REMAINING",
        ["HEALER"] = "HEALER_REMAINING",
        ["DAMAGER"] = "DAMAGER_REMAINING",
    }

    return roles[roleRemainingKeyLookup[playerRole]] > 0
end

local function sortSearchResultsCB(searchResultID1, searchResultID2)
    local searchResultInfo1 = C_LFGList.GetSearchResultInfo(searchResultID1)
    local searchResultInfo2 = C_LFGList.GetSearchResultInfo(searchResultID2)

    local hasRemainingRole1 = HasRemainingSlotsForLocalPlayerRole(searchResultID1)
    local hasRemainingRole2 = HasRemainingSlotsForLocalPlayerRole(searchResultID2)

    local leaderName1 = searchResultInfo1.leaderName
    local leaderName2 = searchResultInfo2.leaderName

    local rioScore1 = 0
    local rioScore2 = 0

    if leaderName1 then
        rioScore1 = getRioScore(leaderName1)
    end

    if leaderName2 then
        rioScore2 = getRioScore(leaderName2)
    end

    if (hasRemainingRole1 ~= hasRemainingRole2) then
        return hasRemainingRole1
    end

    return rioScore1 > rioScore2
end

local function sortSearchResults(results)
    local categoryID = LFGListFrame.SearchPanel.categoryID

    if #results > 0 and categoryID == 2 then
        -- filter if needed

        table.sort(results, sortSearchResultsCB)
    end

    if #results > 0 then
        LFGListSearchPanel_UpdateResults(LFGListFrame.SearchPanel)
    end
end

local function updateApplicantMember(member, appID, memberIdx, ...)
    if not RaiderIO then return end

    local textName = member.Name:GetText()
    local name, class = C_LFGList.GetApplicantMemberInfo(appID, memberIdx)
    local nameLength = 100
    local rioScore = getRioScore(name)
    local rioText = getRioScoreText(rioScore)

    if memberIdx > 1 then
        member.Name:SetText("  "..rioText..textName)
    else
        member.Name:SetText(rioText..textName)
    end

    if member.Name:GetWidth() > nameLength then
        member.Name:SetWidth(nameLength)
    end
end

local function sortApplicantsCB(applicantID1, applicantID2)
    local applicantInfo1 = C_LFGList.GetApplicantInfo(applicantID1)
    local applicantInfo2 = C_LFGList.GetApplicantInfo(applicantID2)

    local name1 = C_LFGList.GetApplicantMemberInfo(applicantInfo1.applicantID, 1)
    local name2 = C_LFGList.GetApplicantMemberInfo(applicantInfo2.applicantID, 1)

    local rioScore1 = 0
    local rioScore2 = 0

    if name1 then
        rioScore1 = getRioScore(name1)
    end

    if name2 then
        rioScore2 = getRioScore(name2)
    end

    return rioScore1 > rioScore2
end

local function sortApplicants(applicants)
    local categoryID = LFGListFrame.CategorySelection.selectedCategory

    if categoryID == 2 and #applicants > 0 then
        -- filter if needed

        table.sort(applicants, sortApplicantsCB)
    end

    if #applicants > 0 then
        LFGListApplicationViewer_UpdateResults(LFGListFrame.ApplicationViewer)
    end
end


hooksecurefunc("LFGListSearchEntry_Update", searchEntryUpdate)
hooksecurefunc("LFGListUtil_SortSearchResults", sortSearchResults)
hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", updateApplicantMember)
hooksecurefunc("LFGListUtil_SortApplicants", sortApplicants)