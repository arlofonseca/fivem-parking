--#region Variables

local ESX = not UseOx and exports.es_extended.getSharedObject()
if UseOx then
	assert(load(LoadResourceFile("ox_core", "imports/client.lua"), "@@ox_core/imports/client.lua"))()
end

local vehiclePropertiesSetter = UseOx and lib.setVehicleProperties or ESX.Game.SetVehicleProperties
local vehiclePropertiesGetter = UseOx and lib.getVehicleProperties or ESX.Game.GetVehicleProperties

local tempVehicle
local hasStarted = false

--#endregion Variables

--#region Functions

---Returns the string with only the first character as uppercase and lowercases the rest of the string
---@param s string
---@return string
function string.firstToUpper(s)
	return s:sub(1, 1):upper() .. s:sub(2):lower()
end

---Returns the icon of fontawesome for a vehicle type, or class if the type is not defined
---@param model? string | number
---@param _type? string
---@return string | nil
local function getVehicleIcon(model, _type)
	if not model and not _type then return end

	local icon = _type or VehicleClasses[GetVehicleClassFromName(model --[[@as string | number]])]
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
			return false, "The vehicle is already spawning"
		end
	end

	tempVehicle = plate
	lib.requestModel(data.model)

	local netVeh = lib.callback.await("vgarage:server:spawnVehicle", false, data.model, coords, plate)

	if not netVeh then
		tempVehicle = nil
		TriggerServerEvent("vgarage:server:vehicleSpawnFailed", plate)
		return false, "This vehicle is not registered, couldn't spawn it"
	end

	local attempts = 0

	while netVeh == 0 or not NetworkDoesEntityExistWithNetworkId(netVeh) do
		Wait(10)
		attempts += 1
		if attempts == 100 then
			break
		end
	end

	local vehicle = netVeh == 0 and 0 or not NetworkDoesEntityExistWithNetworkId(netVeh) and 0 or NetToVeh(netVeh)

	if not vehicle or vehicle == 0 then
		TriggerServerEvent("vgarage:server:vehicleSpawnFailed", plate, netVeh)
		tempVehicle = nil
		return false, "Failed to spawn the vehicle"
	end

	Wait(500) -- Wait for the server to completely register the vehicle
	SetVehicleNeedsToBeHotwired(vehicle, false)
	SetVehicleHasBeenOwnedByPlayer(vehicle, true)
	SetEntityAsMissionEntity(vehicle, true, true)
	SetVehicleIsStolen(vehicle, false)
	SetVehicleIsWanted(vehicle, false)
	SetVehicleOnGroundProperly(vehicle)
	SetModelAsNoLongerNeeded(data.model)
	--exports.mk_vehiclekeys:AddKey(vehicle)

	Wait(500)
	vehiclePropertiesSetter(vehicle, data.props)
	tempVehicle = nil

	return true, "Successfully spawned the vehicle"
end

---Copied from ox_lib
---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@param includePlayerVehicle? boolean Whether or not to include the player's current vehicle.
---@return number? vehicle
---@return vector3? vehicleCoords
local function getClosestVehicle(coords, maxDistance, includePlayerVehicle)
	local vehicles = GetGamePool("CVehicle")
	local closestVehicle, closestCoords
	maxDistance = maxDistance or 2.0

	for i = 1, #vehicles do
		local vehicle = vehicles[i]

		if not cache.vehicle or vehicle ~= cache.vehicle or includePlayerVehicle then
			local vehicleCoords = GetEntityCoords(vehicle)
			local distance = #(coords - vehicleCoords)

			if distance < maxDistance then
				maxDistance = distance
				closestVehicle = vehicle
				closestCoords = vehicleCoords
			end
		end
	end

	return closestVehicle, closestCoords
end

--#endregion Functions

--#region Events

RegisterNetEvent("vgarage:client:started", function()
	if GetInvokingResource() then return end

	hasStarted = true
end)

--#endregion Events

--#region Callbacks

