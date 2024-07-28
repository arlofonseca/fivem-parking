---@param eventName string
---@param playerId number
---@param eventData any
local function triggerEvent(eventName, playerId, eventData)
    return TriggerClientEvent(eventName, playerId, eventData)
end

return triggerEvent