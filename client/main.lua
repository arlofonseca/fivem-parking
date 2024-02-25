--#region Variables

local tempVehicle
local hasStarted = false
local shownTextUI = false
local impoundBlip = 0
local parkingBlip
local npc

local config = require "config"
local framework = require(("modules.bridge.%s.client"):format(config.framework))
local interface = require "modules.interface.client"

--#endregion Variables

--#region Functions

local function onEnter()
    local model = type(config.impound.entity.model) == "string" and joaat(config.impound.entity.model) or config.impound.entity.model
    local type = ("male" == "male") and 4 or 5
    lib.requestModel(model)
    npc = CreatePed(type, model, config.impound.entity.location.x, config.impound.entity.location.y, config.impound.entity.location.z, config.impound.entity.location.w, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end

local function onExit()
    DeletePed(npc)
    npc = nil
end

---@type CPoint
lib.points.new({
    coords = config.impound.entity.location,
    distance = config.impound.entity.distance,
    onEnter = onEnter,
    onExit = onExit,
})

---Returns the icon of fontawesome for a vehicle type, or class if the type is not defined
---@param model? string | number
---@param type? string
---@return string | nil
local function getVehicleIcon(model, type)
    if not model and not type then return end

    local icon = type or config.vehicleClasses[GetVehicleClassFromName(model --[[@as string | number]])]
    icon = config.convertIcons[icon] or icon

    return icon
end

---@param plate string
---@param data Vehicle
---@param coords vector4
---@return boolean
---@return string
local function spawnVehicle(plate, data, coords)
    plate = plate and plate:upper() or plate

    if tempVehicle then
        if tempVehicle ~= plate then
            while tempVehicle do
                Wait(100)
            end
        else
            return false, locale("already_spawning")
        end
    end

    tempVehicle = plate
    lib.requestModel(data.model)

    local networkVehicle = lib.callback.await("bgarage:server:spawnVehicle", false, data.model, type(coords) == "vector4" and coords, plate)
    if not networkVehicle then
        TriggerServerEvent("bgarage:server:vehicleSpawnFailed", plate)
        tempVehicle = nil
        return false, locale("not_registered")
    end

    local attempts = 0
    while networkVehicle == 0 or not NetworkDoesEntityExistWithNetworkId(networkVehicle) do
        Wait(10)
        attempts += 1
        if attempts == 100 then
            break
        end
    end

    local vehicle = networkVehicle == 0 and 0 or not NetworkDoesEntityExistWithNetworkId(networkVehicle) and 0 or NetToVeh(networkVehicle)
    if not vehicle or vehicle == 0 then
        TriggerServerEvent("bgarage:server:vehicleSpawnFailed", plate, networkVehicle)
        tempVehicle = nil
        return false, locale("failed_to_spawn")
    end

    Wait(500) -- Wait for the server to completely register the vehicle

    PlaceObjectOnGroundProperly(vehicle)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    Entity(vehicle).state:set("vehicleProperties", data.props, true)
    SetVehicleProperties(vehicle, data.props) -- Ensure vehicle props are set after the vehicle spawns

    tempVehicle = nil

    return true, locale("successfully_spawned")
end

---@param price number
local function purchaseParkingSpot(price)
    local canPay, reason = lib.callback.await("bgarage:server:payFee", price, config.garage.parkingLocation, false)
    if not canPay then
        framework.Notify(reason, 5000, "top-right", "error", "circle-info", "#7f1d1d")
        return
    end

    local entity = cache.vehicle or cache.ped
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local success, successReason = lib.callback.await("bgarage:server:setParkingSpot", false, vec4(coords.x, coords.y, coords.z, heading))
    framework.Notify(successReason, 5000, "top-right", "success", "circle-info", "#14532d")

    if not success then return end

    lib.callback.await("bgarage:server:payFee", price, config.garage.parkingLocation, true)
end

exports("purchaseParkingSpot", purchaseParkingSpot)

local function storeVehicle()
    local vehicle = cache.vehicle
    if not vehicle or vehicle == 0 then
        framework.Notify(locale("not_in_vehicle"), 5000, "top-right", "inform", "car", "#3b82f6")
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    ---@type Vehicle?
    local owner = lib.callback.await("bgarage:server:getVehicleOwner", false, plate)
    if not owner then
        framework.Notify(locale("not_owner"), 5000, "top-right", "inform", "car", "#3b82f6")
        return
    end

    ---@type vector4?
    local location = lib.callback.await("bgarage:server:getParkingSpot", false)
    if not location then
        framework.Notify(locale("no_parking_spot"), 5000, "top-right", "inform", "circle-info", "#3b82f6")
        return
    end

    if #(location.xyz - GetEntityCoords(vehicle)) > 5.0 then
        SetNewWaypoint(location.x, location.y)
        framework.Notify(locale("not_in_parking_spot"), 5000, "top-right", "inform", "car", "#3b82f6")
        return
    end

    local props = GetVehicleProperties(vehicle)
    ---@type boolean, string
    local status, reason = lib.callback.await("bgarage:server:setVehicleStatus", false, "parked", plate, props)
    if status then
        SetEntityAsMissionEntity(vehicle, false, false)
        lib.callback.await("bgarage:server:deleteVehicle", false, VehToNet(vehicle))
        framework.Notify(reason, 5000, "top-right", "success", "car", "#14532d")
    end

    if not status then
        framework.Notify(reason, 5000, "top-right", "error", "car", "#7f1d1d")
        return
    end
end

exports("storeVehicle", storeVehicle)

local function vehicleList()
    ---@type table<string, Vehicle>
    local vehicles, amount = lib.callback.await("bgarage:server:getOwnedVehicles", false)
    if amount == 0 then
        framework.Notify(locale("no_vehicles"), 5000, "top-right", "inform", "car", "#3b82f6")
        return
    end

    for plate, vehicle in pairs(vehicles) do
        vehicle.plate = plate
        vehicle.modelName = GetDisplayNameFromVehicleModel(vehicle.model)
        vehicle.type = getVehicleIcon(vehicle.model)
    end

    interface.sendReactMessage("bgarage:nui:setVehicles", vehicles)
    interface.toggleNuiFrame(true, false)
end

exports("vehicleList", vehicleList)

local function vehicleImpound()
    ---@type table<string, Vehicle>, number
    local vehicles, amount = lib.callback.await("bgarage:server:getImpoundedVehicles", false)
    if amount == 0 then
        framework.Notify(locale("no_impounded_vehicles"), 5000, "top-right", "inform", "car", "#3b82f6")
        return
    end

    for plate, vehicle in pairs(vehicles) do
        vehicle.plate = plate
        vehicle.modelName = GetDisplayNameFromVehicleModel(vehicle.model)
        vehicle.type = getVehicleIcon(vehicle.model)
    end

    interface.sendReactMessage("bgarage:nui:setVehicles", vehicles)
    interface.toggleNuiFrame(true, true)

    framework.hideTextUI()
    shownTextUI = false
end

exports("vehicleImpound", vehicleImpound)

--#endregion Functions

--#region Callbacks

lib.callback.register("bgarage:client:getTempVehicle", function()
    return tempVehicle
end)

---@param _ any
---@param cb function
RegisterNuiCallback("bgarage:nui:hideFrame", function(_, cb)
    cb(1)
    if not hasStarted then return end

    interface.toggleNuiFrame(false, false)
end)

---@param options Options
---@param cb function
RegisterNuiCallback("bgarage:nui:saveSettings", function(options, cb)
    cb(1)
    if not hasStarted then return end

    SetResourceKvp("bgarage:client:cacheSettings", json.encode(options))
end)

---@param data Vehicle
---@param cb function
---@param price number
RegisterNuiCallback("bgarage:nui:retrieveFromGarage", function(data, cb, price)
    cb(1)
    if not hasStarted or not data or not data.plate then return end

    local canPay, reason = lib.callback.await("bgarage:server:payFee", price, config.garage.retrieveVehicle, false)
    if not canPay then
        cb(false)
        framework.Notify(reason, 5000, "top-right", "error", "car", "#7f1d1d")
        return
    end

    local location = lib.callback.await("bgarage:server:getParkingSpot", false)
    if not location then
        cb(false)
        framework.Notify(locale("no_parking_spot"), 5000, "top-right", "inform", "circle-info", "#3b82f6")
        return
    end

    local success, spawnReason = spawnVehicle(data.plate, data, location)
    framework.Notify(spawnReason, 5000, "top-right", "success", "car", "#14532d")

    if not success then return end

    lib.callback.await("bgarage:server:payFee", price, config.garage.retrieveVehicle, true)
end)

---@param data Vehicle
---@param cb function
---@param price number
RegisterNuiCallback("bgarage:nui:retrieveFromImpound", function(data, cb, price)
    cb(1)
    if not hasStarted or not data or not data.plate then return end

    local canPay, reason = lib.callback.await("bgarage:server:payFee", price, config.impound.price, false)
    if not canPay then
        cb(false)
        framework.Notify(reason, 5000, "top-right", "error", "circle-info", "#7f1d1d")
        return
    end

    local success, spawnReason = spawnVehicle(data.plate, data, config.impound.location)
    framework.Notify(spawnReason, 5000, "top-right", "success", "car", "#14532d")

    if not success then return end

    lib.callback.await("bgarage:server:payFee", price, config.impound.price, true)
end)

--#endregion Callbacks

--#region Events

RegisterNetEvent("bgarage:client:startedCheck", function()
    if GetInvokingResource() then return end
    hasStarted = true
end)

AddEventHandler("playerSpawned", function()
    local settings = GetResourceKvpString("bgarage:client:cacheSettings")

    interface.sendReactMessage("bgarage:nui:setImpoundPrice", config.impound and config.impound.price or 0)
    interface.sendReactMessage("bgarage:nui:setGaragePrice", config.garage and config.garage.retrieveVehicle or 0)

    if settings then
        interface.sendReactMessage("bgarage:nui:setOptions", json.decode(settings))
        lib.print.info(("Impound price: %s \n Garage price: %s \n Settings: %s"):format(config.impound and config.impound.price or "nil", config.garage and config.garage.retrieveVehicle or "nil", settings))
    end
end)

---@param resource string
AddEventHandler("onResourceStop", function(resource)
    if resource == cache.resource then return end
    RemoveBlip(impoundBlip)
    RemoveBlip(parkingBlip)
    DeletePed(npc)
end)

--#endregion Events

--#region Commands

---@param args string[]
RegisterCommand("v", function(_, args)
    if not hasStarted then return end

    local action = args[1]
    if action == "buy" then
        purchaseParkingSpot()
    elseif action == "park" then
        storeVehicle()
    elseif action == "list" then
        vehicleList()
    end
end, false)

RegisterCommand("impound", function()
    if not hasStarted then return end

    local currentJob = framework.hasJob()
    if not currentJob then
        return framework.Notify(locale("no_access"), 5000, "top-right", "error", "circle-info", "#7f1d1d")
    end

    local vehicle = GetVehiclePedIsIn(cache.ped, false) --[[@as number?]]
    if not vehicle or vehicle == 0 then
        vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, true)
        if not vehicle or vehicle == 0 then
            framework.Notify(locale("no_nearby_vehicles"), 5000, "top-right", "inform", "car", "#3b82f6")
            return
        end
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local data = lib.callback.await("bgarage:server:getVehicle", false, plate) --[[@as Vehicle?]]

    if data then
        local _, reason = lib.callback.await("bgarage:server:setVehicleStatus", false, "impound", plate, data.props, data.owner)
        framework.Notify(reason, 5000, "top-right", "inform", "circle-info", "#3b82f6")
    end

    SetEntityAsMissionEntity(vehicle, false, false)
    lib.callback.await("bgarage:server:deleteVehicle", false, VehToNet(vehicle))
end, false)

