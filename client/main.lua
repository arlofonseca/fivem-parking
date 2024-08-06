--#region Variables

local client = require 'config.client'
local shared = require 'config.shared'

local framework = require(('client.framework.%s'):format(shared.framework))
local capitalizeFirst = require 'client.utils.capitalizeFirst'
local createBlip = require 'client.utils.createBlip'
local getModLevel = require 'client.utils.getModLevel'
local getState = require 'client.utils.getState'
local registerEvent = require 'client.utils.registerEvent'

local useTarget = GetResourceState('ox_target'):find('start') and shared.impound.useTarget
local tempVehicle
local hasStarted = false
local impoundBlip = 0
local point = nil
local npc = 0

--#endregion Variables

--#region Functions

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
            return false, locale('already_spawning')
        end
    end

    tempVehicle = plate
    lib.requestModel(data.model)

    local netVehicle = lib.callback.await('fivem_parking:server:spawnVehicle', false, data.model, type(coords) == 'vector4' and coords, plate)
    if not netVehicle then
        TriggerServerEvent('fivem_parking:server:vehicleSpawnFailed', plate)
        tempVehicle = nil
        return false, locale('not_registered')
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
    local state = getState(vehicle)
    if not vehicle or vehicle == 0 then
        TriggerServerEvent('fivem_parking:server:vehicleSpawnFailed', plate, netVehicle)
        tempVehicle = nil
        return false, locale('failed_to_spawn')
    end

    Wait(500) -- Wait for the server to completely register the vehicle

    state:set('cacheVehicle', true, true)
    state:set('vehicleProperties', data.props, true)
    SetVehicleProperties(vehicle, data.props)

    tempVehicle = nil

    return true, locale('successfully_spawned')
end

--#endregion Functions

--#region Callbacks

lib.callback.register('fivem_parking:client:getTempVehicle', function()
    return tempVehicle
end)

--#endregion Callbacks

--#region Events

registerEvent('fivem_parking:client:startedCheck', function()
    if GetInvokingResource() then return end
    hasStarted = true
end)

