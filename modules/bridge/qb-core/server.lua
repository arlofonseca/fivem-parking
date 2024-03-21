local resourceName = "qb-core"

if not GetResourceState(resourceName):find("start") then return end

local _, QBCore = pcall(exports["qb-core"].GetCoreObject) --[[@as table | false]]

if not QBCore then return end

local qb = {}
local shared = require "config.shared"

---@param source integer
---@return table
function qb.getPlayerId(source)
    return QBCore.Functions.GetPlayer(source)
end

---@param identifier string
---@return table
function qb.getPlayerIdentifier(identifier)
    return QBCore.Functions.GetPlayerFromCitizenId(identifier)
end

---@param player table
---@return string
function qb.getIdentifier(player)
    return player.PlayerData.citizenid
end

---@param identifier string
---@return string
function qb.identifierTypeConversion(identifier)
    return identifier
end

---@param player table
---@return string
function qb.getFullName(player)
    return player.PlayerData.firstname .. " " .. player.PlayerData.lastName
end

---@param source integer
---@return number
function qb.getMoney(source)
    local player = qb.getPlayerId(source)
    if not player then return 0 end

    return player.PlayerData.money.cash
end

---@param source integer
---@param amount number
function qb.removeMoney(source, amount)
    local player = qb.getPlayerId(source)
    if not player then return end

    player.Functions.removeMoney("cash", amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
function qb.Notify(source, message, duration, position, _type, icon)
    return lib.notify(source, {
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = shared.notifications.iconColors[_type] or "#ffffff",
    })
end

return qb
