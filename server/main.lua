--#region Variables

local server = require 'config.server'
local shared = require 'config.shared'

local framework = require(('server.framework.%s'):format(shared.framework))
local db = require 'server.db'

---@type table <string, Vehicle>
local vehicles = {}

---@type table <string | number, vector4>
local parkingSpots = {}
local hasStarted = false

--#endregion Variables

--#region Functions

---Add a vehicle
---@param owner number The identifier of the owner of the car
---@param plate string The plate number of the car
---@param model string | number The hash of the model
---@param props? table The vehicle properties
---@param _type? string Type of the vehicle
---@param location? 'outside' | 'parked' | 'impound' The location that the vehicle is at
---@param fuel? number The vehicle fuel level
---@param body? number The vehicle body health
---@param engine? number The vehicle engine health
---@param temporary? boolean If true, will not add the vehicle to the database
---@return boolean
local function addVehicle(owner, plate, model, props, _type, location, fuel, body, engine, temporary)
    plate = plate and plate:upper() or plate
    if not owner or not plate or not model then return false end

    if vehicles[plate] then return true end

    model = type(model) == 'string' and joaat(model) or model
    props = props or {}
    location = location or 'outside'

    vehicles[plate] = {
        owner = owner,
        model = model,
        props = props,
        type = _type,
        location = location,
        fuel = fuel or 100,
        body = body or 1000,
        engine = engine or 1000,
        temporary = temporary,
    }

    return true
end

exports('addVehicle', addVehicle)

---Remove a vehicle
---@param plate string The plate number of the car
---@return boolean
local function removeVehicle(plate)
    plate = plate and plate:upper() or plate
    if not plate or not vehicles[plate] then return false end

    vehicles[plate] = nil

    return true
end

exports('removeVehicle', removeVehicle)

---Get a vehicle by its plate
---@param plate string The plate number of the car
---@return Vehicle?
local function getVehicle(plate)
    plate = plate and plate:upper() or plate
    return vehicles[plate]
end

exports('getVehicle', getVehicle)

---Get a vehicle by its plate and check if they're owner
---@param source integer
---@param plate string The plate number of the car
---@return Vehicle?
local function getVehicleOwner(source, plate)
    local vehicle = getVehicle(plate)
    local owner = vehicle?.owner == framework.getIdentifier(framework.getPlayerId(source))
    return owner and vehicle or nil
end

exports('getVehicleOwner', getVehicleOwner)

---Get all vehicles from an owner, with an optional location filter
---@param owner number The identifier of the owner of the car
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

exports('getVehicles', getVehicles)

---Set the status of a vehicle and perform actions based on it, doesn't work with the 'outside' status
---@param owner number The identifier of the owner of the car
---@param plate string The plate number of the car
---@param status 'parked' | 'impound' The location that the vehicle is at, so the status
---@param props? table The vehicle properties
---@param fuel? number The vehicle fuel level
---@param body? number The vehicle body health
---@param engine? number The vehicle engine health
---@return boolean
---@return string
local function setVehicleStatus(owner, plate, status, props, fuel, body, engine)
    plate = plate and plate:upper() or plate

    if not owner or not vehicles[plate] or not plate then
        return false, locale('failed_to_set_status')
    end

    local ply = framework.getPlayerIdentifier(owner)
    if not ply or vehicles[plate].owner ~= owner then
        return false, locale('not_owner')
    end

    if status == 'parked' and shared.garage.storage.price ~= -1 then
        if framework.getMoney(ply.source) < shared.garage.storage.price then
            return false, locale('invalid_funds')
        end
        framework.removeMoney(ply.source, shared.garage.storage.price)
    end

    vehicles[plate].location = status
    vehicles[plate].props = props or {}
    vehicles[plate].fuel = fuel or 100
    vehicles[plate].body = body or 1000
    vehicles[plate].engine = engine or 1000

    return true, status == 'parked' and locale('successfully_parked') or status == 'impound' and locale('successfully_impounded') or ''
end

exports('setVehicleStatus', setVehicleStatus)

