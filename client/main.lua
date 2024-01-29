--#region Variables

local tempVehicle
local hasStarted = false
local shownTextUI = false
local impoundBlip = 0
local NPC

--#endregion Variables

--#region Functions

---Returns the string with only the first character as uppercase and lowercases the rest of the string
---@param s string
---@return string
function string.firstToUpper(s)
    if not s or s == "" then return "" end
    return s:sub(1, 1):upper() .. s:sub(2):lower()
end

---@type CPoint
local point = lib.points.new(EntityCoords, EntityDistance)

function point:onEnter()
    local model = type(EntityModel) == "string" and joaat(EntityModel) or EntityModel
    local type = ("male" == "male") and 4 or 5
    lib.requestModel(model)
    NPC = CreatePed(type, model, EntityCoords.x, EntityCoords.y, EntityCoords.z, EntityCoords.w, false, true)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)
end

function point:onExit()
    DeletePed(NPC)
    NPC = nil
end

---Hide the textUI outside of the loop
local function hideTextUI()
    if not shownTextUI then return end

    lib.hideTextUI()
    shownTextUI = false
end

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

    local networkVehicle = lib.callback.await("bgarage:server:spawnVehicle", false, data.model, coords, plate)
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

    SetVehicleProperties(vehicle, data.props)
    Entity(vehicle).state:set("vehicleProps", data.props, true)
    Entity(vehicle).state:set("cacheVehicle", true, true)

    tempVehicle = nil

    return true, locale("successfully_spawned")
end

--#endregion Functions

--#region Events

---Check if the event is being invoked from another resource
RegisterNetEvent("bgarage:client:started", function()
    if GetInvokingResource() then return end
    hasStarted = true
end)

---Deleting the blip & ped when the resource stops
---@param resource string
AddEventHandler("onResourceStop", function(resource)
    if resource ~= "bgarage" or not DoesBlipExist(impoundBlip) then return end
    RemoveBlip(impoundBlip)
    DeletePed(NPC)
end)

--#endregion Events

--#region Callbacks