lib.callback.register("vgarage:client:getTempVehicle", function()
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
			TriggerEvent("chat:addMessage", {
				template = "You have to be in a vehicle to do this",
			})
			return
		end

		local plate = GetVehicleNumberPlateText(vehicle)
		---@type Vehicle?
		local vehicleData = lib.callback.await("vgarage:server:getVehicleOwner", false, plate)

		if not vehicleData then
			TriggerEvent("chat:addMessage", {
				template = "You are not the owner of this vehicle",
			})
			return
		end

		---@type vector4?
		local parkingSpot = lib.callback.await("vgarage:server:getParkingSpot", false)
		if not parkingSpot then
			TriggerEvent("chat:addMessage", {
				template = "You don't have a parking spot setup, run /v buy to buy a parking spot",
			})
			return
		end

		if #(parkingSpot.xyz - GetEntityCoords(vehicle)) > 5.0 then
			SetNewWaypoint(parkingSpot.x, parkingSpot.y)
			TriggerEvent("chat:addMessage", {
				template = "You have to be at your parking spot, a waypoint has been set to it. Run /v park again at the spot to park your vehicle",
			})
			return
		end

		local props = vehiclePropertiesGetter(vehicle)
		---@type boolean, string
		local parked, reason = lib.callback.await("vgarage:server:setVehicleStatus", false, "parked", plate, props)

		if parked then
			SetEntityAsMissionEntity(vehicle, false, false)
			lib.callback.await("vgarage:server:deleteVehicle", false, VehToNet(vehicle))
		end

		TriggerEvent("chat:addMessage", {
			template = reason,
		})
	elseif action == "buy" then
		local canPay, reason = lib.callback.await("vgarage:server:payment", false, ParkingSpotPrice, false)
		if not canPay then
			TriggerEvent("chat:addMessage", {
				template = reason,
			})
			return
		end

		local entity = cache.vehicle or cache.ped
		local coords = GetEntityCoords(entity)
		local heading = GetEntityHeading(entity)
		local success, saveReason = lib.callback.await("vgarage:server:setParkingSpot", false, vec4(coords.x, coords.y, coords.z, heading))
		TriggerEvent("chat:addMessage", {
			template = saveReason,
		})

		if not success then return end

		lib.callback.await("vgarage:server:payment", false, ParkingSpotPrice, true)
	elseif action == "list" then
		---@type table<string, Vehicle>
		local vehicles, amount = lib.callback.await("vgarage:server:getVehicles", false)
		---@type vector4?
		local parkingSpot = lib.callback.await("vgarage:server:getParkingSpot", false)

		if amount == 0 then
			TriggerEvent("chat:addMessage", {
				template = "You have no vehicles",
			})
			return
		end

		local menuOptions = {
			{
				title = ("Vehicles: %s"):format(amount),
				disabled = true,
			},
		}

		for k, v in pairs(vehicles) do
			local getMenuOptions = {}

			if v.location == "parked" then
				getMenuOptions[#getMenuOptions + 1] = {
					title = "Get Vehicle",
					description = "Take the vehicle out of your garage and spawn it at the coords it was left at",
					onSelect = function()
						local canPay, reason = lib.callback.await("vgarage:server:payment", false, GetPrice, false)
						if not canPay then
							TriggerEvent("chat:addMessage", {
								template = reason,
							})
							return
						end

						if not parkingSpot then
							TriggerEvent("chat:addMessage", {
								template = "You don't have a parking spot setup, run /v buy to buy a parking spot",
							})
							return
						end

						local success, spawnReason = spawnVehicle(k, v, parkingSpot)

						TriggerEvent("chat:addMessage", {
							template = spawnReason,
						})

						if not success then return end

						lib.callback.await("vgarage:server:payment", false, GetPrice, true)
					end,
				}
			end

			if v.location == "parked" or v.location == "outside" and not cache.vehicle then
				getMenuOptions[#getMenuOptions + 1] = {
					title = "Marker",
					description = 'Set a marker to where your vehicle will spawn when you press "Get Vehicle"',
					onSelect = function()
						local coords = v.location == 'parked' and parkingSpot?.xy or v.location == 'outside' and lib.callback.await('vgarage:server:getOutsideVehicleCoords', false, k)?.xy or nil
						if not coords then
							TriggerEvent("chat:addMessage", {
								template = v.location == "outside" and "Your vehicle does not exist, meaning it's in the impound" or "You don't have a parking spot, so your vehicle can't spawn anywhere yet",
							})
							return
						end

						SetNewWaypoint(coords.x, coords.y)
						TriggerEvent("chat:addMessage", {
							template = "Waypoint set to your vehicle",
						})
					end,
				}
			end

			local make, name = GetMakeNameFromVehicleModel(v.model):firstToUpper(), GetDisplayNameFromVehicleModel(v.model):firstToUpper()
			menuOptions[#menuOptions + 1] = {
				title = ("%s %s - %s"):format(make, name, k),
				icon = getVehicleIcon(v.model, v.type),
				metadata = {
					Location = v.location:firstToUpper(),
					Coords = v.location == "impound" and ("(%s, %s, %s)"):format(ImpoundSaveCoords.x, ImpoundSaveCoords.y, ImpoundSaveCoords.z) or v.location == "parked" and parkingSpot and ("(%s,%s, %s)"):format(parkingSpot.x, parkingSpot.y, parkingSpot.z) or nil,
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
			title = "Your Vehicles",
			options = menuOptions,
		})

		lib.showContext("get_menu")
	elseif action == "impound" then
		---@type table<string, Vehicle>, number
		local vehicles, amount = lib.callback.await("vgarage:server:getImpoundedVehicles", false)

		if amount == 0 then
			TriggerEvent("chat:addMessage", {
				template = "You have no vehicles in the impound",
			})
			return
		end

		local menuOptions = {
			{
				title = ("Vehicles: %s"):format(amount),
				disabled = true,
			},
		}

		for k, v in pairs(vehicles) do
			local make, name =
				GetMakeNameFromVehicleModel(v.model):firstToUpper(),
				GetDisplayNameFromVehicleModel(v.model):firstToUpper()
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
						title = "Get Vehicle",
						description = "Take the vehicle out of the impound and spawn it at the coords it was left at",
						onSelect = function()
							local canPay, reason = lib.callback.await("vgarage:server:payment", false, ImpoundPrice, false)
							if not canPay then
								TriggerEvent("chat:addMessage", {
									template = reason,
								})
								return
							end

							local success, spawnReason = spawnVehicle(k, v, ImpoundSaveCoords)
							TriggerEvent("chat:addMessage", {
								template = spawnReason,
							})

							if not success then return end

							lib.callback.await("vgarage:server:payment", false, ImpoundPrice, true)
						end,
					},
					{
						title = "Marker",
						description = 'Set a marker to where your vehicle will spawn when you press "Get Vehicle"',
						onSelect = function()
							SetNewWaypoint(ImpoundSaveCoords.x, ImpoundSaveCoords.y)
						end,
					},
				},
			})
		end

		lib.registerContext({
			id = "impound_get_menu",
			title = "Your Impounded Vehicles",
			options = menuOptions,
		})

		lib.showContext("impound_get_menu")
	end
