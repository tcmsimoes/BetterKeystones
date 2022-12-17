local function SlotKeystone()
    local totalBags = NUM_BAG_SLOTS or 4
    for bagId = 0, totalBags do
        for slotId = 1, C_Container.GetContainerNumSlots(bagId) do
            local info = C_Container.GetContainerItemInfo(bagId, slotId)
            if info and info.hyperlink and info.hyperlink:match("|Hkeystone:") then
                C_Container.PickupContainerItem(bagId, slotId)
                if CursorHasItem() then
                    C_ChallengeMode.SlotKeystone()
                end
            end
        end
    end
end
local myFrame = CreateFrame("Frame")
myFrame:RegisterEvent("ADDON_LOADED")
myFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

myFrame:SetScript("OnEvent", function(self, event, ...)
    if IsAddOnLoaded("Blizzard_ChallengesUI") and ChallengesKeystoneFrame and ChallengesKeystoneFrame.OnShow then
        ChallengesKeystoneFrame:HookScript("OnShow", SlotKeystone)

        self:UnregisterEvent('PLAYER_ENTERING_WORLD', self)
    end
end)