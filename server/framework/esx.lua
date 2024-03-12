local resourceName = "es_extended"

if not GetResourceState(resourceName):find("start") then return end

local _, ESX = pcall(exports.es_extended.getSharedObject) --[[@as table | false]]

if not ESX then return end

local server = {}

---@param source integer
---@return table
function server.getPlayerId(source)
    return ESX.GetPlayerFromId(source)
end

---@param identifier string
---@return table
function server.getPlayerIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

---@param player table
---@return string
function server.getIdentifier(player)
    return player.identifier
end

---@param identifier string
---@return string
function server.identifierTypeConversion(identifier)
    return identifier
end

---@param player table
---@return string
function server.getFullName(player)
    return player.getName()
end

---@param source integer
---@return number
function server.getMoney(source)
    local player = server.getPlayerId(source)
    if not player then return 0 end

    return player.getMoney()
end

---@param source integer
---@param amount number
function server.removeMoney(source, amount)
    local player = server.getPlayerId(source)
    if not player then return end

    player.removeMoney(amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
---@param iconColor? string
function server.Notify(source, message, duration, position, _type, icon, iconColor)
    return lib.notify(source, {
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = iconColor,
    })
end

return server