---@param args string[]
RegisterCommand("givevehicle", function(_, args)
    if not hasStarted then return end

    local modelStr = args[1]
    local target = tonumber(args[2])

    if not (modelStr and target) or modelStr == "" then
        framework.Notify(locale("invalid_format"), 5000, "top-right", "inform", "circle-info", "#3b82f6")
        return
    end

    local model = joaat(modelStr)

    if not IsModelInCdimage(model) then
        framework.Notify(locale("invalid_model"), 5000, "top-right", "error", "car", "#7f1d1d")
        return
    end

    local _, reason = lib.callback.await("bgarage:server:giveVehicle", false, target, model)
    framework.Notify(reason, 5000, "top-right", "inform", "circle-info", "#3b82f6")
end, config.useAces)

--#endregion Commands

--#region State Bag Change Handlers

AddStateBagChangeHandler("vehicleProperties", "vehicle", function(bagName, key, value)
    if not value then return end

    local networkId = tonumber(bagName:gsub("entity:", ""), 10)
    local validEntity, timeout = false, 0

    while not validEntity and timeout < 1000 do
        validEntity = NetworkDoesEntityExistWithNetworkId(networkId)
        timeout += 1
        Wait(0)
    end

    if not validEntity then
        return lib.print.warn(("^^7Statebag (^3%s^7) timed out after waiting %s ticks for entity creation on %s.^0"):format(bagName, timeout, key))
    end

    Wait(500)

    local vehicle = NetworkDoesEntityExistWithNetworkId(networkId) and NetworkGetEntityFromNetworkId(networkId)
    if not vehicle or vehicle == 0 or NetworkGetEntityOwner(vehicle) ~= cache.playerId or not SetVehicleProperties(vehicle, value) then return end

    Entity(vehicle).state:set(key, nil, true)
end)

