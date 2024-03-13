--#region Variables

---@type table <string, Vehicle>
local vehicles = {}

---@type table <string | number, vector4>
local parkingSpots = {}
local hasStarted = false

local config = require "config"
local framework = require(("server.framework.%s"):format(config.framework))
local db = require "server.db"

--#endregion Variables

--#region Functions

---Add a vehicle
---@param owner number | string The identifier of the owner of the car
---@param plate string The plate number of the car
---@param model string | number The hash of the model
---@param props? table The vehicle properties
---@param location? 'outside' | 'parked' | 'impound' The location that the vehicle is at
---@param _type? string Type of the vehicle
---@param temporary? boolean If true, will not add the vehicle to the database
---@return boolean
local function addVehicle(owner, plate, model, props, location, _type, temporary)
    plate = plate and plate:upper() or plate
    if not owner or not plate or not model then return false end

    if vehicles[plate] then return true end

    model = type(model) == "string" and joaat(model) or model
    props = props or {}
    location = location or "outside"

    vehicles[plate] = {
        owner = owner,
        model = model,
        props = props,
        location = location,
        type = _type,
        temporary = temporary,
    }

    return true
end

exports("addVehicle", addVehicle)

---Remove a vehicle
---@param plate string The plate number of the car
---@return boolean
local function removeVehicle(plate)
    plate = plate and plate:upper() or plate
    if not plate or not vehicles[plate] then return false end

    vehicles[plate] = nil

    return true
end

exports("removeVehicle", removeVehicle)

---Get a vehicle by its plate
---@param plate string The plate number of the car
---@return Vehicle?
local function getVehicle(plate)
    plate = plate and plate:upper() or plate
    return vehicles[plate]
end

exports("getVehicle", getVehicle)

---Get a vehicle by its plate and check if they're owner
---@param source integer
---@param plate string The plate number of the car
---@return Vehicle?
local function getVehicleOwner(source, plate)
    local vehicle = getVehicle(plate)
    local owner = vehicle?.owner == framework.getIdentifier(framework.getPlayerId(source))
    return owner and vehicle or nil
end

exports("getVehicleOwner", getVehicleOwner)

---Get all vehicles from an owner, with an optional location filter
---@param owner number | string The identifier of the owner of the car
---@param location? 'outside' | 'parked' | 'impound' The location that the vehicle is at
---@return table<string, Vehicle>, number
local function getVehicles(owner, location)
    local ownedVehicles = {}
    local amount = 0
    for k, v in pairs(vehicles) do
        if v.owner == owner and (location and v.location == location or not location) then
            ownedVehicles[k] = v
            amount += 1
        end
    end

    return ownedVehicles, amount
end

exports("getVehicles", getVehicles)

---Set the status of a vehicle and perform actions based on it, doesn't work with the 'outside' status
---@param owner number | string The identifier of the owner of the car
---@param plate string The plate number of the car
---@param status 'parked' | 'impound' The location that the vehicle is at, so the status
---@param props? table The vehicle properties
---@return boolean
---@return string
local function setVehicleStatus(owner, plate, status, props)
    plate = plate and plate:upper() or plate

    if not owner or not vehicles[plate] or not plate then
        return false, locale("failed_to_set_status")
    end

    local ply = framework.getPlayerIdentifier(owner)
    if not ply or vehicles[plate].owner ~= owner then
        return false, locale("not_owner")
    end

    if status == "parked" and config.garage.storeVehicle ~= -1 then
        if framework.getMoney(ply.source) < config.garage.storeVehicle then
            return false, locale("invalid_funds")
        end
        framework.removeMoney(ply.source, config.garage.storeVehicle)
    end

    vehicles[plate].location = status
    vehicles[plate].props = props or {}

    return true, status == "parked" and locale("successfully_parked") or status == "impound" and locale("successfully_impounded") or ""
end

exports("setVehicleStatus", setVehicleStatus)

---Generates and returns a random number plate with the given pattern
---@param pattern? string
---@return string
local function getRandomPlate(pattern)
    pattern = pattern or "........"
    return lib.string.random(pattern):upper()
end

exports("getRandomPlate", getRandomPlate)

---Save all vehicles and parking locations to the database
local function saveData()
    db.saveVehicle(vehicles)
    db.saveParkingSpot(parkingSpots)
end

exports("saveData", saveData)

--#endregion Functions

--#region Callbacks

---@param plate string
lib.callback.register("bgarage:server:getVehicle", function(_, plate)
    local entity = getVehicle(plate)
    return entity
end)

---@param source integer
---@param plate string
lib.callback.register("bgarage:server:getVehicleOwner", function(source, plate)
    local owner = getVehicleOwner(source, plate)
    return owner
end)

