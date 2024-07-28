---@param bagName string
---@param keyName string
---@return integer?
local function getEntityFromStateBagName(bagName, keyName)
    local netId = tonumber(bagName:gsub('entity:', ''), 10)

    lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netId) then return true end
    end, ("'%s' received invalid entity '%s'"):format(keyName, bagName), 10000)

    return NetworkGetEntityFromNetworkId(netId)
end

return getEntityFromStateBagName