lib.callback.register("bgarage:client:getTempVehicle", function()
    return tempVehicle
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
            Notify(locale("not_in_vehicle"), NotificationIcons[0], NotificationType[1])
            return
        end

        local plate = GetVehicleNumberPlateText(vehicle)
        ---@type Vehicle?
        local owner = lib.callback.await("bgarage:server:getVehicleOwner", false, plate)
        if not owner then
            Notify(locale("not_owner"), NotificationIcons[0], NotificationType[1])
            lib.callback.await("bgarage:server:vehicleNotOwned", false)
            return
        end

        ---@type vector4?
        local location = lib.callback.await("bgarage:server:getParkingSpot", false)
        if not location then
            Notify(locale("no_parking_spot"), NotificationIcons[1], NotificationType[1])
            return
        end

        if #(location.xyz - GetEntityCoords(vehicle)) > 5.0 then
            SetNewWaypoint(location.x, location.y)
            Notify(locale("not_in_parking_spot"), NotificationIcons[0], NotificationType[1])
            return
        end

        local props = GetVehicleProperties(vehicle)
        ---@type boolean, string
        local status, reason = lib.callback.await("bgarage:server:setVehicleStatus", false, "parked", plate, props)
        if status then
            SetEntityAsMissionEntity(vehicle, false, false)
            lib.callback.await("bgarage:server:deleteVehicle", false, VehToNet(vehicle))
            Notify(reason, NotificationIcons[0], NotificationType[2])
        end

        if not status then
            Notify(reason, NotificationIcons[0], NotificationType[0])
            lib.callback.await("bgarage:server:storeVehicleInParkingSpace", false)
            return
        end
    elseif action == "buy" then
        local canPay, reason = lib.callback.await("bgarage:server:payment", false, ParkingSpotPrice, false)
        if not canPay then
            Notify(reason, NotificationIcons[1], NotificationType[0])
            lib.callback.await("bgarage:server:purchaseParkingSpace", false)
            return
        end

        local entity = cache.vehicle or cache.ped
        local coords = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        local success, successReason = lib.callback.await("bgarage:server:setParkingSpot", false, vec4(coords.x, coords.y, coords.z, heading))
        Notify(successReason, NotificationIcons[1], NotificationType[2])

        if not success then return end

        lib.callback.await("bgarage:server:payment", false, ParkingSpotPrice, true)
    elseif action == "list" then
        ---@type table<string, Vehicle>
        local vehicles, amount = lib.callback.await("bgarage:server:getVehicles", false)
        ---@type vector4?
        local location = lib.callback.await("bgarage:server:getParkingSpot", false)
        if amount == 0 then
            Notify(locale("no_vehicles"), NotificationIcons[0], NotificationType[1])
            return
        end

        local menuOptions = {
            {
                title = locale("vehicle_amount"):format(amount),
                disabled = true,
            },
        }

        for k, v in pairs(vehicles) do
            local getMenuOptions = {}

            if v.location == "parked" then
                getMenuOptions[#getMenuOptions + 1] = {
                    title = locale("menu_subtitle_one"),
                    description = locale("menu_description_one"),
                    onSelect = function()
                        local canPay, reason = lib.callback.await("bgarage:server:payment", false, GetPrice, false)
                        if not canPay then
                            Notify(reason, NotificationIcons[0], NotificationType[0])
                            lib.callback.await("bgarage:server:retrieveVehicleFromList", false)
                            return
                        end

                        if not location then
                            Notify(locale("no_parking_spot"), NotificationIcons[1], NotificationType[1])
                            return
                        end

                        local success, spawnReason = spawnVehicle(k, v, location)
                        Notify(spawnReason, NotificationIcons[0], NotificationType[2])

                        if not success then return end

                        lib.callback.await("bgarage:server:payment", false, GetPrice, true)
                    end,
                }
            end

            if v.location == "parked" or v.location == "outside" and not cache.vehicle then
                getMenuOptions[#getMenuOptions + 1] = {
                    title = locale("menu_subtitle_two"),
                    description = locale("menu_description_two"),
                    onSelect = function()
                        local coords = v.location == "parked" and location?.xy or v.location == "outside" and lib.callback.await("bgarage:server:getVehicleCoords", false, k)?.xy or nil
                        if not coords then
                            Notify(
                            v.location == "outside" and locale("vehicle_doesnt_exist") or locale("no_parking_spot"), NotificationIcons[0] or NotificationIcons[1], NotificationType[1])
                            return
                        end

                        if coords then
                            SetNewWaypoint(coords.x, coords.y)
                            Notify(locale("set_waypoint"), NotificationIcons[1], NotificationType[1])
                            return
                        end
                    end,
                }
            end

            local make, name = GetMakeNameFromVehicleModel(v.model):firstToUpper(), GetDisplayNameFromVehicleModel(v.model):firstToUpper()
            menuOptions[#menuOptions + 1] = {
                title = ("%s %s - %s"):format(make, name, k),
                icon = getVehicleIcon(v.model, v.type),
                metadata = {
                    Location = v.location:firstToUpper(), Coords = v.location == "impound" and ("(%s, %s, %s)"):format(ImpoundCoords.x, ImpoundCoords.y, ImpoundCoords.z) or v.location == "parked" and location and ("(%s,%s, %s)"):format(location.x, location.y, location.z) or nil,
                },

                menu = table.type(getMenuOptions) ~= "empty" and v.location ~= "impound" and ("get_%s"):format(k) or nil,
            }

            if table.type(getMenuOptions) ~= "empty" then
                lib.registerContext({
                    id = ("get_%s"):format(k),
                    title = ("%s %s - %s"):format(make, name, k),
                    menu = "get_menu",
                    options = getMenuOptions,
                })
            end
        end

        lib.registerContext({
            id = "get_menu",
            title = locale("vehicle_menu_title"),
            options = menuOptions,
        })

        hideTextUI()
        lib.showContext("get_menu")
    end
end, false)

RegisterCommand("impound", function()
    if not hasStarted then return end

    local currentJob = HasJob()
    if not currentJob then
        return Notify(locale("no_access"), NotificationIcons[1], NotificationType[0])
    end

    local vehicle = GetVehiclePedIsIn(cache.ped, false) --[[@as number?]]
    if not vehicle or vehicle == 0 then
        vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, true)
        if not vehicle or vehicle == 0 then
            Notify(locale("no_nearby_vehicles"), NotificationIcons[0], NotificationType[1])
            return
        end
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local data = lib.callback.await("bgarage:server:getVehicle", false, plate) --[[@as Vehicle?]]

    if data then
        local _, reason = lib.callback.await("bgarage:server:setVehicleStatus", false, "impound", plate, data.props, data.owner)
        Notify(reason, NotificationIcons[1], NotificationType[1])
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
        Notify(locale("invalid_format"), NotificationIcons[1], NotificationType[1])
        return
    end

    local model = joaat(modelStr)

    if not IsModelInCdimage(model) then
        Notify(locale("invalid_model"), NotificationIcons[0], NotificationType[0])
        return
    end

    local _, reason = lib.callback.await("bgarage:server:giveVehicle", false, target, model)
    Notify(reason, NotificationIcons[1], NotificationType[1])
end, UseAces)

--#endregion Commands

--#region Exports

