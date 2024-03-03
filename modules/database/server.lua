local db = {}
local config = require "config"
local framework = require(("modules.bridge.%s.server"):format(config.framework))

local Query = {
    INSERT_VEHICLES = "INSERT INTO `bgarage_owned_vehicles` (`owner`, `plate`, `model`, `props`, `location`, `type`) VALUES (:owner, :plate, :model, :props, :location, :type) ON DUPLICATE KEY UPDATE props = :props, location = :location",
    INSERT_PARKING = "INSERT INTO `bgarage_parking_locations` (`owner`, `coords`) VALUES (:owner, :coords) ON DUPLICATE KEY UPDATE coords = :coords",
    SELECT_VEHICLES = "SELECT * FROM bgarage_owned_vehicles",
    SELECT_PARKING = "SELECT * FROM bgarage_parking_locations",
}

function db.check(query)
    return table.type(query) ~= "empty"
end

---@param owner number | string
---@param plate string
---@param model string | number
---@param props? table
---@param location? 'outside' | 'parked' | 'impound'
---@param vehicleType string
function db.saveVehicles(owner, plate, model, props, location, vehicleType)
    if not db.check(Query.INSERT_VEHICLES) then return end

    local properties = type(props) == "table" and json.encode(props) or nil
    local values = { owner = tostring(owner), plate = plate, model = model, props = properties, location = location, type = vehicleType }

    MySQL.query.await(Query.INSERT_VEHICLES, values)
end

---@param owner string | number
---@param coords table
function db.saveParkingSpots(owner, coords)
    if not db.check(Query.INSERT_PARKING) then return end

    local coordinates = type(coords) == "table" and json.encode(coords) or nil
    local values = { owner = tostring(owner), coords = coordinates }

    MySQL.query.await(Query.INSERT_PARKING, values)
end

---@param vehicles table
function db.fetchOwnedVehicles(vehicles)
    local success, result = pcall(MySQL.query.await, Query.SELECT_VEHICLES)

    if success then
        for i = 1, #result do
            local data = result[i] --[[@as VehicleDatabase]]
            local props = json.decode(data.props) --[[@as table]]
            vehicles[data.plate] = {
                owner = framework.identifierTypeConversion(data.owner),
                model = data.model,
                props = props,
                location = data.location,
                type = data.type,
            }
        end
    else
        db.createOwnedVehicles()
    end
end

---@param parkingSpots table
function db.fetchParkingLocations(parkingSpots)
    local success, result = pcall(MySQL.query.await, Query.SELECT_PARKING)

    if success then
        for i = 1, #result do
            local data = result[i]
            local owner = framework.identifierTypeConversion(data.owner)
            local coords = json.decode(data.coords)
            parkingSpots[owner] = vec4(coords.x, coords.y, coords.z, coords.w)
        end
    else
        db.createParkingLocations()
    end
end

---For those who don't execute the queries in `sql/install.sql`
function db.createOwnedVehicles()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS bgarage_owned_vehicles (owner VARCHAR(255) NOT NULL, plate VARCHAR(8) NOT NULL, model INT NOT NULL, props LONGTEXT NOT NULL, location VARCHAR(255) DEFAULT 'impound', type VARCHAR(255) DEFAULT 'car', PRIMARY KEY (plate))")
end

function db.createParkingLocations()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS bgarage_parking_locations (owner VARCHAR(255) NOT NULL, coords LONGTEXT DEFAULT NULL, PRIMARY KEY (owner))")
end

return db