registerEvent('fivem_parking:client:openVehicleList', function()
    if not hasStarted then return end

    ---@type table<string, Vehicle>
    local vehicles, amount = lib.callback.await('fivem_parking:server:getOwnedVehicles', false)
    if amount == 0 then
        framework.Notify(locale('no_vehicles'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
        return
    end

    ---@type vector4?
    local location = lib.callback.await('fivem_parking:server:getParkingSpot', false)

    local options = {
        {
            title = locale('vehicle_amount'):format(amount),
            disabled = true,
        },
    }

    for k, v in pairs(vehicles) do
        local vehicleListOptions = {}

        if v.location == 'parked' then
            vehicleListOptions[#vehicleListOptions + 1] = {
                title = locale('menu_subtitle_one'),
                description = locale('menu_description_one'),
                onSelect = function(price)
                    local canPay, reason = lib.callback.await('fivem_parking:server:payFee', price, shared.garage.retrieve.price, false)
                    if not canPay then
                        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, 'error', shared.notifications.icons[0])
                        return
                    end

                    if not location then
                        framework.Notify(locale('no_parking_spot'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
                        return
                    end

                    local success, status = spawnVehicle(k, v, location)
                    framework.Notify(status, shared.notifications.duration, shared.notifications.position, 'success', shared.notifications.icons[0])

                    if not success then return end

                    lib.callback.await('fivem_parking:server:payFee', price, shared.garage.retrieve.price, true)
                end,
            }
        end

        if v.location == 'parked' or v.location == 'outside' and not cache.vehicle then
            vehicleListOptions[#vehicleListOptions + 1] = {
                title = locale('menu_subtitle_two'),
                description = locale('menu_description_two'),
                onSelect = function()
                    local coords = v.location == 'parked' and location?.xy or v.location == 'outside' and lib.callback.await('fivem_parking:server:getVehicleCoords', false, k)?.xy or nil
                    if not coords then
                        framework.Notify(v.location == 'outside' and locale('vehicle_doesnt_exist') or locale('no_parking_spot'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[0] or shared.notifications.icons[1])
                        return
                    end

                    if coords then
                        SetNewWaypoint(coords.x, coords.y)
                        framework.Notify(locale('set_waypoint'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
                        return
                    end
                end,
            }
        end

        local make, name = capitalizeFirst(GetMakeNameFromVehicleModel(v.model)), capitalizeFirst(GetDisplayNameFromVehicleModel(v.model))
        options[#options + 1] = {
            menu = table.type(vehicleListOptions) ~= 'empty' and v.location ~= 'impound' and ('vehicleList_%s'):format(k) or nil,
            title = ('%s %s (%s)'):format(make, name, k),
            description = capitalizeFirst(v.location),
            metadata = {
                Fuel = v.fuel,
            },
        }

        if table.type(vehicleListOptions) ~= 'empty' then
            lib.registerContext({
                id = ('vehicleList_%s'):format(k),
                menu = 'vehicleList_menu',
                title = ('%s %s (%s)'):format(make, name, k),
                options = vehicleListOptions,
            })
        end
    end

    lib.registerContext({
        id = 'vehicleList_menu',
        title = locale('vehicle_menu_title'),
        options = options,
    })

    framework.hideTextUI()
    framework.showContext('vehicleList_menu')
end)

local function vehicleImpound()
    if not hasStarted then return end

    ---@type table<string, Vehicle>, number
    local vehicles, amount = lib.callback.await('fivem_parking:server:getImpoundedVehicles', false)
    if amount == 0 then
        framework.Notify(locale('no_impounded_vehicles'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
        return
    end

    local options = {
        {
            title = locale('vehicle_amount'):format(amount),
            disabled = true,
        },
    }

    for k, v in pairs(vehicles) do
        local make, name = capitalizeFirst(GetMakeNameFromVehicleModel(v.model)), capitalizeFirst(GetDisplayNameFromVehicleModel(v.model))
        options[#options + 1] = {
            menu = ('vehicleImpound_%s'):format(k),
            title = ('%s %s (%s)'):format(make, name, k),
            description = capitalizeFirst(v.location),
            metadata = {
                Fuel = v.fuel,
            },
        }

        lib.registerContext({
            id = ('vehicleImpound_%s'):format(k),
            menu = 'vehicleImpound_menu',
            title = ('%s %s (%s)'):format(make, name, k),
            options = {
                {
                    title = locale('menu_subtitle_one'),
                    description = locale('impound_description'),
                    onSelect = function(price)
                        if shared.impound.static then
                            local canPay, reason = lib.callback.await('fivem_parking:server:payFee', price, shared.impound.price, false)
                            if not canPay then
                                framework.Notify(reason, shared.notifications.duration, shared.notifications.position, 'error', shared.notifications.icons[1])
                                return
                            end

                            local success, status = spawnVehicle(k, v, shared.impound.location)
                            framework.Notify(status, shared.notifications.duration, shared.notifications.position, 'success', shared.notifications.icons[1])

                            if not success then return end

                            lib.callback.await('fivem_parking:server:payFee', price, shared.impound.price, true)
                        else
                            local canPay, reason = lib.callback.await('fivem_parking:server:payFee', price, shared.impound.price, false)
                            if not canPay then
                                framework.Notify(reason, shared.notifications.duration, shared.notifications.position, 'error', shared.notifications.icons[1])
                                return
                            end

                            ---@type vector4?
                            local location = lib.callback.await('fivem_parking:server:getParkingSpot', false)
                            if not location then
                                framework.Notify(locale('no_parking_spot'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
                                return
                            end

                            local success, status = spawnVehicle(k, v, location)
                            framework.Notify(status, shared.notifications.duration, shared.notifications.position, 'success', shared.notifications.icons[1])

                            if not success then return end

                            lib.callback.await('fivem_parking:server:payFee', price, shared.impound.price, true)
                        end
                    end,
                },
            },
        })
    end

    lib.registerContext({
        id = 'vehicleImpound_menu',
        title = locale('impounded_menu_title'),
        options = options,
    })

    framework.hideTextUI()
    framework.showContext('vehicleImpound_menu')
end

exports('vehicleImpound', vehicleImpound)
RegisterNetEvent('fivem_parking:client:openImpoundList', vehicleImpound)

AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= cache.resource then return end

    if DoesEntityExist(npc) then
        DeletePed(npc)
        npc = 0
    end

    if point then
        point:remove()
        point = nil
    end

    if useTarget then
        exports.ox_target:removeModel(shared.impound.entity.model)
    end
end)

registerEvent('fivem_parking:client:checkVehicleStats', function(date, time)
    if not hasStarted then return end

    local vehicle = cache.vehicle
    if not vehicle then
        framework.Notify(locale('not_in_vehicle'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[0])
        return
    end

    local model = GetEntityModel(vehicle)
    local make, name = capitalizeFirst(GetMakeNameFromVehicleModel(model)), capitalizeFirst(GetDisplayNameFromVehicleModel(model))

    local plate = GetVehicleNumberPlateText(vehicle)
    ---@type Vehicle?
    local registered = lib.callback.await('fivem_parking:server:getVehicleOwner', false, plate)

    local brakes = getModLevel(12)
    local engine = getModLevel(11)
    local suspension = getModLevel(15)
    local transmission = getModLevel(13)

    local turbo = IsToggleModOn(vehicle, 18)

    local engineHealth = math.ceil(GetVehicleEngineHealth(vehicle))
    local bodyHealth = math.ceil(GetVehicleBodyHealth(vehicle))

    local engineColor = engineHealth < 100 and '^1' or engineHealth < 500 and '^3' or '^2'
    local bodyColor = bodyHealth < 100 and '^1' or bodyHealth < 500 and '^3' or '^2'

    TriggerEvent('chat:addMessage', {
        template = '^4 INFO: ^0 Displaying vehicle information for the ^4 {0} {1} ^0 at ^4 {2} {3}',
        args = { make, name, date, time },
    })

    TriggerEvent('chat:addMessage', {
        template = '^4 [General] ^0 | Engine Health: {0} {1} ^0 | Body Health: {2} {3} ^0 | Registered: {4} ^0 | Plate: ^2 {5}',
        args = { engineColor, engineHealth, bodyColor, bodyHealth, registered and '^2 Yes' or '^1 No', plate },
    })

    TriggerEvent('chat:addMessage', {
        template = '^4 [Mods] ^0 | Brakes: {0} | Engine: {1} | Suspension: {2} | Transmission: {3} | {4} ^0 |',
        args = { brakes, engine, suspension, transmission, turbo and '^2 Turbo' or '^1 Turbo' },
    })
end)

---@param price number
registerEvent('fivem_parking:client:purchaseParkingSpace', function(price)
    if not hasStarted then return end

    local canPay, reason = lib.callback.await('fivem_parking:server:payFee', price, shared.garage.parking.price, false)
    if not canPay then
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, 'error', shared.notifications.icons[1])
        return
    end

    local entity = cache.vehicle or cache.ped
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)

    local location, status = lib.callback.await('fivem_parking:server:setParkingSpot', false, vec4(coords.x, coords.y, coords.z, heading))
    framework.Notify(status, shared.notifications.duration, shared.notifications.position, 'success', shared.notifications.icons[1])

    if not location then return end

    lib.callback.await('fivem_parking:server:payFee', price, shared.garage.parking.price, true)
end)

registerEvent('fivem_parking:client:storeVehicle', function()
    if not hasStarted then return end

    local vehicle = cache.vehicle
    if not vehicle or vehicle == 0 then
        framework.Notify(locale('not_in_vehicle'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[0])
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    ---@type Vehicle?
    local owner = lib.callback.await('fivem_parking:server:getVehicleOwner', false, plate)
    if not owner then
        framework.Notify(locale('not_owner'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[0])
        return
    end

    ---@type vector4?
    local location = lib.callback.await('fivem_parking:server:getParkingSpot', false)
    if not location then
        framework.Notify(locale('no_parking_spot'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
        return
    end

    if #(location.xyz - GetEntityCoords(vehicle)) > 5.0 then
        SetNewWaypoint(location.x, location.y)
        framework.Notify(locale('not_in_parking_spot'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
        return
    end

    local props = GetVehicleProperties(vehicle)
    local fuel = GetVehicleFuelLevel(vehicle)
    local body = math.ceil(GetVehicleBodyHealth(vehicle))
    local engine = math.ceil(GetVehicleEngineHealth(vehicle))

    ---@type boolean, string
    local status, reason = lib.callback.await('fivem_parking:server:setVehicleStatus', false, 'parked', plate, props, fuel, body, engine)
    if status then
        SetEntityAsMissionEntity(vehicle, false, false)
        lib.callback.await('fivem_parking:server:deleteVehicle', false, VehToNet(vehicle))
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, 'success', shared.notifications.icons[0])
    end

    if not status then
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, 'error', shared.notifications.icons[0])
        return
    end
end)

local function impoundVehicle()
    if not hasStarted then return end

    local job = framework.hasJob()
    if not job then
        framework.Notify(locale('no_access'), shared.notifications.duration, shared.notifications.position, 'error', shared.notifications.icons[1])
        return
    end

    local vehicle = cache.vehicle
    if not vehicle or vehicle == 0 then
        vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, true)
        if not vehicle or vehicle == 0 then
            framework.Notify(locale('no_nearby_vehicles'), shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[1])
            return
        end
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local data = lib.callback.await('fivem_parking:server:getVehicle', false, plate) --[[@as Vehicle?]]
    if data then
        ---@type boolean, string
        local _, reason = lib.callback.await('fivem_parking:server:setVehicleStatus', false, 'impound', plate, data.props, data.owner)
        framework.Notify(reason, shared.notifications.duration, shared.notifications.position, 'inform', shared.notifications.icons[3])
    end

    SetEntityAsMissionEntity(vehicle, false, false)
    lib.callback.await('fivem_parking:server:deleteVehicle', false, VehToNet(vehicle))
end

exports('impoundVehicle', impoundVehicle)
RegisterNetEvent('fivem_parking:client:impoundVehicle', impoundVehicle)

if GetResourceState('ox_target'):find('start') then
    exports.ox_target:addGlobalVehicle({
        {
            label = locale('impound_vehicle'),
            name = 'impound_vehicle',
            icon = 'fa-solid fa-car-burst',
            distance = 2.5,
            groups = client.jobs,
            event = 'fivem_parking:client:impoundVehicle',
        },
    })
end

--#endregion Events

--#region Threads

CreateThread(function()
    Wait(1000)
    if hasStarted then return end
    hasStarted = lib.callback.await('fivem_parking:server:hasStarted', false)
end)

if shared.impound.static then
    CreateThread(function()
        local settings = { id = shared.impound.blip.sprite, colour = shared.impound.blip.color, scale = shared.impound.blip.scale }
        impoundBlip = createBlip(settings, shared.impound.location)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(locale('impound_blip'))
        EndTextCommandSetBlipName(impoundBlip)

        ---@type CPoint
        point = lib.points.new({
            coords = shared.impound.entity.location,
            distance = shared.impound.entity.distance,
        })

        function point:onEnter()
            local model = type(shared.impound.entity.model) == 'string' and joaat(shared.impound.entity.model) or shared.impound.entity.model
            lib.requestModel(model)
            if not model then return end

            npc = CreatePed(0, model, shared.impound.entity.location.x, shared.impound.entity.location.y, shared.impound.entity.location.z, shared.impound.entity.location.w, false, true)
            SetModelAsNoLongerNeeded(shared.impound.entity.model)
            SetEntityInvincible(npc, true)
            FreezeEntityPosition(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
        end

        function point:onExit()
            if DoesEntityExist(npc) then
                DeletePed(npc)
                npc = 0
            end
        end

        if useTarget then
            exports.ox_target:addModel(shared.impound.entity.model, {
                {
                    label = locale('impound_label'),
                    name = 'impound_entity',
                    icon = 'fa-solid fa-warehouse',
                    distance = 2.5,
                    event = 'fivem_parking:client:openImpoundList',
                },
            })
        else
            local sleep = 500
            while true do
                sleep = 500
                local menuOpened = false
                local coords = GetEntityCoords(cache.ped)
                local markerLocation = shared.impound.marker.location.xyz
                local markerDistance = shared.impound.marker.distance
                if #(coords - markerLocation) < markerDistance then
                    if not menuOpened then
                        sleep = 0
                        ---@diagnostic disable-next-line: param-type-mismatch
                        DrawMarker(shared.impound.marker.type, markerLocation.x, markerLocation.y, markerLocation.z, 0.0, 0.0, 0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 20, 200, 20, 50, false, false, 2, true, nil, nil, false)
                        if not shownTextUI then
                            shownTextUI = true
                            framework.showTextUI(locale('impound_show'))
                        end

                        if IsControlJustPressed(0, 38) then
                            TriggerEvent('fivem_parking:client:openImpoundList')
                            sleep = 500
                        end

                        menuOpened = true
                    end
                else
                    if menuOpened then
                        menuOpened = false
                        framework.hideContext(false)
                    end

                    if shownTextUI then
                        shownTextUI = false
                        framework.hideTextUI()
                    end
                end

                Wait(sleep)
            end
        end
    end)
end

--#endregion Threads

SetDefaultVehicleNumberPlateTextPattern(-1, shared.miscellaneous.plateTextPattern:upper())