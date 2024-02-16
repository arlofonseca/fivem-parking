--#region Variables

local tempVehicle
local hasStarted = false
local shownTextUI = false
local impoundBlip = 0
local parkingBlip
local npc

--#endregion Variables

--#region Functions

---@type CPoint
lib.points.new({
    coords = Impound.entityLocation,
    distance = Impound.entityDistance,
    onEnter = function()
        local model = type(Impound.entity) == "string" and joaat(Impound.entity) or Impound.entity
        local type = ("male" == "male") and 4 or 5
        lib.requestModel(model)
        npc = CreatePed(type, model, Impound.entityLocation.x, Impound.entityLocation.y, Impound.entityLocation.z,
            Impound.entityLocation.w, false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
    end,
    onExit = function()
        DeletePed(npc)
        npc = nil
    end
})

---Returns the icon of fontawesome for a vehicle type, or class if the type is not defined
---@param model? string | number
---@param type? string
---@return string | nil
local function getVehicleIcon(model, type)
    if not model and not type then return end

    local icon = type or VehicleClasses[GetVehicleClassFromName(model --[[@as string | number]])]
    icon = ConvertIcons[icon] or icon

    return icon
end

---Spawn a vehicle
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

    local networkVehicle = lib.callback.await("bgarage:server:spawnVehicle", false, data.model,
        type(coords) == "vector4" and coords, plate)
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

    local vehicle = networkVehicle == 0 and 0 or not NetworkDoesEntityExistWithNetworkId(networkVehicle) and 0 or
        NetToVeh(networkVehicle)
    if not vehicle or vehicle == 0 then
        TriggerServerEvent("bgarage:server:vehicleSpawnFailed", plate, networkVehicle)
        tempVehicle = nil
        return false, locale("failed_to_spawn")
    end

    Wait(500) -- Wait for the server to completely register the vehicle

    Entity(vehicle).state:set("cacheVehicle", true, true)
    Entity(vehicle).state:set("vehicleProps", data.props, true)
    SetVehicleProperties(vehicle, data.props) -- Ensure vehicle props are set after the vehicle spawns

    tempVehicle = nil

    return true, locale("successfully_spawned")
end

---Returns a list of vehicles that are impounded
local function vehicleImpound()
    ---@type table<string, Vehicle>, number
    local vehicles, amount = lib.callback.await("bgarage:server:getImpoundedVehicles", false)
    if amount ~= 0 then
        for plate, vehicle in pairs(vehicles) do
            vehicle.plate = plate
            vehicle.modelName = GetDisplayNameFromVehicleModel(vehicle.model)
            vehicle.type = getVehicleIcon(vehicle.model)
        end

        UIMessage("bgarage:nui:setVehicles", vehicles)
        ToggleNuiFrame(true, true)

        HideTextUI()
        shownTextUI = false
    else
        Notify(locale("no_impounded_vehicles"), 5000, "center-right", "inform", "car", "#3b82f6")
    end
end

--#endregion Functions

--#region Events

---Check if the event is being invoked from another resource
RegisterNetEvent("bgarage:client:started", function()
    if GetInvokingResource() then return end
    hasStarted = true
end)

---Load NUI settings/data on player loaded
AddEventHandler("playerSpawned", function()
    local settings = GetResourceKvpString("bgarage:nui:state:settings")

    UIMessage("bgarage:nui:setImpoundPrice", Impound and Impound.price or 0)
    UIMessage("bgarage:nui:setGaragePrice", Garage and Garage.retrieve or 0)

    if settings then
        UIMessage("bgarage:nui:setOptions", json.decode(settings))
        lib.print.info(("Impound price: %s \n Garage price: %s \n Cached Data: %s"):format(
            Impound and Impound.price or "nil", Garage and Garage.retrieve or "nil", settings))
    end
end)

---Deleting the blip & ped when the resource stops
---@param resource string
AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    RemoveBlip(impoundBlip)
    RemoveBlip(parkingBlip)
    DeletePed(npc)
end)

--#endregion Events

--#region Callbacks

lib.callback.register("bgarage:client:getTempVehicle", function()
    return tempVehicle
end)

---@param cb function
RegisterNuiCallback("bgarage:nui:hideFrame", function(_, cb)
    cb(1)
    if not hasStarted then return end

    ToggleNuiFrame(false)
end)

---@param options Options
---@param cb function
RegisterNuiCallback("bgarage:nui:saveSettings", function(options, cb)
    cb(1)
    if not hasStarted then return end

    SetResourceKvp("bgarage:nui:state:settings", json.encode(options))
end)

---@param data Vehicle
---@param cb function
RegisterNuiCallback("bgarage:nui:retrieveFromGarage", function(data, cb)
    cb(1)
    if not hasStarted or not data or not data.plate then return end

    local canPay, reason = lib.callback.await("bgarage:server:payFee", false, Garage.retrieve, false)
    if not canPay then
        lib.callback.await("bgarage:server:retrieveVehicleFromList", false)
        Notify(reason, 5000, "center-right", "error", "car", "#7f1d1d")
        return
    end

    local location = lib.callback.await("bgarage:server:getParkingSpot", false)
    if not location then
        Notify(locale("no_parking_spot"), 5000, "center-right", "inform", "circle-info", "#3b82f6")
        return
    end

    local success, spawnReason = spawnVehicle(data.plate, data, location)
    Notify(spawnReason, 5000, "center-right", "success", "car", "#14532d")

    if not success then return end

    lib.callback.await("bgarage:server:payFee", false, Garage.retrieve, true)
end)

