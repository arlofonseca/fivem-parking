if CheckVersion then
	lib.versionCheck("bebomusa/bgarage")
end

-- Available options: 'oxlogger', 'DISCORD_WEBHOOK'
if Logging then
	LoggingOption = ""
end

--#region Variables

---@type table <string, Vehicle>
local vehicles = {}

---@type table <string | number, vector4>
local parkingSpots = {}
local hasStarted = false

--#endregion Variables

--#region Functions

---Add a vehicle
---@param owner string | number The identifier of the owner of the car, 'charid' for Ox, 'identifier' for ESX
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
	return vehicles[plate and string.upper(plate)]
end

exports("getVehicle", getVehicle)

---Get a vehicle by its plate and check if they're owner
---@param source integer
---@param plate string The plate number of the car
---@return Vehicle?
local function getVehicleOwner(source, plate)
	local isOwner = getVehicle(plate) and getVehicle(plate).owner == GetIdentifier(GetPlayerFromId(source))
	return isOwner and getVehicle(plate) or nil
end

exports("getVehicleOwner", getVehicleOwner)

---Get all vehicles from an owner, with an optional location filter
---@param owner string | number The identifier of the owner of the car, 'charid' for Ox, 'identifier' for ESX
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
---@param owner string | number The identifier of the owner of the car, 'charid' for Ox, 'identifier' for ESX
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

	if status == "parked" and StorePrice ~= -1 then
		if GetMoney(ply.source) < StorePrice then
			return false, locale("invalid_funds")
		end
		RemoveMoney(ply.source, StorePrice)
	end

	vehicles[plate].location = status
	vehicles[plate].props = props or {}

	if Debug then
		print(json.encode(status))
		print(json.encode(props))
	end

	return true, status == "parked" and locale("successfully_parked") or status == "impound" and locale("successfully_impounded") or ""
end

exports("setVehicleStatus", setVehicleStatus)

---source https://github.com/Qbox-project/qbx-core/blob/main/modules/utils.lua#L106
local stringCharset = {}
local numberCharset = {}

