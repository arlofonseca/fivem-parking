local getEntity = require 'client.utils.getEntity'
local getEntityFromStateBagName = require 'client.utils.getEntityFromStateBagName'
local getState = require 'client.utils.getState'

---@param bagName string
---@param key string
---@param value any
AddStateBagChangeHandler('vehicleProperties', 'vehicle', function(bagName, key, value)
    if not value then return end

    local entity = getEntityFromStateBagName(bagName, key)
    if not entity then return end

    Wait(500)

    local vehicle = getEntity(entity)
    if not vehicle then return end

    local props = json.decode(value.vehicle)
    if not SetVehicleProperties(vehicle, props) then return end

    local state = getState(vehicle)
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

    local vehicle = getEntity(entity)
    if not vehicle then return end

    PlaceObjectOnGroundProperly(vehicle)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetEntityAsMissionEntity(vehicle, true, true)

    local state = getState(vehicle)
    state:set(key, nil, true)
end)