---@param data Vehicle
---@param cb function
RegisterNuiCallback("bgarage:nui:retrieveFromImpound", function(data, cb)
    cb(1)

    if not hasStarted or not data or not data.plate then return end

    local canPay, reason = lib.callback.await("bgarage:server:payFee", false, Impound.price, false)
    if not canPay then
        lib.callback.await("bgarage:server:retrieveVehicleFromImpound", false)
        Notify(reason, 5000, "center-right", "error", "circle-info", "#7f1d1d")
        return
    end

    local success, spawnReason = spawnVehicle(data.plate, data, Impound.location)
    Notify(spawnReason, 5000, "center-right", "success", "car", "#14532d")

    if not success then return end

    lib.callback.await("bgarage:server:payFee", false, Impound.price, true)
end)

---@param data any
---@param cb function
RegisterNuiCallback("bgarage:nui:getLocation", function(data, cb)
    cb(1)

    if not hasStarted or not data or not data.plate then return end

    if data.location == "impound" then
        SetNewWaypoint(Impound.location.x, Impound.location.y)
        return
    end

    local location = lib.callback.await("bgarage:server:getParkingSpot", false)
    local coords = data.location == "parked" and location?.xy or
        data.location == "outside" and lib.callback.await("bgarage:server:getVehicleCoords", false, data.plate)?.xy or
        nil

    if not coords then
        Notify(data .. location == "outside" and locale("vehicle_doesnt_exist") or locale("no_parking_spot"), 5000,
            "center-right", "inform", "car" or "circle-info", "#3b82f6")
        return
    end

    if coords then
        SetNewWaypoint(coords.x, coords.y)
        Notify(locale("set_waypoint"), 5000, "center-right", "inform", "circle-info", "#3b82f6")
        return
    end
end)

--#endregion Callbacks

--#region Commands

---@param args string[]
RegisterCommand("v", function(_, args)
    if not hasStarted then return end

    local action = args[1]
    if action == "park" then
        local vehicle = cache.vehicle
        if not vehicle or vehicle == 0 then
            Notify(locale("not_in_vehicle"), 5000, "center-right", "inform", "car", "#3b82f6")
            return
        end

        local plate = GetVehicleNumberPlateText(vehicle)
        ---@type Vehicle?
        local owner = lib.callback.await("bgarage:server:getVehicleOwner", false, plate)
        if not owner then
            lib.callback.await("bgarage:server:vehicleNotOwned", false)
            Notify(locale("not_owner"), 5000, "center-right", "inform", "car", "#3b82f6")
            return
        end

        ---@type vector4?
        local location = lib.callback.await("bgarage:server:getParkingSpot", false)
        if not location then
            Notify(locale("no_parking_spot"), 5000, "center-right", "inform", "circle-info", "#3b82f6")
            return
        end

        if #(location.xyz - GetEntityCoords(vehicle)) > 5.0 then
            SetNewWaypoint(location.x, location.y)
            Notify(locale("not_in_parking_spot"), 5000, "center-right", "inform", "car", "#3b82f6")
            return
        end

        local props = GetVehicleProperties(vehicle)
        ---@type boolean, string
        local status, reason = lib.callback.await("bgarage:server:setVehicleStatus", false, "parked", plate, props)
        if status then
            SetEntityAsMissionEntity(vehicle, false, false)
            lib.callback.await("bgarage:server:deleteVehicle", false, VehToNet(vehicle))
            Notify(reason, 5000, "center-right", "success", "car", "#14532d")
        end

        if not status then
            lib.callback.await("bgarage:server:storeVehicleInParkingSpace", false)
            Notify(reason, 5000, "center-right", "error", "car", "#7f1d1d")
            return
        end
    elseif action == "buy" then
        local canPay, reason = lib.callback.await("bgarage:server:payFee", false, Garage.location, false)
        if not canPay then
            lib.callback.await("bgarage:server:purchaseParkingSpace", false)
            Notify(reason, 5000, "center-right", "error", "circle-info", "#7f1d1d")
            return
        end

        local entity = cache.vehicle or cache.ped
        local coords = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        local success, successReason = lib.callback.await("bgarage:server:setParkingSpot", false,
            vec4(coords.x, coords.y, coords.z, heading))
        Notify(successReason, 5000, "center-right", "success", "circle-info", "#14532d")

        if not success then return end

        lib.callback.await("bgarage:server:payFee", false, Garage.location, true)
    elseif action == "list" then
        ---@type table<string, Vehicle>
        local vehicles, amount = lib.callback.await("bgarage:server:getVehicles", false)
        if amount == 0 then
            Notify(locale("no_vehicles"), 5000, "center-right", "inform", "car", "#3b82f6")
            return
        end

        for plate, vehicle in pairs(vehicles) do
            vehicle.plate = plate
            vehicle.modelName = GetDisplayNameFromVehicleModel(vehicle.model)
            vehicle.type = getVehicleIcon(vehicle.model)
        end

        UIMessage("bgarage:nui:setVehicles", vehicles)
        ToggleNuiFrame(true, false)

        HideTextUI()
    end
end, false)

