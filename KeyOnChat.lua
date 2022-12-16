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
                local totalBags = NUM_BAG_SLOTS or 4
                for bagId = 0, totalBags do
                    for slotId = 1, C_Container.GetContainerNumSlots(bagId) do
                        local info = C_Container.GetContainerItemInfo(bagId, slotId)
                        if info and info.hyperlink:match("|Hkeystone:") then
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