--#endregion State Bag Change Handlers

--#region Threads

CreateThread(function()
    Wait(1000)
    if hasStarted then return end
    hasStarted = lib.callback.await("bgarage:server:hasStarted", false)
end)

CreateThread(function()
    impoundBlip = AddBlipForCoord(config.impound.location.x, config.impound.location.y, config.impound.location.z)
    SetBlipSprite(impoundBlip, config.impound.blip.sprite)
    SetBlipAsShortRange(impoundBlip, true)
    SetBlipColour(impoundBlip, config.impound.blip.color)
    SetBlipScale(impoundBlip, config.impound.blip.scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(locale("blip_impound"))
    EndTextCommandSetBlipName(impoundBlip)
end)

--#endregion Threads

--#region Exports

exports.ox_target:addGlobalVehicle({
    {
        label = locale("impound_vehicle"),
        name = "impound_vehicle",
        icon = "fa-solid fa-car-burst",
        distance = 2.5,
        groups = config.jobs,
        command = "impound",
    },
})

if config.impound.useTarget then
    exports.ox_target:addModel(config.impound.entity.model, {
        {
            label = locale("impound_label"),
            name = "impound_entity",
            icon = "fa-solid fa-car-side",
            distance = 2.5,
            onSelect = function()
                vehicleImpound()
            end
        },
    })
else
    CreateThread(function()
        local sleep = 500
        while true do
            sleep = 500
            local menuOpened = false

            if #(GetEntityCoords(cache.ped) - config.impound.marker.location.xyz) < config.impound.marker.distance then
                if not menuOpened then
                    sleep = 0
                    DrawMarker(config.impound.marker.type, config.impound.marker.location.x, config.impound.marker.location.y, config.impound.marker.location.z, 0.0, 0.0, 0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 20, 200, 20, 50, false, false, 2, true, nil, nil, false)
                    if not shownTextUI then
                        framework.showTextUI(locale("impound_show"))
                        shownTextUI = true
                    end

                    if IsControlJustPressed(0, 38) then
                        vehicleImpound()
                    end
                end
            else
                if menuOpened then
                    menuOpened = false
                    lib.hideContext(false)
                end

                if shownTextUI then
                    framework.hideTextUI()
                    shownTextUI = false
                end
            end
            Wait(sleep)
        end
    end)
end

--#endregion Exports

--#region Keybinds

lib.addKeybind({
    defaultKey = "l",
    description = "Open the vehicle list",
    name = "vehicleList",
    onPressed = vehicleList
})

--#endregion Keybinds

SetDefaultVehicleNumberPlateTextPattern(-1, config.plateTextPattern:upper())

TriggerEvent("chat:addSuggestion", "/v", nil, {
    { name = "list | buy | park", help = "List all owned vehicles, purchase a parking spot, or store your vehicle." },
})
