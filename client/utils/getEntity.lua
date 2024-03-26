---@param entity any
local function getEntity(entity)
    local ent = NetworkDoesEntityExistWithNetworkId(entity) and NetworkGetEntityFromNetworkId(entity)
    if not ent or ent == 0 or not DoesEntityExist(ent) or NetworkGetEntityOwner(ent) ~= cache.playerId then return nil end
    return ent
end

return getEntity