---@param source integer
lib.callback.register("bgarage:server:getOwnedVehicles", function(source)
    local ownedVehicles = getVehicles(framework.getIdentifier(framework.getPlayerId(source)))
    return ownedVehicles
end)

---@param source integer
lib.callback.register("bgarage:server:getParkedVehicles", function(source)
    local parkedVehicles = getVehicles(framework.getIdentifier(framework.getPlayerId(source)), "parked")
    return parkedVehicles
end)

---@param source integer
lib.callback.register("bgarage:server:getImpoundedVehicles", function(source)
    local impoundedVehicles = getVehicles(framework.getIdentifier(framework.getPlayerId(source)), "impound")
    return impoundedVehicles
end)

---@param source integer
lib.callback.register("bgarage:server:getOutsideVehicles", function(source)
    local outsideVehicles = getVehicles(framework.getIdentifier(framework.getPlayerId(source)), "outside")
    return outsideVehicles
end)

---@param plate string
lib.callback.register("bgarage:server:getVehicleCoords", function(_, plate)
    plate = plate and plate:upper() or plate
    if not vehicles[plate] then return end

    local pool = GetAllVehicles()

    for i = 1, #pool do
        local veh = pool[i]
        if GetVehicleNumberPlateText(veh) == plate then
            return GetEntityCoords(veh)
        end
    end
end)

---@param source integer
---@param status 'parked' | 'impound'
---@param plate string
---@param props? table
---@param owner? number | string
lib.callback.register("bgarage:server:setVehicleStatus", function(source, status, plate, props, owner)
    if not owner then
        local ply = framework.getPlayerId(source)
        if not ply then
            return false, locale("failed_to_set_status")
        end
        owner = framework.getIdentifier(ply)
    end

    return setVehicleStatus(owner, plate, status, props)
end)

---@param model number
---@param coords vector4
---@param plate string
lib.callback.register("bgarage:server:spawnVehicle", function(_, model, coords, plate)
    plate = plate and plate:upper() or plate
    if not plate or not vehicles[plate] or not model or not coords then return end

    vehicles[plate].location = "outside"

    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)
    while not DoesEntityExist(tempVehicle) do
        Wait(0)
    end

    local entityType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)

    local veh = CreateVehicleServerSetter(model, entityType, coords.x, coords.y, coords.z, coords.w)
    while not DoesEntityExist(veh) do
        Wait(0)
    end

    SetVehicleNumberPlateText(veh, plate)

    return NetworkGetNetworkIdFromEntity(veh)
end)

---@param source integer
---@param price number
---@param remove? boolean
lib.callback.register("bgarage:server:payFee", function(source, price, remove)
    if not source then return end

    if price == -1 then return true end

    local plyMoney = framework.getMoney(source)
    if plyMoney < price then
        return false, locale("invalid_funds")
    end

    if remove then
        framework.removeMoney(source, price)
    end

    return true
end)

---@param target integer
---@param model string | number
lib.callback.register("bgarage:server:giveVehicle", function(_, target, model)
    if not target or not model then
        return false, locale("target_model_mising")
    end

    local ply = framework.getPlayerId(target)
    if not ply then
        return false, locale("player_doesnt_exist")
    end

    local plyName = framework.getFullName(ply)
    local identifier = framework.getIdentifier(ply)
    local plate = getRandomPlate()

    local success = addVehicle(identifier, plate, model, {}, "parked")
    if config.logging then
        local admin = framework.getPlayerId(source)
        local adminName = framework.getFullName(admin)
        lib.logger(source, "admin", ("**'%s'** provided the vehicle model **'%s'** with the license plate **'%s'** to **'%s'**."):format(adminName, model, plate, plyName))
    end

    return success, success and locale("successfully_add"):format(model, plyName) or locale("failed_to_add"), plate
end)

---@param netId integer
lib.callback.register("bgarage:server:deleteVehicle", function(_, netId)
    if not netId or netId == 0 then return false end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then return false end

    DeleteEntity(vehicle)

    return true
end)

---@param source integer
---@param coords vector4
lib.callback.register("bgarage:server:setParkingSpot", function(source, coords)
    local ply = framework.getPlayerId(source)
    if not coords or not ply then
        return false, locale("failed_to_save_parking")
    end

    local identifier = framework.getIdentifier(ply)
    parkingSpots[identifier] = coords

    -- It is recommended to move this logging implementation elsewhere and modify it according to your specific requirements.
    if config.logging then
        local plyName = framework.getFullName(ply)
        lib.logger(source, "admin", ("**'%s'** bought a parking space at **'%s'**."):format(plyName, coords))
    end

    return true, locale("successfully_saved_parking")
end)

