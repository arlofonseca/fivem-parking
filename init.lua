lib.locale()

---source https://github.com/overextended/ox_core/blob/main/shared/init.lua#L1
local success, message = lib.checkDependency("ox_lib", "3.6.1")
success, message = lib.checkDependency("oxmysql", "2.7.1")

if not success then
    return print(('^1Error: %s^0'):format(message))
end

--#region Statebag Change Handlers

AddStateBagChangeHandler("cacheVehicle", "vehicle", function(bagName, key, value)
	if not value then return end

	local networkId = tonumber(bagName:gsub("entity:", ""), 10)
	local invalidEntity, timeout = false, 0

	while not invalidEntity and timeout < 1000 do
		invalidEntity = NetworkDoesEntityExistWithNetworkId(networkId)
		timeout += 1
		Wait(0)
	end

	if not invalidEntity then
		print("^5[vgarage] ^7Statebag (^3%s^7) timed out after waiting %s ticks for entity creation on %s.^0"):format(bagName, timeout, key)
		return
	end

	Wait(500)

	local veh = NetworkDoesEntityExistWithNetworkId(networkId) and NetworkGetEntityFromNetworkId(networkId)
	if not veh or veh == 0 then return end

	if NetworkGetEntityOwner(veh) ~= cache.playerId then return end

	SetVehicleOnGroundProperly(veh)
	SetVehicleNeedsToBeHotwired(veh, false)

	Entity(veh).state:set(key, nil, true)
end)

AddStateBagChangeHandler("vehicleProps", "vehicle", function(bagName, key, value)
	if not value then return end

	local networkId = tonumber(bagName:gsub("entity:", ""), 10)
	local invalidEntity, timeout = false, 0

	while not invalidEntity and timeout < 1000 do
		invalidEntity = NetworkDoesEntityExistWithNetworkId(networkId)
		timeout += 1
		Wait(0)
	end

	if not invalidEntity then
        print("^5[vgarage] ^7Statebag (^3%s^7) timed out after waiting %s ticks for entity creation on %s.^0"):format(bagName, timeout, key)
		return
	end

	Wait(500)

	local vehicle = NetworkDoesEntityExistWithNetworkId(networkId) and NetworkGetEntityFromNetworkId(networkId)
	if not vehicle or vehicle == 0 then return end

	if NetworkGetEntityOwner(vehicle) ~= cache.playerId then return end
	if not SetVehicleProperties(vehicle, value) then return end

	Entity(vehicle).state:set(key, nil, true)
end)

--#endregion Statebag Change Handlers