---@todo fix 
local server = {}
local config = require "config"

---@param source integer
---@return table | boolean
function server.getPlayerId(source)
    local src = GetPlayerPed(source)
    if not src then return false end
    return { playerId = source, ped = src }
end

---@param identifier integer
---@return table | nil
function server.getPlayerIdentifier(identifier)
    local value = GetPlayerIdentifierByType(server.getPlayerId(source), identifier)
    if value then return { [identifier] = value } end
    return nil
end

---@param player table
---@return integer | nil
function server.getIdentifier(player)
    if not player then return nil end
    local table = server.getPlayerIdentifier(player)
    if table then
        local value = table[1]
        if type(value) == "number" then
            return value
        end
    end
    return nil
end

---@param identifier string
---@return number
function server.identifierTypeConversion(identifier)
    return tonumber(identifier) --[[@as number]]
end

---@param player table
---@return string
function server.getFullName(player)
    return GetPlayerName(player)
end

---@param source integer
---@return number
function server.getMoney(source)
    return exports.ox_inventory:GetItem(source, "money", false, true) or 0
end

---@param source integer
---@param amount number
function server.removeMoney(source, amount)
    exports.ox_inventory:RemoveItem(source, "money", amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
function server.Notify(source, message, duration, position, _type, icon)
    return lib.notify(source, {
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = config.notifications.iconColors[_type] or "#ffffff",
    })
end

return server