---@param source integer
lib.callback.register("bgarage:server:getParkingSpot", function(source)
    local ply = framework.getPlayerId(source)
    if not ply or not parkingSpots then return end

    local identifier = framework.getIdentifier(ply)
    local location = parkingSpots[identifier]

    return location
end)

lib.callback.register("bgarage:server:hasStarted", function()
    return hasStarted
end)

--#endregion Callbacks

--#region Events

---@param plate string
---@param netId integer
RegisterNetEvent("bgarage:server:vehicleSpawnFailed", function(plate, netId)
    plate = plate and plate:upper() or plate

    if not plate or not vehicles[plate] then return end

    local ply = framework.getPlayerId(source)
    if not ply or vehicles[plate].owner ~= framework.getIdentifier(ply) then return end

    vehicles[plate].location = "impound"

    if not netId then return end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then return end

    DeleteEntity(veh)
end)

---@param entity number
AddEventHandler("entityRemoved", function(entity)
    local entityType = GetEntityType(entity)
    if entityType ~= 2 then return end

    local plate = GetVehicleNumberPlateText(entity)

    local data = vehicles[plate]
    if not data or data.location ~= "outside" then return end

    data.location = "impound"
end)

---@param resource string
AddEventHandler("onResourceStop", function(resource)
    if resource ~= "bgarage" then return end
    saveData()
end)

--#endregion Events

--#region Commands

lib.addCommand("admincar", {
    help = locale("cmd_help"),
    params = {},
    restricted = config.adminGroup,
}, function(source)
    if not hasStarted then return end

    local ply = framework.getPlayerId(source)
    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not DoesEntityExist(vehicle) then
        framework.Notify(source, locale("not_in_vehicle"), config.notifications.duration, config.notifications.position, "inform", config.notifications.icons[0])
        return
    end

    local identifier = framework.getIdentifier(ply)
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)

    local success = addVehicle(identifier, plate, model, {}, "outside", "car", false)

    framework.Notify(source, success and locale("successfully_set") or locale("failed_to_set"), config.notifications.duration, config.notifications.position, success and "inform" or "error", config.notifications.icons[2])
end)

if config.debug then
    lib.addCommand("fetchvehicles", {
        help = "Generate vehicle/parking data from the database",
        params = {},
        restricted = config.adminGroup,
    }, function(source)
        if not hasStarted then return end

        local ply = framework.getPlayerId(source)
        if not ply then return end

        db.fetchOwnedVehicles(vehicles)
        db.fetchParkingLocations(parkingSpots)
        SaveResourceFile("bgarage", "vehicles.json", json.encode(vehicles, { indent = true, sort_keys = true, indent_count = 2 }), -1)
        framework.Notify(source, "Data successfully generated and saved", config.notifications.duration, config.notification.position, config.notifications.iconColors["error"], config.notifications.icons[0])
    end)
end

--#endregion Commands

--#region Threads

CreateThread(function()
    Wait(1000)
    db.fetchOwnedVehicles(vehicles)
    db.fetchParkingLocations(parkingSpots)
    hasStarted = true
    TriggerClientEvent("bgarage:client:startedCheck", -1)
end)

lib.cron.new(("*/%s * * * *"):format(config.database.interval), saveData, { debug = config.debug })

CreateThread(function()
    while true do
        Wait(500)

        local players = GetPlayers()
        local spawnedVehicles = {}
        local cache = {}
        local pool = GetAllVehicles()

        for i = 1, #players do
            local player = players[i]
            local spawnedVehicle = lib.callback.await("bgarage:client:getTempVehicle", player)
            if spawnedVehicle then
                cache[spawnedVehicle] = true
            end
        end

        for i = 1, #pool do
            if DoesEntityExist(pool[i]) then
                spawnedVehicles[GetVehicleNumberPlateText(pool[i])] = pool[i]
            end
        end

        for k, v in pairs(vehicles) do
            if v.location == "outside" and not spawnedVehicles[k] and not cache[k] then
                vehicles[k].location = "impound"
            end
        end
    end
end)

--#endregion Threads

--#region Startup

if GetCurrentResourceName() ~= "bgarage" then
    error("Please don\'t rename this resource, change the folder name (back) to \'bgarage\'.")
    return
end

if not LoadResourceFile("bgarage", "web/dist/index.html") then
    error("UI has not been built, refer to the 'README.md' or download a release build.\n^3https://github.com/bebomusa/bgarage/releases/latest^0")
    return
end

lib.versionCheck("bebomusa/bgarage")

--#endregion Startup
