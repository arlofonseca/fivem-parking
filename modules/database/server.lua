local database = {}
local config = require "config"
local framework = require(("modules.bridge.%s.server"):format(config.framework))

---@param owner number | string
---@param plate string
---@param model string | number
---@param props? table
---@param location? 'outside' | 'parked' | 'impound'
---@param vehicleType string
function database.saveVehicles(owner, plate, model, props, location, vehicleType)
    local query = "INSERT INTO `bgarage_owned_vehicles` (`owner`, `plate`, `model`, `props`, `location`, `type`) VALUES (:owner, :plate, :model, :props, :location, :type) ON DUPLICATE KEY UPDATE props = :props, location = :location"
    local values = {
        owner = tostring(owner),
        plate = plate,
        model = model,
        props = json.encode(props),
        location = location,
        type = vehicleType,
    }

    if table.type(query --[[@as table]]) == "empty" then return end
    MySQL.query.await(query, values)
end

---@param owner string | number
---@param coords table
function database.saveParkingSpots(owner, coords)
    local query = "INSERT INTO `bgarage_parking_locations` (`owner`, `coords`) VALUES (:owner, :coords) ON DUPLICATE KEY UPDATE coords = :coords"
    local values = {
        owner = tostring(owner),
        coords = json.encode(coords),
    }

    if table.type(query --[[@as table]]) == "empty" then return end
    MySQL.query.await(query, values)
end

---@param vehicles table
function database.fetchOwnedVehicles(vehicles)
    local success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_owned_vehicles")

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
        database.createOwnedVehicles()
    end
end

---@param parkingSpots table
function database.fetchParkingLocations(parkingSpots)
    local success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_parking_locations")

    if success then
        for i = 1, #result do
            local data = result[i]
            local owner = framework.identifierTypeConversion(data.owner)
            local coords = json.decode(data.coords)
            parkingSpots[owner] = vec4(coords.x, coords.y, coords.z, coords.w)
        end
    else
        database.createParkingLocations()
    end
end

---For those who don't execute the queries in `sql/install.sql`
function database.createOwnedVehicles()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS bgarage_owned_vehicles (owner VARCHAR(255) NOT NULL, plate VARCHAR(8) NOT NULL, model INT NOT NULL, props LONGTEXT NOT NULL, location VARCHAR(255) DEFAULT 'impound', type VARCHAR(255) DEFAULT 'car', PRIMARY KEY (plate))")
end

function database.createParkingLocations()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS bgarage_parking_locations (owner VARCHAR(255) NOT NULL, coords LONGTEXT DEFAULT NULL, PRIMARY KEY (owner))")
end

return database