end, false)

RegisterCommand("impound", function()
	if not hasStarted then return end

	if UseOx then
		local data = Ox.GetPlayerData()
		if not data then return end

		local hasGroup = false

		for i = 1, #ImpoundJobs do
			if data.groups[ImpoundJobs[i]] then
				hasGroup = true
				break
			end
		end

		if not hasGroup then
			TriggerEvent("chat:addMessage", {
				template = "You don't have access to this command",
			})
			return
		end
	else
		local job = LocalPlayer.state.job
		if not job then return end

		local hasJob = false

		for i = 1, #ImpoundJobs do
			if job.name == ImpoundJobs[i] then
				hasJob = true
				break
			end
		end

		if not hasJob then
			TriggerEvent("chat:addMessage", {
				template = "You don't have access to this command",
			})
			return
		end
	end

	local vehicle = GetVehiclePedIsIn(cache.ped, false) --[[@as number?]]

	if not vehicle or vehicle == 0 then
		vehicle = getClosestVehicle(GetEntityCoords(cache.ped), 5.0)
		if not vehicle or vehicle == 0 then
			TriggerEvent("chat:addMessage", {
				template = "There is no vehicle nearby",
			})
			return
		end
	end

	local plate = GetVehicleNumberPlateText(vehicle)
	local vehicleData = lib.callback.await("vgarage:server:getVehicle", false, plate) --[[@as Vehicle?]]

	if vehicleData then
		local _, reason = lib.callback.await("vgarage:server:setVehicleStatus", false, "impound", plate, vehicleData.props, vehicleData.owner)
		TriggerEvent("chat:addMessage", {
			template = reason,
		})
	else
		TriggerEvent("chat:addMessage", {
			template = "Successfully impounded the static vehicle",
		})
	end

	SetEntityAsMissionEntity(vehicle, false, false)
	lib.callback.await("vgarage:server:deleteVehicle", false, VehToNet(vehicle))
end, false)

---@param args string[]
RegisterCommand("givevehicle", function(_, args)
	if not hasStarted then return end

	local model = args[1] --[[@as string | number]]
	local target = tonumber(args[2])

	if not args[1] or args[1] == "" or not args[2] then
		TriggerEvent("chat:addMessage", {
			template = "You need to fill in all fields of the command in the following format /givevehicle [model] [targetId]",
		})
		return
	end

	model = joaat(model)

	if not IsModelInCdimage(model) then
		TriggerEvent("chat:addMessage", {
			template = "The model {0} does not exist",
			args = { args[1] },
		})
		return
	end

	local _, reason = lib.callback.await("vgarage:server:giveVehicle", false, target, model)

	TriggerEvent("chat:addMessage", {
		template = reason,
	})
end, false)

--#endregion Commands

SetDefaultVehicleNumberPlateTextPattern(-1, PlateTextPattern:upper())

-- Fallback to check if hasStarted if the event is not triggered
CreateThread(function()
	Wait(1000)
	if hasStarted then return end

	hasStarted = lib.callback.await("vgarage:server:hasStarted", false)
end)
