--#region Variables

---@type table <string, Vehicle>
local vehicles = {}

---@type table <string | number, vector4>
local parkingSpots = {}
local hasStarted = false

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
    local owner = vehicle?.owner == GetIdentifier(GetPlayerFromId(source))
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

    local ply = GetPlayerFromIdentifier(owner)
    if not ply or vehicles[plate].owner ~= owner then
        return false, locale("not_owner")
    end

    if status == "parked" and Garage.storage ~= -1 then
        if GetMoney(ply.source) < Garage.storage then
            return false, locale("invalid_funds")
        end
        RemoveMoney(ply.source, Garage.storage)
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

---Save all vehicles to the database
local function saveData()
    local queries = {}

    for k, v in pairs(vehicles) do
        if not v.temporary then
            queries[#queries + 1] = {
                query = "INSERT INTO `bgarage_ownedvehicles` (`owner`, `plate`, `model`, `props`, `location`, `type`) VALUES (:owner, :plate, :model, :props, :location, :type) ON DUPLICATE KEY UPDATE props = :props, location = :location",
                values = {
                    owner = tostring(v.owner),
                    plate = k,
                    model = v.model,
                    props = json.encode(v.props),
                    location = v.location,
                    type = v.type,
                },
            }
        end
    end

    for k, v in pairs(parkingSpots) do
        queries[#queries + 1] = {
            query = "INSERT INTO `bgarage_parkingspots` (`owner`, `coords`) VALUES (:owner, :coords) ON DUPLICATE KEY UPDATE coords = :coords",
            values = {
                owner = tostring(k),
                coords = json.encode(v),
            },
        }
    end

    if table.type(queries) == "empty" then return end
    MySQL.transaction(queries, function() end)
end

exports("saveData", saveData)

--#endregion Functions

--#region Events

---@param plate string
---@param netId integer
RegisterNetEvent("bgarage:server:vehicleSpawnFailed", function(plate, netId)
    plate = plate and plate:upper() or plate

    if not plate or not vehicles[plate] then return end

    local ply = GetPlayerFromId(source)
    if not ply or vehicles[plate].owner ~= GetIdentifier(ply) then return end

    vehicles[plate].location = "impound"

    if not netId then return end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then return end

    DeleteEntity(veh)
end)

---OneSync event that is triggered when an entity is removed from the server
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
    if resource ~= GetCurrentResourceName() then return end
    saveData()
end)

--#endregion Events

--#region Callbacks

---@param plate string
lib.callback.register("bgarage:server:getVehicle", function(_, plate)
    return getVehicle(plate)
end)

---@param source integer
---@param plate string
lib.callback.register("bgarage:server:getVehicleOwner", function(source, plate)
    return getVehicleOwner(source, plate)
end)

---@param source integer
lib.callback.register("bgarage:server:getVehicles", function(source)
    return getVehicles(GetIdentifier(GetPlayerFromId(source)))
end)

---@param source integer
lib.callback.register("bgarage:server:getParkedVehicles", function(source)
    return getVehicles(GetIdentifier(GetPlayerFromId(source)), "parked")
end)

---@param source integer
lib.callback.register("bgarage:server:getImpoundedVehicles", function(source)
    return getVehicles(GetIdentifier(GetPlayerFromId(source)), "impound")
end)

---@param source integer
lib.callback.register("bgarage:server:getOutsideVehicles", function(source)
    local outsideVehicles = getVehicles(GetIdentifier(GetPlayerFromId(source)), "outside")
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
        local ply = GetPlayerFromId(source)
        if not ply then
            return false, locale("failed_to_set_status")
        end
        owner = GetIdentifier(ply)
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
lib.callback.register("bgarage:server:payment", function(source, price, remove)
    if not source then return end

    if price == -1 then return true end

    local plyMoney = GetMoney(source)
    if plyMoney < price then
        return false, locale("invalid_funds")
    end

    if remove then
        RemoveMoney(source, price)
    end

    return true
end)

---@param target integer
---@param model string | number
lib.callback.register("bgarage:server:giveVehicle", function(_, target, model)
    if not target or not model then
        return false, locale("missing_model")
    end

    local ply = GetPlayerFromId(target)
    if not ply then
        return false, locale("player_doesnt_exist")
    end

    local identifier = GetIdentifier(ply)
    local plate = getRandomPlate()

    local success = addVehicle(identifier, plate, model, {}, "parked")

    return success, success and locale("successfully_add"):format(model, target) or locale("failed_to_add"), plate
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
    local ply = GetPlayerFromId(source)
    if not coords or not ply then
        return false, locale("failed_to_save_parking")
    end

    parkingSpots[GetIdentifier(ply)] = coords

    -- It is recommended to move this logging implementation elsewhere and modify it according to your specific requirements.
    if Misc.logging then
        local plyName = GetFullName(ply)
        lib.logger(source, "admin", ("'%s' purchased a parking space at **%s**"):format(plyName, coords))
    end

    return true, locale("successfully_saved_parking")
end)

lib.callback.register("bgarage:server:getParkingSpot", function(source)
    local ply = GetPlayerFromId(source)
    if not ply or not parkingSpots then return end

    local identifier = GetIdentifier(ply)
    local location = parkingSpots[identifier]

    return location
end)

lib.callback.register("bgarage:server:hasStarted", function()
    return hasStarted
end)

lib.callback.register("bgarage:server:getRandomPlate", function()
    return getRandomPlate()
end)

--#endregion Callbacks

--#region Commands

lib.addCommand("admincar", {
    help = locale("cmd_help"),
    restricted = Misc.adminGroup,
    params = {},
}, function(source)
    if not hasStarted then return end

    local ply = GetPlayerFromId(source)
    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not DoesEntityExist(vehicle) then
        Notify(source, locale("not_in_vehicle"), 5000, "center-right", "inform", "car", "#3b82f6")
        return
    end

    local identifier = GetIdentifier(ply)
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)

    local success = addVehicle(identifier, plate, model, {}, "outside", "car", false)

    Notify(source, success and locale("successfully_set") or locale("failed_to_set"), 5000, "center-right", success and "inform" or "error", "circle-info", "#3b82f6")
end)

