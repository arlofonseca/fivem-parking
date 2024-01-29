local success = lib.checkDependency("oxmysql", "2.7.7", true)
if not success then return end

success = lib.checkDependency("ox_lib", "3.16.2", true)
if not success then return end

--#region Framework

if IsDuplicityVersion() then
	CreateThread(function() lib.load("@ox_core.imports.server") end)

	---@param source integer
	---@return table
	function GetPlayerFromId(source)
		return Ox.GetPlayer(source)
	end

	---@param identifier integer
	---@return table
	function GetPlayerFromIdentifier(identifier)
		return Ox.GetPlayerByFilter({ charId = identifier })
	end

	---@param player table
	---@return integer
	function GetIdentifier(player)
		return player.charId
	end

	---@param identifier string
	---@return number
	function IdentifierTypeConversion(identifier)
		return tonumber(identifier) --[[@as number]]
	end

	---@param player table
	---@return string
	function GetFullName(player)
		return player.firstName .. " " .. player.lastName
	end

	---@param source integer
	---@return number
	function GetMoney(source)
		return exports.ox_inventory:GetItem(source, "money", false, true) or 0
	end

	---@param source integer
	---@param amount number
	function RemoveMoney(source, amount)
		exports.ox_inventory:RemoveItem(source, "money", amount)
	end

	---@param source integer
	---@param message string
	---@param type "error" | "info" | "success"
	function Notify(source, message, icon, type)
		return lib.notify(source, {
			title = locale("notification_title"),
			duration = NotificationDuration,
			description = message,
			position = NotificationPosition,
			icon = icon,
			iconColor = NotificationIconColors[type] or "#ffffff",
		})
	end
else
	CreateThread(function() lib.load("@ox_core.imports.client") end)

	SetVehicleProperties = lib.setVehicleProperties
	GetVehicleProperties = lib.getVehicleProperties

	---@return boolean
	function HasJob()
		local data = Ox.GetPlayerData()
		if not data then return false end

		for i = 1, #Jobs do
			if data.groups[Jobs[i]] then
				return true
			end
		end

		return false
	end

	---@param message string
	---@param type "error" | "info" | "success"
	function Notify(message, icon, type)
		return lib.notify({
			title = locale("notification_title"),
			duration = NotificationDuration,
			description = message,
			position = NotificationPosition,
			icon = icon,
			iconColor = NotificationIconColors[type] or "#ffffff",
		})
	end
end

--#endregion Framework

--#region Statebag Change Handlers

if not IsDuplicityVersion() then
	AddStateBagChangeHandler("cacheVehicle", "vehicle", function(bagName, key, value)
		if not value then return end

		local networkId = tonumber(bagName:gsub("entity:", ""), 10)
		local validEntity, timeout = false, 0

		while not validEntity and timeout < 1000 do
			validEntity = NetworkDoesEntityExistWithNetworkId(networkId)
			timeout += 1
			Wait(0)
		end

		if not validEntity then
			return lib.print.warn(("^7Statebag (^3%s^7) timed out after waiting %s ticks for entity creation on %s.^0"):format(bagName, timeout, key))
		end

		Wait(500)

		local vehicle = NetworkDoesEntityExistWithNetworkId(networkId) and NetworkGetEntityFromNetworkId(networkId)
		if not vehicle or vehicle == 0 or NetworkGetEntityOwner(vehicle) ~= cache.playerId then return end

		SetVehicleOnGroundProperly(vehicle)
		SetVehicleNeedsToBeHotwired(vehicle, false)

		Entity(vehicle).state:set(key, nil, true)
	end)

	AddStateBagChangeHandler("vehicleProps", "vehicle", function(bagName, key, value)
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
end

--#endregion Statebag Change Handlers
