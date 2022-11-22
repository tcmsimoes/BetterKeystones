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