---Generates and returns a random number plate with the given pattern
---@param pattern? string
---@return string
local function getRandomPlate(pattern)
    pattern = pattern or '........'
    return lib.string.random(pattern):upper()
end

exports('getRandomPlate', getRandomPlate)

---Save all vehicles and parking locations to the database
---@param resource string?
local function saveData(resource)
    if resource == 'fivem-parking' then
        resource = nil
    end

    db.saveVehicle(vehicles)
    db.saveParkingSpot(parkingSpots)
end

exports('saveData', saveData)

--#endregion Functions

--#region Callbacks

---@param plate string
lib.callback.register('fivem-parking:server:getVehicle', function(_, plate)
    return getVehicle(plate)
end)

---@param source integer
---@param plate string
lib.callback.register('fivem-parking:server:getVehicleOwner', function(source, plate)
    return getVehicleOwner(source, plate)
end)

---@param source integer
lib.callback.register('fivem-parking:server:getOwnedVehicles', function(source)
    return getVehicles(framework.getIdentifier(framework.getPlayerId(source)))
end)

---@param source integer
lib.callback.register('fivem-parking:server:getParkedVehicles', function(source)
    return getVehicles(framework.getIdentifier(framework.getPlayerId(source)), 'parked')
end)

---@param source integer
lib.callback.register('fivem-parking:server:getImpoundedVehicles', function(source)
    return getVehicles(framework.getIdentifier(framework.getPlayerId(source)), 'impound')
end)

---@param source integer
lib.callback.register('fivem-parking:server:getOutsideVehicles', function(source)
    return getVehicles(framework.getIdentifier(framework.getPlayerId(source)), 'outside')
end)

---@param plate string
lib.callback.register('fivem-parking:server:getVehicleCoords', function(_, plate)
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
---@param fuel? number
---@param body? number
---@param engine? number
---@param owner? number
lib.callback.register('fivem-parking:server:setVehicleStatus', function(source, status, plate, props, fuel, body, engine, owner)
    if not owner then
        local src = source
        local ply = framework.getPlayerId(src)
        if not ply then
            return false, locale('failed_to_set_status')
        end
        owner = framework.getIdentifier(ply)
    end

    return setVehicleStatus(owner, plate, status, props, fuel, body, engine)
end)

---@param model number
---@param coords vector4
---@param plate string
lib.callback.register('fivem-parking:server:spawnVehicle', function(_, model, coords, plate)
    plate = plate and plate:upper() or plate
    if not plate or not vehicles[plate] or not model or not coords then return end

    vehicles[plate].location = 'outside'

    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)
    while not DoesEntityExist(tempVehicle) do
        Wait(0)
    end

    local entityType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)

    local vehicle = CreateVehicleServerSetter(model, entityType, coords.x, coords.y, coords.z, coords.w)
    while not DoesEntityExist(vehicle) do
        Wait(0)
    end

    SetVehicleNumberPlateText(vehicle, plate)
    if server.logging.enabled then
        lib.logger(source, 'admin', ("**'%s'** initiated the creation of vehicle model **'%s'** with license plate **'%s'** at location **'%s'**."):format(GetPlayerIdentifierByType(source, server.logging.identifier), vehicle, plate, coords))
    end

    return NetworkGetNetworkIdFromEntity(vehicle)
end)

---@param source integer
---@param price number
---@param remove? boolean
---@return boolean
lib.callback.register('fivem-parking:server:payFee', function(source, price, remove)
    local src = source
    if not src then return false end

    if price == -1 then return true end

    local plyMoney = framework.getMoney(src)
    if plyMoney < price then
        return false, locale('invalid_funds')
    end

    if remove then
        framework.removeMoney(src, price)
    end

    return true
end)

---@param netId integer
---@return boolean
lib.callback.register('fivem-parking:server:deleteVehicle', function(_, netId)
    if not netId or netId == 0 then return false end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then return false end

    DeleteEntity(vehicle)

    return true
end)