if UseOxTarget then
    exports.ox_target:addGlobalVehicle({
        {
            name = "impound_vehicle",
            icon = OxTargetIcon,
            label = locale("impound_vehicle"),
            command = "impound",
            distance = 2.5,
        },
    })

    ---@TODO: Access the vehicle impound menu with ox_target export using the impound entity
end

--#endregion Exports

--#region Threads

---Fallback to check if hasStarted if the event is not triggered
CreateThread(function()
    Wait(1000)
    if hasStarted then return end
    hasStarted = lib.callback.await("bgarage:server:hasStarted", false)
end)

---@TODO: Create a function for the impound menu / add config option to use lib.textui OR ox_target to retrieve vehicles from the impound
CreateThread(function()
    impoundBlip = AddBlipForCoord(ImpoundCoords.x, ImpoundCoords.y, ImpoundCoords.z)
    SetBlipSprite(impoundBlip, ImpoundSprite)
    SetBlipAsShortRange(impoundBlip, true)
    SetBlipColour(impoundBlip, ImpoundSpriteColor)
    SetBlipScale(impoundBlip, ImpoundSpriteScale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(locale("impound_blip"))
    EndTextCommandSetBlipName(impoundBlip)

    local sleep = 500
    while true do
        sleep = 500
        local menuOpened = false
        if #(GetEntityCoords(cache.ped) - MarkerCoords.xyz) < MarkerDistance then
            if not menuOpened then
                sleep = 0
                ---@diagnostic disable-next-line: param-type-mismatch
                DrawMarker(ImpoundMarker, MarkerCoords.x, MarkerCoords.y, MarkerCoords.z, 0.0, 0.0, 0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 20, 200, 20, 50, false, true, 2, false, nil, nil, false)
                if not shownTextUI then
                    lib.showTextUI(locale("impound_show"))
                    shownTextUI = true
                end

                if IsControlJustPressed(0, 38) then
                    sleep = 500
                    ---@type table<string, Vehicle>, number
                    local vehicles, amount = lib.callback.await("bgarage:server:getImpoundedVehicles", false)
                    if amount ~= 0 then
                        local menuOptions = {
                            {
                                title = locale("vehicle_amount"):format(amount),
                                disabled = true,
                            },
                        }

                        for k, v in pairs(vehicles) do
                            local make, name = GetMakeNameFromVehicleModel(v.model):firstToUpper(), GetDisplayNameFromVehicleModel(v.model):firstToUpper()
                            menuOptions[#menuOptions + 1] = {
                                title = ("%s %s - %s"):format(make, name, k),
                                icon = getVehicleIcon(v.model, v.type),
                                metadata = { Location = v.location:firstToUpper() },
                                menu = ("impound_get_%s"):format(k),
                            }

                            lib.registerContext({
                                id = ("impound_get_%s"):format(k),
                                title = ("%s %s - %s"):format(make, name, k),
                                menu = "impound_get_menu",
                                options = {
                                    {
                                        title = locale("menu_subtitle_one"),
                                        description = locale("menu_description_one"),
                                        onSelect = function()
                                            local canPay, reason = lib.callback.await("bgarage:server:payment", false, ImpoundPrice, false)
                                            if not canPay then
                                                Notify(reason, NotificationIcons[1], NotificationType[0])
                                                lib.callback.await("bgarage:server:retrieveVehicleFromImpound", false)
                                                return
                                            end

                                            local success, spawnReason = spawnVehicle(k, v, ImpoundCoords)
                                            Notify(spawnReason, NotificationIcons[0], NotificationType[2])

                                            if not success then return end

                                            lib.callback.await("bgarage:server:payment", false, ImpoundPrice, true)
                                        end,
                                    },
                                    {
                                        title = locale("menu_subtitle_two"),
                                        description = locale("menu_description_two"),
                                        onSelect = function()
                                            SetNewWaypoint(ImpoundCoords.x, ImpoundCoords.y)
                                        end,
                                    },
                                },
                            })
                        end

                        lib.registerContext({
                            id = "impound_get_menu",
                            title = locale("impounded_menu_title"),
                            onClose = function()
                                menuOpened = false
                            end,
                            options = menuOptions,
                        })

                        lib.hideTextUI()
                        shownTextUI = false

                        lib.showContext("impound_get_menu")
                        menuOpened = true
                    else
                        Notify(locale("no_impounded_vehicles"), NotificationIcons[0], NotificationType[1])
                    end
                end
            end
        else
            if menuOpened then
                menuOpened = false
                lib.hideContext(false)
            end

            if shownTextUI then
                lib.hideTextUI()
                shownTextUI = false
            end
        end
        Wait(sleep)
    end
end)

--#endregion Threads

SetDefaultVehicleNumberPlateTextPattern(-1, PlateTextPattern:upper())
