--#region Variables

local tempVehicle
local hasStarted = false
local impoundBlip = 0

local EntityCreation = require "classes.entityCreation"
local ImpoundInteraction = require "classes.impoundInteraction"
local client = require "config.client"
local shared = require "config.shared"
local framework = require(("modules.bridge.%s.client"):format(shared.framework))
local utils = require "modules.utils.client"

--#endregion Variables

--#region Functions

---@param model? string | number
---@param type? string
---@return string | nil
local function getVehicleIcon(model, type)
    if not model and not type then return end

    local icon = type or client.vehicleClasses[GetVehicleClassFromName(model --[[@as string | number]])]
    icon = client.convertIcons[icon] or icon

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

    local netVehicle = lib.callback.await("bGarage:server:spawnVehicle", false, data.model, type(coords) == "vector4" and coords, plate)
    if not netVehicle then
        TriggerServerEvent("bGarage:server:vehicleSpawnFailed", plate)
        tempVehicle = nil
        return false, locale("not_registered")
    end

    local attempts = 0
    while netVehicle == 0 or not NetworkDoesEntityExistWithNetworkId(netVehicle) do
        Wait(10)
        attempts += 1
        if attempts == 100 then
            break
        end
    end

    local vehicle = netVehicle == 0 and 0 or not NetworkDoesEntityExistWithNetworkId(netVehicle) and 0 or NetToVeh(netVehicle)
    if not vehicle or vehicle == 0 then
        TriggerServerEvent("bGarage:server:vehicleSpawnFailed", plate, netVehicle)
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

---@todo improve handling of vehicle properties - currently works fine but can be done better
---@param bagName string
---@param key string
---@param value any
AddStateBagChangeHandler("vehicleProperties", "vehicle", function(bagName, key, value)
    if not value then return end

    local netId = tonumber(bagName:gsub("entity:", ""), 10)
    local entity, timeout = false, 0

    while not entity and timeout < 1000 do
        entity = NetworkDoesEntityExistWithNetworkId(netId)
        timeout += 1
        Wait(0)
    end

    if not entity then
        return lib.print.warn(("Statebag '(%s)' timed out after waiting '%s' ticks for entity creation on '%s'."):format(bagName, timeout, key))
    end

    Wait(500)

    local vehicle = NetworkDoesEntityExistWithNetworkId(netId) and NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or NetworkGetEntityOwner(vehicle) ~= cache.playerId or not SetVehicleProperties(vehicle, value) then return end

    Entity(vehicle).state:set(key, nil, true)
end)

lib.callback.register("bGarage:client:purchaseParkingSpace", function(price)
    local canPay, reason = lib.callback.await("bGarage:server:payFee", price, shared.garage.parking.price, false)
    if not canPay then
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, "error", shared.notifications.icons[1])
        return
    end

    local entity = cache.vehicle or cache.ped
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)

    local location, status = lib.callback.await("bGarage:server:setParkingSpot", false, vec4(coords.x, coords.y, coords.z, heading))
    framework.Notify(status, shared.notifications.duration, shared.notifications.position, "success", shared.notifications.icons[1])

    if not location then return end

    lib.callback.await("bGarage:server:payFee", price, shared.garage.parking.price, true)
end)