for i = 48, 57 do
	numberCharset[#numberCharset + 1] = string.char(i)
end

for i = 65, 90 do
	stringCharset[#stringCharset + 1] = string.char(i)
end

local globalCharset = {}

for i = 1, #stringCharset do
	globalCharset[#globalCharset + 1] = stringCharset[i]
end

for i = 1, #numberCharset do
	globalCharset[#globalCharset + 1] = numberCharset[i]
end

---Shuffle table for more randomization
for i = #globalCharset, 2, -1 do
	local j = math.random(i)
	globalCharset[i], globalCharset[j] = globalCharset[j], globalCharset[i]
end

---@return string
local function getRandomNumber(length)
	if length <= 0 then return "" end
	return getRandomNumber(length - 1) .. numberCharset[math.random(1, #numberCharset)]
end

---@return string
local function getRandomLetter(length)
	if length <= 0 then return "" end
	return getRandomLetter(length - 1) .. stringCharset[math.random(1, #stringCharset)]
end

---@return string
local function getRandomAny(length)
	if length <= 0 then return "" end
	return getRandomAny(length - 1) .. globalCharset[math.random(1, #globalCharset)]
end

---@return string
local function getRandomPlate()
	local pattern = PlateTextPattern
	local newPattern = ""
	local skipNext = false
	for i = 1, #pattern do
		if not skipNext then
			local last = i == #pattern
			local c = pattern:sub(i, i)
			local nextC = last and "\0" or pattern:sub(i + 1, i + 1)
			local curC = ""

			if c == "1" then
				curC = getRandomNumber(1)
			elseif c == "A" then
				curC = getRandomLetter(1)
			elseif c == "." then
				curC = getRandomAny(1)
			elseif c == "^" and (nextC == "1" or nextC == "A" or nextC == ".") then
				curC = nextC
				skipNext = true
			else
				curC = c
			end

			newPattern = newPattern .. curC
		else
			skipNext = false
		end
	end

	return newPattern:upper()
end

exports("getRandomPlate", getRandomPlate)

---Save all vehicles to the database
local function save()
	local queries = {}

	for k, v in pairs(vehicles) do
		if not v.temporary then
			queries[#queries + 1] = {
				query = "INSERT INTO `bgarage_vehicles` (`owner`, `plate`, `model`, `props`, `location`, `type`) VALUES (:owner, :plate, :model, :props, :location, :type) ON DUPLICATE KEY UPDATE props = :props, location = :location",
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
			values = { owner = tostring(k), coords = json.encode(v) },
		}
	end

	if table.type(queries) == "empty" then return end

	MySQL.transaction(queries, function() end)
end

exports("save", save)

--#endregion Functions

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
	local ply = GetPlayerFromId(source)
	local owner = GetIdentifier(ply)
	---@diagnostic disable-next-line: redefined-local
	local vehicles = getVehicles(owner, "outside")

	return vehicles
end)

---@param plate string
lib.callback.register("bgarage:server:getOutsideVehicle", function(_, plate)
	plate = plate and plate:upper() or plate
	if not vehicles[plate] then return end

	local pool = GetAllVehicles()

	for i = 1, #pool do
		local veh = pool[i]
		if GetVehicleNumberPlateText(veh) == plate then
			return NetworkGetNetworkIdFromEntity(veh)
		end
	end
end)

---@param plate string
lib.callback.register("bgarage:server:getOutsideVehicleCoords", function(_, plate)
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
---@param owner? string | number
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
	if Debug then
		print("Spawning vehicle: model: " .. model, "plate: " .. plate)
		print("Location: " .. coords)
	end

	plate = plate and plate:upper() or plate
	if not plate or not vehicles[plate] or not model or not coords then return end

	vehicles[plate].location = "outside"

	local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)
	if Debug then
		print("Created tempVehicle: " .. tempVehicle)
	end

	while not DoesEntityExist(tempVehicle) do
		Wait(0)
	end

	local entityType = GetVehicleType(tempVehicle)
	DeleteEntity(tempVehicle)

	if Debug then
		print("Got entity type: " .. entityType)
	end

	local veh = CreateVehicleServerSetter(model, entityType, coords.x, coords.y, coords.z, coords.w)

	while not DoesEntityExist(veh) do
		Wait(0)
	end

	SetVehicleNumberPlateText(veh, plate)

	if Debug then
		print("Spawned actual vehicle: " .. veh)
		print("Network id: " .. NetworkGetNetworkIdFromEntity(veh))
	end

	Entity(veh).state:set("cacheVehicle", true, true)

	return NetworkGetNetworkIdFromEntity(veh)
end)

---@param source integer
---@param price number
---@param remove? boolean
lib.callback.register("bgarage:server:payment", function(source, price, remove)
	if not source then return end

	if price == -1 then return true end

	if GetMoney(source) < price then
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

	local plate = getRandomPlate()
	local success = addVehicle(GetIdentifier(ply), plate, model, {}, "parked")

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
	-- Alternatively, you can come up with your own way of logging - this is just an example that was requested :peepo_shrug:
	if Logging then
		SendLog(source, "Purchased a parking space at **\n" .. coords .. "**")
	end

	return true, locale("successfully_saved_parking")
end)

lib.callback.register("bgarage:server:getParkingSpot", function(source)
	local ply = GetPlayerFromId(source)
	if not ply or not parkingSpots then return end

	local identifier = GetIdentifier(ply)
	local parkingSpot = parkingSpots[identifier]

	return parkingSpot
end)

lib.callback.register("bgarage:server:hasStarted", function()
	return hasStarted
end)

lib.callback.register("bgarage:server:getRandomPlate", function()
	return getRandomPlate()
end)

--#endregion Callbacks

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

---@param resource string
AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then return end
	save()
end)

---Onesync event that is triggered when an entity is removed from the server
---@param entity number
AddEventHandler("entityRemoved", function(entity)
	local entityType = GetEntityType(entity)
	if entityType ~= 2 then return end

	local plate = GetVehicleNumberPlateText(entity)

	local data = vehicles[plate]
	if not data or data.location ~= "outside" then return end

	data.location = "impound"
end)

--#endregion Events

--#region Threads

CreateThread(function()
	Wait(1000)

	local success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_vehicles")

	if success then
		for i = 1, #result do
			local data = result[i] --[[@as VehicleDatabase]]
			local props = json.decode(data.props) --[[@as table]]
			vehicles[data.plate] = {
				owner = UseOx and tonumber(data.owner) --[[@as number]] or data.owner,
				model = data.model,
				props = props,
				location = data.location,
				type = data.type,
			}
		end
	else
		MySQL.query.await("CREATE TABLE bgarage_vehicles (owner VARCHAR(255) NOT NULL, plate VARCHAR(8) NOT NULL, model INT NOT NULL, props LONGTEXT NOT NULL, location VARCHAR(255) DEFAULT 'impound', type VARCHAR(255) DEFAULT 'car', PRIMARY KEY (plate))")
	end

	success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_parkingspots")

	if success then
		for i = 1, #result do
			local data = result[i]
			local owner = UseOx and tonumber(data.owner) or data.owner
			local coords = json.decode(data.coords)
			parkingSpots[owner] = vec4(coords.x, coords.y, coords.z, coords.w)
		end
	else
		MySQL.query.await("CREATE TABLE bgarage_parkingspots (owner VARCHAR(255) NOT NULL, coords LONGTEXT DEFAULT NULL, PRIMARY KEY (owner))")
	end

	hasStarted = true
	TriggerClientEvent("bgarage:client:started", -1)
end)

---Scheduled to run at a specific time interval specified by `TickTime`.
lib.cron.new(("*/%s * * * *"):format(TickTime), save, { debug = Debug })

CreateThread(function()
	while true do
		Wait(500)

		local spawnedVehicles = {}
		local spawningVehicles = {}
		local pool = GetAllVehicles()
		local players = GetPlayers()

		for i = 1, #players do
			local player = players[i]
			local spawnedVehicle = lib.callback.await("bgarage:client:getTempVehicle", player)
			if spawnedVehicle then
				spawningVehicles[spawnedVehicle] = true
			end
		end

		for i = 1, #pool do
			if DoesEntityExist(pool[i]) then
				spawnedVehicles[GetVehicleNumberPlateText(pool[i])] = pool[i]
			end
		end

		for k, v in pairs(vehicles) do
			if v.location == "outside" and not spawnedVehicles[k] and not spawningVehicles[k] then
				vehicles[k].location = "impound"
			end
		end
	end
end)

--#endregion Threads

--#region Commands

lib.addCommand("admincar", {
	help = locale("cmd_help"),
	restricted = AdminGroup,
}, function(source)
	if not hasStarted then return end

	local ply = GetPlayerFromId(source)
	local ped = GetPlayerPed(source)
	local vehicle = GetVehiclePedIsIn(ped, false)

	if not DoesEntityExist(vehicle) then
		return ShowNotification(source, locale("not_in_vehicle"), NotificationIcons[0], NotificationType[1])
	end

	local identifier = GetIdentifier(ply)
	local plate = GetVehicleNumberPlateText(vehicle)
	local model = GetEntityModel(vehicle)

	local added = addVehicle(identifier, plate, model, {}, "outside", "car", false)

	ShowNotification(source, added and locale("successfully_set") or locale("failed_to_set"), NotificationIcons[0], added and NotificationType[2] or NotificationType[0])
end)

--#endregion Commands

--#region Logging

if Logging then
	---@param source number
	---@param message string
	local function discordLog(source, message)
		local ply = GetPlayerFromId(source)
		local plyName = GetPlayerName(source)
		---@diagnostic disable-next-line: param-type-mismatch
		local plyIdentifier = GetPlayerIdentifierByType(source, IdentifierType)
		local plyCharacter = UseOx and (ply.firstName .. " " .. ply.lastName) or ply.getName()

		local discordId = ""

		for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
			if string.find(identifier, "discord:") then
				discordId = string.sub(identifier, 9)
				break
			end
		end

		local embed = {
			{
				color = 14925969,
				title = locale("embed_title"),
				description = message,
				fields = {
					{
						name = "**Character Name**",
						value = plyCharacter,
						inline = true,
					},
					{
						name = "**Discord**",
						value = "<@" .. discordId .. ">",
						inline = true,
					},
					{
						name = "**User**",
						value = plyName .. "\n" .. plyIdentifier .. "",
						inline = false,
					},
				},
				footer = {
					text = os.date("%H:%M ↝ %m-%d-%Y", os.time()),
				},
			},
		}

		local headers = { ["Content-Type"] = "application/json" }
		PerformHttpRequest(LoggingOption, function() end, "POST", json.encode({ username = GetCurrentResourceName(), embeds = embed }), headers)
	end

	---@param source number
	---@param message string
	function SendLog(source, message)
		if LoggingOption == "oxlogger" then
			---@param source number | string
			---@param event string
			---@param message string
			---@param vararg string
			lib.logger(source, GetCurrentResourceName(), json.encode(message))
		else
			discordLog(source, message)
		end
	end
end

--#endregion Logging

--#region Debug

if Debug then
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

		for _, debug in ipairs(actions) do
			if debug.event == event then
				TriggerClientEvent("chat:addMessage", -1, {
					template = debug.template,
					args = { UseOx and (ply.firstName .. " " .. ply.lastName) or ply.getName(), source },
				})
				break
			end
		end
	end

	for _, debug in ipairs(actions) do
		RegisterServerEvent(debug.event, function()
			actionDebug(debug.event)
		end)
	end
end

--#endregion Debug

---Do not rename this resource or touch this part of the code
local function initializeResource()
	assert(GetCurrentResourceName() == "bgarage", "^It is required to keep this resource name original, change the folder name back to 'bgarage'.^0")
	print("^5[bgarage] ^2Resource has been initialized.^0")
	print("^5[bgarage] ^2Vehicle(s) module is loaded.^0")
end

MySQL.ready(initializeResource)