---@param source integer
---@param coords vector4
---@return boolean
lib.callback.register('fivem-parking:server:setParkingSpot', function(source, coords)
    local src = source
    local ply = framework.getPlayerId(src)
    if not coords or not ply then
        return false, locale('failed_to_save_parking')
    end

    parkingSpots[framework.getIdentifier(ply)] = coords
    if server.logging.enabled then
        lib.logger(src, 'admin', ("**'%s'** bought a parking space at **'%s'**."):format(GetPlayerIdentifierByType(source --[[@as string]], server.logging.identifier), coords))
    end

    return true, locale('successfully_saved_parking')
end)

---@param source integer
lib.callback.register('fivem-parking:server:getParkingSpot', function(source)
    local src = source
    local ply = framework.getPlayerId(src)
    if not ply or not parkingSpots then return end

    local location = parkingSpots[framework.getIdentifier(ply)]
    return location
end)

lib.callback.register('fivem-parking:server:hasStarted', function()
    return hasStarted
end)

--#endregion Callbacks

--#region Events

---@param plate string
---@param netId integer
RegisterNetEvent('fivem-parking:server:vehicleSpawnFailed', function(plate, netId)
    plate = plate and plate:upper() or plate

    if not plate or not vehicles[plate] then return end

    local ply = framework.getPlayerId(source)
    if not ply or vehicles[plate].owner ~= framework.getIdentifier(ply) then return end

    vehicles[plate].location = 'impound'

    if not netId then return end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then return end

    DeleteEntity(veh)
end)

---@param entity number
AddEventHandler('entityRemoved', function(entity)
    local entityType = GetEntityType(entity)
    if entityType ~= 2 then return end

    local plate = GetVehicleNumberPlateText(entity)

    local data = vehicles[plate]
    if not data or data.location ~= 'outside' then return end

    data.location = 'impound'
end)

AddEventHandler('onResourceStop', function() saveData() end)
AddEventHandler('txAdmin:events:serverShuttingDown', function() saveData() end)

--#endregion Events

--#region Commands

lib.addCommand('v', {
    help = "Access your vehicle's parking garage.",
    params = {
        { name = 'option', type = 'string', help = 'Available commands are: buy, list, park.' },
    },
    restricted = false,
}, function(source, args)
    if not hasStarted then return end

    local src = source
    local ply = framework.getPlayerId(src)
    if not ply then return end

    local action = args.option
    if action == 'buy' then
        TriggerClientEvent('fivem-parking:client:purchaseParkingSpace', src, nil)
    elseif action == 'list' then
        TriggerClientEvent('fivem-parking:client:openVehicleList', src, nil)
    elseif action == 'park' then
        TriggerClientEvent('fivem-parking:client:storeVehicle', src, nil)
    elseif action == 'impound' then
        if not shared.impound.static then
            TriggerClientEvent('fivem-parking:client:openImpoundList', src, nil)
        else
            framework.Notify(src, 'This command is not available.', shared.notifications.duration, shared.notifications.position, 'inform', 'circle-info', '#3b82f6')
        end
    elseif action == 'stats' then
        local date = os.date('%m/%d/%Y')
        local time = os.date('%H:%M:%S')
        TriggerClientEvent('fivem-parking:client:checkVehicleStats', src, date, time)
    else
        framework.Notify(src, 'Invalid action. Available actions: buy, list, park, impound, and stats.', shared.notifications.duration, shared.notifications.position, 'inform', 'circle-info', '#3b82f6')
    end
end)

lib.addCommand(server.aliases.buy, {
    help = nil,
    params = {},
    restricted = false,
}, function(source)
    if not hasStarted then return end

    local src = source
    local ply = framework.getPlayerId(src)
    if not ply then return end

    TriggerClientEvent('fivem-parking:client:purchaseParkingSpace', src, nil)
end)

lib.addCommand(server.aliases.list, {
    help = nil,
    params = {},
    restricted = false,
}, function(source)
    if not hasStarted then return end

    local src = source
    local ply = framework.getPlayerId(src)
    if not ply then return end

    TriggerClientEvent('fivem-parking:client:openVehicleList', src, nil)
end)

