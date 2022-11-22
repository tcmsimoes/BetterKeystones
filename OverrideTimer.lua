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