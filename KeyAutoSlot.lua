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
local myFrame = CreateFrame("Frame")
myFrame:RegisterEvent("ADDON_LOADED")
myFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

myFrame:SetScript("OnEvent", function(self, event, ...)
    if IsAddOnLoaded("Blizzard_ChallengesUI") and ChallengesKeystoneFrame and ChallengesKeystoneFrame.OnShow then
        ChallengesKeystoneFrame:HookScript("OnShow", SlotKeystone)

        self:UnregisterEvent('PLAYER_ENTERING_WORLD', self)
    end
end)