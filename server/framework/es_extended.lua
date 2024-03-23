local resourceName = "es_extended"

if not GetResourceState(resourceName):find("start") then return end

local _, ESX = pcall(exports.es_extended.getSharedObject) --[[@as table | false]]

if not ESX then return end

local esx = {}
local shared = lib.load("config.shared")

---@param source integer
---@return table
function esx.getPlayerId(source)
    return ESX.GetPlayerFromId(source)
end

---@param identifier string
---@return table
function esx.getPlayerIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

---@param player table
---@return string
function esx.getIdentifier(player)
    return player.identifier
end

---@param identifier string
---@return string
function esx.identifierTypeConversion(identifier)
    return identifier
end

---@param player table
---@return string
function esx.getFullName(player)
    return player.getName()
end

---@param source integer
---@return number
function esx.getMoney(source)
    local player = esx.getPlayerId(source)
    if not player then return 0 end

    return player.getMoney()
end

---@param source integer
---@param amount number
function esx.removeMoney(source, amount)
    local player = esx.getPlayerId(source)
    if not player then return end

    player.removeMoney(amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
function esx.Notify(source, message, duration, position, _type, icon)
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

return esx