lib.addCommand(server.aliases.park, {
    help = nil,
    params = {},
    restricted = false,
}, function(source)
    if not hasStarted then return end

    local src = source
    local ply = framework.getPlayerId(src)
    if not ply then return end

    TriggerClientEvent('fivem-parking:client:storeVehicle', src, nil)
end)

if not shared.impound.static then
    lib.addCommand(server.aliases.impound, {
        help = nil,
        params = {},
        restricted = false,
    }, function(source)
        if not hasStarted then return end

        local src = source
        local ply = framework.getPlayerId(src)
        if not ply then return end

        TriggerClientEvent('fivem-parking:client:openImpoundList', src, nil)
    end)
end

lib.addCommand(server.aliases.stats, {
    help = nil,
    params = {},
    restricted = false,
}, function(source)
    if not hasStarted then return end

    local src = source
    local ply = framework.getPlayerId(src)
    if not ply then return end

    local date = os.date('%m/%d/%Y')
    local time = os.date('%H:%M:%S')
    TriggerClientEvent('fivem-parking:client:checkVehicleStats', src, date, time)
end)

lib.addCommand(shared.impound.command, {
    help = locale('commands.impound'),
    params = {},
    restricted = false,
}, function(source)
    if not hasStarted then return end

    local src = source
    local ply = framework.getPlayerId(src)
    if not ply then return end

    TriggerClientEvent('fivem-parking:client:impoundVehicle', src, nil)
end)

lib.addCommand('admincar', {
    help = locale('commands.admincar'),
    params = {},
    restricted = shared.adminGroup,
}, function(source)
    if not hasStarted then return end

    local src = source
    local ply = framework.getPlayerId(src)
    local ped = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not DoesEntityExist(vehicle) then
        framework.Notify(src, locale('not_in_vehicle'), shared.notifications.duration, shared.notifications.position, 'inform', 'circle-info', '#3b82f6')
        return
    end

    local identifier = framework.getIdentifier(ply)
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)

    local success = addVehicle(identifier, plate, model, {}, GetVehicleType(vehicle), 'outside')
    if server.logging.enabled then
        lib.logger(src, 'admin', ("**'%s'** designated the vehicle model **'%s'** with license plate **'%s'** as owned."):format(GetPlayerIdentifierByType(src, server.logging.identifier), model, plate))
    end

    framework.Notify(src, success and locale('successfully_set') or locale('failed_to_set'), shared.notifications.duration, shared.notifications.position, success and 'inform' or 'error', 'circle-info', '#3b82f6' or '#7f1d1d')
end)

lib.addCommand('givevehicle', {
    help = locale('commands.givevehicle'),
    params = {
        { name = 'target', type = 'playerId', help = 'The id of the player receiving the vehicle' },
        { name = 'model',  type = 'string',   help = 'The model name of the vehicle (e.g., fugitive, asea, etc.)' },
    },
    restricted = shared.adminGroup,
}, function(source, args)
    if not hasStarted then return end

    local src = source
    local target = args.target
    local ply = framework.getPlayerId(target)
    local plyName = framework.getFullName(ply)
    local identifier = framework.getIdentifier(ply)
    if not ply then
        framework.Notify(src, locale('player_doesnt_exist'), shared.notifications.duration, shared.notifications.position, 'error', 'circle-info', '#7f1d1d')
        return
    end

    local model = args.model
    if not model then
        framework.Notify(src, locale('invalid_model'), shared.notifications.duration, shared.notifications.position, 'error', 'circle-info', '#7f1d1d')
        return
    end

    local plate = getRandomPlate()
    local success = addVehicle(identifier, plate, model, {}, GetVehicleType(model), 'parked')
    if success then
        framework.Notify(ply, locale('successfully_added'):format(model, plyName), shared.notifications.duration, shared.notifications.position, 'inform', 'circle-info', '#3b82f6')
        framework.Notify(src, locale('successfully_added'):format(model, plyName), shared.notifications.duration, shared.notifications.position, 'inform', 'circle-info', '#3b82f6')
        if server.logging.enabled then
            local admin = framework.getPlayerId(src)
            local adminIdentifier = GetPlayerIdentifierByType(admin, server.logging.identifier)
            lib.logger(src, 'admin', ("**'%s'** provided the vehicle model **'%s'** with the license plate **'%s'** to **'%s'**."):format(adminIdentifier, model, plate, plyName))
        end
    else
        framework.Notify(src, locale('failed_to_add'), shared.notifications.duration, shared.notifications.position, 'error', 'circle-info', '#7f1d1d')
    end
end)

