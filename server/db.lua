local db = {}
local shared = require "config.shared".framework
local framework = require(("server.framework.%s"):format(shared))

---@param plate string
function db.selectVehicle(plate)
    return MySQL.rawExecute.await("SELECT `owner`, FROM `character_vehicles` WHERE plate = ?", { plate })
end

---@param coords table | vector4
function db.selectParking(coords)
    return MySQL.rawExecute.await("SELECT `owner`, FROM `character_parking` WHERE coords = ?", { coords })
end

function db.createOwnedVehicles()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS character_vehicles (owner VARCHAR(255) NOT NULL, plate VARCHAR(8) NOT NULL, model INT NOT NULL, props LONGTEXT NOT NULL, type VARCHAR(255) DEFAULT 'car', location VARCHAR(255) DEFAULT 'impound', fuel INT DEFAULT 100, body FLOAT DEFAULT 1000, engine FLOAT DEFAULT 1000, PRIMARY KEY (plate))")
end

function db.createParkingLocations()
    return MySQL.query.await("CREATE TABLE IF NOT EXISTS character_parking (owner VARCHAR(255) NOT NULL, coords LONGTEXT DEFAULT NULL, PRIMARY KEY (owner))")
end

---@param vehicles table
function db.saveVehicle(vehicles)
    if type(vehicles) ~= "table" then return vehicles end

    local queries = {}

    for k, v in pairs(vehicles) do
        if not v.temporary then
            queries[#queries + 1] = {
                query = "INSERT INTO `character_vehicles` (`owner`, `plate`, `model`, `props`, `type`, `location`, `fuel`, `body`, `engine`) VALUES (:owner, :plate, :model, :props, :type, :location, :fuel, :body, :engine) ON DUPLICATE KEY UPDATE props = :props, location = :location, fuel = :fuel, body = :body, engine = :engine",
                values = {
                    owner = tostring(v.owner),
                    plate = k,
                    model = v.model,
                    props = json.encode(v.props),
                    type = v.type,
                    location = v.location,
                    fuel = v.fuel,
                    body = v.body,
                    engine = v.engine,
                },
            }
        end
    end

    if #queries == 0 then return end
    MySQL.transaction(queries, function(success, err)
        if not success then return lib.print.error(err) end
    end)
end

---@param parkingSpots table
function db.saveParkingSpot(parkingSpots)
    if type(parkingSpots) ~= "table" then return parkingSpots end

    local queries = {}

    for k, v in pairs(parkingSpots) do
        queries[#queries + 1] = {
            query = "INSERT INTO `character_parking` (`owner`, `coords`) VALUES (:owner, :coords) ON DUPLICATE KEY UPDATE coords = :coords",
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
    local success, result = pcall(MySQL.query.await, "SELECT * FROM character_vehicles")
    if not success then db.createOwnedVehicles() return end

    for i = 1, #result do
        local data = result[i] --[[@as VehicleDatabase]]
        local props = json.decode(data.props) --[[@as table]]
        vehicles[data.plate] = {
            owner = framework.identifierTypeConversion(data.owner),
            model = data.model,
            props = props,
            type = data.type,
            location = data.location,
            fuel = data.fuel,
            body = data.body,
            engine = data.engine,
        }
    end
end

---@param parkingSpots table
function db.fetchParkingLocations(parkingSpots)
    local success, result = pcall(MySQL.query.await, "SELECT * FROM character_parking")
    if not success then db.createParkingLocations() return end

    for i = 1, #result do
        local data = result[i]
        local owner = framework.identifierTypeConversion(data.owner)
        local coords = json.decode(data.coords)
        parkingSpots[owner] = vec4(coords.x, coords.y, coords.z, coords.w)
    end
end

return db