--#endregion Commands

--#region Threads

CreateThread(function()
    Wait(1000)

    local success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_ownedvehicles")

    if success then
        for i = 1, #result do
            local data = result[i] --[[@as VehicleDatabase]]
            local props = json.decode(data.props) --[[@as table]]
            vehicles[data.plate] = {
                owner = IdentifierTypeConversion(data.owner),
                model = data.model,
                props = props,
                location = data.location,
                type = data.type,
            }
        end
    else
        MySQL.query.await("CREATE TABLE bgarage_ownedvehicles (owner VARCHAR(255) NOT NULL, plate VARCHAR(8) NOT NULL, model INT NOT NULL, props LONGTEXT NOT NULL, location VARCHAR(255) DEFAULT 'impound', type VARCHAR(255) DEFAULT 'car', PRIMARY KEY (plate))")
    end

    success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_parkingspots")

    if success then
        for i = 1, #result do
            local data = result[i]
            local owner = IdentifierTypeConversion(data.owner)
            local coords = json.decode(data.coords)
            parkingSpots[owner] = vec4(coords.x, coords.y, coords.z, coords.w)
        end
    else
        MySQL.query.await("CREATE TABLE bgarage_parkingspots (owner VARCHAR(255) NOT NULL, coords LONGTEXT DEFAULT NULL, PRIMARY KEY (owner))")
    end

    hasStarted = true
    TriggerClientEvent("bgarage:client:started", -1)
end)

---Scheduled to run at a specific time interval specified by `SaveTime`.
lib.cron.new(("*/%s * * * *"):format(SaveTime), saveData, { debug = Misc.debug })

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

--#region Debug

if Misc.debug then
    local actions = {
        {
            event = "bgarage:server:purchaseParkingSpace",
            template = "^1[debug:parking:buy] ^3{0} ({1}) attempted to purchase a parking spot but has no funds.",
        },
        {
            event = "bgarage:server:storeVehicleInParkingSpace",
            template = "^1[debug:parking:park] ^3{0} ({1}) attempted to park their vehicle but has no funds.",
        },
        {
            event = "bgarage:server:retrieveVehicleFromList",
            template = "^1[debug:parking:list] ^3{0} ({1}) attempted to retrieve a vehicle from their garage but has no funds.",
        },
        {
            event = "bgarage:server:retrieveVehicleFromImpound",
            template = "^1[debug:parking:impound] ^3{0} ({1}) attempted to retrieve a vehicle from the impound but has no funds.",
        },
        {
            event = "bgarage:server:vehicleNotOwned",
            template = "^1[debug:parking:owner] ^3{0} ({1}) attempted to park a vehicle that they did not own.",
        },
    }

    ---@param event string
    local function actionDebug(event)
        local ply = GetPlayerFromId(source)
        if not ply then return end

        for i = 1, #actions do
            local debug = actions[i]
            if debug.event == event then
                TriggerClientEvent("chat:addMessage", source, {
                    template = debug.template,
                    args = { GetFullName(ply), source },
                })
                break
            end
        end
    end

    for i = 1, #actions do
        local debug = actions[i]
        lib.callback.register(debug.event, function()
            actionDebug(debug.event)
        end)
    end
end

--#endregion Debug

--#region Startup

if GetCurrentResourceName() ~= "bgarage" then
    error("Please don\'t rename this resource, change the folder name (back) to \'bgarage\'.")
    return
end

lib.versionCheck("bebomusa/bgarage")

--#endregion Startup