lib.addCommand('deletevehicle', {
    help = locale('commands.deletevehicle'),
    params = {
        { name = 'target', type = 'playerId', help = "The id of the player you're removing the vehicle from" },
        { name = 'plate',  type = 'string',   help = 'The plate number of the vehicle' },
    },
    restricted = shared.adminGroup,
}, function(source, args)
    if not hasStarted then return end

    local src = source
    local target = args.target
    local ply = framework.getPlayerId(target)
    local plyName = framework.getFullName(ply)
    if not ply then
        framework.Notify(src, locale('player_doesnt_exist'), shared.notifications.duration, shared.notifications.position, 'error', 'circle-info', '#7f1d1d')
        return
    end

    local plate = args.plate
    local success = removeVehicle(plate)
    if success then
        framework.Notify(ply, locale('successfully_deleted'):format(plate), shared.notifications.duration, shared.notifications.position, 'success', 'square-parking', '#14532d')
        framework.Notify(src, locale('successfully_deleted'):format(plate), shared.notifications.duration, shared.notifications.position, 'success', 'square-parking', '#14532d')
        if server.logging.enabled then
            local admin = framework.getPlayerId(src)
            local adminName = framework.getFullName(admin)
            local adminIdentifier = GetPlayerIdentifierByType(admin, server.logging.identifier)
            lib.logger(src, 'admin', ("**'%s (%s)'** deleted the vehicle with the license plate **'%s'** from **'%s'**."):format(adminName, adminIdentifier, plate, plyName))
        end
    else
        framework.Notify(src, locale('failed_to_delete'):format(plate), shared.notifications.duration, shared.notifications.position, 'error', 'circle-info', '#7f1d1d')
    end
end)

if server.database.debug then
    lib.addCommand('fetchdata', {
        help = locale('commands.fetchdata'),
        params = {},
        restricted = shared.adminGroup,
    }, function(source)
        if not hasStarted then return end

        local src = source
        local ply = framework.getPlayerId(src)
        if not ply then return end

        db.fetchOwnedVehicles(vehicles)
        db.fetchParkingLocations(parkingSpots)
        SaveResourceFile('fivem-parking', 'data.json', json.encode(vehicles, { indent = true, sort_keys = true, indent_count = 2 }), -1)
        framework.Notify(src, "Data successfully generated and saved", shared.notifications.duration, shared.notifications.position, 'inform', 'circle-info', '#3b82f6')
    end)
end

--#endregion Commands

--#region Threads

lib.cron.new(('*/%s * * * *'):format(server.database.interval), saveData, { debug = server.database.debug })

CreateThread(function()
    Wait(1000)
    db.fetchOwnedVehicles(vehicles)
    db.fetchParkingLocations(parkingSpots)
    hasStarted = true
    TriggerClientEvent('fivem-parking:client:startedCheck', -1)
end)

CreateThread(function()
    while true do
        Wait(500)

        local players = GetPlayers()
        local spawnedVehicles = {}
        local cache = {}
        local pool = GetAllVehicles()

        for i = 1, #players do
            local player = players[i]
            local temporary = lib.callback.await('fivem-parking:client:getTempVehicle', player)
            if temporary then
                cache[temporary] = true
            end
        end

        for i = 1, #pool do
            if DoesEntityExist(pool[i]) then
                spawnedVehicles[GetVehicleNumberPlateText(pool[i])] = pool[i]
            end
        end

        for k, v in pairs(vehicles) do
            if v.location == 'outside' and not spawnedVehicles[k] and not cache[k] then
                vehicles[k].location = 'impound'
            end
        end
    end
end)

--#endregion Threads
