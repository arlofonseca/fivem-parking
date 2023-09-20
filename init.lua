local success = lib.checkDependency("oxmysql", "2.7.4", true)
if not success then return end

success = lib.checkDependency("ox_lib", "3.9.1", true)
if not success then return end

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
			return print(("^5[bgarage] ^7Statebag (^3%s^7) timed out after waiting %s ticks for entity creation on %s.^0"):format(bagName, timeout, key))
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
			return print(("^5[bgarage] ^7Statebag (^3%s^7) timed out after waiting %s ticks for entity creation on %s.^0"):format(bagName, timeout, key))
		end

		Wait(500)

		local vehicle = NetworkDoesEntityExistWithNetworkId(networkId) and NetworkGetEntityFromNetworkId(networkId)
		if not vehicle or vehicle == 0 or NetworkGetEntityOwner(vehicle) ~= cache.playerId or not SetVehicleProperties(vehicle, value) then return end

		Entity(vehicle).state:set(key, nil, true)
	end)
end

--#endregion Statebag Change Handlers