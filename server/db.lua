local db = {}
local config = require "config"
local framework = require(("modules.bridge.%s.server"):format(config.framework))

---@param plate string
function db.selectVehicle(plate)
    return MySQL.rawExecute.await("SELECT `owner`, FROM `bgarage_owned_vehicles` WHERE plate = ?", { plate })
end

---@param coords table
function db.selectParking(coords)
    return MySQL.rawExecute.await("SELECT `owner`, FROM `bgarage_parking_locations` WHERE coords = ?", { coords })
end

function db.createOwnedVehicles()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS bgarage_owned_vehicles (owner VARCHAR(255) NOT NULL, plate VARCHAR(8) NOT NULL, model INT NOT NULL, props LONGTEXT NOT NULL, location VARCHAR(255) DEFAULT 'impound', type VARCHAR(255) DEFAULT 'car', PRIMARY KEY (plate))")
end

function db.createParkingLocations()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS bgarage_parking_locations (owner VARCHAR(255) NOT NULL, coords LONGTEXT DEFAULT NULL, PRIMARY KEY (owner))")
end

---@param vehicles table[]
function db.saveVehicle(vehicles)
    if type(vehicles) ~= "table" then return vehicles end

    local queries = {}

    for k, v in pairs(vehicles) do
        if not v.temporary then
            queries[#queries + 1] = {
                query = "INSERT INTO `bgarage_owned_vehicles` (`owner`, `plate`, `model`, `props`, `location`, `type`) VALUES (:owner, :plate, :model, :props, :location, :type) ON DUPLICATE KEY UPDATE props = :props, location = :location",
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

    if #queries == 0 then return end
    MySQL.transaction(queries, function(success, err)
        if not success then return lib.print.error(err) end
    end)
end

---@param parkingSpots table[]
function db.saveParkingSpot(parkingSpots)
    if type(parkingSpots) ~= "table" then return parkingSpots end

    local queries = {}

    for k, v in pairs(parkingSpots) do
        queries[#queries + 1] = {
            query = "INSERT INTO `bgarage_parking_locations` (`owner`, `coords`) VALUES (:owner, :coords) ON DUPLICATE KEY UPDATE coords = :coords",
            values = {
                owner = tostring(k),
                coords = json.encode(v),
            },
        }
    end

    if #queries == 0 then return end
    MySQL.transaction(queries, function(success, err)
        if not success then return lib.print.error(err) end
    end)
end

---@param vehicles table
function db.fetchOwnedVehicles(vehicles)
    local success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_owned_vehicles")
    if not success then db.createOwnedVehicles() return end

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
end

---@param parkingSpots table
function db.fetchParkingLocations(parkingSpots)
    local success, result = pcall(MySQL.query.await, "SELECT * FROM bgarage_parking_locations")
    if not success then db.createParkingLocations() return end

    for i = 1, #result do
        local data = result[i]
        local owner = framework.identifierTypeConversion(data.owner)
        local coords = json.decode(data.coords)
        parkingSpots[owner] = vec4(coords.x, coords.y, coords.z, coords.w)
    end
end

return db