lib.callback.register("bGarage:client:storeVehicle", function()
    local vehicle = cache.vehicle
    if not vehicle or vehicle == 0 then
        framework.Notify(locale("not_in_vehicle"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[0])
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    ---@type Vehicle?
    local owner = lib.callback.await("bGarage:server:getVehicleOwner", false, plate)
    if not owner then
        framework.Notify(locale("not_owner"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[0])
        return
    end

    ---@type vector4?
    local location = lib.callback.await("bGarage:server:getParkingSpot", false)
    if not location then
        framework.Notify(locale("no_parking_spot"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
        return
    end

    if #(location.xyz - GetEntityCoords(vehicle)) > 5.0 then
        SetNewWaypoint(location.x, location.y)
        framework.Notify(locale("not_in_parking_spot"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
        return
    end

    local props = GetVehicleProperties(vehicle)
    ---@type boolean, string
    local status, reason = lib.callback.await("bGarage:server:setVehicleStatus", false, "parked", plate, props)
    if status then
        SetEntityAsMissionEntity(vehicle, false, false)
        lib.callback.await("bGarage:server:deleteVehicle", false, VehToNet(vehicle))
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, "success", shared.notifications.icons[0])
    end

    if not status then
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, "error", shared.notifications.icons[0])
        return
    end
end)

RegisterNetEvent("bGarage:client:openVehicleList", function(data)
    ---@type table<string, Vehicle>
    local vehicles, amount = lib.callback.await("bGarage:server:getOwnedVehicles", false)
    if amount == 0 then
        framework.Notify(locale("no_vehicles"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
        return
    end

    ---@type vector4?
    local location = lib.callback.await("bGarage:server:getParkingSpot", false)

    local options = {
        {
            title = locale("vehicle_amount"):format(amount),
            disabled = true,
        },
    }

    for k, v in pairs(vehicles) do
        local vehicleListOptions = {}

        if v.location == "parked" then
            vehicleListOptions[#vehicleListOptions + 1] = {
                title = locale("menu_subtitle_one"),
                description = locale("menu_description_one"),
                onSelect = function(price)
                    local canPay, reason = lib.callback.await("bGarage:server:payFee", price, shared.garage.retrieve.price, false)
                    if not canPay then
                        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, "error", shared.notifications.icons[0])
                        return
                    end

                    if not location then
                        framework.Notify(locale("no_parking_spot"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
                        return
                    end

                    local success, status = spawnVehicle(k, v, location)
                    framework.Notify(status, shared.notifications.duration, shared.notifications.position, "success", shared.notifications.icons[0])

                    if not success then return end

                    lib.callback.await("bGarage:server:payFee", price, shared.garage.retrieve.price, true)
                end,
            }
        end

        if v.location == "parked" or v.location == "outside" and not cache.vehicle then
            vehicleListOptions[#vehicleListOptions + 1] = {
                title = locale("menu_subtitle_two"),
                description = locale("menu_description_two"),
                onSelect = function()
                    local coords = v.location == "parked" and location?.xy or v.location == "outside" and lib.callback.await("bGarage:server:getVehicleCoords", false, k)?.xy or nil
                    if not coords then
                        framework.Notify(v.location == "outside" and locale("vehicle_doesnt_exist") or locale("no_parking_spot"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[0] or shared.notifications.icons[1])
                        return
                    end

                    if coords then
                        SetNewWaypoint(coords.x, coords.y)
                        framework.Notify(locale("set_waypoint"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
                        return
                    end
                end,
            }
        end

        local make, name = GetMakeNameFromVehicleModel(v.model):firstToUpper(), GetDisplayNameFromVehicleModel(v.model):firstToUpper()
        local icon = v.location == "impound" and "🔴" or v.location == "parked" and "🟢" or "🟡"
        options[#options + 1] = {
            menu = table.type(vehicleListOptions) ~= "empty" and v.location ~= "impound" and ("vehicleList_%s"):format(k) or nil,
            title = ("%s %s - %s"):format(make, name, k),
            icon = getVehicleIcon(v.model, v.type),
            metadata = {
                Location = ("%s %s"):format(icon, v.location:firstToUpper()),
                ---@todo include vehicle owner, engine health, and fuel.
            },
        }

        if table.type(vehicleListOptions) ~= "empty" then
            lib.registerContext({
                id = ("vehicleList_%s"):format(k),
                menu = "vehicleList_menu",
                title = ("%s %s - %s"):format(make, name, k),
                options = vehicleListOptions,
            })
        end
    end

    lib.registerContext({
        id = "vehicleList_menu",
        title = locale("vehicle_menu_title"),
        options = options,
    })

    framework.hideTextUI()
    framework.showContext("vehicleList_menu")
end)

RegisterNetEvent("bGarage:client:openImpoundList", function(data)
    ---@type table<string, Vehicle>, number
    local vehicles, amount = lib.callback.await("bGarage:server:getImpoundedVehicles", false)
    if amount == 0 then
        framework.Notify(locale("no_impounded_vehicles"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
        return
    end

    local options = {
        {
            title = locale("vehicle_amount"):format(amount),
            disabled = true,
        },
    }

    for k, v in pairs(vehicles) do
        local make, name = GetMakeNameFromVehicleModel(v.model):firstToUpper(), GetDisplayNameFromVehicleModel(v.model):firstToUpper()
        local icon = v.location == "impound" and "🔴" or v.location == "parked" and "🟢" or "🟡"
        options[#options + 1] = {
            menu = ("vehicleImpound_%s"):format(k),
            title = ("%s %s - %s"):format(make, name, k),
            icon = getVehicleIcon(v.model, v.type),
            metadata = { Location = ("%s %s"):format(icon, v.location:firstToUpper()) },
        }

        lib.registerContext({
            id = ("vehicleImpound_%s"):format(k),
            menu = "vehicleImpound_menu",
            title = ("%s %s - %s"):format(make, name, k),
            options = {
                {
                    title = locale("menu_subtitle_one"),
                    description = locale("impound_description"),
                    onSelect = function(price)
                        if client.impound.static then
                            local canPay, reason = lib.callback.await("bGarage:server:payFee", price, client.impound.price, false)
                            if not canPay then
                                framework.Notify(reason, shared.notifications.duration, shared.notifications.position, "error", shared.notifications.icons[1])
                                return
                            end

                            local success, status = spawnVehicle(k, v, client.impound.location)
                            framework.Notify(status, shared.notifications.duration, shared.notifications.position, "success", shared.notifications.icons[1])

                            if not success then return end

                            lib.callback.await("bGarage:server:payFee", price, client.impound.price, true)
                        else
                            local canPay, reason = lib.callback.await("bGarage:server:payFee", price, client.impound.price, false)
                            if not canPay then
                                framework.Notify(reason, shared.notifications.duration, shared.notifications.position, "error", shared.notifications.icons[1])
                                return
                            end

                            ---@type vector4?
                            local location = lib.callback.await("bGarage:server:getParkingSpot", false)
                            if not location then
                                framework.Notify(locale("no_parking_spot"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
                                return
                            end

                            local success, status = spawnVehicle(k, v, location)
                            framework.Notify(status, shared.notifications.duration, shared.notifications.position, "success", shared.notifications.icons[1])

                            if not success then return end

                            lib.callback.await("bGarage:server:payFee", price, client.impound.price, true)
                        end
                    end,
                },
            },
        })
    end

    lib.registerContext({
        id = "vehicleImpound_menu",
        title = locale("impounded_menu_title"),
        options = options,
    })

    framework.hideTextUI()
    framework.showContext("vehicleImpound_menu")
end)

if client.impound.static then
    EntityCreation:generateStaticEntity()
    ImpoundInteraction:generateInteraction()
end

--#endregion Functions

--#region Callbacks / Events

lib.callback.register("bGarage:client:getTempVehicle", function()
    return tempVehicle
end)

RegisterNetEvent("bGarage:client:startedCheck", function()
    if GetInvokingResource() then return end
    hasStarted = true
end)

--#endregion Callbacks / Events

--#region Commands

RegisterCommand(client.impound.command, function()
    if not hasStarted then return end

    local job = framework.hasJob()
    if not job then
        framework.Notify(locale("no_access"), shared.notifications.duration, shared.notifications.position, "error", shared.notifications.icons[1])
        return
    end

    local vehicle = GetVehiclePedIsIn(cache.ped, false) --[[@as number?]]
    if not vehicle or vehicle == 0 then
        vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, true)
        if not vehicle or vehicle == 0 then
            framework.Notify(locale("no_nearby_vehicles"), shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[1])
            return
        end
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local data = lib.callback.await("bGarage:server:getVehicle", false, plate) --[[@as Vehicle?]]
    if data then
        ---@type boolean, string
        local _, reason = lib.callback.await("bGarage:server:setVehicleStatus", false, "impound", plate, data.props, data.owner)
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, "inform", shared.notifications.icons[3])
    end

    SetEntityAsMissionEntity(vehicle, false, false)
    lib.callback.await("bGarage:server:deleteVehicle", false, VehToNet(vehicle))
end, false)

if GetResourceState("ox_target"):find("start") then
    exports.ox_target:addGlobalVehicle({
        {
            label = locale("impound_vehicle"),
            name = "impound_vehicle",
            icon = "fa-solid fa-car-burst",
            distance = 2.5,
            groups = client.jobs,
            command = client.impound.command,
        },
    })
end

--#endregion Commands

--#region Threads

CreateThread(function()
    Wait(1000)
    if hasStarted then return end
    hasStarted = lib.callback.await("bGarage:server:hasStarted", false)
end)

if client.impound.static then
    CreateThread(function()
        local settings = { id = client.impound.blip.sprite, colour = client.impound.blip.color, scale = client.impound.blip.scale }
        impoundBlip = utils.createBlip(settings, client.impound.location)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(locale("impound_blip"))
        EndTextCommandSetBlipName(impoundBlip)
    end)
end

--#endregion Threads

SetDefaultVehicleNumberPlateTextPattern(-1, shared.miscellaneous.plateTextPattern:upper())