RegisterCommand("impound", function()
    if not hasStarted then return end

    local currentJob = HasJob()
    if not currentJob then
        return Notify(locale("no_access"), 5000, "center-right", "error", "circle-info", "#7f1d1d")
    end

    local vehicle = GetVehiclePedIsIn(cache.ped, false) --[[@as number?]]
    if not vehicle or vehicle == 0 then
        vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, true)
        if not vehicle or vehicle == 0 then
            Notify(locale("no_nearby_vehicles"), 5000, "center-right", "inform", "car", "#3b82f6")
            return
        end
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local data = lib.callback.await("bgarage:server:getVehicle", false, plate) --[[@as Vehicle?]]

    if data then
        local _, reason = lib.callback.await("bgarage:server:setVehicleStatus", false, "impound", plate, data.props,
            data.owner)
        Notify(reason, 5000, "center-right", "inform", "circle-info", "#3b82f6")
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
        Notify(locale("invalid_format"), 5000, "center-right", "inform", "circle-info", "#3b82f6")
        return
    end

    local model = joaat(modelStr)

    if not IsModelInCdimage(model) then
        Notify(locale("invalid_model"), 5000, "center-right", "error", "car", "#7f1d1d")
        return
    end

    local _, reason = lib.callback.await("bgarage:server:giveVehicle", false, target, model)
    Notify(reason, 5000, "center-right", "inform", "circle-info", "#3b82f6")
end, Misc.useAces)

---@TODO: remove this command and implement a map page on the nui - maybe add a button or two that will trigger a waypoint to your parking spot/vehicle?
---Check to locate the current position of your parking spot
RegisterCommand("findspot", function()
    if not hasStarted then return end

    if parkingBlip then
        RemoveBlip(parkingBlip)
        parkingBlip = nil
    end

    local location = lib.callback.await("bgarage:server:getParkingSpot", false)
    if location then
        parkingBlip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(parkingBlip, Garage.sprite)
        SetBlipAsShortRange(parkingBlip, true)
        SetBlipColour(parkingBlip, Garage.spriteColor)
        SetBlipScale(parkingBlip, Garage.spriteScale)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(locale("blip_parking"))
        EndTextCommandSetBlipName(parkingBlip)
        Notify(locale("set_location"), 5000, "center-right", "inform", "circle-info", "#3b82f6")
    end
end, false)

--#endregion Commands

--#region Threads

---Fallback to check if hasStarted if the event is not triggered
CreateThread(function()
    Wait(1000)
    if hasStarted then return end
    hasStarted = lib.callback.await("bgarage:server:hasStarted", false)
end)

---Creates a blip where the static impound is located
CreateThread(function()
    impoundBlip = AddBlipForCoord(Impound.location.x, Impound.location.y, Impound.location.z)
    SetBlipSprite(impoundBlip, Impound.sprite)
    SetBlipAsShortRange(impoundBlip, true)
    SetBlipColour(impoundBlip, Impound.spriteColor)
    SetBlipScale(impoundBlip, Impound.spriteScale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(locale("blip_impound"))
    EndTextCommandSetBlipName(impoundBlip)
end)

--#endregion Threads

--#region Exports

exports.ox_target:addGlobalVehicle({
    {
        name = "impound_vehicle",
        icon = "fa-solid fa-car-burst",
        label = locale("impound_vehicle"),
        command = "impound",
        distance = 2.5,
    },
})

if Impound.textui then
    CreateThread(function()
        local sleep = 500
        while true do
            sleep = 500
            local menuOpened = false

            if #(GetEntityCoords(cache.ped) - Impound.markerLocation.xyz) < Impound.markerDistance then
                if not menuOpened then
                    sleep = 0
                    DrawMarker(Impound.marker, Impound.markerLocation.x, Impound.markerLocation.y,
                        Impound.markerLocation.z, 0.0, 0.0, 0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 20, 200, 20, 50, false,
                        false, 2, true, nil, nil, false)
                    if not shownTextUI then
                        ShowTextUI(locale("impound_show"))
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
                    HideTextUI()
                    shownTextUI = false
                end
            end
            Wait(sleep)
        end
    end)
else
    exports.ox_target:addModel(Impound.entity, {
        {
            name = "impound_entity",
            icon = "fa-solid fa-car-side",
            label = locale("impound_label"),
            distance = 2.5,
            onSelect = function()
                vehicleImpound()
            end
        },
    })
end

--#endregion Exports

SetDefaultVehicleNumberPlateTextPattern(-1, Misc.plateTextPattern:upper())

TriggerEvent("chat:addSuggestion", "/v", "Vehicle Parking", {
    { name = "list | buy | park", help = "List all owned vehicles, purchase a parking spot, store your vehicle." },
})
