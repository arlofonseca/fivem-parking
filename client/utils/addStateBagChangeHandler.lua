local getEntityFromStateBagName = require 'client.utils.getEntityFromStateBagName'

---@param bagName string
---@param key string
---@param value any
AddStateBagChangeHandler('vehicleProperties', 'vehicle', function(bagName, key, value)
    if not value then return end

    local entity = getEntityFromStateBagName(bagName, key)
    if not entity then return end

    Wait(500)

    local vehicle = NetworkDoesEntityExistWithNetworkId(entity) and NetworkGetEntityFromNetworkId(entity)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) or NetworkGetEntityOwner(vehicle) ~= cache.playerId then return end

    local props = json.decode(value.vehicle)
    if not SetVehicleProperties(vehicle, props) then return end

    local state = Entity(vehicle).state
    state:set(key, nil, true)
end)

---@param bagName string
---@param key string
---@param value any
AddStateBagChangeHandler('cacheVehicle', 'vehicle', function(bagName, key, value)
    if not value then return end

    local entity = getEntityFromStateBagName(bagName, key)
    if not entity then return end

    Wait(500)

    local vehicle = NetworkDoesEntityExistWithNetworkId(entity) and NetworkGetEntityFromNetworkId(entity)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) or NetworkGetEntityOwner(vehicle) ~= cache.playerId then return end

    PlaceObjectOnGroundProperly(vehicle)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetEntityAsMissionEntity(vehicle, true, true)

    local state = Entity(vehicle).state
    state:set(key, nil, true)
end)
